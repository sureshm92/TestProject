/**
 * Created by Olga Skrynnikova on 12/9/2019.
 */

public with sharing class SMSService {

    public static void send(List<Notification__c> notifications){
        for (Notification__c n : notifications) {
            Notification_Target__mdt smsTarget = NotificationService.getNotificationTarget(n.Notification_Type__c, NotificationService.NOTIFICATION_TARGET_TYPE_SMS);
            Notification_Type__mdt smsType = NotificationService.getNotificationType(n.Notification_Type__c);
            
        }
    }
}