/**
 * Created by Leonid Bartenev
 */

public class SurveyResponseTriggerHandler {
    
    public static final String SURVEY_RESPONSE_STATUS_COMPLETED = 'Completed';
    public static final String SURVEY_RESPONSE_STATUS_PAUSED = 'Paused';
    
    // Handlers: -------------------------------------------------------------------------------------------------------
    
    public class ChangeCompleteSurveyTaskStatusHandler extends TriggerHandler{
        
        public override void afterInsert(List<SObject> newList) {
            changeCompleteSurveyTaskStatus(newList, null);
        }
        
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            changeCompleteSurveyTaskStatus(newList, (Map<Id, SurveyResponse>) oldMap);
        }
    }
    
    
    // Logic: ----------------------------------------------------------------------------------------------------------
    
    @TestVisible
    private static void changeCompleteSurveyTaskStatus(List<SurveyResponse> newList,  Map<Id, SurveyResponse> oldMap){
        List<Id> contactIdsForCloseTask = new List<Id>();
        List<Id> contactIdsForPauseTask = new List<Id>();
        for(SurveyResponse sr : newList){
            if(oldMap == null || (oldMap != null && oldMap.get(sr.Id).Status != sr.Status)){
                if(sr.Status == SURVEY_RESPONSE_STATUS_COMPLETED) {
                    contactIdsForCloseTask.add(sr.SubmitterId);
                }
                if(sr.Status == SURVEY_RESPONSE_STATUS_PAUSED){
                    contactIdsForPauseTask.add(sr.SubmitterId);
                }
            }
        }
    
        List<Task> tasksForComplete = [
                SELECT Id
                FROM Task
                WHERE WhoId IN: contactIdsForCloseTask
                AND Task_Code__c =: TaskService.TASK_CODE_COMPLETE_BASELINE_SURVEY
        ];
        for (Task t : tasksForComplete) TaskService.completeTask(t);
    
        System.debug('FOR COMPLETE SIZE: ' + tasksForComplete.size());
        update tasksForComplete;
    
        List<Task> tasksForPause = [
                SELECT Id
                FROM Task
                WHERE WhoId IN: contactIdsForPauseTask
                AND Task_Code__c =: TaskService.TASK_CODE_COMPLETE_BASELINE_SURVEY
        ];
        for (Task t : tasksForPause){
            t.Status = TaskService.TASK_STATUS_IN_PROGRESS;
        }
        System.debug('FOR PAUSE SIZE: ' + tasksForComplete.size());
        update tasksForPause;
    }
}