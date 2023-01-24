/**
* Created by Sravani on  7/28/2021 for PEH-3721.
*/ 
public class Batch_CreateRecurringAdminTask extends Batch_ScheduledAbstract {
    private String query;
    private List<Manual_Creation_Panel_Task__c> manualConfigList;
    
    public Batch_CreateRecurringAdminTask() {
        this.query = 'Select Task_Name__c, Recurrence_End_Date__c, Last_Recurrence_Reminder__c, Status__c, Start_Date__c,Reminder_Date__c, Next_Due_Date__c, Next_Reminder_Date__c, Next_Occurence_Date__c, Last_Occurrence_Date__c, TaskConfig__c, TaskFilter__c from Manual_Creation_Panel_Task__c where Status__c = \'Active\' and Next_Occurence_Date__c <= TOMORROW';
        this.manualConfigList = new List<Manual_Creation_Panel_Task__c>();
    }
    
    public Database.QueryLocator start(Database.BatchableContext param) {
       return Database.getQueryLocator(this.query);
    }
    
    public void execute(Database.BatchableContext param, List<Manual_Creation_Panel_Task__c> manualTasks) {
        Map<Id, List<Id>> whatIdByContactIds = new Map<Id, List<Id>>();
        set<id> contactWithoutUser = new set<Id>();
        Map<id,String> idTypeOfContactMap = new Map<id,String>();
        
        ManualTaskFilter filter = (ManualTaskFilter) JSON.deserialize(
            manualTasks[0].TaskFilter__c,
            ManualTaskFilter.class
        );
        TaskService.TaskConfig taskConfig = (TaskService.TaskConfig) JSON.deserialize(
            manualTasks[0].TaskConfig__c,
            TaskService.TaskConfig.class
        );
        taskConfig.subject = manualTasks[0].Task_Name__c;
        taskConfig.startDate = manualTasks[0].Next_Occurence_Date__c;
        taskConfig.endTime = manualTasks[0].Next_Due_Date__c;
        if(taskConfig.isRecurrence && manualTasks[0].Next_Reminder_Date__c != null){	
            taskConfig.reminderDate = manualTasks[0].Next_Reminder_Date__c;	
        }
        if((!taskConfig.isRecurrence) && manualTasks[0].Reminder_Date__c != null){	
            taskConfig.reminderDate = manualTasks[0].Reminder_Date__c;	
        }
        whatIdByContactIds = filter.getContactsWithWhatIds(taskConfig);
        idTypeOfContactMap = ManualTaskFilter.IdTypeOfContactMap;
        System.enqueueJob(new BatchQueueableforAdminTasks(whatIdByContactIds,taskConfig,idTypeOfContactMap));
        updateManualTaskConfig(manualTasks[0], taskConfig);
    }
    
    public override void finalAction() {
        try{
            if(manualConfigList.size() != 0){
                Database.update(manualConfigList);
            }
        }catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
    public void updateManualTaskConfig(Manual_Creation_Panel_Task__c manualTask, TaskService.TaskConfig taskConfig){
        manualTask.Last_Occurrence_Date__c = manualTask.Next_Occurence_Date__c;
        if(taskConfig.isRecurrence){
            manualTask.Last_Recurrence_Reminder__c = manualTask.Next_Reminder_Date__c;
            if(manualTask.Next_Due_Date__c != manualTask.Recurrence_End_Date__c){
                if(taskConfig.recurrenceFrequency == 'Daily'){
                manualTask.Next_Occurence_Date__c = taskConfig.startDate + 1;
                manualTask.Next_Due_Date__c = taskConfig.endTime + 1;
                }
                if(taskConfig.recurrenceFrequency == 'Weekly'){
                    manualTask.Next_Occurence_Date__c = taskConfig.startDate.addDays(7);
                    manualTask.Next_Due_Date__c = taskConfig.endTime.addDays(7);
                }
                if(taskConfig.recurrenceFrequency == 'Monthly'){
                    manualTask.Next_Occurence_Date__c = taskConfig.startDate.addMonths(1);
                    manualTask.Next_Due_Date__c = taskConfig.endTime.addMonths(1);
                }
                if(taskConfig.recurrenceFrequency == 'Yearly'){
                    manualTask.Next_Occurence_Date__c = taskConfig.startDate.addYears(1);
                    manualTask.Next_Due_Date__c = taskConfig.endTime.addYears(1);
                }
                if(manualTask.Next_Due_Date__c > manualTask.Recurrence_End_Date__c){
                    manualTask.Next_Due_Date__c = manualTask.Recurrence_End_Date__c;
                }
                manualConfigList.add(manualTask);
            }
            else{
                manualTask.Next_Occurence_Date__c = null;
                manualTask.Next_Due_Date__c = null;
                manualTask.Status__c = 'Completed';
                manualConfigList.add(manualTask);
            }
        }else{	
            	manualTask.Last_Recurrence_Reminder__c = manualTask.Reminder_Date__c;	
                manualTask.Next_Occurence_Date__c = null;	
                manualTask.Next_Due_Date__c = null;	
            	manualTask.Reminder_Date__c = null;	
                manualTask.Status__c = 'InProgress';	
                manualConfigList.add(manualTask);	
            }
    }
    public override Type getType() {
        return Batch_CreateRecurringAdminTask.class;
    }

    public override String getBatchDescription() {
        return 'This job creates recurring tasks';
    }
    public override String getRecommendedIntervalMode() {
        return Batch_ScheduledAbstract.INTERVAL_DAYS;
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 1;
    }
    public override Integer getRecommendedScopeSize() {
        return 1;
    }
}