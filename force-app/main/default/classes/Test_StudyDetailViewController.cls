@isTest
public class Test_StudyDetailViewController {
	@TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    
    @IsTest
    static void baseHCPTest() {
        TestData testData = new TestData();
        System.runAs(testData.hcpUser) {
        StudyDetailViewController.getTrialDetail(
                    testData.ctp.Id,
                    CommunityService.USER_MODE_HCP
                );
        StudyDetailViewController.getTrialDetail(
                    testData.ctp.Id,
                    CommunityService.USER_MODE_HCP,
            false
                );
        
        }
    }
    @IsTest
    static void getTelevisitData() {
        TestData testData = new TestData();
        StudyDetailViewController.gettelevisitData(testData.ss.Id);
        
    }
    
    @IsTest
    static void baseHCPTest2() {
        TestData testData = new TestData();
        System.runAs(testData.hcpUser) {
            try{
                StudyDetailViewController.getTrialDetail(testData.ctp.Id,null,CommunityService.USER_MODE_HCP);
            	StudyDetailViewController.gettelevisitData('jgtdtre');
            }catch(exception ex){
                
            }
        }
    }
}