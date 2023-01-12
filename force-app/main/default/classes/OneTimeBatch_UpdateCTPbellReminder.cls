global without sharing class OneTimeBatch_UpdateCTPbellReminder implements Database.Batchable<SObject>{

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(
            [SELECT Bell_Notification_Reminder__c,Id FROM Clinical_Trial_Profile__c 
             WHERE Bell_Notification_Reminder__c = null
            ]
        );
    }

    global void execute(Database.BatchableContext bc, List<Clinical_Trial_Profile__c> scope) {
        List<Clinical_Trial_Profile__c> ctpToUpdate = new List<Clinical_Trial_Profile__c>();
        for (Clinical_Trial_Profile__c c : scope){
            c.Bell_Notification_Reminder__c = 5;
            ctpToUpdate.add(c);
        }
        TriggerHandlerExecutor.bypassHandler(
            CTPNotificationTriggerHandler.CreateNotificationHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(ClinicalTrialProfileTriggerHandler.UpdateClinicalTrialProfile.class);
        TriggerHandlerExecutor.bypassHandler(ClinicalTrialProfileTriggerHandler.manageBypassedFieldsForTMDH.class);
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.PrepareAdditionalFieldsHandler.class);
        TriggerHandlerExecutor.bypassHandler(
        StudySiteTriggerHandler.DeleteStatusHistoryOnDeleteHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.CreatePIOrSendNotificationHandler.class);
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.SwitchContactUserModeHandler.class);
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.CreateStatusHistoryHandler.class);
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.CreateHCPEnrollmentsForRPInWhiteListHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.SetSuppressEmailsFieldAccordingToStudy.class
        );
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.AssignCommunityPermissionsForUser.class);
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.SetEnableCCSupportFieldAccordingToStudy.class
        );
        if(!ctpToUpdate.isEmpty()){
            Database.update(ctpToUpdate,false);
        }
 
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('CTP Bell_Notification_Reminder__c update complete: ');
    }
}