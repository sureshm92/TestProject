global class IncentivePlanBatchDeletion implements Database.Batchable<sObject>{
	private String ctpId;
    global IncentivePlanBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        /*List<Incentive_Plan__c> incPlanLst = CTPDeletionHelper.getIncentivePlans(ctpId);
        return Database.getQueryLocator([SELECT Id, Name FROM Incentive_Plan__c WHERE Id IN :incPlanLst]);*/
        return Database.getQueryLocator([SELECT Id, Name, Clinical_Trial_Profile__c FROM Incentive_Plan__c 
                                         WHERE Clinical_Trial_Profile__c = :ctpId]); 
    }
    
    global void execute(Database.BatchableContext BC, List<Incentive_Plan__c> incPlanLst){
        delete incPlanLst;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}