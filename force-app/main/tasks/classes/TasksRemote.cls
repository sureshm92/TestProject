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
    }

    public class CompletedTask {
        @AuraEnabled
        public Task task;
        @AuraEnabled
        public Date completedDate;
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
                }
                when 'Delegate' {
                    taskWrapper.originator = Label.Delegate;
                }
                when else {
                    taskWrapper.originator = Label.Admin;
                }
            }
        }
    }
}
