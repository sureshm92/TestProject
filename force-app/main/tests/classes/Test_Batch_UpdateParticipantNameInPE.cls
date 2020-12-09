@isTest
private class Test_Batch_UpdateParticipantNameInPE {
    @isTest
    static void testBehavior() {
    
        TestData.loadTestData();
         Test.startTest();
        TestData testData = new TestData();

        testData.pe.Participant_Name__c = '';
        testData.pe.Participant_Surname__c = '';
        update testData.pe;

        
        Database.executeBatch(new Batch_UpdateParticipantNameInPE());
        Test.stopTest();

        List<Participant_Enrollment__c> resPEs = [
            SELECT Id, Participant_Name__c, Participant_Surname__c
            FROM Participant_Enrollment__c
            WHERE Id = :testData.pe.Id
        ];
        System.assertNotEquals('', resPEs[0].Participant_Name__c);
        System.assertNotEquals('', resPEs[0].Participant_Surname__c);
    }
}