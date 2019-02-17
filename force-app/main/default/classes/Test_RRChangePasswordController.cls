/**
 * Created by Leonid Bartenev
 */

@IsTest
private class Test_RRChangePasswordController {

    @IsTest(SeeAllData=true)
    public static void testChangePasswordController() {

        Account acc1 = new Account (
                Name = 'newAcc1'
        );
        insert acc1;
        Contact conCase = new Contact (
                AccountId = acc1.id,
                LastName = 'portalTestUser1'
        );
        insert conCase;

        //Create user
        Profile profile = [SELECT Id FROM Profile WHERE Name =: CommunityService.COMMUNITY_USER_PROFILE_NAME];
        User portalUser = new User(
                profileId = profile.id,
                username = 'newUser@yahoo.com',
                email = 'pb@f.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='nuser',
                lastname='lastname',
                contactId = conCase.id
        );
        insert portalUser;


        //run test:
        System.runAs(portalUser){
            Test.startTest();
            // Instantiate a new controller with all parameters in the page
            RRChangePasswordController controller = new RRChangePasswordController();
            controller.oldPassword = '123456';
            controller.newPassword = 'qwerty1';
            controller.verifyNewPassword = 'qwerty1';
            System.assertEquals(controller.changePassword(), null);
            controller.showProfileAction();
            controller.oldPassword = 'qwerty1';
            controller.newPassword = 'NewPas1234';
            controller.verifyNewPassword = 'NewPas123456';
            controller.changePassword();

            Test.stopTest();
        }
    }
}