global class TrialNotificationBatchDeletion implements Database.Batchable<sObject>{
    private String ctpId;
    global TrialNotificationBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
    
        return Database.getQueryLocator([
            SELECT Id FROM Trial_Notification__c WHERE Clinical_Trial_Profile__c = :ctpId
        ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Trial_Notification__c> trialNotifList){
        delete trialNotifList;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}