/**
 * Created by Leonid Bartenev
 */

public without sharing class TaskService {
    
    public class TaskServiceException extends Exception{}
    
    public static final String TASK_TYPE_MEDICATION = 'Medication';
    public static final String TASK_TYPE_VISIT = 'Visit';
    
    public static final List<String> DEFAULT_FIELDS = new List<String>{
            'Id',
            'Status',
            'Subject',
            'Description',
            'Priority',
            'OwnerId',
            'CreatedById',
            'CreatedDate',
            'Completed_Date__c',
            'ActivityDate',
            'Task_Code__c',
            'WhatId',
            'Task_Type__c',
            'Visible_For__c'
    };
    
    public static List<Task> getTasksCommon(String filter){
        String ownerFilter;
        if(!ParticipantService.getParticipantState().isDelegate){
            ownerFilter = ' OwnerId = \'' + UserInfo.getUserId() + '\'';
        } else {
            ownerFilter = ' OwnerId = \'' + PatientDelegateService.getDelegatePatientUserId() + '\'';
        }
        if(filter == null) {
            filter = ownerFilter;
        }else{
            filter = ownerFilter + ' AND ' + filter;
        }
        String query = 'SELECT ' + String.join(DEFAULT_FIELDS, ',') + ' FROM Task WHERE ' + filter;
        System.debug(query);
        List<Task> tasks = Database.query(query);
        TaskTriggerHandler.processDefaultFieldValues(tasks);
        return tasks;
    }
    
    public static List<Task> getOpenTasks() {
        return getTasksCommon(' Status=\'Open\'' + getVisibilityFilter() + ' ORDER BY Priority, ActivityDate NULLS LAST, CreatedDate');
    }

    private static String getVisibilityFilter(){
        String role = ParticipantService.getParticipantState().isDelegate ? 'Delegates' : 'Owner';
        return ' AND Visible_For__c INCLUDES (\'' + role + '\') ';
    }
    
    public static List<Task> getPreviewTasks(){
        return getTasksCommon(' Status=\'Open\' AND CreatedById != \'' + UserInfo.getUserId()  + '\' ORDER BY Priority DESC, CreatedDate DESC LIMIT 5 ');
    }
    
    public static Task getTask(Id taskId){
        List<Task> tasks = getTasksCommon(' Id = \'' + taskId + '\' ');
        if(tasks.size() == 0) throw new TaskServiceException('Task not found: ' + taskId);
        return tasks[0];
    }
    
    public static List<Task> getCompletedTasks(){
        return getTasksCommon(' Status IN (\'Completed\', \'Ignored\')' + getVisibilityFilter() + ' ORDER BY Completed_Date__c DESC');
    }
    
    public static void ignoreTask(Id taskId){
        Task task = getTask(taskId);
        task.Status = 'Ignored';
        task.Completed_Date__c = Datetime.now();
        update task;
    }
    
    public static void completeTask(Id taskId){
        Task task = getTask(taskId);
        task.Status = 'Completed';
        task.Completed_Date__c = Datetime.now();
        update task;
    }
 
}