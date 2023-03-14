/**
 * Created by Leonid Bartenev
 */

@IsTest(IsParallel=true)
private class Test_RRLoginRemote {
    @IsTest
    static void testRRLoginRemote() {
        Test.startTest();
        String username;
        String password;
        String startUrl;
        String communityName;
        RRLoginRemote.login(username,password,startUrl);
        RRLoginRemote.getForgotPasswordUrl(username);
        RRLoginRemote.getForgotPasswordUrl();
        RRLoginRemote.getCommunityURL(communityName); 
        RRLoginRemote.isUserPasswordLocked(username);
        RRLoginRemote.communityLogin(username,password,startUrl);
    }
    
    
    @IsTest
    static void testLoginWithInvalidCredentials() {
        // System.assertEquals('Argument 1 cannot be null', RRLoginRemote.login('testUser', 'fakepwd', null));
        String res = LightningLoginFormController.login('testUser', 'fakepwd', null);
        if (String.isNotBlank(res))
            System.assertEquals('Argument 1 cannot be null', res);
        else
            System.assertNotEquals('Argument 1 cannot be null', res);
    }

    @IsTest
    static void LightningLoginFormControllerInstantiation() {
        RRLoginRemote controller = new RRLoginRemote();
        System.assertNotEquals(controller, null);
    }

    @IsTest
    static void testIsUsernamePasswordEnabled() {
        System.assertEquals(true, RRLoginRemote.getIsUsernamePasswordEnabled());
    }

    @IsTest
    static void testIsSelfRegistrationEnabled() {
        System.assertEquals(false, RRLoginRemote.getIsSelfRegistrationEnabled());
    }

    @IsTest
    static void testGetSelfRegistrationURL() {
        System.assertEquals(null, RRLoginRemote.getSelfRegistrationUrl());
    }

    @IsTest
    static void testAuthConfig() {
        Auth.AuthConfiguration authConfig = RRLoginRemote.getAuthConfig();
        System.assertNotEquals(null, authConfig);
    }

    @IsTest
    static void testExpId() {
        String testSetting = RRLoginRemote.setExperienceId('111');
        System.assertEquals(
            'This method can be invoked only from within a community.',
            testSetting
        );
    }
}