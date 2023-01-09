public without sharing class Batch_CompleteEcoaTasks extends Batch_ScheduledAbstract {
    public Database.QueryLocator start(Database.BatchableContext bc) {
       return Database.getQueryLocator(
            [
               SELECT Id,Start_Date__c
               FROM Task 
               WHERE Ecoa_Task_Configuration_del__r.Diary_Status__c = 'completed' AND 
               Status = 'Open' AND
               Task_Type__c =: TaskService.TASK_TYPE_ECOA
            ]
        );
    }
    public void execute(Database.BatchableContext bc, List<Task> taskConfigList) {
        EcoaTaskService.completeTask(taskConfigList);
    }
    public override Type getType() {
        return Batch_CompleteEcoaTasks.class;
    }

    public override virtual String getBatchDescription() {
        return 'Complete task in PP if diary completed';
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 2;
    }

    public override Integer getRecommendedScopeSize() {
        return 50;
    }
    

}
