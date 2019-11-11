/**
 * Created by Igor Malyuta on 19.06.2019.
 */

public without sharing class TrialSurveyTriggerHandler {

    public class ExpireSurveyTaskAndInvitations extends TriggerHandler {
        public override void beforeDelete(List<SObject> oldList) {
            doExpire((List<Trial_Survey__c>) oldList);
        }
    }

    @TestVisible
    private static void doExpire(List<Trial_Survey__c> oldTrialSurveys) {
        Map<Id, SurveyInvitation> surveyInvitations = new Map<Id, SurveyInvitation>([
                SELECT
                        Id,
                        CreatedDate,
                        ExpireDateTime__c,
                        Participant_Enrollment__r.Participant_Contact__c
                FROM SurveyInvitation
                WHERE Trial_Survey__c IN:oldTrialSurveys
        ]);

        Set<Id> contactIds = new Set<Id>();
        for(SurveyInvitation inv : surveyInvitations.values()) {
            if(!Test.isRunningTest()) inv.ExpireDateTime__c = System.now();

            Id participantCId = inv.Participant_Enrollment__r.Participant_Contact__c;
            contactIds.add(participantCId);
            contactIds.addAll(PatientDelegateService.getDelegatedContactIds(participantCId));
        }
        update surveyInvitations.values();

        List<Task> surveyTasks = [
                SELECT
                        Id,
                        Description,
                        Status
                FROM Task
                WHERE Task_Type__c =: TaskService.TASK_TYPE_SURVEY
                    AND Status IN: TaskService.TASK_STATUS_GROUP_EXPIRE_AVAILABLE
                    AND WhoId IN: contactIds
        ];
        for(Task task : surveyTasks) {
            if(surveyInvitations.containsKey(task.Description)) task.Status = TaskService.TASK_STATUS_EXPIRED;
        }
        update surveyTasks;
    }
}