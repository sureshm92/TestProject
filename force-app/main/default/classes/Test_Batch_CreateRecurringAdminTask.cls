/**
 * Created by Sravani Dasari on 02.09.2021.
 */
@IsTest
private  class Test_Batch_CreateRecurringAdminTask {
	@TestSetup
    static void testRecurringTaskCreation() {
        TestData.loadTestData();
    }
    @isTest
    static void testRecurringTaskDaily() {
        Manual_Creation_Panel_Task__c mct = new Manual_Creation_Panel_Task__c(
            TaskConfig__c ='{"isRecurrence":true,"priority":"Normal","visibility":"Owner;Delegates","subject":"Test Rec","startDate":"2021-08-30","endTime":"2021-09-06","recurrenceFrequency":"Daily"}', 
            TaskFilter__c ='	{"areas":[],"countries":[],"isPlatformLevel":true,"sites":[],"sponsors":[],"statuses":["Referred","Enrolled"],"studies":[]}', 
            Recurrence_Frequency__c ='Daily', 
            Start_Date__c = Date.today(),  
            Recurrence_End_Date__c = Date.today().addDays(7),
            Next_Occurence_Date__c = Date.today(), 
            Next_Due_Date__c = Date.today()
        );
        insert mct;
        Test.startTest();
        Database.executeBatch(new Batch_CreateRecurringAdminTask(), 1);
        Test.stopTest();
    }
    @isTest
    static void testRecurringTaskWeekly() {
        Manual_Creation_Panel_Task__c mct = new Manual_Creation_Panel_Task__c(
            TaskConfig__c ='{"isRecurrence":true,"priority":"Normal","visibility":"Owner;Delegates","subject":"Test Rec","startDate":"2021-08-30","endTime":"2021-09-06","recurrenceFrequency":"Weekly"}', 
            TaskFilter__c ='	{"areas":[],"countries":[],"isPlatformLevel":true,"sites":[],"sponsors":[],"statuses":["Referred","Enrolled"],"studies":[]}', 
            Recurrence_Frequency__c ='Weekly', 
            Start_Date__c = Date.today(),  
            Recurrence_End_Date__c = Date.today().addDays(15),
            Next_Occurence_Date__c = Date.today(), 
            Next_Due_Date__c = Date.today().addDays(6)
        );
        insert mct;
        Test.startTest();
        Database.executeBatch(new Batch_CreateRecurringAdminTask(), 1);
        Test.stopTest();
    }
    
    @isTest
    static void testRecurringTaskMonthly() {
        Manual_Creation_Panel_Task__c mct = new Manual_Creation_Panel_Task__c(
            TaskConfig__c ='{"isRecurrence":true,"priority":"Normal","visibility":"Owner;Delegates","subject":"Test Rec","startDate":"2021-08-30","endTime":"2021-09-06","recurrenceFrequency":"Monthly"}', 
            TaskFilter__c ='	{"areas":[],"countries":[],"isPlatformLevel":true,"sites":[],"sponsors":[],"statuses":["Referred","Enrolled"],"studies":[]}', 
            Recurrence_Frequency__c ='Monthly', 
            Start_Date__c = Date.today(),  
            Recurrence_End_Date__c = Date.today().addMonths(2),
            Next_Occurence_Date__c = Date.today(), 
            Next_Due_Date__c = Date.today().addMonths(1).addDays(-1)
        );
        insert mct;
        Test.startTest();
        Database.executeBatch(new Batch_CreateRecurringAdminTask(), 1);
        Test.stopTest();
    }
    @isTest
    static void testRecurringTaskYearly() {
        Manual_Creation_Panel_Task__c mct = new Manual_Creation_Panel_Task__c(
            TaskConfig__c ='{"isRecurrence":true,"priority":"Normal","visibility":"Owner;Delegates","subject":"Test Rec","startDate":"2021-08-30","endTime":"2021-09-06","recurrenceFrequency":"Yearly"}', 
            TaskFilter__c ='	{"areas":[],"countries":[],"isPlatformLevel":true,"sites":[],"sponsors":[],"statuses":["Referred","Enrolled"],"studies":[]}', 
            Recurrence_Frequency__c ='Yearly', 
            Start_Date__c = Date.today(),
            Reminder_days_before_due_date__c = 3,
            Recurrence_End_Date__c = Date.today().addYears(2),
            Next_Occurence_Date__c = Date.today(), 
            Next_Due_Date__c = Date.today().addYears(1).addDays(-1)
        );
        insert mct;
        Test.startTest();
        Batch_CreateRecurringAdminTask bt = new Batch_CreateRecurringAdminTask();
        Database.executeBatch(bt, 1);
        bt.getBatchDescription();
        bt.getType();
        bt.getRecommendedIntervalMode();
        bt.getRecommendedRelaunchInterval();
        bt.getRecommendedScopeSize();
        Test.stopTest();
        
    }
    
