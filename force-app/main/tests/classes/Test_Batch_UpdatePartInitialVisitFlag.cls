/**
 * Created by Nargiz Mamedova on 6/4/2020.
 */

@IsTest
private class Test_Batch_UpdatePartInitialVisitFlag {
    @IsTest
    static void testBehavior() {
        TestData.loadTestData();
        TestData testData = new TestData();

        testData.ctp.Initial_Visit_Required__c = true;
        update testData.ctp;

        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS;
        update testData.pe;

        Test.startTest();
        Database.executeBatch(new Batch_UpdateParticipantInitialVisitFlag());
        Test.stopTest();
        List<Participant_Enrollment__c> resPEs = [
                SELECT Id, Initial_visit_occurred_flag__c
                FROM Participant_Enrollment__c
                WHERE Id =: testData.pe.Id
        ];
        System.assertEquals(true, resPEs[0].Initial_visit_occurred_flag__c);
    }
}