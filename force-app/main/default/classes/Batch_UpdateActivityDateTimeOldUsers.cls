/**
 * Created by Olga Skrynnikova on 10/31/2019.
 */

public with sharing class Batch_UpdateActivityDateTimeOldUsers implements Database.Batchable<SObject>{

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT ActivityDate, Activity_Datetime__c, WhoId
                FROM Task
                WHERE ActivityDate != NULL
                AND Activity_Datetime__c = NULL
        ]);
    }

    public void execute(Database.BatchableContext param1, List<Task> tasks) {
        for(Task t: tasks) {
            t.Activity_Datetime__c = Datetime.newInstanceGmt(t.ActivityDate.year(), t.ActivityDate.month(), t.ActivityDate.day());
        }
        update tasks;

    }

    public void finish(Database.BatchableContext param1) {
    }
}