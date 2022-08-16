global class IntegrationPatientBatchDeletion implements Database.Batchable<sObject>{
	private String ctpId;
    global IntegrationPatientBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query='SELECT Id, Name, STUDYID__c FROM Integration_Patient__c WHERE STUDYID__c = :ctpId';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Integration_Patient__c> intPatientLst){
        List<Integration_Patient__c> recordToBeDeletedIP = [SELECT Id, Name, STUDYID__c FROM Integration_Patient__c WHERE Id IN :intPatientLst];
        if(!recordToBeDeletedIP.isEmpty()){
            delete recordToBeDeletedIP;
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
}