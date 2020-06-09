/**
 * Created by Leonid Bartenev
 */

public without sharing class Action_UpdateSendResults implements Action{
    
    private NotificationResultService notificationResultService;
    
    public Action_UpdateSendResults(NotificationResultService notificationResultService){
        this.notificationResultService = notificationResultService;
    }
    
    public void execute() {
        notificationResultService.updateResults();
    }
    
    public Type getType() {
        return Action_UpdateSendResults.class;
    }
    
    public Boolean isDMLWithSetupObjects() {
        return false;
    }
    
    public void postDML(Action__c dbAction, Execution_History__c executionHistory) {
    }
}