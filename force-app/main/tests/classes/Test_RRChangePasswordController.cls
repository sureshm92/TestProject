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
        HCP_Enrollment__c hcpEnrollment = new HCP_Enrollment__c(
                Study_Site__c = testData.ss.Id,
                HCP_Contact__c = testData.participant.Contact__c,
                Status__c = HCPEnrollmentService.HCP_S_ON_HOLD_ACTIVATION
        );
        insert hcpEnrollment;

        System.runAs(testData.participantUser){
            // Instantiate a new controller with all parameters in the page
            RRChangePasswordController controller = new RRChangePasswordController();
            controller.oldPassword = '123456';
            controller.newPassword = 'qwerty1';
            controller.verifyNewPassword = 'qwerty1';
            System.assertEquals(null, controller.changePassword());
            controller.showProfileAction();

            controller.oldPassword = 'qwerty1';
            controller.newPassword = 'NewPas1234';
            controller.verifyNewPassword = 'NewPas1234';
            controller.browserLanguage = '["en_US","ru-ru",""]';
            controller.changePassword();

            controller.updateBrowserLanguageAction();
            controller.updateLanguageAction();
            controller.initTemplateData();

            controller.notEnrollNow = false;
            controller.states = new List<SelectOption>{
                    new SelectOption('CA', 'CA'),
                    new SelectOption('TX', 'TX')
            };

            /* Check with empty fields */
            controller.contact.LastName = null;
            controller.account.Name = null;
            controller.checkPasswords();

            Test.clearApexPageMessages();

            /* Check with full fields */
            controller.contact.FirstName = 'TestFirstName';
            controller.contact.LastName = 'TestLastName';
            controller.contact.MailingCountryCode = 'US';
            controller.contact.MailingStateCode = 'TX';
            controller.contact.MailingStreet = 'Test st.';
            controller.contact.MailingCity = 'Test City';
            controller.contact.MailingPostalCode = '123000';
            controller.contact.Phone = '(999)555-0000';
            controller.account.Name = 'TestAccountName';
            controller.checkPasswords();

            controller.translateFieldsAction();
            controller.updateStatesAction();
        }
        Test.stopTest();
    }
}