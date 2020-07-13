public class EmailForPendingReferrals {
@InvocableMethod
    public static void sendMails(List<Batch_Notification__c> notifications){
        system.debug('notifications'+notifications);
         List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        Notification_Type__mdt notificationType = NotificationService.getNotificationType('PI_Delegates_New_Referral');
        Notification_Target__mdt nt = notificationType.Notification_Targets__r[0];
        for(Batch_Notification__c bn : notifications){
            List<Id> contactIds = new List<Id>();
            contactIds = bn.Recipient_Ids__c.split(';');
         
            NotificationAvailabilityService availabilityService = new NotificationAvailabilityService(contactIds, contactIds);
            for(Id contactId :contactIds)
		emailMessages.add(EmailService.createEmail(EmailService.getEmailTemplateId('PI_RP_New_Referral'), contactId, contactId, 
                                      availabilityService.getOrgWideEmail(contactId, contactId,nt.Org_Wide_Email_Address__c)));
        }
        List<Messaging.SendEmailResult> resultList = Messaging.sendEmail(emailMessages, false);
    }
}