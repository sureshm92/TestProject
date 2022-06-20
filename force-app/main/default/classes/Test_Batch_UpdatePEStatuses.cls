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
        Participant_Enrollment__c peObj = new Participant_Enrollment__c();
        peObj.Id = peId;
        peObj.Participant_Status__c = 'screening passed - wash out period';
        peObj.Non_Enrollment_Reason__c = '';
        peObj.Last_Status_Changed_Notes__c = 'unable to screen';
        update peObj;
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
