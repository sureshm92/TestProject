/**
 * Created by Igor Malyuta on 13.06.2019.
 */
@IsTest(SeeAllData = true)
private class Test_SurveyService {

    private static Trial_Survey__c ts;

    @IsTest
    static void getSurveyWrapperTest() {
        List<Survey> survey = [SELECT Id, Name FROM Survey LIMIT 1];
        if(survey.isEmpty()) return;

        TestData.loadTestData();

        Test.startTest();
        TestData testData = new TestData();

        ts = new Trial_Survey__c(
                Active_On_Status__c = PSEService.PSE_STATUS_ENROLLED,
                Clinical_Trial_Profile__c = testData.ctp.Id,
                Expires_After_Days__c = 5,
                Survey__c = survey.get(0).Id,
                Visible_For__c = 'Participant'
        );
        insert ts;

        SurveyService.getInstance().generateInvitation(ts, testData.pse);

        Test.stopTest();
    }

    @IsTest
    static void generateInvitationTest() {
        List<Survey> survey = [SELECT Id, Name FROM Survey LIMIT 1];
        if(survey.isEmpty()) return;

        TestData.loadTestData();

        Test.startTest();
        TestData testData = new TestData();

        ts = new Trial_Survey__c(
                Active_On_Status__c = PSEService.PSE_STATUS_ENROLLED,
                Clinical_Trial_Profile__c = testData.ctp.Id,
                Expires_After_Days__c = 5,
                Survey__c = survey.get(0).Id,
                Visible_For__c = 'Participant'
        );
        insert ts;

        SurveyInvitation invitation = SurveyService.getInstance().generateInvitation(ts, testData.pse);
        insert invitation;

        SurveyService.getInstance().getSurveyWrapper(invitation.Id);
        Test.stopTest();
    }

    @IsTest
    static void getSurveyInvitationIdTest() {
        List<Survey> survey = [SELECT Id, Name FROM Survey LIMIT 1];
        if(survey.isEmpty()) return;

        TestData.loadTestData();

        Test.startTest();
        TestData testData = new TestData();

        ts = new Trial_Survey__c(
                Active_On_Status__c = PSEService.PSE_STATUS_ENROLLED,
                Clinical_Trial_Profile__c = testData.ctp.Id,
                Expires_After_Days__c = 5,
                Survey__c = survey.get(0).Id,
                Visible_For__c = 'Participant'
        );
        insert ts;
        insert SurveyService.getInstance().generateInvitation(ts, testData.pse);

        SurveyService.getInstance().getSurveyInvitationId(survey.get(0).Id, testData.pse.Participant_Contact__c);
        Test.stopTest();
    }
}