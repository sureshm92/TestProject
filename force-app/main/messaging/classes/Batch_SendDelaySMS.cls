/**
 * Created by Olga Skrynnikova on 12/18/2019.
 */

public with sharing class Batch_SendDelaySMS extends Batch_ScheduledAbstract implements Database.AllowsCallouts{
    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT
                        Id, Time_Delay_Status__c,
                        WhatId__c, Recipient__c,
                        Notification_Type__c
                FROM Notification__c
                WHERE Time_Delay_Status__c = 'Pending'
        ]);
    }

    public void execute(Database.BatchableContext param1, List<Notification__c> notifications) {
        SMSService.send(notifications);
        for(Notification__c n: notifications) n.Time_Delay_Status__c = NotificationService.DELAY_STATUS_COMPLETE;
        update notifications;
    }

    public override Type getType() {
        return Batch_SendDelaySMS.class;
    }

}