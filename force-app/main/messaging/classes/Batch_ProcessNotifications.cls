/**
 * Created by Leonid Bartenev
 */

public without sharing class Batch_ProcessNotifications extends Batch_ScheduledAbstract implements Database.AllowsCallouts{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
                SELECT Id,
                        Status__c,
                        WhatId__c, Recipient__c,
                        Notification_Type__c
                FROM Notification__c
                WHERE Status__c =: NotificationService.NOTIFICATION_STATUS_PENDING
        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<Notification__c> notifications) {
        NotificationService.sendNotifications(notifications);
    }
    
    public override Type getType() {
        return Batch_ProcessNotifications.class;
    }
    
    public override virtual String getBatchDescription() {
        return 'Send all pending notifications to recipients';
    }

}