/**
 * Created by Igor Malyuta on 30.05.2019.
 */

public with sharing class AdminPanelRemote {

    private static List<Batch_Executor__mdt> batchExecutors;
    private static Map<String, Batch_Executor__mdt> jobMap;
    private static Map<String, CronTrigger> jobCron;

    static {
        batchExecutors = [SELECT Id, Relaunch_Interval__c, Label FROM Batch_Executor__mdt];

        jobMap = new Map<String, Batch_Executor__mdt>();
        for(Batch_Executor__mdt be : batchExecutors) jobMap.put(be.Label, be);
    }

    @AuraEnabled
    public static String getData() {
        try {
            List<JobWrapper> wrappers = new List<JobWrapper>();
            for (Batch_Executor__mdt bex : batchExecutors) wrappers.add(new JobWrapper(bex.Label));

            List<CronTrigger> cronTriggers = [
                    SELECT
                            CronJobDetailId,
                            CronJobDetail.Name,
                            EndTime,
                            Id,
                            NextFireTime,
                            PreviousFireTime,
                            StartTime,
                            State,
                            TimesTriggered
                    FROM CronTrigger
                    WHERE CronJobDetail.Name IN:jobMap.keySet()
            ];
            if(!cronTriggers.isEmpty()) {
                jobCron = new Map<String, CronTrigger>();
                for(CronTrigger ct : cronTriggers) jobCron.put(ct.CronJobDetail.Name, ct);

                for(JobWrapper jw : wrappers) {
                    CronTrigger cron = jobCron.get(jw.jobName);
                    if(cron == null) continue;

                    jw.state = cron.State;
                    jw.timesTrigg = cron.TimesTriggered;
                    jw.prevFT = cron.PreviousFireTime;
                    jw.nextFT = cron.NextFireTime;
                }
            }

            return JSON.serialize(wrappers);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void runBatch(String jobName) {
        try {
            BatchExecutor.run(jobName);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void stopBatch(String jobName) {
        try {
            BatchExecutor.stop(jobName);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    public class JobWrapper {
        public String jobName;
        public String state;
        public Integer timesTrigg;
        public Datetime prevFT;
        public Datetime nextFT;

        public JobWrapper(String jobName) {
            this.jobName = jobName;
            this.state = 'NOT STARTED';
        }
    }
}