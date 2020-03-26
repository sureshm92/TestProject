/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class ResourceExpBatchScheduler implements Schedulable {

    public static final String ALERT_GENERATOR_JOB = 'ResourceExp_JOB';
    public static final String LABEL_SCHEDULE = 'ExpDeleteInterval';

    public void execute(SchedulableContext SC) {

        String query = 'SELECT ' +
                'Id,' +
                'Expiration_Date__c, ' +
                'Content_Class__c ' +
                'FROM Resource__c ' +
                'WHERE Expiration_Date__c <= today  AND Remove_sharing__c = false';
        Database.executeBatch(new BatchProcess(query, new ResourceExpirationBatchHandlerImpl()), 1000);
        start();
    }

    public static void start() {
        List<CronTrigger> cleanStatusJob = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name
                        LIKE:ResourceExpBatchScheduler.ALERT_GENERATOR_JOB + '%'
        ];
        if (!cleanStatusJob.isEmpty()) {
            for (CronTrigger cr : cleanStatusJob) {
                System.abortJob(cr.Id);
            }
        }
        ScheduleIntervalSettings__mdt resourcesScheduleSetting = [
                SELECT
                        Seconds__c,
                        Minutes__c,
                        Hour__c,
                        Days__c,
                        Months__c,
                        Years__c
                FROM ScheduleIntervalSettings__mdt
                WHERE Label = :LABEL_SCHEDULE
        ][0];
        Datetime sysTime = System.now()
                .addSeconds(Integer.valueOf(resourcesScheduleSetting.Seconds__c))
                .addMinutes(Integer.valueOf(resourcesScheduleSetting.Minutes__c))
                .addHours(Integer.valueOf(resourcesScheduleSetting.Hour__c))
                .addDays(Integer.valueOf(resourcesScheduleSetting.Days__c))
                .addMonths(Integer.valueOf(resourcesScheduleSetting.Months__c))
                .addYears(Integer.valueOf(resourcesScheduleSetting.Years__c));
        String chronExpression = ''
                + sysTime.second()
                + ' ' + sysTime.minute()
                + ' ' + sysTime.hour()
                + ' ' + sysTime.day()
                + ' ' + sysTime.month()
                + ' ? ' + sysTime.year();
        System.schedule(ALERT_GENERATOR_JOB + sysTime, chronExpression, new ResourceExpBatchScheduler());
    }
}