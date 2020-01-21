/**
 * Created by Olga Skrynnikova on 12/9/2019.
 */

public with sharing class SMSService {
    
    public class SendSMSQueueable implements Queueable, Database.AllowsCallouts{
        
        private List<Notification__c> notifications;
        
        public SendSMSQueueable(List<Notification__c> notifications){
            this.notifications = notifications;
        }
    
        public void execute(QueueableContext qc) {
            send(notifications);
        }
    }

    public static void send(List<Notification__c> notifications) {
        Map<String, String> messageByPhone = new Map<String, String>();
        List <Id> conIds = new List<Id>();
        for (Notification__c n : notifications) conIds.add(n.Recipient__c);
        Map<Id, Contact> contactMap = new Map<Id, Contact>([
                SELECT Id, Phone, Language__c
                FROM Contact
                WHERE Id IN :conIds
        ]);
        ParametrizedMessageService parametrizedMessageService = new ParametrizedMessageService();
        for(Notification__c n : notifications){
            Notification_Type__mdt messageType = NotificationService.getNotificationType(n.Notification_Type__c);
            Notification_Target__mdt smsTarget = NotificationService.getNotificationTarget(n.Notification_Type__c, NotificationService.NOTIFICATION_TARGET_TYPE_SMS);
            Contact recipient = contactMap.get(n.Recipient__c);
            parametrizedMessageService.addMessage(
                    n.Id,
                    smsTarget.Message_Body__c,
                    n.WhatId__c,
                    messageType.Parameters_Provider__r.DeveloperName,
                    recipient.Language__c
            );
        }
        parametrizedMessageService.processMessages();
        
        for (Notification__c n : notifications) {
            Contact recipient = contactMap.get(n.Recipient__c);
            String phoneNumber = recipient.Phone;
            String message = parametrizedMessageService.getMessage(n.Id);
            if(phoneNumber != null) {
                messageByPhone.put(phoneNumber, message);
                //TODO For Demo only, to remove!!!
                /*new MCloudSMSSender().sendSMS(new List<String>{
                        phoneNumber
                }, message);*/
            }
        }

        Action_SendSMS actionSendSMS = new Action_SendSMS(messageByPhone);
        ActionExecutor.execute(actionSendSMS);
        NotificationResultService sendResultService = new NotificationResultService(notifications);
        for(Notification__c n : notifications){
            if(actionSendSMS.log.Success__c){
                sendResultService.setSent(n.Id, NotificationService.NOTIFICATION_TARGET_TYPE_SMS);
            }else{
                sendResultService.setFailed(n.Id, NotificationService.NOTIFICATION_TARGET_TYPE_SMS, actionSendSMS.log.Error_Message__c);
            }
        }
        sendResultService.updateResults();
    }
    
    public static void sendQueueable(List<Notification__c> notifications){
        System.enqueueJob(new SendSMSQueueable(notifications));
    }
    
    
}