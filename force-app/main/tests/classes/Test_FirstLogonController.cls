/**
 * Created by Krivo on 26.10.2019.
 */

@IsTest(IsParallel=false)
private class Test_FirstLogonController {

    @IsTest(SeeAllData=true)
    public static void testChangePasswordController() {
        TestData.loadTestData();
        TestData testData = new TestData();
        //run test:
        Test.startTest();
        System.runAs(testData.participantUser) {
            // Instantiate a new controller with all parameters in the page
            FirstLogonController controller = new FirstLogonController();
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