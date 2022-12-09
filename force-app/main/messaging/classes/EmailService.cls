/**
 * Created by Olga Skrynnikova on 11/28/2019.
 */

public without sharing class EmailService {
    public class SendEmailTemplateException extends Exception {
    }

    public static final String COMMUNITY_ORG_WIDE_ADDRESS_REFERRAL = 'IQVIA Referral Hub';
    public static final String COMMUNITY_ORG_WIDE_ADDRESS_PATIENT = 'IQVIA Patient Portal';
    public static final String COMMUNITY_ORG_WIDE_ADDRESS_GSK_PATIENT = 'Gather Share Know Participant Hub';
    public static final String COMMUNITY_ORG_WIDE_ADDRESS_ST_SPECIFIC = 'Study Specific';

    private static final Map<String, Id> templateNameIdMap = new Map<String, Id>();
    private static final Map<String, Id> orgWideEmailAddressesMap = new Map<String, Id>();

    static {
        List<OrgWideEmailAddress> listAddresses = [SELECT Id, DisplayName FROM OrgWideEmailAddress];
        for (OrgWideEmailAddress address : listAddresses) {
            orgWideEmailAddressesMap.put(address.DisplayName, address.Id);
        }
        List<EmailTemplate> templates = [SELECT Id, DeveloperName FROM EmailTemplate];
        for (EmailTemplate temp : templates) {
            templateNameIdMap.put(temp.DeveloperName, temp.Id);
        }
    }

    public static Id getEmailTemplateId(String templateName) {
        if (templateName != null)
            return templateNameIdMap.get(templateName);
        return null;
    }

    public static Id getOrgWideEmailAddressId(String orgWideEmailAddress) {
        if (orgWideEmailAddress != null)
            return orgWideEmailAddressesMap.get(orgWideEmailAddress);
        return null;
    }

    public static Messaging.SingleEmailMessage createEmail(
        Id emailTemplateId,
        Id recipientId,
        Id whatId,
        List<String> ccAddresses,
        String orgWideEmAddress
    ) {
        Messaging.SingleEmailMessage newEmail = new Messaging.SingleEmailMessage();
        newEmail.setTemplateId(emailTemplateId);
        newEmail.setTargetObjectId(recipientId);
        newEmail.setSaveAsActivity(false);
        newEmail.setWhatId(whatId);
        Id orgWideEmailAddressId = getOrgWideEmailAddressId(orgWideEmAddress);
        if (orgWideEmailAddressId != null && !SystemService.isScratchOrg())
            newEmail.setOrgWideEmailAddressId(orgWideEmailAddressId);
        if (ccAddresses != null)
            newEmail.setCcAddresses(ccAddresses);
        return newEmail;
    }

    public static void send(
        List<Notification__c> notifications,
        Map<Id, String> orgWideEmailByNotifyMap,
        NotificationAvailabilityService availabilityService
    ) {
        NotificationResultService sendResultService = new NotificationResultService(notifications);
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        List<Notification__c> notificationShareEmail = new List<Notification__c>();
        for (Notification__c n : notifications) {
            if (n.Email__c != null && n.Recipient__c == null) {
                notificationShareEmail.add(n);
            } else {
                Notification_Target__mdt emailTarget = NotificationService.getNotificationTarget(
                    n.Notification_Type__c,
                    NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL
                );
                String emailTemplate = n.IsDelegate__c
                    ? emailTarget.Email_Template_Delegate__c
                    : emailTarget.Email_Template__c;
                emailTemplate = availabilityService.isUpdatedPPTemplate(
                        n.WhatId__c,
                        n.Recipient__c
                    ) == true
                    ? emailTemplate + '_PP'
                    : emailTemplate;
                emailMessages.add(
                    createEmail(
                        getEmailTemplateId(emailTemplate),
                        n.Recipient__c,
                        n.WhatId__c,
                        orgWideEmailByNotifyMap.get(n.Id)
                    )
                );
            }
        }
        List<Messaging.SendEmailResult> resultList = Messaging.sendEmail(emailMessages, false);
        if (!notificationShareEmail.isEmpty())
            resultList.addAll(
                EmailService.sendEmailToExternalUser(
                    notificationShareEmail,
                    orgWideEmailByNotifyMap
                )
            );

        for (Integer i = 0; i < resultList.size(); i++) {
            if (!resultList[i].success) {
                sendResultService.setFailed(
                    notifications[i].Id,
                    NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
                    JSON.serializePretty(resultList[i].errors)
                );
            } else {
                sendResultService.setSent(
                    notifications[i].Id,
                    NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL
                );
            }
        }
        sendResultService.updateResults();
    }

    public static void sendEmail(String emailTemplate, Id recipientId, Id whatId) {
        Messaging.SingleEmailMessage sem = createEmail(
            getEmailTemplateId(emailTemplate),
            recipientId,
            whatId,
            null
        );
        System.debug('>>' + JSON.serializePretty(sem));
        for (
            Messaging.SendEmailResult result : Messaging.sendEmail(
                new List<Messaging.SingleEmailMessage>{ sem },
                false
            )
        ) {
            if (result.success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' + JSON.serializePretty(result.errors));
            }
        }
    }

    public static Messaging.SingleEmailMessage createEmail(
        Id emailTemplateId,
        Id contactId,
        Id whatId,
        String orgWideEmAddress
    ) {
        return createEmail(emailTemplateId, contactId, whatId, null, orgWideEmAddress);
    }

    public static List<Messaging.SendEmailResult> sendEmailToExternalUser(
        List<Notification__c> notifications,
        Map<Id, String> orgWideEmailByNotifyMap
    ) {
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();
        for (Notification__c n : notifications) {
            Notification_Target__mdt emailTarget = NotificationService.getNotificationTarget(
                n.Notification_Type__c,
                NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL
            );
            msg = createMessage(
                n.WhatId__c,
                n.From__c,
                n.Email__c,
                emailTarget.Email_Template__c,
                orgWideEmailByNotifyMap.get(n.Id)
            );
            msgListToBeSend.add(msg);
        }
        List<Messaging.SendEmailResult> resultList = Messaging.sendEmail(msgListToBeSend);
        return resultList;
    }

    public static Messaging.SingleEmailMessage createMessage(
        Id whatId,
        Id fromId,
        String emailAddr,
        String templateName,
        String orgWideEmAddress
    ) {
        EmailTemplate shareStudyEmailTemplate = [
            SELECT Id, Subject, Body
            FROM EmailTemplate
            WHERE DeveloperName = :templateName
            LIMIT 1
        ];
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setTemplateId(shareStudyEmailTemplate.Id);
        msg.setWhatId(whatId);
        msg.setTargetObjectId(fromId);
        msg.setToAddresses(new List<String>{ emailAddr });
        msg.setTreatTargetObjectAsRecipient(false);

        msg.setSaveAsActivity(false);
        Id orgWideEmailAddressId = getOrgWideEmailAddressId(orgWideEmAddress);
        if (orgWideEmailAddressId != null && !SystemService.isScratchOrg())
            msg.setOrgWideEmailAddressId(orgWideEmailAddressId);
        return msg;
    }

    public static void sendException(Exception e, String recipientEmail) {
        System.debug('>>Error stack: ' + e.getMessage() + '\n' + e.getStackTraceString());

        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        if (String.isEmpty(recipientEmail))
            recipientEmail = 'pp_rh_dev@yahoo.com';
        emailMessage.setToAddresses(new List<String>{ recipientEmail });
        emailMessage.setSubject('Email Error');
        emailMessage.setPlainTextBody(
            '>>Error stack: ' +
            e.getMessage() +
            '\n' +
            e.getStackTraceString()
        );
        /*Messaging.sendEmail((List<Messaging.Email>) new List<Messaging.SingleEmailMessage>{
                emailMessage
        });*/
    }
}
