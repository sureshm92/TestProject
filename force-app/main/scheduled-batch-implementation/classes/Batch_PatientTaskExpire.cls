 /**
 * Created by Igor Malyuta on 28.05.2019.
 */

public with sharing class Batch_PatientTaskExpire extends Batch_ScheduledAbstract {
    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator(
            [
                SELECT Id, Survey_Invitation__c
                FROM Task
                WHERE
                    Status IN :TaskService.TASK_STATUS_GROUP_EXPIRE_AVAILABLE
                    AND (Activity_Datetime__c <= :System.now()
                    OR Survey_Invitation__r.Is_Expired__c = TRUE)
            ]
        );
    }

    public void execute(Database.BatchableContext param1, List<Task> tasks) {
        List<Id> invitationIds = new List<Id>();
        for (Task t : tasks) {
            t.Status = TaskService.TASK_STATUS_EXPIRED;
            if (t.Survey_Invitation__c != null)
                invitationIds.add(Id.valueOf(t.Survey_Invitation__c));
        }
        update tasks;

        SurveyService.getInstance().expireInvitation(invitationIds);
    }

    public override Type getType() {
        return Batch_PatientTaskExpire.class;
    }

    public override String getBatchDescription() {
        return 'This job sets the task status to expired, provided that their end date matches the current one or their invitation has expired (only for the "survey" type)';
    }

    public override String getRecommendedIntervalMode() {
        return Batch_ScheduledAbstract.INTERVAL_DAYS;
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 1;
    }
}
