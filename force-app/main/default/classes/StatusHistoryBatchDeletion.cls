global class StatusHistoryBatchDeletion implements Database.Batchable<sObject>{
	private String ctpId;
    global StatusHistoryBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<Study_Site__c> studySiteLst= [select Id,Name from Study_Site__c where Clinical_Trial_Profile__c=: ctpId];
        String query='Select Id, Name FROM Status_History__c where StudySite__c in:studySiteLst';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Status_History__c> statusHistoryLst){
        List<Status_History__c> recordsToDeleteSH= [select Id,name from Status_History__c where Id in: statusHistoryLst];
        if(!recordsToDeleteSH.isEmpty()){
            delete recordsToDeleteSH;
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
}