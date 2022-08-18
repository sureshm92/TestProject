global class MediaOutreachBatchDeletion implements Database.Batchable<sObject>{
	private String ctpId;
    global MediaOutreachBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<Study_Site__c> studySiteLst= [select Id,Name from Study_Site__c where Clinical_Trial_Profile__c=: ctpId];
        String query='Select Id, Name, Media_Type__c FROM Media_Outreach__c where Study_Name__c in:studySiteLst';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Media_Outreach__c> mediaOutreachLst){
        List<Media_Outreach__c> recordsToBeDeletedMO=[Select Id, Name, Media_Type__c FROM Media_Outreach__c where Id in:mediaOutreachLst];
        if(!recordsToBeDeletedMO.isEmpty()){
            delete mediaOutreachLst;
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
}