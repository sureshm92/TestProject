@IsTest(SeeAllData=true)
public class TrialSurveyContainerControllerTest {
    @IsTest
    static void testBehavior() {
List<Survey> survey = [SELECT Id FROM Survey WHERE ActiveVersionId != NULL LIMIT 1];
        if (survey.isEmpty())
            return;
        TriggerHandlerExecutor.bypassHandler(
            TaskTriggerHandler.SendImmediateEmailsForTaskCodeHandler.class
        );
        Test.startTest();
        TestData.loadTestData();
                Test.stopTest();
        
        TestData testData = new TestData();

        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS;
        update testData.pe;

        Reminder_Schedule__c schedule = new Reminder_Schedule__c(First_Reminder_day__c = 1);
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
        TrialSurveyContainerController.getRecordTypeNameById(tsAllSee.RecordTypeId);
}
}