public class Batch_UpdatePendingNotifications implements
    Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
       return Database.getQueryLocator(
            [
                SELECT
                    Id,
                    Status__c,
                    WhatId__c,
                    Recipient__c,
                    Notification_Type__c,
                    Email__c,
                    From__c,
                    IsDelegate__c,
                    RemindUsing__c
                FROM Notification__c
                WHERE Status__c = :NotificationService.NOTIFICATION_STATUS_PENDING and Notification_Type__c IN('Message_to_PT_New_Study_eRP_VT_Type', 'Message_to_PI_SS_Was_Changed_Type','Message_to_PT_Enrollment_Success_Type','Message_to_PT_Ref_Status_Update_Type','Message_to_PT_SS_Was_Changed_Type')

            ]
        );
    }
    public void execute(Database.BatchableContext bc, List<Notification__c> scope){
        List<Notification__c> notificationsTobeUpdated = new List<Notification__c>();
        for (Notification__c n : scope) {
		    n.Status__c = 'Processed';
            notificationsTobeUpdated.add(n);
            }
        update notificationsTobeUpdated;
    }
    public void finish(Database.BatchableContext bc){
        
    }
}