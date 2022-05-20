/**
* Created by Ranjit R on  4/25/2022 for PEH-4149.
*/
public class EcoaTaskConfigTriggerHandler {

    public class MarkEcoaTaskCompleted extends TriggerHandler {
        public override void beforeUpdate(List<SObject> newList, Map<id, SObject> oldMap) {
            Ecoa_Task_Configuration__c completefEconfigTask = new Ecoa_Task_Configuration__c();
            List<Ecoa_Task_Configuration__c> resetConfiTaskStatus = new List<Ecoa_Task_Configuration__c>();
            Set<Id> completefEconfigTaskIds = new Set<Id>();
            List<Ecoa_Task_Configuration__c> isProcessedReset = new List<Ecoa_Task_Configuration__c>();
            
            for(Ecoa_Task_Configuration__c eConfig :(List<Ecoa_Task_Configuration__c>)newList){
                Ecoa_Task_Configuration__c oldEconfig = (Ecoa_Task_Configuration__c)oldMap.get(eConfig.id);
                Boolean statusChanged = oldEconfig.Diary_Status__c != eConfig.Diary_Status__c ? true : false;
                Boolean dateChanged = oldEconfig.Window_Begin__c != eConfig.Window_Begin__c ? true : false;
                if(eConfig.IsProcessed__c  && 
                statusChanged &&
                eConfig.Diary_Status__c == 'completed'){ // task completion logic
                    //completefEconfigTask.add(eConfig);
                    completefEconfigTaskIds.add(eConfig.Id);
                   // eConfig.Diary_Status__c = 'required';
                    //resetConfiTaskStatus.add(eConfig);
                }
                if(eConfig.IsProcessed__c  && 
                eConfig.Diary_Status__c == 'required' &&
                dateChanged                
                ){
                    //mark is processed false
                    eConfig.IsProcessed__c = false;
                    isProcessedReset.add(eConfig);
                }
            }
            if ( completefEconfigTaskIds != null && !completefEconfigTaskIds.isEmpty() ) {
                markTaskAsCompleted(completefEconfigTaskIds);
            }
            if ( isProcessedReset != null && !isProcessedReset.isEmpty() ) {
                try{
                    update isProcessedReset;
                }Catch(Exception e){
                    System.debug('err:'+ e.getMessage());
                    System.debug('err:'+ e.getStackTraceString());
                }
            }
        }
        public void markTaskAsCompleted(Set<Id> eTaskId){
            List<Task> completeTasks = new List<Task>();
            for(Task t:[Select Id,Ecoa_Task_Configuration_del__c,Status 
                        from Task 
                        Where Ecoa_Task_Configuration_del__c IN:eTaskId AND 
                        Start_Date__c < TOMORROW AND
                        Status = 'Open'
            ]){
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
