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
        Map<Id, SurveyInvitation> surveyInvitations = new Map<Id, SurveyInvitation>(
            [
                SELECT
                    Id,
                    CreatedDate,
                    ExpireDateTime__c,
                    InviteExpiryDateTime,
                    Participant_Enrollment__r.Participant_Contact__c
                FROM SurveyInvitation
                WHERE Trial_Survey__c IN :oldTrialSurveys
            ]
        );

        Set<Id> contactIds = new Set<Id>();
        for (SurveyInvitation inv : surveyInvitations.values()) {
            inv.ExpireDateTime__c = System.now();
            inv.Is_Expired__c = true;
            if (inv.InviteExpiryDateTime != null)
                inv.InviteExpiryDateTime = null;

            Id participantCId = inv.Participant_Enrollment__r.Participant_Contact__c;
            contactIds.add(participantCId);
            contactIds.addAll(PatientDelegateService.getDelegatedContactIds(participantCId));
        }
        update surveyInvitations.values();

        List<Task> surveyTasks = [
            SELECT Id, Status
            FROM Task
            WHERE
                Task_Type__c = :TaskService.TASK_TYPE_SURVEY
                AND Status IN :TaskService.TASK_STATUS_GROUP_EXPIRE_AVAILABLE
                AND WhoId IN :contactIds
                AND Survey_Invitation__c IN :surveyInvitations.keySet()
        ];
        for (Task task : surveyTasks)
            task.Status = TaskService.TASK_STATUS_EXPIRED;

        update surveyTasks;
    }
}
