/**
 * Created by Leonid Bartenev
 */

public without sharing class Action_SendEmail implements Action{
    
    private List<Notification__c> emailNotifications;
    private Map<Id, String> orgWideEmailByNotifyMap;
    
    public Action_SendEmail(List<Notification__c> emailNotifications, Map<Id, String> orgWideEmailByNotifyMap){
        this.emailNotifications = emailNotifications;
        this.orgWideEmailByNotifyMap = orgWideEmailByNotifyMap;
    }
    
    public void execute() {
        EmailService.send(emailNotifications, orgWideEmailByNotifyMap);
    }
    
    public Type getType() {
        return Action_SendEmail.class;
    }
    
    public Boolean isDMLWithSetupObjects() {
        return false;
    }
    
    public void postDML(Action__c dbAction, Execution_History__c executionHistory) {
    }
}