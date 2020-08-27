@IsTest
public class Test_Batch_UpdateParticipantStudyFlag {
     @IsTest
    static void testBehavior() {
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class);
        TestDataFactory.createInitData();
        Test.startTest();
        Database.executeBatch(new Batch_UpdateParticipantStudyFlag());
        Test.stopTest();
    }

}