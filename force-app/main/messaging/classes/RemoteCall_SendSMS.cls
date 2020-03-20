/**
 * Created by Olga Skrynnikova on 12/16/2019.
 */

public with sharing class RemoteCall_SendSMS extends RemoteCall {

    public class MessageWrapper {
        public String message;
        public String phone;

        public MessageWrapper(String phone, String message){
            this.message = message;
            this.phone = phone;
        }
    }

    public List<MessageWrapper> messageWrapperList;

    public RemoteCall_SendSMS(Map<String, String> messageByPhone) {
        this.endPointURL = 'callout:MulesoftSMS';
        this.httpMethod = METHOD_POST;
        this.headersMap.putAll(new Map<String, String>{
                'Content-Type' => 'application/json'
        });
        messageWrapperList = new List<MessageWrapper>();
        logAutoInsert = false;
        for(String phoneNumber : messageByPhone.keySet()){
            messageWrapperList.add(new MessageWrapper(phoneNumber,messageByPhone.get(phoneNumber)));
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