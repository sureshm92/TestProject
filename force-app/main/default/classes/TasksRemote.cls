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
        @AuraEnabled
        public List<Task> openTasks;
        @AuraEnabled
        public List<Task> completedTasks;
    }
    
    @AuraEnabled
    public static ParticipantTasks getParticipantTasks(){
        try{
            ParticipantTasks participantTasks = new ParticipantTasks();
            participantTasks.openTasks = TaskService.getOpenTasks();
            participantTasks.completedTasks = TaskService.getCompletedTasks();
            return participantTasks;
        }catch (Exception e){
            AuraHelper.throwException(e);
        }
        return null;
    }
    
    @AuraEnabled
    public static ParticipantTasks ignoreTask(Id taskId){
        TaskService.ignoreTask(taskId);
        return getParticipantTasks();
    }
    
    @AuraEnabled
    public static ParticipantTasks completeTask(Id taskId){
        TaskService.completeTask(taskId);
        return getParticipantTasks();
    }

}