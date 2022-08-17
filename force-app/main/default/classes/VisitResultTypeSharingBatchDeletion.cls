global class VisitResultTypeSharingBatchDeletion implements Database.Batchable<sObject>{
	private String ctpId;
    global VisitResultTypeSharingBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        /*List<Visit_Result_Type_Sharing__c> visitResTypeSharingLst = CTPDeletionHelper.getVisitResultTypeSharings(ctpId);
        return Database.getQueryLocator([SELECT Id, Name FROM Visit_Result_Type_Sharing__c WHERE Id IN :visitResTypeSharingLst]);*/
        return Database.getQueryLocator([SELECT Id, Name, Clinical_Trial_Profile__c FROM Visit_Result_Type_Sharing__c 
                                         WHERE Clinical_Trial_Profile__c =:ctpId]); 
    }
    
    global void execute(Database.BatchableContext BC, List<Visit_Result_Type_Sharing__c> visitResTypeSharingLst){
        delete visitResTypeSharingLst;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}