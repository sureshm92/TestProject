//One time batch for updating DCT_Platform__c field 
//Needs to be deleted

global without sharing class Batch_UpdatePromotetoDCT implements Database.Batchable<SObject> {
     global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(
            [
                SELECT Id, Promote_to_SH__c,DCT_Platform__c FROM Clinical_Trial_Profile__c WHERE Promote_to_SH__c = True
            ]
        );
    }
    global void execute(Database.BatchableContext bc, List<Clinical_Trial_Profile__c> scope) {
        List<Clinical_Trial_Profile__c> ctp = new list<Clinical_Trial_Profile__c>();
        for(Clinical_Trial_Profile__c c : scope){
            c.DCT_Platform__c = 'Study Hub';
            ctp.add(c);
        }
        TriggerHandlerExecutor.bypassHandler(ClinicalTrialProfileTriggerHandler.class);
        if(!ctp.isEmpty()){
            Database.update(ctp,false);
        }
    }
    global void finish(Database.BatchableContext bc) {
    }

}