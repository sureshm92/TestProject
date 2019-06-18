/**
 * Created by Igor Malyuta on 13.06.2019.
 */
@IsTest(SeeAllData = true)
private class Test_SurveyService {

    static Trial_Survey__c ts;

    @IsTest
    static void getSurveyWrapperTest() {
        List<Survey> survey = [SELECT Id, Name FROM Survey LIMIT 1];
        if(survey.isEmpty()) return;

        TestData.loadTestData();

        Test.startTest();
        TestData testData = new TestData();

        Reminder_Schedule__c schedule = new Reminder_Schedule__c(
                First_Reminder_day__c = 1,
                Second_Reminder_day__c = 2
        );
        insert  schedule;

        ts = new Trial_Survey__c(
                Active_On_Status__c = PSEService.PSE_STATUS_ENROLLED,
                Clinical_Trial_Profile__c = testData.ctp.Id,
                Expires_After_Days__c = 5,
                Reminder_Schedule__c = schedule.Id,
                Survey__c = survey.get(0).Id,
                Whose_response_needed__c = 'Patient only'
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

        Reminder_Schedule__c schedule = new Reminder_Schedule__c(
                First_Reminder_day__c = 1,
                Second_Reminder_day__c = 2
        );
        insert  schedule;

        ts = new Trial_Survey__c(
                Active_On_Status__c = PSEService.PSE_STATUS_ENROLLED,
                Clinical_Trial_Profile__c = testData.ctp.Id,
                Expires_After_Days__c = 5,
                Reminder_Schedule__c = schedule.Id,
                Survey__c = survey.get(0).Id,
                Whose_response_needed__c = 'Patient only'
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

        Reminder_Schedule__c schedule = new Reminder_Schedule__c(
                First_Reminder_day__c = 1,
                Second_Reminder_day__c = 2
        );
        insert  schedule;

        ts = new Trial_Survey__c(
                Active_On_Status__c = PSEService.PSE_STATUS_ENROLLED,
                Clinical_Trial_Profile__c = testData.ctp.Id,
                Expires_After_Days__c = 5,
                Reminder_Schedule__c = schedule.Id,
                Survey__c = survey.get(0).Id,
                Whose_response_needed__c = 'Patient only'
        );
        insert ts;
        insert SurveyService.getInstance().generateInvitation(ts, testData.pse);

        SurveyService.getInstance().getSurveyInvitationId(survey.get(0).Id, testData.pse.Participant_Contact__c);
        Test.stopTest();
    }
}