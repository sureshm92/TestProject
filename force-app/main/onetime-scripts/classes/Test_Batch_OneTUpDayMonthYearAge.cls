@isTest
public class Test_Batch_OneTUpDayMonthYearAge {
    @IsTest
    static void testAge(){
         Test.startTest();

           TestData.loadTestData();
           Test.stopTest();

        TestData testData = new TestData();

        testData.participant.Date_of_Birth__c = '1984-04-07';
        update testData.participant;

        Database.executeBatch(new Batch_OneTimeUpdDayMonthYearAge());
    }
    @IsTest
    static void testAgebkp(){
         Test.startTest();

           TestData.loadTestData();
           Test.stopTest();

        TestData testData = new TestData();

        testData.participant.Date_of_Birth__c = '1984-04-07';
        update testData.participant;

        Database.executeBatch(new Batch_OneTimeUpdDayMonthYearAgeBkp());
    }	
}