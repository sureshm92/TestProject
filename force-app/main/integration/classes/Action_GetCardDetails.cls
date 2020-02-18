/**
 * Created by Nargiz Mamedova on 1/21/2020.
 */

public with sharing class Action_GetCardDetails implements Action{

    public class Action_GetCardDetails_Exception extends Exception{}
    private String protocolId;
    private String patientId;
    private Participant__c participant;
    public Id integrationLogId;
    transient public IntegrationLog__c log;
    transient public List<RemoteCall_GetCardDetails.Card> result;

    public Action_GetCardDetails(String protocolId, String patientId, Participant__c participant) {
        this.protocolId = protocolId;
        this.patientId = patientId;
        this.participant = participant;
    }

    public void execute() {
        integrationLogId = null;
        RemoteCall_GetCardDetails remoteCallGetCardDetails = new RemoteCall_GetCardDetails(protocolId, patientId);
        result = (List<RemoteCall_GetCardDetails.Card>) remoteCallGetCardDetails.execute();
        integrationLogId = remoteCallGetCardDetails.log.Id;
        log = remoteCallGetCardDetails.log;
        if(remoteCallGetCardDetails.log.Success__c) {
            if(result[0].balance.substring(result[0].balance.length() - 2).equals('.0')) result[0].balance = result[0].balance + '0';
            result[0].status = result[0].status.substring(0, 1).toUpperCase() + result[0].status.substring(1).toLowerCase();
            participant.Balance__c = result[0].balance;
            participant.Status__c = result[0].status;
            update participant;
        }
        else throw new Action_GetCardDetails_Exception(remoteCallGetCardDetails.log.Error_Message__c);
    }

    public Type getType() {
        return Action_GetCardDetails.class;
    }
}