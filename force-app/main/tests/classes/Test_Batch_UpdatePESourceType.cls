/**
 * Created by Alexey Moseev
 */
@IsTest
public class Test_Batch_UpdatePESourceType {

    @IsTest
    public static void testMigratePicklistToCheckboxBatch() {
        String peId = null;

        Test.startTest();
        TestData.loadTestData();
        TestData tstData = new TestData();
        peId = tstData.pe.Id;

        Database.executeBatch(new Batch_UpdatePESourceType());
        Test.stopTest();

        Participant_Enrollment__c result = [SELECT Id,
                                                Referral_Source__c,
                                                Source_Type__c
                                         	FROM Participant_Enrollment__c
        									WHERE Id = :peId];

        system.assertEquals(ParticipantEnrollmentService.PE_SOURCE_TYPE_RP, result.Source_Type__c);
    }

}