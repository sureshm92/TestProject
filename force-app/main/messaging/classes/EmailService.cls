/**
 * Created by Olga Skrynnikova on 11/28/2019.
 */

public without sharing class EmailService {
    public class SendEmailTemplateException extends Exception {
    }

    public static Messaging.SingleEmailMessage createEmail(String templateDeveloperName, Id contactId, Id whatId) {
        return createEmail(getEmailTemplateId(templateDeveloperName), contactId, whatId);
    }

    public static void send(List<Notification__c> notifications) {
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        for (Notification__c n : notifications) {
            Notification_Target__mdt currentTarget = NotificationService.getNotificationType(n.Notification_Type__c).Notification_Targets__r;
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

    private static final Map<String, Id> templateNameIdMap = new Map<String, Id>();

    private static Id getEmailTemplateId(String templateName) {
        Id templateId = templateNameIdMap.get(templateName);
        if (templateId != null) return templateId;
        List<EmailTemplate> templates = [
                SELECT Id
                FROM EmailTemplate
                WHERE DeveloperName = :templateName
                LIMIT 1
        ];
        if (templates.isEmpty()) throw new SendEmailTemplateException('Email template: "' + templateName + '" not found');
        templateNameIdMap.put(templateName, templates[0].Id);
        return templates[0].Id;
    }

    public static Messaging.SingleEmailMessage createEmail(Id emailTemplateId, Id contactId, Id whatId) {
        return createEmail(emailTemplateId, contactId, whatId, null, false, '');
    }

    public static Messaging.SingleEmailMessage createEmail(Id emailTemplateId, Id contactId, Id whatId, Id studyId, Boolean ccDelegates, String userMode) {
        Messaging.SingleEmailMessage newEmail = new Messaging.SingleEmailMessage();
        newEmail.setTemplateId(emailTemplateId);
        newEmail.setTargetObjectId(contactId);
        newEmail.setSaveAsActivity(false);
        newEmail.setOrgWideEmailAddressId(SendEmailTemplate.getOrgWideEmailId(contactId));

        //newEmail.setToAddresses(new List<String>{toAddress});
        newEmail.setWhatId(whatId);
        if (ccDelegates && userMode == CommunityService.USER_MODE_PI) {
            List<String> delegateAddresses = new List<String>();
            for (Site_Staff__c delegate : [
                    SELECT Id, Site_Contact__r.Email
                    FROM Site_Staff__c
                    WHERE
                    Delegate_Level__c = :DelegateService.DELEGATE_LEVEL_1
                    AND Study_Site__c = :studyId
            ]) {
                delegateAddresses.add(delegate.Site_Contact__r.Email);
            }
            newEmail.setCcAddresses(delegateAddresses);
        } else if (ccDelegates && userMode == CommunityService.USER_MODE_HCP) {
            List<String> delegateAddresses = new List<String>();
            for (Referring_HCP_Staff__c delegate : [
                    SELECT Id, Contact__r.Email
                    FROM Referring_HCP_Staff__c
                    WHERE
                    Delegate_Level__c = :DelegateService.DELEGATE_LEVEL_1
                    AND HCP_Enrollment__r.Study_Site__c = :studyId
            ]) {
                delegateAddresses.add(delegate.Contact__r.Email);
            }
            newEmail.setCcAddresses(delegateAddresses);
        }

        return newEmail;
    }


}