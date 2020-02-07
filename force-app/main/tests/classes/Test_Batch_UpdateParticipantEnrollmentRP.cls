/**
 * Created by user on 06-Feb-20.
 */

@IsTest
private class Test_Batch_UpdateParticipantEnrollmentRP {
    @IsTest
    static void testNewCheckBoxForPe() {
        String peId = null;

        Test.startTest();
        TestData.loadTestData();
        TestData tstData = new TestData();
        peId = tstData.pe.Id;
        Participant_Enrollment__c startStatus = [SELECT Id, Show_Referring_Provider__c,
                Referral_Source__c,
                Source_Type__c
        FROM Participant_Enrollment__c
        WHERE Show_Referring_Provider__c = FALSE
        LIMIT 1];

        Database.executeBatch(new Batch_UpdateParticipantEnrollmentRP());
        Test.stopTest();

        Participant_Enrollment__c result = [SELECT Id, Show_Referring_Provider__c,
                                                   Referral_Source__c,
                                                   Source_Type__c
                                            FROM Participant_Enrollment__c
                                            WHERE Id = :startStatus.Id];

        system.assertEquals(true, result.Show_Referring_Provider__c);
    }
}