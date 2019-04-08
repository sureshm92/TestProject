/**
 * Created by Leonid Bartenev
 */

trigger SurveyResponseTrigger on SurveyResponse (after insert, after update) {
    
    List<Id> contactIdsForCloseTask = new List<Id>();
    List<Id> contactIdsForPauseTask = new List<Id>();
    for(SurveyResponse sr : Trigger.new){
        if(Trigger.isInsert || (Trigger.isUpdate && Trigger.oldMap.get(sr.Id).Status != sr.Status)){
            if(sr.Status == 'Completed') {
                contactIdsForCloseTask.add(sr.SubmitterId);
            }
            if(sr.Status == 'Paused'){
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
    for (Task t : tasksForComplete){
        t.Status = TaskService.TASK_STATUS_COMPLETED;
    }
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
    update tasksForPause;
}