/**
 * Created by Olga Skrynnikova on 11/28/2019.
 */

public without sharing class EmailService {
    public class SendEmailTemplateException extends Exception {
    }

    public static final String COMMUNITY_ORG_WIDE_ADDRESS_REFERRAL = 'IQVIA Referral Hub';
    public static final String COMMUNITY_ORG_WIDE_ADDRESS_PATIENT = 'IQVIA Patient Portal';

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
        if (orgWideEmailAddressId != null && !SystemService.isScratchOrg()) newEmail.setOrgWideEmailAddressId(orgWideEmailAddressId);
        if (ccAddresses != null) newEmail.setCcAddresses(ccAddresses);
        return newEmail;
    }

    public static String getOrgWideEmailAddressByContactId(Id contactId) {
        String userMode = CommunityService.getContactUserMode(contactId);
        if (userMode != null && userMode.equalsIgnoreCase(CommunityService.USER_MODE_PARTICIPANT)) {
            return COMMUNITY_ORG_WIDE_ADDRESS_PATIENT;
        } else {
            return COMMUNITY_ORG_WIDE_ADDRESS_REFERRAL;
        }
    }

    public static void send(List<Notification__c> notifications) {
        NotificationResultService sendResultService = new NotificationResultService(notifications);
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        List<Notification__c> notificationShareEmail = new List<Notification__c>();
        for (Notification__c n : notifications) {
            if (n.Email__c != null && n.Recipient__c == null) {
                notificationShareEmail.add(n);
            } else {
                Notification_Target__mdt emailTarget = NotificationService.getNotificationTarget(n.Notification_Type__c, NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL);
                emailMessages.add(createEmail(getEmailTemplateId(emailTarget.Email_Template__c), n.Recipient__c, n.WhatId__c, emailTarget.Org_Wide_Email_Address__c));
            }
        }
        List<Messaging.SendEmailResult> resultList = Messaging.sendEmail(emailMessages, false);
        for(Integer i = 0; i < resultList.size(); i++) {
            if (!resultList[i].success) {
                sendResultService.setFailed(notifications[i].Id, NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL, JSON.serializePretty(resultList[i].errors));
            } else {
                sendResultService.setSent(notifications[i].Id, NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL);
            }
        }
        sendResultService.updateResults();
        if (!notificationShareEmail.isEmpty()) EmailService.sendEmailToExternalUser(notificationShareEmail);
    }

    public static void sendEmail(String emailTemplate, Id recipientId, Id whatId){
        Messaging.SingleEmailMessage sem = createEmail(getEmailTemplateId(emailTemplate), recipientId, whatId, null);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{sem}, false);
    }

    public static Messaging.SingleEmailMessage createEmail(Id emailTemplateId, Id contactId, Id whatId, String orgWideEmAddress) {
        return createEmail(emailTemplateId, contactId, whatId, null, orgWideEmAddress);
    }

    public static void sendEmailToExternalUser(List<Notification__c> notifications) {
        Messaging.SingleEmailMessage msg;
        List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();
        Map<Messaging.SingleEmailMessage, Id> fromIdbyMsgMap = new Map<Messaging.SingleEmailMessage, Id>();
        for (Notification__c n : notifications) {
            Notification_Target__mdt emailTarget = NotificationService.getNotificationTarget(n.Notification_Type__c, NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL);
            msg = createMessage(n.WhatId__c, n.From__c, n.Email__c, emailTarget.Email_Template__c);
            msgListToBeSend.add(msg);
        }
        Messaging.sendEmail(msgListToBeSend);
    }

    public static Messaging.SingleEmailMessage createMessage(Id whatId, Id fromId,  String emailAddr, String templateName) {
        EmailTemplate shareStudyEmailTemplate = [SELECT Id, Subject, Body  FROM EmailTemplate WHERE DeveloperName =:templateName LIMIT 1];
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setTemplateId(shareStudyEmailTemplate.Id);
        msg.setWhatId(whatId);
        msg.setTargetObjectId(fromId);
        msg.setToAddresses(new List<String>{
                emailAddr
        });
        msg.setSaveAsActivity(false);
        msg.setSubject(shareStudyEmailTemplate.subject);
        msg.setPlainTextBody(shareStudyEmailTemplate.body);
        msg.setHtmlBody(shareStudyEmailTemplate.body);
        return msg;
    }
}