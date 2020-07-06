/**
 * Created by user on 18-Jun-20.
 */

@IsTest
private class Test_Batch_UpdatePE_PermitContactFlag {

    @IsTest
    static void testBehavior() {
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class);
        TestDataFactory.createInitData();

        Integer peSize = [SELECT Id, Permit_IQVIA_to_contact_about_study__c
                          FROM Participant_Enrollment__c
                          WHERE Permit_IQVIA_to_contact_about_study__c = FALSE ].size();
        System.assert(peSize > 0);

        Test.startTest();
        Database.executeBatch(new Batch_UpdatePE_PermitContactFlag());
        Test.stopTest();

        Integer peSize2 = [SELECT Id, Permit_IQVIA_to_contact_about_study__c
                           FROM Participant_Enrollment__c
                           WHERE Permit_IQVIA_to_contact_about_study__c = FALSE].size();
        System.assert(peSize2 == 0);
    }
}