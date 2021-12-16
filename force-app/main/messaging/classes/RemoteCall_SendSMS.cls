/**
 * Created by Olga Skrynnikova on 12/16/2019.
 * Refactored by Pijush Kar on 10/07/2021
 */

public with sharing class RemoteCall_SendSMS extends RemoteCall {
    public enum NotificationTypes {
        TRANSACTIONAL,
        PROMOTIONAL
    }
    public static final String FROM_NUMBER = 'FromNumber';
    public static final String SOURCE_IDENTIFIER = 'SourceIdentifier';
    public static final String API_MULESOFT_SMS = 'MulesoftSMS';
    public static final String PIN_POINT_PROJECT_ID = 'PinpointProjectId';
    public static final String PL_SPONSOR = 'Sponsor';
    public static final String PL_STUDY = 'Study';

    public class MessageWrapper {
        public SourceMetadata sourceMetadata;
        public TargetMetadata targetMetadata;
        public NotificationMetadata notificationMetadata;
        public NotificationOption notificationOption;
        public PreferredDeliveryPeriod preferredDeliveryPeriod;
        //public Arguments arguments;
    }

    public class SourceMetadata {
        public String sourceIdentifier; // = 'RH_PP' as per initial design discussion
        public String transactionId;
    }

    public class TargetMetadata {
        public String sponsor;
        public String study;
        public String pinPointProjectId;
    }

    public class NotificationMetadata {
        public String notificationType;
        public String fromNumber;
        //public List<String> toNumber;
        public List<ToNumber> toNumbers;
        public String templateId;
        public String messageBody;
        public String subject;
        public String templateName;
        public String templateVersion;
    }

    public class ToNumber {
        public String mobNumber;
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
        public String timezone; //ISO code
    }

    /** public class Arguments {
        public List<Argument> argument;
    }

    public class Argument {
        public String name;
        public String value;
        public Boolean isSensitive;
    }
     */
    private MessageWrapper messageWrapper;

    public RemoteCall_SendSMS(List<Action_SendSMS.MessageParameters> messageParametersList) {
        this.endPointURL = 'callout:MulesoftSMS';
        this.httpMethod = METHOD_POST;
        Map<String, Config_API_Param__mdt> apiParamsMap = new Map<String, Config_API_Param__mdt>();
        for (Config_API_Param__mdt mdt : [
            SELECT DeveloperName, ParamValue__c
            FROM Config_API_Param__mdt
            WHERE ConfigAPI__r.DeveloperName = :API_MULESOFT_SMS
        ]) {
            apiParamsMap.put(mdt.DeveloperName, mdt);
        }
        this.headersMap.putAll(new Map<String, String>{ 'Content-Type' => 'application/json' });
        messageWrapper = new MessageWrapper();
        Action_SendSMS.MessageParameters msgParam = messageParametersList.get(0);
        logAutoInsert = false;
        //Initialize
        messageWrapper.sourceMetadata = new SourceMetadata();
        messageWrapper.targetMetadata = new TargetMetadata();
        messageWrapper.notificationMetadata = new NotificationMetadata();
        NotificationOption notificationOptionObj = new NotificationOption();
        notificationOptionObj.customerResponseRequired = true;
        notificationOptionObj.blacklistCheckRequired = true;
        notificationOptionObj.deliveryReceiptStatusRequired = true;
        notificationOptionObj.optOutCheckRequired = true;
        messageWrapper.notificationOption = notificationOptionObj;
        PreferredDeliveryPeriod preferredDeliveryPeriodObj = new PreferredDeliveryPeriod();
        preferredDeliveryPeriodObj.deliveryEndTime = '';
        preferredDeliveryPeriodObj.deliveryStartTime = '';
        preferredDeliveryPeriodObj.timezone = 'GMT';
        messageWrapper.preferredDeliveryPeriod = preferredDeliveryPeriodObj;
        // messageWrapper.arguments = new Arguments();
        //messageWrapper.arguments.argument = new List<Argument>();
        //Assign
        messageWrapper.sourceMetadata.transactionId = msgParam.transactionId;
        messageWrapper.sourceMetadata.sourceIdentifier = apiParamsMap.get(SOURCE_IDENTIFIER)
            .ParamValue__c;
        messageWrapper.targetMetadata.pinPointProjectId = msgParam.isPlatformLevel
            ? apiParamsMap.get(PIN_POINT_PROJECT_ID).ParamValue__c
            : msgParam.pinPointProjectId;
        messageWrapper.targetMetadata.sponsor = msgParam.isPlatformLevel
            ? apiParamsMap.get(PL_SPONSOR).ParamValue__c
            : msgParam.awsSponsorName;
        messageWrapper.targetMetadata.study = msgParam.isPlatformLevel
            ? apiParamsMap.get(PL_STUDY).ParamValue__c
            : msgParam.awsStudy;
        // messageWrapper.targetMetadata.pinPointProjectId = '123';
        messageWrapper.notificationMetadata.notificationType = NotificationTypes.TRANSACTIONAL.name();
        messageWrapper.notificationMetadata.fromNumber = apiParamsMap.get(FROM_NUMBER)
            .ParamValue__c;
        //  messageWrapper.notificationMetadata.ToNumber = msgParam.toNumber;
        ToNumber toNumberObj = new ToNumber();
        toNumberObj.mobNumber = msgParam.toNumber[0];
        List<ToNumber> toNumbers = new List<ToNumber>{ toNumberObj };
        messageWrapper.notificationMetadata.toNumbers = toNumbers;
        messageWrapper.notificationMetadata.templateName = '';
        messageWrapper.notificationMetadata.templateVersion = '';
        messageWrapper.notificationMetadata.subject = '';
        messageWrapper.notificationMetadata.templateId = '';
        messageWrapper.notificationMetadata.messageBody = msgParam.messageBody;
    }

    public override Type getType() {
        return RemoteCall_SendSMS.class;
    }

    protected override String buildRequestBody() {
        //System.debug('reqBody:::'+JSON.serializePretty(messageWrapper, true));
        return JSON.serializePretty(messageWrapper, true).replaceAll('mobNumber', 'number');
    }

    protected override Object parseResponse(String responseBody) {
        //TO:DO
        return responseBody;
    }
}
