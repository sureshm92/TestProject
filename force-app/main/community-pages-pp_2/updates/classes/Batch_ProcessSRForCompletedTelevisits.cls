public with sharing class Batch_ProcessSRForCompletedTelevisits implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> scheduledAndRescheduled = new List<String>{
            NotificationCatalog.UPDATE_TO_PT_TELEVISIT_SCHEDULED,
            NotificationCatalog.UPDATE_TO_PT_TELEVISIT_RESCHEDULED
        };
        return Database.getQueryLocator(
            [
                SELECT
                    Id,
                    Notification__c,
                    Notification__r.Target_Record_Ids__c,
                    Notification__r.whatId__c
                FROM Send_Result__c
                WHERE
                    Notification__r.Target_Record_Ids__c != NULL
                    AND Target_Type__c = :UpdateService.SR_TARGET_TYPE_UPDATES
                    AND Status__c = :UpdateService.SR_STATUS_IN_PROGRESS
                    AND Notification__r.Notification_Type__c IN :scheduledAndRescheduled
            ]
        );
    }

    public Batch_ProcessSRForCompletedTelevisits() {
    }

    public void execute(Database.BatchableContext bc, List<Send_Result__c> sendResults) {
        List<Notification__c> updateNotificationsToComplete = new List<Notification__c>();
        List<Id> allTelevisitIdsInNotifications = new List<Id>();
        for (Send_Result__c sr : sendResults) {
            allTelevisitIdsInNotifications.addAll(
                sr.Notification__r.Target_Record_Ids__c.split(',')
            );
        }
        Map<Id, Televisit__c> televisitIdsAndDetails = new Map<Id, Televisit__c>(
            [
                SELECT Id
                FROM Televisit__c
                WHERE
                    Status__c IN ('Completed', 'Cancelled')
                    AND Id IN :allTelevisitIdsInNotifications
            ]
        );
        Set<Id> allTelevisitIds = televisitIdsAndDetails.keySet();
        for (Send_Result__c sr : sendResults) {
            List<Id> televisitIds = (List<Id>) sr.Notification__r.Target_Record_Ids__c.split(',');
            if (alltelevisitIds.containsAll(televisitIds)) {
                sr.Status__c = 'Sent';
                updateNotificationsToComplete.add(
                    new Notification__c(
                        Id = sr.Notification__c,
                        Status__c = NotificationService.NOTIFICATION_STATUS_PROCESSED
                    )
                );
            }
        }
        if (!sendResults.isEmpty()) {
            Database.update(sendResults, false);
        }
        if (!updateNotificationsToComplete.isEmpty()) {
            Database.update(updateNotificationsToComplete, false);
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}
