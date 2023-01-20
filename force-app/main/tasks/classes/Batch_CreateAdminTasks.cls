/**
 * Created by Igor Malyuta on 04.10.2019.
 */ 

public class Batch_CreateAdminTasks implements Database.Batchable<WhatIdByContactWrapper>, Database.Stateful {
    private TaskService.TaskConfig taskConfig;
    private Map<Id, List<Id>> contactsWithWhatIds;
    private Map<Id, List<Id>> failedContactsWithWhatIds;

    private Id userId;
    private Boolean isQueueable;
    private Integer taskCreated;
    private Integer launchCount;
    private Map<id, String> IdTypeOfContactMap;

    public Batch_CreateAdminTasks(
        Map<Id, List<Id>> contactsWithWhatIds,
        TaskService.TaskConfig taskConfig,
        Id userId,
        Integer taskCreated,
        Integer launchCount,
        Map<id, String> IdTypeOfContactMap,
        Boolean isQueueable
    ) {
        this.contactsWithWhatIds = contactsWithWhatIds;
        this.failedContactsWithWhatIds = new Map<Id, List<Id>>();
        this.taskConfig = taskConfig;
        this.userId = userId;
        this.taskCreated = taskCreated;
        this.launchCount = launchCount;
        this.IdTypeOfContactMap = IdTypeOfContactMap;
        this.isQueueable = isQueueable;
    }

    public List<WhatIdByContactWrapper> start(Database.BatchableContext param1) {
        List<WhatIdByContactWrapper> wrappers = new List<Batch_CreateAdminTasks.WhatIdByContactWrapper>();
        for (Id conId : contactsWithWhatIds.keySet()) {
            wrappers.add(new WhatIdByContactWrapper(conId, contactsWithWhatIds.get(conId)));
        }

        return wrappers;
    }

