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
    
    public static void sendShareEmail(Id hcpeId, Id hcpContactId,  String emailAddr) {
        Id shareStudyEmailTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: CommunityService.COMMUNITY_ET_SHARE_STUDY LIMIT 1].Id;
        List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setTemplateId(shareStudyEmailTemplateId);
        msg.setWhatId(hcpeId);
        msg.setTargetObjectId(hcpContactId);
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
    
    
    public static Messaging.SingleEmailMessage createEmail(String templateDeveloperName, Id contactId, Id whatId){
        return createEmail(getEmailTemplateId(templateDeveloperName), contactId, whatId);
    }
    
    public static Messaging.SingleEmailMessage createEmail(Id emailTemplateId, Id contactId, Id whatId){
        Messaging.SingleEmailMessage newEmail = new Messaging.SingleEmailMessage();
        newEmail.setTemplateId(emailTemplateId);
        newEmail.setTargetObjectId(contactId);
        newEmail.setSaveAsActivity(false);
        newEmail.setOrgWideEmailAddressId(ORGWIDE_EMAIL_ADDRESS_Id);
        //newEmail.setToAddresses(new List<String>{toAddress});
        newEmail.setWhatId(whatId);
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
            throw new SendEmailTemplateException('Org Wide Email Address: "' + CommunityService.COMMUNITY_ORG_WIDE_ADDRESS_NAME + '" not found');
        }
        return orgwideEmailAddresses[0];
    }
    
    public static void sendEmailMessages(List<Messaging.SingleEmailMessage> emailMessages){
        for(Messaging.SendEmailResult result : Messaging.sendEmail(emailMessages, false)){
            if (result.success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' + result.errors[0].message);
            }
        }
    }

}