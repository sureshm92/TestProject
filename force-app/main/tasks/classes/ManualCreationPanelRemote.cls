/**
 * Created by Igor Malyuta on 16.09.2019.
 */

public without sharing class ManualCreationPanelRemote {
    public class InitData {
        @AuraEnabled
        public ManualTaskRemote.TaskPanelWrapper taskPanelWrapper;
        @AuraEnabled
        public AdHocWrapper adHocWrapper;
        @AuraEnabled
        public ManualTaskFilter filter;
        @AuraEnabled
        public List<LabelValueItem> patientStatusOptions;

        public InitData() {
            taskPanelWrapper = new ManualTaskRemote.TaskPanelWrapper();
            adHocWrapper = new AdHocWrapper();
            filter = new ManualTaskFilter();

            patientStatusOptions = new List<LabelValueItem>{
                new LabelValueItem('Referred', 'Referred'),
                new LabelValueItem('Enrolled', 'Enrolled'),
                new LabelValueItem('Alumni', 'Alumni')
            };
        }
    }

    public class AdHocWrapper {
        @AuraEnabled
        public String selectedSurvey;
        @AuraEnabled
        public Integer daysToExpire;
        @AuraEnabled
        public String selectedRS;
        @AuraEnabled
        public Boolean expireOnAlumni = false;
        @AuraEnabled
        public List<LabelValueItem> neededResponsesOptions = new List<LabelValueItem>{
            new LabelValueItem(
                SurveyService.SURVEY_RESPONSE_PATIENT_ONLY,
                SurveyService.SURVEY_RESPONSE_PATIENT_ONLY
            ),
            new LabelValueItem(
                SurveyService.SURVEY_RESPONSE_PATIENT_EACH_DELEGATE,
                SurveyService.SURVEY_RESPONSE_PATIENT_EACH_DELEGATE
            ),
            new LabelValueItem(
                SurveyService.SURVEY_RESPONSE_PATIENT_ANY_DELEGATE,
                SurveyService.SURVEY_RESPONSE_PATIENT_ANY_DELEGATE
            ),
            new LabelValueItem(
                SurveyService.SURVEY_RESPONSE_ANY_DELEGATE,
                SurveyService.SURVEY_RESPONSE_ANY_DELEGATE
            ),
            new LabelValueItem(
                SurveyService.SURVEY_RESPONSE_EACH_DELEGATE,
                SurveyService.SURVEY_RESPONSE_EACH_DELEGATE
            )
        };
        @AuraEnabled
        public String neededResponse = SurveyService.SURVEY_RESPONSE_PATIENT_ONLY;
    }

    //Remote methods:---------------------------------------------------------------------------------------------------
    @AuraEnabled
    public static InitData getInitData() {
        try {
            return new InitData();
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static Manual_Creation_Panel_Task__c getTaskData(Id recId) {
        Manual_Creation_Panel_Task__c mcpt = [SELECT Id,Country__c,Date_Cancelled_Inactive__c,Is_Recurrence__c,Last_Occurrence_Date__c,
                                                Last_Recurrence_Reminder__c,Make_this_Task_visible_to__c,Next_Occurence_Date__c,Next_Reminder_Date__c,
                                                Next_Due_Date__c,Patient_Status__c,Platform_level_Task__c,Recurrence_Frequency__c,Reminder_days_before_due_date__c,
                                                Site__c,Status__c,Study__c,Recurrence_End_Date__c,Start_Date__c,TaskConfig__c,TaskFilter__c,Therapeutic_Area__c
                                                FROM Manual_Creation_Panel_Task__c 
                                                where Id=:recId];
        return mcpt;
    }

    @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews =
            [SELECT Id, Name FROM ListView WHERE SobjectType = 'Manual_Creation_Panel_Task__c' and Name='All'];

        // Perform isAccessible() check here
        return listviews;
    }

    @AuraEnabled
    public static String createTasks(
        String config,
        String adHoc,
        String filter,
        String activeTab,
        Manual_Creation_Panel_Task__c mcpt    
        ) {
        try {
            System.debug('mcpt: '+mcpt);
            ManualTaskFilter manualTaskFilter = (ManualTaskFilter) JSON.deserialize(
                filter,
                ManualTaskFilter.class
            );
            if (activeTab.equals('task')) {
                TaskService.TaskConfig taskConfig = (TaskService.TaskConfig) JSON.deserialize(
                    config,
                    TaskService.TaskConfig.class
                );
                if(mcpt != null){
                    String retVal = ManualTaskRemote.updateTasks( config, filter, taskConfig, mcpt);
                    return retVal;
                }
                // If the task is recurrence to recalculate the due date and reminder date for PEH-3716
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
                if(taskConfig.startDate > Date.today()){
                    String a = ManualTaskRemote.createManualConfigTasks(true, config, filter, taskConfig,mcpt);
                    System.debug('a1: '+a);
                    return a;
                }
                String a1 = ManualTaskRemote.createManualConfigTasks(false, config, filter, taskConfig,mcpt);
                System.debug('a2: '+a1);
                String mtr = ManualTaskRemote.createTasks(taskConfig, manualTaskFilter);
                System.debug('mtr: '+mtr);
                return a1;                
            } else if (activeTab.equals('adHoc')) {
                AdHocWrapper adHocWrapper = (AdHocWrapper) JSON.deserialize(
                    adHoc,
                    AdHocWrapper.class
                );
                //return createInvitationAndTask(adHocWrapper, manualTaskFilter);
            }
            return 'false';
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    //Search lookup logic: ---------------------------------------------------------------------------------------------
    @AuraEnabled
    public static List<LookupSearchResult> searchSurveys(String searchTerm, String value) {
        try {
            if (searchTerm == null || String.isBlank(searchTerm))
                searchTerm = '';
            searchTerm = '%' + searchTerm + '%';

            List<String> selectedSurveys = new List<String>();
            if (!String.isEmpty(value))
                selectedSurveys = value.split(';');

            List<Survey> surveys = [
                SELECT Id, Name
                FROM Survey
                WHERE
                    ActiveVersionId != NULL
                    AND Id NOT IN :selectedSurveys
                    AND Name LIKE :searchTerm
            ];

            List<LookupSearchResult> resList = new List<LookupSearchResult>();
            for (Survey survey : surveys) {
                resList.add(
                    new LookupSearchResult(
                        survey.Id,
                        'Survey',
                        'standard:survey',
                        survey.Name,
                        null
                    )
                );
            }

            return resList;
        } catch (Exception e) {
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static List<LookupSearchResult> searchSurveysByValue(String value) {
        try {
            List<LookupSearchResult> resList = new List<LookupSearchResult>();
            if (value == null || String.isBlank(value))
                return resList;

            List<String> selectedSurveys = value.split(';');
            List<Survey> surveys = [
                SELECT Id, Name
                FROM Survey
                WHERE ActiveVersionId != NULL AND Id IN :selectedSurveys
            ];

            for (Survey survey : surveys) {
                resList.add(
                    new LookupSearchResult(
                        survey.Id,
                        'Survey',
                        'standard:survey',
                        survey.Name,
                        null
                    )
                );
            }

            return resList;
        } catch (Exception e) {
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static List<LookupSearchResult> searchReminderSchedule(String searchTerm, String value) {
        try {
            if (searchTerm == null || String.isBlank(searchTerm))
                searchTerm = '';
            searchTerm = '%' + searchTerm;

            List<String> selectedRS = new List<String>();
            if (!String.isEmpty(value))
                selectedRS = value.split(';');

            List<Reminder_Schedule__c> reminderSchedules = [
                SELECT Id, Name, First_Reminder_day__c, Second_Reminder_day__c
                FROM Reminder_Schedule__c
                WHERE Id NOT IN :selectedRS AND Name LIKE :searchTerm
            ];

            List<LookupSearchResult> resList = new List<LookupSearchResult>();
            for (Reminder_Schedule__c rs : reminderSchedules) {
                resList.add(
                    new LookupSearchResult(
                        rs.Id,
                        'Reminder_Schedule__c',
                        'standard:announcement',
                        rs.Name,
                        'First = ' +
                        rs.First_Reminder_day__c +
                        '; Second = ' +
                        rs.Second_Reminder_day__c
                    )
                );
            }

            return resList;
        } catch (Exception e) {
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static List<LookupSearchResult> searchReminderScheduleByValue(String value) {
        try {
            List<LookupSearchResult> resList = new List<LookupSearchResult>();
            if (value == null || String.isBlank(value))
                return resList;

            List<String> selectedRS = value.split(';');
            List<Reminder_Schedule__c> reminderSchedules = [
                SELECT Id, Name, First_Reminder_day__c, Second_Reminder_day__c
                FROM Reminder_Schedule__c
                WHERE Id IN :selectedRS
            ];

            for (Reminder_Schedule__c rs : reminderSchedules) {
                resList.add(
                    new LookupSearchResult(
                        rs.Id,
                        'Reminder_Schedule__c',
                        'standard:announcement',
                        rs.Name,
                        'First = ' +
                        rs.First_Reminder_day__c +
                        '; Second = ' +
                        rs.Second_Reminder_day__c
                    )
                );
            }

            return resList;
        } catch (Exception e) {
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }
    }

    //Inner logic:------------------------------------------------------------------------------------------------------
    @TestVisible
    private static Boolean createInvitationAndTask(AdHocWrapper wrapper, ManualTaskFilter filter) {
        try {
            Survey survey = [SELECT Id, Name FROM Survey WHERE Id = :wrapper.selectedSurvey];
            List<Reminder_Schedule__c> rsList = [
                SELECT Id
                FROM Reminder_Schedule__c
                WHERE Id = :wrapper.selectedRS
            ];
            Reminder_Schedule__c rs = rsList.isEmpty() ? null : rsList.get(0);

            Map<Id, List<Participant_Enrollment__c>> contactsWithPE = filter.getContactsWithPE();
            Map<String, Id> communitiesMap = CommunityService.getCommunityIdsMap();
            Map<Id, String> networkByPE = new Map<Id, String>();
            for (List<Participant_Enrollment__c> peList : contactsWithPE.values()) {
                for (Participant_Enrollment__c pe : peList) {
                    if (!networkByPE.containsKey(pe.Id)) {
                        String communityName = CommunityTemplateService.getTemplate(
                                pe.Clinical_Trial_Profile__r.CommunityTemplate__c
                            )
                            .communityName;
                        networkByPE.put(pe.Id, communitiesMap.get(communityName));
                    }
                }
            }

            List<SurveyInvitation> newInvitations = new List<SurveyInvitation>();
            for (Id contactId : contactsWithPE.keySet()) {
                for (Participant_Enrollment__c pe : contactsWithPE.get(contactId)) {
                    newInvitations.add(
                        SurveyService.getInstance()
                            .generateInvitation(
                                survey,
                                rs,
                                wrapper.daysToExpire,
                                wrapper.expireOnAlumni,
                                pe.Id,
                                networkByPE.get(pe.Id)
                            )
                    );
                }
            }

            if (!newInvitations.isEmpty()) {
                insert newInvitations;

                Map<Id, String> invitationsVisible = new Map<Id, String>();
                for (SurveyInvitation inv : newInvitations)
                    invitationsVisible.put(inv.Id, wrapper.neededResponse);

                Batch_CreateSurveyTasks.launch(invitationsVisible);
                return true;
            }
        } catch (Exception e) {
            return (Boolean) AuraHelper.throwException(e);
        }
        return false;
    }
}