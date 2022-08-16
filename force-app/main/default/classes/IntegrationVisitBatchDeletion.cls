global class IntegrationVisitBatchDeletion implements Database.Batchable<sObject>{
	private String ctpId;
    global IntegrationVisitBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query='SELECT Id, Name, STUDYID__c FROM Integration_Visit__c WHERE STUDYID__c = :ctpId';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Integration_Visit__c> integrationVisitLst){
        List<Integration_Visit__c> recordToBeDeletedIV = [SELECT Id, Name, STUDYID__c FROM Integration_Visit__c WHERE Id IN :integrationVisitLst];
        if(!recordToBeDeletedIV.isEmpty()){
            delete recordToBeDeletedIV;
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
}