/**
 * Created by Leonid Bartenev
 */

public without sharing class SurveyResponseTriggerHandler {

    public static final String SURVEY_RESPONSE_STATUS_COMPLETED = 'Completed';
    public static final String SURVEY_RESPONSE_STATUS_PAUSED = 'Paused';

    @InvocableMethod(Label='Handle Suvey Response status Change')
    public static void handleStatusChange(List<SurveyResponse> srList) {
        Set<Id> invitationsClose = new Set<Id>();
        Set<Id> invitationsPaused = new Set<Id>();

        for (SurveyResponse sr : srList) {
            if (sr.Status == SURVEY_RESPONSE_STATUS_COMPLETED) {
                invitationsClose.add(sr.InvitationId);
            }
            if (sr.Status == SURVEY_RESPONSE_STATUS_PAUSED) {
                invitationsPaused.add(sr.InvitationId);
            }
        }

        List<SurveyInvitation> closeInv = [
                SELECT Participant_Study_Enrollment__r.Participant_Contact__c
                FROM SurveyInvitation
                WHERE Id IN:invitationsClose
        ];
        Set<Id> closeContactsIds = new Set<Id>();
        for(SurveyInvitation si : closeInv) {
            closeContactsIds.add(si.Participant_Study_Enrollment__r.Participant_Contact__c);
        }

        List<Task> tasksForComplete = [
                SELECT Id, Description, WhoId
                FROM Task
                WHERE WhoId IN: closeContactsIds
                AND Task_Type__c = :TaskService.TASK_TYPE_SURVEY
        ];
        for (Task t : tasksForComplete) {
            if(invitationsClose.contains(t.Description)) TaskService.getInstance().completeTask(t);
        }

        System.debug('FOR COMPLETE SIZE: ' + tasksForComplete.size());
        update tasksForComplete;


        List<SurveyInvitation> pausedInv = [
                SELECT Participant_Study_Enrollment__r.Participant_Contact__c
                FROM SurveyInvitation
                WHERE Id IN:invitationsPaused
        ];
        Set<Id> pausedContactsIds = new Set<Id>();
        for(SurveyInvitation si : closeInv) {
            pausedContactsIds.add(si.Participant_Study_Enrollment__r.Participant_Contact__c);
        }

        List<Task> tasksForPause = [
                SELECT Id, Description, WhoId
                FROM Task
                WHERE WhoId IN: pausedContactsIds
                AND Task_Type__c = :TaskService.TASK_TYPE_SURVEY
        ];
        for (Task t : tasksForPause) {
            if (invitationsPaused.contains(t.Description)) t.Status = TaskService.TASK_STATUS_IN_PROGRESS;
        }
        System.debug('FOR PAUSE SIZE: ' + tasksForComplete.size());
        update tasksForPause;
    }
}