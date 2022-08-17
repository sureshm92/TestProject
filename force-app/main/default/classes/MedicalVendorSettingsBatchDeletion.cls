global class MedicalVendorSettingsBatchDeletion implements Database.Batchable<sObject>, Database.Stateful{
    private String ctpId;
    private Boolean isStudyToDelete = false;
    private Set<Id> medicalVendorSettingsIds = new Set<Id>();
    private Set<Id> medicalRecordVendorIds = new Set<Id>();
    
    global MedicalVendorSettingsBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global MedicalVendorSettingsBatchDeletion(String ctpId, Boolean isStudyToDelete){
        this.ctpId = ctpId;
        this.isStudyToDelete = isStudyToDelete;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<Study_Site__c> studySiteLst= [select Id,Name from Study_Site__c where Clinical_Trial_Profile__c=: ctpId];
        String query='Select Id,Name from MedicalVendorSettings__c where Study_Site__c in:studySiteLst';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<MedicalVendorSettings__c> medVendorSetLst){
        List<MedicalVendorSettings__c> recsToDeletemedVenSet=[select Id, Name,Medical_Record_Vendor__c from MedicalVendorSettings__c where Id in: medVendorSetLst];
        if(!recsToDeletemedVenSet.isEmpty()){
            if(isStudyToDelete) {
                delete recsToDeletemedVenSet;
            } else {
                medicalVendorSettingsIds.addAll((new Map<Id,MedicalVendorSettings__c>(
                    recsToDeletemedVenSet
                )).keySet());
            }
        }
    }
    global void finish(Database.BatchableContext BC){
        
        if(isStudyToDelete == false) {
        
            List<Study_Closure__c> studyClosureProcessList = [
                SELECT Id FROM Study_Closure__c WHERE Clinical_Trial_Profile_Id__c = :ctpId LIMIT 1
            ];
            if(studyClosureProcessList.isEmpty() == false) {
                
                List<ContentVersion> contentVersions =new List<ContentVersion>();
                contentVersions.add(Batch_SCParticipantEnrollment.constructCsvFile(
                    ctpId, 'Medical Vendor Settings', medicalVendorSettingsIds
                ));
                
                Batch_SCParticipantEnrollment.insertContentVersions(studyClosureProcessList[0].Id, contentVersions);
            }
        }
    }
}