/**
 * Created by Olga Skrynnikova on 11/19/2019.
 */

public without sharing class NotificationTriggerHandler {

    // Handlers: -------------------------------------------------------------------------------------------------------

    public class CheckFieldsHandler extends TriggerHandler {

        public override void beforeInsert(List<SObject> newList) {
            checkFieldsForNotification(newList);
        }

        public override void afterInsert(List<SObject> newList) {
            sendNotificationToRecipient(newList);
        }
    }

    // Logic: ----------------------------------------------------------------------------------------------------------

    private static void checkFieldsForNotification(List<Notification__c> newList) {
        for (Notification__c n : newList) {
            if (NotificationService.getNotificationType(n.Notification_Type__c) == null) {
                n.addError('Wrong type of Notification ' + n.Notification_Type__c);
            }
        }
    }

    @TestVisible
    private static void sendNotificationToRecipient(List<Notification__c> newList) {
        List<Notification__c> notificationsForMassEmail = new List<Notification__c>();
        List<Notification__c> nonTopicNotifications = new List<Notification__c>();
        List<Id> whatIds = new List<Id>();

        for (Notification__c n : newList) {
            whatIds.add(n.WhatId__c);
            if (n.Recipient__c == null && n.Topic__c != null) {
                notificationsForMassEmail.add(n);
            }else {
                nonTopicNotifications.add(n);
            }
        }

        NotificationAvailabilityService availabilityService = new NotificationAvailabilityService(whatIds);
        List<Notification__c> emailNotifications = new List<Notification__c>();
        List<Notification__c> smsNotificationsAsync = new List<Notification__c>();
        List<Notification__c> smsNotificationsSync = new List<Notification__c>();
        List<Notification__c> pushNotifications = new List<Notification__c>();
        List<Send_Result__c> sendResults = new List<Send_Result__c>();

        for (Notification__c n : nonTopicNotifications) {
            Notification_Type__mdt notificationType = NotificationService.getNotificationType(n.Notification_Type__c);
            for(Notification_Target__mdt nt: notificationType.Notification_Targets__r){
//
                    if (nt.Target_Type__c == NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL) {
                        if (availabilityService.isAvailable(n.WhatId__c, notificationType.Recipient_Type__c, nt.Target_Type__c, n.Recipient__c)) {
                            emailNotifications.add(n);
                        }else{
                            sendResults.add(new Send_Result__c(
                                    Notification__c = n.Id,
                                    Target_Type__c = nt.Target_Type__c,
                                    Status__c = NotificationService.STATUS_SKIPPED));
                        }
                    } else if (nt.Target_Type__c == NotificationService.NOTIFICATION_TARGET_TYPE_SMS) {
                        if (availabilityService.isAvailableForSMS(n.Recipient__c)) {
                            if(n.Time_Delay_Status__c == NotificationService.DELAY_STATUS_CREATED) smsNotificationsAsync.add(n);
                            if(n.Time_Delay_Status__c == NotificationService.DELAY_STATUS_PENDING) smsNotificationsSync.add(n);
                        }else{
                            sendResults.add(new Send_Result__c(
                                    Notification__c = n.Id,
                                    Target_Type__c = nt.Target_Type__c,
                                    Status__c = NotificationService.STATUS_SKIPPED));
                        }
                    } else if (nt.Target_Type__c == NotificationService.NOTIFICATION_TARGET_TYPE_PUSH) {
                        pushNotifications.add(n);
                    }
            }

        }
        insert sendResults;
        EmailService.send(emailNotifications);

        SMSService.sendAsync(smsNotificationsAsync);
        //SMSService.send(smsNotificationsSync);

        if (notificationsForMassEmail.size() > 0) {
            for (Notification__c n : notificationsForMassEmail) {
                Database.executeBatch(new Batch_MassEmailPatient(n));
            }
        }
    }
}
