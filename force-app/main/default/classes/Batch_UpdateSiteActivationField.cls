public class Batch_UpdateSiteActivationField implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        List<String> referralsStatus = new List<String>{'Accepted','Accepted (Admin)','Deactivated (Admin)','Deactivated','Invitation Sent','On Hold (Admin)','On Hold'};
        return Database.getQueryLocator('select Id,Site_Activation_Status__c, Override_PI_Referral_Status__c  from Study_Site__c '
                                        +'where Site_Activation_Status__c !=null and (Override_PI_Referral_Status__c  IN :referralsStatus or Override_PI_Referral_Status__c =null) ');
    }
    public void execute(Database.BatchableContext BC, List<Study_Site__c> scope){
        for(Study_Site__c ss : scope){
            system.debug('ss.Override_PI_Referral_Status__c :: '+ss.Override_PI_Referral_Status__c);
            if(ss.Override_PI_Referral_Status__c == 'Accepted' || ss.Override_PI_Referral_Status__c =='Accepted (Admin)'){
                ss.Site_Activation_Status__c = 'Activated (Admin)';
            }
            else if(ss.Override_PI_Referral_Status__c =='Deactivated (Admin)'
               || ss.Override_PI_Referral_Status__c =='Deactivated'
               || ss.Override_PI_Referral_Status__c == 'Invitation Sent'){
                ss.Site_Activation_Status__c = 'Deactivated';
            }
            else if(ss.Override_PI_Referral_Status__c == 'On Hold (Admin)'
               || ss.Override_PI_Referral_Status__c == 'On Hold'){
                ss.Site_Activation_Status__c = 'On Hold';
            }
            else if(ss.Override_PI_Referral_Status__c ==null || ss.Override_PI_Referral_Status__c =='' ){
                ss.Site_Activation_Status__c = 'Deactivated (Admin)';
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