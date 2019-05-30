/**
 * Created by Igor Malyuta on 28.05.2019.
 */

public with sharing class Batch_PatientTaskExpire implements Database.Batchable<Task>, Database.Stateful{

    private static final String JOB_NAME = 'PatientTaskExpire';

    public Iterable<Task> start(Database.BatchableContext param1) {
        List<Task> tasks = [
                SELECT Id
                FROM Task
                WHERE ActivityDate <=: System.today()
                    AND Status IN: TaskService.TASK_STATUS_GROUP_EXPIRE_AVAILABLE
        ];

        System.debug('Records found: '+ tasks.size());
        return tasks;
    }

    public void execute(Database.BatchableContext param1, List<Task> tasks) {
        for(Task t : tasks) t.Status = TaskService.TASK_STATUS_EXPIRED;
        update tasks;
    }

    public void finish(Database.BatchableContext param1) {
        List<Batch_Executor__mdt> batchExecutor = [
                SELECT Relaunch_Interval__c FROM Batch_Executor__mdt WHERE Job_Name__c = :JOB_NAME];
        if(!batchExecutor.isEmpty()) {
            Integer minutes = batchExecutor.get(0).Relaunch_Interval__c.intValue();
            System.scheduleBatch(
                    new Batch_PatientTaskExpire(), JOB_NAME, minutes);
        }
    }

    public static void run() {
        Database.executeBatch(new Batch_PatientTaskExpire());
    }

    public static void stop() {
        List<CronTrigger> cronTriggers = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name =: JOB_NAME
        ];
        if(!cronTriggers.isEmpty()) {
            for(CronTrigger cronT : cronTriggers) {
                System.abortJob(cronT.Id);
            }
        }
    }
}