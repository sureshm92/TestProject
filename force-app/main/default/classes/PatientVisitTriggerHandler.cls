/**
 * Created by Denis Z on 01-Jul-19.
 */

public with sharing class PatientVisitTriggerHandler {

    public class UpdateMissedVisits extends TriggerHandler{

        public override void afterInsert(List<SObject> newList) {
            //updateMissedVisits(newList);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            //updateMissedVisits(newList);
        }
    }

    private static void updateMissedVisits(List<Patient_Visit__c> patientVisits){
        Set<String> visitExternalKeys = new Set<String>();
        Set<Id> visitIds = new Set<Id>();
        for(Patient_Visit__c visit : patientVisits){
            visitIds.add(visit.Id);
        }
        List<Patient_Visit__c> visits = [
                SELECT  Participant_Study_Enrollment__r.External_Key__c
                FROM    Patient_Visit__c
                WHERE   Id IN : visitIds
        ];
        for(Patient_Visit__c visit : visits){
            visitExternalKeys.add(visit.Participant_Study_Enrollment__r.External_Key__c);
        }
        System.debug(visitExternalKeys);
        patientVisits = [
                SELECT
                        Id,
                        Participant_Study_Enrollment__r.External_Key__c,
                        Status__c,
                        Visit_Number__c
                FROM    Patient_Visit__c
                WHERE   Participant_Study_Enrollment__r.External_Key__c IN : visitExternalKeys
                AND     Status__c != 'Missed'
                ORDER BY Visit_Number__c
                DESC
        ];
        Boolean recordsChanged = false;
        Map<String, Patient_Visit__c> visitMap = new Map<String, Patient_Visit__c>();
        for(Patient_Visit__c visit : patientVisits){
            if(visit.Status__c == 'Completed'){
                visitMap.put(visit.Participant_Study_Enrollment__r.External_Key__c, visit);
            }
            if(visitMap.containsKey(visit.Participant_Study_Enrollment__r.External_Key__c) && visitMap.get(visit.Participant_Study_Enrollment__r.External_Key__c).Visit_Number__c > visit.Visit_Number__c
                    && visit.Status__c != 'Completed' && visit.Status__c != 'Missed'){
                visit.Status__c = 'Missed';
                recordsChanged = true;
            }
        }
        if(recordsChanged)
            update patientVisits;
    }
}