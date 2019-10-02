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

        ManualTaskRemote.TaskPanelWrapper taskPanelWrapper = new ManualTaskRemote.TaskPanelWrapper();
        taskPanelWrapper.task.Subject = 'Test';
        taskPanelWrapper.task.Start_Date__c = System.today();
        taskPanelWrapper.task.Visible_For__c = 'Owner;Delegates';

        Test.startTest();
        ManualCreationPanelRemote.getInitData();
        ManualCreationPanelRemote.searchReminderScheduleByValue(schedule.Id);
        ManualCreationPanelRemote.searchReminderSchedule('RS', schedule.Id);
        Test.stopTest();
    }
}