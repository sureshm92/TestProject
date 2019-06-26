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

        testData();
        Clinical_Trial_Profile__c ctp = [
                SELECT Id FROM Clinical_Trial_Profile__c WHERE Protocol_ID__c = 'Prot-999' LIMIT 1];
        Participant_Study_Enrollment__c pse = [
                SELECT Id, Participant_Contact__c
                FROM Participant_Study_Enrollment__c
                WHERE Clinical_Trial_Profile__c =:ctp.Id
                LIMIT 1
        ];

        Test.startTest();

        Reminder_Schedule__c schedule = new Reminder_Schedule__c(
                First_Reminder_day__c = 1,
                Second_Reminder_day__c = 2
        );
        insert  schedule;

        ts = new Trial_Survey__c(
                Active_On_Status__c = PSEService.PSE_STATUS_ENROLLED,
                Clinical_Trial_Profile__c = ctp.Id,
                Expires_After_Days__c = 5,
                Reminder_Schedule__c = schedule.Id,
                Survey__c = survey.get(0).Id,
                Whose_response_needed__c = 'Patient only'
        );
        insert ts;

        SurveyService.getInstance().generateInvitation(ts, pse);

        Test.stopTest();
    }

    @IsTest
    static void generateInvitationTest() {
        List<Survey> survey = [SELECT Id, Name FROM Survey LIMIT 1];
        if(survey.isEmpty()) return;

        testData();
        Clinical_Trial_Profile__c ctp = [
                SELECT Id FROM Clinical_Trial_Profile__c WHERE Protocol_ID__c = 'Prot-999' LIMIT 1];
        Participant_Study_Enrollment__c pse = [
                SELECT Id, Participant_Contact__c
                FROM Participant_Study_Enrollment__c
                WHERE Clinical_Trial_Profile__c =:ctp.Id
                LIMIT 1
        ];
        Test.startTest();

        Reminder_Schedule__c schedule = new Reminder_Schedule__c(
                First_Reminder_day__c = 1,
                Second_Reminder_day__c = 2
        );
        insert  schedule;

        ts = new Trial_Survey__c(
                Active_On_Status__c = PSEService.PSE_STATUS_ENROLLED,
                Clinical_Trial_Profile__c = ctp.Id,
                Expires_After_Days__c = 5,
                Reminder_Schedule__c = schedule.Id,
                Survey__c = survey.get(0).Id,
                Whose_response_needed__c = 'Patient only'
        );
        insert ts;

        SurveyInvitation invitation = SurveyService.getInstance().generateInvitation(ts, pse);
        insert invitation;

        SurveyService.getInstance().getSurveyWrapper(invitation.Id);
        Test.stopTest();
    }

    @IsTest
    static void getSurveyInvitationIdTest() {
        List<Survey> survey = [SELECT Id, Name FROM Survey LIMIT 1];
        if(survey.isEmpty()) return;

        testData();

        Clinical_Trial_Profile__c ctp = [
                SELECT Id FROM Clinical_Trial_Profile__c WHERE Protocol_ID__c = 'Prot-999' LIMIT 1];
        Participant_Study_Enrollment__c pse = [
                SELECT Id, Participant_Contact__c
                FROM Participant_Study_Enrollment__c
                WHERE Clinical_Trial_Profile__c =:ctp.Id
                LIMIT 1
        ];

        Test.startTest();
        Reminder_Schedule__c schedule = new Reminder_Schedule__c(
                First_Reminder_day__c = 1,
                Second_Reminder_day__c = 2
        );
        insert  schedule;

        ts = new Trial_Survey__c(
                Active_On_Status__c = PSEService.PSE_STATUS_ENROLLED,
                Clinical_Trial_Profile__c = ctp.Id,
                Expires_After_Days__c = 5,
                Reminder_Schedule__c = schedule.Id,
                Survey__c = survey.get(0).Id,
                Whose_response_needed__c = 'Patient only'
        );
        insert ts;
        insert SurveyService.getInstance().generateInvitation(ts, pse);

        SurveyService.getInstance().getSurveyInvitationId(survey.get(0).Id, pse.Participant_Contact__c);
        Test.stopTest();
    }

    private static void testData() {
        Clinical_Trial_Profile__c trial = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'Prot-999',
                NCT_Number__c = 'NCT09999999'
        );
        insert trial;

        Account accountPartic = new Account(Name = 'Participant');
        insert accountPartic;
        Contact patientContact = new Contact(
                FirstName = 'Richard',
                LastName = 'Wilson',
                Email = 'r.wilson@gmail.com',
                userCommunityMode__c = 'Participant',
                AccountId = accountPartic.Id
        );
        insert patientContact;

        Participant__c participant = new Participant__c(
                First_Name__c = patientContact.FirstName,
                Contact__c = patientContact.Id
        );
        insert participant;

        Participant_Enrollment__c pe = new Participant_Enrollment__c(
                Patient_ID__c = 'SomePatientId1',
                Referral_Source__c = 'HCP',
                Participant__c = participant.Id
        );
        insert pe;

        Participant_Study_Enrollment__c pse = new Participant_Study_Enrollment__c(
                Clinical_Trial_Profile__c = trial.Id,
                Participant__c = participant.Id,
                Participant_Enrollment__c = pe.Id
        );
        insert pse;
    }
}