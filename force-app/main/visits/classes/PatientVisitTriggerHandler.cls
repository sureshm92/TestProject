/**
 * Created by Denis Z on 01-Jul-19.
 * Modified by Ranjit Ravindranath 28/03/2022
 * Desc: handler for patient visit trigger.
 */

public without sharing class PatientVisitTriggerHandler {
    public static Map<String, Config_API_Param__mdt> apiParamsMap;
    public static final String ECOA_CONFIG_NAME = 'ECOAIntegration';
    public static final String ORG_GUID = 'OrgGuid';

    static {
        apiParamsMap = new Map<String, Config_API_Param__mdt>();
        for (Config_API_Param__mdt mdt : [
            SELECT DeveloperName, ParamValue__c, Param_Value_Long__c
            FROM Config_API_Param__mdt
            WHERE ConfigAPI__r.DeveloperName = :ECOA_CONFIG_NAME
        ]) {
            apiParamsMap.put(mdt.DeveloperName, mdt);
        }
        System.debug('apiParamsMap::' + apiParamsMap);
    }

    public class updateEcoaEvents extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updateEcoaEvents(newList, (Map<Id, Patient_Visit__c>) oldMap);
        }
    }
    public class completePatientVisitTask extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            completePVTask(newList, (Map<Id, Patient_Visit__c>) oldMap);
        }
    }
    /*public override void afterInsert(List<SObject> newList) {
        updateEcoaEvents(newList);
    }*/
    @TestVisible
    private static void updateEcoaEvents(
        List<Patient_Visit__c> patientVisits,
        Map<Id, Patient_Visit__c> oldMap
    ) {
        List<Patient_Visit__c> completedVisitPatients = new List<Patient_Visit__c>();
        Set<Id> pvIds = new Set<Id>();
        for (Patient_Visit__c pv : patientVisits) {
            if (pv.Status__c == 'Completed' && pv.Status__c != oldMap.get(pv.Id).Status__c) {
                completedVisitPatients.add(pv);
                pvIds.add(pv.Id);
            }
        }
        if (!pvIds.isEmpty() && !system.isBatch()) {
            triggerEcoaEventAsync(pvIds);
        }
    }

    private static void completePVTask(
        List<Patient_Visit__c> patientVisits,
        Map<Id, Patient_Visit__c> oldMap
    ) {
        Set<Id> pvIds = new Set<Id>();
        List<Task> tasks = new List<Task>();
        for (Patient_Visit__c pv : patientVisits) {
            if (pv.Status__c == 'Completed' && pv.Status__c != oldMap.get(pv.Id).Status__c) {
                pvIds.add(pv.Id);
            }
        }
        if(!pvIds.isEmpty() && !system.isBatch()){
            for(Task task:[Select Id from Task where Patient_Visit__c IN:pvIds]){
                Task newTask = new Task();
                newTask.Id = task.Id;
                newTask.Status = 'Completed';
                newTask.Completed_Date__c = Datetime.now();
                tasks.add(newTask);
            }
        }
        if(!tasks.isEmpty())
        update tasks;
    }

    @Future(Callout=true)
    public static void triggerEcoaEventAsync(Set<Id> pvIds) {
        List<Map<String, String>> requestMapList = new List<Map<String, String>>();
        for (Patient_Visit__c pv : [
            SELECT
                Id,
                Completed_Date__c,
                Ecoa_Key__c,
                Participant_Enrollment__r.Subject_GUID__c,
                Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_GUID__c
            FROM Patient_Visit__c
            WHERE Id IN :pvIds AND Completed_Date__c != NULL
        ]) {
            Date dateToday = pv.Completed_Date__c;
            String sMonth = String.valueof(dateToday.month());
            String sDay = String.valueof(dateToday.day());
            if (sMonth.length() == 1) {
                sMonth = '0' + sMonth;
            }
            if (sDay.length() == 1) {
                sDay = '0' + sDay;
            }
            String dateVal = String.valueof(dateToday.year()) + '-' + sMonth + '-' + sDay;

            Map<String, String> ecoaEventMap = new Map<String, String>{
                'studyGuid' => pv.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_GUID__c,
                'orgGuid' => apiParamsMap.get(ORG_GUID).ParamValue__c,
                'subjectGuid' => pv.Participant_Enrollment__r.Subject_GUID__c,
                'date' => dateVal,
                'dateKey' => pv.Ecoa_Key__c
            };
            requestMapList.add(ecoaEventMap);
        }
        if (requestMapList != null && !requestMapList.isEmpty()) {
            try {
                ECOAService.createEcoaEvent(requestMapList);
            } catch (Exception e) {
                System.debug('Err');
            }
        }
    }
}
