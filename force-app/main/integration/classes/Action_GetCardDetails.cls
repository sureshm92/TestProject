/**
 * Created by Nargiz Mamedova on 1/21/2020.
 */

public with sharing class Action_GetCardDetails implements Action{

    public class Action_GetCardDetails_Exception extends Exception{}
    private String paymentId;
    private Participant__c participant;
    public Id integrationLogId;
    transient public IntegrationLog__c log;
    transient public RemoteCall_GetCardDetails.Card result;

    public Action_GetCardDetails(String paymentId, Participant__c participant) {
        this.paymentId = paymentId;
        this.participant = participant;
    }

    public void execute() {
        integrationLogId = null;
        RemoteCall_GetCardDetails remoteCallGetCardDetails = new RemoteCall_GetCardDetails(paymentId, '148642');
        result = (RemoteCall_GetCardDetails.Card) remoteCallGetCardDetails.execute();
        integrationLogId = remoteCallGetCardDetails.log.Id;
        log = remoteCallGetCardDetails.log;
        if(remoteCallGetCardDetails.log.Success__c) {
            if(result.balance.substring(result.balance.length() - 2).equals('.0')) result.balance = result.balance + '0';
            result.status = result.status.substring(0, 1).toUpperCase() + result.status.substring(1).toLowerCase();
            participant.Balance__c = result.balance;
            participant.Status__c = result.status;
            update participant;
        }
        else throw new Action_GetCardDetails_Exception(remoteCallGetCardDetails.log.Error_Message__c);
    }

    public Type getType() {
        return Action_GetCardDetails.class;
    }
}