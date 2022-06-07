@IsTest
public class Test_Batch_UpdatePEStatuses {
    @IsTest
    static void testBehavior() {
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateMissingStatuses.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateService.getDelegateContactIdsByPAContactIs.class
        );
        TestDataFactory.createInitData();
        Participant_Enrollment_Status_History__c pesh = new Participant_Enrollment_Status_History__c();
        id peId = [SELECT Id FROM Participant_Enrollment__c].id;
        Batch_UpdatePEStatuses up = new Batch_UpdatePEStatuses(peId);
        pesh.ParticipantEnrollment__c = peId;
        pesh.Status__c = 'Eligiblity Passed';
        Test.startTest();
        Database.executeBatch(new Batch_UpdatePEStatuses());
        //pesh.ParticipantEnrollment__c = peId;
        pesh.Status__c = 'Referral Accepted';
        //Insert pesh;
        Database.executeBatch(new Batch_DataCleanup_ReceivedHistories());

        Test.stopTest();
    }
}
