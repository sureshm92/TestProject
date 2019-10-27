/**
 * Created by Leonid Bartenev
 */

@IsTest(IsParallel=false)
private class Test_RRChangePasswordController {

    @IsTest(SeeAllData=true)
    public static void testChangePasswordController() {
        TestData.loadTestData();
        TestData testData = new TestData();
        //run test:
        Test.startTest();
        System.runAs(testData.participantUser){
            // Instantiate a new controller with all parameters in the page
            RRChangePasswordController controller = new RRChangePasswordController();
            controller.oldPassword = '123456';
            controller.newPassword = 'qwerty1';
            controller.verifyNewPassword = 'qwerty1';
            System.assertEquals(controller.changePassword(), null);
            controller.showProfileAction();
            controller.oldPassword = 'qwerty1';
            controller.newPassword = 'NewPas1234';
            controller.verifyNewPassword = 'NewPas1234';
            controller.browserLanguage = '["en_US","",""]';
            controller.changePassword();
            controller.updateBrowserLanguageAction();
            controller.updateLanguageAction();
        }
        Test.stopTest();
    }
}