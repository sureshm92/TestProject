@IsTest
public class Test_EmailTemplateInitialPT {
    
      @TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData(); 
        Test.stopTest();
    }
    
      @IsTest
    public static void runTest() {
          TestData tstData = new TestData();
        Test.startTest();
        tstData.pe.Invited_to_PP_Date__c = DateTime.now();
        System.runAs(tstData.participantUser) {
        EmailTemplateInitialPT email=new EmailTemplateInitialPT( tstData.pe.Participant_Contact__c,'HTML', 'Default');
    }
   }

}