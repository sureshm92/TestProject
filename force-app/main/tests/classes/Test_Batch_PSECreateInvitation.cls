/**
 * Created by Igor Malyuta on 01.08.2019.
 */

@IsTest(SeeAllData=true)
private class Test_Batch_PSECreateInvitation {

    @IsTest
    static void testBehavior() {
        List<Survey> survey = [SELECT Id FROM Survey WHERE ActiveVersionId != NULL LIMIT 1];
        if (survey.isEmpty()) return;

        TriggerHandlerExecutor.bypassHandler(TaskTriggerHandler.SendImmediateEmailsForTaskCodeHandler.class);

        TestData.loadTestData();
        TestData testData = new TestData();

        Test.startTest();
        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS;
        update testData.pe;

        Reminder_Schedule__c schedule = new Reminder_Schedule__c(
                First_Reminder_day__c = 1
        );
        insert schedule;

        Trial_Survey__c tsAllSee = new Trial_Survey__c(
                Active_After_Days__c = 0,
                Clinical_Trial_Profile__c = testData.ctp.Id,
                Expires_After_Days__c = 999,
                Reminder_Schedule__c = schedule.Id,
                Survey__c = survey.get(0).Id,
                Whose_response_needed__c = 'Patient or any Delegate'
        );
        insert tsAllSee;

        List<Participant_Enrollment__c> enrollments = [
                SELECT
                        Id,
                        Clinical_Trial_Profile__c,
                        Clinical_Trial_Profile__r.CommunityTemplate__c,
                        Days_After_Enrolled__c,
                        Participant_Contact__c,
                        Participant_Status__c
                FROM Participant_Enrollment__c
                WHERE Id =: testData.pe.Id
        ];

        new Batch_PSECreateInvitation().execute(null, enrollments);
        Test.stopTest();
    }
}
