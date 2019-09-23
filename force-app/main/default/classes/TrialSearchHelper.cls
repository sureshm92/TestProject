/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class TrialSearchHelper {

    //AssignmentRule
    private static final String QUEUE = 'Queue';
    private static final String PEH_CASE_QUEUE_NAME = 'PEH Case Queue';

    public TrialSearchContainerRemote.TrialSearchContainer getInitTrialSearchContainer() {
        TrialSearchContainerRemote.TrialSearchContainer trialSearchContainer = this.getTrialSearchContainer(null, true, true);
        DatabaseProxy proxy = ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class));
        String query = 'SELECT Id, ' +
                'Gender__c,' +
                'Mailing_State_Code__c,' +
                'Phone_Type__c,' +
                'Mailing_Country_Code__c,' +
                'Last_Name__c,' +
                'Date_of_Birth__c,' +
                'Phone__c,' +
                'Email__c,' +
                'Mailing_Zip_Postal_Code__c ' +
                'FROM Participant__c ' +
                'WHERE Contact__c IN (SELECT ContactId FROM User WHERE Id = \'' + UserInfo.getUserId() + '\') ' +
                'LIMIT 1';
        trialSearchContainer.participant = (Participant__c) proxy.query(query, true)[0];
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

        if (taId.isEmpty() || (!isEnrolling && !isNotYetEnrolling)) {
            return trialSearchContainer;
        }
        List<Clinical_Trial_Profile__c> ctps = this.getCtps(taId, proxy, isEnrolling, isNotYetEnrolling);
        Set<Id> taIds = new Set<Id>();
        for (Clinical_Trial_Profile__c ctp : ctps) {
            if (ctp.Therapeutic_Area__c != null) {
                taIds.add(ctp.Therapeutic_Area__c);
            }
        }
        List<TrialSearchContainerRemote.TrialTDO> trialTDOS = this.getTrialTDOs(ctps);
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
            filter += 'AND Id NOT IN (';
            for (String selectedCoisId : selectedCoisIds) {
                filter += '\'' + selectedCoisId + '\', ';
            }
            filter += ') ';
            filter = filter.replace(', )', ')');
            System.debug(filter);
        }
        String query = 'SELECT ' +
                'Id, ' +
                'Name, ' +
                'Therapeutic_Area__c ' +
                'FROM Therapeutic_Area__c ' +
                'WHERE RecordType.DeveloperName = \'Condition_of_Interests\' ' +
                filter +
                'LIMIT 5';
        System.debug('here ' + query);
        List<Therapeutic_Area__c> therapeuticArea = (List<Therapeutic_Area__c>) proxy.query(query, true);
        return therapeuticArea;
    }

    public void upsertTaps(List<Therapeutic_Area_Patient__c> taps) {
        DatabaseProxy proxy = ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class));
        proxy.upsertRecords(taps, false);
    }

    public void createCaseAndSendNotification(Participant__c participant, Clinical_Trial_Profile__c ctp) {
        DatabaseProxy proxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        Group queueGroup = this.getQueueGroup(proxy);
        System.debug(' queueId ===> ' + queueGroup.Id);
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
                Study_Code__c = ctp.NCT_Number__c
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
        System.debug(notification);
        proxy.upsertRecord(notification, true);
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

    @TestVisible
    private List<Clinical_Trial_Profile__c> getCtps(Set<Id> taId, DatabaseProxy proxy, Boolean isEnrolling, Boolean isNotYetEnrolling) {
        Boolean isQCare = this.isQCare(proxy);
        String whereClause = new TrialSearchWhereClauseFactory().getWhereClause(new List<Id>(taId), isEnrolling, isNotYetEnrolling, isQCare).getWhereClause();
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
                '(SELECT Id FROM Trial_Notifications__r WHERE Contact__c = \'' + CommunityService.getUserContact().Id + '\') ' +
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
                'WHERE Contact__c IN (SELECT ContactId FROM User WHERE Id = \'' + UserInfo.getUserId() + '\')';
        return (Participant__c) proxy.query(query)[0];
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
    public Boolean isCtpEnrolling(Clinical_Trial_Profile__c ctp) {
        return ctp.Override_Recruitment_Status__c == TrialSearchWhereClauseFactory.ACTIVELY_ENROLLING ||
                (String.isBlank(ctp.Override_Recruitment_Status__c) &&
                        (ctp.Recruitment_Status__c == TrialSearchWhereClauseFactory.ENROLLING ||
                                ctp.Recruitment_Status__c == TrialSearchWhereClauseFactory.OPEN_TO_ENROLLMENT)
                );
    }

    @TestVisible
    private Boolean isQCare(DatabaseProxy proxy) {
        String query = 'SELECT Id, ' +
                'Current_Participant_Enrollment__r.Study_Site__r.Partner_Type__c ' +
                'FROM Contact ' +
                'WHERE Id IN (SELECT ContactId FROM User WHERE Id = \'' + UserInfo.getUserId()  + '\')' +
                'AND Current_Participant_Enrollment__r.Study_Site__r.Site__c != NULL';
        List<Contact> contacts = (List<Contact>) proxy.query(query, true);
        if (contacts.isEmpty()) {
            return false;
        }
        return contacts[0].Current_Participant_Enrollment__r.Study_Site__r.Partner_Type__c == TrialSearchWhereClauseFactory.QCARE_TYPE;

    }

}