    public void execute(Database.BatchableContext param1, List<WhatIdByContactWrapper> wrappers) {
        Map<Id, List<Id>> whatIdByContactIds = new Map<Id, List<Id>>();
        set<id> contactWithoutUser = new Set<Id>();

        for (WhatIdByContactWrapper wrapper : wrappers)
            whatIdByContactIds.put(wrapper.contactId, wrapper.whatIds);
        contactWithoutUser.addAll(whatIdByContactIds.keySet());

        Map<Id, Participant_Enrollment__c> participantEnrollmentMap = getParticipantEnrollments(
            whatIdByContactIds.values()
        );

        try {
            List<User> users = [
                SELECT Id, ContactId, Name, TimeZoneSidKey
                FROM User
                WHERE
                    ContactId IN :whatIdByContactIds.keySet()
                    AND IsActive = TRUE
                    AND Profile.Name = :CommunityService.COMMUNITY_USER_PROFILE_NAME
            ];
            List<Task> tasks = new List<Task>();
             Time eodTime = Time.newInstance(23, 59, 0, 0);
            for (User user : users) {
                contactWithoutUser.remove(user.ContactId);
                TimeZone userTZ = TimeZone.getTimeZone(user.TimeZoneSidKey);
                //Time eodTime = Time.newInstance(23, 59, 0, 0);
                Time remTime = Time.newInstance(11, 30, 0, 0);
                String TypeOfContactTemp = IdTypeOfContactMap.get(user.ContactId);
                for (Id whatId : whatIdByContactIds.get(user.ContactId)) {
                    Datetime activityDT;
                    Integer offsetSeconds;
                    if (taskConfig.endTime != null) {
                        offsetSeconds = userTZ.getOffset(taskConfig.endTime) / 1000;
                        activityDT = Datetime.newInstanceGmt(taskConfig.endTime, eodTime)
                            .addSeconds(-offsetSeconds);
                    }
                    Datetime reminderDT_GMT;
                    Datetime reminderDT;

                    if (taskConfig.reminderDate != null) {
                        reminderDT_GMT = Datetime.newInstanceGmt(
                            taskConfig.reminderDate,
                            Datetime.now().timeGmt()
                        );
                        System.debug('Batch Rem reminderDT_GMT: ' + reminderDT_GMT);
                        if (isQueueable) {
                            reminderDT = Datetime.newInstanceGmt(taskConfig.reminderDate, remTime)
                                .addSeconds(-offsetSeconds);
                        } else {
                            reminderDT = Datetime.newInstance(
                                taskConfig.reminderDate,
                                Datetime.now().time()
                            );
                        }
                        System.debug('Batch Rem reminderDT: ' + reminderDT);
                    }
                    String VisibleFor = taskConfig.visibility;
                    if (
                        String.isNotBlank(TypeOfContactTemp) &&
                        TypeOfContactTemp.contains('Participant')
                    ) {
                        TypeOfContactTemp = TypeOfContactTemp.remove('Participant');
                        VisibleFor = 'Owner; Delegates';
                    } else if (
                        String.isNotBlank(TypeOfContactTemp) &&
                        TypeOfContactTemp.contains('Delegate')
                    ) {
                        VisibleFor = 'Owner';
                    } else {
                        VisibleFor = taskConfig.visibility;
                    }
                    // KK-End
                    Task objtask = new Task(
                        OwnerId = user.Id,
                        Subject = taskConfig.subject,
                        Priority = taskConfig.priority,
                        Start_Date__c = taskConfig.startDate,
                        Activity_Datetime__c = activityDT,
                        ReminderDateTime = reminderDT,
                        Reminder_Date__c = reminderDT,
                        Remind_Using_Email__c = reminderDT != null ? true : false,
                        Remind_Using_SMS__c = reminderDT != null ? true : false,
                        Visible_For__c = VisibleFor,
                        WhatId = whatId,
                        WhoId = user.ContactId,
                        Task_Type__c = TaskService.TASK_TYPE_NOT_SELECTED,
                        CreatedByAdmin__c = true,
                        InitialTaskNotification__c = true
                    );
                    if (
                        participantEnrollmentMap != null &&
                        participantEnrollmentMap.containsKey(whatId)
                    ) {
                        objtask.Community_Template_Name__c = participantEnrollmentMap.get(whatId)
                            .Clinical_Trial_Profile__r.CommunityTemplate__c;
                    }
                    tasks.add(objtask);
                }
            }
            List<Id> contactListOfId = new List<Id>(contactWithoutUser);
            if (!contactListOfId.isEmpty()) {
                for (Id contactIds : contactListOfId) {
                    for (Id whatId : whatIdByContactIds.get(contactIds)) {
                         Datetime reminderDT_GMT;
                         Datetime reminderDT;
                    if (taskConfig.reminderDate != null) {
                        reminderDT_GMT = Datetime.newInstanceGmt(
                            taskConfig.reminderDate,
                            Datetime.now().timeGmt()
                        );
                            reminderDT = Datetime.newInstance(
                                taskConfig.reminderDate,
                                Datetime.now().time()
                            );
                    }
                        Datetime activityDT;
                        if (taskConfig.endTime != null) {
                        activityDT = Datetime.newInstanceGmt(taskConfig.endTime, eodTime).addSeconds(120);
                    }
                        String TypeOfContactTemp = IdTypeOfContactMap.get(contactIds);
                        String VisibleFor = taskConfig.visibility;
                        if (
                            String.isNotBlank(TypeOfContactTemp) &&
                            TypeOfContactTemp.contains('Participant')
                        ) {
                            TypeOfContactTemp = TypeOfContactTemp.remove('Participant');
                            VisibleFor = 'Owner; Delegates';
                        } else if (
                            String.isNotBlank(TypeOfContactTemp) &&
                            TypeOfContactTemp.contains('Delegate')
                        ) {
                            VisibleFor = 'Owner';
                        } else {
                            VisibleFor = taskConfig.visibility;
                        }
                        Task objTask = new Task(
                            Owner_Contact__c = contactIds,
                            Subject = taskConfig.subject,
                            Priority = taskConfig.priority,
                            Start_Date__c = taskConfig.startDate,
                            Activity_Datetime__c = activityDT,
                            ReminderDateTime = reminderDT,
                            Reminder_Date__c = reminderDT,
                            Remind_Using_Email__c = reminderDT != null ? true : false,
                            Remind_Using_SMS__c = reminderDT != null ? true : false,
                            Visible_For__c = VisibleFor,
                            WhatId = whatId,
                            WhoId = contactIds,
                            Task_Type__c = TaskService.TASK_TYPE_NOT_SELECTED,
                            CreatedByAdmin__c = true,
                            InitialTaskNotification__c = true
                        );
                        if (
                            participantEnrollmentMap != null &&
                            participantEnrollmentMap.containsKey(whatId)
                        ) {
                            objtask.Community_Template_Name__c = participantEnrollmentMap.get(
                                    whatId
                                )
                                .Clinical_Trial_Profile__r.CommunityTemplate__c;
                        }
                        tasks.add(objTask);
                    }
                }
            }
            insert tasks;
            System.debug('Tasklist: ' + tasks);
            taskCreated += tasks.size();
        } catch (Exception e) {
            failedContactsWithWhatIds.putAll(whatIdByContactIds);
        }
    }

