/**
 * Created by Olga Skrynnikova on 11/28/2019.
 */

public without sharing class EmailService {
    public class SendEmailTemplateException extends Exception {
    }

    private static final Map<String, Id> templateNameIdMap = new Map<String, Id>();
    private static final Map<String, Id> orgWideEmailAddressesMap = new Map<String, Id>();

    static {
        List<OrgWideEmailAddress> listAddresses = [
                SELECT Id, DisplayName
                FROM OrgWideEmailAddress
        ];
        for (OrgWideEmailAddress address : listAddresses) {
            orgWideEmailAddressesMap.put(address.DisplayName, address.Id);
        }
        List<EmailTemplate> templates = [
                SELECT Id, DeveloperName
                FROM EmailTemplate
        ];
        for (EmailTemplate temp : templates) {
            templateNameIdMap.put(temp.DeveloperName, temp.Id);
        }
    }

    public static Id getEmailTemplateId(String templateName) {
        if (templateName != null) return templateNameIdMap.get(templateName);
        return null;
    }

    public static Id getOrgWideEmailAddressId(String orgWideEmailAddress) {
        if (orgWideEmailAddress != null) return orgWideEmailAddressesMap.get(orgWideEmailAddress);
        return null;
    }

    public static Messaging.SingleEmailMessage createEmail(Id emailTemplateId, Id recipientId, Id whatId, List<String> ccAddresses, String orgWideEmAddress) {
        Messaging.SingleEmailMessage newEmail = new Messaging.SingleEmailMessage();
        newEmail.setTemplateId(emailTemplateId);
        newEmail.setTargetObjectId(recipientId);
        newEmail.setSaveAsActivity(false);
        newEmail.setWhatId(whatId);
        Id orgWideEmailAddressId = getOrgWideEmailAddressId(orgWideEmAddress);
        if (orgWideEmailAddressId != null) newEmail.setOrgWideEmailAddressId(orgWideEmailAddressId);
        if (ccAddresses != null) newEmail.setCcAddresses(ccAddresses);
        return newEmail;
    }

    public static void send(List<Notification__c> notifications) {
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        for (Notification__c n : notifications) {
            Notification_Target__mdt currentTarget = NotificationService.getTargetByNotification(n.Notification_Type__c, NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL);
            emailMessages.add(createEmail(getEmailTemplateId(currentTarget.Email_Template__c), n.Recipient__c, n.WhatId__c));
        }
        List<Messaging.SendEmailResult> resultList = Messaging.sendEmail(emailMessages, false);
        List<Notification__c> notificationList = new List<Notification__c>(notifications);
        for (Integer i = 0; i < notificationList.size(); i++) {
            if (!resultList[i].success) {
                notificationList[i].Email_Status__c = NotificationService.EMAIL_STATUS_FAILED;
            }
        }
    }
    public static Messaging.SingleEmailMessage createEmail(String templateDeveloperName, Id contactId, Id whatId) {
        return createEmail(getEmailTemplateId(templateDeveloperName), contactId, whatId);
    }


}