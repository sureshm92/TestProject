@IsTest(SeeAllData=true)
public with sharing class LightningForgotPasswordControllerTest {
    /* Verifies that ForgotPasswordController handles invalid usernames appropriately */
    @IsTest
    static void testLightningForgotPasswordControllerInvalidUserName() {
        System.assertEquals(
            LightningForgotPasswordController.forgotPassword('fakeUser', 'http://a.com'),
            Label.Site.invalid_email
        );
        System.assertEquals(
            LightningForgotPasswordController.forgotPassword(null, 'http://a.com'),
            Label.Site.invalid_email
        );
        System.assertEquals(
            LightningForgotPasswordController.forgotPassword('a', '/home/home.jsp'),
            Label.Site.invalid_email
        );

        LightningForgotPasswordController.forgotPasswordCommunity('fakeUser', 'http://a.com');
    }

    /* Verifies that null checkEmailRef url throws proper exception. */
    @IsTest
    static void testLightningForgotPasswordControllerWithNullCheckEmailRef() {
        System.assertEquals(
            LightningForgotPasswordController.forgotPassword('a', null),
            'Argument 1 cannot be null'
        );
        System.assertEquals(
            LightningForgotPasswordController.forgotPassword('a@salesforce.com', null),
            'Argument 1 cannot be null'
        );
    }

    /* Verifies that LightningForgotPasswordController object is instantiated correctly. */
    @IsTest
    static void LightningForgotPasswordControllerInstantiation() {
        LightningForgotPasswordController controller = new LightningForgotPasswordController();
        System.assertNotEquals(controller, null);
    }
    @IsTest
    static void testforgotPasswordCommunity() {
        Contact contact_1;
        Account account_1;
        Profile profile_1 = [
            SELECT Id
            FROM Profile
            WHERE Name = 'IQVIA Customer Community Plus Login User'
            LIMIT 1
        ];
        account_1 = new Account(Name = 'Community', BillingCountry = 'United States');
        insert account_1;

        contact_1 = new Contact(AccountId = account_1.Id, LastName = 'xgeek');
        insert contact_1;
        user user_1 = new User(
            Email = 'yourusername@gmail.com',
            ProfileId = profile_1.Id,
            UserName = 'yourusername@gmail.com',
            Alias = 'Test',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'ISO-8859-1',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ContactId = contact_1.Id,
            PortalRole = 'Manager',
            FirstName = 'Firstname',
            LastName = 'Lastname'
        );
        insert user_1;
        System.runAs(user_1) {
            LightningForgotPasswordController.forgotPasswordCommunity(
                'yourusername@gmail.com',
                'http://a.com'
            );
            LightningForgotPasswordController.forgotPassword(
                'yourusername@gmail.com',
                'http://a.com'
            );
            LightningForgotPasswordController.setExperienceId('ASAD');
        }
    }
}
