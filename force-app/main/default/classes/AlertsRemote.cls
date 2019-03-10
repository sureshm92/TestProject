/**
 * Created by Leonid Bartenev
 */

public class AlertsRemote {
    
    @AuraEnabled
    public static String getAlerts(String userMode){
        List<Alert> alerts = Alert.getContactAlerts(CommunityService.getUserContact().Id);
        return JSON.serialize(alerts);
    }
    
    @AuraEnabled
    public static void setAlertViewed(Id alertId){
        try{
            Alert__c alert = new Alert__c(Id = alertId, Viewed__c = true);
            update alert;
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

}