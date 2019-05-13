/**
 * Created by Igor Malyuta on 01.03.2019.
 */

public with sharing class ManualTaskRemote {

    @AuraEnabled
    public static String getInitData() {
        try {
            InitData initData = new InitData();
            return JSON.serialize(initData);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static Integer createTasks(String task, String filter) {
        try {
            Task newTask = (Task) JSON.deserialize(task, Task.class);
            newTask.Reminder_Date__c = newTask.Reminder_Date__c.addHours(12);
            ManualTaskFilter taskFilter = (ManualTaskFilter) JSON.deserialize(filter, ManualTaskFilter.class);

            //Assigning a common task for each found user
            List<User> users = taskFilter.getUsers();
            List<Task> tasks = new List<Task>();
            for(User user : users) {
                tasks.add(new Task(
                                OwnerId = user.Id,
                                Subject = newTask.Subject,
                                Priority = newTask.Priority,
                                Start_Date__c = newTask.Start_Date__c,
                                ActivityDate = newTask.ActivityDate,
                                Reminder_Date__c = newTask.Reminder_Date__c,
                                Visible_For__c = newTask.Visible_For__c)
                );
            }
            insert tasks;

            //For toast after onclick
            return users.size();
        } catch (Exception e) {
            return (Integer) AuraHelper.throwException(e);
        }
    }

    public class InitData {
        public Task task;
        public ManualTaskFilter filters;
        public List<LabelValueItem> priorities;
        public List<LabelValueItem> visibility;

        public InitData() {
            task = new Task();
            task.Priority = 'Normal';
            
            filters = new ManualTaskFilter();

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