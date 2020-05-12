String emailTemplateName = 'Initial_Email_GSK';
Id contactId = '003c000001KnrEQAAZ';
Id userId = [SELECT Id FROM User WHERE ContactId =: contactId].Id;
Id whatId = userId;

SendEmailTemplate.sendEmailMessages(new List<Messaging.SingleEmailMessage>{
        SendEmailTemplate.createEmail(emailTemplateName, userId, whatId)
});
