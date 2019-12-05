/**
 * Created by Krivo on 26.10.2019.
 */

@IsTest(IsParallel=false)
private class Test_FirstLogonController {

    @IsTest//(SeeAllData=true)
    public static void testFirstLogonController() {
        TestData.loadTestData();
        TestData testData = new TestData();

        Test.startTest();
        System.runAs(testData.participantUser) {
            // Instantiate a new controller with all parameters in the page
            FirstLogonController controller = new FirstLogonController();
            controller.newPassword = 'qwerty1';
            controller.verifyNewPassword = 'qwerty1';

            System.assertEquals(controller.setPassword(), null);
            controller.showProfileAction();
            controller.account.Name = 'new Name';
            controller.updateNameOfAccount();
            controller.updateLanguageAction();
            controller.updateStatesAction();
        }
        Test.stopTest();
    }

    @IsTest
    public static void testChangePasswordPageController() {
        TestData.loadTestData();
        TestData testData = new TestData();

        Test.startTest();
        System.runAs(testData.participantUser) {
            ChangePasswordPageController controller = new ChangePasswordPageController();
            controller.browserLanguage = '["en-US","",""]';
            controller.updateBrowserLanguageAction();
        }
        Test.stopTest();
    }
}