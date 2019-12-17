/**
 * Created by Olga Skrynnikova on 12/16/2019.
 */

public with sharing class Action_SendSMS implements Action{
    public class Action_SendSMS_Exception extends Exception{}
    public String message;
    public String phoneNumber;

    public Action_SendSMS(String phoneNumber, String message){
        this.message = message;
        this.phoneNumber = phoneNumber;
    }

    public void execute() {
        try {
            RemoteCall_SendSMS remoteCallSendSMS = new RemoteCall_SendSMS(phoneNumber, message);
        } catch (Exception e){
            throw new Action_SendSMS_Exception('SendSMS Action failed');
        }
    }

    public Type getType() {
        return Action_SendSMS.class;
    }
}