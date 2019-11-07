/**
 * Created by Leonid Bartenev
 */

public class TasksRemote {

    public class ParticipantTasks {
        @AuraEnabled public List<OpenTask> openTasksWrapper;
        @AuraEnabled public List<CompletedTask> completedTasks;
        @AuraEnabled public String emptyText;
    }

    public class OpenTask {
        @AuraEnabled public Task openTask;
        @AuraEnabled public String originator;
        @AuraEnabled public Date activityDate;
        @AuraEnabled public Date reminder;
    }

    public class CompletedTask {
        @AuraEnabled public Task task;
        @AuraEnabled public Date completedDate;
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
            TimeZone timezone = DateTimeConverterUtil.getUserTimeZone(CommunityService.getInstance().getCurrentContactId());

            List<Task> openTasks = TaskService.getInstance().getOpenTasks();
            for (Task task : openTasks) {
                OpenTask taskWrapper = new OpenTask();
                taskWrapper.openTask = task;

                if (task.Activity_Datetime__c != null) {
                    taskWrapper.activityDate =
                            DateTimeConverterUtil.getUserDatetime(timezone, task.Activity_Datetime__c).date();
                }
                if (task.ReminderDateTime != null) {
                    taskWrapper.reminder =
                            DateTimeConverterUtil.getUserDatetime(timezone, task.ReminderDateTime).date();
                }

                participantTasks.openTasksWrapper.add(taskWrapper);
            }
            createOriginatorsList(participantTasks.openTasksWrapper);

            participantTasks.completedTasks = new List<TasksRemote.CompletedTask>();
            List<Task> completedTasks = TaskService.getInstance().getCompletedTasks();
            for (Task compTask : completedTasks) {
                CompletedTask completedTask = new CompletedTask();
                completedTask.task = compTask;
                if (compTask.Completed_Date__c != null) {
                    completedTask.completedDate =
                            DateTimeConverterUtil.getUserDatetime(timezone, compTask.Completed_Date__c).date();
                }

                participantTasks.completedTasks.add(completedTask);
            }

            ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
            if (participantState.isDelegate) {
                participantTasks.emptyText = Label.PG_Task_Tab_No_Tasks_Delegate.replace(
                        '##ParticipantFirstName', participantState.participant.First_Name__c);
            } else {
                participantTasks.emptyText = Label.PG_Task_Tab_No_Tasks;
            }
        } catch (Exception e) {
            return (ParticipantTasks) AuraHelper.throwException(e);
        }
        return participantTasks;
    }

    private static void createOriginatorsList(List<OpenTask> tasks) {
        Id participantId;
        Set<Id> delegateIds = new Set<Id>(PatientDelegateService.getInstance().getDelegatedUsersIds());
        if (ParticipantService.getParticipantState().isDelegate) {
            participantId = PatientDelegateService.getInstance().getParticipantUserId();
        } else {
            participantId = UserInfo.getUserId();
        }
        for (OpenTask taskWrapper : tasks) {
            if (taskWrapper.openTask.CreatedById == participantId) {
                taskWrapper.originator = Label.Patient;
            } else if (delegateIds.contains(taskWrapper.openTask.CreatedById)) {
                taskWrapper.originator = Label.Delegate;
            } else {
                taskWrapper.originator = Label.Admin;
            }
        }
    }
}
