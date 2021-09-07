@IsTest
private class RemoveRecurrenceController_Test {
     @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @isTest
    static void testMethod1() {
        Id ConfigId = [Select Id from Manual_Creation_Panel_Task__c limit 1].Id;
        RemoveRecurrenceController.getTaskDetails(String.valueOf(ConfigId));
        RemoveRecurrenceController.removeRecurrence(String.valueOf(ConfigId));
    }
    @isTest
    static void testMethod2() {
        Manual_Creation_Panel_Task__c mct = [Select Id,Next_Occurence_Date__c,Status__c,Start_Date__c From Manual_Creation_Panel_Task__c limit 1];
        mct.Start_Date__c = Date.today().addDays(1);
        mct.Next_Occurence_Date__c = Date.today().addDays(1);
        update mct;
        Id ConfigId = [Select Id from Manual_Creation_Panel_Task__c limit 1].Id;
        RemoveRecurrenceController.getTaskDetails(String.valueOf(ConfigId));
        RemoveRecurrenceController.removeRecurrence(String.valueOf(ConfigId));
    }
}
