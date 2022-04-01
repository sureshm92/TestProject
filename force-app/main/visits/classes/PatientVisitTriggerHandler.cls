/**
 * Created by Denis Z on 01-Jul-19.
 * Modified by Ranjit Ravindranath 28/03/2022
 * Desc: handler for patient visit trigger.
 */

public without sharing class PatientVisitTriggerHandler {
    public static Map<String, Config_API_Param__mdt> apiParamsMap;
    public static final String ECOA_CONFIG_NAME = 'ECOAIntegration';
    public static final String ORG_GUID = 'OrgGuid';

    public class updateEcoaEvents extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updateEcoaEvents(newList,(Map<Id, Patient_Visit__c>) oldMap);
        }
    }
    /*public override void afterInsert(List<SObject> newList) {
        updateEcoaEvents(newList);
    }*/
    @TestVisible
    private static void updateEcoaEvents(List<Patient_Visit__c> patientVisits,Map<Id, Patient_Visit__c> oldMap){
    List<Patient_Visit__c> completedVisitPatients = new List<Patient_Visit__c>(); 
    Set<Id> pvIds = new Set<Id>();   
        for(Patient_Visit__c pv:patientVisits){
            if(pv.Status__c == 'Completed' && pv.Status__c!= oldMap.get(pv.Id).Status__c){
                completedVisitPatients.add(pv);
                pvIds.add(pv.Id);
            }
        }
        if(!pvIds.isEmpty()){
            ECOAService.triggerEcoaEventAsync(pvIds);
        }
    }

}
