@IsTest(IsParallel=true)
public with sharing class LightningLoginFormControllerTest {
    @IsTest
    static void testLoginWithInvalidCredentials() {
        //System.assertEquals('Argument 1 cannot be null', RRLoginRemote.login('testUser', 'fakepwd', null));
        String res = LightningLoginFormController.login('testUser', 'fakepwd', null);
        if (String.isNotBlank(res))
            System.assertEquals('Argument 1 cannot be null', res);
        else
            System.assertNotEquals('Argument 1 cannot be null', res);
    }

    @IsTest
    static void LightningLoginFormControllerInstantiation() {
        LightningLoginFormController controller = new LightningLoginFormController();
        System.assertNotEquals(controller, null);
    }

    @IsTest
    static void testIsUsernamePasswordEnabled() {
        System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled());
    }

    @IsTest
    static void testIsSelfRegistrationEnabled() {
        System.assertEquals(false, LightningLoginFormController.getIsSelfRegistrationEnabled());
    }

    @IsTest
    static void testGetSelfRegistrationURL() {
        System.assertEquals(null, LightningLoginFormController.getSelfRegistrationUrl());
    }

    @IsTest
    static void testAuthConfig() {
        Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
        System.assertNotEquals(null, authConfig);
    }
}
