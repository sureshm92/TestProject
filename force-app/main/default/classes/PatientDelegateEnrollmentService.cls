/*
Created By: Ranjit Ravindranath
*/
public without sharing class PatientDelegateEnrollmentService {
    private static PatientDelegateEnrollmentService instance;
    private Boolean isDelegate = false;
    public Boolean hasDelegates = false;
    private Participant__c participant;
    public static list<PatientDelegateEnrollmentsWrapper> listPDEWrapper = new List<PatientDelegateEnrollmentsWrapper>();

    public list<PatientDelegateEnrollmentsWrapper> PdeWrapper;
    public static PatientDelegateEnrollmentService getInstance() {
        if (instance == null)
            instance = new PatientDelegateEnrollmentService();
        return instance;
    }
    public static void setMock(StubProvider stubProvider) {
        instance = (PatientDelegateEnrollmentService) Test.createStub(
            PatientDelegateEnrollmentService.class,
            stubProvider
        );
    }
    public PatientDelegateEnrollmentService() {
        list<Patient_Delegate_Enrollment__c> lstPDE = DatabaseService.query(
            new List<String>{
                'Id',
                'Patient_Delegate__r.Participant__r.Full_Name__c',
                'Patient_Delegate__r.Id',
                'Patient_Delegate__r.Participant__r.Contact__c',
                'Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c',
                'Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_SMS__c',
                'Patient_Delegate__r.Participant__r.First_Name__c',
                'Patient_Delegate__r.Participant__r.Last_Name__c',
                'Patient_Delegate__r.Contact__c',
                'Patient_Delegate__r.Participant_Delegate__r.Id',
                'Patient_Delegate__r.Participant_Delegate__r.First_Name__c',
                'Patient_Delegate__r.Participant_Delegate__r.Last_Name__c',
                'Patient_Delegate__r.Participant_Delegate__r.Email__c',
                'Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_Emails__c',
                'Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_SMS__c',
                'Status__c',
                'Participant_Enrollment__c',
                'Participant_Enrollment__r.Name'
            },
            Patient_Delegate_Enrollment__c.getSObjectType(),
            DatabaseService.fieldEqual(
                'Patient_Delegate__r.Contact__c',
                CommunityService.getInstance().getCurrentContactId()
            ) +
            ' AND ' +
            DatabaseService.fieldNotEqual('Status__c', 'Withdrawn')
        );
        isDelegate = lstPDE.size() > 0;
        participant = ParticipantContext.getCurrentParticipant();
        map<id, list<Patient_Delegate_Enrollment__c>> mapIdPDE = new Map<id, list<Patient_Delegate_Enrollment__c>>();
        for (Patient_Delegate_Enrollment__c pde : lstPDE) {
            PatientDelegateEnrollmentsWrapper pdw = new PatientDelegateEnrollmentsWrapper();
            if (mapIdPDE.containsKey(pde.Patient_Delegate__r.Participant_Delegate__r.Id)) {
                mapIdPDE.get(pde.Patient_Delegate__r.Participant_Delegate__r.Id).add(pde);
            } else {
                mapIdPDE.put(
                    pde.Patient_Delegate__r.Participant_Delegate__r.Id,
                    new List<Patient_Delegate_Enrollment__c>{ pde }
                );
            }
        }
        for (Id ide : mapIdPDE.keyset()) {
            PatientDelegateEnrollmentsWrapper pdw = new PatientDelegateEnrollmentsWrapper();
            Participant__c del = new Participant__c();
            del.Id = ide;
            del.First_Name__c = mapIdPDE.get(ide)[0]
                .Patient_Delegate__r.Participant_Delegate__r.First_Name__c;
            del.Last_Name__c = mapIdPDE.get(ide)[0]
                .Patient_Delegate__r.Participant_Delegate__r.Last_Name__c;
            del.Email__c = mapIdPDE.get(ide)[0]
                .Patient_Delegate__r.Participant_Delegate__r.Email__c;
            pdw.PatientDelegate = del;
            pdw.PDEEnrollments = mapIdPDE.get(ide);
            listPDEWrapper.add(pdw);
        }
    }
    
    
    @AuraEnabled
    public static list<PatientDelegateEnrollmentsWrapper> getPDE() {
        return PatientDelegateEnrollmentService.getInstance().listPDEWrapper;
    }
    public void createPatientDelegateEnrollment(
        Patient_Delegate__c newDelegate,
        String studyPERData
    ) {
        //get the list of selected studies for Delegate.
        MyTeamRemote.PEFilterData filterData = (MyTeamRemote.PEFilterData) JSON.deserialize(
            studyPERData,
            MyTeamRemote.PEFilterData.class
        );
        List<LabelValueItem> studiesSelected = filterData.studiesSelected;
        List<Patient_Delegate_Enrollment__c> pdEnrollments = new List<Patient_Delegate_Enrollment__c>();
        for (LabelValueItem studyPER : studiesSelected) {
            Patient_Delegate_Enrollment__c pde = new Patient_Delegate_Enrollment__c();
            pde.Participant_Enrollment__c = studyPER.Value; //PER val
            pde.Patient_Delegate__c = newDelegate.Id;
            //pde.Attestation_c__c = newDelegate.Attestation__c;
            pde.Attestation_TimeStamp__c = newDelegate.Attestation_TimeStamp__c;
            pde.Attested_by__c = newDelegate.Attested_by__c;
            pde.Status__c = 'Active';
            pdEnrollments.add(pde);
        }
        if (pdEnrollments.size() > 0) {
            insert pdEnrollments;
        }
    }

    public static PDEWrapper getDelegatedParticipantIdsMap(Id contactId) {
        List<Patient_Delegate_Enrollment__c> pdeList = new List<Patient_Delegate_Enrollment__c>();
        if (contactId != null) {
            pdeList = [
                SELECT
                    Id,
                    Participant_Enrollment__c,
                    Patient_Delegate__c,
                    Patient_Delegate__r.Contact__c,
                    Patient_Delegate__r.Participant__c,
                    Name,
                    Status__c,
                    Participant_Enrollment__r.study__c
                FROM Patient_Delegate_Enrollment__c
                WHERE Patient_Delegate__r.Contact__c = :contactId AND Status__c = 'Active'
            ];
        }
        PDEWrapper delConMap = new PDEWrapper();
        Map<Id, List<Id>> delParticipantIds = new Map<Id, List<Id>>();
        Map<Id, List<Id>> pdercrdslst = new Map<Id, List<Id>>();
        for (Patient_Delegate_Enrollment__c pd : pdeList) {
            List<Id> participantIds = delParticipantIds.get(pd.Patient_Delegate__r.Contact__c);
            List<Id> pdercrds = pdercrdslst.get(pd.Patient_Delegate__r.Contact__c);
            if (participantIds == null)
                participantIds = new List<Id>();
            if (pdercrds == null)
                pdercrds = new List<Id>();

            if (!participantIds.contains(pd.Patient_Delegate__r.Participant__c))
                participantIds.add(pd.Patient_Delegate__r.Participant__c);
            if (!pdercrds.contains(pd.Participant_Enrollment__c))
                pdercrds.add(pd.Participant_Enrollment__c);
            delParticipantIds.put(pd.Patient_Delegate__r.Contact__c, participantIds); /// Delegate contat with list of  actual participant Ids
            pdercrdslst.put(pd.Patient_Delegate__r.Contact__c, pdercrds);
        }
        if (!delParticipantIds.isEmpty() && delParticipantIds != null)
            delConMap.delParticipantIds = delParticipantIds;
        if (!pdercrdslst.isEmpty() && pdercrdslst != null)
            delConMap.pdercrds = pdercrdslst;

        return delConMap;
    }

    // define our wrapper
    public class PDEWrapper {
        public Map<Id, List<Id>> delParticipantIds = new Map<Id, List<Id>>();
        //public Map<Id,List<Patient_Delegate_Enrollment__c>> pdercrds = new Map<Id,List<Patient_Delegate_Enrollment__c>>();
        public Map<Id, List<Id>> pdercrds = new Map<Id, List<Id>>();
    }

    public class PatientDelegateEnrollmentsWrapper {
        @AuraEnabled        
        public Participant__c PatientDelegate;
        @AuraEnabled
        public list<Patient_Delegate_Enrollment__c> PDEEnrollments;
    }
}