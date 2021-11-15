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
                        if(rTask.Start_Date__c == Date.today()){
                            startDateToday(rTask);
                        }else{
                            rTask.Next_Occurence_Date__c = rTask.Start_Date__c;
                            dueDateUpdate(rTask);
                        }
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
                            if(!rTask.Is_Recurrence__c){
                                rTask.Next_Due_Date__c = rTask.Recurrence_End_Date__c;
                            }
                        }
                    }
                    if(rTask.Recurrence_Frequency__c != oldRTask.Recurrence_Frequency__c){// change in freq
                        System.debug('Change in feq: '+rTask.Recurrence_Frequency__c);
                        
                        nextOccDateUpdate(rTask);
                        dueDateUpdate(rTask);
                    }
                    if(rTask.Is_Recurrence__c != oldRTask.Is_Recurrence__c){// change in recurrence
                        if(!rTask.Is_Recurrence__c){
                            rTask.Next_Due_Date__c = rTask.Recurrence_End_Date__c;
                        }
                    }

                }
                
            }
            catch(Exception e){
                System.debug(e);
            }
            
        }
        public void startDateToday(Manual_Creation_Panel_Task__c rTask){
            rTask.Last_Occurrence_Date__c = Date.today();
            nextOccDateUpdate(rTask);
            dueDateUpdate(rTask);
            TaskService.TaskConfig taskConfig = (TaskService.TaskConfig) JSON.deserialize(
                    rTask.TaskConfig__c,
                    TaskService.TaskConfig.class
                );
            if(taskConfig.isRecurrence){
                if(taskConfig.recurrenceFrequency == 'Daily'){
                    taskConfig.endTime = taskConfig.startDate;
                }
                if(taskConfig.recurrenceFrequency == 'Weekly'){
                    taskConfig.endTime = taskConfig.startDate.addDays(6);
                }
                if(taskConfig.recurrenceFrequency == 'Monthly'){
                    taskConfig.endTime = taskConfig.startDate.addMonths(1).addDays(-1);
                }
                if(taskConfig.recurrenceFrequency == 'Yearly'){
                    taskConfig.endTime = taskConfig.startDate.addYears(1).addDays(-1);
                }
                if(taskConfig.reminderDays != null){
                    taskConfig.reminderDate = taskConfig.endTime.addDays(-taskConfig.reminderDays);
                }
                if(taskConfig.reminderDate < taskConfig.startDate){
                        taskConfig.reminderDate = null;
                }
                
            }
            if(rTask.Is_Recurrence__c){
                if(taskConfig.reminderDays != null){
                    //taskConfig.reminderDate = 
                    rTask.Last_Recurrence_Reminder__c = taskConfig.endTime.addDays(-taskConfig.reminderDays);
                }
            }else{
                rTask.Next_Due_Date__c = null;
                rTask.Next_Occurence_Date__c = null;
                if(taskConfig.reminderDays != null){
                    taskConfig.reminderDate = taskConfig.endTime.addDays(-taskConfig.reminderDays);
                }
                rTask.Last_Recurrence_Reminder__c = taskConfig.reminderDate;
                rTask.Status__c = 'InProgress';
            }
            
            //rTask.TaskConfig__c = JSON.serialize(taskConfig);
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
            if(rTask.Next_Due_Date__c >= rTask.Recurrence_End_Date__c){
                rTask.Next_Due_Date__c = rTask.Recurrence_End_Date__c;
            }
        }
        public void nextOccDateUpdate(Manual_Creation_Panel_Task__c rTask){
            Date firstRecDate;
            if(rTask.Start_Date__c <= Date.today()){
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
            }else{
                rTask.Next_Occurence_Date__c = rTask.Start_Date__c;
            }
        }
    }
}