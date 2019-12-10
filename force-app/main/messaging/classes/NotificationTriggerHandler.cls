/**
 * Created by Olga Skrynnikova on 11/19/2019.
 */

public without sharing class NotificationTriggerHandler {

    // Handlers: -------------------------------------------------------------------------------------------------------

    public class CheckFieldsHandler extends TriggerHandler {

        public override void beforeInsert(List<SObject> newList) {
            checkFieldsForNotification(newList);
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
        System.debug('BEFORE AND AFTER BATCH <<<<< ' + JSON.serializePretty(newList));
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
        List<Notification__c> smsNotifications = new List<Notification__c>();
        List<Notification__c> pushNotifications = new List<Notification__c>();
        for (Notification__c n : nonTopicNotifications) {
            Notification_Type__mdt notificationType = NotificationService.getNotificationType(n.Notification_Type__c);
            Boolean isAllSkipped = true;
            for(Notification_Target__mdt nt: notificationType.Notification_Targets__r){
                if (availabilityService.isAvailable(n.WhatId__c, notificationType.Recipient_Type__c, nt.Target_Type__c)) {
                    isAllSkipped = false;
                    if (nt.Target_Type__c == NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL) {
                        emailNotifications.add(n);
                    } else if (nt.Target_Type__c == NotificationService.NOTIFICATION_TARGET_TYPE_SMS) {
                        smsNotifications.add(n);
                    } else if (nt.Target_Type__c == NotificationService.NOTIFICATION_TARGET_TYPE_PUSH) {
                        pushNotifications.add(n);
                    }
                }
            }
            if(isAllSkipped) {
                n.Email_Status__c = NotificationService.EMAIL_STATUS_SKIPPED;
            } else {
                n.Email_Status__c = NotificationService.EMAIL_STATUS_SENT;
            }
        }

        EmailService.send(emailNotifications);
        SMSService.send(smsNotifications);
        if (notificationsForMassEmail.size() > 0) {
            for (Notification__c n : notificationsForMassEmail) {
                Database.executeBatch(new Batch_MassEmailPatient(n));
            }
        }
    }


}