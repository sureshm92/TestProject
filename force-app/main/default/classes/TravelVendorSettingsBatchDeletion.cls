global class TravelVendorSettingsBatchDeletion implements Database.Batchable<sObject>, Database.Stateful{
    private String ctpId;
    private Boolean isStudyToDelete = false;
    private Set<Id> travelVendorSettingsIds = new Set<Id>();
    private Set<Id> travelVendorIds = new Set<Id>();
    
    global TravelVendorSettingsBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global TravelVendorSettingsBatchDeletion(String ctpId, Boolean isStudyToDelete){
        this.ctpId = ctpId;
        this.isStudyToDelete = isStudyToDelete;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<Study_Site__c> studySiteLst= [select Id,Name from Study_Site__c where Clinical_Trial_Profile__c=: ctpId];
        String query='Select Id,Name,TravelVendor__c FROM TravelVendorSettings__c where Study_Site__c in:studySiteLst';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<TravelVendorSettings__c> travelVendorSettingsLst){
        List<TravelVendorSettings__c> recToDeleteTVenSet=[select Id, Name, TravelVendor__c from TravelVendorSettings__c where Id in: travelVendorSettingsLst];
        if(!recToDeleteTVenSet.isEmpty()){
            if(isStudyToDelete) {
                delete recToDeleteTVenSet;
            } else {
                travelVendorSettingsIds.addAll((new Map<Id,TravelVendorSettings__c>(
                    recToDeleteTVenSet
                )).keySet());
            }
        }
        /*Map<Id,TravelVendor__c> travelVenRecMap = new Map<Id,TravelVendor__c>();
        List<TravelVendorSettings__c> travelVendorSettingsLst = new List<TravelVendorSettings__c>();
        for(Study_Site__c ss : studySiteLst){
            travelVendorSettingsLst.addAll(ss.TravelVendorSettings__r);
        }
        for(TravelVendorSettings__c tvsRec : travelVendorSettingsLst){
            if(tvsRec.TravelVendor__c!= null && !travelVenRecMap.containsKey(tvsRec.TravelVendor__c)){
                travelVenRecMap.put(tvsRec.TravelVendor__c,new TravelVendor__c(Id=tvsRec.TravelVendor__c));
            }
        }
        for(TravelVendorSettings__c travelVenSetRec: [select Id, Name, TravelVendor__c from TravelVendorSettings__c 
                                                      where TravelVendor__c in: travelVenRecMap.keySet() and Id not in:travelVendorSettingsLst and Study_Site__c not in:[select Id from Study_Site__c where Clinical_Trial_Profile__c= :ctpId]]){
            if(travelVenRecMap.containsKey(travelVenSetRec.TravelVendor__c)){
                travelVenRecMap.remove(travelVenSetRec.TravelVendor__c);
            }
        }
        if(!travelVendorSettingsLst.isEmpty()){
            List<TravelVendorSettings__c> recToDeleteTVenSet=[select Id, Name, TravelVendor__c from TravelVendorSettings__c where Id in: travelVendorSettingsLst];
            
            if(isStudyToDelete) {
                delete recToDeleteTVenSet;
            } else {
                
                travelVendorSettingsIds.addAll((new Map<Id,TravelVendorSettings__c>(
                    recToDeleteTVenSet
                )).keySet());
            }
        }
        If(!travelVenRecMap.isEmpty()){
            List<TravelVendor__c> recToDeleteTVenRec =[SELECT Id, Name FROM TravelVendor__c WHERE Id IN :travelVenRecMap.keySet()];
            
            if(isStudyToDelete) {
                delete recToDeleteTVenRec;
            } else {
                
                travelVendorIds.addAll((new Map<Id,TravelVendor__c>(
                    recToDeleteTVenRec
                )).keySet());
            }
        }*/
    }
    global void finish(Database.BatchableContext BC){
        
         if(isStudyToDelete == false) {
        
            List<Study_Closure__c> studyClosureProcessList = [
                SELECT Id FROM Study_Closure__c WHERE Clinical_Trial_Profile_Id__c = :ctpId LIMIT 1
            ];
            if(studyClosureProcessList.isEmpty() == false) {
                
                List<ContentVersion> contentVersions =new List<ContentVersion>();
                contentVersions.add(Batch_SCParticipantEnrollment.constructCsvFile(
                    ctpId, 'Travel Vendor Settings', travelVendorSettingsIds
                ));
                /*contentVersions.add(Batch_SCParticipantEnrollment.constructCsvFile(
                    ctpId, 'Travel Vendor', travelVendorIds
                ));*/
                
                Batch_SCParticipantEnrollment.insertContentVersions(studyClosureProcessList[0].Id, contentVersions);
            }
        }
    }
}