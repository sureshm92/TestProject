@IsTest(SeeAllData=true)
public class Test_ProfileIconController {
    @isTest
    private static void getPhotoUrl() {
        TestData.loadTestData();
        Test.startTest();
        ProfileIconController.getPhotoURL();
        Test.stopTest();
    }
}
