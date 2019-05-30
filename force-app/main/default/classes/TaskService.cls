/**
 * Created by Leonid Bartenev
 */

public without sharing class TaskService {

    public class TaskServiceException extends Exception {
    }

    public static final String TASK_STATUS_OPEN = 'Open';
    public static final String TASK_STATUS_COMPLETED = 'Completed';
    public static final String TASK_STATUS_IN_PROGRESS = 'In Progress';
    public static final String TASK_STATUS_IGNORED = 'Ignored';
    public static final String TASK_STATUS_EXPIRED = 'Expired';

    public static final String TASK_PRIORITY_NORMAL = 'Normal';
    public static final String TASK_PRIORITY_CRITICAL = 'Critical';

    public static final String TASK_VISIBILITY_OWNER = 'Owner';
    public static final String TASK_VISIBILITY_DELEGATES = 'Delegates';

    public static final String TASK_TYPE_MEDICATION = 'Medication';
    public static final String TASK_TYPE_VISIT = 'Visit';
    public static final String TASK_TYPE_SURVEY = 'Survey';

    public static final String TASK_CODE_COMPLETE_SURVEY = 'Complete_Survey';
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
            'Action_URL__c',
            'Reminder_Date__c',
            'Originator__c'
    };

    public static final List<String> TASK_STATUS_GROUP_EXPIRE_AVAILABLE = new List<String> {
            TASK_STATUS_OPEN,
            TASK_STATUS_IGNORED,
            TASK_STATUS_IN_PROGRESS
    };

    private static TaskService instance;

    public static TaskService getInstance() {
        if (instance == null) instance = new TaskService();
        return instance;
    }

    /*private TaskService(){
        //lock Task Service Constructor outside
    }*/

    public static void setMock(StubProvider mock) {
        instance = (TaskService) Test.createStub(TaskService.class, mock);
    }

    public List<Task> getTasksCommon(String filter) {
        String ownerFilter;
        if (!ParticipantService.getInstance().getState().isDelegate) {
            ownerFilter = ' OwnerId = \'' + UserInfo.getUserId() + '\'';
        } else {
            ownerFilter = ' OwnerId = \'' + PatientDelegateService.getInstance().getParticipantUserId() + '\'';
        }
        if (filter == null) {
            filter = ownerFilter;
        } else {
            filter = ownerFilter + ' AND ' + filter;
        }
        String query = 'SELECT ' + String.join(DEFAULT_FIELDS, ',') + ' FROM Task WHERE ' + filter;
        System.debug(query);
        List<Task> tasks = (List<Task>) DatabaseService.query(query);
        TaskTriggerHandler.processDefaultFieldValues(tasks);
        return tasks;
    }

    public List<Task> getOpenTasks() {
        return getTasksCommon(getOpenTasksFilter() + getVisibilityFilter() + OPEN_TASKS_ORDER);
    }

    public List<Task> getPreviewTasks() {
        return getTasksCommon(getOpenTasksFilter() + getVisibilityFilter() + OPEN_TASKS_ORDER + ' LIMIT 5');
    }

    public Task getTask(Id taskId) {
        List<Task> tasks = getTasksCommon(' Id = \'' + taskId + '\' ');
        if (tasks.size() == 0) throw new TaskServiceException('Task not found: ' + taskId);
        return tasks[0];
    }

    public List<Task> getCompletedTasks() {
        return getTasksCommon(getCompletedTasksFilter() + getVisibilityFilter() + ' ORDER BY Completed_Date__c DESC');
    }

    public void ignoreTask(Id taskId) {
        Task task = getTask(taskId);
        task.Status = TASK_STATUS_IGNORED;
        task.Completed_Date__c = Datetime.now();
        update task;
    }

    public void completeTask(Id taskId) {
        Task task = getTask(taskId);
        completeTask(task);
        update task;
    }

    public void completeTask(Task task) {
        task.Status = TASK_STATUS_COMPLETED;
        task.Completed_Date__c = Datetime.now();
    }

    public void createSurveyTasks(List<SurveyInvitation> invitations) {
        List<SurveyInvitation> surveyInvitation = [
                SELECT
                        CreatedDate,
                        Id,
                        InvitationLink,
                        InviteExpiryDateTime,
                        Name,
                        OwnerId,
                        Participant_Study_Enrollment__c,
                        ParticipantId,
                        SurveyId,
                        Survey.Name,
                        Trial_Survey__c
                FROM SurveyInvitation
                WHERE Id IN:invitations
        ];

        Set<Id> contactIds = new Set<Id>();
        for(SurveyInvitation inv : surveyInvitation) contactIds.add(inv.ParticipantId);

        List<User> users = [
                SELECT Id, ContactId
                FROM User
                WHERE ContactId IN: contactIds
                AND IsActive = TRUE
        ];

        Map<Id, User> usersMap = new Map<Id, User>();
        for(User u : users) usersMap.put(u.ContactId, u);

        List<Task> tasks = new List<Task>();
        for(SurveyInvitation inv : surveyInvitation) {
            User owner =  usersMap.get(inv.ParticipantId);
            if(owner != null) tasks.add(createCompleteSurveyTask(owner.Id, inv));
        }

        insert tasks;
    }

    public Task createCompleteSurveyTask(Id ownerId, SurveyInvitation invitation) {
        String subject = Label.Task_Subject_Complete_Survey.replace('##SurveyName', invitation.Survey.Name);
        Date showDate = Date.newInstance(
                invitation.CreatedDate.year(),
                invitation.CreatedDate.month(),
                invitation.CreatedDate.day()
        );

        Task task = new Task(
                Description = invitation.Id,
                OwnerId = ownerId,
                Subject = subject,
                Priority = TaskService.TASK_PRIORITY_CRITICAL,
                Start_Date__c = showDate,
                Status = TASK_STATUS_OPEN,
                Task_Code__c = TASK_CODE_COMPLETE_SURVEY,
                Reminder_Date__c = showDate,
                Task_Type__c = TASK_TYPE_SURVEY,
                Visible_For__c = TASK_VISIBILITY_OWNER,
                WhoId = invitation.ParticipantId

        );
        if (invitation.InviteExpiryDateTime != null) {
            task.ActivityDate = Date.newInstance(
                    invitation.InviteExpiryDateTime.year(),
                    invitation.InviteExpiryDateTime.month(),
                    invitation.InviteExpiryDateTime.day()
            );
        }

        return task;
    }

    public Task createCompleteYourProfileTask(Id ownerId, Id participantId, Id participantContactId) {
        return new Task(
                OwnerId = ownerId,
                Subject = TaskService.TASK_CODE_COMPLETE_YOUR_PROFILE,
                Task_Code__c = TaskService.TASK_CODE_COMPLETE_YOUR_PROFILE,
                Status = TASK_STATUS_OPEN,
                Priority = TASK_PRIORITY_CRITICAL,
                WhatId = participantId,
                WhoId = participantContactId,
                Visible_For__c = TASK_VISIBILITY_OWNER
        );
    }

    private String getVisibilityFilter() {
        String role = ParticipantService.getParticipantState().isDelegate ? 'Delegates' : 'Owner';
        return ' AND Visible_For__c INCLUDES (\'' + role + '\') ';
    }

    public String getOpenTasksFilter() {
        List<String> statusFilter = new List<String>{
                TASK_STATUS_OPEN,
                TASK_STATUS_IN_PROGRESS
        };
        return ' Status IN (\'' + String.join(statusFilter, '\',\'') + '\') ';
    }

    public void completeCYPTaskForParticipant() {
        List<Task> tasks = getTasksCommon('Task_Code__c =\'' +
                TASK_CODE_COMPLETE_YOUR_PROFILE + '\' AND ' + getOpenTasksFilter());
        if (tasks.size() > 0) {
            completeTask(tasks[0]);
            update tasks[0];
        }
    }

    private String getCompletedTasksFilter() {
        List<String> statusFilter = new List<String>{
                TASK_STATUS_IGNORED,
                TASK_STATUS_COMPLETED
        };
        return ' Status IN (\'' + String.join(statusFilter, '\',\'') + '\') ';
    }


}