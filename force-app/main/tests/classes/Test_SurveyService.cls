/**
 * Created by Igor Malyuta on 13.06.2019.
 */
@IsTest(SeeAllData=true)
private class Test_SurveyService {
    static Trial_Survey__c ts;
    static Id communityId = CommunityService.getCommunityId(null);

    @IsTest
    static void generateInvitationTest() {
        List<Survey> survey = [SELECT Id, Name FROM Survey WHERE ActiveVersionId != NULL LIMIT 1];
        if (survey.isEmpty())
            return;

        TestData.loadTestData();
        Test.startTest();

        Reminder_Schedule__c schedule = new Reminder_Schedule__c(
            First_Reminder_day__c = 1,
            Second_Reminder_day__c = 2
        );
        insert schedule;

        TestData testData = new TestData();
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.CreatePIOrSendNotificationHandler.class
        );
        ts = new Trial_Survey__c(
            Active_On_Status__c = PEStatusState.PE_STATUS_SCREENING_IN_PROGRESS,
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Reminder_Schedule__c = schedule.Id,
            Survey__c = survey.get(0).Id,
            Survey_end_date__c = date.today(),
            Survey_start_date__c = date.today() - 1,
            Is_Recurrence_Survey__c = true,
            Recurrence_Frequency__c = 'weekly',
            Whose_response_needed__c = 'Patient only'
        );
        insert ts;

        SurveyInvitation invitation = SurveyService.getInstance()
            .generateInvitation(
                ts,
                testData.pe.Id,
                communityId,
                System.today(),
                UserInfo.getTimeZone()
            );
        insert invitation;

        SurveyService.getInstance().getSurveyWrapper(invitation.Id);
        SurveyService.getInstance().expireInvitation(new List<Id>{ invitation.Id });
        Test.stopTest();
    }

    @IsTest
    static void generateInvitationWithoutTSTest() {
        List<Survey> survey = [SELECT Id, Name FROM Survey WHERE ActiveVersionId != NULL LIMIT 1];
        if (survey.isEmpty())
            return;

        TestData.loadTestData();
        Test.startTest();

        Reminder_Schedule__c schedule = new Reminder_Schedule__c(
            First_Reminder_day__c = 1,
            Second_Reminder_day__c = 2
        );
        insert schedule;

        TestData testData = new TestData();

        SurveyInvitation invitation = SurveyService.getInstance()
            .generateInvitation(survey.get(0), schedule, 5, true, testData.pe.Id, communityId);
        insert invitation;
        Test.stopTest();
    }

    @IsTest
    static void getSurveyInvitationIdTest() {
        List<Survey> survey = [SELECT Id, Name FROM Survey WHERE ActiveVersionId != NULL LIMIT 1];
        if (survey.isEmpty())
            return;

        TestData.loadTestData();
        Test.startTest();
        Reminder_Schedule__c schedule = new Reminder_Schedule__c(
            First_Reminder_day__c = 1,
            Second_Reminder_day__c = 2
        );
        insert schedule;

        TestData testData = new TestData();

        ts = new Trial_Survey__c(
            Active_On_Status__c = PEStatusState.PE_STATUS_SCREENING_IN_PROGRESS,
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Expires_After_Days__c = 5,
            Survey__c = survey.get(0).Id,
            Whose_response_needed__c = 'Patient only'
        );
        insert ts;
        insert SurveyService.getInstance()
            .generateInvitation(
                ts,
                testData.pe.Id,
                communityId,
                System.today(),
                UserInfo.getTimeZone()
            );

        SurveyService.getInstance()
            .isInvitationExpired(
                SurveyService.getInstance()
                    .getSurveyInvitationId(survey.get(0).Id, testData.pe.Participant_Contact__c)
            );
        Test.stopTest();
    }
}
