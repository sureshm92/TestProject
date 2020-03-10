String emailTemplateName = 'Initial_Email_GSK';
Id contactId = '003c000001KnrEQAAZ';
Id userId = [SELECT Id FROM User WHERE ContactId =: contactId].Id;
Id whatId = userId;

SendEmailTemplate.sendEmailMessages(new List<Messaging.SingleEmailMessage>{
        SendEmailTemplate.createEmail(emailTemplateName, userId, whatId)
});
 

/*
ParametersDataProvider parametersDataProvider =  new ParametersDataProvider(whatId, null, contactId, null, null, null, 'HTML');

EmailTemplateController controller = new EmailTemplateController();
controller.sourceRecordId = contactId;
controller.outputMode = 'HTML';
controller.replaceLineBreaksOnHTMLBreaks = false;

controller.getParameters();
controller.getDelegateLevelsPI();
controller.getDelegateLevelsHCP();
controller.getResultUserMode();
controller.getParameters();

String str = controller.bodyValue;
str = controller.titleValue;
str = controller.userGreetingValue;
str = controller.signatureValue;
str = controller.preSignatureValue;
str = controller.buttonLabelValue;*/
