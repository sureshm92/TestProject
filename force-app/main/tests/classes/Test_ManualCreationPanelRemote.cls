/**
 * Created by Igor Malyuta on 01.10.2019.
 */
@IsTest
private class Test_ManualCreationPanelRemote {
    @IsTest
    static void testTaskCreation() {
        TestData.loadTestData();

        ManualTaskFilter filter = new ManualTaskFilter();
        filter.statuses = new List<String>{ PEStatusState.PE_ST_REFERRED };

        TaskService.TaskConfig taskConfig = new TaskService.TaskConfig();
        taskConfig.subject = 'Test';
        taskConfig.startDate = System.today();
        taskConfig.endTime = System.today();
        taskConfig.reminderDate = System.today();
        taskConfig.visibility = 'Owner;Delegates';
        taskConfig.isRecurrence = true;
        taskConfig.recurrenceFrequency = 'Daily';
        
        ManualCreationPanelRemote.AdHocWrapper adHocWrapper = new ManualCreationPanelRemote.AdHocWrapper();

        Test.startTest();
        ManualCreationPanelRemote.getInitData();
        ManualCreationPanelRemote.createTasks(
            JSON.serialize(taskConfig),
            JSON.serialize(adHocWrapper),
            JSON.serialize(filter),
            'task'
        );
        Test.stopTest();
    }
    
    @IsTest
    static void testTaskCreationWeekly() {
        TestData.loadTestData();

        ManualTaskFilter filter = new ManualTaskFilter();
        filter.statuses = new List<String>{ PEStatusState.PE_ST_REFERRED };

        TaskService.TaskConfig taskConfig = new TaskService.TaskConfig();
        taskConfig.subject = 'Test';
        taskConfig.startDate = System.today().addDays(1);
        taskConfig.endTime = System.today().addDays(14);
        taskConfig.reminderDays = 10;
        taskConfig.visibility = 'Owner;Delegates';
        taskConfig.isRecurrence = true;
        taskConfig.recurrenceFrequency = 'Weekly';
        
        ManualCreationPanelRemote.AdHocWrapper adHocWrapper = new ManualCreationPanelRemote.AdHocWrapper();

        Test.startTest();
        ManualCreationPanelRemote.getInitData();
        ManualCreationPanelRemote.createTasks(
            JSON.serialize(taskConfig),
            JSON.serialize(adHocWrapper),
            JSON.serialize(filter),
            'task'
        );
        Test.stopTest();
    }

    @IsTest(SeeAllData=true)
    static void testSurveyTaskCreation() {
        TestData.loadTestData();

        Reminder_Schedule__c schedule = new Reminder_Schedule__c(
            First_Reminder_day__c = 0,
            Second_Reminder_day__c = 1
        );
        insert schedule;

        List<Survey> surveys = new List<Survey>(
            [SELECT Id FROM Survey WHERE ActiveVersionId != NULL LIMIT 1]
        );
        if (surveys.isEmpty())
            return;

        List<Participant_Enrollment__c> enrollments = new List<Participant_Enrollment__c>(
            [
                SELECT
                    Clinical_Trial_Profile__c,
                    Clinical_Trial_Profile__r.Name,
                    Clinical_Trial_Profile__r.Study_Code_Name__c
                FROM Participant_Enrollment__c
                WHERE
                    Clinical_Trial_Profile__r.Tasks_Are_Available__c = TRUE
                    AND Clinical_Trial_Profile__r.CommunityTemplate__c = :CommunityTemplateService.TEMPLATE_DEFAULT
                LIMIT 1
            ]
        );
        if (enrollments.isEmpty())
            return;

        List<LookupSearchResult> searchResults = new List<LookupSearchResult>();
        searchResults.add(
            new LookupSearchResult(
                enrollments[0].Clinical_Trial_Profile__c,
                'Clinical_Trial_Profile__c',
                'custom:custom86',
                enrollments[0].Clinical_Trial_Profile__r.Name,
                'Code name ' + enrollments[0].Clinical_Trial_Profile__r.Study_Code_Name__c
            )
        );

        ManualTaskFilter filter = new ManualTaskFilter();
        filter.statuses = new List<String>{ PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS };
        filter.studies = searchResults;

        TaskService.TaskConfig taskConfig = new TaskService.TaskConfig();

        ManualCreationPanelRemote.AdHocWrapper adHocWrapper = new ManualCreationPanelRemote.AdHocWrapper();
        adHocWrapper.selectedSurvey = String.valueOf(surveys[0].Id);
        adHocWrapper.daysToExpire = 10;
        adHocWrapper.selectedRS = schedule.Id;
        adHocWrapper.expireOnAlumni = false;
        adHocWrapper.neededResponse = SurveyService.SURVEY_RESPONSE_EACH_DELEGATE;

        Test.startTest();
        ManualCreationPanelRemote.getInitData();
        ManualCreationPanelRemote.createTasks(
            JSON.serialize(taskConfig),
            JSON.serialize(adHocWrapper),
            JSON.serialize(filter),
            'adHoc'
        );
        ManualCreationPanelRemote.searchReminderScheduleByValue(schedule.Id);
        ManualCreationPanelRemote.searchReminderSchedule('RS', '');
        Test.stopTest();
    }

    @IsTest(SeeAllData=true)
    static void testSearchSurveys() {
        List<Survey> surveys = new List<Survey>(
            [SELECT Name FROM Survey WHERE ActiveVersionId != NULL LIMIT 1]
        );
        if (surveys.isEmpty())
            return;

        List<LookupSearchResult> searchResults = new List<LookupSearchResult>();
        searchResults = ManualCreationPanelRemote.searchSurveys(surveys.get(0).Name, '');

        System.assert(searchResults.size() > 0);
    }

    @IsTest(SeeAllData=true)
    static void testSearchSurveysByValue() {
        List<Survey> surveys = new List<Survey>(
            [SELECT Id FROM Survey WHERE ActiveVersionId != NULL LIMIT 1]
        );
        if (surveys.isEmpty())
            return;

        List<LookupSearchResult> searchResults = new List<LookupSearchResult>();
        searchResults = ManualCreationPanelRemote.searchSurveysByValue(surveys.get(0).Id);

        System.assert(searchResults.size() > 0);
    }
}