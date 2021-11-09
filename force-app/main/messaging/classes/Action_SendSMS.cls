/**
 * Created by Olga Skrynnikova on 12/16/2019.
 * Refactored by Pijush Kar on 09/30/2021
 */

public with sharing class Action_SendSMS implements Action {
    private List<Id> notificationIds;
    transient private NotificationResultService sendResultService;
    transient private IntegrationLog__c log;
    public static final String PHONE_TYPE_MOBILE = 'Mobile';

    public class Action_SendSMS_Exception extends Exception {
    }
    public class MessageParameters {
        public String transactionId;
        public List<String> toNumber;
        public String subject;
        public String messageBody;
    }
    class MessagegResponseWrapper {
        public string applicationId;
        public string requestId;
        public List<MsgResult> result;
    }
    class MsgResult {
        public String toNumber;
        public MsgStatus status;
    }
    class MsgStatus {
        public String deliveryStatus;
        public String statusCode;
        public String statusMessage;
        public String messageId;
    }
    class DialingCountryConfig {
        public List<String> dialCountryCodeList;
        public Integer characterLimit;
    }

    public Action_SendSMS(List<Notification__c> notifications) {
        this.notificationIds = SObjectHelper.toIdsList(notifications);
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
        // Map<String, List<String>> countryDialCodeMap = new Map<String, List<String>>();
        Map<String, DialingCountryConfig> countryDialCodeMap = new Map<String, DialingCountryConfig>();
        for (Dialing_Country_Code__mdt mdt : [
            SELECT Id, DeveloperName, Dialing_Code__c, Enabled_for_SMS__c, Character_Limit__c
            FROM Dialing_Country_Code__mdt
            WHERE Enabled_for_SMS__c = TRUE
        ]) {
            DialingCountryConfig obj = new DialingCountryConfig();
            obj.dialCountryCodeList = mdt.Dialing_Code__c.split(',');
            obj.characterLimit = mdt.Character_Limit__c == null
                ? 160
                : Integer.valueOf(mdt.Character_Limit__c);
            //countryDialCodeMap.put(mdt.DeveloperName, mdt.Dialing_Code__c.split(','));
            countryDialCodeMap.put(mdt.DeveloperName, obj);
        }
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
            SELECT
                Id,
                Contact__c,
                Phone__c,
                Phone_Type__c,
                Alternative_Phone_Number__c,
                Alternative_Phone_Type__c
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
                Notification__r.Recipient__r.MobilePhone,
                Notification__r.Recipient__r.Language__c,
                Notification__r.Recipient__r.MailingCountryCode,
                Notification__r.Notification_Type__c,
                Notification__r.Task_Id__c
            FROM Send_Result__c
            WHERE
                Notification__c IN :notificationIds
                AND Target_Type__c = :NotificationService.NOTIFICATION_TARGET_TYPE_SMS
        ]) {
            String phoneNumber = smsChannel.Notification__r.Recipient__r.MobilePhone;
            if (
                phoneNumber == null &&
                participantMap.get(smsChannel.Notification__r.Recipient__c) != null
            ) {
                phoneNumber = participantMap.get(smsChannel.Notification__r.Recipient__c)
                        .Alternative_Phone_Type__c.equals(PHONE_TYPE_MOBILE)
                    ? participantMap.get(smsChannel.Notification__r.Recipient__c)
                          .Alternative_Phone_Number__c
                    : null;
            }
            //Uncomment and set the value in metadata if needed in future.
            /*String title = parametrizedMessageService.getMessage(
                smsChannel.Notification__c + '_title'
            );*/
            String message = parametrizedMessageService.getMessage(smsChannel.Notification__c);
            if (
                !String.isBlank(message) &&
                NotificationService.taskAndVisitReminderTypes.contains(
                    smsChannel.Notification__r.Notification_Type__c
                )
            ) {
                if (
                    !String.isBlank(smsChannel.Notification__r.Task_Id__c) &&
                    taskMap.containsKey(smsChannel.Notification__r.Task_Id__c)
                ) {
                    String communityTemaplteName = taskMap.get(
                            smsChannel.Notification__r.Task_Id__c
                        )
                        .Community_Template_Name__c;
                    if (String.isBlank(communityTemaplteName)) {
                        communityTemaplteName = 'Default';
                    }
                    String commUrl = CommunityService.getCommunityURLFromTemplateName(
                        communityTemaplteName
                    );
                    message = message.replace('##CommunityURL', commUrl);
                }
            }
            if (phoneNumber != null) {
                MessageParameters msgParam = new MessageParameters();
                phoneNumber =
                    countryDialCodeMap.get(
                            smsChannel.Notification__r.Recipient__r.MailingCountryCode
                        )
                        .dialCountryCodeList.get(0) + phoneNumber.replaceAll('\\D', '');
                msgParam.transactionId = smsChannel.Id; //Keeping Send_Result__c Id for 32 char limit
                msgParam.toNumber = new List<String>{ phoneNumber };
                if (
                    message.length() >
                    countryDialCodeMap.get(
                            smsChannel.Notification__r.Recipient__r.MailingCountryCode
                        )
                        .characterLimit
                ) {
                    message = message.substring(
                        0,
                        countryDialCodeMap.get(
                                smsChannel.Notification__r.Recipient__r.MailingCountryCode
                            )
                            .characterLimit
                    );
                }
                msgParam.messageBody = message;
                messageParametersList.add(msgParam);
            }
        }
        if (!messageParametersList.isEmpty()) {
            RemoteCall_SendSMS remoteCallSendSMS = new RemoteCall_SendSMS(messageParametersList);
            // remoteCallSendSMS.execute();
            String respBody = (String) remoteCallSendSMS.execute();
            MessagegResponseWrapper respWrapper = parseResponseBody(respBody);
            log = remoteCallSendSMS.log;
            for (Notification__c n : notifications) {
                if (remoteCallSendSMS.log.Success__c) {
                    sendResultService.setSent(
                        n.Id,
                        NotificationService.NOTIFICATION_TARGET_TYPE_SMS
                    );
                    sendResultService.getSendResult(
                            n.Id,
                            NotificationService.NOTIFICATION_TARGET_TYPE_SMS
                        )
                        .Msg_Id__c = respWrapper.result[0].status.messageId;
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

    public MessagegResponseWrapper parseResponseBody(String responseBody) {
        try {
            MessagegResponseWrapper msgResponseWrap = (MessagegResponseWrapper) JSON.deserialize(
                responseBody,
                MessagegResponseWrapper.class
            );
            return msgResponseWrap;
        } catch (JSONException e) {
            return new MessagegResponseWrapper();
        }
    }
}
