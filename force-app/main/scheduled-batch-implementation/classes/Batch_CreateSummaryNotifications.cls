/**
 * Created by Igor Malyuta on 11.09.2019.
 */

public without sharing class Batch_CreateSummaryNotifications extends Batch_ScheduledAbstract {
    public Set<Id> ctpIds = new Set<Id>();
    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator(
            [
                SELECT
                    Active_After_Days__c,
                    Active_On_Status__c,
                    Clinical_Trial_Profile__c,
                    Expires_After_Days__c,
                    Expires_On_Status__c,
                    Id,
                    Notify_On_Availability__c,
                    Resource__c,
                    Visible_In_Alumni__c,
                    Visible_To_Delegates__c,
                    Visible_To_Participant__c,
                    Visible_To_PI__c,
                    Visible_To_RP__c,
                    Resource__r.Content_Type__c
                FROM Res_study__c
                WHERE Visible_To_Participant__c = TRUE
            ]
        );
    }

    public void execute(Database.BatchableContext param1, List<Res_study__c> resStudies) {
        Map<Id, List<Res_study__c>> resStudyByCtp = new Map<Id, List<Res_study__c>>();
        for (Res_study__c res : resStudies) {
            if (!ctpIds.contains(res.Clinical_Trial_Profile__c)) {
                ctpIds.add(res.Clinical_Trial_Profile__c);
            }
        }
    }

    public override void finalAction() {
        Batch_CreateStudyReSourceNotification objBatch = new Batch_CreateStudyReSourceNotification(
            ctpIds
        );
        Database.executeBatch(objBatch, 200);
    }

    public override Type getType() {
        return Batch_CreateSummaryNotifications.class;
    }

    private Boolean needNotify(Contact contact, Id resourceId) {
        Boolean notify = false;
        if (
            contact.Resource_Notifications__c == null ||
            !contact.Resource_Notifications__c.contains(resourceId)
        ) {
            notify = true;
        }
        return notify;
    }

    public override String getBatchDescription() {
        return 'This job sends Emails and SMS when new Study Document is available and insert update notification';
    }

    public override String getRecommendedIntervalMode() {
        return Batch_ScheduledAbstract.INTERVAL_HOURS;
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 1;
    }
}
