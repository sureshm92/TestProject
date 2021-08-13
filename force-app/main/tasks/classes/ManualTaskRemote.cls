/**
 * Created by Igor Malyuta on 01.03.2019.
 */

public with sharing class ManualTaskRemote {
    public static Boolean createTasks(TaskService.TaskConfig taskConfig, ManualTaskFilter filter) {
        try {
            system.debug('******filterLINE8>>'+taskConfig);
            //system.debug('******filterLINE8>>'+filter + 'ManualTaskFilter.IdTypeOfContactMap: '+ManualTaskFilter.IdTypeOfContactMap);
            //Batch_CreateAdminTasks.launch(filter.getContactsWithWhatIds(taskConfig), taskConfig,filter.IdTypeOfContactMap);
            Batch_CreateAdminTasks.launch(filter.getContactsWithWhatIds(taskConfig), taskConfig, ManualTaskFilter.IdTypeOfContactMap);
            return true;
        } catch (Exception e) {
            return (Boolean) AuraHelper.throwException(e);
        }
    }
    public static void createManualConfigTasks(String config, String filter, TaskService.TaskConfig taskConfig) {
        List<Manual_Creation_Panel_Task__c> manualTaskLists = new List<Manual_Creation_Panel_Task__c>();
        try {
            Date nextTaskDueDate;
            TaskService.TaskConfig actualTaskConfig = (TaskService.TaskConfig) JSON.deserialize(
                    config,
                    TaskService.TaskConfig.class
                );
                if(taskConfig.recurrenceFrequency == 'Daily'){
                    nextTaskDueDate = taskConfig.endTime.addDays(1);
                }
                if(taskConfig.recurrenceFrequency == 'Weekly'){
                    nextTaskDueDate = taskConfig.endTime.addDays(7);
                }
                if(taskConfig.recurrenceFrequency == 'Monthly'){
                    nextTaskDueDate = taskConfig.endTime.addMonths(1);
                }
                if(taskConfig.recurrenceFrequency == 'Yearly'){
                    nextTaskDueDate = taskConfig.endTime.addYears(1);
                }
            Manual_Creation_Panel_Task__c manualTask = new Manual_Creation_Panel_Task__c();
            manualTaskLists.add(
                        new Manual_Creation_Panel_Task__c(
                            Name = taskConfig.subject,
                            TaskConfig__c = config,
                            TaskFilter__c = filter,
                            Last_Occurrence_Date__c = Date.today(),
                            Next_Occurence_Date__c = date.newinstance(taskConfig.endTime.addDays(1).year(), taskConfig.endTime.addDays(1).month(), taskConfig.endTime.addDays(1).day()),
                            Is_Recurrence__c =  taskConfig.isRecurrence,
                            Start_Date__c = actualTaskConfig.startDate,
                            Recurrence_End_Date__c = actualTaskConfig.endTime,
                            Recurrence_Frequency__c = taskConfig.recurrenceFrequency,
                            Next_Due_Date__c = nextTaskDueDate,
                            Reminder_days_before_due_date__c = taskConfig.reminderDays
                        )
                    );
            Database.insert(manualTaskLists, true);
        } catch (Exception e) {
            System.debug('Exception Occured : '+e);
        }
    }

    public class TaskPanelWrapper {
        @AuraEnabled
        public TaskService.TaskConfig taskConfig;
        @AuraEnabled
        public Date nowDate;
        @AuraEnabled
        public List<LabelValueItem> priorities;
        @AuraEnabled
        public List<LabelValueItem> visibility;

        public TaskPanelWrapper() {
            taskConfig = new TaskService.TaskConfig();
            taskConfig.priority = 'Normal';
            taskConfig.visibility = 'Owner;Delegates';

            nowDate = Date.today();

            priorities = new List<LabelValueItem>();
            priorities.add(new LabelValueItem('Not selected', 'Normal'));
            priorities.add(new LabelValueItem('Critical', 'Critical'));

            visibility = new List<LabelValueItem>();
            visibility.add(new LabelValueItem('All', 'Owner;Delegates'));
            visibility.add(new LabelValueItem('Patients only', 'Owner'));
            visibility.add(new LabelValueItem('Delegates only', 'Delegates'));
        }
    }
}