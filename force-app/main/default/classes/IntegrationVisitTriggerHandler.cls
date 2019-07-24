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

    public  static void updateVisits(List<Integration_Visit__c> visits){
        Set<String> externalKeys = new Set<String>();
        Map<String, List<Patient_Visit__c>> patientVisitMap = new Map<String, List<Patient_Visit__c>>();
        for(Integration_Visit__c visit : visits){
            externalKeys.add(visit.USUBJID__c);
            visit.Work_Status__c = 'Failed';
            patientVisitMap.put(visit.USUBJID__c, new List<Patient_Visit__c>());
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
        Map<String, Id> pseIdsMap = new Map<String, Id>();
        for(Participant_Study_Enrollment__c pse : pseList){
            patientVisitMap.get(pse.External_Key__c).addAll(pse.Patient_Visits__r);
            pseIdsMap.put(pse.External_Key__c, pse.Id);
        }
        List<Patient_Visit__c> visitsToUpsert = new List<Patient_Visit__c>();
        Map<String, Decimal> maxCompletedVisitMap = new Map<String, Decimal>();
        for(Integration_Visit__c externalVisit : visits) {
            if(patientVisitMap.containsKey(externalVisit.USUBJID__c)){
                Boolean matchFound = false;
                for(Patient_Visit__c visit : patientVisitMap.get(externalVisit.USUBJID__c)){
                    if((externalVisit.VISIT__c != null && externalVisit.VISIT__c == visit.Name) ||
                            (externalVisit.VISITNUM__c != null && externalVisit.VISITNUM__c == visit.Visit_Number__c)){
                        matchFound = true;
                        visit.Status__c = 'Completed';
                        visit.Completed_Date__c = externalVisit.SVSTDTC__c;
                        visitsToUpsert.add(visit);
                    }
                    if(visit.Status__c == 'Completed'){
                        if(!maxCompletedVisitMap.containsKey(externalVisit.USUBJID__c)) {
                            maxCompletedVisitMap.put(externalVisit.USUBJID__c, visit.Visit_Number__c);
                        } else if (maxCompletedVisitMap.get(externalVisit.USUBJID__c) < visit.Visit_Number__c){
                            maxCompletedVisitMap.remove(externalVisit.USUBJID__c);
                            maxCompletedVisitMap.put(externalVisit.USUBJID__c, visit.Visit_Number__c);
                        }
                    }
                }
                if(!matchFound){
                    visitsToUpsert.add(createAdhockVisit(externalVisit, pseIdsMap));
                }
                externalVisit.Work_Status__c = 'Success';
                externalVisit.Processed__c = true;
            }
        }
        update visits;
        upsert visitsToUpsert;
        updateMissedVisits(pseList, maxCompletedVisitMap);
    }

    private static void updateMissedVisits(List<Participant_Study_Enrollment__c> pseList, Map<String, Decimal> maxCompletedVisitMap){
        System.debug(maxCompletedVisitMap);
        List<Patient_Visit__c> pseListToUpdate = new List<Patient_Visit__c>();
        for(Participant_Study_Enrollment__c pse : pseList){
            for(Patient_Visit__c visit : pse.Patient_Visits__r){
                if(visit.Visit_Number__c < maxCompletedVisitMap.get(pse.External_Key__c) && visit.Status__c == 'Pending'){
                    visit.Status__c = 'Missed';
                    pseListToUpdate.add(visit);
                    System.debug(visit);
                    System.debug(pseListToUpdate);
                }
            }
        }
        update pseListToUpdate;
    }

    private static Patient_Visit__c createAdhockVisit(Integration_Visit__c externalVisit, Map<String, Id> pseIdsMap){
        Patient_Visit__c newVisit = new Patient_Visit__c();
        newVisit.Is_Adhoc__c = true;
        newVisit.Name = externalVisit.Visit__c;
        newVisit.Status__c = 'Completed';
        newVisit.Completed_Date__c = externalVisit.SVSTDTC__c;
        newVisit.Visit_Number__c = externalVisit.VISITNUM__c;
        newVisit.Participant_Study_Enrollment__c = pseIdsMap.get(externalVisit.USUBJID__c);
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