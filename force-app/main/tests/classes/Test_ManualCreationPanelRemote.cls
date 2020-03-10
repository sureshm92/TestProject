/**
 * Created by Igor Malyuta on 01.10.2019.
 */
@IsTest
private class Test_ManualCreationPanelRemote {

    @IsTest
    static void testTaskCreation() {
        TestData.loadTestData();

        ManualTaskFilter filter = new ManualTaskFilter();
        filter.statuses = new List<String>{PEStatusState.PE_ST_REFERRED};

        TaskService.TaskConfig taskConfig = new TaskService.TaskConfig();
        taskConfig.subject = 'Test';
        taskConfig.startDate = System.today();
        taskConfig.endTime = System.today();
        taskConfig.reminderDate = System.today();
        taskConfig.visibility = 'Owner;Delegates';

        ManualCreationPanelRemote.AdHocWrapper adHocWrapper = new ManualCreationPanelRemote.AdHocWrapper();

        Test.startTest();
        ManualCreationPanelRemote.getInitData();
        ManualCreationPanelRemote.createTasks(
                JSON.serialize(taskConfig), JSON.serialize(adHocWrapper), JSON.serialize(filter), 'task');
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

        List<Survey> surveys = new List<Survey> ([SELECT Id FROM Survey WHERE ActiveVersionId != NULL LIMIT 1]);
        System.assertEquals(1, surveys.size());

        ManualTaskFilter filter = new ManualTaskFilter();
        filter.statuses = new List<String>{PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS};

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
                JSON.serialize(taskConfig), JSON.serialize(adHocWrapper), JSON.serialize(filter), 'adHoc');
        ManualCreationPanelRemote.searchReminderScheduleByValue(schedule.Id);
        ManualCreationPanelRemote.searchReminderSchedule('RS', '');
        Test.stopTest();
    }
}