global class StudyIncentivePlanBatchDeletion implements Database.Batchable<sObject>{
	private String ctpId;
    global StudyIncentivePlanBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        /*List<Study_Incentive_Plan__c> studIncPlanLst = CTPDeletionHelper.getStudyIncentivePlans(ctpId);
        return Database.getQueryLocator([SELECT Id, Name FROM Study_Incentive_Plan__c WHERE Id IN :studIncPlanLst]);*/
        return Database.getQueryLocator([SELECT Id, Name, Clinical_Trial_Profile__c FROM Study_Incentive_Plan__c 
                                         WHERE Clinical_Trial_Profile__c = :ctpId]); 
    }
    
    global void execute(Database.BatchableContext BC, List<Study_Incentive_Plan__c> studIncPlanLst){
        delete studIncPlanLst;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}