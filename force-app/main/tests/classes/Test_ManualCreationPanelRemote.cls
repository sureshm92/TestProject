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

        Manual_Creation_Panel_Task__c mct = new Manual_Creation_Panel_Task__c(
            TaskConfig__c ='{"isRecurrence":true,"priority":"Normal","visibility":"Owner;Delegates","subject":"Test Rec","startDate":"2021-08-30","endTime":"2021-09-06","recurrenceFrequency":"Weekly"}', 
            TaskFilter__c ='	{"areas":[],"countries":[],"isPlatformLevel":true,"sites":[],"sponsors":[],"statuses":["Referred","Enrolled"],"studies":[]}', 
            Recurrence_Frequency__c ='Weekly', 
            Status__c = 'Active',
            Start_Date__c = Date.today(),  
            Recurrence_End_Date__c = Date.today().addDays(15),
            Next_Occurence_Date__c = Date.today(), 
            Next_Due_Date__c = Date.today().addDays(6)
        );
        insert mct;

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
            'task',
            null
        );
        Test.stopTest();
    }
    @IsTest(SeeAllData=true)
    static void testTaskUpdate() {
        TestData.loadTestData();

        ManualTaskFilter filter = new ManualTaskFilter();
        filter.statuses = new List<String>{ PEStatusState.PE_ST_REFERRED };

        Manual_Creation_Panel_Task__c mct = new Manual_Creation_Panel_Task__c(
            TaskConfig__c ='{"isRecurrence":false,"priority":"Normal","visibility":"Owner;Delegates","subject":"Test Rec","startDate":"2021-08-30","endTime":"2021-09-06"}', 
            TaskFilter__c ='	{"areas":[],"countries":[],"isPlatformLevel":true,"sites":[],"sponsors":[],"statuses":["Referred","Enrolled"],"studies":[]}', 
            Status__c = 'Active',
            Start_Date__c = Date.today().addDays(1),  
            Recurrence_End_Date__c = Date.today().addDays(15),
            Next_Occurence_Date__c = Date.today().addDays(1)
        );
        insert mct;

        ManualCreationPanelRemote.AdHocWrapper adHocWrapper = new ManualCreationPanelRemote.AdHocWrapper();

        Test.startTest();
        mct.Recurrence_End_Date__c = Date.today();
        mct.Reminder_Date__c = Date.today().addDays(2);
        update mct;
        ManualCreationPanelRemote.getInitData();
        ManualCreationPanelRemote.createTasks(
            '{"isRecurrence":false,"priority":"Normal","visibility":"Owner;Delegates","subject":"Test Rec","startDate":"2021-08-30","endTime":"2021-09-06"}',
            JSON.serialize(adHocWrapper),
            JSON.serialize(filter),
            'task',
            mct
        );
        Test.stopTest();

    }
    @IsTest(SeeAllData=true)
    static void testFutrTaskCreate() {
        TestData.loadTestData();

        ManualTaskFilter filter = new ManualTaskFilter();
        filter.statuses = new List<String>{ PEStatusState.PE_ST_REFERRED };

        Manual_Creation_Panel_Task__c mct = new Manual_Creation_Panel_Task__c(
            TaskConfig__c ='{"isRecurrence":false,"priority":"Normal","visibility":"Owner;Delegates","subject":"Test Rec","startDate":"2022-08-30","endTime":"2022-09-06"}', 
            TaskFilter__c ='	{"areas":[],"countries":[],"isPlatformLevel":true,"sites":[],"sponsors":[],"statuses":["Referred","Enrolled"],"studies":[]}', 
            Status__c = 'Active',
            Start_Date__c = Date.today().addDays(4),  
            Recurrence_End_Date__c = Date.today().addDays(15),
            Next_Occurence_Date__c = Date.today().addDays(1)
        );
        insert mct;

        TaskService.TaskConfig taskConfig = new TaskService.TaskConfig();
        taskConfig.subject = 'Test';
        taskConfig.startDate = System.today().addDays(4);
        taskConfig.endTime = System.today().addDays(15);
        taskConfig.reminderDate = System.today().addDays(2);
        taskConfig.visibility = 'Owner;Delegates';
        taskConfig.isRecurrence = false;
        ManualCreationPanelRemote.AdHocWrapper adHocWrapper = new ManualCreationPanelRemote.AdHocWrapper();

        Test.startTest();
        ManualCreationPanelRemote.getInitData();
        ManualCreationPanelRemote.createTasks(
            JSON.serialize(taskConfig),
            JSON.serialize(adHocWrapper),
            JSON.serialize(filter),
            'task',
            null
        );
        Test.stopTest();

    }
    @IsTest(SeeAllData=true)
    static void testTaskStartDateToday() {
        Manual_Creation_Panel_Task__c mct = new Manual_Creation_Panel_Task__c(
            TaskConfig__c ='{"isRecurrence":true,"priority":"Normal","visibility":"Owner;Delegates","subject":"Test Rec","startDate":"2021-08-30","endTime":"2021-09-06","recurrenceFrequency":"Weekly","reminderDate":"2022-07-02","reminderDays":"2"}', 
            TaskFilter__c ='	{"areas":[],"countries":[],"isPlatformLevel":true,"sites":[],"sponsors":[],"statuses":["Referred","Enrolled"],"studies":[]}', 
            Recurrence_Frequency__c ='Weekly', 
            Status__c = 'Active',
            Is_Recurrence__c = true,
            Start_Date__c = Date.today().addDays(1),  
            Recurrence_End_Date__c = Date.today().addDays(415),
            Next_Occurence_Date__c = Date.today(), 
            Next_Due_Date__c = Date.today().addDays(6)
        );
        insert mct;
        Test.startTest();
        mct.Start_Date__c = Date.today();
        update mct;

        mct.Start_Date__c = Date.today().addDays(1);
        mct.TaskConfig__c ='{"isRecurrence":true,"priority":"Normal","visibility":"Owner;Delegates","subject":"Test Rec","startDate":"2021-08-30","endTime":"2021-09-06","recurrenceFrequency":"Daily"}';
        update mct;

        mct.Start_Date__c = Date.today();
        update mct;

        mct.Start_Date__c = Date.today().addDays(1);
        mct.TaskConfig__c ='{"isRecurrence":true,"priority":"Normal","visibility":"Owner;Delegates","subject":"Test Rec","startDate":"2021-08-30","endTime":"2021-09-06","recurrenceFrequency":"Yearly"}';
        update mct;

        mct.Start_Date__c = Date.today();
        update mct;

        mct.Start_Date__c = Date.today().addDays(1);
        mct.TaskConfig__c ='{"isRecurrence":true,"priority":"Normal","visibility":"Owner;Delegates","subject":"Test Rec","startDate":"2021-08-30","endTime":"2021-09-06","recurrenceFrequency":"Monthly"}';
        update mct;

        mct.Start_Date__c = Date.today();
        update mct;

        Test.stopTest();
    }
    @IsTest(SeeAllData=true)
    static void testTaskUpdateToday() {
        TestData.loadTestData();

        ManualTaskFilter filter = new ManualTaskFilter();
        filter.statuses = new List<String>{ PEStatusState.PE_ST_REFERRED };

        Manual_Creation_Panel_Task__c mct = new Manual_Creation_Panel_Task__c(
            TaskConfig__c ='{"isRecurrence":true,"priority":"Normal","visibility":"Owner;Delegates","subject":"Test Rec","startDate":"2021-08-30","endTime":"2021-09-06","recurrenceFrequency":"Weekly"}', 
            TaskFilter__c ='	{"areas":[],"countries":[],"isPlatformLevel":true,"sites":[],"sponsors":[],"statuses":["Referred","Enrolled"],"studies":[]}', 
            Recurrence_Frequency__c ='Weekly', 
            Status__c = 'Active',
            Start_Date__c = Date.today().addDays(1),  
            Recurrence_End_Date__c = Date.today().addDays(415),
            Next_Occurence_Date__c = Date.today(), 
            Next_Due_Date__c = Date.today().addDays(6)
        );
        insert mct;
        
        TaskService.TaskConfig taskConfig = new TaskService.TaskConfig();
        taskConfig.subject = 'Test';
        taskConfig.startDate = System.today();
        taskConfig.endTime = System.today().addDays(415);
        taskConfig.reminderDate = System.today().addDays(2);
        taskConfig.visibility = 'Owner;Delegates';
        taskConfig.isRecurrence = true;
        taskConfig.recurrenceFrequency = 'Weekly';

        ManualCreationPanelRemote.AdHocWrapper adHocWrapper = new ManualCreationPanelRemote.AdHocWrapper();

        Test.startTest();
        mct.Start_Date__c = Date.today();
        update mct;
        ManualCreationPanelRemote.getInitData();
        ManualCreationPanelRemote.createTasks(
            JSON.serialize(taskConfig),
            JSON.serialize(adHocWrapper),
            JSON.serialize(filter),
            'task',
            mct
        );
        
        taskConfig.recurrenceFrequency = 'Daily';
        mct.Recurrence_Frequency__c ='Daily';
        update mct;
        ManualCreationPanelRemote.getInitData();
        ManualCreationPanelRemote.createTasks(
            JSON.serialize(taskConfig),
            JSON.serialize(adHocWrapper),
            JSON.serialize(filter),
            'task',
            mct
        );
        taskConfig.recurrenceFrequency = 'Monthly';
        mct.Recurrence_Frequency__c ='Monthly';
        update mct;
        ManualCreationPanelRemote.getInitData();
        ManualCreationPanelRemote.createTasks(
            JSON.serialize(taskConfig),
            JSON.serialize(adHocWrapper),
            JSON.serialize(filter),
            'task',
            mct
        );
        taskConfig.recurrenceFrequency = 'Yearly';
        mct.Recurrence_Frequency__c ='Yearly';
        update mct;
        ManualCreationPanelRemote.getInitData();
        ManualCreationPanelRemote.createTasks(
            JSON.serialize(taskConfig),
            JSON.serialize(adHocWrapper),
            JSON.serialize(filter),
            'task',
            mct
        );
        Test.stopTest();



    }
    @IsTest(SeeAllData=true)
    static void testExtendEnddate() {
        TestData.loadTestData();

        ManualTaskFilter filter = new ManualTaskFilter();
        filter.statuses = new List<String>{ PEStatusState.PE_ST_REFERRED };

        Manual_Creation_Panel_Task__c mct = new Manual_Creation_Panel_Task__c(
            TaskConfig__c ='{"isRecurrence":true,"priority":"Normal","visibility":"Owner;Delegates","subject":"Test Rec","startDate":"2022-08-30","endTime":"2022-09-06","recurrenceFrequency":"Weekly"}', 
            TaskFilter__c ='	{"areas":[],"countries":[],"isPlatformLevel":true,"sites":[],"sponsors":[],"statuses":["Referred","Enrolled"],"studies":[]}', 
            Recurrence_Frequency__c ='Weekly', 
            Status__c = 'Active',
            Start_Date__c = Date.today(),  
            Recurrence_End_Date__c = Date.today().addDays(15),
            Next_Occurence_Date__c = Date.today(), 
            Next_Due_Date__c = Date.today().addDays(6)
        );
        insert mct;

        ManualCreationPanelRemote.AdHocWrapper adHocWrapper = new ManualCreationPanelRemote.AdHocWrapper();

        Test.startTest();
        mct.Recurrence_End_Date__c = Date.today().addDays(20);
        update mct;
        Test.stopTest();

    }
    @IsTest(SeeAllData=true)
    static void testGetTaskData() {
        TestData.loadTestData();

        ManualTaskFilter filter = new ManualTaskFilter();
        filter.statuses = new List<String>{ PEStatusState.PE_ST_REFERRED };

        Manual_Creation_Panel_Task__c mct = new Manual_Creation_Panel_Task__c(
            TaskConfig__c ='{"isRecurrence":true,"priority":"Normal","visibility":"Owner;Delegates","subject":"Test Rec","startDate":"2021-08-30","endTime":"2021-09-06","recurrenceFrequency":"Weekly"}', 
            TaskFilter__c ='	{"areas":[],"countries":[],"isPlatformLevel":true,"sites":[],"sponsors":[],"statuses":["Referred","Enrolled"],"studies":[]}', 
            Recurrence_Frequency__c ='Weekly', 
            Status__c = 'Active',
            Start_Date__c = Date.today(),  
            Recurrence_End_Date__c = Date.today().addDays(15),
            Next_Occurence_Date__c = Date.today(), 
            Next_Due_Date__c = Date.today().addDays(6)
        );
        insert mct;

        Test.startTest();
        ManualCreationPanelRemote.getTaskData(mct.Id);
        ManualCreationPanelRemote.getListViews();
        Test.stopTest();

    }
    @IsTest
    static void testRecTaskCreation() {
        TestData.loadTestData();

        ManualTaskFilter filter = new ManualTaskFilter();
        filter.statuses = new List<String>{ PEStatusState.PE_ST_REFERRED };

        ManualCreationPanelRemote.AdHocWrapper adHocWrapper = new ManualCreationPanelRemote.AdHocWrapper();

        Manual_Creation_Panel_Task__c mct1 = new Manual_Creation_Panel_Task__c();

        Test.startTest();
        ManualCreationPanelRemote.getInitData();
        ManualCreationPanelRemote.createTasks(
            '{"isRecurrence":true,"priority":"Normal","visibility":"Owner;Delegates","subject":"Test Rec","startDate":"2021-08-30","endTime":"2021-09-06","recurrenceFrequency":"Daily"}',
            JSON.serialize(adHocWrapper),
            JSON.serialize(filter),
            'task',
            null
        );
        Test.stopTest();

    }
    @IsTest
    static void testRecTaskCreationMonthly() {
        TestData.loadTestData();

        ManualTaskFilter filter = new ManualTaskFilter();
        filter.statuses = new List<String>{ PEStatusState.PE_ST_REFERRED };

        ManualCreationPanelRemote.AdHocWrapper adHocWrapper = new ManualCreationPanelRemote.AdHocWrapper();

        Manual_Creation_Panel_Task__c mct1 = new Manual_Creation_Panel_Task__c();

        Test.startTest();
        ManualCreationPanelRemote.getInitData();
        ManualCreationPanelRemote.createTasks(
            '{"isRecurrence":true,"priority":"Normal","visibility":"Owner;Delegates","subject":"Test Rec","startDate":"2021-08-30","endTime":"2021-10-06","recurrenceFrequency":"Monthly"}',
            JSON.serialize(adHocWrapper),
            JSON.serialize(filter),
            'task',
            null
        );
        Test.stopTest();

    }
    @IsTest
    static void testRecTaskCreationYearly() {
        TestData.loadTestData();

        ManualTaskFilter filter = new ManualTaskFilter();
        filter.statuses = new List<String>{ PEStatusState.PE_ST_REFERRED };

        ManualCreationPanelRemote.AdHocWrapper adHocWrapper = new ManualCreationPanelRemote.AdHocWrapper();

        Manual_Creation_Panel_Task__c mct1 = new Manual_Creation_Panel_Task__c();

        Test.startTest();
        ManualCreationPanelRemote.getInitData();
        ManualCreationPanelRemote.createTasks(
            '{"isRecurrence":true,"priority":"Normal","visibility":"Owner;Delegates","subject":"Test Rec","startDate":"2021-08-30","endTime":"2023-10-06","recurrenceFrequency":"Yearly"}',
            JSON.serialize(adHocWrapper),
            JSON.serialize(filter),
            'task',
            null
        );
        Test.stopTest();

    }

    @IsTest
    static void testTaskCreationWeekly() {
        TestData.loadTestData();

        ManualTaskFilter filter = new ManualTaskFilter();
        filter.statuses = new List<String>{ PEStatusState.PE_ST_REFERRED };

        Manual_Creation_Panel_Task__c mct = new Manual_Creation_Panel_Task__c();

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
            'task',
            mct
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

        Manual_Creation_Panel_Task__c mct = new Manual_Creation_Panel_Task__c();

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
            'adHoc',
            mct
        );
        ManualCreationPanelRemote.searchReminderScheduleByValue(schedule.Id);
        ManualCreationPanelRemote.searchReminderSchedule('RS', '');
        ManualCreationPanelRemote.searchReminderSchedule('', '');
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