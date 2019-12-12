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
        if (orgWideEmailAddressId != null) newEmail.setOrgWideEmailAddressId(orgWideEmailAddressId);
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
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        List<Send_Result__c> sendResults = new List<Send_Result__c>();
        for (Notification__c n : notifications) {
            Notification_Target__mdt emailTarget = NotificationService.getNotificationTarget(n.Notification_Type__c, NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL);
            Notification_Type__mdt emailType = NotificationService.getNotificationType(n.Notification_Type__c);
            emailMessages.add(createEmail(getEmailTemplateId(emailTarget.Email_Template__c), n.Recipient__c, n.WhatId__c, emailType.Org_Wide_Email_Address__c));
            sendResults.add(new Send_Result__c(
                    Target_Type__c = NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
                    Notification__c = n.Id
            ));
        }
        List<Messaging.SendEmailResult> resultList = Messaging.sendEmail(emailMessages, false);
        for(Integer i=0; i<resultList.size();i++) {
            if (!resultList[i].success) {
                sendResults[i].Status__c = NotificationService.STATUS_FAILED;
                sendResults[i].Error__c = JSON.serializePretty(resultList[i].errors);
            } else {
                sendResults[i].Status__c = NotificationService.STATUS_SENT;
            }
        }

        insert sendResults;
    }

    public static void sendEmail(String emailTemplate, Id recipientId, Id whatId){
        String orgWideEmAddress = getOrgWideEmailAddressByContactId(recipientId);
        Messaging.SingleEmailMessage sem = createEmail(getEmailTemplateId(emailTemplate), recipientId, whatId, orgWideEmAddress);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{sem}, false);
    }

    public static Messaging.SingleEmailMessage createEmail(Id emailTemplateId, Id contactId, Id whatId, String orgWideEmAddress) {
        return createEmail(emailTemplateId, contactId, whatId, null, orgWideEmAddress);
    }




}