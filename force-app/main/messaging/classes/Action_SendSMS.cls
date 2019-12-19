/**
 * Created by Olga Skrynnikova on 12/16/2019.
 */

public with sharing class Action_SendSMS implements Action{
    public class Action_SendSMS_Exception extends Exception{}
    public Map<String, String> messageByPhone = new Map<String, String>();

    public Action_SendSMS(Map<String, String> messageByPhone){
       this.messageByPhone = messageByPhone;
    }

    public void execute() {
        RemoteCall_SendSMS remoteCallSendSMS = new RemoteCall_SendSMS(messageByPhone);
        remoteCallSendSMS.execute();
        if(!remoteCallSendSMS.log.Success__c) throw new Action_SendSMS_Exception(remoteCallSendSMS.log.Error_Message__c);
    }

    public Type getType() {
        return Action_SendSMS.class;
    }
}