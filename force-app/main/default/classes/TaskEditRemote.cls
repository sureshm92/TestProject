/**
 * Created by mkotenev on 3/5/2019.
 */

public without sharing class TaskEditRemote {

    @AuraEnabled
    public static Task getTaskById(Id taskId) {
        try {
            return TaskService.getTask(taskId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String upsertTask(Task paramTask) {
        try{
            if (paramTask.OwnerId == null) {
                paramTask.OwnerId = Id.valueOf(UserInfo.getUserId());
            }
            upsert paramTask;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }

        return 'Success';
    }

    @AuraEnabled
    public static String deleteTask(Task paramTask) {
        try {
            delete paramTask;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }

        return 'Success';
    }

    @AuraEnabled
    public static String markAsCompleted(Task paramTask) {
        try {
            paramTask.Status = 'Completed';
            upsert paramTask;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }

        return 'Success';
    }
}