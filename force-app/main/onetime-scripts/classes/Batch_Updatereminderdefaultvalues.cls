global without sharing class Batch_Updatereminderdefaultvalues implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query  = 'Select id,First_Reminder__c,Second_Reminder__c from Study_Site__c where Second_Reminder__c = null or First_Reminder__c = null';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Sobject> records){
        List<Study_Site__c> lst_Studysite = (List<Study_Site__c>)records;
        List<Study_Site__c> toupdatestudysite = new List<Study_Site__c>();
        for(Study_Site__c ss:lst_Studysite){
            Study_Site__c sstoupdate = new Study_Site__c();
            sstoupdate.Id = ss.Id;
            if(ss.Second_Reminder__c == null){
                sstoupdate.Second_Reminder__c = 1;
            }
            if(ss.First_Reminder__c == null){
                sstoupdate.First_Reminder__c = 24;
            } 
            toupdatestudysite.add(sstoupdate);
        }
        if(!toupdatestudysite.isEmpty()){
            TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.PrepareAdditionalFieldsHandler.class);
            TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.CreatePIOrSendNotificationHandler.class);
            TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.SwitchContactUserModeHandler.class);
            TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.CreateStatusHistoryHandler.class);
            TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.CreateHCPEnrollmentsForRPInWhiteListHandler.class);
            TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.SetSuppressEmailsFieldAccordingToStudy.class);
            TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.AssignCommunityPermissionsForUser.class);
            TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.SetEnableCCSupportFieldAccordingToStudy.class );
            TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.DeleteStatusHistoryOnDeleteHandler.class);
            update toupdatestudysite;
        }
        
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}