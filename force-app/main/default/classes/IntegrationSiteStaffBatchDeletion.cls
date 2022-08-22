global class IntegrationSiteStaffBatchDeletion implements Database.Batchable<sObject>{
	private String ctpId;
    global IntegrationSiteStaffBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String protocolId = [SELECT Id, Protocol_ID__c FROM Clinical_Trial_Profile__c WHERE Id = :ctpId].Protocol_ID__c;
        String query = 'SELECT Id, Name FROM Integration_Site_Staff__c WHERE protocolId__c = : protocolId';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Integration_Site_Staff__c> intSiteStaffLst){
        delete intSiteStaffLst;
    }
    global void finish(Database.BatchableContext BC){
        
    }
}