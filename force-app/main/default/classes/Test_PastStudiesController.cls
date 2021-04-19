@isTest
public class Test_PastStudiesController {
     @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        TestData.createTCAcceptance();
        Test.stopTest();
    }
    
    @isTest
    public static void testgetPastStudyRecords(){
        TestData testData = new TestData();
        test.startTest();
          System.runAs(testData.piUser) {
        PastStudiesController.getPastStudyRecords();
          }
        test.stopTest();
    }
    @isTest
    public static void testgetPastStudyRecords_Catch(){
        TestData testData = new TestData();
        test.startTest();
        try{
        PastStudiesController.getPastStudyRecords();
        }
        catch(Exception e){
            
        }
        test.stopTest();
    }

}