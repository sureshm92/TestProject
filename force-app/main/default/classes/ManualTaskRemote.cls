/**
 * Created by Igor Malyuta on 01.03.2019.
 */

public with sharing class ManualTaskRemote {

    public static Boolean createTasks(Task newTask, ManualTaskFilter filter) {
        try {
            Map<Id, Participant_Enrollment__c> contactsWithPE = filter.getContactsWithPE();
            List<User> users = [
                    SELECT Id, ContactId, Name
                    FROM User
                    WHERE ContactId IN :contactsWithPE.keySet()
                    AND IsActive = TRUE
                    AND Profile.Name =: CommunityService.COMMUNITY_USER_PROFILE_NAME
            ];

            List<Task> tasks = new List<Task>();
            for (User user : users) {
                tasks.add(new Task(
                        OwnerId = user.Id,
                        Subject = newTask.Subject,
                        Priority = newTask.Priority,
                        Start_Date__c = newTask.Start_Date__c,
                        ActivityDate = newTask.ActivityDate,
                        Reminder_Date__c = newTask.Reminder_Date__c,
                        Visible_For__c = newTask.Visible_For__c,
                        WhatId = contactsWithPE.get(user.ContactId).Id
                ));
            }
            insert tasks;

            return !tasks.isEmpty();
        } catch (Exception e) {
            return (Boolean) AuraHelper.throwException(e);
        }
    }

    public class TaskPanelWrapper {
        @AuraEnabled public Task task;
        @AuraEnabled public List<LabelValueItem> priorities;
        @AuraEnabled public List<LabelValueItem> visibility;

        public TaskPanelWrapper() {
            task = new Task();
            task.Priority = 'Normal';

            priorities = new List<LabelValueItem>();
            priorities.add(new LabelValueItem('Not selected', 'Normal'));
            priorities.add(new LabelValueItem('Critical', 'Critical'));

            visibility = new List<LabelValueItem>();
            visibility.add(new LabelValueItem('All', 'Owner;Delegates'));
            visibility.add(new LabelValueItem('Patients only', 'Owner'));
            visibility.add(new LabelValueItem('Delegates only', 'Delegates'));
        }
    }
}