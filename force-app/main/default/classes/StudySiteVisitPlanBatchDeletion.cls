global class StudySiteVisitPlanBatchDeletion implements Database.Batchable<sObject>{
	private String ctpId;
    global StudySiteVisitPlanBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<Study_Site__c> studySiteLst= [select Id,Name from Study_Site__c where Clinical_Trial_Profile__c=: ctpId];
        String query='Select Id, Name FROM StudySiteVisitPlan__c where Study_Site__c in:studySiteLst';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<StudySiteVisitPlan__c> studySiteVisitPlanLst){
        List<StudySiteVisitPlan__c> recordsToDeleteSSVP= [select Id,name from StudySiteVisitPlan__c where Id in: studySiteVisitPlanLst];
        if(!recordsToDeleteSSVP.isEmpty()){
            delete recordsToDeleteSSVP;
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
}