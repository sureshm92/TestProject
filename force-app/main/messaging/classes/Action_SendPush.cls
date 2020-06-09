/**
 * Created by Leonid Bartenev
 */

public without sharing class Action_SendPush implements Action{
    
    public class Action_SendPush_Exception extends Exception{}
    
    private final static String CUSTOM_NOTIFICATION_TYPE_NAME = 'PP_RH_Push_Notification';
    private List<Id> notificationIds;
    transient private NotificationResultService sendResultService;
    
    public Action_SendPush(List<Notification__c> notifications){
        this.notificationIds = SObjectHelper.toIdsList(notifications);
    }
    
    public void execute() {
        List<Notification__c> notifications = [
                SELECT Id,
                        Notification_Type__c,
                        Recipient__c,
                        Recipient__r.Phone,
                        Recipient__r.Language__c,
                        WhatId__c
                FROM Notification__c
                WHERE Id IN: notificationIds
        ];
        List<Id> contactIds = new List<Id>();
        for(Notification__c notification : notifications) {
            if(notification.Recipient__c != null) contactIds.add(notification.Recipient__c);
        }
        List<User> users = [SELECT Id, ContactId FROM User WHERE ContactId IN: contactIds];
        Map<Id, Id> userByContactIdMap = new Map<Id, Id>();
        for(User user : users) userByContactIdMap.put(user.ContactId, user.Id);
        sendResultService = new NotificationResultService(notifications);
        ParametrizedMessageService parametrizedMessageService = new ParametrizedMessageService();
        for(Notification__c n : notifications){
            Notification_Type__mdt messageType = NotificationService.getNotificationType(n.Notification_Type__c);
            Notification_Target__mdt pushTarget = NotificationService.getNotificationTarget(n.Notification_Type__c, NotificationService.NOTIFICATION_TARGET_TYPE_PUSH);
            parametrizedMessageService.addMessage(
                    n.Id,
                    pushTarget.Message_Body__c,
                    n.WhatId__c,
                    messageType.Parameters_Provider__r.DeveloperName,
                    n.Recipient__r.Language__c
            );
            parametrizedMessageService.addMessage(
                    n.Id + '_title',
                    pushTarget.Title__c,
                    n.WhatId__c,
                    messageType.Parameters_Provider__r.DeveloperName,
                    n.Recipient__r.Language__c
            );

        }
        parametrizedMessageService.processMessages();
    
        List<CustomNotificationType> ppRhPushNotificationTypes = [
                SELECT Id
                FROM CustomNotificationType
                WHERE DeveloperName =: CUSTOM_NOTIFICATION_TYPE_NAME
        ];
        if(ppRhPushNotificationTypes.size() == 0) throw new Action_SendPush_Exception('Custom notification: ' + CUSTOM_NOTIFICATION_TYPE_NAME + ' not found. Create custom notification with this name' );
        List<ToolingAPI_SendCustomNotifications.CustomNotification> customNotifications = new List<ToolingAPI_SendCustomNotifications.CustomNotification>();
        for (Notification__c n : notifications) {
            Id userId = userByContactIdMap.get(n.Recipient__c);
            String title = parametrizedMessageService.getMessage(n.Id + '_title');
            String message = parametrizedMessageService.getMessage(n.Id);
            if(userId != null) {
                customNotifications.add(new ToolingAPI_SendCustomNotifications.CustomNotification(
                        ppRhPushNotificationTypes[0].Id,
                        userId,
                        userId,
                        title,
                        message
                ));
            }
        }
    
        String errorMessage;
        try{
            new ToolingAPI_SendCustomNotifications(customNotifications).execute();
        }catch(Exception e){
            errorMessage = e.getMessage() + '/n' + e.getStackTraceString();
        }
        for(Notification__c n : notifications){
            if(errorMessage == null){
                sendResultService.setSent(n.Id, NotificationService.NOTIFICATION_TARGET_TYPE_PUSH);
            }else{
                sendResultService.setFailed(n.Id, NotificationService.NOTIFICATION_TARGET_TYPE_PUSH, errorMessage);
            }
        }
    
        if(errorMessage != null) throw new Action_SendPush_Exception(errorMessage);

    }
    
    public Type getType() {
        return Action_SendPush.class;
    }
    
    public Boolean isDMLWithSetupObjects() {
        return false;
    }
    
    public void postDML(Action__c dbAction, Execution_History__c executionHistory) {
        sendResultService.setAction(dbAction);
        sendResultService.updateResults();
    }
}