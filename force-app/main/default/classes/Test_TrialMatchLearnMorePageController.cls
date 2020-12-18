@IsTest
public class Test_TrialMatchLearnMorePageController {
    
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
        System.runAs(tstData.participantUser) {
        PageReference pageRef =  Page.TrialMatchLearnMorePage;
        System.debug('ctpppp:::'+tstData.ctp.Id);
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('CTPId', tstData.ctp.Id);
        TrialMatchLearnMorePageController controller=new TrialMatchLearnMorePageController();        
        controller.CTPId=tstData.ctp.Id;
        controller.getisRTL();
        }  
        Test.stopTest();
        
    }

}