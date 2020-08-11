/**
 * Created by Leonid Bartenev
 */

@IsTest(IsParallel=true)
private class Test_RRLoginRemote {

    @IsTest
    static void testLoginWithInvalidCredentials() {
        System.assertEquals('List has no rows for assignment to SObject', RRLoginRemote.login('testUser', 'fakepwd', null));
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
    static void testExpId(){
        RRLoginRemote.setExperienceId('111'); 
    }

}