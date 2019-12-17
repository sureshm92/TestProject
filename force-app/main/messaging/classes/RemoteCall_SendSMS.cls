/**
 * Created by Olga Skrynnikova on 12/16/2019.
 */

public with sharing class RemoteCall_SendSMS extends RemoteCall {

    public class MessageWrapper {
        public String message;
        public String phoneNumber;
    }

    public MessageWrapper messageWrapper;

    public RemoteCall_SendSMS(String phoneNumber, String message) {
        this.endPointURL = 'callout:ServiceNowAndStudyHub';
        this.httpMethod = METHOD_POST;
        this.headersMap.putAll(new Map<String, String>{
                'Content-Type' => 'application/json'
        });
        this.messageWrapper.message = message;
        this.messageWrapper.phoneNumber = phoneNumber;
    }

    public override Type getType() {
        return RemoteCall_SendSMS.class;
    }

    protected override String buildRequestBody() {
        return JSON.serializePretty(messageWrapper, true);
    }

    protected override Object parseResponse(String responseBody) {
        return null;
    }

}