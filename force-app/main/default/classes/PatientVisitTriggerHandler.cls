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
        Set<Id> visitIds = new Set<Id>();
        for(Patient_Visit__c visit : patientVisits){
            visitIds.add(visit.Id);
        }
        patientVisits = [
                SELECT
                        Id,
                        Participant_Study_Enrollment__r.External_Key__c,
                        Status__c,
                        Visit_Number__c
                FROM    Patient_Visit__c
                ORDER BY Visit_Number__c
                DESC
        ];
        Map<String, Patient_Visit__c> visitMap = new Map<String, Patient_Visit__c>();
        for(Patient_Visit__c visit : patientVisits){
            visitMap.put(visit.Participant_Study_Enrollment__r.External_Key__c, visit);
            if(visitMap.get(visit.Participant_Study_Enrollment__r.External_Key__c).Visit_Number__c < visit.Visit_Number__c
                    && visit.Status__c != 'Completed'){
                visit.Status__c = 'Missed';
            }
        }
        update patientVisits;
    }
}