public class Batch_UpdatePIStatusField implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select Id, Override_PI_Referral_Status__c from Study_Site__c ');
    }
    public void execute(Database.BatchableContext BC, List<Study_Site__c> scope){
        for(Study_Site__c ss : scope){
            if(ss.Override_PI_Referral_Status__c == 'On Hold' || ss.Override_PI_Referral_Status__c =='On Hold (Admin)' 
               || ss.Override_PI_Referral_Status__c =='Accepted (Admin)'){
                ss.Override_PI_Referral_Status__c = 'Accepted';
            }
            else if(ss.Override_PI_Referral_Status__c =='Deactivated (Admin)'
               || ss.Override_PI_Referral_Status__c =='Non-Responsive (Admin)'
               || ss.Override_PI_Referral_Status__c == 'Declined (Acceptance)'){
                ss.Override_PI_Referral_Status__c = 'Deactivated';
            }
            else if(ss.Override_PI_Referral_Status__c ==null || ss.Override_PI_Referral_Status__c =='' ){
                ss.Override_PI_Referral_Status__c = 'None';
            }
        }
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.PrepareAdditionalFieldsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.DeleteStatusHistoryOnDeleteHandler.class);
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.CreatePIOrSendNotificationHandler.class);
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.SwitchContactUserModeHandler.class);
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.CreateStatusHistoryHandler.class);
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.CreateHCPEnrollmentsForRPInWhiteListHandler.class);
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.SetSuppressEmailsFieldAccordingToStudy.class);
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.AssignCommunityPermissionsForUser.class);
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.SetEnableCCSupportFieldAccordingToStudy.class);
        update scope;
    }
    public void finish(Database.BatchableContext BC){
        
    }
}