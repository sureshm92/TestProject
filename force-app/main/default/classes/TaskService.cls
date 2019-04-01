/**
 * Created by Leonid Bartenev
 */

public class TaskService {
    
    public class TaskServiceException extends Exception{}
    
    public static final String TASK_TYPE_MEDICATION = 'Medication';
    public static final String TASK_TYPE_VISIT = 'Visit';
    
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
            'WhatId'
    };
    
    public static List<Task> getTasksCommon(String filter){
        String ownerFilter = ' OwnerId = \'' + UserInfo.getUserId() + '\'';
        if(filter == null) {
            filter = ownerFilter;
        }else{
            filter = ownerFilter + ' AND ' + filter;
        }
        String query = 'SELECT ' + String.join(DEFAULT_FIELDS, ',') + ' FROM Task WHERE ' + filter;
        List<Task> tasks = Database.query(query);
        TaskTriggerHandler.processDefaultFieldValues(tasks);
        return tasks;
    }
    
    public static List<Task> getOpenTasks() {
        return getTasksCommon(' Status=\'Open\' AND CreatedById != \'' + UserInfo.getUserId()  + '\' ORDER BY Priority DESC, CreatedDate DESC');
//        List<Task> openTasks = getTasksCommon(' Status=\'Open\' AND CreatedById != \'' + UserInfo.getUserId()  + '\' ORDER BY Priority DESC, CreatedDate DESC');
//        List<String> priorities = new List<String>{'Critical', 'High', 'Medium', 'Normal', 'Low'};
//        Map<String, List<Task>> priorityTasksMap = new Map<String, List<Task>>();
//        List<Task> sortedTasks = new List<Task>();
//
//        System.debug('Open Tasks: ' + openTasks);
//
//        // initialize map
//        for (String t: priorities) {
//            priorityTasksMap.put(t, new List<Task>());
//        }
//        // fill map with Task's List
//        for (Task t: openTasks) {
//            if (t.Priority.equals('Critical')) {
//                System.debug('Here is Critical');
//                List<Task> critical = priorityTasksMap.get('Critical');
//                critical.add(t);
//                priorityTasksMap.put('Critical', critical);
//            } else if (t.Priority == 'High') {
//                List<Task> high = priorityTasksMap.get('High');
//                high.add(t);
//                priorityTasksMap.put('High', high);
//            } else if (t.Priority == 'Medium') {
//                List<Task> medium = priorityTasksMap.get('Medium');
//                medium.add(t);
//                priorityTasksMap.put('Medium', medium);
//            } else if (t.Priority == 'Normal') {
//                List<Task> normal = priorityTasksMap.get('Normal');
//                normal.add(t);
//                priorityTasksMap.put('Normal', normal);
//            } else if (t.Priority == 'Low') {
//                List<Task> low = priorityTasksMap.get('Low');
//                low.add(t);
//                priorityTasksMap.put('Low', low);
//            }
//        }
//
//        for (String priority: priorities) {
//            List<Task> prTasks = priorityTasksMap.get(priority);
//            for (Integer i = 0; i < prTasks.size(); i++) {
//                if (i == (prTasks.size()-1)) {
//                    sortedTasks.add(prTasks.get(prTasks.size()-1));
//                    break;
//                }
//                if (prTasks.get(i).CreatedDate > prTasks.get(i+1).CreatedDate) {
//                    sortedTasks.add(prTasks.get(i));
//                }
//            }
//        }
//
//        return sortedTasks;
    }
    
    public static List<Task> getPreviewTasks(){
        return getTasksCommon(' Status=\'Open\' AND CreatedById != \'' + UserInfo.getUserId()  + '\' ORDER BY Priority DESC, CreatedDate DESC LIMIT 5 ');
    }
    
    public static Task getTask(Id taskId){
        List<Task> tasks = getTasksCommon(' Id = \'' + taskId + '\' ');
        if(tasks.size() == 0) throw new TaskServiceException('Task not found: ' + taskId);
        return tasks[0];
    }
    
    public static List<Task> getMyTasks(){
        return getTasksCommon(' Status=\'Open\' AND CreatedById = \'' + UserInfo.getUserId()  + '\' ORDER BY Priority DESC, CreatedDate DESC');
    }
    
    public static List<Task> getCompletedTasks(){
        return getTasksCommon(' Status IN (\'Completed\', \'Ignored\') ORDER BY Completed_Date__c DESC');
    }
    
    public static void ignoreTask(Id taskId){
        Task task = getTask(taskId);
        task.Status = 'Ignored';
        task.Completed_Date__c = Datetime.now();
        update task;
    }
    
    public static void completeTask(Id taskId){
        Task task = getTask(taskId);
        task.Status = 'Completed';
        task.Completed_Date__c = Datetime.now();
        update task;
    }
 
}