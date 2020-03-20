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
    }

    public Type getType() {
        return Action_GetCardDetails.class;
    }
    
    public Boolean isDMLWithSetupObjects() {
        return false;
    }
    
    public void postDML(Action__c dbAction, Execution_History__c executionHistory) {
    }
}