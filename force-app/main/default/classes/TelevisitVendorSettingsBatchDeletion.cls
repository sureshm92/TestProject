global class TelevisitVendorSettingsBatchDeletion implements Database.Batchable<sObject>{
	private String ctpId;
    global TelevisitVendorSettingsBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<Study_Site__c> studySiteLst= [select Id,Name from Study_Site__c where Clinical_Trial_Profile__c=: ctpId];
        String query='Select Id,Name from TelevisitVendorSettings__c where Study_Site__c in:studySiteLst';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<TelevisitVendorSettings__c> telVisitVendorLst){
        List<TelevisitVendorSettings__c> recToDeleteVenSet=[select Id, Name, Televisit_Record_Vendor__c from TelevisitVendorSettings__c where Id in: telVisitVendorLst];
        if(!recToDeleteVenSet.isEmpty()){
            delete recToDeleteVenSet;
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
}