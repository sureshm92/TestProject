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
        Set<String> visitNames = new Set<String>();
        Set<Decimal> visitNumbers = new Set<Decimal>();
        Map<String, List<Patient_Visit__c>> patientVisitMap = new Map<String, List<Patient_Visit__c>>();
        for(Integration_Visit__c visit : visits){
            externalKeys.add(visit.USUBJID__c);
            visitNames.add(visit.VISIT__c);
            visitNumbers.add(visit.VISITNUM__c);
            visit.Work_Status__c = 'Failed';
            patientVisitMap.put(visit.USUBJID__c, new List<Patient_Visit__c>());
        }
        List<Patient_Visit__c> patientVisits = [
            SELECT
                    Id,
                    Visit__r.Name,
                    Participant_Study_Enrollment__r.External_Key__c,
                    Status__c,
                    Visit__r.Visit_Number__c,
                    Visit_Number__c,
                    Name
            FROM    Patient_Visit__c
            WHERE   Participant_Study_Enrollment__r.External_Key__c IN : externalKeys
            AND     Visit_Number__c IN : visitNumbers
            AND     Name IN : visitNames
            ORDER BY Visit_Number__c
            DESC
        ];
        //Not sure
        List<Participant_Study_Enrollment__c> pseList = [
            SELECT
                    Id,
                    External_Key__c
            FROM    Participant_Study_Enrollment__c
            WHERE   External_Key__c IN : externalKeys
        ];
        Map<String, Id> pseIdsMap = new Map<String, Id>();
        for(Participant_Study_Enrollment__c pse : pseList){
            pseIdsMap.put(pse.External_Key__c, pse.Id);
        }
        //
        for(Patient_Visit__c visit : patientVisits){
            patientVisitMap.get(visit.Participant_Study_Enrollment__r.External_Key__c).add(visit);
        }
        List<Patient_Visit__c> newVisits = new List<Patient_Visit__c>();
        for(Integration_Visit__c externalVisit : visits) {
            if(patientVisitMap.containsKey(externalVisit.USUBJID__c)){
                Boolean matchFound = false;
                for(Patient_Visit__c visit : patientVisitMap.get(externalVisit.USUBJID__c)){
                    if(matchFoundByName(externalVisit, visit) || matchFoundByNumber(externalVisit, visit)){
                        matchFound = true;
                        continue;
                    }
                }
                if(!matchFound){
                    newVisits.add(createAdhockVisit(externalVisit, pseIdsMap));
                }
                externalVisit.Work_Status__c = 'Success';
                externalVisit.Processed__c = true;
            }
        }
        update patientVisits;
        insert newVisits;
        update visits;
        patientVisits.addAll(newVisits);
        updateMissedVisits(patientVisits);
    }

    private static Boolean matchFoundByName(Integration_Visit__c externalVisit, Patient_Visit__c visit){
        if(externalVisit.VISIT__c != null){
            if(externalVisit.VISIT__c == visit.Name){
                updatePatientVisit(externalVisit, visit);
                return true;
            }
        }
        return false;
    }

    private static Boolean matchFoundByNumber(Integration_Visit__c externalVisit, Patient_Visit__c visit){
        if(externalVisit.VISITNUM__c != null){
            if(externalVisit.VISITNUM__c == visit.Visit_Number__c){
                updatePatientVisit(externalVisit, visit);
                return true;
            }
        }
        return false;
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

    private static void updatePatientVisit(Integration_Visit__c externalVisit, Patient_Visit__c visit){
        visit.Status__c = 'Completed';
        visit.Completed_Date__c = externalVisit.SVSTDTC__c;
    }
    
    private static void setIsProcessed(List<Integration_Visit__c> newList, Map<Id, Integration_Visit__c> oldMap){
        for(Integration_Visit__c visit : newList){
            if(oldMap == null || visit.MD5_Hash__c != oldMap.get(visit.Id).MD5_Hash__c){
                visit.Processed__c = false;
            }
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
        if(recordsChanged) update patientVisits;
    }

}