    public void finish(Database.BatchableContext param1) {
        if (!failedContactsWithWhatIds.isEmpty() && launchCount < 3 && !Test.isRunningTest()) {
            Database.executeBatch(
                new Batch_CreateAdminTasks(
                    failedContactsWithWhatIds,
                    taskConfig,
                    userId,
                    taskCreated,
                    ++launchCount,
                    IdTypeOfContactMap,
                    isQueueable
                )
            );
        } else {
            //Send email to Admin
            try {
                Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
                List<User> user = [SELECT Id, Email FROM User WHERE Id = :userId];
                emailMessage.setToAddresses(new List<String>{ user.get(0).Email });
                emailMessage.setSubject('Batch Create Admin Task');

                String messageBody = 'Task Subject: ' + taskConfig.subject + '\n';
                messageBody +=
                    'Task(s) created = ' +
                    taskCreated +
                    '. Task(s) failed = ' +
                    (failedContactsWithWhatIds.isEmpty()
                        ? '0'
                        : '' + (failedContactsWithWhatIds.values().size() + '\n'));
                if (!failedContactsWithWhatIds.isEmpty()) {
                    messageBody += 'Failed contact ids:\n';
                    Integer i = 0;
                    for (Id conId : failedContactsWithWhatIds.keySet()) {
                        messageBody += conId + ', ';
                        if (Math.mod(3, ++i) == 0)
                            messageBody += '\n';
                    }

                    messageBody = messageBody.removeEnd(', ');
                }

                emailMessage.setPlainTextBody(messageBody);
                Messaging.sendEmail(
                    (List<Messaging.Email>) new List<Messaging.SingleEmailMessage>{ emailMessage }
                );
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }
    }

    public static void launch(
        Map<Id, List<Id>> contactsWithWhatIds,
        TaskService.TaskConfig adminTask,
        Map<id, String> IdTypeOfContactMap
    ) {
        Database.executeBatch(
            new Batch_CreateAdminTasks(
                contactsWithWhatIds,
                adminTask,
                UserInfo.getUserId(),
                0,
                1,
                IdTypeOfContactMap,
                System.isQueueable()
            )
        );
    }
    public static Map<Id, Participant_Enrollment__c> getParticipantEnrollments(
        List<List<Id>> whatIdListOfList
    ) {
        Set<Id> allWhatIdSet = new Set<Id>();
        Map<Id, Participant_Enrollment__c> participantEnrollmentMap;
        for (List<Id> whatIdList : whatIdListOfList) {
            for (Id whatId : whatIdList) {
                if (
                    whatId.getSObjectType().getDescribe().getName() == 'Participant_Enrollment__c'
                ) {
                    allWhatIdSet.add(whatId);
                }
            }
        }
        if (allWhatIdSet.size() > 0) {
            participantEnrollmentMap = new Map<Id, Participant_Enrollment__c>(
                [
                    SELECT Id, Clinical_Trial_Profile__r.CommunityTemplate__c
                    FROM Participant_Enrollment__c
                    WHERE Id IN :allWhatIdSet
                ]
            );
        }
        return participantEnrollmentMap;
    }
    public class WhatIdByContactWrapper {
        public Id contactId;
        public List<Id> whatIds;

        public WhatIdByContactWrapper(Id contactId, List<Id> whatIds) {
            this.contactId = contactId;
            this.whatIds = whatIds;
        }
    }
}
