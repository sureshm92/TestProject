/**
 * Created by Olga Skrynnikova on 11/28/2019.
 */

public without sharing class EmailService {
    public class SendEmailTemplateException extends Exception {
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

    public static Messaging.SingleEmailMessage createEmail(String templateDeveloperName, Id contactId, Id whatId) {
        return createEmail(getEmailTemplateId(templateDeveloperName), contactId, whatId);
    }

    public static void sendEmailMessages(Map<Notification__c, Messaging.SingleEmailMessage> emailByNotificationMap) {
        List<Messaging.SendEmailResult> resultList = Messaging.sendEmail(emailByNotificationMap.values(), false);
        Set<Notification__c> notificationSet = emailByNotificationMap.keySet();
        List<Notification__c> notificationList = new List<Notification__c>(notificationSet);
        for (Integer i = 0; i < notificationList.size(); i++) {
            if (resultList[i].success) {
                notificationList[i].Email_Status__c = NotificationService.EMAIL_STATUS_SENT;
            } else {
                notificationList[i].Email_Status__c = NotificationService.EMAIL_STATUS_FAILED;
            }
        }
        update notificationList;
    }
}