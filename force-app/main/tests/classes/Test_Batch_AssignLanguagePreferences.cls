/**
 * Created by Nargiz Mamedova on 5/22/2020.
 */

@IsTest
private class Test_Batch_AssignLanguagePreferences {
    @IsTest
    static void testBehavior() {
        TestData.loadTestData();
        TestData td = new TestData();
        td.participant.Preferred_Language__c = null;
        td.participant.Language_Preference_Code__c = 'en_US';
        update td.participant;
        Test.startTest();
        Batch_AssignLanguagePreferences.run();
        Test.stopTest();

        Participant__c participant = [SELECT Id, Preferred_Language__c FROM Participant__c WHERE Id =: td.participant.Id];
        System.assertEquals('en_US', participant.Preferred_Language__c);
    }
}