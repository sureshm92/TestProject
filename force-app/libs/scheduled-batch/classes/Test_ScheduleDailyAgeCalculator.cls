/*
 * This is the test class for ScheduleDailyAgeCalculator
 */

 @isTest
public class Test_ScheduleDailyAgeCalculator {
    
    //test only scheduling part for ScheduleDailyAgeCalculator
    @isTest
    public static void testSchedule() {
        Test.StartTest();
        ScheduleDailyAgeCalculator sh1 = new ScheduleDailyAgeCalculator();        
       //mock-schedule for Daily age calculator
        String sch = '0 0 23 * * ?'; system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest(); 
    }
}