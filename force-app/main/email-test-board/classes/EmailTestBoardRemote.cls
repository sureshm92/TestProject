/**
 * Created by Igor Malyuta on 04.05.2020.
 */
public without sharing class EmailTestBoardRemote {

    public class EmailTestBoardRemoteException extends Exception {
    }

    private static final List<String> SKIPPED_EMAILS = new List<String>{
            'Apex_Test_Result_Summary',
            'Build_Task_Status_Notification',
            'Deployment_Result_Summary',
            'New_Delegate_Email',
            'New_Study_Email_HCP',
            'New_Study_Email_Participant',
            'New_Study_Email_PI',
            'Medication_Task_Reminder',
            'Test_Email',
            'Trial_Alert_Match_Delegate',
            'Trial_Alert_Received_Delegate',
            'Visit_Task_Reminder',
            'Visit_task_Reminder_Type_not_selected'
    };

    @AuraEnabled(Cacheable = true)
    public static List<EmailTemplateWrapper> getEmailTemplateWrappers() {
        try {
            List<EmailTemplateWrapper> wrappers = new List<EmailTemplateWrapper>();
            List<EmailTemplate> emailTemplates = [
                    SELECT
                            DeveloperName,
                            Markup,
                            Name
                    FROM EmailTemplate
                    WHERE TemplateType = 'visualforce'
                    AND DeveloperName NOT IN:SKIPPED_EMAILS
            ];
            for (EmailTemplate template : emailTemplates) {
                Integer recipientStart = template.Markup.indexOf('recipientType="') + 15;
                Integer recipientEnd = template.Markup.indexOf('"', recipientStart);
                String recipientType = template.Markup.substring(recipientStart, recipientEnd);

                String relatedToType;
                Integer relatedStart = template.Markup.indexOf('relatedToType="');
                if (relatedStart > 0) {
                    relatedStart += 15;
                    Integer relatedEnd = template.Markup.indexOf('"', relatedStart);
                    relatedToType = template.Markup.substring(relatedStart, relatedEnd);
                }

                wrappers.add(new EmailTemplateWrapper(
                        template.Name,
                        template.DeveloperName,
                        recipientType,
                        relatedToType
                ));
            }

            return wrappers;
        } catch (Exception e) {
            return (List<EmailTemplateWrapper>) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> searchRecipient(String searchTerm) {
        try {
            List<LookupSearchResult> results = new List<LookupSearchResult>();
            if (String.isEmpty(searchTerm)) return results;

            List<Contact> foundContacts = [FIND :searchTerm IN ALL FIELDS RETURNING Contact (Id, Name)].get(0);
            if (foundContacts == null || foundContacts.isEmpty()) return results;

            for (Contact contact : foundContacts) {
                results.add(new LookupSearchResult(
                        contact.Id,
                        'Contact',
                        'standard:avatar',
                        contact.Name,
                        null)
                );
            }
            return results;
        } catch (Exception e) {
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> searchRelated(String objName, String searchTerm) {
        try {
            List<LookupSearchResult> results = new List<LookupSearchResult>();
            if (String.isEmpty(searchTerm)) return results;

            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objName);

            List<SObject> foundObjects = DatabaseService.query(new List<String>{
                    'Id', 'Name'
            }, objType, DatabaseService.fieldLike('Name', searchTerm));
            if (foundObjects == null || foundObjects.isEmpty()) return results;

            String objTypeDescribeName = objType.getDescribe().getName();
            for (SObject obj : foundObjects) {
                results.add(new LookupSearchResult(
                        obj.Id,
                        objTypeDescribeName,
                        'standard:entity',
                        obj.get('Name').toString(),
                        null)
                );
            }
            return results;
        } catch (Exception e) {
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getPreviewHTML(String wrapper, String contactId, String relatedId) {
        try {
            EmailTemplateWrapper templateWrapper = (EmailTemplateWrapper) JSON.deserialize(wrapper, EmailTemplateWrapper.class);

            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            Id shareStudyEmailTemplateId = [
                    SELECT Id FROM EmailTemplate WHERE DeveloperName =:templateWrapper.emailDevName LIMIT 1
            ].Id;
            msg.setTemplateId(shareStudyEmailTemplateId);

            if(String.isNotEmpty(relatedId)) msg.setWhatId(Id.valueOf(relatedId));

            Id recipientId = contactId;
            if (templateWrapper.recipientType.equals('User')) {
                List<User> user = [SELECT Id FROM User WHERE ContactId = :contactId];
                if (user.isEmpty()) throw new EmailTestBoardRemoteException('Can\'t find user with this contact Id!');

                recipientId = user.get(0).Id;
            }
            msg.setSaveAsActivity(false);
            msg.setTargetObjectId(recipientId);
            msg.setToAddresses(new List<String>{
                    'mail123@mail.com'
            });
            List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
            msgList.add(msg);

            Savepoint sp = Database.setSavepoint();
            Messaging.sendEmail(msgList);
            Database.rollback(sp);

            return msgList.get(0).getHtmlBody();
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void sendEmail(String wrapper, String contactId, String relatedId, String sendMethod) {
        try {
            EmailTemplateWrapper templateWrapper = (EmailTemplateWrapper) JSON.deserialize(wrapper, EmailTemplateWrapper.class);
            if (sendMethod.equals('notification')) {
                List<Notification_Target__mdt> notificationTarget = [
                        SELECT Notification_Type__r.DeveloperName
                        FROM Notification_Target__mdt
                        WHERE Email_Template__c = :templateWrapper.emailDevName
                ];
                if (notificationTarget.isEmpty()) {
                    throw new EmailTestBoardRemoteException('Can\'t find notification type for this email template!');
                }

                insert new Notification__c(
                        Recipient__c = contactId,
                        Notification_Type__c = notificationTarget.get(0).Notification_Type__r.DeveloperName,
                        WhatId__c = relatedId
                );
            } else {
                Id recipientId = contactId;
                if (templateWrapper.recipientType.equals('User')) {
                    List<User> user = [SELECT Id FROM User WHERE ContactId = :contactId];
                    if (user.isEmpty()) throw new EmailTestBoardRemoteException('Can\'t find user with this contact Id!');

                    recipientId = user.get(0).Id;
                }

                Id whatId = relatedId;
                if(String.isEmpty(templateWrapper.relatedObjName)) whatId = recipientId;
                EmailService.sendEmail(templateWrapper.emailDevName, recipientId, whatId);
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    public class EmailTemplateWrapper {
        @AuraEnabled public String emailLabel;
        @AuraEnabled public String emailDevName;
        @AuraEnabled public String recipientType;
        @AuraEnabled public String relatedObjName;
        @AuraEnabled public String relatedObjLabel;
        @AuraEnabled public Boolean supportNotification = false;
        @AuraEnabled public Boolean supportSearchByName = false;

        public EmailTemplateWrapper(String emailLabel, String emailDevName, String recipientType, String relatedType) {
            this.emailLabel = emailLabel;
            this.emailDevName = emailDevName;
            this.recipientType = recipientType;

            if(String.isNotEmpty(relatedType)) {
                SObjectType sObjectType = Schema.getGlobalDescribe().get(relatedType);
                relatedObjName = sObjectType.getDescribe().getName();
                relatedObjLabel = sObjectType.getDescribe().getLabel();

                supportNotification = !relatedType.equals('Community');
                supportSearchByName = supportNotification && (!relatedObjLabel.equals('Case') && !relatedObjLabel.equals('Task'));
            }
        }
    }
}