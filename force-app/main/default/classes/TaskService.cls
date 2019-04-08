/**
 * Created by Leonid Bartenev
 */

public without sharing class TaskService {
    
    public class TaskServiceException extends Exception{}
    
    public static final String TASK_STATUS_OPEN = 'Open';
    public static final String TASK_STATUS_COMPLETED = 'Completed';
    public static final String TASK_STATUS_IN_PROGRESS = 'In Progress';
    public static final String TASK_STATUS_IGNORED = 'Ignored';
    
    public static final String TASK_PRIORITY_NORMAL = 'Normal';
    public static final String TASK_PRIORITY_CRITICAL = 'Critical';
    
    public static final String TASK_VISIBILITY_OWNER = 'Owner';
    public static final String TASK_VISIBILITY_DELEGATE = 'Delegate';
    
    public static final String TASK_TYPE_MEDICATION = 'Medication';
    public static final String TASK_TYPE_VISIT = 'Visit';
    
    public static final String TASK_CODE_COMPLETE_BASELINE_SURVEY = 'Complete_Baseline_Survey';
    public static final String TASK_CODE_COMPLETE_YOUR_PROFILE = 'Complete_Your_Profile';
    
    public static final String OPEN_TASKS_ORDER = ' ORDER BY Priority DESC, ActivityDate NULLS LAST, CreatedDate DESC';
    
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
            'Visible_For__c',
            'Action_URL__c'
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
        return getTasksCommon(getOpenTasksFilter() + getVisibilityFilter() + OPEN_TASKS_ORDER);
    }

    public static List<Task> getPreviewTasks(){
        return getTasksCommon(getOpenTasksFilter() + getVisibilityFilter() +
                ' AND CreatedById != \'' + UserInfo.getUserId()  + '\' ' + OPEN_TASKS_ORDER + ' LIMIT 5');
    }
    
    public static Task getTask(Id taskId){
        List<Task> tasks = getTasksCommon(' Id = \'' + taskId + '\' ');
        if(tasks.size() == 0) throw new TaskServiceException('Task not found: ' + taskId);
        return tasks[0];
    }
    
    public static List<Task> getCompletedTasks(){
        List<String> statusFilter = new List<String>{
                TASK_STATUS_IGNORED,
                TASK_STATUS_COMPLETED
        };
        return getTasksCommon(getCompletedTasksFilter() + getVisibilityFilter() + ' ORDER BY Completed_Date__c DESC');
    }
    
    public static void ignoreTask(Id taskId){
        Task task = getTask(taskId);
        task.Status = TASK_STATUS_IGNORED;
        task.Completed_Date__c = Datetime.now();
        update task;
    }
    
    public static void completeTask(Id taskId){
        Task task = getTask(taskId);
        task.Status = TASK_STATUS_COMPLETED;
        task.Completed_Date__c = Datetime.now();
        update task;
    }
    
    
    public static Task createCompleteBaselineSurveyTask(Id ownerId){
        return new Task(
                OwnerId = ownerId,
                Subject = TaskService.TASK_CODE_COMPLETE_BASELINE_SURVEY,
                Task_Code__c = TaskService.TASK_CODE_COMPLETE_BASELINE_SURVEY,
                Status = TASK_STATUS_OPEN,
                Priority = TASK_PRIORITY_CRITICAL,
                ActivityDate = Date.today().addDays(3),
                Visible_For__c = TASK_VISIBILITY_OWNER
        );
    }
    
    public static Task createCompleteYourProfileTask(Id ownerId, Id participantId, Id participantContactId){
        return new Task(
                OwnerId = ownerId,
                Subject = TaskService.TASK_CODE_COMPLETE_YOUR_PROFILE,
                Task_Code__c = TaskService.TASK_CODE_COMPLETE_YOUR_PROFILE,
                Status = TASK_STATUS_OPEN,
                Priority = TASK_PRIORITY_CRITICAL,
                WhatId = participantId,
                WhoId = participantContactId,
                ActivityDate = Date.today().addDays(3),
                Visible_For__c = TASK_VISIBILITY_OWNER
        );
    }
    
    private static String getVisibilityFilter(){
        String role = ParticipantService.getParticipantState().isDelegate ? 'Delegates' : 'Owner';
        return ' AND Visible_For__c INCLUDES (\'' + role + '\') ';
    }
    
    private static String getOpenTasksFilter(){
        List<String> statusFilter = new List<String>{
                TASK_STATUS_OPEN,
                TASK_STATUS_IN_PROGRESS
        };
        return ' Status IN (\'' + String.join(statusFilter, '\',\'') +  '\') ';
    }
    
    private static String getCompletedTasksFilter(){
        List<String> statusFilter = new List<String>{
                TASK_STATUS_IGNORED,
                TASK_STATUS_COMPLETED
        };
        return ' Status IN (\'' + String.join(statusFilter, '\',\'') +  '\') ';
        
    }



}