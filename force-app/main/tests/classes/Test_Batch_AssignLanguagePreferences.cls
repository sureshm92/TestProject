/**
 * Created by Nargiz Mamedova on 5/22/2020.
 */

@IsTest
private class Test_Batch_AssignLanguagePreferences {
    @IsTest
    static void testBehavior() {
        Test.startTest();
        TestData.loadTestData();
        TestData td = new TestData();
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.UpdateParticipantAndUserEmailsOnEmailChangeHandler.class
        );
        td.participant.Preferred_Language__c = null;
        td.participant.Language_Preference_Code__c = 'en_US';
        update td.participant;       
        Batch_AssignLanguagePreferences.run();
        Test.stopTest();
    } 
     
}
