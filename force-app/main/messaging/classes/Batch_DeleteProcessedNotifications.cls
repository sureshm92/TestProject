/**
 * Created by Leonid Bartenev
 */ 

public without sharing class Batch_DeleteProcessedNotifications extends Batch_ScheduledAbstract {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime removeDT = Datetime.now();
        return Database.getQueryLocator(
            [
                SELECT
                    Id,
                    Status__c,
                    WhatId__c,
                    Recipient__c,
                    Notification_Type__c,
                    (SELECT Id, Status__c FROM Send_Results__r)
                FROM Notification__c
                WHERE
                    Status__c = :NotificationService.NOTIFICATION_STATUS_PROCESSED
                    AND LastModifiedDate <= :removeDT
            ]
        );
    }

    public void execute(Database.BatchableContext bc, List<Notification__c> notifications) {
        List<Notification__c> notificationToDelete = new List<Notification__c>();
        for (Notification__c notification : notifications) {
            Boolean isFailedResultFound = false;
            if (notification.Send_Results__r != null) {
                for (Send_Result__c sendResult : notification.Send_Results__r) {
                    if (sendResult.Status__c == 'Failed') {
                        isFailedResultFound = true;
                        break;
                    }
                }
            }
            if (!isFailedResultFound)
                notificationToDelete.add(notification);
        }
        delete notificationToDelete;
    }

    public override Type getType() {
        return Batch_DeleteProcessedNotifications.class;
    }

    public override virtual String getBatchDescription() {
        return 'Delete all processed notifications without failed send result';
    }

    public override String getRecommendedIntervalMode() {
        return Batch_ScheduledAbstract.INTERVAL_DAYS;
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 1;
    }
}
