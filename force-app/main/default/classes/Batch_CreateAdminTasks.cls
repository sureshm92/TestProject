/**
 * Created by Igor Malyuta on 04.10.2019.
 */

public class Batch_CreateAdminTasks implements Database.Batchable<PEByContactWrapper>, Database.Stateful {

    private Task adminTask;
    private Map<Id, List<Participant_Enrollment__c>> contactsWithPE;
    private Map<Id, List<Participant_Enrollment__c>> failedContactsWithPE;

    private Id userId;
    private Integer taskCreated;
    private Integer launchCount;

    public Batch_CreateAdminTasks(Map<Id, List<Participant_Enrollment__c>> contactsWithPE, Task adminTask, Id userId,
            Integer taskCreated, Integer launchCount) {
        this.contactsWithPE = contactsWithPE;
        this.failedContactsWithPE = new Map<Id, List<Participant_Enrollment__c>>();
        this.adminTask = adminTask;
        this.userId = userId;
        this.taskCreated = taskCreated;
        this.launchCount = launchCount;
    }

    public List<PEByContactWrapper> start(Database.BatchableContext param1) {
        List<PEByContactWrapper> wrappers = new List<Batch_CreateAdminTasks.PEByContactWrapper>();
        for (Id conId : contactsWithPE.keySet()) {
            wrappers.add(new PEByContactWrapper(conId, contactsWithPE.get(conId)));
        }

        return wrappers;
    }

    public void execute(Database.BatchableContext param1, List<PEByContactWrapper> wrappers) {
        Map<Id, List<Participant_Enrollment__c>> peByContactIds = new Map<Id, List<Participant_Enrollment__c>>();
        for (PEByContactWrapper wrapper : wrappers) peByContactIds.put(wrapper.contactId, wrapper.enrollments);

        try {
            List<User> users = [
                    SELECT Id, ContactId, Name
                    FROM User
                    WHERE ContactId IN :peByContactIds.keySet()
                    AND IsActive = TRUE
                    AND Profile.Name = :CommunityService.COMMUNITY_USER_PROFILE_NAME
            ];

            List<Task> tasks = new List<Task>();
            for (User user : users) {
                for(Participant_Enrollment__c pe : peByContactIds.get(user.ContactId)) {
                    tasks.add(new Task(
                            OwnerId = user.Id,
                            Subject = adminTask.Subject,
                            Priority = adminTask.Priority,
                            Start_Date__c = adminTask.Start_Date__c,
                            Activity_Datetime__c = adminTask.Activity_Datetime__c,
                            ReminderDateTime = adminTask.ReminderDateTime,
                            Visible_For__c = adminTask.Visible_For__c,
                            WhatId = pe.Id,
                            Task_Type__c = TaskService.TASK_TYPE_NOT_SELECTED
                    ));
                }
            }
            insert tasks;
            taskCreated += tasks.size();
        } catch (Exception e) {
            failedContactsWithPE.putAll(peByContactIds);
        }
    }

    public void finish(Database.BatchableContext param1) {
        if (!failedContactsWithPE.isEmpty() && launchCount < 3) {
            Database.executeBatch(
                    new Batch_CreateAdminTasks(failedContactsWithPE, adminTask, userId, taskCreated, ++launchCount));
        } else {
            //Send email to Admin
            try {
                Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
                List<User> user = [SELECT Id, Email FROM User WHERE Id = :userId];
                emailMessage.setToAddresses(new List<String>{
                        user.get(0).Email
                });
                emailMessage.setSubject('Batch Create Admin Task');

                String messageBody = 'Task Subject: ' + adminTask.Subject + '\n';
                messageBody += 'Task(s) created = ' + taskCreated
                        + '. Task(s) failed = '
                        + (failedContactsWithPE.isEmpty() ? '0' : '' + (failedContactsWithPE.values().size() + '\n'));
                if (!failedContactsWithPE.isEmpty()) {
                    messageBody += 'Failed contact ids:\n';
                    Integer i = 0;
                    for (Id conId : failedContactsWithPE.keySet()) {
                        messageBody += conId + ', ';
                        if (Math.mod(3, i) == 0) messageBody += '\n';
                        i++;
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

    public static void launch(Map<Id, List<Participant_Enrollment__c>> contactsWithPE, Task adminTask) {
        Database.executeBatch(new Batch_CreateAdminTasks(contactsWithPE, adminTask, UserInfo.getUserId(), 0, 1));
    }

    public class PEByContactWrapper {

        public Id contactId;
        public List<Participant_Enrollment__c> enrollments;

        public PEByContactWrapper(Id contactId, List<Participant_Enrollment__c> enrollments) {
            this.contactId = contactId;
            this.enrollments = enrollments;
        }
    }
}