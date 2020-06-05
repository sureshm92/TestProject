/**
 * Created by Leonid Bartenev
 */

public without sharing class ToolingAPI_SendCustomNotifications extends ToolingAPIAbstract{
    
    public static final String ENDPOINT_CUSTOM_NOTIFICATION_ACTION = '/services/data/v48.0/actions/standard/customNotificationAction';
    
    public class CustomNotification {
        public String customNotifTypeId;
        public List<String> recipientIds;
        public String title;
        public String body;
        public String targetId;
        
        public CustomNotification(Id customNotificationTypeId, Id recipientId, Id targetId, String title, String message){
            this.customNotifTypeId = customNotificationTypeId;
            this.recipientIds = new List<String>{recipientId};
            this.targetId = targetId;
            this.title = title;
            this.body = message;
        }
        
        public CustomNotification(Id customNotificationTypeId, List<Id> recipientIds, Id targetId, String title, String message){
            this.customNotifTypeId = customNotificationTypeId;
            this.recipientIds = recipientIds;
            this.targetId = targetId;
            this.title = title;
            this.body = message;
        }
    }
    
    private class CustomNotificationActionRequest{
        public List<CustomNotification> inputs;
        
        public CustomNotificationActionRequest(List<CustomNotification> notifications){
            inputs = notifications;
        }
        
    }
    
    private List<CustomNotification> customNotifications;
    
    public ToolingAPI_SendCustomNotifications(List<CustomNotification> customNotifications){
        this.customNotifications = customNotifications;
        this.httpMethod = METHOD_POST;
        this.endPointURL = ENDPOINT_CUSTOM_NOTIFICATION_ACTION;
    }
    
    protected override String buildRequestBody() {
        CustomNotificationActionRequest requestData = new CustomNotificationActionRequest(customNotifications);
        return JSON.serialize(requestData);
    }
    
    protected override Object parseResponse(String responseBody) {
        //do nothing
        return null;
    }
}