/**
 * Created by Igor Malyuta on 08.07.2019.
 */
@IsTest(SeeAllData=true)
private class Test_TrialSurveyTriggerHandler {
    @IsTest
    static void doExpireTest() {
        List<Survey> survey = [SELECT Id FROM Survey WHERE ActiveVersionId != NULL LIMIT 1];
        if (survey.isEmpty())
            return;

        TestData.loadTestData();
        Test.startTest();
        TestData testData = new TestData();

        Integer taskSize;

        Trial_Survey__c ts = new Trial_Survey__c(
            Active_On_Status__c = PEStatusState.PE_STATUS_RECEIVED,
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Survey__c = survey.get(0).Id,
            Survey_end_date__c = date.today(),
            Survey_start_date__c = date.today() - 1,
            Whose_response_needed__c = 'Patient only'
        );
        insert ts;
        system.debug('userinfo ->' + UserInfo.getTimeZone());
        SurveyInvitation invitation = SurveyService.getInstance()
            .generateInvitation(
                ts,
                testData.pe.Id,
                CommunityService.getCommunityId(null),
                System.today(),
                UserInfo.getTimeZone()
            );

        insert invitation;
        taskSize = TaskService.getInstance()
            .createSurveyTasks(new Map<Id, String>{ invitation.Id => 'Patient only' });
        TrialSurveyTriggerHandler.doExpire(new List<Trial_Survey__c>{ ts });
        delete ts;
        Test.stopTest();
        System.assertEquals(1, taskSize);
    }
}
