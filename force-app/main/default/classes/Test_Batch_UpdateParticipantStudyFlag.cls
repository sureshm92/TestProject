@IsTest
public class Test_Batch_UpdateParticipantStudyFlag {
    @IsTest
    static void testBehavior() {
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateMissingStatuses.class
        );
        TestDataFactory.createInitData();
        Test.startTest();
        Database.executeBatch(new Batch_UpdateParticipantStudyFlag());
        Batch_UpdateParticipantStudyFlag.launch();
        Test.stopTest();
    }
}
