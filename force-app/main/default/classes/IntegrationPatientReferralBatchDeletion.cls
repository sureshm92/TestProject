global class IntegrationPatientReferralBatchDeletion implements Database.Batchable<sObject>{
    private String ctpId;
    global IntegrationPatientReferralBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String protocolId = [SELECT Id, Protocol_ID__c FROM Clinical_Trial_Profile__c WHERE Id = :ctpId].Protocol_ID__c;
        
        String query = 'SELECT Id FROM Integration_Patient_Referral__c ';
        if(String.isNotBlank(protocolId)) {
            query += 'WHERE protocolId__c = :protocolId';
        } else {
            query += 'LIMIT 0';
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Integration_Patient_Referral__c> iprLst){
        delete iprLst;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}