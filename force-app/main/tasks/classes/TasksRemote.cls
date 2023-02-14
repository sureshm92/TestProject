/**
 * Created by Leonid Bartenev
 */

public without sharing class TasksRemote {
    public class ParticipantTasks {
        @AuraEnabled
        public List<OpenTask> openTasksWrapper;
        @AuraEnabled
        public List<CompletedTask> completedTasks;
        @AuraEnabled
        public String emptyText;
        @AuraEnabled
        public Boolean showCreateTaskButton = false;
    }

    public class OpenTask {
        @AuraEnabled
        public Task openTask;
        @AuraEnabled
        public String originator;
        @AuraEnabled
        public Date activityDate;
        @AuraEnabled
        public Date reminder;
        @AuraEnabled
        public Boolean isMCPTask;
    }

    public class CompletedTask {
        @AuraEnabled
        public Task task;
        @AuraEnabled
        public Date completedDate;
        @AuraEnabled
        public Boolean isMCPTask;
    }

    @AuraEnabled
    public static List<Task> getPreviewTasks() {
        try {
            return TaskService.getInstance().getPreviewTasks();
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static ParticipantTasks getParticipantTasks() {
        ParticipantTasks participantTasks = new ParticipantTasks();
        try {
            participantTasks.openTasksWrapper = new List<OpenTask>();
            List<Task> openTasks = TaskService.getInstance().getOpenTasks();
            for (Task task : openTasks) {
                OpenTask taskWrapper = new OpenTask();
                taskWrapper.openTask = task;

                if (task.Activity_Datetime__c != null)
                    taskWrapper.activityDate = task.Activity_Datetime__c.date();
                if (task.ReminderDateTime != null)
                    taskWrapper.reminder = task.ReminderDateTime.date();

                participantTasks.openTasksWrapper.add(taskWrapper);
            }
            createOriginatorsList(participantTasks.openTasksWrapper);

            participantTasks.completedTasks = new List<TasksRemote.CompletedTask>();
            List<Task> completedTasks = TaskService.getInstance().getCompletedTasks();
            for (Task compTask : completedTasks) {
                CompletedTask completedTask = new CompletedTask();
                completedTask.task = compTask;
                if (compTask.Completed_Date__c != null)
                    completedTask.completedDate = compTask.Completed_Date__c.date();

                participantTasks.completedTasks.add(completedTask);
            }

            ParticipantService.ParticipantState participantState = ParticipantService.getInstance()
                .getState();
            if (participantState.isDelegate) {
                participantTasks.emptyText = Label.PG_Task_Tab_No_Tasks_Delegate.replace(
                    '##ParticipantFirstName',
                    participantState.participant.First_Name__c
                );
            } else {
                participantTasks.emptyText = Label.PG_Task_Tab_No_Tasks;
            }
            if (
                /*ParticipantContext.getCurrentUser() != null &&*/ /*create tasks for minors */
                (participantState.value == ParticipantService.ParticipantStates.ALUMNI ||
                participantState.ctp.Tasks_Are_Available__c)
            ) {
                participantTasks.showCreateTaskButton = true;
            }
        } catch (Exception e) {
            return (ParticipantTasks) AuraHelper.throwException(e);
        }
        return participantTasks;
    }

    @AuraEnabled
    public static ParticipantTasks getPPParticipantTasks() {
        ParticipantTasks participantTasks = new ParticipantTasks();
        try {
            participantTasks.openTasksWrapper = new List<OpenTask>();
            List<Task> openTasks = TaskService.getInstance().getOpenTasks();
            List<Task> sortedTaskList = getPPSortedTasks(openTasks);
            for (Task task : sortedTaskList) {
                OpenTask taskWrapper = new OpenTask();
                taskWrapper.openTask = task;

                if (task.Activity_Datetime__c != null)
                    taskWrapper.activityDate = task.Activity_Datetime__c.date();
                if (task.ReminderDateTime != null)
                    taskWrapper.reminder = task.ReminderDateTime.date();

                participantTasks.openTasksWrapper.add(taskWrapper);
            }
            createOriginatorsList(participantTasks.openTasksWrapper);

            participantTasks.completedTasks = new List<TasksRemote.CompletedTask>();

            List<Task> completedTasks = TaskService.getInstance().getCompletedTasks();
            List<Task> sortedCompleteTasks = gropupCompletedTasks(completedTasks);
            for (Task compTask : sortedCompleteTasks) {
                CompletedTask completedTask = new CompletedTask();
                completedTask.task = compTask;
                if (compTask.Completed_Date__c != null)
                    completedTask.completedDate = compTask.Completed_Date__c.date();

                participantTasks.completedTasks.add(completedTask);
            }
            createMCPList(participantTasks.completedTasks);
            ParticipantService.ParticipantState participantState = ParticipantService.getInstance()
                .getState();
            if (participantState.isDelegate) {
                participantTasks.emptyText = Label.PG_Task_Tab_No_Tasks_Delegate.replace(
                    '##ParticipantFirstName',
                    participantState.participant.First_Name__c
                );
            } else {
                participantTasks.emptyText = Label.PG_Task_Tab_No_Tasks;
            }
            if (
                /*ParticipantContext.getCurrentUser() != null &&*/ /*create tasks for minors */
                (participantState.value == ParticipantService.ParticipantStates.ALUMNI ||
                participantState.ctp.Tasks_Are_Available__c)
            ) {
                participantTasks.showCreateTaskButton = true;
            }
        } catch (Exception e) {
            return (ParticipantTasks) AuraHelper.throwException(e);
        }
        return participantTasks;
    }

    @AuraEnabled
    public static void taskClicked(String id, String message) {
        try {
            if (Pattern.compile('\\bautocomplete=true\\b').matcher(message.toLowerCase()).find()) {
                TaskService.getInstance().completeTask(id);
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    private static void createOriginatorsList(List<OpenTask> tasks) {
        for (OpenTask taskWrapper : tasks) {
            switch on taskWrapper.openTask.Originator__c {
                when 'Participant' {
                    taskWrapper.originator = Label.PP_Participant;
                    taskWrapper.isMCPTask = false;
                }
                when 'Delegate' {
                    taskWrapper.originator = Label.Delegate;
                    taskWrapper.isMCPTask = false;
                }
                when else {
                    taskWrapper.originator = Label.Admin;
                    taskWrapper.isMCPTask = taskWrapper.openTask.Task_Type__c == 'Not Selected'
                        ? true
                        : false;
                }
            }
        }
    }

    private static void createMCPList(List<CompletedTask> tasks) {
        for (CompletedTask taskWrapper : tasks) {
            if (taskWrapper.task.Task_Type__c == 'Not Selected') {
                if (
                    taskWrapper.task.Originator__c == 'Participant' ||
                    taskWrapper.task.Originator__c == 'Delegate'
                ) {
                    taskWrapper.isMCPTask = false;
                } else {
                    taskWrapper.isMCPTask = true;
                }
            } else {
                taskWrapper.isMCPTask = false;
            }
        }
    }

    public static List<Task> getPPSortedTasks(List<Task> tasks) {
        List<String> codeList = new List<String>{
            'Complete_Your_Profile',
            'Update_Your_Phone_Number',
            'Select_COI'
        };
        List<Task> finalSortedTasksList = new List<Task>();
        System.debug('openTasks::::' + tasks);
        List<Task> groupATasks = new List<Task>();
        List<Task> groupBTasks = new List<Task>();
        for (Task taskObj : tasks) {
            if (taskObj.whatId != null && !codeList.contains(taskObj.Task_code__c)) {
                if (
                    String.valueOf(taskObj.whatId.getSobjectType()) == 'Participant_Enrollment__c'
                ) {
                    groupATasks.add(taskObj); //Study Level Task
                }
                if (
                    String.valueOf(taskObj.whatId.getSobjectType()) == 'Participant__c' &&
                    taskObj.Task_Type__c != TaskService.TASK_TYPE_ECOA
                ) {
                    if (taskObj.Originator__c == 'IQVIA Admin') {
                        //add it to platform level task
                        groupBTasks.add(taskObj);
                    } else {
                        //add it to manually created tasks
                        groupATasks.add(taskObj);
                    }
                }
            }
            if (taskObj.Survey_Invitation__c != null) {
                // add it to study level surveys
                if (taskObj.Survey_Invitation__r.IsTrialSurvey__c) {
                    groupATasks.add(taskObj);
                } else {
                    // add it to platform level surveys
                    groupBTasks.add(taskObj);
                }
            }
            if (taskObj.Task_Type__c == 'Ecoa') {
                groupATasks.add(taskObj);
                //add it to ecoa surveys
            }
            if (codeList.contains(taskObj.Task_code__c)) {
                //add it to System tasks
                groupBTasks.add(taskObj);
            }
        }
        System.debug('groupA Tasks ' + groupATasks);
        if (groupATasks.size() > 0) {
            finalSortedTasksList.addAll(processSorting(groupATasks));
        }
        System.debug('groupB Tasks ' + groupBTasks);
        if (groupBTasks.size() > 0) {
            finalSortedTasksList.addAll(processSorting(groupBTasks));
        }
        System.debug('finalOpenTasksList:::' + finalSortedTasksList);
        return finalSortedTasksList;
    }
    public static List<Task> processSorting(List<Task> tasksList) {
        Map<Datetime, List<Task>> tasksWithDue = new Map<Datetime, List<Task>>();
        Map<Datetime, List<Task>> taskswithStartDate = new Map<Datetime, List<Task>>();
        Map<Datetime, List<Task>> taskswithCreationDate = new Map<Datetime, List<Task>>();
        Map<Datetime, List<Task>> taskswithCriticalTaskswithDueDate = new Map<Datetime, List<Task>>();
        Map<Datetime, List<Task>> taskswithCriticalTaskswithStartDate = new Map<Datetime, List<Task>>();
        Map<Datetime, List<Task>> taskswithCriticalTaskswithCreatedDate = new Map<Datetime, List<Task>>();
        List<String> taskCodeList = new List<String>{
            'Complete_Survey',
            'Complete_Your_Profile',
            'Activate_Ecoa_Ediaries',
            'Update_Your_Phone_Number',
            'Select_COI'
        };
        for (Task taskObj : tasksList) {
            if (taskCodeList.contains(taskObj.Task_Code__c)) {
                taskObj.Priority = 'Normal';
            }
            if (taskObj.Activity_Datetime__c != null) {
                if (
                    (tasksWithDue.keySet().contains(taskObj.Activity_Datetime__c) &&
                    taskObj.Priority != 'Critical') ||
                    (taskObj.Priority == 'Critical' &&
                    taskswithCriticalTaskswithDueDate.keySet()
                        .contains(taskObj.Activity_Datetime__c))
                ) {
                    if (taskObj.Priority == 'Critical') {
                        taskswithCriticalTaskswithDueDate.get(taskObj.Activity_Datetime__c)
                            .add(taskObj);
                    } else {
                        tasksWithDue.get(taskObj.Activity_Datetime__c).add(taskObj);
                    }
                } else {
                    if (taskObj.Priority == 'Critical') {
                        taskswithCriticalTaskswithDueDate.put(
                            taskObj.Activity_Datetime__c,
                            new List<Task>{ taskObj }
                        );
                    } else {
                        tasksWithDue.put(taskObj.Activity_Datetime__c, new List<Task>{ taskObj });
                    }
                }
            }
            if (taskObj.Activity_Datetime__c == null && taskObj.Start_Date__c != null) {
                if (
                    (taskswithStartDate.keySet().contains((Datetime) taskObj.Start_Date__c) &&
                    taskObj.Priority != 'Critical') ||
                    (taskObj.Priority == 'Critical' &&
                    taskswithCriticalTaskswithStartDate.keySet()
                        .contains((Datetime) taskObj.Start_Date__c))
                ) {
                    if (taskObj.Priority == 'Critical') {
                        taskswithCriticalTaskswithStartDate.get((Datetime) taskObj.Start_Date__c)
                            .add(taskObj);
                    } else {
                        taskswithStartDate.get((Datetime) taskObj.Start_Date__c).add(taskObj);
                    }
                } else {
                    if (taskObj.Priority == 'Critical') {
                        taskswithCriticalTaskswithStartDate.put(
                            (Datetime) taskObj.Start_Date__c,
                            new List<Task>{ taskObj }
                        );
                    } else {
                        taskswithStartDate.put(
                            (Datetime) taskObj.Start_Date__c,
                            new List<Task>{ taskObj }
                        );
                    }
                }
            }
            if (taskObj.Activity_Datetime__c == null && taskObj.Start_Date__c == null) {
                if (
                    (taskswithCreationDate.keySet().contains(taskObj.CreatedDate) &&
                    taskObj.Priority != 'Critical') ||
                    (taskObj.Priority == 'Critical' &&
                    taskswithCriticalTaskswithCreatedDate.keySet().contains(taskObj.CreatedDate))
                ) {
                    if (taskObj.Priority == 'Critical') {
                        taskswithCriticalTaskswithCreatedDate.get(taskObj.CreatedDate).add(taskObj);
                    } else {
                        taskswithCreationDate.get(taskObj.CreatedDate).add(taskObj);
                    }
                } else {
                    if (taskObj.Priority == 'Critical') {
                        taskswithCriticalTaskswithCreatedDate.put(
                            taskObj.CreatedDate,
                            new List<Task>{ taskObj }
                        );
                    } else {
                        taskswithCreationDate.put(taskObj.CreatedDate, new List<Task>{ taskObj });
                    }
                }
            }
        }
        List<Task> sortedTasksList = new List<Task>();
        sortedTasksList.addAll(sortListOrderbyAsc(taskswithCriticalTaskswithDueDate));
        sortedTasksList.addAll(sortListOrderbyAsc(taskswithCriticalTaskswithStartDate));
        sortedTasksList.addAll(sortListOrderbyDesc(taskswithCriticalTaskswithCreatedDate));
        sortedTasksList.addAll(sortListOrderbyAsc(tasksWithDue));
        sortedTasksList.addAll(sortListOrderbyAsc(taskswithStartDate));
        sortedTasksList.addAll(sortListOrderbyDesc(taskswithCreationDate));
        System.debug(sortedTasksList);
        return sortedTasksList;
    }
    public static List<Task> sortListOrderbyDesc(Map<Datetime, List<Task>> tasksDateListMap) {
        List<Datetime> dateslist = new List<Datetime>();
        List<Task> tasksList = new List<Task>();
        dateslist.addAll(tasksDateListMap.keySet());
        dateslist.sort();
        for (Integer i = dateslist.size() - 1; i >= 0; i--) {
            tasksList.addAll(tasksDateListMap.get(dateslist.get(i)));
        }
        return tasksList;
    }
    public static List<Task> sortListOrderbyAsc(Map<Datetime, List<Task>> tasksDateListMap) {
        List<Datetime> dateslist = new List<Datetime>();
        List<Task> tasksList = new List<Task>();
        dateslist.addAll(tasksDateListMap.keySet());
        dateslist.sort();
        for (Datetime dt : dateslist) {
            tasksList.addAll(tasksDateListMap.get(dt));
        }
        return tasksList;
    }

    public static List<Task> gropupCompletedTasks(List<Task> tasksList) {
        List<Task> completedTaskList = new List<Task>();
        List<Task> ignoreTaskList = new List<Task>();
        List<Task> expiredTaskList = new List<Task>();
        List<Task> resultSortedList = new List<Task>();

        for (Task taskObj : tasksList) {
            if (taskObj.Status == 'Completed') {
                completedTaskList.add(taskObj);
            }
            if (taskObj.Status == 'Ignored') {
                ignoreTaskList.add(taskObj);
            }
            if (taskObj.Status == 'Expired') {
                expiredTaskList.add(taskObj);
            }
        }
        resultSortedList.addAll(processSortingForComplete(completedTaskList, 'Completed'));
        resultSortedList.addAll(processSortingForComplete(ignoreTaskList, 'Ignored'));
        resultSortedList.addAll(processSortingForComplete(expiredTaskList, 'Expired'));

        return resultSortedList;
    }

    public static List<Task> processSortingForComplete(List<Task> tasksList, String taskStatus) {
        Map<Datetime, List<Task>> tasksMapwithDueDate = new Map<Datetime, List<Task>>();
        Map<Datetime, List<Task>> tasksMapwithStartDate = new Map<Datetime, List<Task>>();
        Map<Datetime, List<Task>> tasksMapwithCreatedDate = new Map<Datetime, List<Task>>();
        Map<Datetime, List<Task>> tasksMapwithCompletedDate = new Map<Datetime, List<Task>>();
        Map<Datetime, List<Task>> tasksMapwithExpiredDate = new Map<Datetime, List<Task>>();
        List<Task> sortedTasksList = new List<Task>();

        List<String> taskCodeList = new List<String>{
            'Complete_Survey',
            'Complete_Your_Profile',
            'Activate_Ecoa_Ediaries',
            'Update_Your_Phone_Number',
            'Select_COI'
        };
        for (Task taskObj : tasksList) {
            if (taskCodeList.contains(taskObj.Task_Code__c)) {
                taskObj.Priority = 'Normal';
            }

            if (taskObj.Completed_Date__c != null && taskObj.Status == 'Completed') {
                if (tasksMapwithCompletedDate.keySet().contains(taskObj.Completed_Date__c)) {
                    tasksMapwithCompletedDate.get(taskObj.Completed_Date__c).add(taskObj);
                } else {
                    tasksMapwithCompletedDate.put(
                        taskObj.Completed_Date__c,
                        new List<Task>{ taskObj }
                    );
                }
            }
            if (taskObj.Status != 'Completed' && taskObj.Activity_Datetime__c != null) {
                if (tasksMapwithDueDate.keySet().contains(taskObj.Activity_Datetime__c)) {
                    tasksMapwithDueDate.get(taskObj.Activity_Datetime__c).add(taskObj);
                } else {
                    tasksMapwithDueDate.put(
                        taskObj.Activity_Datetime__c,
                        new List<Task>{ taskObj }
                    );
                }
            }
            if (
                taskObj.Status != 'Completed' &&
                taskObj.Activity_Datetime__c == null &&
                taskObj.Start_Date__c != null
            ) {
                if (tasksMapwithStartDate.keySet().contains((Datetime) taskObj.Start_Date__c)) {
                    tasksMapwithStartDate.get((Datetime) taskObj.Start_Date__c).add(taskObj);
                } else {
                    tasksMapwithStartDate.put(
                        (Datetime) taskObj.Start_Date__c,
                        new List<Task>{ taskObj }
                    );
                }
            }
            if (
                taskObj.Status != 'Completed' &&
                taskObj.Activity_Datetime__c == null &&
                taskObj.Start_Date__c == null
            ) {
                if (tasksMapwithCreatedDate.keySet().contains(taskObj.CreatedDate)) {
                    tasksMapwithCreatedDate.get(taskObj.CreatedDate).add(taskObj);
                } else {
                    tasksMapwithCreatedDate.put(taskObj.CreatedDate, new List<Task>{ taskObj });
                }
            }
            if (
                taskObj.Status != 'Completed' &&
                taskObj.Task_Type__c == 'Survey' &&
                taskObj.Survey_Invitation__c != null &&
                taskObj.Activity_Datetime__c == null
            ) {
                if (
                    tasksMapwithExpiredDate.keySet()
                        .contains(taskObj.Survey_Invitation__r.ExpireDateTime__c)
                ) {
                    tasksMapwithExpiredDate.get(taskObj.Survey_Invitation__r.ExpireDateTime__c)
                        .add(taskObj);
                } else {
                    tasksMapwithExpiredDate.put(
                        taskObj.Survey_Invitation__r.ExpireDateTime__c,
                        new List<Task>{ taskObj }
                    );
                }
            }
        }

        if (taskStatus == 'Completed') {
            sortedTasksList.addAll(sortListOrderbyDesc(tasksMapwithCompletedDate));
        }
        if (taskStatus == 'Ignored') {
            sortedTasksList.addAll(sortListOrderbyAsc(tasksMapwithDueDate));
            sortedTasksList.addAll(sortListOrderbyAsc(tasksMapwithStartDate));
            sortedTasksList.addAll(sortListOrderbyDesc(tasksMapwithCreatedDate));
        }
        if (taskStatus == 'Expired') {
            sortedTasksList.addAll(sortListOrderbyDesc(tasksMapwithDueDate));
            sortedTasksList.addAll(sortListOrderbyDesc(tasksMapwithExpiredDate));
        }
        return sortedTasksList;
    }
}
