/**
 * Created by Rushikesh Kadam on 03-Jan-2022.
 */

public without sharing class Batch_SDHDataFix implements Database.Batchable<SObject>, Database.Stateful{
    public Set<String> sDHSet;
    public Map<String, Visit_Result_TypeM__mdt> resultTypesByCodes;
    
    public Batch_SDHDataFix(){
        sDHSet = new Set<String>();
        resultTypesByCodes = this.getVisitResultTypesMap();
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            [
                SELECT
                    Id,
                	RecordTypeId,
                    Actual_Value__c,
                    Max_Value__c,
                    Min_Value__c,
                    Measurement__c,
                    Result_Type__c,
                    Patient_Visit__r.Participant_Enrollment__r.External_Key__c,
                    Patient_Visit__r.Name,
                    Patient_Visit__r.Completed_Date__c,
                    SDH_Key__c
                FROM Visit_Result__c
                WHERE SDH_Key__c!=null
            ]
        );
    }

    public void execute(Database.BatchableContext param1, List<Visit_Result__c> scope) {
        List<Visit_Result__c> vRToBeCreated = new List<Visit_Result__c>();
        List<Visit_Result__c> vRToBeUpdated = new List<Visit_Result__c>();
        Set<String> sdhVRSet = new Set<String>();
        Set<String> usubidSet = new Set<String>();
        for(Visit_Result__c vr: scope){
            sdhVRSet.add(vr.SDH_Key__c);
            usubidSet.add(vr.Patient_Visit__r.Participant_Enrollment__r.External_Key__c);
        }
        
        Map<String, List<Integration_VisitResult__c>> iVRSDHMap = this.getKeysIVRMap(usubidSet);
        Map<String, List<Visit_Result__c>> vRSDHMap = this.getKeysVRMap(sdhVRSet);

        for(Visit_Result__c vr: scope){

            if(iVRSDHMap.containsKey(vr.SDH_Key__c + vr.Result_Type__c)){
                List<Integration_VisitResult__c> iVRList = iVRSDHMap.get(vr.SDH_Key__c + vr.Result_Type__c);
                List<Visit_Result__c> vRList = vRSDHMap.get(vr.SDH_Key__c + vr.Result_Type__c);

                if(iVRList!=null && iVRList.size()==1 && vRList!=null && vRList.size()==1){
                    vr.SDH_Key__c = vr.SDH_Key__c + iVRList[0].VISITNUM__c.stripTrailingZeros().toPlainString();
                    vRToBeUpdated.add(vr);
                }else if(iVRList!=null && iVRList.size()>1 && vRList!=null && vRList.size()==1){
                    String oldVisitKey = vr.SDH_Key__c;
                    vr.SDH_Key__c = vr.SDH_Key__c + iVRList[0].VISITNUM__c.stripTrailingZeros().toPlainString();
                    vRToBeUpdated.add(vr);
                    for(Integer i = 1; i<iVRList.size(); i++){
                        Visit_Result__c visitResult = new Visit_Result__c();
                        String codeResult = iVRList[i].TESTCD__c.toUpperCase();
                        visitResult.SDH_Key__c = oldVisitKey + iVRList[i].VISITNUM__c.stripTrailingZeros().toPlainString();
                        visitResult.Patient_Visit__c = vr.Patient_Visit__c;
                        visitResult.Actual_Value__c = iVRList[i].STRESN__c;
                        visitResult.Max_Value__c = iVRList[i].STNRHI__c;
                        visitResult.Measurement__c = iVRList[i].STRESU__c;
                        visitResult.Min_Value__c = iVRList[i].STNRLO__c;
                        visitResult.RecordTypeId = vr.RecordTypeId;
                        visitResult.Result_Type__c = vr.Result_Type__c;
                        vRToBeCreated.add(visitResult);
                    }
                }else if(iVRList!=null && iVRList.size()>1 && vRList!=null && vRList.size()==iVRList.size()){
                    if(!sDHSet.contains(vr.SDH_Key__c+vr.Result_Type__c)){
                        sDHSet.add(vr.SDH_Key__c+vr.Result_Type__c);
                        for(Integer i = 0; i<iVRList.size(); i++){
                            vRList[i].SDH_Key__c = vRList[i].SDH_Key__c + iVRList[i].VISITNUM__c.stripTrailingZeros().toPlainString();
                            vRToBeUpdated.add(vRList[i]);
                        }
                    }
                }
            }
        }
        if(!vRToBeCreated.isEmpty()){
            Database.insert(vRToBeCreated);
        }
        if(!vRToBeUpdated.isEmpty()){
            Database.update(vRToBeUpdated);
        }
        
    }
    
    public void finish(Database.BatchableContext param1) {
    }

    private Map<String, List<Integration_VisitResult__c>> getKeysIVRMap(Set<String> usubidSet) {
        List<Integration_VisitResult__c> results = new List<Integration_VisitResult__c>();
        results = [SELECT
                        Id,
                        OwnerId,
                        IsDeleted,
                        Name,
                        CreatedDate,
                        CreatedById,
                        LastModifiedDate,
                        LastModifiedById,
                        SystemModstamp,
                        External_Key__c,
                        IsDeletedInSDH__c,
                        MD5__c,
                        NRIND__c,
                        STNRHI__c,
                        STNRLO__c,
                        STRESN__c,
                        STRESU__c,
                        STUDYID__c,
                        TESTCD__c,
                        USUBJID__c,
                        VISITNUM__c,
                        VISIT__c,
                        VSDTC__c,
                        Vital_or_Lab__c,
                        Work_Status__c
                    FROM Integration_VisitResult__c
                   	WHERE IsDeletedInSDH__c='N'
                    AND USUBJID__c IN: usubidSet
                    ORDER BY VISITNUM__c
                    ];

        Map<String, List<Integration_VisitResult__c>> externalKeys = new Map<String, List<Integration_VisitResult__c>>();
        for (Integration_VisitResult__c visitResult : results) {
            if (
                visitResult.USUBJID__c != null &&
                visitResult.STUDYID__c != null &&
                visitResult.VISIT__c != null &&
                visitResult.VSDTC__c != null &&
                visitResult.TESTCD__c != null &&
                visitResult.VISITNUM__c != null
            ) {
                String sDHKey = visitResult.USUBJID__c + visitResult.VISIT__c + visitResult.VSDTC__c + 
                    resultTypesByCodes.get(visitResult.TESTCD__c.toUpperCase()).DeveloperName;
                if(externalKeys.containsKey(sDHKey)){
                    List<Integration_VisitResult__c> iVRList = externalKeys.get(sDHKey);
                    iVRList.add(visitResult);
                    externalKeys.put(sDHKey, iVRList);
                }else{
                    externalKeys.put(sDHKey, new List<Integration_VisitResult__c>{visitResult});
                }
            }
        }
        return externalKeys;
    }
    
    private Map<String, List<Visit_Result__c>> getKeysVRMap(Set<String> sdhVRSet) {
        List<Visit_Result__c> results = new List<Visit_Result__c>();
        results = [ SELECT
                        Id,
                        RecordTypeId,
                        Actual_Value__c,
                        Max_Value__c,
                        Min_Value__c,
                        Measurement__c,
                        Result_Type__c,
                        Patient_Visit__r.Participant_Enrollment__r.External_Key__c,
                        Patient_Visit__r.Name,
                        Patient_Visit__r.Completed_Date__c,
                        SDH_Key__c
                        FROM Visit_Result__c
                    WHERE SDH_Key__c IN: sdhVRSet
                    ];

        Map<String, List<Visit_Result__c>> externalKeys = new Map<String, List<Visit_Result__c>>();
        for (Visit_Result__c visitResult : results) {
            if (
                visitResult.SDH_Key__c != null &&
                visitResult.Result_Type__c != null
            ) {
                String sDHKey = visitResult.SDH_Key__c + visitResult.Result_Type__c;
                if(externalKeys.containsKey(sDHKey)){
                    List<Visit_Result__c> vRList = externalKeys.get(sDHKey);
                    vRList.add(visitResult);
                    externalKeys.put(sDHKey, vRList);
                }else{
                    externalKeys.put(sDHKey, new List<Visit_Result__c>{visitResult});
                }
            }
        }
        return externalKeys;
    }

    private Map<String, Visit_Result_TypeM__mdt> getVisitResultTypesMap() {
        List<Visit_Result_TypeM__mdt> resultTypes = [
            SELECT DeveloperName, Visit_Result_Code__c
            FROM Visit_Result_TypeM__mdt
        ];
        Map<String, Visit_Result_TypeM__mdt> resultTypeMap = new Map<String, Visit_Result_TypeM__mdt>();
        for (Visit_Result_TypeM__mdt resultType : resultTypes) {
            if (resultType.Visit_Result_Code__c != null) {
                for (String code : resultType.Visit_Result_Code__c.split(';')) {
                    resultTypeMap.put(code.toUpperCase(), resultType);
                }
            }
        }
        return resultTypeMap;
    }
}