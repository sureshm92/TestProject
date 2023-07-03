public without sharing class Batch_TelevisitCompletedStatus extends Batch_ScheduledAbstract implements Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            [
                SELECT
                    Id,
                    Status__c,
                    Visit_Date_Time__c,
                    Visit_Date__c,
                    Start_Time__c,
                    Visit_End_Date_Time__c
                FROM Televisit__c
                WHERE Status__c != 'Cancelled' AND Status__c != 'Completed'
            ]
        );
    }

    public void execute(Database.BatchableContext BC, List<Televisit__c> scope) {
        for (Televisit__c tv : scope) {
            if (tv.Visit_End_Date_Time__c < system.now()) {
                tv.Status__c = 'Completed';
            }
        }
        update scope;
    }

    public override void finalAction() {
        Database.executeBatch(new Batch_ProcessSRForCompletedTelevisits(), 200);
    }

    public override Type getType() {
        return Batch_TelevisitCompletedStatus.class;
    }

    public override virtual String getBatchDescription() {
        return 'Update televisit status to completed';
    }

    public override String getRecommendedIntervalMode() {
        return Batch_ScheduledAbstract.INTERVAL_HOURS;
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 12;
    }
}
