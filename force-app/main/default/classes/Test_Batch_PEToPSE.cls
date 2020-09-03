@isTest
public class Test_Batch_PEToPSE {
    @isTest
    static void testBehavior() {
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class);
        TestDataFactory.createInitData();
        List<Id> pId = new List<Id>();
        for(Participant_Enrollment__c peId: [Select Id FROM Participant_Enrollment__c]){
            pId.add(peId.Id);
        }
        Test.startTest();
        Database.executeBatch(new Batch_PEToPSE(pId));
        Test.stopTest();
    }
}