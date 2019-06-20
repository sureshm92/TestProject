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
                if(!invitationSubmitterClose.containsKey(sr.InvitationId)) invitationSubmitterClose.put(sr.InvitationId, new List<Id>());
                invitationSubmitterClose.get(sr.InvitationId).add(sr.SubmitterId);
            }
            if (sr.Status == SURVEY_RESPONSE_STATUS_PAUSED) {
                if(!invitationSubmitterPaused.containsKey(sr.InvitationId)) invitationSubmitterPaused.put(sr.InvitationId, new List<Id>());
                invitationSubmitterPaused.get(sr.InvitationId).add(sr.SubmitterId);
            }
        }

        Map<Id, SurveyInvitation> closeInv = new Map<Id, SurveyInvitation>([
                SELECT
                        InviteExpiryDateTime,
                        Participant_Study_Enrollment__r.Participant_Contact__c
                FROM SurveyInvitation
                WHERE Id IN:invitationSubmitterClose.keySet()
        ]);
        Set<Id> closeContactsIds = new Set<Id>();
        for(SurveyInvitation si : closeInv.values()) {
            closeContactsIds.add(si.Participant_Study_Enrollment__r.Participant_Contact__c);
            closeContactsIds.addAll(invitationSubmitterClose.get(si.Id));
        }

        List<Task> tasksForComplete = [
                SELECT
                        Id,
                        Description,
                        Visible_For__c,
                        WhoId
                FROM Task
                WHERE WhoId IN: closeContactsIds
                AND Task_Type__c =: TaskService.TASK_TYPE_SURVEY
        ];
        for(Task t : tasksForComplete) {
            if(invitationSubmitterClose.containsKey(t.Description)) {
                for(Id submitterId : invitationSubmitterClose.get(t.Description)) {
                    if(t.WhoId == submitterId) {
                        TaskService.getInstance().completeTask(t);
                        break;
                    } else if(t.Visible_For__c.contains(TaskService.TASK_VISIBILITY_DELEGATES)){
                        if(t.WhoId == closeInv.get(t.Description).Participant_Study_Enrollment__r.Participant_Contact__c) {
                            TaskService.getInstance().completeTask(t);
                            closeInv.get(t.Description).InviteExpiryDateTime = System.now();
                            break;
                        }
                    }
                }
            }
        }
        update closeInv.values();

        System.debug('FOR COMPLETE SIZE: ' + tasksForComplete.size());
        update tasksForComplete;

        Map<Id, SurveyInvitation> pausedInv = new Map<Id, SurveyInvitation>([
                SELECT Participant_Study_Enrollment__r.Participant_Contact__c
                FROM SurveyInvitation
                WHERE Id IN:invitationSubmitterPaused.keySet()
        ]);
        Set<Id> pausedContactsIds = new Set<Id>();
        for(SurveyInvitation si : pausedInv.values()) {
            pausedContactsIds.add(si.Participant_Study_Enrollment__r.Participant_Contact__c);
            pausedContactsIds.addAll(invitationSubmitterPaused.get(si.Id));
        }

        List<Task> tasksForPause = [
                SELECT Id, Description, WhoId
                FROM Task
                WHERE WhoId IN: pausedContactsIds
                AND Task_Type__c = :TaskService.TASK_TYPE_SURVEY
        ];
        for (Task t : tasksForPause) {
            if (invitationSubmitterPaused.containsKey(t.Description)) {
                for(Id submitterId : invitationSubmitterPaused.get(t.Description)) {
                    if(t.WhoId == submitterId) {
                        t.Status = TaskService.TASK_STATUS_IN_PROGRESS;
                        break;
                    } else if(t.Visible_For__c.contains(TaskService.TASK_VISIBILITY_DELEGATES)) {
                        if(t.WhoId == pausedInv.get(t.Description).Participant_Study_Enrollment__r.Participant_Contact__c) {
                            t.Status = TaskService.TASK_STATUS_IN_PROGRESS;
                            break;
                        }
                    }
                }
            }
        }

        System.debug('FOR PAUSE SIZE: ' + tasksForComplete.size());
        update tasksForPause;
    }
}