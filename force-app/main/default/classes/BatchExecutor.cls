/**
 * Created by Igor Malyuta on 31.05.2019.
 */

public with sharing class BatchExecutor {

    public class BatchExecutorException extends Exception{}

    public static void run(String batchName) {
        if(getCronTrigger(batchName).isEmpty()) {
            Database.executeBatch((Database.Batchable<SObject>) Type.forName(batchName).newInstance());
        }
        else {
            throw new BatchExecutorException('Job already run!');
        }
    }

    public static void stop(String batchName) {
        List<CronTrigger> cronTriggers = getCronTrigger(batchName);
        if(!cronTriggers.isEmpty()) {
            for(CronTrigger cronT : cronTriggers) {
                System.abortJob(cronT.Id);
            }
        }
        else {
            throw new BatchExecutorException('No job found!');
        }
    }

    private static List<CronTrigger> getCronTrigger(String jobName) {
        return [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name =: jobName
        ];
    }
}