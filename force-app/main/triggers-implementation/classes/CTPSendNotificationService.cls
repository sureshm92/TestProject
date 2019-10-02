/**
 * Created by Vitalii Aheienko on 9/17/2019.
 */

public with sharing class CTPSendNotificationService {

    private List<Trial_Notification__c> sentNotifications;

    public void updateRelatedTrialNotifications(List<Clinical_Trial_Profile__c> ctps, Map<Id, Clinical_Trial_Profile__c> oldRecords) {
        Set<Id> justOpenedCtpIds = this.extractJustOpenedCtpIds(ctps, oldRecords);
        List<Trial_Notification__c> relatedNotifications = this.getNotificationsByCtpIds(new List<Id>(justOpenedCtpIds));
        if (relatedNotifications.isEmpty()) {
            return;
        }
        this.runSendNotificationsWorkflow(relatedNotifications);
        this.sentNotifications = relatedNotifications;
    }

    public void removeSentNotifications() {
        if (this.sentNotifications != null && !this.sentNotifications.isEmpty()) {
            DatabaseProxy proxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
            proxy.deleteRecords(this.sentNotifications, true);
        }
    }

    public void removeRelatedTrialNotificationsOnDelete(List<Clinical_Trial_Profile__c> removedCtps) {
        DatabaseProxy proxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        Set<Id> ctpIds = new Map<Id, Clinical_Trial_Profile__c>(removedCtps).keySet();
        List<Trial_Notification__c> notifications = this.getNotificationsByCtpIds(new List<Id>(ctpIds));
        proxy.deleteRecords(notifications, true);
    }

    private void runSendNotificationsWorkflow(List<Trial_Notification__c> notifications) {
        for (Trial_Notification__c notification : notifications) {
            notification.Need_To_Send_Alert__c = true;
        }
        DatabaseProxy proxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        proxy.updateRecords(notifications, true);
    }

    private Set<Id> extractJustOpenedCtpIds(List<Clinical_Trial_Profile__c> profiles, Map<Id, Clinical_Trial_Profile__c> oldRecords) {
        Set<Id> justOpenedCtpIds = new Set<Id>();
        TrialSearchHelper trialHelper = (TrialSearchHelper) ClassFactory.newInstance(TrialSearchHelper.class);
        for (Clinical_Trial_Profile__c profile : profiles) {
            if (trialHelper.isCtpEnrolling(profile) && !trialHelper.isCtpEnrolling(oldRecords.get(profile.Id))) {
                justOpenedCtpIds.add(profile.Id);
            }
        }
        return justOpenedCtpIds;
    }

    private List<Trial_Notification__c> getNotificationsByCtpIds(List<Id>ctpIds) {
        List<Trial_Notification__c> relatedNotifications = new List<Trial_Notification__c>();
        if (!ctpIds.isEmpty()) {
            DatabaseProxy proxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
            String query = 'SELECT Id ' +
                    'FROM Trial_Notification__c ' +
                    'WHERE Clinical_Trial_Profile__c IN (\'' + String.join(ctpIds, '\',\'') + '\')';
            relatedNotifications = proxy.query(query);
        }
        return relatedNotifications;
    }

}