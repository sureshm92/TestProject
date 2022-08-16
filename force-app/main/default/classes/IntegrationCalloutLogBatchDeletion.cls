global class IntegrationCalloutLogBatchDeletion implements Database.Batchable<sObject>{
	private String ctpId;
    global IntegrationCalloutLogBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        /*List<Integration_Callout_Log__c> intCalloutLogLst = CTPDeletionHelper.getIntegrationCalloutLogs(ctpId);
        return Database.getQueryLocator([SELECT Id, Name FROM Integration_Callout_Log__c WHERE Id IN :intCalloutLogLst]);*/
        return Database.getQueryLocator([SELECT Id, Name, Reference_Id__c FROM Integration_Callout_Log__c
                                  		 WHERE Reference_Id__c = :ctpId]);
    }
    
    global void execute(Database.BatchableContext BC, List<Integration_Callout_Log__c> intCalloutLogLst){
        delete intCalloutLogLst;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}