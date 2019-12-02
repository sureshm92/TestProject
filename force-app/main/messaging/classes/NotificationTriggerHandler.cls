/**
 * Created by Olga Skrynnikova on 11/19/2019.
 */

public without sharing class NotificationTriggerHandler {

    // Handlers: -------------------------------------------------------------------------------------------------------

    public class CheckFieldsHandler extends TriggerHandler {

        public override void beforeInsert(List<SObject> newList) {
            checkFieldsForNotification(newList);
        }
    }

    public class SendNotificationHandler extends TriggerHandler {

        public override void afterInsert(List<SObject> newList) {
            sendNotificationToRecipient(newList);
        }
    }

    // Logic: ----------------------------------------------------------------------------------------------------------

    private static void checkFieldsForNotification(List<Notification__c> newList) {
        List<Notification_Type__mdt> notificationTypeList = [
                SELECT Id,
                        DeveloperName
                FROM Notification_Type__mdt
        ];

        Set<String> notificationSet = new Set<String>();
        for (Notification_Type__mdt nt : notificationTypeList) notificationSet.add(nt.DeveloperName);
        List<Notification__c> availableList = new List<Notification__c>();

        for (Notification__c n : newList) {
            if (notificationSet.contains(n.Notification_Type__c)) {
                availableList.add(n);
            } else {
                n.addError('Wrong type of Notification ' + n.Notification_Type__c);
            }
        }
    }

    @TestVisible
    private static void sendNotificationToRecipient(List<Notification__c> newList) {
        List<Notification__c> cloneList = [
                SELECT Id, Email_Status__c, WhatId__c, Notification_Type__c, Recipient__c
                FROM Notification__c
                WHERE Id IN :newList
        ];
        List<String> notificationTypes = new List<String>();
        List<String> whatIds = new List<String>();
        for (Notification__c n : cloneList) {
            notificationTypes.add(n.Notification_Type__c);
            whatIds.add(n.WhatId__c);
        }

        List<Notification_Type__mdt> notificationTypesAndTargets = [
                SELECT Id, DeveloperName, Recipient_Type__c, (
                        SELECT Id, Target_Type__c, Message_Body__c, Email_Template__c
                        FROM Notification_Targets__r
                )
                FROM Notification_Type__mdt
                WHERE DeveloperName IN:notificationTypes
        ];

        Map<String, String> notificationByRecipientMap = new Map<String, String>();

        for (Notification_Type__mdt nt : notificationTypesAndTargets) {
            notificationByRecipientMap.put(nt.DeveloperName, nt.Recipient_Type__c);
        }
        List<Notification__c> notificationAvailableList = new List<Notification__c>();
        List<Notification__c> notificationNotAvailableList = new List<Notification__c>();

        NotificationAvailabilityService availabilityService = new NotificationAvailabilityService(whatIds);

        for (Notification__c n : cloneList) {
            if (availabilityService.isAvailable(n.WhatId__c, notificationByRecipientMap.get(n.Notification_Type__c))) {
                notificationAvailableList.add(n);
            } else {
                n.Email_Status__c = NotificationService.EMAIL_STATUS_SKIPPED;
                notificationNotAvailableList.add(n);
            }
        }

        if (!notificationNotAvailableList.isEmpty()) update notificationNotAvailableList;

        Map<String, List<Notification_Target__mdt>> notificationTargetMap = new Map<String, List<Notification_Target__mdt>>();
        for (Notification_Type__mdt ntr : notificationTypesAndTargets) {
            notificationTargetMap.put(ntr.DeveloperName, ntr.Notification_Targets__r);
        }

        Map<Notification__c, Messaging.SingleEmailMessage> emailByNotificationMap =
                new Map<Notification__c, Messaging.SingleEmailMessage>();
        for (Notification__c n : notificationAvailableList) {
            List<Notification_Target__mdt> ntrList = notificationTargetMap.get(n.Notification_Type__c);
            for (Notification_Target__mdt ntr : ntrList)
                if (ntr.Target_Type__c == 'Email') {
                    emailByNotificationMap.put(n,
                            SendEmailTemplate.createEmail(ntr.Email_Template__c, n.Recipient__c, n.WhatId__c));
                } else if (ntr.Target_Type__c == 'SMS') {
                    //TODO for SMS
                } else if (ntr.Target_Type__c == 'Push') {
                    //TODO for Push
                }
        }

        if (emailByNotificationMap.size() > 0) {
            EmailService.sendEmailMessages(emailByNotificationMap);
        }

    }
}