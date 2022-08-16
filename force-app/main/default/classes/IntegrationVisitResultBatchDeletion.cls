global class IntegrationVisitResultBatchDeletion implements Database.Batchable<sObject>{
    private String ctpId;
    global IntegrationVisitResultBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query='SELECT Id, Name, STUDYID__c FROM Integration_VisitResult__c WHERE STUDYID__c = :ctpId';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Integration_VisitResult__c> integrationVisitResLst){
        List<Integration_VisitResult__c> recordToBeDeletedIVR = [SELECT Id, Name, STUDYID__c FROM Integration_VisitResult__c WHERE Id IN :integrationVisitResLst];
        if(!recordToBeDeletedIVR.isEmpty()){
            delete recordToBeDeletedIVR;
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
}