public class RecurringTaskTriggerHandler {
    public class UpdateRecurringTaskonEndDateChange extends TriggerHandler {
       public override void beforeUpdate(List<SObject> newList, Map<id, SObject> oldMap) {
           for(Manual_Creation_Panel_Task__c rTask: (List<Manual_Creation_Panel_Task__c>)newList){
               Manual_Creation_Panel_Task__c oldRTask = (Manual_Creation_Panel_Task__c)oldMap.get(rTask.id);
               if(rTask.Start_Date__c != oldRTask.Start_Date__c){
                   rTask.Next_Occurence_Date__c = rTask.Start_Date__c;
                   dueDateUpdate(rTask);
               }
               if(rTask.Recurrence_End_Date__c != oldRTask.Recurrence_End_Date__c){
                   if(rTask.Recurrence_End_Date__c < rTask.Next_Occurence_Date__c){
                       rTask.Next_Occurence_Date__c = null;
                       rTask.Next_Due_Date__c = null;
                       rTask.Status__c = 'Completed';
                   }
                   else if(rTask.Recurrence_End_Date__c >= rTask.Next_Occurence_Date__c && 
                           rTask.Recurrence_End_Date__c < rTask.Next_Due_Date__c){
                            rTask.Next_Due_Date__c = rTask.Recurrence_End_Date__c;
                   }
                   else{
                        dueDateUpdate(rTask);
                       if(rTask.Next_Due_Date__c > rTask.Recurrence_End_Date__c){
                           rTask.Next_Due_Date__c = rTask.Recurrence_End_Date__c;
                       }
                   }
               }
           }
       }
       public void dueDateUpdate(Manual_Creation_Panel_Task__c rTask){
        if(rTask.Recurrence_Frequency__c == 'Daily'){
            rTask.Next_Due_Date__c = rTask.Next_Occurence_Date__c;
        }
        if(rTask.Recurrence_Frequency__c == 'Weekly'){
            rTask.Next_Due_Date__c = rTask.Next_Occurence_Date__c.addDays(6);
        }
        if(rTask.Recurrence_Frequency__c == 'Monthly'){
            rTask.Next_Due_Date__c = rTask.Next_Occurence_Date__c.addMonths(1).addDays(-1);
        }
        if(rTask.Recurrence_Frequency__c == 'Yearly'){
            rTask.Next_Due_Date__c = rTask.Next_Occurence_Date__c.addYears(1).addDays(-1);
        }
       }
   }
}