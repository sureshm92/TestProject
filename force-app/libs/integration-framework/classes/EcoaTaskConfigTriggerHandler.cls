/**
* Created by Ranjit R on  4/25/2022 for PEH-4149.
*/
public class EcoaTaskConfigTriggerHandler {
    public class MarkEcoaTaskCompleted extends TriggerHandler {
        public override void beforeUpdate(List<SObject> newList, Map<id, SObject> oldMap) {
            Ecoa_Task_Configuration__c completefEconfigTask = new Ecoa_Task_Configuration__c();
            Set<Id> completefEconfigTaskIds = new Set<Id>();
            
            for(Ecoa_Task_Configuration__c eConfig :(List<Ecoa_Task_Configuration__c>)newList){
                Ecoa_Task_Configuration__c oldEconfig = (Ecoa_Task_Configuration__c)oldMap.get(eConfig.id);
                if(eConfig.IsProcessed__c  && 
                oldEconfig.Diary_Status__c != 
                eConfig.Diary_Status__c &&
                eConfig.Diary_Status__c == 'completed'){
                    //completefEconfigTask.add(eConfig);
                    completefEconfigTaskIds.add(eConfig.Id);
                }
            }
            if ( completefEconfigTaskIds != null && !completefEconfigTaskIds.isEmpty() ) {
                markTaskAsCompleted(completefEconfigTaskIds);
            }
        }
        public void markTaskAsCompleted(Set<Id> eTaskId){
            List<Task> completeTasks = new List<Task>();
            for(Task t:[Select Id,Ecoa_Task_Configuration_del__c,Status from Task Where Ecoa_Task_Configuration_del__c IN:eTaskId]){
                t.Status = 'Completed';
                completeTasks.add(t);
            }
            try{
                update completeTasks;
            }Catch(Exception e){
                System.debug('err:'+ e.getMessage());
                System.debug('err:'+ e.getStackTraceString());
            }
            
        }
    }
    
}
