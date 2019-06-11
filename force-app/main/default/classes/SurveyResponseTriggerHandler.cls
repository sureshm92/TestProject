/**
 * Created by Leonid Bartenev
 */

public without sharing class SurveyResponseTriggerHandler {

    public static final String SURVEY_RESPONSE_STATUS_COMPLETED = 'Completed';
    public static final String SURVEY_RESPONSE_STATUS_PAUSED = 'Paused';

    @InvocableMethod(Label='Handle Suvey Response status Change')
    public static void handleStatusChange(List<SurveyResponse> srList) {
        Map<String, SurveyResponse> submitterResponse = new Map<String, SurveyResponse>();
        List<Id> contactIdsForCloseTask = new List<Id>();
        List<Id> contactIdsForPauseTask = new List<Id>();
        for (SurveyResponse sr : srList) {
            submitterResponse.put(sr.SubmitterId, sr);
            if (sr.Status == SURVEY_RESPONSE_STATUS_COMPLETED) {
                contactIdsForCloseTask.add(sr.SubmitterId);
            }
            if (sr.Status == SURVEY_RESPONSE_STATUS_PAUSED) {
                contactIdsForPauseTask.add(sr.SubmitterId);
            }
        }

        List<Task> tasksForComplete = [
                SELECT Id, Description, WhoId
                FROM Task
                WHERE WhoId IN:contactIdsForCloseTask
                AND Task_Type__c = :TaskService.TASK_TYPE_SURVEY
        ];
        for (Task t : tasksForComplete) {
            SurveyResponse response = submitterResponse.get(t.WhoId);
            if (t.Description == SurveyService.getInstance().getSurveyInvitationId(response.SurveyId, response.SubmitterId)) {
                TaskService.getInstance().completeTask(t);
            }
        }

        System.debug('FOR COMPLETE SIZE: ' + tasksForComplete.size());
        update tasksForComplete;

        List<Task> tasksForPause = [
                SELECT Id, Description, WhoId
                FROM Task
                WHERE WhoId IN:contactIdsForPauseTask
                AND Task_Type__c = :TaskService.TASK_TYPE_SURVEY
        ];
        for (Task t : tasksForPause) {
            SurveyResponse response = submitterResponse.get(t.WhoId);
            if (t.Description == SurveyService.getInstance().getSurveyInvitationId(response.SurveyId, response.SubmitterId)) {
                t.Status = TaskService.TASK_STATUS_IN_PROGRESS;
            }
        }
        System.debug('FOR PAUSE SIZE: ' + tasksForComplete.size());
        update tasksForPause;
    }

}