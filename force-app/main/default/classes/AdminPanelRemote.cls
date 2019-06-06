/**
 * Created by Igor Malyuta on 30.05.2019.
 */

public with sharing class AdminPanelRemote {

    public class BatchException extends Exception{}

    public static final List<String> ASYNC_STATUSES = new List<String>{
            'Holding',
            'Queued',
            'Preparing',
            'Processing'
    };

    @AuraEnabled
    public static List<JobWrapper> getData() {
        try {
            List<Batch_Executor__mdt> batchExecutors = [SELECT Id, Label, DeveloperName FROM Batch_Executor__mdt];

            Map<String, Batch_Executor__mdt> batchMap = new Map<String, Batch_Executor__mdt>();
            for (Batch_Executor__mdt be : batchExecutors) batchMap.put(be.DeveloperName, be);

            List<AsyncApexJob> asyncApexJobs = [
                    SELECT
                            ApexClass.Name
                    FROM AsyncApexJob
                    WHERE JobType = 'BatchApex' AND Status IN: ASYNC_STATUSES
                    AND ApexClass.Name IN: batchMap.keySet()
            ];
            Map<String, Id> runningBatches = new Map<String, Id>();
            for(AsyncApexJob asyncApexJob : asyncApexJobs) runningBatches.put(asyncApexJob.ApexClass.Name, asyncApexJob.Id);

            List<CronTrigger> cronTriggers = [
                    SELECT
                            CronJobDetail.Name,
                            NextFireTime
                    FROM CronTrigger
                    WHERE CronJobDetail.Name IN:batchMap.keySet()
            ];
            Map<String, CronTrigger> scheduledBatches = new Map<String, CronTrigger>();
            for(CronTrigger ct : cronTriggers) scheduledBatches.put(ct.CronJobDetail.Name, ct);

            List<JobWrapper> jobWrappers = new List<JobWrapper>();
            for (Batch_Executor__mdt bex : batchExecutors) {
                jobWrappers.add(new JobWrapper(bex, scheduledBatches, runningBatches));
            }

            return jobWrappers;
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
            JobWrapper jobWrapper = getState(jobName);
            if(jobWrapper.jobId == null) {
                Database.executeBatch((Database.Batchable<SObject>) Type.forName(jobWrapper.jobName).newInstance());
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void stopBatch(String jobName) {
        try {
            JobWrapper jobWrapper = getState(jobName);
            if(jobWrapper.jobId != null) System.abortJob(jobWrapper.jobId);
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
            if(wrapper == null) throw new BatchException('No batch found!');

            return wrapper;
        } catch (Exception e) {
            return (JobWrapper) AuraHelper.throwException(e);
        }
    }

    public class JobWrapper {
        @AuraEnabled public String css;
        @AuraEnabled public String label;
        @AuraEnabled public String jobId;
        @AuraEnabled public String jobName;
        @AuraEnabled public Datetime nextLaunch;
        @AuraEnabled public String state;
        @AuraEnabled public Boolean showSpinner;

        public JobWrapper(Batch_Executor__mdt be, Map<String, CronTrigger> scheduledBatches, Map<String, Id> runningBatches) {
            this.jobName = be.DeveloperName;
            this.label = be.Label;
            this.showSpinner = false;

            if(runningBatches.containsKey(jobName)) {
                jobId = runningBatches.get(jobName);
                state = 'RUNNING';
                css = 'ad-state-running';
            } else if(scheduledBatches.containsKey(jobName)) {
                jobId = scheduledBatches.get(jobName).Id;
                state = 'SCHEDULED';
                css = 'ad-state-waiting';
                nextLaunch = scheduledBatches.get(jobName).NextFireTime;
            } else {
                state = 'NOT STARTED';
                css = 'ad-state-not-started';
            }
        }
    }
}