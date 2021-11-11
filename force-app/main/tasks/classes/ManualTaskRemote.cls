/**
 * Created by Igor Malyuta on 01.03.2019.
 */

public with sharing class ManualTaskRemote {
    public static String createTasks(TaskService.TaskConfig taskConfig, ManualTaskFilter filter) {
        List<Manual_Creation_Panel_Task__c> oneTimeTaskLists = new List<Manual_Creation_Panel_Task__c>();
        try {
            system.debug('******filterLINE8>>'+taskConfig);
            //system.debug('******filterLINE8>>'+filter + 'ManualTaskFilter.IdTypeOfContactMap: '+ManualTaskFilter.IdTypeOfContactMap);
            //Batch_CreateAdminTasks.launch(filter.getContactsWithWhatIds(taskConfig), taskConfig,filter.IdTypeOfContactMap);
            Batch_CreateAdminTasks.launch(filter.getContactsWithWhatIds(taskConfig), taskConfig, ManualTaskFilter.IdTypeOfContactMap);
            //return '';
            return 'true';
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }
    
    //To create a record for recurring task PEH-3716
    public static String createManualConfigTasks(Boolean isFirst, String config, String filter, TaskService.TaskConfig taskConfig,Manual_Creation_Panel_Task__c mcpt) {
        List<Manual_Creation_Panel_Task__c> manualTaskLists = new List<Manual_Creation_Panel_Task__c>();
        try {
            Date nextTaskDueDate;
            Date lastOccurenceDate;
            Date lastReminderDate;
            Date nextTaskStartDate;
            Date nextTaskReminderDate;	
            String status = 'Active'; 
            TaskService.TaskConfig actualTaskConfig = (TaskService.TaskConfig) JSON.deserialize(
                    config,
                    TaskService.TaskConfig.class
                );
            if(taskConfig.isRecurrence){
                if(taskConfig.reminderDays == null){
                    taskConfig.reminderDate = null;
                }
            }
            //Manual_Creation_Panel_Task__c manCpt = new Manual_Creation_Panel_Task__c();
            //If start date is future date
            if(isFirst){
                nextTaskDueDate = taskConfig.endTime;
                nextTaskStartDate = taskConfig.startDate;
                if(!taskConfig.isRecurrence){	
                    nextTaskReminderDate = taskConfig.reminderDate;	
                }
            }
            
            else{//If task start date is today.
                lastOccurenceDate = Date.today();
                lastReminderDate = taskConfig.reminderDate;
                if(!taskConfig.isRecurrence){	
                    status = 'Active';	
                }else{
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
            String visibilityStr = taskConfig.visibility.replace('Owner', 'Patients');
            String visibleTo = visibilityStr;
            Boolean isPlatformLevel = mtf.isPlatformLevel;
            String siteTitle = String.join(siteList, ',');
            String studyTitle = String.join(studyList, ',');
            String countryTitle = String.join(CountryList, ',');
            String ts = String.join(titleString, ',');
            String statusString = String.join(mtf.statuses, ',');
             // creting config record
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
                            Last_Recurrence_Reminder__c = lastReminderDate,
                            Status__c = status,	
                            Reminder_Date__c = nextTaskReminderDate
                        )
                    );
            Database.SaveResult[] srList = Database.insert(manualTaskLists, true);
            String insId;
            
                for(Integer i=0;i<srList.size();i++){
                    if (srList.get(i).isSuccess()){
                        insId= srList.get(i).getId();

                    }else if (!srList.get(i).isSuccess()){
                        // DML operation failed
                    }

                }
                return insId;
        } catch (Exception e) {
            System.debug('Exception Occured : '+e);
            return '';
        }
    }
    public static String updateTasks(String config, String filter, TaskService.TaskConfig taskConfig,Manual_Creation_Panel_Task__c mcpt) {
        List<Manual_Creation_Panel_Task__c> manualTaskLists = new List<Manual_Creation_Panel_Task__c>();
        try {
            Date nextTaskDueDate;
            Date lastOccurenceDate;
            Date lastReminderDate;
            Date nextTaskStartDate;
            Date nextTaskReminderDate;	
            String status = 'Active'; 
            TaskService.TaskConfig actualTaskConfig = (TaskService.TaskConfig) JSON.deserialize(
                    config,
                    TaskService.TaskConfig.class
                );
            if(!taskConfig.isRecurrence){
                if(taskConfig.reminderDate != mcpt.Reminder_Date__c){
                    nextTaskReminderDate = taskConfig.reminderDate;
                }
            }
            if(taskConfig.isRecurrence){
                if(taskConfig.reminderDays == null){
                    taskConfig.reminderDate = null;
                }
                if(taskConfig.recurrenceFrequency == 'Daily'){
                    taskConfig.reminderDate = null;
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
            String visibilityStr = taskConfig.visibility.replace('Owner', 'Patients');
            String visibleTo = visibilityStr;
            Boolean isPlatformLevel = mtf.isPlatformLevel;
            String siteTitle = String.join(siteList, ',');
            String studyTitle = String.join(studyList, ',');
            String countryTitle = String.join(CountryList, ',');
            String ts = String.join(titleString, ',');
            String statusString = String.join(mtf.statuses, ',');
            String taskConfigToString = JSON.serialize(taskConfig);

              manualTaskLists.add(
                        new Manual_Creation_Panel_Task__c(
                            Id=mcpt.Id,
                            Task_Name__c = taskConfig.subject,
                            TaskFilter__c = filter,
                            Country__c = countryTitle,
                            Site__c = siteTitle,
                            Make_this_Task_visible_to__c = visibleTo,
                            Platform_level_Task__c = isPlatformLevel,
                            Study__c = studyTitle,
                            Therapeutic_Area__c = ts,
                            TaskConfig__c = taskConfigToString,
                            Patient_Status__c = statusString,
                            //Last_Occurrence_Date__c = lastOccurenceDate,
                            //Next_Occurence_Date__c = nextTaskStartDate,
                            Is_Recurrence__c =  taskConfig.isRecurrence,
                            Start_Date__c = actualTaskConfig.startDate,
                            Recurrence_End_Date__c = actualTaskConfig.endTime,
                            Recurrence_Frequency__c = taskConfig.recurrenceFrequency,
                            //Next_Due_Date__c = nextTaskDueDate,
                            Reminder_days_before_due_date__c = taskConfig.reminderDays,
                            Last_Recurrence_Reminder__c = lastReminderDate,
                            Status__c = status,	
                            Reminder_Date__c = nextTaskReminderDate
                        )
                    );
                    Database.SaveResult[] srList = Database.update(manualTaskLists, true);
                    String insId;
                    if(taskConfig.startDate == Date.today()){
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
                            
                        }else{
                            //one time
                        }
                        if(taskConfig.startDate != mcpt.Start_Date__c){
                            createTasks(taskConfig,mtf);
                        }
                    }
                    for(Integer i=0;i<srList.size();i++){
                        if (srList.get(i).isSuccess()){
                            insId= srList.get(i).getId();

                        }else if (!srList.get(i).isSuccess()){
                            // DML operation failed
                        }

                    }
                    return insId;
        } catch (Exception e) {
            System.debug('Exception Occured : '+e);
            return '';
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
            visibility.add(new LabelValueItem('Patients', 'Owner'));
            visibility.add(new LabelValueItem('Delegates', 'Delegates'));
        }
    }
}