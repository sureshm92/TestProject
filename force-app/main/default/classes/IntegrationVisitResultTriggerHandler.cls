/**
 * Created by user on 08-Jul-19.
 */

public without sharing class IntegrationVisitResultTriggerHandler {

    public class UpdateVisitResults extends TriggerHandler{

        public override void afterInsert(List<SObject> newList) {
            updateVisitResults(JSON.serialize(newList));
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updateVisitResults(JSON.serialize(newList));
        }
    }

    @future
    private static void updateVisitResults(String jsonString){
        //If USUBJID, STUDYID, VISIT, VSDTC AND TESTCD ARE PRIMARY KEYS Exclude record if blank or NULL
        List<Integration_VisitResult__c> results = (List<Integration_VisitResult__c>) JSON.deserialize(jsonString, List<Integration_Visit__c>.class);
        Set<String> externalIds = new Set<String>();
        Set<String> visitNames = new Set<String>();
        Set<Date> visitDates = new Set<Date>();
        getKeys(externalIds, visitNames, visitDates, results);
        Map<String, Patient_Visit__c> visitMap = getPatientVisitsMap(externalIds, visitNames, visitDates);
        Map<String, Visit_Result__c> resultMap = getVisitResultsMap(externalIds, visitNames, visitDates);
        Map<String, Id> recordTypesMap = getRecordTypeMap();
        Map<String,Visit_Result_TypeM__mdt> resultTypesMap = getVisitResultTypesMap();
        List<Visit_Result__c> newResults = new List<Visit_Result__c>();
        for(Integration_VisitResult__c result : results){
            String key = result.External_Key__c + result.VISIT__c + result.VSDTC__c + result.TESTCD__c;
            if(resultMap.containsKey(key)){
                populateVisitResult(resultMap.get(key), result, recordTypesMap, resultTypesMap);
            } else if(visitMap.containsKey(key.removeEnd(result.TESTCD__c))){
                newResults.add(createNewResult(visitMap.get(key.removeEnd(result.TESTCD__c)), result, recordTypesMap, resultTypesMap));
            }
        }
        update resultMap.values();
        insert newResults;
    }

    private static Visit_Result__c createNewResult(Patient_Visit__c visit, Integration_VisitResult__c externalResult, Map<String, Id> recordTypesMap, Map<String, Visit_Result_TypeM__mdt> resultTypesMap){
        Visit_Result__c result = new Visit_Result__c();
        populateVisitResult(result, externalResult, recordTypesMap, resultTypesMap);
        result.Patient_Visit__c = visit.Id;
        return result;
    }

    private static Map<String,Id> getRecordTypeMap(){
        List<RecordType> recordTypes = [
                SELECT
                        Id,
                        Name
                FROM    RecordType
                WHERE   Name = 'Lab'
                OR      Name = 'Vital'
        ];
        Map<String,Id> recordTypeMap = new Map<String, Id>();
        for(RecordType rt : recordTypes){
            recordTypeMap.put(rt.Name, rt.Id);
        }
        return recordTypeMap;
    }

    private static void getKeys(Set<String> externalIds, Set<String> visitNames, Set<Date> visitDates, List<Integration_VisitResult__c> results){
        for(Integration_VisitResult__c visitResult : results){
            if(visitResult.USUBJID__c != null
                    && visitResult.STUDYID__c != null
                    && visitResult.VISIT__c != null
                    && visitResult.VSDTC__c != null
                    && visitResult.TESTCD__c != null){
                externalIds.add(visitResult.External_Key__c);
                visitNames.add(visitResult.VISIT__c);
                visitDates.add(visitResult.VSDTC__c);
            }
        }
    }

    private static Map<String,Visit_Result_TypeM__mdt> getVisitResultTypesMap(){
        List<Visit_Result_TypeM__mdt> resultTypes = [
                SELECT
                        Label,
                        Visit_Result_Code__c
                FROM    Visit_Result_TypeM__mdt
        ];
        Map<String,Visit_Result_TypeM__mdt> resultTypeMap = new Map<String,Visit_Result_TypeM__mdt>();
        for(Visit_Result_TypeM__mdt resultType : resultTypes){
            for(String code : resultType.Visit_Result_Code__c.split(';')) {
                resultTypeMap.put(code, resultType);
            }
        }
        return resultTypeMap;
    }

    private static void populateVisitResult(Visit_Result__c result, Integration_VisitResult__c integrationVisitResult, Map<String,Id> recordTypesMap, Map<String, Visit_Result_TypeM__mdt> resultTypesMap){
        //Confirm
        result.Actual_Value__c = integrationVisitResult.STRESN__c;
        result.Max_Value__c = integrationVisitResult.STNRHI__c;
        result.Measurement__c = integrationVisitResult.STRESU__c;
        result.Min_Value__c = integrationVisitResult.STNRLO__c;
        result.RecordTypeId = recordTypesMap.get(integrationVisitResult.Vital_or_Lab__c);
        if(resultTypesMap.containsKey(integrationVisitResult.TESTCD__c)){
            result.Result_Type__c = resultTypesMap.get(integrationVisitResult.TESTCD__c).Label;
        }
    }

    private static Map<String, Visit_Result__c> getVisitResultsMap(Set<String> externalIds, Set<String> visitNames, Set<Date> visitDates){
        List<Visit_Result__c> visits = [
                SELECT
                        Id,
                        Actual_Value__c,
                        Max_Value__c,
                        Min_Value__c,
                        Measurement__c,
                        Result_Type__c,
                        Patient_Visit__r.Participant_Study_Enrollment__r.External_Key__c,
                        Patient_Visit__r.Name,
                        Patient_Visit__r.Completed_Date__c
                FROM    Visit_Result__c
                WHERE   Patient_Visit__r.Participant_Study_Enrollment__r.External_Key__c IN : externalIds
                AND     Patient_Visit__r.Name IN : visitNames
                AND     Patient_Visit__r.Completed_Date__c IN : visitDates
        ];
        Map<String, Visit_Result__c> resultMap = new Map<String, Visit_Result__c>();
        for(Visit_Result__c result : visits){
            String key = result.Patient_Visit__r.Participant_Study_Enrollment__r.External_Key__c +
                    result.Patient_Visit__r.Name +
                    result.Patient_Visit__r.Completed_Date__c + result.Result_Type__c;
            resultMap.put(key, result);
        }
        return resultMap;
    }

    private static Map<String, Patient_Visit__c> getPatientVisitsMap(Set<String> externalIds, Set<String> visitNames, Set<Date> visitDates){
        List<Patient_Visit__c> visits = [
                SELECT
                        Id,
                        Name,
                        Participant_Study_Enrollment__r.External_Key__c,
                        Completed_Date__c
                FROM    Patient_Visit__c
                WHERE   Name IN : visitNames
                AND     Completed_Date__c IN : visitDates
                AND     Participant_Study_Enrollment__r.External_Key__c IN : externalIds
        ];
        Map<String, Patient_Visit__c> visitMap = new Map<String, Patient_Visit__c>();
        for(Patient_Visit__c visit : visits){
            String key = visit.Participant_Study_Enrollment__r.External_Key__c + visit.Name + visit.Completed_Date__c;
            visitMap.put(key, visit);
        }
        return visitMap;
    }
}