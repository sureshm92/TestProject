/**
 * Created by Vitalii Aheienko on 9/17/2019.
 */

public with sharing class CTPSendNotificationService {

    private List<Trial_Notification__c> relatedNotifications;


    public void runWorkflow(List<Clinical_Trial_Profile__c> profiles, Map<Id, Clinical_Trial_Profile__c> oldRecords) {
        for (Trial_Notification__c notification : this.getNotificationsByCtps(profiles, oldRecords)) {
            notification.Need_To_Send_Alert__c = true;
        }
        update relatedNotifications;
    }

    public void removeSentNotifications(List<Clinical_Trial_Profile__c> profiles, Map<Id, Clinical_Trial_Profile__c> oldRecords) {
        delete this.getNotificationsByCtps(profiles, oldRecords);
    }

    private List<Trial_Notification__c> getNotificationsByCtps(List<Clinical_Trial_Profile__c> ctps, Map<Id, Clinical_Trial_Profile__c> oldRecords) {
        if (this.relatedNotifications == null) {
            DatabaseProxy proxy = new DatabaseProxy();
            List<Id> ctpIds = this.extractJustOpenedCtps(ctps, oldRecords);
            if (ctpIds.isEmpty()){
                this.relatedNotifications = new List<Trial_Notification__c>();
            } else {
                String query = 'SELECT Id FROM Trial_Notification__c WHERE Clinical_Trial_Profile__c IN (\'' + String.join(ctpIds, '\',\'') + '\')';
                relatedNotifications = proxy.query(query);
            }
        }
        return relatedNotifications;
    }

    private List<Id> extractJustOpenedCtps(List<Clinical_Trial_Profile__c> profiles, Map<Id, Clinical_Trial_Profile__c> oldRecords) {
        List<Id> justOpenedCtpIds = new List<Id>();
        TrialSearchHelper trialHelper = (TrialSearchHelper) ClassFactory.newInstance(TrialSearchHelper.class);
        for (Clinical_Trial_Profile__c profile : profiles) {
            if (trialHelper.isCtpEnrolling(profile) && !trialHelper.isCtpEnrolling(oldRecords.get(profile.Id))) {
                justOpenedCtpIds.add(profile.Id);
            }
        }
        return justOpenedCtpIds;
    }

}