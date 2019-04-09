/**
 * Created by Leonid Bartenev
 */

public class TasksRemote {
    
    @AuraEnabled
    public static List<Task> getPreviewTasks(){
        try {
            return TaskService.getPreviewTasks();
        }catch (Exception e){
            AuraHelper.throwException(e);
        }
        return null;
    }
    
    public class ParticipantTasks{
        @AuraEnabled public List<OpenTask> openTasksWrapper;
        @AuraEnabled public List<Task> completedTasks;
    }

    public class OpenTask{
        @AuraEnabled public Task openTask;
        @AuraEnabled public String originator;
    }
    
    @AuraEnabled
    public static ParticipantTasks getParticipantTasks(){
        try{
            ParticipantTasks participantTasks = new ParticipantTasks();
            List<Task> openTasks = new List<Task>();
            openTasks = TaskService.getOpenTasks();
            participantTasks.openTasksWrapper = new List<OpenTask>();
            for(Task task : openTasks){
                OpenTask taskWrapper = new OpenTask();
                taskWrapper.openTask = task;
                participantTasks.openTasksWrapper.add(taskWrapper);
            }

            participantTasks.completedTasks = TaskService.getCompletedTasks();
            createOriginatorsList(participantTasks.openTasksWrapper);
            return participantTasks;
        }catch (Exception e){
            AuraHelper.throwException(e);
        }
        return null;
    }
    
    @AuraEnabled
    public static ParticipantTasks ignoreTask(Id taskId){
        try{
            TaskService.ignoreTask(taskId);
            return getParticipantTasks();
        }catch (Exception e){
            AuraHelper.throwException(e);
        }
        return null;
    }
    
    @AuraEnabled
    public static ParticipantTasks completeTask(Id taskId){
        try{
            TaskService.completeTask(taskId);
            return getParticipantTasks();
        }catch (Exception e){
            AuraHelper.throwException(e);
        }
        return null;
    }
    
    private static void createOriginatorsList(List<OpenTask> tasks) {
        Id participantId;
        Set<Id> delegateIds = new Set<Id>(PatientDelegateService.getDelegatedParticipantUserIds());
        if(ParticipantService.getParticipantState().isDelegate){
            participantId = PatientDelegateService.getDelegatePatientUserId();
        } else {
            participantId = UserInfo.getUserId();
        }
        for(OpenTask taskWrapper : tasks){
            if(taskWrapper.openTask.CreatedById == participantId){
                taskWrapper.originator = Label.Patient;
            } else if(delegateIds.contains(taskWrapper.openTask.CreatedById)){
                taskWrapper.originator = Label.Delegate;
            } else {
                taskWrapper.originator = Label.Admin;
            }
        }
    }
    

}