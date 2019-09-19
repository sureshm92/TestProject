/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class TrialSearchHelper {

    //ORS status
    public static final String ACTIVELY_ENROLLING = 'Actively Enrolling';
    public static final String ON_HOLD = 'On Hold';

    //CTMS status
    private static final String ENROLLING = 'Enrolling';
    private static final String OPEN_TO_ENROLLMENT = 'Open to Enrollment';
    private static final String PLANNING = 'Planning';
    private static final String IN_DEVELOPMENT = 'In Development';

    //AssignmentRule
    private static final String ASSIGMENT_RULE_TYPE_CASE = 'Case';
    private static final String ASSIGMENT_RULE_NAME = 'CaseRule';

    public static final List<String> ORS_STATUS_ENROLLING = new List<String>{
            ACTIVELY_ENROLLING,
            ON_HOLD
    };

    public static final List<String> CTMS_RECRUITMENT = new List<String>{
            ENROLLING,
            OPEN_TO_ENROLLMENT,
            PLANNING,
            IN_DEVELOPMENT
    };

    public static final List<String> CTMS_RECRUITMENT_ENROLLING = new List<String>{
            ENROLLING,
            OPEN_TO_ENROLLMENT
    };

    public static final List<String> CTMS_ON_HOLD = new List<String>{
            PLANNING,
            IN_DEVELOPMENT
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
        List<TrialSearchContainerRemote.TrialTDO> trialTDOS = this.getTrialTDOs(taIds, ctps, proxy);
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

    public void createCaseAndSendNotification(Participant__c participant) {
        DatabaseProxy proxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        Case caseContact = new Case(
                Postal_code__c = participant.Mailing_Zip_Postal_Code__c,
                Country__c = participant.Mailing_Country_Code__c,
                Date_of_Birth__c = participant.Date_of_Birth__c,
                State__c = participant.Mailing_State_Code__c,
                First_Name__c = participant.First_Name__c,
                Phone_Type__c = participant.Phone_Type__c,
                Email_address__c = participant.Email__c,
                Last_Name__c = participant.Last_Name__c,
                Gender__c = participant.Gender__c,
                Phone__c = participant.Phone__c
        );
        AssignmentRule ar = this.getAssignmentRule(proxy);
        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.assignmentRuleHeader.assignmentRuleId= ar.Id;
        caseContact.setOptions(dlo);
        insert caseContact;
    }

    private List<TrialSearchContainerRemote.TrialTDO> getTrialTDOs(Set<Id> taIds, List<Clinical_Trial_Profile__c> ctps, DatabaseProxy proxy) {
        List<TrialSearchContainerRemote.TrialTDO> trialTDOS = new List<TrialSearchContainerRemote.TrialTDO>();
        for (Clinical_Trial_Profile__c ctp : ctps) {
            TrialSearchContainerRemote.TrialTDO tdo = new TrialSearchContainerRemote.TrialTDO();
            tdo.ctp = ctp;
            tdo.isEnrollingCTP = isCtpEnrolling(ctp);
            trialTDOS.add(tdo);
        }
        return trialTDOS;
    }

    private Boolean isCtpEnrolling(Clinical_Trial_Profile__c ctp) {
        return ctp.Override_Recruitment_Status__c == ACTIVELY_ENROLLING ||
                (String.isBlank(ctp.Override_Recruitment_Status__c) &&
                        (ctp.Recruitment_Status__c == ENROLLING ||
                                ctp.Recruitment_Status__c == OPEN_TO_ENROLLMENT)
                );
    }

    private List<Clinical_Trial_Profile__c> getCtps(Set<Id> taId, DatabaseProxy proxy, Boolean isEnrolling, Boolean isNotYetEnrolling) {
        String whereClause = 'WHERE Therapeutic_Area__c IN ' + '(\'' + String.join(new List<Id>(taId), '\',\'') + '\') ';
        if (isEnrolling && isNotYetEnrolling) {
            whereClause += ' AND (Override_Recruitment_Status__c IN ' + '(\'' + String.join(ORS_STATUS_ENROLLING, '\',\'') + '\') ' +
                    'OR Override_Recruitment_Status__c IN ' + '(\'' + String.join(CTMS_RECRUITMENT, '\',\'') + '\')) ';
        } else if (isEnrolling) {
            whereClause += ' AND (Override_Recruitment_Status__c = ' + '\'' + ACTIVELY_ENROLLING + '\' ' +
                    'OR Override_Recruitment_Status__c IN ' + '(\'' + String.join(CTMS_RECRUITMENT_ENROLLING, '\',\'') + '\')) ';
        } else if (isNotYetEnrolling) {
            whereClause += ' AND (Override_Recruitment_Status__c = ' + '\'' + ON_HOLD + '\' ' +
                    'OR Override_Recruitment_Status__c IN ' + '(\'' + String.join(CTMS_ON_HOLD, '\',\'') + '\')) ';
        }
        String orderBy = ' ORDER BY Enrollment_Start_Date__c';
        String queryCTP = 'SELECT ' +
                'Therapeutic_Area__c, ' +
                'Therapeutic_Area__r.Name, ' +
                'Study_Code_Name__c, ' +
                'Official_Title__c, ' +
                'Enrollment_Start_Date__c, ' +
                'Override_Recruitment_Status__c, ' +
                'Recruitment_Status__c ' +
                'FROM Clinical_Trial_Profile__c ';

        queryCTP += whereClause;
        queryCTP += orderBy;

        List<Clinical_Trial_Profile__c> ctps = (List<Clinical_Trial_Profile__c>) proxy.query(queryCTP, true);
        return ctps;
    }

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

    public AssignmentRule getAssignmentRule(DatabaseProxy proxy) {
        String queryAssignmentRule = 'SELECT ' +
                'Id ' +
                'FROM AssignmentRule ' +
                'WHERE SobjectType = \'' + ASSIGMENT_RULE_TYPE_CASE + '\' ' +
                'AND Name = \'' + ASSIGMENT_RULE_NAME + '\' ' +
                'AND Active = TRUE ' +
                'LIMIT 1';
        return (AssignmentRule) proxy.query(queryAssignmentRule, true)[0];
    }
}