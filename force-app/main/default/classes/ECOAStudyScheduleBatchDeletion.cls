global class ECOAStudyScheduleBatchDeletion implements Database.Batchable<sObject>{
	private String ctpId;
    global ECOAStudyScheduleBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        /*List<ECOA_Study_Schedule__c> ecoaStudSchLst = CTPDeletionHelper.getECOAStudySchedules(ctpId);
        return Database.getQueryLocator([SELECT Id, Name FROM ECOA_Study_Schedule__c WHERE Id IN :ecoaStudSchLst]);*/
        return Database.getQueryLocator([SELECT Id, Name, Clinical_Trial_Profile__c FROM ECOA_Study_Schedule__c 
                                         WHERE Clinical_Trial_Profile__c = :ctpId]);
    }
    
    global void execute(Database.BatchableContext BC, List<ECOA_Study_Schedule__c> ecoaStudSchLst){
        delete ecoaStudSchLst;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}