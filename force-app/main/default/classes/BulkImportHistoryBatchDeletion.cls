global class BulkImportHistoryBatchDeletion implements Database.Batchable<sObject>{
	private String ctpId;
    global BulkImportHistoryBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<Study_Site__c> studySiteLst= [select Id,Name from Study_Site__c where Clinical_Trial_Profile__c=: ctpId];
        String query='SELECT Id, Name, File_Name__c FROM Bulk_Import_History__c where Study_Site__c in:studySiteLst';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Bulk_Import_History__c> bulkImportHistLst){
        List<Bulk_Import_History__c> recordToBeDeletedBIH = [SELECT Id, Name, File_Name__c FROM Bulk_Import_History__c where Id in:bulkImportHistLst];
        if(!recordToBeDeletedBIH.isEmpty()){
            delete recordToBeDeletedBIH;
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
}