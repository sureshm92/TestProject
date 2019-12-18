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
    public static final String TASK_TYPE_NOT_SELECTED = 'Not Selected';

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
            'Activity_Datetime__c',
            'Task_Code__c',
            'WhatId',
            'Task_Type__c',
            'Visible_For__c',
            'Action_URL__c',
            'ReminderDateTime',
            'Reminder_Date__c',
            'Originator__c',
            'Patient_Visit__c',
            'Is_Reminder_Sent__c',
            'Survey_Invitation__c',
            'Survey_Invitation__r.Is_Expired__c'
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
        if (isDelegate) {
            ownerFilter = 'OwnerId = \'' + PatientDelegateService.getInstance().getParticipantUserId() + '\'';
            if (filter == null) {
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
        return filterCurrentStudyTasks(getTasksCommon(getCompletedTasksFilter() + getVisibilityFilter() + ' ORDER BY Completed_Date__c DESC'));
    }

    public List<Task> getOpenTasks() {
        return filterCurrentStudyTasks(getTasksCommon(getOpenTasksFilter() + getVisibilityFilter() + OPEN_TASKS_ORDER));
    }

    public List<Task> getPreviewTasks() {
        return filterCurrentStudyTasks(getTasksCommon(getOpenTasksFilter() + getVisibilityFilter() + OPEN_TASKS_ORDER + ' LIMIT 5'));
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

    public Integer createSurveyTasks(Map<Id, String> invitationsVisible) {
        List<SurveyInvitation> surveyInvitation = [
                SELECT
                        Id,
                        ExpireDateTime__c,
                        Participant_Enrollment__r.Participant_Contact__c,
                        Reminder_Schedule__c,
                        Reminder_Schedule__r.First_Reminder_day__c,
                        Survey.Name
                FROM SurveyInvitation
                WHERE Id IN:invitationsVisible.keySet()
        ];

        Set<Id> contactIds = new Set<Id>();
        for (SurveyInvitation inv : surveyInvitation) contactIds.add(inv.Participant_Enrollment__r.Participant_Contact__c);

        List<Patient_Delegate__c> patientDelegates = [
                SELECT Id,
                        Contact__c,
                        Participant__r.Contact__c
                FROM Patient_Delegate__c
                WHERE Participant__r.Contact__c IN:contactIds
        ];
        Set<Id> delContactIds = new Set<Id>();
        Map<Id, Set<Id>> delegatesByParticipant = new Map<Id, Set<Id>>();
        for (Patient_Delegate__c pd : patientDelegates) {
            if (!delegatesByParticipant.containsKey(pd.Participant__r.Contact__c)) {
                delegatesByParticipant.put(pd.Participant__r.Contact__c, new Set<Id>());
            }
            delegatesByParticipant.get(pd.Participant__r.Contact__c).add(pd.Contact__c);
            delContactIds.add(pd.Contact__c);
        }

        Map<Id, Id> participantContactUser = getContactUserIdsMap(contactIds);
        Map<Id, Id> delContactUser = getContactUserIdsMap(delContactIds);
        Map<Id, Id> userContact = new Map<Id, Id>();

        Set<Id> allContacts = new Set<Id>();
        allContacts.addAll(contactIds);
        allContacts.addAll(delContactIds);
        Map<Id, TimeZone> userTimezoneMap = DateTimeConverterUtil.getUsersTimezoneMap(allContacts);

        List<TaskConfig> taskConfigs = new List<TaskConfig>();
        for (SurveyInvitation inv : surveyInvitation) {
            Id partContactId = inv.Participant_Enrollment__r.Participant_Contact__c;
            Id partUserId = participantContactUser.get(partContactId);
            if (partUserId == null) continue;

            userContact.put(partUserId, partContactId);
            Set<Id> patientDelContactIds = delegatesByParticipant.containsKey(partContactId)
                    ? delegatesByParticipant.get(partContactId) : new Set<Id>();

            List<TaskConfig> tmpConfigs = new List<TaskConfig>();
            String visible = invitationsVisible.get(inv.Id);
            switch on visible {
                when 'Patient only', 'Patient or any Delegate', 'Any Delegate' {
                    tmpConfigs.add(new TaskConfig(partUserId));
                }
                when 'Each Delegate' {
                    for (Id pdId : patientDelContactIds) {
                        if (delContactUser.get(pdId) == null) continue;

                        tmpConfigs.add(new TaskConfig(delContactUser.get(pdId)));
                        userContact.put(delContactUser.get(pdId), pdId);
                    }
                }
                when 'Patient and each Delegate' {
                    tmpConfigs.add(new TaskConfig(partUserId));
                    for (Id pdId : patientDelContactIds) {
                        if (delContactUser.get(pdId) == null) continue;

                        tmpConfigs.add(new TaskConfig(delContactUser.get(pdId)));
                        userContact.put(delContactUser.get(pdId), pdId);
                    }
                }
            }

            String subject = Label.Task_Subject_Complete_Survey.replace('##SurveyName', inv.Survey.Name);
            for (TaskConfig tsc : tmpConfigs) {
                tsc.code = TASK_CODE_COMPLETE_SURVEY;
                tsc.invitation = inv.Id;
                tsc.priority = TASK_PRIORITY_CRITICAL;
                tsc.reminderSchedule = inv.Reminder_Schedule__c;

                TimeZone userTZ = userTimezoneMap.get(tsc.ownerId);
                Datetime userDatetime = DateTimeConverterUtil.getUserDatetime(userTZ, Datetime.now());

                tsc.startDate = userDatetime.date();
                if (inv.ExpireDateTime__c != null) {
                    Date expiryDate = inv.ExpireDateTime__c.date();
                    Integer daysBetween = Date.today().daysBetween(expiryDate);
                    tsc.activityDate = DateTimeConverterUtil.addDaysInUserTimeZone(userDatetime, userTZ, daysBetween);
                }

                if (inv.Reminder_Schedule__r.First_Reminder_day__c != null) {
                    Integer firstReminderDay = (Integer) inv.Reminder_Schedule__r.First_Reminder_day__c;
                    tsc.reminderDatetime = DateTimeConverterUtil.addDaysInUserTimeZone(userDatetime, userTZ, firstReminderDay);
                    tsc.reminderGMT = DateTimeConverterUtil.convertUserDatetimeToGMT(tsc.reminderDatetime, userTZ);
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
        return tasks.size();
    }

    public Task createTask(TaskConfig taskConfig) {
        Task task = new Task(
                OwnerId = taskConfig.ownerId,
                Priority = taskConfig.priority,
                Status = taskConfig.status,
                Subject = taskConfig.subject,
                Visible_For__c = taskConfig.visibility
        );

        if (taskConfig.activityDate != null) task.Activity_Datetime__c = taskConfig.activityDate;
        if (taskConfig.code != null) task.Task_Code__c = taskConfig.code;
        if (taskConfig.invitation != null) task.Survey_Invitation__c = taskConfig.invitation;
        if (taskConfig.originator != null) task.Originator__c = taskConfig.originator;
        if (taskConfig.reminderDatetime != null) {
            task.Reminder_Date__c = taskConfig.reminderDatetime;
            if(taskConfig.reminderGMT != null) task.ReminderDateTime = taskConfig.reminderGMT;
        }
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
        return DatabaseService.fieldInValues('Status', statusFilter)
                + 'AND Survey_Invitation__r.Is_Expired__c != TRUE ';
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

    public class TaskConfig {
        public Datetime activityDate;
        public String code;
        public Id invitation;
        public String originator;
        public Id ownerId;
        public String priority;
        public Datetime reminderDatetime;
        public Datetime reminderGMT;
        public Id reminderSchedule;
        public Date startDate;
        public String status;
        public String subject;
        public String type;
        public String visibility;
        public Id whatId;
        public Id whoId;

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

    public List<Task> filterCurrentStudyTasks(List<Task> tasks) {
        Participant_Enrollment__c currentPE = ParticipantService.getInstance().getState().pe;
        if(currentPE == null) {
            List<Id> participantsIds = new List<Id>();
            for (Task t : tasks) {
                if (t.WhatId != null && t.WhatId.getSobjectType() == Participant__c.getSObjectType()) {
                    participantsIds.add(t.WhatId);
                }
            }

            List<Participant_Enrollment__c> participantsPE = [
                    SELECT Id, Clinical_Trial_Profile__r.Tasks_Are_Available__c, Participant__c
                    FROM Participant_Enrollment__c
                    WHERE Participant__c IN: participantsIds AND Clinical_Trial_Profile__r.Tasks_Are_Available__c = TRUE
            ];
            List<Id> participantsIdsToShow = new List<Id>();

            for(Participant_Enrollment__c participantEnrollment : participantsPE){
                participantsIdsToShow.add(participantEnrollment.Participant__c);
            }

            List<Task> tasksToShow = new List<Task>();
            for (Task t : tasks) {
                if (t.WhatId != null && t.WhatId.getSobjectType() == Participant__c.getSObjectType()){
                    if(participantsIdsToShow.contains(t.WhatId)) tasksToShow.add(t);
                }
            }
            return tasksToShow;
        }

        Set<Id> invIds = new Set<Id>();
        for (Task t : tasks) {
            if (t.Task_Type__c == TASK_TYPE_SURVEY && t.Survey_Invitation__c != null) invIds.add(t.Survey_Invitation__c);
        }
        List<SurveyInvitation> invitations = [
                SELECT Id, Participant_Enrollment__c
                FROM SurveyInvitation
                WHERE Id IN:invIds AND Participant_Enrollment__c =: currentPE.Id
        ];
        Set<Id> peIds = new Set<Id>();
        Set<Id> invFilterIds = new Set<Id>();
        for (SurveyInvitation inv : invitations) {
            peIds.add(inv.Participant_Enrollment__c);
            invFilterIds.add(inv.Id);
        }

        List<Task> filteredList = new List<Task>();
        for (Task t : tasks) {
            if (t.WhatId != null && t.WhatId.getSobjectType() == Participant_Enrollment__c.getSObjectType()) {
                if (t.WhatId == currentPE.Id) {
                    filteredList.add(t);
                }
            } else if (t.Task_Type__c == TASK_TYPE_SURVEY && t.Survey_Invitation__c != null) {
                if (invFilterIds.contains(t.Survey_Invitation__c)) {
                    filteredList.add(t);
                }
            } else if (t.Task_Type__c != TASK_TYPE_SURVEY) {
                filteredList.add(t);
            }
        }
        return filteredList;
    }

}