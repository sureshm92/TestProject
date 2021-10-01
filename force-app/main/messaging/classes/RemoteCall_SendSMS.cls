/**
 * Created by Olga Skrynnikova on 12/16/2019.
 */

public with sharing class RemoteCall_SendSMS extends RemoteCall {
    public enum NotificationTypes {
        TRANSACTIONAL,
        PROMOTIONAL
    }

    public class MessageWrapper {
        public SourceMetadata sourceMetadata;
        public NotificationMetadata notificationMetadata;
        public NotificationOption notificationOption;
        public PreferredDeliveryPeriod preferredDeliveryPeriod;
        public Arguments arguments;
    }

    public class SourceMetadata {
        public String sourceIdentifier = 'PP';
        public String transactionId;
    }

    public class NotificationMetadata {
        public String notificationType;
        public String fromNumber;
        public List<String> toNumber;
        public String templateId;
        public String messageBody;
        public String subject;
    }

    public class NotificationOption {
        public Boolean customerResponseRequired;
        public Boolean deliveryReceiptStatusRequired;
        public Boolean blacklistCheckRequired;
        public Boolean optOutCheckRequired;
    }

    public class PreferredDeliveryPeriod {
        public String deliveryStartTime; //Format HH:MM:SS
        public String deliveryEndTime; //Format HH:MM:SS
        public String timezone;
    }

    public class Arguments {
        public List<Argument> argument;
    }

    public class Argument {
        public String name;
        public String value;
        public Boolean isSensitive;
    }

    public List<MessageWrapper> messageWrapperList;

    public RemoteCall_SendSMS(List<MessageParameters> messageParametersList) {
        this.endPointURL = 'callout:MulesoftSMS';
        this.httpMethod = METHOD_POST;
        this.headersMap.putAll(new Map<String, String>{ 'Content-Type' => 'application/json' });
        messageWrapperList = new List<MessageWrapper>();
        logAutoInsert = false;
        for (MessageParameters messageParameters : messageParametersList) {
            MessageWrapper messageWrapper = new MessageWrapper();
            messageWrapper.sourceMetadata = new SourceMetadata();
            messageWrapper.notificationMetadata = new NotificationMetadata();
            messageWrapper.notificationOption = new NotificationOption();
            messageWrapper.preferredDeliveryPeriod = new PreferredDeliveryPeriod();
            messageWrapper.arguments = new Arguments();
            messageWrapper.arguments.argument = new List<Argument>();

            //TO-DO:
            messageWrapperList.add(messageWrapper);
        }
    }

    public override Type getType() {
        return RemoteCall_SendSMS.class;
    }

    protected override String buildRequestBody() {
        return JSON.serializePretty(messageWrapperList, true);
    }

    protected override Object parseResponse(String responseBody) {
        return null;
    }
}
