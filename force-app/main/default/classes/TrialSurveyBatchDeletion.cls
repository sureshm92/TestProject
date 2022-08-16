global class TrialSurveyBatchDeletion implements Database.Batchable<sObject>{
	private String ctpId;
    global TrialSurveyBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        /*List<Trial_Survey__c> trialSurvLst = CTPDeletionHelper.getTrialSurveys(ctpId);
        return Database.getQueryLocator([SELECT Id, Name FROM Trial_Survey__c WHERE Id IN :trialSurvLst]);*/
        return Database.getQueryLocator([SELECT Id, Name, Clinical_Trial_Profile__c FROM Trial_Survey__c 
                                  		 WHERE Clinical_Trial_Profile__c = :ctpId]);
    }
    
    global void execute(Database.BatchableContext BC, List<Trial_Survey__c> trialSurvLst){
        delete trialSurvLst;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}