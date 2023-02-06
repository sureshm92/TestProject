public class Batch_CleanUpBatchNotifications extends Batch_ScheduledAbstract {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime tenDaysBefore = DateTime.now().addDays(-10);
        return DataBase.getQueryLocator(
            [SELECT Id FROM Batch_Notification__c WHERE CreatedDate < :tenDaysBefore]
        );
    }
    public void execute(
        Database.BatchableContext bc,
        List<Batch_Notification__c> BatchNotifications
    ) {
        delete BatchNotifications;
    }
    public override Type getType() {
        return Batch_CleanUpBatchNotifications.class;
    }

    public override String getBatchDescription() {
        return 'This job cleans Batch_Notification records';
    }

    public override String getRecommendedIntervalMode() {
        return Batch_ScheduledAbstract.INTERVAL_DAYS;
    }
    

    public override Integer getRecommendedRelaunchInterval() {
        return 10;
    }
}
