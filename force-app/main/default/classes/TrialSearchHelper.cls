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

    //Participant Enrollment
    private static final String PS_SENT_TO_PI = 'Referral sent to PI';
    private static final String PS_REFERRAL_ACCEPTED = 'Referral accepted';
    private static final String PS_ATTEMPT_IN_PROGRESS = 'Contact Attempt in Progress';
    private static final String PS_CONTACT_SUCCESSFUL = 'Contact Successful';
    private static final String PS_ELIGIBILITY_PASSED = 'Eligibility Passed';
    private static final String PS_SCREENING_IN_PROGRESS = 'Screening in Progress';
    private static final String PS_SCREENING_IN_COMPLETE = 'Screening Complete';
    private static final String PS_ENROLLMENT_SUCCESS = 'Enrollment success';
    private static final String PS_TREATMENT_PERIOD_STARTED = 'Treatment Period Started';
    private static final String PS_FOLLOW_UP_PEIOD_STARTED = 'Follow-Up Period Started';
    private static final String PS_PARTICIPATION_COMPLETE = 'Participation Complete';
    private static final String PS_TRIAL_COMPLETE = 'Trial Complete';
    private static final List<String> PS_ES = new List<String>{
            PS_SENT_TO_PI,
            PS_REFERRAL_ACCEPTED,
            PS_ENROLLMENT_SUCCESS,
            PS_ATTEMPT_IN_PROGRESS,
            PS_CONTACT_SUCCESSFUL,
            PS_ELIGIBILITY_PASSED,
            PS_SCREENING_IN_COMPLETE,
            PS_SCREENING_IN_PROGRESS,
            PS_TREATMENT_PERIOD_STARTED,
            PS_FOLLOW_UP_PEIOD_STARTED,
            PS_PARTICIPATION_COMPLETE,
            PS_TRIAL_COMPLETE

    };

    public TrialSearchContainerRemote.TrialSearchContainer getInitTrialSearchContainer() {
        TrialSearchContainerRemote.TrialSearchContainer trialSearchContainer = this.getTrialSearchContainer(null, true, true);
        trialSearchContainer.participant = this.getParticipant();
        return trialSearchContainer;
    }

    public TrialSearchContainerRemote.TrialSearchContainer getTrialSearchContainer(List<Therapeutic_Area_Patient__c> taps, Boolean isEnrolling, Boolean isNotYetEnrolling) {
        DatabaseProxy proxy = ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class));
        TrialSearchContainerRemote.TrialSearchContainer trialSearchContainer = new TrialSearchContainerRemote.TrialSearchContainer();

        List<Therapeutic_Area_Patient__c> therapeuticAreaPatients = taps != null ? taps : this.getTherapeuticAreaPatients(proxy);
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

        if (!isEnrolling && !isNotYetEnrolling) {
            return trialSearchContainer;
        }
        List<Clinical_Trial_Profile__c> ctps = this.getCtps(taId, proxy, isEnrolling, isNotYetEnrolling);
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
        List<TrialSearchContainerRemote.TrialTDO> trialTDOS = this.getTrialTDOs(ctpsLanguageApprove);
        trialSearchContainer.trialTDOs = trialTDOS;
        return trialSearchContainer;
    }

    public List<Therapeutic_Area__c> getFilteredTherapeuticAreas(String searchText, List<String> selectedCoisIds) {
        DatabaseProxy proxy = ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class));
        String filter = '';
        if (searchText != null && searchText != '') {
            filter += 'AND Name LIKE \'%' + searchText + '%\' ';
        }
        if (selectedCoisIds != null && !selectedCoisIds.isEmpty()) {
            filter += 'AND Id NOT IN (\'' + String.join(selectedCoisIds, '\',\'') + '\') ';
        }
        String query = 'SELECT ' +
                'Id, ' +
                'Name, ' +
                'Therapeutic_Area__c ' +
                'FROM Therapeutic_Area__c ' +
                'WHERE RecordType.DeveloperName = \'' + COI_REC_TYPE + '\' ' +
                filter +
                'LIMIT 5';
        List<Therapeutic_Area__c> therapeuticArea = (List<Therapeutic_Area__c>) proxy.query(query, true);
        return therapeuticArea;
    }

    public void createCaseAndSendNotification(Participant__c participant, Clinical_Trial_Profile__c ctp) {
        DatabaseProxy proxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        Group queueGroup = this.getQueueGroup(proxy);
        Case caseContact = new Case(
                OwnerId = queueGroup.Id,
                Postal_code__c = participant.Mailing_Zip_Postal_Code__c,
                Country__c = participant.Mailing_Country_Code__c,
                Date_of_Birth__c = participant.Date_of_Birth__c,
                State__c = participant.Mailing_State_Code__c,
                First_Name__c = participant.First_Name__c,
                Phone_Type__c = participant.Phone_Type__c,
                Email_address__c = participant.Email__c,
                Last_Name__c = participant.Last_Name__c,
                Gender__c = participant.Gender__c,
                Phone__c = participant.Phone__c,
                Study_Code__c = ctp.NCT_Number__c,
                Study__c = ctp.Id
        );
        insert caseContact;
    }

    public void createTrialNotification(Id ctpId) {
        DatabaseProxy proxy = ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class));
        Contact currentContact = CommunityService.getUserContact();
        Trial_Notification__c notification = new Trial_Notification__c(
                Contact__c = currentContact.Id
                , Clinical_Trial_Profile__c = ctpId
        );
        proxy.upsertRecord(notification, true);
    }

    public Boolean isCtpEnrolling(Clinical_Trial_Profile__c ctp) {
        return ctp.Override_Recruitment_Status__c == TrialSearchWhereClauseFactory.ACTIVELY_ENROLLING ||
                (String.isBlank(ctp.Override_Recruitment_Status__c) &&
                        (ctp.Recruitment_Status__c == TrialSearchWhereClauseFactory.ENROLLING ||
                                ctp.Recruitment_Status__c == TrialSearchWhereClauseFactory.OPEN_TO_ENROLLMENT)
                );
    }


    private List<Clinical_Trial_Profile__c> getCtpsLanguageApprove(List<Clinical_Trial_Profile__c> ctps) {
        List<Clinical_Trial_Profile__c> ctpsLanguageApprove = new List<Clinical_Trial_Profile__c>();
        for (Clinical_Trial_Profile__c ctp : ctps) {
            if (!ctp.Study_Site_Profiles__r.isEmpty()) {
                ctpsLanguageApprove.add(ctp);
            }
        }
        return ctpsLanguageApprove;
    }

    private List<TrialSearchContainerRemote.TrialTDO> getTrialTDOs(List<Clinical_Trial_Profile__c> ctps) {
        List<TrialSearchContainerRemote.TrialTDO> trialTDOS = new List<TrialSearchContainerRemote.TrialTDO>();
        for (Clinical_Trial_Profile__c ctp : ctps) {
            TrialSearchContainerRemote.TrialTDO tdo = new TrialSearchContainerRemote.TrialTDO();
            tdo.ctp = ctp;
            tdo.isEnrollingCTP = isCtpEnrolling(ctp);
            tdo.relatedNotificationExists = !ctp.Trial_Notifications__r.isEmpty();
            trialTDOS.add(tdo);
        }
        return trialTDOS;
    }

    private Set<String> getContactLanguage(DatabaseProxy proxy) {
        User user = this.getUser(proxy);
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
    private List<Clinical_Trial_Profile__c> getCtps(Set<Id> taId, DatabaseProxy proxy, Boolean isEnrolling, Boolean isNotYetEnrolling) {
        Set<String> contactLanguage = this.getContactLanguage(proxy);
        Set<Id> ssIds = this.getUsersQCareSiteIds(proxy);
        TrialSearchWhereClauseFactory factory = (TrialSearchWhereClauseFactory) ClassFactory.newInstance(TrialSearchWhereClauseFactory.class);
        String whereClause = factory.getInstance(new List<Id>(taId), isEnrolling, isNotYetEnrolling, ssIds).getWhereClause();
        String orderBy = ' ORDER BY Enrollment_Start_Date__c';
        String queryCTP = 'SELECT ' +
                'Therapeutic_Area__c, ' +
                'Therapeutic_Area__r.Name, ' +
                'Study_Code_Name__c, ' +
                'Official_Title__c, ' +
                'Enrollment_Start_Date__c, ' +
                'Override_Recruitment_Status__c, ' +
                'Recruitment_Status__c, ' +
                'NCT_Number__c, ' +
                'Link_to_ePR_Campaign__c, ' +
                '(SELECT Id FROM Trial_Notifications__r WHERE Contact__c = \'' + CommunityService.getUserContact().Id + '\'), ' +
                '(SELECT Approved_Lng__c FROM Study_Site_Profiles__r WHERE Approved_Lng__c INCLUDES (' + CollectionUtil.joinByComa(CollectionUtil.wrapInApostrophes(contactLanguage)) + ')) ' +
                'FROM Clinical_Trial_Profile__c ';

        queryCTP += whereClause;
        queryCTP += orderBy;
        List<Clinical_Trial_Profile__c> ctps = (List<Clinical_Trial_Profile__c>) proxy.query(queryCTP, true);
        return ctps;
    }

    @TestVisible
    private List<Therapeutic_Area_Patient__c> getTherapeuticAreaPatients(DatabaseProxy proxy) {
        CommunityService cService = (CommunityService) ClassFactory.newInstance(CommunityService.class);
        String participantId = cService.getParticipantId();
        String queryTAP = 'SELECT ' +
                'Participant__c, ' +
                'Therapeutic_Area__c , ' +
                'Therapeutic_Area__r.Therapeutic_Area__c, ' +
                'Therapeutic_Area__r.Name, ' +
                'Condition_Of_Interest_Order__c ' +
                'FROM Therapeutic_Area_Patient__c ' +
                'WHERE Condition_Of_Interest_Order__c > 0 ' +
                'AND Therapeutic_Area__r.RecordType.DeveloperName = \'' + TherapeuticAreaService.COI_RT_NAME + '\' ' +
                'AND Participant__c = \'' + participantId + '\' ' +
                'ORDER BY Condition_Of_Interest_Order__c';
        List<Therapeutic_Area_Patient__c> therapeuticAreaPatients = (List<Therapeutic_Area_Patient__c>) proxy.query(queryTAP, true);
        return therapeuticAreaPatients;
    }

    private Participant__c getParticipant() {
        DatabaseProxy proxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        String query = 'SELECT ' +
                'Id, ' +
                'Gender__c, ' +
                'Mailing_State_Code__c, ' +
                'Phone_Type__c, ' +
                'Mailing_Country_Code__c, ' +
                'First_Name__c, ' +
                'Last_Name__c, ' +
                'Date_of_Birth__c, ' +
                'Phone__c, ' +
                'Email__c, ' +
                'Mailing_Zip_Postal_Code__c ' +
                'FROM Participant__c ' +
                'WHERE Contact__c IN (SELECT ContactId FROM User WHERE Id = \'' + UserInfo.getUserId() + '\') ' +
                'LIMIT 1';
        return (Participant__c) proxy.query(query)[0];
    }

    private User getUser(DatabaseProxy proxy) {
        String queryUser = 'SELECT ' +
                'ContactId, ' +
                'Contact.Language__c, ' +
                'Contact.Second_Choice_Language__c, ' +
                'Contact.Third_Choice_Language__c ' +
                'FROM User ' +
                'WHERE Id = \'' + UserInfo.getUserId() + '\'';
        User user = (User) proxy.query(queryUser)[0];
        return user;
    }

    private Group getQueueGroup(DatabaseProxy proxy) {
        String query = 'SELECT ' +
                'Id, ' +
                'Name ' +
                'FROM Group ' +
                'WHERE Type = \'' + QUEUE + '\' ' +
                'AND Name = \'' + PEH_CASE_QUEUE_NAME + '\' ' +
                'LIMIT 1';
        Group queueGroup = (Group) proxy.query(query, true)[0];
        return queueGroup;
    }

    @TestVisible
    private Set<Id> getUsersQCareSiteIds(DatabaseProxy proxy) {
        CommunityService cService = (CommunityService) ClassFactory.newInstance(CommunityService.class);
        String contactId = cService.getCurrentContactId();
        String query = 'SELECT Id, ' +
                'Study_Site__c ' +
                'FROM Participant_Enrollment__c ' +
                'WHERE Study_Site__r.Partner_Type__c = \'' + QCARE_TYPE + '\' ' +
                'AND Participant__r.Contact__c = \'' + contactId + '\' ' +
                'AND Participant_Status__c IN (' + CollectionUtil.joinByComa(CollectionUtil.wrapInApostrophes(PS_ES)) + ')';
        List<Participant_Enrollment__c> participantEnrollments = (List<Participant_Enrollment__c>) proxy.query(query, true);
        Set<Id> ssIds = new Set<Id>();
        for (Participant_Enrollment__c pe : participantEnrollments) {
            ssIds.add(pe.Study_Site__c);
        }
        return ssIds;
    }

}