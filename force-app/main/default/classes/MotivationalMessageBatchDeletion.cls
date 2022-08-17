global class MotivationalMessageBatchDeletion implements Database.Batchable<sObject>{
	private String ctpId;
    global MotivationalMessageBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        /*List<Motivational_Message__c> motivMessageLst = CTPDeletionHelper.getMotivationalMessages(ctpId);
        return Database.getQueryLocator([SELECT Id, Name FROM Motivational_Message__c WHERE Id IN :motivMessageLst]);*/
        return Database.getQueryLocator([SELECT Id, Name, Clinical_Trial_Profile__c FROM Motivational_Message__c 
                                         WHERE Clinical_Trial_Profile__c = :ctpId]); 
    }
    
    global void execute(Database.BatchableContext BC, List<Motivational_Message__c> motivMessageLst){
        delete motivMessageLst;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}