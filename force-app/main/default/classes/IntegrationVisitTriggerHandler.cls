/**
 * Created by Denis Z on 20-Jun-19.
 */

public with sharing class IntegrationVisitTriggerHandler{

    public class CheckProcessedRecordsHandler extends TriggerHandler{

        public override void beforeInsert(List<SObject> newList) {
            setIsProcessed(newList, null);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            setIsProcessed(newList, (Map<Id, Integration_Visit__c>)oldMap);
        }

    }

    public  static void updateVisits(List<Integration_Visit__c> integrationVisits){
        Set<String> externalKeys = new Set<String>();
        for(Integration_Visit__c integrationVisit : integrationVisits){
            externalKeys.add(integrationVisit.USUBJID__c);
            integrationVisit.Work_Status__c = 'Failed';
        }
        List<Participant_Study_Enrollment__c> pseList = [
                SELECT
                        Id,
                        External_Key__c,
                        (
                                SELECT
                                        Id,
                                        Status__c,
                                        Visit_Number__c,
                                        Name
                                FROM    Patient_Visits__r
                                ORDER BY Visit_Number__c
                                DESC
                        )
                FROM    Participant_Study_Enrollment__c
                WHERE   External_Key__c IN : externalKeys
        ];
        Map<String, Participant_Study_Enrollment__c> pseMap = new Map<String, Participant_Study_Enrollment__c>();
        for(Participant_Study_Enrollment__c pse : pseList) pseMap.put(pse.External_Key__c, pse);
        
        Map<Id, Patient_Visit__c> visitsToUpdateMap = new Map<Id, Patient_Visit__c>();
        List<Patient_Visit__c> visitsToInsert = new List<Patient_Visit__c>();
        Map<String, Decimal> maxCompletedVisitMap = new Map<String, Decimal>();
        for(Integration_Visit__c integrationVisit : integrationVisits) {
            Boolean matchFound = false;
            Participant_Study_Enrollment__c pse = pseMap.get(integrationVisit.USUBJID__c);
            if(pse == null) continue;
            for(Patient_Visit__c visit : pse.Patient_Visits__r){
                if((integrationVisit.VISIT__c != null && integrationVisit.VISIT__c == visit.Name) ||
                        (integrationVisit.VISITNUM__c != null && integrationVisit.VISITNUM__c == visit.Visit_Number__c)){
                    matchFound = true;
                    visit.Status__c = 'Completed';
                    visit.Completed_Date__c = integrationVisit.SVSTDTC__c;
                    visitsToUpdateMap.put(visit.Id, visit);
                }
                if(visit.Status__c == 'Completed'){
                    if(!maxCompletedVisitMap.containsKey(integrationVisit.USUBJID__c)) maxCompletedVisitMap.put(integrationVisit.USUBJID__c, 0);
                    if (visit.Visit_Number__c != null && visit.Visit_Number__c > maxCompletedVisitMap.get(integrationVisit.USUBJID__c)){
                        maxCompletedVisitMap.put(integrationVisit.USUBJID__c, visit.Visit_Number__c);
                    }
                }
            }
            if(!matchFound) visitsToInsert.add(createAdhockVisit(integrationVisit, pse.Id));
            integrationVisit.Work_Status__c = 'Success';
            integrationVisit.Processed__c = true;
        }
        for(Participant_Study_Enrollment__c pse : pseList){
            for(Patient_Visit__c visit : pse.Patient_Visits__r){
                if(visit.Visit_Number__c != null && visit.Visit_Number__c < maxCompletedVisitMap.get(pse.External_Key__c) && visit.Status__c == 'Pending'){
                    visit.Status__c = 'Missed';
                    visitsToUpdateMap.put(visit.Id, visit);
                }
            }
        }
    
        update integrationVisits;
        update visitsToUpdateMap.values();
        insert visitsToInsert;
    }
    
    private static Patient_Visit__c createAdhockVisit(Integration_Visit__c externalVisit, String pseId){
        Patient_Visit__c newVisit = new Patient_Visit__c();
        newVisit.Is_Adhoc__c = true;
        newVisit.Name = externalVisit.Visit__c;
        newVisit.Status__c = 'Completed';
        newVisit.Completed_Date__c = externalVisit.SVSTDTC__c;
        newVisit.Visit_Number__c = externalVisit.VISITNUM__c;
        newVisit.Participant_Study_Enrollment__c = pseId;
        return newVisit;
    }

    private static void setIsProcessed(List<Integration_Visit__c> newList, Map<Id, Integration_Visit__c> oldMap){
        for(Integration_Visit__c visit : newList){
            if(oldMap == null || visit.MD5_Hash__c != oldMap.get(visit.Id).MD5_Hash__c){
                visit.Processed__c = false;
            }
        }
    }

}