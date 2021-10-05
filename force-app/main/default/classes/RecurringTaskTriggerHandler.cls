/**
* Created by Sravani on  8/23/2021 for PEH-3800.
*/
public class RecurringTaskTriggerHandler {
    public class UpdateRecurringTaskonEndDateChange extends TriggerHandler {
        public override void beforeUpdate(List<SObject> newList, Map<id, SObject> oldMap) {
            try{
                for(Manual_Creation_Panel_Task__c rTask: (List<Manual_Creation_Panel_Task__c>)newList){
                    Manual_Creation_Panel_Task__c oldRTask = (Manual_Creation_Panel_Task__c)oldMap.get(rTask.id);
                    if(rTask.Start_Date__c != oldRTask.Start_Date__c){
                        rTask.Next_Occurence_Date__c = rTask.Start_Date__c;
                        dueDateUpdate(rTask);
                    }
                    if(rTask.Recurrence_End_Date__c != oldRTask.Recurrence_End_Date__c){
                        if(rTask.Recurrence_End_Date__c < rTask.Next_Occurence_Date__c && 
                          rTask.Recurrence_End_Date__c == rTask.Next_Occurence_Date__c -1){
                            rTask.Next_Occurence_Date__c = null;
                            rTask.Next_Due_Date__c = null;
                            rTask.Status__c = 'Completed';
                        }
                        else if(rTask.Recurrence_End_Date__c >= rTask.Next_Occurence_Date__c && 
                                rTask.Recurrence_End_Date__c < rTask.Next_Due_Date__c){
                                    rTask.Next_Due_Date__c = rTask.Recurrence_End_Date__c;
                                }
                        else if(rTask.Recurrence_End_Date__c > rTask.Next_Due_Date__c){
                            dueDateUpdate(rTask);
                            if(rTask.Next_Due_Date__c > rTask.Recurrence_End_Date__c){
                                rTask.Next_Due_Date__c = rTask.Recurrence_End_Date__c;
                            }
                        }
                    }
                    if(rTask.Recurrence_Frequency__c != oldRTask.Recurrence_Frequency__c){
                        System.debug('Change in feq: '+rTask.Recurrence_Frequency__c);
                        
                        nextOccDateUpdate(rTask);
                        dueDateUpdate(rTask);
                    }
                }
                
            }
            catch(Exception e){
                System.debug(e);
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
        public void nextOccDateUpdate(Manual_Creation_Panel_Task__c rTask){
            Date firstRecDate;
            if(rTask.Recurrence_Frequency__c == 'Daily'){
                rTask.Next_Occurence_Date__c = Date.today().addDays(1);
            }
            if(rTask.Recurrence_Frequency__c == 'Weekly'){
                firstRecDate = rTask.Start_Date__c.addDays(7);
                while (firstRecDate <= Date.today()) {
                    firstRecDate = firstRecDate.addDays(7);
                }
                rTask.Next_Occurence_Date__c = firstRecDate;
            }
            if(rTask.Recurrence_Frequency__c == 'Yearly'){
                firstRecDate = rTask.Start_Date__c.addYears(1);
                while (firstRecDate <= Date.today()) {
                    firstRecDate = firstRecDate.addYears(1);
                }
                rTask.Next_Occurence_Date__c = firstRecDate;
            }
            if(rTask.Recurrence_Frequency__c == 'Monthly'){
                firstRecDate = rTask.Start_Date__c.addMonths(1);
                while (firstRecDate <= Date.today()) {
                    firstRecDate = firstRecDate.addMonths(1);
                }
                rTask.Next_Occurence_Date__c = firstRecDate;
            }
        }
    }
}