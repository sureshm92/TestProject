/**
 * Created by Denis Z on 17-Jun-19.
 */

public with sharing class IntegrationPatientTriggerHandler {

    private static final String PATIENT_WORK_STATUS_FAILED = 'Failed';
    private static final String PATIENT_WORK_STATUS_SUCCESS = 'Success';
    private static final String PE_OBJECT_NAME = 'Participant Enrollment';

    public class UpdatePatientsHandler extends TriggerHandler{

        public override void beforeInsert(List<SObject> newList) {
            updatePatients(newList);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updatePatients(newList);
        }
    }

    @TestVisible
    private static void updatePatients(List<Integration_Patient__c> integrationPatients){
        List<String> externalKeys = new List<String>();
        for(Integration_Patient__c patient : integrationPatients){
            externalKeys.add(patient.External_ID__c);
            patient.Work_Status__c = PATIENT_WORK_STATUS_FAILED;
        }

        List<SDH_Status__mdt> sdhStatuses = [
            SELECT
                    Label,
                    Salesforce_Status__c,
                    Salesforce_Object__c
            FROM    SDH_Status__mdt
        ];
        Map<String, SDH_Status__mdt> sdhStatusMap = new Map<String, SDH_Status__mdt>();
        for(SDH_Status__mdt sdhStatus : sdhStatuses) sdhStatusMap.put(sdhStatus.Label.remove(' '), sdhStatus);

        Set<String> statusDateChanges = new Set<String>();
        Map<String, Participant_Enrollment__c> peByExternalKey = new Map<String, Participant_Enrollment__c>();
        for(Participant_Enrollment__c pe : ParticipantEnrollmentService.getEnrollmentsByExternalKey(externalKeys)){
            peByExternalKey.put(pe.External_Key__c, pe);
            for(Participant_Enrollment_Status_History__c statusHistory : pe.Participant_Enrollment_Status_History__r){
                statusDateChanges.add(statusHistory.Status__c + statusHistory.Date__c);
            }
        }

        List<Participant_Enrollment_Status_History__c> histories = new List<Participant_Enrollment_Status_History__c>();
        for(Integration_Patient__c patient : integrationPatients){
            if(peByExternalKey.containsKey(patient.External_ID__c)) {
                String status = getPEStatus(sdhStatusMap, patient);
                String statusDate = status + patient.Subject_Date__c;

                if(!statusDateChanges.contains(statusDate)) {
                    statusDateChanges.add(statusDate);
                    histories.add(new Participant_Enrollment_Status_History__c(
                            Date__c = patient.Subject_Date__c,
                            Status__c = status,
                            ParticipantEnrollment__c = peByExternalKey.get(patient.External_ID__c).Id
                    ));

                    patient.Work_Status__c = PATIENT_WORK_STATUS_SUCCESS;
                    if (patient.IsDeletedInSDH__c == 'N') {
                        peByExternalKey.get(patient.External_ID__c).IsSubjectIDverifiedInSDH__c = true;
                    } else {
                        peByExternalKey.get(patient.External_ID__c).IsSubjectIDverifiedInSDH__c = false;
                    }
                }
            }
        }

        update peByExternalKey.values();
        insert histories;
    }

    private static String getPEStatus(Map<String, SDH_Status__mdt> sdhStatusMap, Integration_Patient__c patient){
        String patientStatus = patient.Subject_Status__c.remove(' ');
        if (sdhStatusMap.containsKey(patientStatus)){
            SDH_Status__mdt sdhStatus = sdhStatusMap.get(patientStatus);
            if(sdhStatus.Salesforce_Object__c == PE_OBJECT_NAME) return sdhStatus.Salesforce_Status__c;
        }

        return null;
    }
}