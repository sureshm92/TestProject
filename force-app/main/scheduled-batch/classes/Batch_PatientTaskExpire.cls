/**
 * Created by Igor Malyuta on 28.05.2019.
 */

public with sharing class Batch_PatientTaskExpire extends Batch_ScheduledAbstract {

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT Id, Description
                FROM Task
                WHERE Activity_Datetime__c <= :System.now()
                AND Status IN:TaskService.TASK_STATUS_GROUP_EXPIRE_AVAILABLE
        ]);
    }

    public void execute(Database.BatchableContext param1, List<Task> tasks) {
        List<Id> invitationIds = new List<Id>();
        for (Task t : tasks) {
            t.Status = TaskService.TASK_STATUS_EXPIRED;
            if (t.Description != null) invitationIds.add(Id.valueOf(t.Description));
        }
        update tasks;

        SurveyService.getInstance().expireInvitation(invitationIds);
    }

    public override Type getType() {
        return Batch_PatientTaskExpire.class;
    }
}