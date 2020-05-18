/**
 * Created by Dmytro Pokutnii
 */
public with sharing class IntegrationVisitResultService {

    Map<String, Id> recordTypeIdsByNames;
    Map<String,Visit_Result_TypeM__mdt> resultTypesByCodes;

    public IntegrationVisitResultService() {
        this.recordTypeIdsByNames = this.getRecordTypeMap();
        this.resultTypesByCodes = this.getVisitResultTypesMap();
    }

    public void updateVisitResults(List<Integration_VisitResult__c> iResults){
        //If USUBJID, STUDYID, VISIT, VSDTC AND TESTCD ARE PRIMARY KEYS Exclude record if blank or NULL

        Set<String> externalKeys = this.getKeys(iResults);
        Map<String, Patient_Visit__c> visitsByExternalIds = this.getPatientVisitsMap(externalKeys);
        Map<String, Visit_Result__c> resultsByExternalIds = this.getVisitResultsMap(externalKeys);

        List<Visit_Result__c> newResults = new List<Visit_Result__c>();
        List<Visit_Result__c> resultsToDelete = new List<Visit_Result__c>();
        List<Visit_Result__c> resultsToUpdate = new List<Visit_Result__c>();

        for(Integration_VisitResult__c iResult : iResults){
            String codeResult = iResult.TESTCD__c.toUpperCase();
            if (resultTypesByCodes.containsKey(codeResult)) {
                String visitKey = iResult.USUBJID__c + iResult.VISIT__c + iResult.VSDTC__c;
                String key = visitKey + resultTypesByCodes.get(codeResult).DeveloperName;

                if(resultsByExternalIds.containsKey(key)){
                    Visit_Result__c result = resultsByExternalIds.get(key);
                    if(iResult.IsDeletedInSDH__c == 'N') {
                        resultsToUpdate.add(this.populateVisitResult(result, visitKey, iResult));
                    } else {
                        resultsToDelete.add(result);
                    }
                } else if(visitsByExternalIds.containsKey(visitKey)){
                    newResults.add(this.createNewResult(visitsByExternalIds.get(visitKey), visitKey, iResult));
                }
            }
        }

        update resultsToUpdate;
        delete resultsToDelete;
        insert newResults;
        update iResults;
    }

    private Visit_Result__c createNewResult(Patient_Visit__c visit, String externalId, Integration_VisitResult__c iResult){
        Visit_Result__c result = this.populateVisitResult(new Visit_Result__c(), externalId, iResult);
        result.Patient_Visit__c = visit.Id;
        return result;
    }

    private Map<String,Id> getRecordTypeMap(){
        return new Map<String, Id>{
                'Lab' => SchemaUtil.getRecordTypeIdByName('Lab', Visit_Result__c.getSObjectType()),
                'Vital' => SchemaUtil.getRecordTypeIdByName('Vital', Visit_Result__c.getSObjectType()),
                'Biomarker' => SchemaUtil.getRecordTypeIdByName('Biomarker', Visit_Result__c.getSObjectType())
        };
    }

    private Set<String> getKeys(List<Integration_VisitResult__c> results){

        Set<String> externalKeys = new Set<String>();
        for(Integration_VisitResult__c visitResult : results){
            visitResult.Work_Status__c = 'Failed';
            if(visitResult.USUBJID__c != null
                    && visitResult.STUDYID__c != null
                    && visitResult.VISIT__c != null
                    && visitResult.VSDTC__c != null
                    && visitResult.TESTCD__c != null){
                externalKeys.add(visitResult.USUBJID__c + visitResult.VISIT__c + visitResult.VSDTC__c);
            }
        }
        return externalKeys;
    }

    private Map<String,Visit_Result_TypeM__mdt> getVisitResultTypesMap(){

        List<Visit_Result_TypeM__mdt> resultTypes = [
                SELECT
                        DeveloperName,
                        Visit_Result_Code__c
                FROM    Visit_Result_TypeM__mdt
        ];
        Map<String,Visit_Result_TypeM__mdt> resultTypeMap = new Map<String,Visit_Result_TypeM__mdt>();
        for(Visit_Result_TypeM__mdt resultType : resultTypes){
            if(resultType.Visit_Result_Code__c != null) {
                for (String code : resultType.Visit_Result_Code__c.split(';')) {
                    resultTypeMap.put(code.toUpperCase(), resultType);
                }
            }
        }
        return resultTypeMap;
    }

    private Visit_Result__c populateVisitResult(Visit_Result__c result, String externalKey, Integration_VisitResult__c integrationVisitResult){

        result.Actual_Value__c = integrationVisitResult.STRESN__c;
        result.Max_Value__c = integrationVisitResult.STNRHI__c;
        result.Measurement__c = integrationVisitResult.STRESU__c;
        result.Min_Value__c = integrationVisitResult.STNRLO__c;
        result.RecordTypeId = this.recordTypeIdsByNames.get(integrationVisitResult.Vital_or_Lab__c);
        result.SDH_Key__c = externalKey;
        if(resultTypesByCodes.containsKey(integrationVisitResult.TESTCD__c.toUpperCase())){
            result.Result_Type__c = resultTypesByCodes.get(integrationVisitResult.TESTCD__c.toUpperCase()).DeveloperName;
        }
        integrationVisitResult.Work_Status__c = 'Success';
        integrationVisitResult.Processed__c = true;

        return result;
    }

    private Map<String, Visit_Result__c> getVisitResultsMap(Set<String> externalKeys){

        List<Visit_Result__c> visitResults = [
                SELECT
                        Id,
                        Actual_Value__c,
                        Max_Value__c,
                        Min_Value__c,
                        Measurement__c,
                        Result_Type__c,
                        Patient_Visit__r.Participant_Enrollment__r.External_Key__c,
                        Patient_Visit__r.Name,
                        Patient_Visit__r.Completed_Date__c,
                        SDH_Key__c
                FROM    Visit_Result__c
                WHERE   SDH_Key__c IN :externalKeys
        ];
        Map<String, Visit_Result__c> resultMap = new Map<String, Visit_Result__c>();
        for(Visit_Result__c result : visitResults){
            resultMap.put(result.SDH_Key__c + result.Result_Type__c, result);
        }
        return resultMap;
    }

    private Map<String, Patient_Visit__c> getPatientVisitsMap(Set<String> externalKeys){

        List<Patient_Visit__c> visits = [
                SELECT
                        Id,
                        Name,
                        Participant_Enrollment__r.External_Key__c,
                        Completed_Date__c,
                        SDH_Key__c
                FROM    Patient_Visit__c
                WHERE   SDH_Key__c IN : externalKeys
        ];
        Map<String, Patient_Visit__c> visitMap = new Map<String, Patient_Visit__c>();
        for(Patient_Visit__c visit : visits){
            visitMap.put(visit.SDH_Key__c, visit);
        }
        return visitMap;
    }
}