    @isTest
    static void testRecurringTaskTrigger() {
        List<Manual_Creation_Panel_Task__c> mctList = new List<Manual_Creation_Panel_Task__c>();
        Manual_Creation_Panel_Task__c mct = new Manual_Creation_Panel_Task__c(
            TaskConfig__c ='{"isRecurrence":true,"priority":"Normal","visibility":"Owner;Delegates","subject":"Test Rec","startDate":"2021-08-30","endTime":"2021-09-06","recurrenceFrequency":"Daily"}', 
            TaskFilter__c ='	{"areas":[],"countries":[],"isPlatformLevel":true,"sites":[],"sponsors":[],"statuses":["Referred","Enrolled"],"studies":[]}', 
            Recurrence_Frequency__c ='Daily', 
            Start_Date__c = Date.today(),  
            Recurrence_End_Date__c = Date.today().addDays(7),
            Next_Occurence_Date__c = Date.today(), 
            Next_Due_Date__c = Date.today()
        );
        mctList.add(mct);
        
        Manual_Creation_Panel_Task__c mct1 = new Manual_Creation_Panel_Task__c(
            TaskConfig__c ='{"isRecurrence":true,"priority":"Normal","visibility":"Owner;Delegates","subject":"Test Rec","startDate":"2021-08-30","endTime":"2021-09-06","recurrenceFrequency":"Weekly"}', 
            TaskFilter__c ='	{"areas":[],"countries":[],"isPlatformLevel":true,"sites":[],"sponsors":[],"statuses":["Referred","Enrolled"],"studies":[]}', 
            Recurrence_Frequency__c ='Weekly', 
            Start_Date__c = Date.today(),  
            Recurrence_End_Date__c = Date.today().addDays(14),
            Next_Occurence_Date__c = Date.today().addDays(8), 
            Next_Due_Date__c = Date.today().addDays(14)
        );
        mctList.add(mct1);
        
        insert mctList;
        Test.startTest();
        	mct.Start_Date__c = mct.Start_Date__c.addDays(2);
        	mct.Recurrence_End_Date__c = Date.today().addDays(14);
        	mct1.Recurrence_End_Date__c = Date.today().addDays(7);
        	update mctList;
        Test.stopTest();
    }

    @isTest
    static void testRecurringNextDueDate() {
        List<Manual_Creation_Panel_Task__c> mctList = new List<Manual_Creation_Panel_Task__c>();
        Manual_Creation_Panel_Task__c mct = new Manual_Creation_Panel_Task__c(
            TaskConfig__c ='{"isRecurrence":true,"priority":"Normal","visibility":"Owner;Delegates","subject":"Test Rec","startDate":"2021-08-30","endTime":"2021-09-06","recurrenceFrequency":"Daily"}', 
            TaskFilter__c ='	{"areas":[],"countries":[],"isPlatformLevel":true,"sites":[],"sponsors":[],"statuses":["Referred","Enrolled"],"studies":[]}', 
            Recurrence_Frequency__c ='Daily', 
            Start_Date__c = Date.today(),  
            Recurrence_End_Date__c = Date.today().addDays(7),
            Next_Occurence_Date__c = Date.today(), 
            Next_Due_Date__c = Date.today()
        );
        mctList.add(mct);
        
        Manual_Creation_Panel_Task__c mct1 = new Manual_Creation_Panel_Task__c(
            TaskConfig__c ='{"isRecurrence":true,"priority":"Normal","visibility":"Owner;Delegates","subject":"Test Rec","startDate":"2021-08-30","endTime":"2021-09-06","recurrenceFrequency":"Weekly"}', 
            TaskFilter__c ='	{"areas":[],"countries":[],"isPlatformLevel":true,"sites":[],"sponsors":[],"statuses":["Referred","Enrolled"],"studies":[]}', 
            Recurrence_Frequency__c ='Weekly', 
            Start_Date__c = Date.today(),  
            Recurrence_End_Date__c = Date.today().addDays(14),
            Next_Occurence_Date__c = Date.today().addDays(8), 
            Next_Due_Date__c = Date.today().addDays(14)
        );
        mctList.add(mct1);
        
        insert mctList;
        Test.startTest();
        	mct.Recurrence_End_Date__c = Date.today();
            mct.Next_Due_Date__c = Date.today();
        	update mctList;
            Batch_CreateRecurringAdminTask bt = new Batch_CreateRecurringAdminTask();
            Database.executeBatch(bt, 1);
        Test.stopTest();
    }
    @isTest
    static void testOneTimetask() {
        Manual_Creation_Panel_Task__c mct = new Manual_Creation_Panel_Task__c(
            TaskConfig__c ='{"isRecurrence":false,"priority":"Normal","visibility":"Owner;Delegates","subject":"Test Rec","startDate":"2021-08-30","endTime":"2021-09-06"}', 
            TaskFilter__c ='	{"areas":[],"countries":[],"isPlatformLevel":true,"sites":[],"sponsors":[],"statuses":["Referred","Enrolled"],"studies":[]}', 
            Start_Date__c = Date.today(),  
            Recurrence_End_Date__c = Date.today().addDays(7),
            Next_Occurence_Date__c = Date.today()
        );
        insert mct;
        Test.startTest();
        Database.executeBatch(new Batch_CreateRecurringAdminTask(), 1);
        Test.stopTest();
    }
    
}