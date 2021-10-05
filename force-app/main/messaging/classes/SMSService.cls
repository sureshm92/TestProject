/**
 * Created by Olga Skrynnikova on 12/9/2019.
 */

public with sharing class SMSService {
    public class SendSMSQueueable implements Queueable, Database.AllowsCallouts {
        private List<Notification__c> notifications;

        public SendSMSQueueable(List<Notification__c> notifications) {
            this.notifications = notifications;
        }

        public void execute(QueueableContext qc) {
            send(notifications);
        }
    }

    public static void send(List<Notification__c> notifications) {
        Notification__c smsNotification = notifications.remove(0);
        Action sendSMSAction = new Action_SendSMS(new List<Notification__c>{ smsNotification });
        ActionExecutor.ExecutionResult executionResult = ActionExecutor.execute(sendSMSAction);
        executionResult.complete();
        if (!notifications.isEmpty()) {
            sendQueueable(notifications);
        }
    }

    public static void sendQueueable(List<Notification__c> notifications) {
        System.enqueueJob(new SendSMSQueueable(notifications));
    }
}
