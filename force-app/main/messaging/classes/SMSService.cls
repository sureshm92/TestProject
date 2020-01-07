/**
 * Created by Olga Skrynnikova on 12/9/2019.
 */

public with sharing class SMSService {

    public static void send(List<Notification__c> notifications) {
        send(notifications, false);
    }

    public static void sendAsync(List<Notification__c> notifications) {
        send(notifications, true);
    }

    private static void send(List<Notification__c> notifications, Boolean sendAsync) {
        Map<String, String> messageByPhone = new Map<String, String>();
        List <Id> conIds = new List<Id>();
        for (Notification__c n : notifications) conIds.add(n.Recipient__c);
        Map<Id, Contact> contactMap = new Map<Id, Contact>([
                SELECT Id, Phone, Language__c
                FROM Contact
                WHERE Id IN :conIds
        ]);

        for (Notification__c n : notifications) {
            Notification_Target__mdt smsTarget = NotificationService.getNotificationTarget(n.Notification_Type__c, NotificationService.NOTIFICATION_TARGET_TYPE_SMS);
            Notification_Type__mdt messageType = NotificationService.getNotificationType(n.Notification_Type__c);
            Contact recipient = contactMap.get(n.Recipient__c);
            String phoneNumber = recipient.Phone;
            String message = CatalogParametersHelper.prepareLabel(smsTarget.Message_Body__c, n.WhatId__c, messageType.Parameters_Provider__r.DeveloperName, recipient.Language__c);
            if(phoneNumber !=null) messageByPhone.put(phoneNumber, message);

            if (sendAsync && phoneNumber !=null) {
                MCloudSMSSender.sendSMSAsync(new List<String>{
                        phoneNumber
                }, message);
            } else if (phoneNumber !=null){
                MCloudSMSSender mCloudSMSSender = new MCloudSMSSender();
                mCloudSMSSender.sendSMS(new List<String>{
                        phoneNumber
                }, message);
            }
        }

        Action_SendSMS actionSendSMS = new Action_SendSMS(messageByPhone);
        if (sendAsync) {
            ActionExecutor.executeAsync(actionSendSMS);
        } else {
            ActionExecutor.execute(actionSendSMS);
        }
    }
}