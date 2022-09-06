/**
 * Created by user on 06-Feb-20.
 */

@IsTest
private class Test_Batch_UpdateParticipantEnrollmentRP {
    
    @IsTest
    static void testNewCheckBoxForPe() {
        String peId = null;
        List<String> triggersToExecute = new List<String>();
        triggersToExecute.add('ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler');
        TestData.loadTestData(true, triggersToExecute);
        TestData testData = new TestData();
        testData.pe.Show_Referring_Provider__c = false;
        testData.pe.Source_Type__c = 'Referring Provider';
        testData.pe.Referral_Source__c ='HCP';
        update testData.pe;
        
        Test.startTest();
        Database.executeBatch(new Batch_UpdateParticipantEnrollmentRP());
        Test.stopTest();

        Participant_Enrollment__c result = [
            SELECT Id, Show_Referring_Provider__c, Referral_Source__c, Source_Type__c
            FROM Participant_Enrollment__c
            WHERE Id = : testData.pe.Id
        ];
       system.assertEquals(false, result.Show_Referring_Provider__c);
    }
}