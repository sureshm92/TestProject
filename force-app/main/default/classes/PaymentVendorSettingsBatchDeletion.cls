global class PaymentVendorSettingsBatchDeletion implements Database.Batchable<sObject>, Database.Stateful{
    private String ctpId;
    private Boolean isStudyToDelete = false;
    private Set<Id> paymentVendorSettingsIds = new Set<Id>();
    private Set<Id> paymentVendorIds = new Set<Id>();
    
    global PaymentVendorSettingsBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global PaymentVendorSettingsBatchDeletion(String ctpId, Boolean isStudyToDelete){
        this.ctpId = ctpId;
        this.isStudyToDelete = isStudyToDelete;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<Study_Site__c> studySiteLst= [select Id,Name from Study_Site__c where Clinical_Trial_Profile__c=: ctpId];
        String query='Select Id,Name from PaymentVendorSettings__c where Study_Site__c in:studySiteLst';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<PaymentVendorSettings__c> paymentVendorSettingsLst){
        List<PaymentVendorSettings__c> recToDeletepayVenSet=[select Id, Name, Payment_Vendor__c from PaymentVendorSettings__c where Id in: paymentVendorSettingsLst];
        If(!recToDeletepayVenSet.isEmpty()){
            if(isStudyToDelete) {
                delete recToDeletepayVenSet;
            } else {
                
                paymentVendorSettingsIds.addAll((new Map<Id,PaymentVendorSettings__c>(
                    recToDeletepayVenSet
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
                    ctpId, 'Payment Vendor Settings', paymentVendorSettingsIds
                ));
                Batch_SCParticipantEnrollment.insertContentVersions(studyClosureProcessList[0].Id, contentVersions);
            }
        }
    }
}