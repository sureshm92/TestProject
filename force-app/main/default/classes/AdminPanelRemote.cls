/**
 * Created by Igor Malyuta on 30.05.2019.
 */

public with sharing class AdminPanelRemote {

    private static final String DEFAULT_JOB_STATE = 'NOT STARTED';

    private static final Map<String, String> STATE_CSS = new Map<String, String>{
            DEFAULT_JOB_STATE => 'ad-state-not-started',
            'WAITING' => 'ad-state-waiting',
            'ACQUIRED' => 'ad-state-acquired',
            'EXECUTING' => 'ad-state-executing',
            'COMPLETE' => 'ad-state-complete',
            'ERROR' => 'ad-state-error',
            'DELETED' => 'ad-state-deleted',
            'PAUSED' => 'ad-state-paused',
            'BLOCKED' => 'ad-state-blocked',
            'PAUSED_BLOCKED' => 'ad-state-paused-blocked'
    };

    @AuraEnabled
    public static List<JobWrapper> getData() {
        try {
            List<Batch_Executor__mdt> batchExecutors = [SELECT Id, Label FROM Batch_Executor__mdt];

            Map<String, Batch_Executor__mdt> batchMap = new Map<String, Batch_Executor__mdt>();
            for (Batch_Executor__mdt be : batchExecutors) batchMap.put(be.Label, be);

            Map<String, JobWrapper> jobMap = new Map<String, JobWrapper>();
            for (Batch_Executor__mdt bex : batchExecutors) {
                jobMap.put(bex.Label, new JobWrapper(bex.Label));
            }

            List<CronTrigger> cronTriggers = [
                    SELECT
                            CronJobDetailId,
                            CronJobDetail.Name,
                            Id,
                            State
                    FROM CronTrigger
                    WHERE CronJobDetail.Name IN:batchMap.keySet()
            ];

            if (!cronTriggers.isEmpty()) {
                Map<String, CronTrigger> jobCron = new Map<String, CronTrigger>();
                for (CronTrigger ct : cronTriggers) jobCron.put(ct.CronJobDetail.Name, ct);

                for (JobWrapper jw : jobMap.values()) {
                    CronTrigger cron = jobCron.get(jw.jobName);
                    if (cron == null) continue;

                    jw.state = cron.State;
                    jw.css = STATE_CSS.get(cron.State);
                }
            }

            return jobMap.values();
        } catch (Exception e) {
            return (List<JobWrapper>) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void runFAQ(String mode) {
        try {
            switch on mode {
                when 'all' {
                    Batch_ReviewOnboardingFAQ.runAll();
                }
                when 'pi' {
                    Batch_ReviewOnboardingFAQ.runPI();
                }
                when 'hcp' {
                    Batch_ReviewOnboardingFAQ.runHCP();
                }
                when 'part' {
                    Batch_ReviewOnboardingFAQ.runParticipant();
                }
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
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

    @AuraEnabled
    public static JobWrapper getState(String jobName) {
        try {
            JobWrapper wrapper;
            for(JobWrapper jw : getData()) {
                if(jw.jobName.equals(jobName)) {
                    wrapper = jw;
                    break;
                }
            }
            if(wrapper == null) throw new BatchExecutor.BatchExecutorException('No batch found!');

            List<CronTrigger> cronTriggers = BatchExecutor.getCronTrigger(wrapper.jobName);
            if (!cronTriggers.isEmpty()) {
                wrapper.state = cronTriggers.get(0).State;
                wrapper.css = STATE_CSS.get(wrapper.state);
            }

            return wrapper;
        } catch (Exception e) {
            return (JobWrapper) AuraHelper.throwException(e);
        }
    }

    public class JobWrapper {
        @AuraEnabled
        public String jobName;

        @AuraEnabled
        public String state;

        @AuraEnabled
        public String css;

        @AuraEnabled
        public Boolean showSpinner;

        public JobWrapper(String jobName) {
            this.css = STATE_CSS.get(DEFAULT_JOB_STATE);
            this.jobName = jobName;
            this.showSpinner = false;
            this.state = DEFAULT_JOB_STATE;
        }
    }
}