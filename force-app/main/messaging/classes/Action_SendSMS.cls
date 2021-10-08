/**
 * Created by Olga Skrynnikova on 12/16/2019.
 * Refactored by Pijush Kar on 09/30/2021
 */

public with sharing class Action_SendSMS implements Action {
    public class Action_SendSMS_Exception extends Exception {
    }
    private List<Id> notificationIds;
    transient private NotificationResultService sendResultService;
    transient private IntegrationLog__c log;

    public Action_SendSMS(List<Notification__c> notifications) {
        this.notificationIds = SObjectHelper.toIdsList(notifications);
    }

    public class MessageParameters {
        public String transactionId;
        public String fromNumber;
        public List<String> toNumber;
        public String subject;
        public String messageBody;
    }

    public void execute() {
        List<MessageParameters> messageParametersList = new List<MessageParameters>();
        Map<Id, Task> taskMap;
        List<Notification__c> notifications = [
            SELECT
                Id,
                Notification_Type__c,
                Recipient__c,
                Recipient__r.Phone,
                Recipient__r.Language__c,
                WhatId__c,
                Task_Id__c
            FROM Notification__c
            WHERE Id IN :notificationIds
        ];
        sendResultService = new NotificationResultService(notifications);
        List<Id> conIds = new List<Id>();
        List<Id> taskIds = new List<Id>();
        for (Notification__c n : notifications) {
            conIds.add(n.Recipient__c);
            if (!String.isBlank(n.Task_Id__c)) {
                taskIds.add(n.Task_Id__c);
            }
        }
        if (!taskIds.isEmpty()) {
            taskMap = new Map<Id, Task>(
                [SELECT Id, Community_Template_Name__c FROM Task WHERE Id IN :taskIds]
            );
        }
        Map<Id, Participant__c> participantMap = new Map<Id, Participant__c>();
        List<Participant__c> participants = [
            SELECT Id, Contact__c, Phone__c
            FROM Participant__c
            WHERE Contact__c IN :conIds
        ];
        for (Participant__c participant : participants) {
            if (participant.Contact__c != null) {
                participantMap.put(participant.Contact__c, participant);
            }
        }
        ParametrizedMessageService parametrizedMessageService = new ParametrizedMessageService();
        for (Notification__c n : notifications) {
            Notification_Type__mdt messageType = NotificationService.getNotificationType(
                n.Notification_Type__c
            );
            Notification_Target__mdt smsTarget = NotificationService.getNotificationTarget(
                n.Notification_Type__c,
                NotificationService.NOTIFICATION_TARGET_TYPE_SMS
            );
            parametrizedMessageService.addMessage(
                n.Id,
                smsTarget.Message_Body__c,
                n.WhatId__c,
                messageType.Parameters_Provider__r.DeveloperName,
                n.Recipient__r.Language__c
            );
        }
        parametrizedMessageService.processMessages();

        for (Send_Result__c smsChannel : [
            SELECT
                Id,
                Target_Type__c,
                Status__c,
                CreatedDate,
                Notification__c,
                Notification__r.Recipient__c,
                Notification__r.Recipient__r.Phone,
                Notification__r.Recipient__r.Language__c,
                Notification__r.Notification_Type__c,
                Notification__r.Task_Id__c
            FROM Send_Result__c
            WHERE
                Notification__c IN :notificationIds
                AND Target_Type__c = :NotificationService.NOTIFICATION_TARGET_TYPE_SMS
        ]) {
            String phoneNumber = smsChannel.Notification__r.Recipient__r.Phone;
            if (
                phoneNumber == null &&
                participantMap.get(smsChannel.Notification__r.Recipient__c) != null
            ) {
                phoneNumber = participantMap.get(smsChannel.Notification__r.Recipient__c).Phone__c;
            }
            String title = parametrizedMessageService.getMessage(
                smsChannel.Notification__c + '_title'
            );
            String message = parametrizedMessageService.getMessage(smsChannel.Notification__c);
            if (
                !String.isBlank(message) &&
                NotificationService.taskAndVisitReminderTypes.contains(
                    smsChannel.Notification__r.Notification_Type__c
                )
            ) {
                if (
                    !String.isBlank(smsChannel.Notification__r.Task_Id__c) &&
                    taskMap.containsKey(smsChannel.Notification__r.Task_Id__c) &&
                    !String.isBlank(
                        taskMap.get(smsChannel.Notification__r.Task_Id__c)
                            .Community_Template_Name__c
                    )
                ) {
                    String communityTemaplteName = taskMap.get(
                            smsChannel.Notification__r.Task_Id__c
                        )
                        .Community_Template_Name__c;
                    if (!String.isBlank(communityTemaplteName)) {
                        String commUrl = CommunityService.getCommunityURLFromTemplateName(
                            communityTemaplteName
                        );
                        message = message.replace('##CommunityURL', commUrl);
                    }
                }
            }
            if (phoneNumber != null) {
                MessageParameters msgParam = new MessageParameters();
                msgParam.transactionId = smsChannel.Id + '~' + smsChannel.CreatedDate; //
                msgParam.fromNumber = 'XXXX'; //TO-DO
                msgParam.toNumber = new List<String>{ phoneNumber };
                msgParam.subject = title;
                msgParam.messageBody = message;
                messageParametersList.add(msgParam);
            }
        }
        /*for (Notification__c n : notifications) {
            String phoneNumber = n.Recipient__r.Phone;
            if (phoneNumber == null && participantMap.get(n.Recipient__c) != null) {
                phoneNumber = participantMap.get(n.Recipient__c).Phone__c;
            }
            String message = parametrizedMessageService.getMessage(n.Id);
            if (phoneNumber != null) {
                messageParametersList.add(new MessageParameters('XXXX', new List<String>{phoneNumber},
            }
        }*/
        if (!messageParametersList.isEmpty()) {
            RemoteCall_SendSMS remoteCallSendSMS = new RemoteCall_SendSMS(messageParametersList);
            remoteCallSendSMS.execute();
            log = remoteCallSendSMS.log;
            for (Notification__c n : notifications) {
                if (remoteCallSendSMS.log.Success__c) {
                    sendResultService.setSent(
                        n.Id,
                        NotificationService.NOTIFICATION_TARGET_TYPE_SMS
                    );
                } else {
                    sendResultService.setFailed(
                        n.Id,
                        NotificationService.NOTIFICATION_TARGET_TYPE_SMS,
                        remoteCallSendSMS.log.Error_Message__c
                    );
                }
            }

            if (!log.Success__c) {
                throw new Action_SendSMS_Exception(log.Error_Message__c);
            }
        }
    }

    public Type getType() {
        return Action_SendSMS.class;
    }

    public Boolean isDMLWithSetupObjects() {
        return false;
    }

    public void postDML(Action__c dbAction, Execution_History__c executionHistory) {
        if (log != null)
            insert log;
        if (executionHistory != null && executionHistory.Id != null && log != null) {
            executionHistory.Integration_Log__c = log.Id;
            update executionHistory;
        }
        sendResultService.setAction(dbAction);
        sendResultService.updateResults(log);
    }
}
