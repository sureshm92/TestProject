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

    public static final String TASK_VISIBILITY_ALL = 'Owner;Delegates';
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
            'Originator__c',
            'Patient_Visit__c',
            'Is_Reminder_Sent__c'
    };

    public static final List<String> TASK_STATUS_GROUP_EXPIRE_AVAILABLE = new List<String>{
            TASK_STATUS_OPEN,
            TASK_STATUS_IGNORED,
            TASK_STATUS_IN_PROGRESS
    };

    public static final List<String> TASK_STATUS_GROUP_AVAILABLE = new List<String>{
            TASK_STATUS_OPEN,
            TASK_STATUS_IN_PROGRESS
    };

    private static TaskService instance;

    public static TaskService getInstance() {
        if (instance == null) instance = new TaskService();
        return instance;
    }

    public static void setMock(StubProvider mock) {
        instance = (TaskService) Test.createStub(TaskService.class, mock);
    }

    public List<Task> getTasksCommon(String filter) {
        List<Task> tasks = new List<Task>();
        String query = 'SELECT ' + String.join(DEFAULT_FIELDS, ',') + ' FROM Task WHERE ';
        String ownerFilter = 'OwnerId = \'' + UserInfo.getUserId() + '\'';

        String queryFilter;
        if (filter == null) {
            queryFilter = ownerFilter;
        } else {
            queryFilter = ownerFilter + ' AND '
                    + filter.replace('\'' + TASK_VISIBILITY_DELEGATES + '\'', '\'' + TASK_VISIBILITY_OWNER + '\'');
        }
        System.debug('getTaskCommonOwner: ' + query + queryFilter);
        tasks.addAll((List<Task>) DatabaseService.query(query + queryFilter));

        Boolean isDelegate = ParticipantService.getInstance().getState().isDelegate;
        if(isDelegate) {
            ownerFilter = 'OwnerId = \'' + PatientDelegateService.getInstance().getParticipantUserId() + '\'';
            if(filter == null) {
                queryFilter = ownerFilter;
            } else {
                queryFilter = ownerFilter + ' AND ' + filter;
            }
            System.debug('getTaskCommonDelegate: ' + query + queryFilter);
            tasks.addAll((List<Task>) DatabaseService.query(query + queryFilter));
        }

        TaskTriggerHandler.processDefaultFieldValues(tasks);
        return tasks;
    }

    public List<Task> getCompletedTasks() {
        return getTasksCommon(getCompletedTasksFilter() + getVisibilityFilter() + ' ORDER BY Completed_Date__c DESC');
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

    public void createSurveyTasks(Map<Id, String> invitationsVisible) {
        List<SurveyInvitation> surveyInvitation = [
                SELECT
                        Id,
                        InviteExpiryDateTime,
                        Participant_Enrollment__r.Participant_Contact__c,
                        Reminder_Schedule__c,
                        Reminder_Schedule__r.First_Reminder_day__c,
                        Survey.Name
                FROM SurveyInvitation
                WHERE Id IN:invitationsVisible.keySet()
        ];

        Set<Id> contactIds = new Set<Id>();
        Set<Id> delContactIds = new Set<Id>();
        for (SurveyInvitation inv : surveyInvitation) {
            Id partContactId = inv.Participant_Enrollment__r.Participant_Contact__c;
            contactIds.add(partContactId);
            delContactIds.addAll(PatientDelegateService.getDelegatedContactIds(partContactId));
        }

        Map<Id, Id> participantContactUser = getContactUserIdsMap(contactIds);
        Map<Id, Id> delContactUser = getContactUserIdsMap(delContactIds);
        Map<Id, Id> userContact = new Map<Id, Id>();

        Set<Id> allContacts = new Set<Id>();
        allContacts.addAll(contactIds);
        allContacts.addAll(delContactIds);
        Map<Id, TimeZone> userTimezoneMap = getUserTimezoneMap(allContacts);

        List<TaskConfig> taskConfigs = new List<TaskConfig>();
        for (SurveyInvitation inv : surveyInvitation) {
            Id partContactId = inv.Participant_Enrollment__r.Participant_Contact__c;
            Id partUserId = participantContactUser.get(partContactId);
            userContact.put(partUserId, partContactId);
            List<Id> patientDelContactIds = PatientDelegateService.getDelegatedContactIds(partContactId);

            List<TaskConfig> tmpConfigs = new List<TaskConfig>();
            String visible = invitationsVisible.get(inv.Id);
            switch on visible {
                when 'Patient only', 'Patient or any Delegate', 'Any Delegate' {
                    tmpConfigs.add(new TaskConfig(partUserId));
                }
                when 'Each Delegate' {
                    for (Id pdId : patientDelContactIds) {
                        tmpConfigs.add(new TaskConfig(delContactUser.get(pdId)));
                        userContact.put(delContactUser.get(pdId), pdId);
                    }
                }
                when 'Patient and each Delegate' {
                    tmpConfigs.add(new TaskConfig(partUserId));
                    for (Id pdId : patientDelContactIds) {
                        tmpConfigs.add(new TaskConfig(delContactUser.get(pdId)));
                        userContact.put(delContactUser.get(pdId), pdId);
                    }
                }
            }

            String subject = Label.Task_Subject_Complete_Survey.replace('##SurveyName', inv.Survey.Name);
            for (TaskConfig tsc : tmpConfigs) {
                tsc.code = TASK_CODE_COMPLETE_SURVEY;
                tsc.description = inv.Id;
                tsc.priority = TASK_PRIORITY_CRITICAL;
                tsc.reminderSchedule = inv.Reminder_Schedule__c;
                tsc.startDate = getUserDatetime(userTimezoneMap.get(tsc.ownerId), null).date();
                if (inv.InviteExpiryDateTime != null) {
                    Date expiryDate= inv.InviteExpiryDateTime.date();
                    Integer daysBetween = expiryDate.daysBetween(Date.today());
                    tsc.activityDate = tsc.startDate.addDays(daysBetween);
                }

                if (inv.Reminder_Schedule__r.First_Reminder_day__c != null) {
                    Integer firstReminderDay = (Integer) inv.Reminder_Schedule__r.First_Reminder_day__c;
                    tsc.reminderDatetime = getUserDatetime(userTimezoneMap.get(tsc.ownerId), null).addDays(firstReminderDay);
                }
                tsc.subject = subject;
                tsc.type = TASK_TYPE_SURVEY;
                tsc.visibility = SurveyService.SURVEY_VISIBLE.get(visible);
                tsc.whoId = userContact.get(tsc.ownerId);
            }
            taskConfigs.addAll(tmpConfigs);
        }

        List<Task> tasks = new List<Task>();
        for (TaskConfig taskConfig : taskConfigs) tasks.add(createTask(taskConfig));

        insert tasks;
        System.debug('Task inserted: ' + tasks.size());
    }

    public Task createTask(TaskConfig taskConfig) {
        Task task = new Task(
                OwnerId = taskConfig.ownerId,
                Priority = taskConfig.priority,
                Status = taskConfig.status,
                Subject = taskConfig.subject,
                Visible_For__c = taskConfig.visibility
        );

        if (taskConfig.activityDate != null) task.ActivityDate = taskConfig.activityDate;
        if (taskConfig.code != null) task.Task_Code__c = taskConfig.code;
        if (taskConfig.description != null) task.Description = taskConfig.description;
        if (taskConfig.originator != null) task.Originator__c = taskConfig.originator;
        if (taskConfig.reminderDatetime != null) task.Reminder_Date__c = taskConfig.reminderDatetime;
        if (taskConfig.reminderSchedule != null) task.Reminder_Schedule__c = taskConfig.reminderSchedule;
        if (taskConfig.startDate != null) task.Start_Date__c = taskConfig.startDate;
        if (taskConfig.type != null) task.Task_Type__c = taskConfig.type;
        if (taskConfig.whatId != null) task.WhatId = taskConfig.whatId;
        if (taskConfig.whoId != null) task.WhoId = taskConfig.whoId;

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
        String role = ParticipantService.getParticipantState().isDelegate ? TASK_VISIBILITY_DELEGATES : TASK_VISIBILITY_OWNER;
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
        return ' (Status IN (\'' + String.join(statusFilter, '\',\'') + '\') ' +
               'OR (Status = \'' + TASK_STATUS_EXPIRED + '\' AND Task_Type__c = \'' + TASK_TYPE_SURVEY + '\')) ';
    }

    public Map<Id, Id> getContactUserIdsMap(Set<Id> contactIds) {
        List<User> users = [
                SELECT Id, ContactId
                FROM User
                WHERE ContactId IN:contactIds
                AND IsActive = TRUE
        ];
        Map<Id, Id> contactUserMap = new Map<Id, Id>();
        for (User u : users) contactUserMap.put(u.ContactId, u.Id);

        return contactUserMap;
    }

    public static Map<Id, TimeZone> getUserTimezoneMap(Set<Id> contactIds) {
        List<User> users = [
                SELECT Id, TimeZoneSidKey
                FROM User
                WHERE ContactId IN:contactIds
                AND IsActive = TRUE
        ];
        Map<Id, TimeZone> userMap = new Map<Id, TimeZone>();
        for (User u : users) userMap.put(u.Id, TimeZone.getTimeZone(u.TimeZoneSidKey));

        return userMap;
    }

    public static Datetime getUserDatetime(TimeZone timezone, Datetime moment) {
        if(moment == null) moment = Datetime.now();

        String nowFormat = moment.format('YYYY-MM-dd HH:mm:ss', timezone.toString());
        return Datetime.valueOfGmt(nowFormat);
    }

    public class TaskConfig {
        public Date activityDate;
        public String code;
        public String description;
        public String originator;
        public Id ownerId;
        public String priority;
        public Datetime reminderDatetime;
        public Id reminderSchedule;
        public Date startDate;
        public String status;
        public String subject;
        public String type;
        public String visibility;
        public String whatId;
        public String whoId;

        public TaskConfig(Id ownerId) {
            this.ownerId = ownerId;

            priority = TASK_PRIORITY_NORMAL;
            status = TASK_STATUS_OPEN;
            subject = 'Empty';
            visibility = TASK_VISIBILITY_OWNER;
        }

        public TaskConfig(Id ownerId, String subject, String visibility) {
            this(ownerId);

            this.subject = subject;
            this.visibility = visibility;
        }
    }
}