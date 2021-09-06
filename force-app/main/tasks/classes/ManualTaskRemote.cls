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
    
    //To create a record for recurring task PEH-3716
    public static void createManualConfigTasks(Boolean isFirst, String config, String filter, TaskService.TaskConfig taskConfig) {
        List<Manual_Creation_Panel_Task__c> manualTaskLists = new List<Manual_Creation_Panel_Task__c>();
        try {
            Date nextTaskDueDate;
            Date lastOccurenceDate;
            Date lastReminderDate;
            Date nextTaskStartDate; 
            TaskService.TaskConfig actualTaskConfig = (TaskService.TaskConfig) JSON.deserialize(
                    config,
                    TaskService.TaskConfig.class
                );
            if(isFirst){
                nextTaskDueDate = taskConfig.endTime;
                nextTaskStartDate = taskConfig.startDate;
            }
            else{
                lastOccurenceDate = Date.today();
                lastReminderDate = taskConfig.reminderDate;
                nextTaskStartDate = date.newinstance(taskConfig.endTime.addDays(1).year(), taskConfig.endTime.addDays(1).month(), taskConfig.endTime.addDays(1).day());
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
                if(nextTaskDueDate > actualTaskConfig.endTime){
                    nextTaskDueDate = actualTaskConfig.endTime;
                }
            }
            Manual_Creation_Panel_Task__c manualTask = new Manual_Creation_Panel_Task__c();
            ManualTaskFilter mtf = (ManualTaskFilter) JSON.deserialize(filter,ManualTaskFilter.class);
            List<LookupSearchResult> lsr = mtf.areas;//theraputic
            List<LookupSearchResult> counties = mtf.countries;//countries
            List<LookupSearchResult> studies = mtf.studies;//studies
            List<LookupSearchResult> sites = mtf.sites;//sites
            List<String> titleString = new List<String>();
            List<String> CountryList = new List<String>();
            List<String> studyList = new List<String>();
            List<String> siteList = new List<String>();
            for(LookupSearchResult l:lsr){
                titleString.add(l.title);
            }
            for(LookupSearchResult l:counties){
                CountryList.add(l.title);
            }
            for(LookupSearchResult l:studies){
                studyList.add(l.subtitle.remove('Code name '));
            }
            for(LookupSearchResult l:sites){
                siteList.add(l.title);
            }
            String visibleTo = taskConfig.visibility;
            Boolean isPlatformLevel = mtf.isPlatformLevel;
            String siteTitle = String.join(siteList, ',');
            String studyTitle = String.join(studyList, ',');
            String countryTitle = String.join(CountryList, ',');
            String ts = String.join(titleString, ',');
            String statusString = String.join(mtf.statuses, ',');
            
            manualTaskLists.add(
                        new Manual_Creation_Panel_Task__c(
                            Task_Name__c = taskConfig.subject,
                            TaskFilter__c = filter,
                            Country__c = countryTitle,
                            Site__c = siteTitle,
                            Make_this_Task_visible_to__c = visibleTo,
                            Platform_level_Task__c = isPlatformLevel,
                            Study__c = studyTitle,
                            Therapeutic_Area__c = ts,
                            TaskConfig__c = config,
                            Patient_Status__c = statusString,
                            Last_Occurrence_Date__c = lastOccurenceDate,
                            Next_Occurence_Date__c = nextTaskStartDate,
                            Is_Recurrence__c =  taskConfig.isRecurrence,
                            Start_Date__c = actualTaskConfig.startDate,
                            Recurrence_End_Date__c = actualTaskConfig.endTime,
                            Recurrence_Frequency__c = taskConfig.recurrenceFrequency,
                            Next_Due_Date__c = nextTaskDueDate,
                            Reminder_days_before_due_date__c = taskConfig.reminderDays,
                            Last_Recurrence_Reminder__c = lastReminderDate
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