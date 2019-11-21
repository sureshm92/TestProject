/**
 * Created by Igor Malyuta on 21.11.2019.
 */

public without sharing class Batch_MoveTaskInvitations implements Database.Batchable<SObject>{

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT Id, Description, Survey_Invitation__c
                FROM Task
                WHERE Task_Type__c =: TaskService.TASK_TYPE_SURVEY
                AND Status IN: TaskService.TASK_STATUS_GROUP_AVAILABLE
                AND Survey_Invitation__c = NULL
        ]);
    }

    public void execute(Database.BatchableContext param1, List<Task> tasks) {
        for(Task t : tasks) {
            if(t.Description != null) {
                t.Survey_Invitation__c = t.Description;
                t.Description = null;
            }
        }

        update tasks;
    }

    public void finish(Database.BatchableContext param1) {
    }

    public static void run() {
        Database.executeBatch(new Batch_MoveTaskInvitations());
    }
}