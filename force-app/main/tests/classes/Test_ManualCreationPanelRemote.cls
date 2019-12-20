/**
 * Created by Igor Malyuta on 01.10.2019.
 */
@IsTest
private class Test_ManualCreationPanelRemote {

    @IsTest
    static void testBehavior() {
        Reminder_Schedule__c schedule = new Reminder_Schedule__c(
                First_Reminder_day__c = 0,
                Second_Reminder_day__c = 1
        );
        insert schedule;

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
        adHocWrapper.selectedRS = schedule.Id;

        Test.startTest();
        ManualCreationPanelRemote.getInitData();
        ManualCreationPanelRemote.createTasks(JSON.serialize(taskConfig), adHocWrapper, filter, 'task');
        ManualCreationPanelRemote.searchReminderScheduleByValue(schedule.Id);
        ManualCreationPanelRemote.searchReminderSchedule('RS', '');
        Test.stopTest();
    }
}