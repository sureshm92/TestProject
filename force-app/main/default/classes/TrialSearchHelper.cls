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
        return this.getTrialSearchContainer(null, true, true);
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

    private List<TrialSearchContainerRemote.TrialTDO> getTrialTDOs(Set<Id> taIds, List<Clinical_Trial_Profile__c> ctps, DatabaseProxy proxy) {
        Map<Id, Therapeutic_Area__c> therapeuticAreaByParent = getTherapeuticAreaByParent(taIds, proxy);
        List<TrialSearchContainerRemote.TrialTDO> trialTDOS = new List<TrialSearchContainerRemote.TrialTDO>();
        for (Clinical_Trial_Profile__c ctp : ctps) {
            TrialSearchContainerRemote.TrialTDO tdo = new TrialSearchContainerRemote.TrialTDO();
            tdo.ctp = ctp;
            if (String.isNotBlank(ctp.Override_Recruitment_Status__c)) {
                tdo.isGreenLine = ctp.Override_Recruitment_Status__c == ACTIVELY_ENROLLING;
            } else if (String.isNotBlank(ctp.Recruitment_Status__c)) {
                tdo.isGreenLine = ctp.Recruitment_Status__c == ENROLLING || ctp.Recruitment_Status__c == OPEN_TO_ENROLLMENT;
            }
            List<Therapeutic_Area__c> tasTemp = therapeuticAreaByParent.get(ctp.Therapeutic_Area__c).Therapeutic_Areas__r;
            if (tasTemp != null && !tasTemp.isEmpty()) {
                tdo.cois = tasTemp;
            }
            trialTDOS.add(tdo);
        }
        return trialTDOS;
    }

    private Map<Id, Therapeutic_Area__c> getTherapeuticAreaByParent(Set<Id> taIds, DatabaseProxy proxy) {
        Map<Id, Therapeutic_Area__c> therapeuticAreaByParent = new Map<Id, Therapeutic_Area__c>();
        if (!taIds.isEmpty()) {
            String queryTA = 'SELECT ' +
                    'Name, ' +
                    '(SELECT Name, Therapeutic_Area__c FROM Therapeutic_Areas__r WHERE RecordType.DeveloperName = \'' + TherapeuticAreaService.COI_RT_NAME + '\') ' +
                    'FROM Therapeutic_Area__c ' +
                    'WHERE Id IN ' + '(\'' + String.join(new List<Id>(taIds), '\',\'') + '\')';
            List<Therapeutic_Area__c> therapeuticAreas = (List<Therapeutic_Area__c>) proxy.query(queryTA, true);
            if (!therapeuticAreas.isEmpty()) {
                therapeuticAreaByParent = new Map<Id, Therapeutic_Area__c>(therapeuticAreas);
            }
        }
        return therapeuticAreaByParent;
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
}