/**
 * Created by Leonid Bartenev
 */

public without sharing class SurveyResponseTriggerHandler {
    public static final String SURVEY_RESPONSE_STATUS_COMPLETED = 'Completed';
    public static final String SURVEY_RESPONSE_STATUS_PAUSED = 'Paused';

    @InvocableMethod(Label='Handle Suvey Response status Change')
    public static void handleStatusChange(List<SurveyResponse> srList) {
        Map<Id, List<Id>> invitationSubmitterClose = new Map<Id, List<Id>>();
        Map<Id, List<Id>> invitationSubmitterPaused = new Map<Id, List<Id>>();

        for (SurveyResponse sr : srList) {
            if (sr.Status == SURVEY_RESPONSE_STATUS_COMPLETED) {
                if (!invitationSubmitterClose.containsKey(sr.InvitationId)) {
                    invitationSubmitterClose.put(sr.InvitationId, new List<Id>());
                }
                invitationSubmitterClose.get(sr.InvitationId).add(sr.SubmitterId);
            }
            if (sr.Status == SURVEY_RESPONSE_STATUS_PAUSED) {
                if (!invitationSubmitterPaused.containsKey(sr.InvitationId)) {
                    invitationSubmitterPaused.put(sr.InvitationId, new List<Id>());
                }
                invitationSubmitterPaused.get(sr.InvitationId).add(sr.SubmitterId);
            }
        }

        taskStatusChanger(invitationSubmitterPaused, false);
        taskStatusChanger(invitationSubmitterClose, true);
    }

    @TestVisible
    public static void taskStatusChanger(Map<Id, List<Id>> invitationSubmitter, Boolean forFinish) {
        Map<Id, SurveyInvitation> invitationMap = new Map<Id, SurveyInvitation>(
            [
                SELECT
                    ExpireDateTime__c,
                    InviteExpiryDateTime,
                    Participant_Enrollment__r.Participant_Contact__c
                FROM SurveyInvitation
                WHERE Id IN :invitationSubmitter.keySet()
            ]
        );
        Set<Id> contactsIds = new Set<Id>();
        for (SurveyInvitation si : invitationMap.values()) {
            contactsIds.add(si.Participant_Enrollment__r.Participant_Contact__c);
            contactsIds.addAll(invitationSubmitter.get(si.Id));
        }

        List<Task> tasks = [
            SELECT Id, Status, Survey_Invitation__c, Visible_For__c, WhoId
            FROM Task
            WHERE
                WhoId IN :contactsIds
                AND Task_Type__c = :TaskService.TASK_TYPE_SURVEY
                AND Survey_Invitation__c IN :invitationMap.keySet()
        ];
        for (Task t : tasks) {
            SurveyInvitation invitation = invitationMap.get(t.Survey_Invitation__c);
            for (Id submitterId : invitationSubmitter.get(t.Survey_Invitation__c)) {
                if (t.WhoId == submitterId) {
                    if (forFinish) {
                        TaskService.getInstance().completeTask(t);
                        if (t.Visible_For__c.contains(TaskService.TASK_VISIBILITY_DELEGATES)) {
                            invitation.ExpireDateTime__c = System.now();
                            if (invitation.InviteExpiryDateTime != null)
                                invitation.InviteExpiryDateTime = null;
                        }
                    } else if (t.Status != TaskService.TASK_STATUS_COMPLETED) {
                        t.Status = TaskService.TASK_STATUS_IN_PROGRESS;
                    }
                    break;
                } else if (t.Visible_For__c.contains(TaskService.TASK_VISIBILITY_DELEGATES)) {
                    if (t.WhoId == invitation.Participant_Enrollment__r.Participant_Contact__c) {
                        if (forFinish) {
                            TaskService.getInstance().completeTask(t);
                            invitation.ExpireDateTime__c = System.now();
                            if (invitation.InviteExpiryDateTime != null)
                                invitation.InviteExpiryDateTime = null;
                        } else if (t.Status != TaskService.TASK_STATUS_COMPLETED) {
                            t.Status = TaskService.TASK_STATUS_IN_PROGRESS;
                        }
                        break;
                    }
                }
            }
        }
        if (forFinish)
            update invitationMap.values();

        System.debug('FOR ' + (forFinish ? 'COMPLETE' : 'PAUSE') + ' SIZE: ' + tasks.size());
        update tasks;
    }
}
