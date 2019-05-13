/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
@IsTest(IsParallel=true)
 public with sharing class CommunitiesSelfRegConfirmControllerTest {
   public static void testCommunitiesSelfRegConfirmController() {
        // Instantiate a new controller with all parameters in the page
        CommunitiesSelfRegConfirmController controller = new CommunitiesSelfRegConfirmController();
      }    
}