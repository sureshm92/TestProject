/**
 * Created by Igor Malyuta on 28.05.2019.
 */

public with sharing class Batch_PatientTaskExpire implements Database.Batchable<Task>, Database.Stateful{

    public Integer intervalInMinutes;

    public Batch_PatientTaskExpire(Integer intervalInMinutes) {
        this.intervalInMinutes = intervalInMinutes;
    }

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
        System.scheduleBatch(
                new Batch_PatientTaskExpire(intervalInMinutes), 'PatientTaskExpire', intervalInMinutes);
    }

    public static void run(Integer intervalInMinutes) {
        Database.executeBatch(new Batch_PatientTaskExpire(intervalInMinutes));
    }

    public static void stop() {
        List<CronTrigger> cronTriggers = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name = 'PatientTaskExpire'
        ];
        if(!cronTriggers.isEmpty()) {
            for(CronTrigger cronT : cronTriggers) {
                System.abortJob(cronT.Id);
            }
        }
    }
}