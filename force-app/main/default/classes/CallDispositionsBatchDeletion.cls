global class CallDispositionsBatchDeletion implements Database.Batchable<sObject>{
    private String ctpId;
    global CallDispositionsBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query='SELECT Id, Name,(Select Id,Name FROM Call_Dispositions__r) FROM Study_Site__c where Clinical_Trial_Profile__c = :ctpId';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Study_Site__c> studySiteLst){
        List<Call_Dispositions__c> callDispLst = new List<Call_Dispositions__c>();
        for(Study_Site__c ss : studySiteLst){
            callDispLst.addAll(ss.Call_Dispositions__r);
        }
        List<Call_Dispositions__c> recordToBeDeleteCall= [select Id,Name from Call_Dispositions__c where Id in:callDispLst];
        if(!recordToBeDeleteCall.isEmpty()){
            delete recordToBeDeleteCall;
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }

}