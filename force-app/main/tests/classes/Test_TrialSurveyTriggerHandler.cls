/**
 * Created by Igor Malyuta on 08.07.2019.
 */
@IsTest(SeeAllData=true)
private class Test_TrialSurveyTriggerHandler {

    @IsTest
    static void doExpireTest() {
        List<Survey> survey = [SELECT Id FROM Survey WHERE ActiveVersionId != NULL  LIMIT 1];
        if(survey.isEmpty()) return;

        TestData.loadTestData();
        TestData testData = new TestData();

        Test.startTest();
        Trial_Survey__c ts = new Trial_Survey__c(
                Active_On_Status__c = PEStatusState.PE_STATUS_REFERRAL_SENT_TO_PI,
                Clinical_Trial_Profile__c = testData.ctp.Id,
                Survey__c = survey.get(0).Id,
                Whose_response_needed__c = 'Patient only'
        );
        insert ts;

        SurveyInvitation invitation = SurveyService.getInstance()
                .generateInvitation(ts, testData.pe.Id, CommunityService.getCommunityId(null));
        insert invitation;
        TaskService.getInstance().createSurveyTasks(new Map<Id, String>{invitation.Id => 'Patient only'});

        delete ts;
        Test.stopTest();
    }
}