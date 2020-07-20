/**
 * An apex page controller that exposes the site login functionality
 */
@IsTest(IsParallel=true)
global with sharing class CommunitiesLoginControllerTest {

    global static void testCommunitiesLoginController () {
     	CommunitiesLoginController controller = new CommunitiesLoginController();
     	System.assertEquals(null, controller.forwardToAuthPage());       
    }    
}