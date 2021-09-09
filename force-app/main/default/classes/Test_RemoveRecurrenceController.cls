@IsTest
private class Test_RemoveRecurrenceController {
     @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
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
