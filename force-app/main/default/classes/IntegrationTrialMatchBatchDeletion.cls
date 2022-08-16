global class IntegrationTrialMatchBatchDeletion implements Database.Batchable<sObject>{
	private String ctpId;
    global IntegrationTrialMatchBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String protocolId = [SELECT Id, Protocol_ID__c FROM Clinical_Trial_Profile__c WHERE Id = :ctpId].Protocol_ID__c;
        String query = 'SELECT Id, Name FROM Integration_Trial_Match__c WHERE Protocol_ID__c = : protocolId';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Integration_Trial_Match__c> intTrailMatchLst){
        delete intTrailMatchLst;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}