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
    public static final String TASK_CODE_SELECT_COI = 'Select_COI';

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
            'Survey_Invitation__r.Is_Expired__c',
            'Survey_Invitation__r.Participant_Enrollment__c'
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
    
    public List<Task> getTasksCommon(String filter){
        
        return getTasksCommon(filter,  null);
    }

    public List<Task> getTasksCommon(String filter, String sortOrder) {
        CommunityMode currentMode = UserContext.getCurrentUserMode();
        Boolean isDecoupled = (ParticipantContext.getOwnParticipant() != null);

        String commonFilter = '';
        String ownerVisibility = ' AND Visible_For__c INCLUDES (\'' + TASK_VISIBILITY_OWNER + '\') ';
        String delegatesVisibility = ' AND Visible_For__c INCLUDES (\'' + TASK_VISIBILITY_DELEGATES + '\') ';
        if (!ParticipantContext.isCurrentDelegate() || (isDecoupled && !currentMode.isDelegate)) {
            // Owner or decoupled delegate in prospect view
            commonFilter = '(' +
                    'OwnerId = \'' + ParticipantContext.getOwnUserId() + '\'' + ownerVisibility +
                    ')';
        } else if (isDecoupled) {
            // Decoupled delegate in patient view
            if(ParticipantContext.getCurrentUserId() != null) {
                commonFilter = '(' +
                        'OwnerId = \'' + ParticipantContext.getCurrentUserId() + '\'' + delegatesVisibility +
                        ')';
            }
        } else {  // TODO Depricated (all delegates decoupled now)
            // Not decoupled delegate
            commonFilter = '(' +
                    '(OwnerId = \'' + ParticipantContext.getOwnUserId() + '\'' + ownerVisibility + ')';
            if (ParticipantContext.getCurrentUserId() != null)
                commonFilter += ' OR ' + '(OwnerId = \'' + ParticipantContext.getCurrentUserId() + '\'' + delegatesVisibility + ')';
            commonFilter += ')';
        }
        if (filter != null) commonFilter += ' AND ' + filter;
        if (sortOrder != null) commonFilter += ' ' + sortOrder;
        List<Task> tasks;
        if (isDecoupled && ParticipantContext.getCurrentUserId() == null) {
            tasks = new List<Task>();
        } else {
            tasks = (List<Task>) DatabaseService.query(DEFAULT_FIELDS, Task.getSObjectType(), commonFilter);
        }
        TaskTriggerHandler.processDefaultFieldValues(tasks);
        return filterTasks(tasks);
    }
    
    private List<Task> filterTasks(List<Task> tasks){
        List<Task> filteredList = new List<Task>();
        Set<Id> skipPEIds = new Set<Id>();
        Set<Id> skipSurveyInvIds = new Set<Id>();
        for(Task t : tasks){
            if(t.WhatId != null && t.WhatId.getSobjectType() == Participant_Enrollment__c.getSObjectType()) skipPEIds.add(t.WhatId);
            if(t.Survey_Invitation__c != null) skipSurveyInvIds.add(t.Survey_Invitation__c);
        }
        skipPEIds = new Map<Id, Participant_Enrollment__c>([
                SELECT Id
                FROM Participant_Enrollment__c
                WHERE Id IN:skipPEIds AND Clinical_Trial_Profile__r.Tasks_Are_Available__c != TRUE
        ]).keySet();
        skipSurveyInvIds = new Map<Id, SurveyInvitation>([
                SELECT Id
                FROM SurveyInvitation
                WHERE Id IN:skipSurveyInvIds AND Participant_Enrollment__r.Clinical_Trial_Profile__r.Tasks_Are_Available__c != TRUE
        ]).keySet();
        for(Task t : tasks){
            Boolean skipTask = false;
            Id curPEId = ParticipantContext.getCurrentPEId();
            if(t.WhatId != null && t.WhatId.getSobjectType() == Participant_Enrollment__c.getSObjectType()){
                skipTask = skipPEIds.contains(t.WhatId) || (curPEId != null && t.WhatId != curPEId);
            } else if(t.Survey_Invitation__c != null){
                skipTask = skipSurveyInvIds.contains(t.Survey_Invitation__c) || (curPEId != null && t.Survey_Invitation__r.Participant_Enrollment__c != curPEId);
            }
            if(!skipTask) filteredList.add(t);
        }
        return filteredList;
    }

    public List<Task> getCompletedTasks() {
        List<String> statusFilter = new List<String>{
                TASK_STATUS_IGNORED,
                TASK_STATUS_COMPLETED
        };
        String completedTaskFilter =  ' (Status IN (\'' + String.join(statusFilter, '\',\'') + '\') ' +
                ' OR (Status = \'' + TASK_STATUS_EXPIRED + '\' AND Task_Type__c = \'' + TASK_TYPE_SURVEY + '\')) ';
        return getTasksCommon(completedTaskFilter, ' ORDER BY Completed_Date__c DESC');
    }

    public List<Task> getOpenTasks() {
        expireSurveyTasksByExpiredInvitations(getTasksCommon(getOpenTasksFilter()));
        return getTasksCommon(getOpenTasksFilter(), OPEN_TASKS_ORDER);
    }

    public List<Task> getPreviewTasks() {
        List<Task> tasks = getTasksCommon(getOpenTasksFilter(), OPEN_TASKS_ORDER);
        List<Task> resTasks = new List<Task>();
        for(Integer i = 0; i < tasks.size(); i++){
            resTasks.add(tasks[i]);
            if(i >= 4) break;
        }
        expireSurveyTasksByExpiredInvitations(getTasksCommon(getOpenTasksFilter()));
        return resTasks;
    }
    
    public String getOpenTasksFilter(){
        List<String> statusFilter = new List<String>{
                TASK_STATUS_OPEN,
                TASK_STATUS_IN_PROGRESS
        };
        return DatabaseService.fieldInValues('Status', statusFilter);
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
                        Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                        Reminder_Schedule__c,
                        Reminder_Schedule__r.First_Reminder_day__c,
                        Survey.Name
                FROM SurveyInvitation
                WHERE Id IN:invitationsVisible.keySet()
                AND Participant_Enrollment__r.Clinical_Trial_Profile__r.Tasks_Are_Available__c = TRUE
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

            userContact.put(partUserId, partContactId);
            Set<Id> patientDelContactIds = delegatesByParticipant.containsKey(partContactId)
                    ? delegatesByParticipant.get(partContactId) : new Set<Id>();

            List<TaskConfig> tmpConfigs = new List<TaskConfig>();
            String visible = invitationsVisible.get(inv.Id);
            switch on visible {
                when 'Patient only', 'Patient or any Delegate', 'Any Delegate' {
                    tmpConfigs.add(new TaskConfig(partUserId, partContactId));
                }
                when 'Each Delegate' {
                    for (Id pdId : patientDelContactIds) {
                        if (delContactUser.get(pdId) == null) continue;

                        tmpConfigs.add(new TaskConfig(delContactUser.get(pdId)));
                        userContact.put(delContactUser.get(pdId), pdId);
                    }
                }
                when 'Patient and each Delegate' {
                    tmpConfigs.add(new TaskConfig(partUserId, partContactId));
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
                tsc.communityTemplateName = CommunityTemplateService.getTemplate(
                        inv.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c
                ).templateName;
                tsc.invitation = inv.Id;
                tsc.priority = TASK_PRIORITY_CRITICAL;
                tsc.reminderSchedule = inv.Reminder_Schedule__c;

                if(tsc.ownerId != null) {
                    TimeZone userTZ = userTimezoneMap.get(tsc.ownerId);
                    Datetime userDatetime =
                            DateTimeConverterUtil.getUserDT(Datetime.now().date(), Datetime.now().time(), userTZ);

                    tsc.startDate = userDatetime.date();
                    if (inv.ExpireDateTime__c != null) {
                        Date expiryDate = inv.ExpireDateTime__c.date();
                        Integer daysBetween = Date.today().daysBetween(expiryDate);
                        tsc.activityDate = Datetime.now().addDays(daysBetween);
                    }

                    if (inv.Reminder_Schedule__r.First_Reminder_day__c != null) {
                        Integer firstReminderDay = (Integer) inv.Reminder_Schedule__r.First_Reminder_day__c;
                        tsc.reminderDatetime = userDatetime.addDays(firstReminderDay);
                        tsc.reminderGMT = Datetime.now().addDays(firstReminderDay);
                    }
                }

                tsc.subject = subject;
                tsc.type = TASK_TYPE_SURVEY;
                tsc.visibility = SurveyService.SURVEY_VISIBLE.get(visible);
                tsc.whoId = userContact.containsKey(tsc.ownerId) ? userContact.get(tsc.ownerId) : partContactId;
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
                Priority = taskConfig.priority,
                Status = taskConfig.status,
                Subject = taskConfig.subject,
                Visible_For__c = taskConfig.visibility
        );
        if(taskConfig.ownerId != null) {
            task.OwnerId = taskConfig.ownerId;
        } else {
            task.Owner_Contact__c = taskConfig.ownerContactId;
        }

        if (taskConfig.activityDate != null) task.Activity_Datetime__c = taskConfig.activityDate;
        if (taskConfig.code != null) task.Task_Code__c = taskConfig.code;
        if (taskConfig.communityTemplateName != null) task.Community_Template_Name__c = taskConfig.communityTemplateName;
        if (taskConfig.invitation != null) task.Survey_Invitation__c = taskConfig.invitation;
        if (taskConfig.originator != null) task.Originator__c = taskConfig.originator;
        if (taskConfig.reminderDatetime != null) {
            task.Reminder_Date__c = taskConfig.reminderDatetime;
            if (taskConfig.reminderGMT != null) task.ReminderDateTime = taskConfig.reminderGMT;
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
    
    public void completeCYPTaskForParticipant() {
        List<Task> tasks = getTasksCommon('Task_Code__c =\'' +
                TASK_CODE_COMPLETE_YOUR_PROFILE + '\' AND ' + getOpenTasksFilter());
        if (tasks.size() > 0) {
            completeTask(tasks[0]);
            update tasks[0];
        }
    }
    
    public Map<Id, Id> getContactUserIdsMap(Set<Id> contactIds) {
        List<User> users = [
                SELECT Id, ContactId, IsActive
                FROM User
                WHERE ContactId IN:contactIds
        ];
        Map<Id, Id> contactUserMap = new Map<Id, Id>();
        for (User u : users) {
            System.debug('>>> Is Active: ' + u.IsActive);
            contactUserMap.put(u.ContactId, u.Id);
        }

        return contactUserMap;
    }

    public class TaskConfig {
        @AuraEnabled public Datetime activityDate;
        @AuraEnabled public String code;
        @AuraEnabled public String communityTemplateName;
        @AuraEnabled public Id invitation;
        @AuraEnabled public String originator;
        @AuraEnabled public Id ownerId;
        @AuraEnabled public Id ownerContactId;
        @AuraEnabled public String priority;
        @AuraEnabled public Date reminderDate;
        @AuraEnabled public Datetime reminderDatetime;
        @AuraEnabled public Datetime reminderGMT;
        @AuraEnabled public Id reminderSchedule;
        @AuraEnabled public Date startDate;
        @AuraEnabled public Date endTime;
        @AuraEnabled public String status;
        @AuraEnabled public String subject;
        @AuraEnabled public String type;
        @AuraEnabled public String visibility;
        @AuraEnabled public Id whatId;
        @AuraEnabled public Id whoId;

        public TaskConfig() {
        }

        public TaskConfig(Id ownerId) {
            this(ownerId, null);
        }

        public TaskConfig(Id ownerId, Id ownerContactId) {
            if(ownerId != null) {
                this.ownerId = ownerId;
            } else {
                this.ownerContactId = ownerContactId;
            }

            priority = TASK_PRIORITY_NORMAL;
            status = TASK_STATUS_OPEN;
            subject = 'Empty';
            visibility = TASK_VISIBILITY_OWNER;
        }

        public TaskConfig(Id ownerId, Id ownerContactId, String subject, String visibility) {
            this(ownerId, ownerContactId);

            this.subject = subject;
            this.visibility = visibility;
        }
    }
    
    public void expireSurveyTasksByExpiredInvitations(List<Task> tasks) {
        List<Id> invitationsIds = new List<Id>();
        for (Task t : tasks) {
            if (t.Survey_Invitation__c != null) invitationsIds.add(t.Survey_Invitation__c);
        }

        Map<Id, Boolean> invitationStateById = SurveyService.getInstance().isInvitationsExpired(invitationsIds);
        List<Task> expiredTasks = new List<Task>();
        for (Task t : tasks) {
            if (invitationStateById.containsKey(t.Survey_Invitation__c) && invitationStateById.get(t.Survey_Invitation__c)) {
                t.Status = TaskService.TASK_STATUS_EXPIRED;
                t.WhatId = null;
                expiredTasks.add(t);
            }
        }
        update expiredTasks;
    }
}