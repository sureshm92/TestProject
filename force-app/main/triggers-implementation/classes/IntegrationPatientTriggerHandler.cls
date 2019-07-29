/**
 * Created by Denis Z on 17-Jun-19.
 */

public with sharing class IntegrationPatientTriggerHandler {

    public class UpdatePatientsHandler extends TriggerHandler{

        public override void beforeInsert(List<SObject> newList) {
            updatePatients(newList);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updatePatients(newList);
        }
    }

    @TestVisible
    private static void updatePatients(List<Integration_Patient__c> newList){
        List<String> externalKeys = new List<String>();
        for(Integration_Patient__c patient : newList){
            externalKeys.add(patient.External_ID__c);
            patient.Work_Status__c = 'Failed';
        }
        List<Participant_Study_Enrollment__c> pseList = PSEService.getPSEListByExternalIds(externalKeys);
        Set<String> dateAndStatusChangeSet = new Set<String>();
        List<SDH_Status__mdt> sdhStatuses = [
            SELECT
                    Label,
                    Salesforce_Status__c,
                    Salesforce_Object__c
            FROM    SDH_Status__mdt
        ];
        Map<String, SDH_Status__mdt> sdhStatusMap = new Map<String, SDH_Status__mdt>();
        for(SDH_Status__mdt sdhStatus : sdhStatuses){
            sdhStatusMap.put(sdhStatus.Label.remove(' '), sdhStatus);
        }
        Map<String, Participant_Study_Enrollment__c> pseMap = new Map<String, Participant_Study_Enrollment__c>();
        List<PSE_Status_History__c> historyList = new List<PSE_Status_History__c>();
        for(Participant_Study_Enrollment__c pse : pseList){
            pseMap.put(pse.External_Key__c, pse);
            for(PSE_Status_History__c statusHistory : pse.PSE_Status_Histories__r){
                dateAndStatusChangeSet.add(statusHistory.Status__c + statusHistory.Changed_Date__c);
            }
        }
        for(Integration_Patient__c patient : newList){
            if(pseMap.containsKey(patient.External_ID__c)) {
                String dateAndStatus = getPSEStatus(sdhStatusMap, patient) + patient.Subject_Date__c;
                if(!dateAndStatusChangeSet.contains(dateAndStatus)) {
                    dateAndStatusChangeSet.add(dateAndStatus);
                    PSE_Status_History__c history = new PSE_Status_History__c();
                    history.Changed_Date__c = patient.Subject_Date__c;
                    history.Status__c = getPSEStatus(sdhStatusMap, patient);
                    history.PSE__c = pseMap.get(patient.External_ID__c).Id;
                    historyList.add(history);
                    patient.Work_Status__c = 'Success';
                    if (patient.IsDeletedInSDH__c == 'N') {
                        pseMap.get(patient.External_ID__c).IsSubjectIDverifiedInSDH__c = true;
                    } else {
                        pseMap.get(patient.External_ID__c).IsSubjectIDverifiedInSDH__c = false;
                    }
                }
            }
        }
        update pseMap.values();
        insert historyList;
    }

    private static String getPSEStatus(Map<String, SDH_Status__mdt> sdhStatusMap, Integration_Patient__c patient){
        if(sdhStatusMap.containsKey(patient.Subject_Status__c.remove(' ')) && sdhStatusMap.get(patient.Subject_Status__c.remove(' ')).Salesforce_Object__c == 'Participant Study Enrollment'){
            return sdhStatusMap.get(patient.Subject_Status__c.remove(' ')).Salesforce_Status__c;
        }
        return null;
    }

}