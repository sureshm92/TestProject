/**
 * Created by Sumit Surve on 9/23/2021
 */

@IsTest
private class Test_UploadParticipantsBatchHelper {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    
    @IsTest
    static void testBehavior() {
        
        
        Test.startTest();
        TestData td = new TestData();
        
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.UpdateParticipantAndUserEmailsOnEmailChangeHandler.class
        );
        //td.participant.Preferred_Language__c = null;
        //td.participant.Language_Preference_Code__c = 'en_US';
        //update td.participant;
        //UploadParticipantsBatchHelper ba= new UploadParticipantsBatchHelper();
        List<Id> peidlist = new List<Id>();
        
        Participant_Enrollment__c perec = new Participant_Enrollment__c();
        peidlist.add(td.pe.Id);
        Id jobid = Database.executeBatch(new UploadParticipantsBatchHelper(peidlist), 5);
        
    }
}