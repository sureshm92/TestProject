public without sharing class SendEmailTemplate {
    //TODO:REF Deprecated-Check and remove
    public static final String EMAIL_TEMPLATE_PATIENT_SOURCE_EPR_NEW = 'Patient0_New_Study';
    public static final String EMAIL_TEMPLATE_PATIENT_SOURCE_PI_NEW = 'Patient1_New_Study';
    public static final String EMAIL_TEMPLATE_PATIENT_SOURCE_HCP_NEW = 'Patient2_New_Study';
    public static final String EMAIL_TEMPLATE_PATIENT_IMPORT = 'PI_Import_Participants_Email';

    public class EmailMessageWrapper {
        public Id recipientId;
        public Id whatId;
        public String emailTemplateName;

        public EmailMessageWrapper(Id recipientId, Id whatId, String emailTemplateName) {
            this.recipientId = recipientId;
            this.whatId = whatId;
            this.emailTemplateName = emailTemplateName;
        }
    }

    public class SendEmailTemplateException extends Exception {
    }

    public static void sendEmailNotification(String templateName, Map<Id, String> whatIdMap) {
        // if (Test.isRunningTest())
        //     return;
        //prepare emails list:
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        Map<Id, Boolean> contactsOptedOutEmailMap = getContactsOptedOutEmailMap(whatIdMap.values());

        for (Id whatId : whatIdMap.keySet()) {
            if (
                contactsOptedOutEmailMap.get(whatIdMap.get(whatId)) != null &&
                !contactsOptedOutEmailMap.get(whatIdMap.get(whatId))
            ) {
                emailMessages.add(
                    createEmail(getEmailTemplateId(templateName), whatIdMap.get(whatId), whatId)
                );
            }
        }

        //send emails:
        sendEmailMessages(emailMessages);
    }

    public static void sendEmailNotification(
        String templateName,
        Map<Id, Set<Id>> contactIdToWhatIdSet
    ) {
        // if (Test.isRunningTest())
        //     return;
        //prepare emails list:
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();

        Map<Id, Boolean> contactsOptedOutEmailMap = getContactsOptedOutEmailMap(
            new List<Id>(contactIdToWhatIdSet.keySet())
        );
        for (Id currContactId : contactIdToWhatIdSet.keySet()) {
            for (Id whatId : contactIdToWhatIdSet.get(currContactId)) {
                if (
                    contactsOptedOutEmailMap.get(currContactId) != null &&
                    !contactsOptedOutEmailMap.get(currContactId)
                ) {
                    emailMessages.add(
                        createEmail(getEmailTemplateId(templateName), currContactId, whatId)
                    );
                }
            }
        }

        //send emails:
        sendEmailMessages(emailMessages);
    }

    private static Map<Id, Boolean> getContactsOptedOutEmailMap(List<Id> contactIds) {
        List<Contact> contacts = [
            SELECT Id, HasOptedOutOfEmail
            FROM Contact
            WHERE Id IN :contactIds
        ];
        Map<Id, Boolean> contactsOptedOutEmailMap = new Map<Id, Boolean>();
        for (Contact c : contacts)
            contactsOptedOutEmailMap.put(c.Id, c.HasOptedOutOfEmail);
        return contactsOptedOutEmailMap;
    }

    public static void sendShareEmail(Id whatId, Id fromId, String emailAddr, String templateName) {
        Id shareStudyEmailTemplateId = [
            SELECT Id
            FROM EmailTemplate
            WHERE DeveloperName = :templateName
            LIMIT 1
        ]
        .Id;
        List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setTemplateId(shareStudyEmailTemplateId);
        msg.setWhatId(whatId);
        msg.setTargetObjectId(fromId);
        msg.setToAddresses(new List<String>{ emailAddr });
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
            emailToSend.setOrgWideEmailAddressId(getOrgWideEmailId(fromId));
            msgListToBeSend.add(emailToSend);
        }
        Messaging.sendEmail(msgListToBeSend);
    }

    @InvocableMethod(Label='Send Emails')
    public static void sendEmailNotificationWithDelegates(List<emailNotification> variables) {
        if (Test.isRunningTest())
            return;
        //prepare emails list:
        System.debug(variables);
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        emailMessages.add(
            createEmail(
                getEmailTemplateId(variables[0].templateName),
                variables[0].contactId,
                variables[0].whatId,
                variables[0].studyId,
                true,
                variables[0].userMode
            )
        );
        System.debug(emailMessages);
        //send emails:
        sendEmailMessages(emailMessages);
    }
    public class emailNotification {
        @InvocableVariable
        public String templateName;
        @InvocableVariable
        public Id contactId;
        @InvocableVariable
        public Id whatId;
        @InvocableVariable
        public Id studyId;
        @InvocableVariable
        public String userMode;
    }

    public static Messaging.SingleEmailMessage createEmail(
        String templateDeveloperName,
        Id contactId,
        Id whatId
    ) {
        return createEmail(getEmailTemplateId(templateDeveloperName), contactId, whatId);
    }

    public static Messaging.SingleEmailMessage createEmail(
        Id emailTemplateId,
        Id contactId,
        Id whatId
    ) {
        return createEmail(emailTemplateId, contactId, whatId, null, false, '');
    }

    public static Messaging.SingleEmailMessage createEmail(
        Id emailTemplateId,
        Id contactId,
        Id whatId,
        Id studyId,
        Boolean ccDelegates,
        String userMode
    ) {
        Messaging.SingleEmailMessage newEmail = new Messaging.SingleEmailMessage();
        newEmail.setTemplateId(emailTemplateId);
        newEmail.setTargetObjectId(contactId);
        newEmail.setSaveAsActivity(false);
        newEmail.setOrgWideEmailAddressId(getOrgWideEmailId(contactId));

        //newEmail.setToAddresses(new List<String>{toAddress});
        newEmail.setWhatId(whatId);
        if (ccDelegates && userMode == CommunityService.USER_MODE_PI) {
            List<String> delegateAddresses = new List<String>();
            for (Site_Staff__c delegate : [
                SELECT Id, Site_Contact__r.Email, is_Invited__c
                FROM Site_Staff__c
                WHERE
                    Delegate_Level__c = :DelegateService.DELEGATE_LEVEL_1
                    AND Study_Site__c = :studyId
                    AND is_Invited__c = TRUE
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

    private static final Map<String, Id> templateNameIdMap = new Map<String, Id>();

    private static Id getEmailTemplateId(String templateName) {
        Id templateId = templateNameIdMap.get(templateName);
        if (templateId != null)
            return templateId;
        List<EmailTemplate> templates = [
            SELECT Id
            FROM EmailTemplate
            WHERE DeveloperName = :templateName
            LIMIT 1
        ];
        if (templates.isEmpty())
            throw new SendEmailTemplateException(
                'Email template: "' +
                templateName +
                '" not found'
            );
        templateNameIdMap.put(templateName, templates[0].Id);
        return templates[0].Id;
    }

    private static OrgWideEmailAddress getOrgwideEmailAddress(String addressName) {
        List<OrgWideEmailAddress> orgwideEmailAddresses = [
            SELECT Id
            FROM OrgWideEmailAddress
            WHERE DisplayName = :addressName
            LIMIT 1
        ];
        if (orgwideEmailAddresses.isEmpty()) {
            Organization org = [SELECT Id, IsSandbox FROM Organization LIMIT 1];
            if (org.IsSandbox) {
                orgwideEmailAddresses = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
                if (!orgwideEmailAddresses.isEmpty()) {
                    return orgwideEmailAddresses[0];
                }
            }
            throw new SendEmailTemplateException(
                'Org Wide Email Address: "' +
                addressName +
                '" not found'
            );
        }
        return orgwideEmailAddresses[0];
    }

    /**
        @param fromId ID of user Contact
     */
    public static Id getOrgWideEmailId(Id fromId) {
        String userMode = CommunityService.getContactUserMode(fromId);
        if (userMode != null && userMode.equalsIgnoreCase(CommunityService.USER_MODE_PARTICIPANT)) {
            return getOrgwideEmailAddress(CommunityService.COMMUNITY_ORG_WIDE_ADDRESS_PATIENT).Id;
        } else {
            return getOrgwideEmailAddress(CommunityService.COMMUNITY_ORG_WIDE_ADDRESS_REFERRAL).Id;
        }
    }

    public static void sendEmailMessages(List<Messaging.SingleEmailMessage> emailMessages) {
        for (Messaging.SendEmailResult result : Messaging.sendEmail(emailMessages, false)) {
            if (result.success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' + JSON.serializePretty(result.errors));
            }
        }
    }

    public static void sendEmailMessages(List<EmailMessageWrapper> emailMessageWrappers) {
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        for (EmailMessageWrapper emw : emailMessageWrappers) {
            emailMessages.add(createEmail(emw.emailTemplateName, emw.recipientId, emw.whatId));
        }
        sendEmailMessages(emailMessages);
    }
}
