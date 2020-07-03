/**
 * Created by Igor Malyuta on 04.10.2019.
 */

public class Batch_CreateAdminTasks implements Database.Batchable<WhatIdByContactWrapper>, Database.Stateful {

    private TaskService.TaskConfig taskConfig;
    private Map<Id, List<Id>> contactsWithWhatIds;
    private Map<Id, List<Id>> failedContactsWithWhatIds;

    private Id userId;
    private Integer taskCreated;
    private Integer launchCount;

    public Batch_CreateAdminTasks(Map<Id, List<Id>> contactsWithWhatIds, TaskService.TaskConfig taskConfig,
            Id userId, Integer taskCreated, Integer launchCount) {
        this.contactsWithWhatIds = contactsWithWhatIds;
        this.failedContactsWithWhatIds = new Map<Id, List<Id>>();
        this.taskConfig = taskConfig;
        this.userId = userId;
        this.taskCreated = taskCreated;
        this.launchCount = launchCount;
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
        for (WhatIdByContactWrapper wrapper : wrappers) whatIdByContactIds.put(wrapper.contactId, wrapper.whatIds);

        try {
            List<User> users = [
                    SELECT Id, ContactId, Name, TimeZoneSidKey
                    FROM User
                    WHERE ContactId IN :whatIdByContactIds.keySet()
                    AND IsActive = TRUE
                    AND Profile.Name = :CommunityService.COMMUNITY_USER_PROFILE_NAME
            ];

            List<Task> tasks = new List<Task>();
            for (User user : users) {
                for(Id whatId : whatIdByContactIds.get(user.ContactId)) {
                    Datetime activityDT;
                    if(taskConfig.endTime != null) activityDT = Datetime.newInstance(taskConfig.endTime, Datetime.now().time());

                    Datetime reminderDT_GMT;
                    Datetime reminderDT;
                    if(taskConfig.reminderDate != null) {
                         reminderDT_GMT = Datetime.newInstanceGmt(taskConfig.reminderDate, Datetime.now().timeGmt());
                         reminderDT = Datetime.newInstance(taskConfig.reminderDate, Datetime.now().time());
                    }

                    tasks.add(new Task(
                            OwnerId = user.Id,
                            Subject = taskConfig.subject,
                            Priority = taskConfig.priority,
                            Start_Date__c = taskConfig.startDate,
                            Activity_Datetime__c = activityDT,
                            ReminderDateTime = reminderDT_GMT,
                            Reminder_Date__c = reminderDT, 
                            Visible_For__c = taskConfig.visibility,
                            WhatId = whatId,
                            WhoId = user.ContactId,
                            Task_Type__c = TaskService.TASK_TYPE_NOT_SELECTED
                    ));
                }
            }
            insert tasks;
            taskCreated += tasks.size();
        } catch (Exception e) {
            failedContactsWithWhatIds.putAll(whatIdByContactIds);
        }
    }

    public void finish(Database.BatchableContext param1) {
        if (!failedContactsWithWhatIds.isEmpty() && launchCount < 3 && !Test.isRunningTest()) {
            Database.executeBatch(
                    new Batch_CreateAdminTasks(failedContactsWithWhatIds, taskConfig, userId, taskCreated, ++launchCount));
        } else {
            //Send email to Admin
            try {
                Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
                List<User> user = [SELECT Id, Email FROM User WHERE Id = :userId];
                emailMessage.setToAddresses(new List<String>{
                        user.get(0).Email
                });
                emailMessage.setSubject('Batch Create Admin Task');

                String messageBody = 'Task Subject: ' + taskConfig.subject + '\n';
                messageBody += 'Task(s) created = ' + taskCreated
                        + '. Task(s) failed = '
                        + (failedContactsWithWhatIds.isEmpty() ? '0' : '' + (failedContactsWithWhatIds.values().size() + '\n'));
                if (!failedContactsWithWhatIds.isEmpty()) {
                    messageBody += 'Failed contact ids:\n';
                    Integer i = 0;
                    for (Id conId : failedContactsWithWhatIds.keySet()) {
                        messageBody += conId + ', ';
                        if (Math.mod(3, ++i) == 0) messageBody += '\n';
                    }

                    messageBody = messageBody.removeEnd(', ');
                }

                emailMessage.setPlainTextBody(messageBody);
                Messaging.sendEmail((List<Messaging.Email>) new List<Messaging.SingleEmailMessage>{
                        emailMessage
                });
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }
    }

    public static void launch(Map<Id, List<Id>> contactsWithWhatIds, TaskService.TaskConfig adminTask) {
        Database.executeBatch(new Batch_CreateAdminTasks(contactsWithWhatIds, adminTask, UserInfo.getUserId(), 0, 1));
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