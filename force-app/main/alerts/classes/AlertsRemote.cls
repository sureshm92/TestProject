/**
 * Created by Leonid Bartenev
 */

public without sharing class AlertsRemote {
    
    @AuraEnabled
    public static String getPPAlerts(String userMode) { // Changes for PEH -8551 - Anitha
        try {
            List<Alert> alerts = Alert.getContactPPAlerts( 
                CommunityService.getUserContact().Id,
                userMode
            );
            return JSON.serialize(alerts);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getAlerts(String userMode) {
        try {
            List<Alert> alerts = Alert.getContactAlerts(
                CommunityService.getUserContact().Id,
                userMode
            );
            return JSON.serialize(alerts);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void setAlertViewed(Id alertId) {
        try {
            Alert__c alert = new Alert__c(Id = alertId, Viewed__c = true);
            update alert;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }
}