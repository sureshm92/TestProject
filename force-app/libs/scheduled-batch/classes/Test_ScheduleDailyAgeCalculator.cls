@isTest
public class Test_ScheduleDailyAgeCalculator {
    @isTest
    public static void testschedule() {
        Test.StartTest();
        ScheduleDailyAgeCalculator sh1 = new ScheduleDailyAgeCalculator();        
        String sch = '0 0 23 * * ?'; system.schedule('Test Territory Check', sch, sh1); Test.stopTest(); 
    }
}