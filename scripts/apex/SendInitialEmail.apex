String emailTemplateName = 'Initial_Email';
Id contactId = '003c000001IQm66AAD';
Id whatId = '003c000001IQm66AAD';

ParametersDataProvider parametersDataProvider =  new ParametersDataProvider(whatId, null, contactId, null, null, null, 'HTML');

SendEmailTemplate.sendEmailMessages(new List<Messaging.SingleEmailMessage>{
        SendEmailTemplate.createEmail(emailTemplateName, contactId, whatId)
});

EmailTemplateController emailTemplateController = new EmailTemplateController();
emailTemplateController.emailRecipientId = contactId;
emailTemplateController.sourceRecordId = whatId;
emailTemplateController.replaceLineBreaksOnHTMLBreaks = true;
System.debug('Source SObject type ' + emailTemplateController.sourceRecordId.getSobjectType());
System.debug('Is delegate: ' + emailTemplateController.getDataProvider().isDelegate);
System.debug('User mode: ' + emailTemplateController.getDataProvider().userMode);
System.debug('Referral Source: ' + emailTemplateController.getDataProvider().parameters.get('ReferralSource'));
emailTemplateController.getUserName();
emailTemplateController.getUserLanguageCode();
String str = emailTemplateController.titleValue;
str = emailTemplateController.bodyValue;
