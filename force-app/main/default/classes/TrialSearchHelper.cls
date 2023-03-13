/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class TrialSearchHelper {
    //Site Type
    public static final String QCARE_TYPE = '00';

    //COI
    private static final String COI_REC_TYPE = 'Condition_of_Interests';

    //Queue
    private static final String QUEUE = 'Queue';
    private static final String PEH_CASE_QUEUE_NAME = 'PEH Case Queue';

    static {
        ClassFactory.setCacheable(true);
    }

    private DatabaseProxy proxy {
        get {
            if (proxy == null) {
                proxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
            }
            return proxy;
        }
        private set;
    }

    public TrialSearchContainerRemote.TrialSearchContainer getInitTrialSearchContainer() {
        TrialSearchContainerRemote.TrialSearchContainer trialSearchContainer = this.getTrialSearchContainer(
            null,
            true,
            true
        );
        trialSearchContainer.participant = this.getParticipant();
        return trialSearchContainer;
    }

    public TrialSearchContainerRemote.TrialSearchContainer getTrialSearchContainer(
        List<Therapeutic_Area_Patient__c> taps,
        Boolean isEnrolling,
        Boolean isNotYetEnrolling
    ) {
        TrialSearchContainerRemote.TrialSearchContainer trialSearchContainer = new TrialSearchContainerRemote.TrialSearchContainer();
        List<Therapeutic_Area_Patient__c> therapeuticAreaPatients = taps != null
            ? taps
            : this.getTherapeuticAreaPatients();
        Set<Id> taId = new Set<Id>();
        if (!therapeuticAreaPatients.isEmpty()) {
            for (Therapeutic_Area_Patient__c tap : therapeuticAreaPatients) {
                if (tap.Therapeutic_Area__r.Therapeutic_Area__c != null) {
                    taId.add(tap.Therapeutic_Area__r.Therapeutic_Area__c);
                }
            }
            trialSearchContainer.taps = therapeuticAreaPatients;
        } else {
            trialSearchContainer.taps = new List<Therapeutic_Area_Patient__c>();
        }

        if (
            !isEnrolling && !isNotYetEnrolling ||
            (!therapeuticAreaPatients.isEmpty() && taId.isEmpty())
        ) {
            return trialSearchContainer;
        }
        List<Clinical_Trial_Profile__c> ctps = this.getCtps(taId, isEnrolling, isNotYetEnrolling);
        List<Clinical_Trial_Profile__c> ctpsLanguageApprove = this.getCtpsLanguageApprove(ctps);
        if (ctpsLanguageApprove.isEmpty()) {
            return trialSearchContainer;
        }
        Set<Id> taIds = new Set<Id>();
        for (Clinical_Trial_Profile__c ctp : ctpsLanguageApprove) {
            if (ctp.Therapeutic_Area__c != null) {
                taIds.add(ctp.Therapeutic_Area__c);
            }
        }
        List<TrialSearchContainerRemote.TrialTDO> trialTDOS = this.getTrialTDOs(
            ctpsLanguageApprove
        );
        trialSearchContainer.trialTDOs = trialTDOS;
        return trialSearchContainer;
    }

    public List<Therapeutic_Area__c> searchFilteredTherapeuticAreas(
        String searchText,
        List<String> selectedCoisIds
    ) {
        String query =
            'SELECT ' +
            'Id, ' +
            'Name, ' +
            'Therapeutic_Area__c ' +
            'FROM Therapeutic_Area__c ' +
            'WHERE RecordType.DeveloperName = \'' +
            COI_REC_TYPE +
            '\' ' +
            this.filterCoisBySearchText(searchText) +
            this.excludeExistingCoisFromQuery(selectedCoisIds) +
            'LIMIT 5';
        List<Therapeutic_Area__c> therapeuticArea = (List<Therapeutic_Area__c>) proxy.query(
            query,
            true
        );
        return therapeuticArea;
    }

    public void createCaseAndSendNotification(
        Participant__c participant,
        Clinical_Trial_Profile__c ctp
    ) {
        Group queueGroup = this.getQueueGroup();
        Case caseContact = new Case(
            OwnerId = queueGroup.Id,
            Postal_code__c = participant.Mailing_Zip_Postal_Code__c,
            CommunityName__c = UserContext.getCurrentCommunityName(),
            Country__c = participant.Mailing_Country_Code__c,
            Date_of_Birth__c = participant.Date_of_Birth__c,
            State__c = participant.Mailing_State_Code__c,
            First_Name__c = participant.First_Name__c,
            Phone_Type__c = participant.Phone_Type__c,
            Email_address__c = participant.Email__c,
            Last_Name__c = participant.Last_Name__c,
            Gender__c = participant.Gender__c,
            Phone__c = participant.Phone__c,
            Study_Code__c = ctp.Study_Code_Name__c,
            Study__c = ctp.Id
        );
        ((DatabaseProxy) (ClassFactory.newInstance(DatabaseProxy.class)))
            .upsertRecord(caseContact, true);

        if (!Test.isRunningTest()) {
            Notification__c newNotification = new Notification__c(
                WhatId__c = caseContact.Id,
                Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_TRIAL_SEARCH_REQUEST_TYPE
            );
            List<Participant__c> partWithContId = [
                SELECT Id, Contact__c
                FROM Participant__c
                WHERE Id = :participant.Id
            ];
            if (!partWithContId.isEmpty()) {
                newNotification.Recipient__c = partWithContId.get(0).Contact__c;
            } else {
                newNotification.Email__c = participant.Email__c;
                newNotification.From__c = UserContext.getUserContactId();
            }
            insert newNotification;
        }
    }

    public void createSubscribeConnection(Id ctpId) {
        Id conId = CommunityService.getInstance().getCurrentContactId();
        List<Contact_Topic__c> existedContactTopics = [
            SELECT Id, Contact__c
            FROM Contact_Topic__c
            WHERE Contact__c = :conId AND Topic__r.TopicId__c = :ctpId
        ];
        if (existedContactTopics.isEmpty()) {
            try {
                insert new Contact_Topic__c(
                    Contact__c = conId,
                    Topic__c = NotificationService.getTopicOrCreateNew(ctpId).Id
                );
                insert new Notification__c(
                    WhatId__c = ctpId,
                    Recipient__c = conId,
                    Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_NEW_COI_CTP_TYPE
                );
            } catch (DmlException e) {
            }
        }
    }

    public void createSubscribeConnectionByCOI(List<Therapeutic_Area_Patient__c> cois) {
        List<Topic__c> topics = NotificationService.getTopicListOrCreateNewByCOI(cois);
        CommunityService communityService = (CommunityService) ClassFactory.newInstance(
            CommunityService.class
        );
        Id conId = communityService.getCurrentContactId();
        List<Contact_Topic__c> subAlreadyExist = [
            SELECT Id, Contact__c, Topic__c
            FROM Contact_Topic__c
            WHERE Contact__c = :conId
        ];
        List<Id> topicsAlreadyExist = new List<Id>();
        for (Contact_Topic__c ct : subAlreadyExist)
            topicsAlreadyExist.add(ct.Topic__c);
        List<Contact_Topic__c> newContactTopics = new List<Contact_Topic__c>();
        for (Topic__c t : topics) {
            if (!topicsAlreadyExist.contains(t.Id)) {
                newContactTopics.add(new Contact_Topic__c(Contact__c = conId, Topic__c = t.Id));
            }
        }
        try {
            insert newContactTopics;
        } catch (DmlException e) {
        }
    }

    public Boolean isCtpEnrolling(Clinical_Trial_Profile__c ctp) {
        return ctp.Override_Recruitment_Status__c ==
            TrialSearchWhereClauseFactory.ACTIVELY_ENROLLING ||
            (String.isBlank(ctp.Override_Recruitment_Status__c) &&
            (ctp.Recruitment_Status__c == TrialSearchWhereClauseFactory.ENROLLING ||
            ctp.Recruitment_Status__c == TrialSearchWhereClauseFactory.OPEN_TO_ENROLLMENT));
    }

    private Clinical_Trial_Profile__c getClinicalTrialProfileById(Id ctpId) {
        String query =
            'SELECT Id' +
            ', Study_Code_Name__c ' +
            'FROM Clinical_Trial_Profile__c ' +
            'WHERE Id = \'' +
            ctpId +
            '\'';
        List<Clinical_Trial_Profile__c> ctps = (List<Clinical_Trial_Profile__c>) proxy.query(
            query,
            true
        );
        return ctps[0];
    }

    private String excludeExistingCoisFromQuery(List<String> selectedCoisIds) {
        String filter = '';
        if (selectedCoisIds != null && !selectedCoisIds.isEmpty()) {
            filter = 'AND Id NOT IN (\'' + String.join(selectedCoisIds, '\',\'') + '\') ';
        }
        return filter;
    }

    private String filterCoisBySearchText(String searchText) {
        String filter = '';
        if (!String.isBlank(searchText)) {
            filter += 'AND Name LIKE \'%' + searchText + '%\' ';
        }
        return filter;
    }

    private List<Clinical_Trial_Profile__c> getCtpsLanguageApprove(
        List<Clinical_Trial_Profile__c> ctps
    ) {
        List<Clinical_Trial_Profile__c> ctpsLanguageApprove = new List<Clinical_Trial_Profile__c>();
        for (Clinical_Trial_Profile__c ctp : ctps)
           for (Study_Site__c ss : ctp.Study_Site_Profiles__r) {
                ctpsLanguageApprove.add(ctp);
                break;
            }
        return ctpsLanguageApprove;
    }

    private List<TrialSearchContainerRemote.TrialTDO> getTrialTDOs(
        List<Clinical_Trial_Profile__c> CTPs
    ) {
        List<Id> ctpIdsForTopics = new List<Id>();
        //        List<Id> ctpIdsForCases = new List<Id>();
        for (Clinical_Trial_Profile__c ctp : CTPs) {
            if (!isCtpEnrolling(ctp))
                ctpIdsForTopics.add(ctp.Id);
        }

        List<Contact_Topic__c> contactTopics = [
            SELECT Topic__r.TopicId__c
            FROM Contact_Topic__c
            WHERE
                Topic__r.TopicId__c IN :ctpIdsForTopics
                AND Contact__c = :CommunityService.getInstance().getCurrentContactId()
        ];

        //        List<Contact> currentContact = [
        //                SELECT Id,Email
        //                FROM Contact
        //                WHERE Id = :CommunityService.getInstance().getCurrentContactId()
        //                LIMIT 1
        //        ];
        //
        //        List<Case> cases = [
        //                SELECT Id, Study__c, Email_address__c
        //                FROM Case
        //                WHERE Study__c IN :ctpIdsForCases
        //                AND Email_address__c = :currentContact.get(0).Email
        //        ];
        //
        //        List<Id> enrolledCTPByCurrentContact = new List<Id>();
        //        for (Case oneCase : cases) enrolledCTPByCurrentContact.add(oneCase.Study__c);

        //        List<Clinical_Trial_Profile__c> suitableStudies = new List<Clinical_Trial_Profile__c>();
        //        for(Clinical_Trial_Profile__c ctp : CTPs) {
        //            if(!enrolledCTPByCurrentContact.contains(ctp.Id)) suitableStudies.add(ctp);
        //        }

        List<String> existedTopics = new List<String>();
        for (Contact_Topic__c ct : contactTopics)
            existedTopics.add(ct.Topic__r.TopicId__c);

        List<TrialSearchContainerRemote.TrialTDO> trialTDOS = new List<TrialSearchContainerRemote.TrialTDO>();
        for (Clinical_Trial_Profile__c ctp : CTPs) {
            TrialSearchContainerRemote.TrialTDO tdo = new TrialSearchContainerRemote.TrialTDO();
            tdo.ctp = ctp;
            tdo.isEnrollingCTP = isCtpEnrolling(ctp);
            tdo.relatedNotificationExists = existedTopics.contains(String.valueOf(ctp.Id));
            trialTDOS.add(tdo);
        }
        return trialTDOS;
    }

    @TestVisible
    private List<Clinical_Trial_Profile__c> getCtps(
        Set<Id> taId,
        Boolean isEnrolling,
        Boolean isNotYetEnrolling
    ) {
        Set<String> contactLanguage = this.getContactLanguage();
        Set<Id> ssIds = this.getUsersQCareSiteIds();
        TrialSearchWhereClauseFactory factory = (TrialSearchWhereClauseFactory) ClassFactory.newInstance(
            TrialSearchWhereClauseFactory.class
        );
        String whereClause = factory.getInstance(
                new List<Id>(taId),
                isEnrolling,
                isNotYetEnrolling,
                ssIds
            )
            .getWhereClause();

        whereClause +=
            ' and CommunityTemplate__c != \'' +
            CommunityTemplateService.TEMPLATE_JANSSEN +
            '\'';
        String orderBy = ' ORDER BY Enrollment_Start_Date__c';
        String queryCTP =
            'SELECT ' +
            'Therapeutic_Area__c, ' +
            'Therapeutic_Area__r.Name, ' +
            'Study_Code_Name__c, ' +
            'Official_Title__c, ' +
            'Enrollment_Start_Date__c, ' +
            'Override_Recruitment_Status__c, ' +
            'Recruitment_Status__c, ' +
            'NCT_Number__c, ' +
            'Link_to_ePR_Campaign__c, ' +
            '(SELECT Id FROM Trial_Notifications__r WHERE Contact__c = \'' +
            CommunityService.getUserContact().Id +
            '\'), ' +
            '(SELECT Approved_Lng__c FROM Study_Site_Profiles__r WHERE Approved_Lng__c INCLUDES (' +
            CollectionUtil.joinByComa(CollectionUtil.wrapInApostrophes(contactLanguage)) +
            ')) ' +
            'FROM Clinical_Trial_Profile__c ';

        queryCTP += whereClause;
        queryCTP += orderBy;
        System.debug('>>getCtps query: ' + queryCTP);
        List<Clinical_Trial_Profile__c> ctps = (List<Clinical_Trial_Profile__c>) proxy.query(
            queryCTP,
            true
        );
        return ctps;
    }

    private Set<String> getContactLanguage() {
        User user = this.getUser();
        Set<String> contactLanguage = new Set<String>();
        contactLanguage.add(UserInfo.getLanguage());
        if (String.isNotBlank(user.Contact.Language__c)) {
            contactLanguage.add(user.Contact.Language__c);
        }
        if (String.isNotBlank(user.Contact.Second_Choice_Language__c)) {
            contactLanguage.add(user.Contact.Second_Choice_Language__c);
        }
        if (String.isNotBlank(user.Contact.Third_Choice_Language__c)) {
            contactLanguage.add(user.Contact.Third_Choice_Language__c);
        }
        return contactLanguage;
    }

    @TestVisible
    private List<Therapeutic_Area_Patient__c> getTherapeuticAreaPatients() {
        CommunityService cService = (CommunityService) ClassFactory.newInstance(
            CommunityService.class
        );
        String participantId = cService.getParticipantId();
        String queryTAP =
            'SELECT ' +
            'Participant__c, ' +
            'Therapeutic_Area__c , ' +
            'Therapeutic_Area__r.Therapeutic_Area__c, ' +
            'Therapeutic_Area__r.Name, ' +
            'Condition_Of_Interest_Order__c ' +
            'FROM Therapeutic_Area_Patient__c ' +
            'WHERE Condition_Of_Interest_Order__c > 0 ' +
            'AND Therapeutic_Area__r.RecordType.DeveloperName = \'' +
            TherapeuticAreaService.COI_RT_NAME +
            '\' ' +
            'AND Participant__c = \'' +
            participantId +
            '\' ' +
            'ORDER BY Condition_Of_Interest_Order__c';
        List<Therapeutic_Area_Patient__c> therapeuticAreaPatients = (List<Therapeutic_Area_Patient__c>) proxy.query(
            queryTAP,
            true
        );
        return therapeuticAreaPatients;
    }

    private Participant__c getParticipant() {
        DatabaseProxy proxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        String query =
            'SELECT ' +
            'Id, ' +
            'Gender__c, ' +
            'Mailing_State_Code__c, ' +
            'Phone_Type__c, ' +
            'Mailing_Country_Code__c, ' +
            'First_Name__c, ' +
            'Last_Name__c, ' +
            'Date_of_Birth__c, ' +
            'Birth_Year__c, ' +
            'Phone__c, ' +
            'Email__c, ' +
            'Mailing_Zip_Postal_Code__c ' +
            'FROM Participant__c ' +
            'WHERE Contact__c IN (SELECT ContactId FROM User WHERE Id = \'' +
            UserInfo.getUserId() +
            '\') ' +
            'LIMIT 1';
        List<Participant__c> participants = (List<Participant__c>) proxy.query(query, true);
        if (participants.isEmpty()) {
            return null;
        }
        return participants[0];
    }

    private User getUser() {
        String queryUser =
            'SELECT ' +
            'ContactId, ' +
            'Contact.Language__c, ' +
            'Contact.Second_Choice_Language__c, ' +
            'Contact.Third_Choice_Language__c ' +
            'FROM User ' +
            'WHERE Id = \'' +
            UserInfo.getUserId() +
            '\'';
        User user = (User) proxy.query(queryUser)[0];
        return user;
    }

    private Group getQueueGroup() {
        String query =
            'SELECT ' +
            'Id, ' +
            'Name ' +
            'FROM Group ' +
            'WHERE Type = \'' +
            QUEUE +
            '\' ' +
            'AND Name = \'' +
            PEH_CASE_QUEUE_NAME +
            '\' ' +
            'LIMIT 1';
        Group queueGroup = (Group) proxy.query(query, true)[0];
        return queueGroup;
    }

    @TestVisible
    private Set<Id> getUsersQCareSiteIds() {
        CommunityService cService = (CommunityService) ClassFactory.newInstance(
            CommunityService.class
        );
        String contactId = cService.getCurrentContactId();
        String query =
            'SELECT Id, ' +
            'Study_Site__c ' +
            'FROM Participant_Enrollment__c ' +
            'WHERE Study_Site__r.Partner_Type__c = \'' +
            QCARE_TYPE +
            '\' ' +
            'AND Participant__r.Contact__c = \'' +
            contactId +
            '\' ';
        List<Participant_Enrollment__c> participantEnrollments = (List<Participant_Enrollment__c>) proxy.query(
            query,
            true
        );
        Set<Id> ssIds = new Set<Id>();
        for (Participant_Enrollment__c pe : participantEnrollments) {
            ssIds.add(pe.Study_Site__c);
        }
        return ssIds;
    }
}
