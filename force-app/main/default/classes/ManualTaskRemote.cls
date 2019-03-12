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
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static Integer createTasks(String task, String filter) {
        try {
            Task newTask = (Task) JSON.deserialize(task, Task.class);
            ManualTaskFilter taskFilter = (ManualTaskFilter) JSON.deserialize(filter, ManualTaskFilter.class);

            //Assigning a common task for each found user
            List<User> users = taskFilter.getUsers();
            List<Task> tasks = new List<Task>();
            for (User user : users)
                tasks.add(new Task(OwnerId = user.Id,
                        Subject = newTask.Subject,
                        Priority = newTask.Priority,
                        Start_Date__c = newTask.Start_Date__c,
                        ActivityDate = newTask.ActivityDate)
                );

            insert tasks;

            //For toast after onclick
            return users.size();
        } catch (Exception e) {
            System.debug(e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static Date addDays(Date dateStart, Integer count) {
        try {
            return dateStart.addDays(count);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static Date checkAndGetValidDate(Date start, Date due) {
        try {
            if (due.dayOfYear() >= start.dayOfYear())
                return due; else
                    return start;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public class InitData {
        public Task task = new Task();
        public List<String> priorities = new List<String>();
        public ManualTaskFilter filters = new ManualTaskFilter();

        public InitData() {
            for (TaskPriorityEnum priority : TaskPriorityEnum.values())
                priorities.add(priority.name());
        }
    }
}