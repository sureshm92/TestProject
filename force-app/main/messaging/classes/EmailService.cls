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
        for (Notification__c n : notifications) {
            Notification_Target__mdt emailTarget = NotificationService.getNotificationTarget(n.Notification_Type__c, NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL);
            emailMessages.add(createEmail(getEmailTemplateId(emailTarget.Email_Template__c), n.Recipient__c, n.WhatId__c, emailTarget.Org_Wide_Email_Address__c));
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
    }

    public static void sendEmail(String emailTemplate, Id recipientId, Id whatId){
        Messaging.SingleEmailMessage sem = createEmail(getEmailTemplateId(emailTemplate), recipientId, whatId, null);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{sem}, false);
    }

    public static Messaging.SingleEmailMessage createEmail(Id emailTemplateId, Id contactId, Id whatId, String orgWideEmAddress) {
        return createEmail(emailTemplateId, contactId, whatId, null, orgWideEmAddress);
    }

    public static void sendExternalEmail(List<Notification__c> notifications) {
        for (Notification__c n : notifications) {
            Notification_Target__mdt emailTarget = NotificationService.getNotificationTarget(n.Notification_Type__c, NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL);
            sendShareEmail(n.WhatId__c, n.From__c, n.Email__c, emailTarget.Email_Template__c);
        }
    }

    public static void sendShareEmail(Id whatId, Id fromId,  String emailAddr, String templateName) {
        Id shareStudyEmailTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName =:templateName LIMIT 1].Id;
        List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setTemplateId(shareStudyEmailTemplateId);
        msg.setWhatId(whatId);
        msg.setTargetObjectId(fromId);
        msg.setToAddresses(new List<String>{
                emailAddr
        });
        msgList.add(msg);
        // Send the emails in a transaction, then roll it back
        Savepoint sp = Database.setSavepoint();
        Messaging.sendEmail(msgList); // Dummy email send
        Database.rollback(sp); // Email will not send as it is rolled Back
        // Send Actual email
        List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();
        for (Messaging.SingleEmailMessage email : msgList) {
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setToAddresses(email.getToAddresses());
            emailToSend.setPlainTextBody(email.getPlainTextBody());
            emailToSend.setHtmlBody(email.getHtmlBody());
            emailToSend.setSubject(email.getSubject());
            emailToSend.setOrgWideEmailAddressId(getOrgWideEmailAddressByContactId(fromId));
            msgListToBeSend.add(emailToSend);
        }
        Messaging.sendEmail(msgListToBeSend);
    }





}