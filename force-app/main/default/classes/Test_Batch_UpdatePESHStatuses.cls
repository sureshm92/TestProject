@isTest
public class Test_Batch_UpdatePESHStatuses {
    @isTest
    static void testBehavior() {
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
        );
        TestDataFactory.createInitData();

        id peId = [SELECT Id FROM Participant_Enrollment__c].id;
        Test.startTest();
        Database.executeBatch(new Batch_UpdatePESHStatuses(peId));
        Test.stopTest();
    }
}
