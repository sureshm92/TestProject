public without sharing class SendEmailTemplate {
    
    public static final String EMAIL_TEMPLATE_PATIENT1_NEW = 'Patient1_New_Study';
    public static final String EMAIL_TEMPLATE_PATIENT2_NEW = 'Patient2_New_Study';
    
    public class SendEmailTemplateException extends Exception{}
    public static final Id ORGWIDE_EMAIL_ADDRESS_ID = getOrgwideEmailAddress().Id;
    
    public static void sendEmailNotification(String templateName, Map<Id, String> whatIdMap){
        //prepare emails list:
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        List<Contact> contacts = [SELECT Id, HasOptedOutOfEmail FROM Contact WHERE Id IN : whatIdMap.values()];
        Map<Id, Boolean> contactsOptedOutEmailMap = new Map<Id, Boolean>();
        for(Contact c: contacts) contactsOptedOutEmailMap.put(c.Id, c.HasOptedOutOfEmail);
        
        for(Id whatId : whatIdMap.keySet()){
            if(contactsOptedOutEmailMap.get(whatIdMap.get(whatId))!= null && !contactsOptedOutEmailMap.get(whatIdMap.get(whatId))){
                emailMessages.add(createEmail(getEmailTemplateId(templateName), whatIdMap.get(whatId), whatId));
            }
        }
        //send emails:
        sendEmailMessages(emailMessages);
    }
    
    public static void sendShareEmail(Id whatId, Id fromId,  String emailAddr) {
        Id shareStudyEmailTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: CommunityService.COMMUNITY_ET_SHARE_STUDY LIMIT 1].Id;
        List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setTemplateId(shareStudyEmailTemplateId);
        msg.setWhatId(whatId);
        msg.setTargetObjectId(fromId);
        msg.setToAddresses(new List<String>{emailAddr});
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
            emailToSend.setHTMLBody(email.getHTMLBody());
            emailToSend.setPlainTextBody(email.getPlainTextBody());
            emailToSend.setSubject(email.getSubject());
            emailToSend.setOrgWideEmailAddressId(ORGWIDE_EMAIL_ADDRESS_Id);
            msgListToBeSend.add(emailToSend);
        }
        Messaging.sendEmail(msgListToBeSend);
    }
    @InvocableMethod(Label='Send Emails')
    public static void sendEmailNotificationWithDelegates(List<emailNotification> variables){
        //prepare emails list:
        System.debug(variables);
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        emailMessages.add(createEmail(getEmailTemplateId(variables[0].templateName), variables[0].contactId, variables[0].whatId, variables[0].studyId, true, variables[0].userMode));
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


    
    public static Messaging.SingleEmailMessage createEmail(String templateDeveloperName, Id contactId, Id whatId){
        return createEmail(getEmailTemplateId(templateDeveloperName), contactId, whatId);
    }
    
    public static Messaging.SingleEmailMessage createEmail(Id emailTemplateId, Id contactId, Id whatId){

        return createEmail(emailTemplateId, contactId, whatId, null, false,'');
    }

    public static Messaging.SingleEmailMessage createEmail(Id emailTemplateId, Id contactId, Id whatId, Id studyId, Boolean ccDelegates, String userMode){
        Messaging.SingleEmailMessage newEmail = new Messaging.SingleEmailMessage();
        newEmail.setTemplateId(emailTemplateId);
        newEmail.setTargetObjectId(contactId);
        newEmail.setSaveAsActivity(false);
        newEmail.setOrgWideEmailAddressId(ORGWIDE_EMAIL_ADDRESS_Id);
        //newEmail.setToAddresses(new List<String>{toAddress});
        //newEmail.setWhatId(whatId);
        if(ccDelegates && userMode == CommunityService.USER_MODE_PI){
            List<String> delegateAddresses = new List<String>();
            for(Site_Staff__c delegate : [
                    SELECT Id, Site_Contact__r.Email
                    FROM Site_Staff__c
                    WHERE
                    Delegate_Level__c =: DelegateService.DELEGATE_LEVEL_1
                    AND Study_Site__c = :studyId]){
                delegateAddresses.add(delegate.Site_Contact__r.Email);
            }
            newEmail.setCcAddresses(delegateAddresses);
        }
        else if(ccDelegates && userMode == CommunityService.USER_MODE_HCP){
            List<String> delegateAddresses = new List<String>();
            for(Referring_HCP_Staff__c delegate : [
                    SELECT Id, Contact__r.Email
                    FROM Referring_HCP_Staff__c
                    WHERE
                    Delegate_Level__c =: DelegateService.DELEGATE_LEVEL_1
                    AND HCP_Enrollment__r.Study_Site__c = :studyId]){
                delegateAddresses.add(delegate.Contact__r.Email);
            }
            newEmail.setCcAddresses(delegateAddresses);
        }

        return newEmail;
    }
    
    private static final Map<String, Id> templateNameIdMap = new Map<String, Id>();
    
    private static Id getEmailTemplateId(String templateName) {
        Id templateId = templateNameIdMap.get(templateName);
        if(templateId != null) return templateId;
        List<EmailTemplate> templates = [
                SELECT Id
                FROM EmailTemplate
                WHERE DeveloperName = :templateName
                LIMIT 1
        ];
        if(templates.isEmpty()) throw new SendEmailTemplateException('Email template: "' + templateName + '" not found');
        templateNameIdMap.put(templateName, templates[0].Id);
        return templates[0].Id;
    }
    
    private static OrgwideEmailAddress getOrgwideEmailAddress() {
        List<OrgWideEmailAddress> orgwideEmailAddresses = [
                SELECT Id
                FROM OrgwideEmailAddress
                WHERE displayname = :CommunityService.COMMUNITY_ORG_WIDE_ADDRESS_NAME
                LIMIT 1
        ];
        if(orgwideEmailAddresses.isEmpty()){
            Organization org = [SELECT Id, IsSandbox FROM Organization LIMIT 1];
            if(org.IsSandbox){
                orgwideEmailAddresses = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
                if(!orgwideEmailAddresses.isEmpty()){
                    return orgwideEmailAddresses[0];
                }
            }
            throw new SendEmailTemplateException('Org Wide Email Address: "' + CommunityService.COMMUNITY_ORG_WIDE_ADDRESS_NAME + '" not found');
        }
        return orgwideEmailAddresses[0];
    }
    
    public static void sendEmailMessages(List<Messaging.SingleEmailMessage> emailMessages){
        System.debug(emailMessages);
        for(Messaging.SendEmailResult result : Messaging.sendEmail(emailMessages, false)){
            if (result.success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' + result.errors[0].message);
            }
        }
    }

}