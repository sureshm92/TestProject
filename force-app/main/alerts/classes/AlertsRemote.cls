/**
 * Created by Leonid Bartenev
 */

public without sharing class AlertsRemote {
    @AuraEnabled
    public static String getAlerts(String userMode) {
        try {
            List<Alert> alerts = new List<Alert>();
            Boolean isDelegate = ParticipantContext.isCurrentDelegate();
            Participant_Enrollment__c currentPE = ParticipantContext.getCurrentPE();
            if (
                isDelegate &&
                currentPE != null &&
                currentPE.Clinical_Trial_Profile__r.CommunityTemplate__c ==
                CommunityTemplateService.TEMPLATE_PP
            ) {
                alerts = Alert.getContactAlerts(currentPE.Participant_Contact__c, userMode);
            } else {
                alerts = Alert.getContactAlerts(CommunityService.getUserContact().Id, userMode);
            }

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
