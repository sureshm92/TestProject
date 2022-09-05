/**
 * Created by Igor Malyuta on 08.07.2019.
 */

@IsTest(SeeAllData=true)
private class Test_SurveyResponseTriggerHandler {
    static Id communityId = CommunityService.getCommunityId(null);

    @IsTest
    static void taskStatusChangerPauseTest() {
        TriggerHandlerExecutor.bypassHandler(
            TermsAndConditionsTriggerHandler.ActivePortalFieldsHandler.class
        );
        List<Survey> survey = [SELECT Id FROM Survey WHERE ActiveVersionId != NULL LIMIT 1];
        if (survey.isEmpty())
            return;

        TestData.loadTestData();
        Clinical_Trial_Profile__c ctp = [
            SELECT
                Id,
                Therapeutic_Area__c,
                Study_Code_Name__c,
                Study_Title__c,
                Protocol_ID__c,
                Patient_Portal_Enabled__c,
                Terms_and_Conditions__c,
                Initial_Visit_Required__c,
                Participant_Workflow_Final_Step__c,
                Final_Consent_Required__c,
                Enable_for_Call_Center_Support__c,
                Link_to_Medical_Record_Review__c,
                Link_to_Pre_screening__c
            FROM Clinical_Trial_Profile__c
            WHERE NCT_Number__c = 'NCT99999999'
        ];
        Participant__c participant = [
            SELECT
                Id,
                Name,
                First_Name__c,
                Last_Name__c,
                Email__c,
                Status__c,
                Balance__c,
                Contact__c,
                Mailing_Country_Code__c,
                Mailing_Country__c,
                Contact__r.AccountId
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        Participant_Enrollment__c pe = [
            SELECT
                Id,
                Name,
                External_Key__c,
                Participant_Contact__c,
                Participant_Status__c,
                Participant_Contact__r.Visit_Results_OptIn__c,
                Clinical_Trial_Profile__r.Shareback_Availability_Timing__c,
                Initial_visit_scheduled_date__c,
                Initial_visit_occurred_date__c,
                Initial_visit_scheduled_time__c,
                Initial_visit_occurred_flag__c,
                Initial_visit_scheduled_flag__c,
                Screening_ID__c,
                Participant__c,
                Medical_Record_Review_Completed_Date__c,
                Study_Site__r.Principal_Investigator__c,
                Study_Site__r.Principal_Investigator__r.Name,
                Study_Site__r.Principal_Investigator__r.Title,
                Participant__r.Mailing_Country_Code__c,
                Participant__r.Mailing_Country__c
            FROM Participant_Enrollment__c
            WHERE Participant__c = :participant.Id
        ];

        Test.startTest();
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.createPIUserOrSendNotification.class
        );
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.CreatePIOrSendNotificationHandler.class
        );
        Reminder_Schedule__c schedule = new Reminder_Schedule__c(First_Reminder_day__c = 1);
        insert schedule;

        Trial_Survey__c tsAllSee = new Trial_Survey__c(
            Active_On_Status__c = PEStatusState.PE_STATUS_RECEIVED,
            Clinical_Trial_Profile__c = ctp.Id,
            Expires_After_Days__c = 999,
            Reminder_Schedule__c = schedule.Id,
            Survey__c = survey.get(0).Id,
            Whose_response_needed__c = 'Patient or any Delegate'
        );
        insert tsAllSee;

        SurveyInvitation invitationAll = SurveyService.getInstance()
            .generateInvitation(
                tsAllSee,
                pe.Id,
                communityId,
                System.today(),
                UserInfo.getTimeZone()
            );
        insert invitationAll;

        TaskService.getInstance()
            .createSurveyTasks(
                new Map<Id, String>{ invitationAll.Id => 'Patient or any Delegate' }
            );

        Map<Id, List<Id>> invitationSubmitter = new Map<Id, List<Id>>{
            invitationAll.Id => new List<Id>{ pe.Participant_Contact__c }
        };

        SurveyResponseTriggerHandler.taskStatusChanger(invitationSubmitter, false);
        Test.stopTest();
    }

    @IsTest
    static void taskStatusChangerFinishTest() {
        TriggerHandlerExecutor.bypassHandler(
            TermsAndConditionsTriggerHandler.ActivePortalFieldsHandler.class
        );
        List<Survey> survey = [SELECT Id FROM Survey WHERE ActiveVersionId != NULL LIMIT 1];
        if (survey.isEmpty())
            return;

        TestData.loadTestData();
        Clinical_Trial_Profile__c ctp = [
            SELECT
                Id,
                Therapeutic_Area__c,
                Study_Code_Name__c,
                Study_Title__c,
                Protocol_ID__c,
                Patient_Portal_Enabled__c,
                Terms_and_Conditions__c,
                Initial_Visit_Required__c,
                Participant_Workflow_Final_Step__c,
                Final_Consent_Required__c,
                Enable_for_Call_Center_Support__c,
                Link_to_Medical_Record_Review__c,
                Link_to_Pre_screening__c
            FROM Clinical_Trial_Profile__c
            WHERE NCT_Number__c = 'NCT99999999'
        ];
        Participant__c participant = [
            SELECT
                Id,
                Name,
                First_Name__c,
                Last_Name__c,
                Email__c,
                Status__c,
                Balance__c,
                Contact__c,
                Mailing_Country_Code__c,
                Mailing_Country__c,
                Contact__r.AccountId
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        Participant_Enrollment__c pe = [
            SELECT
                Id,
                Name,
                External_Key__c,
                Participant_Contact__c,
                Participant_Status__c,
                Participant_Contact__r.Visit_Results_OptIn__c,
                Clinical_Trial_Profile__r.Shareback_Availability_Timing__c,
                Initial_visit_scheduled_date__c,
                Initial_visit_occurred_date__c,
                Initial_visit_scheduled_time__c,
                Initial_visit_occurred_flag__c,
                Initial_visit_scheduled_flag__c,
                Screening_ID__c,
                Participant__c,
                Medical_Record_Review_Completed_Date__c,
                Study_Site__r.Principal_Investigator__c,
                Study_Site__r.Principal_Investigator__r.Name,
                Study_Site__r.Principal_Investigator__r.Title,
                Participant__r.Mailing_Country_Code__c,
                Participant__r.Mailing_Country__c
            FROM Participant_Enrollment__c
            WHERE Participant__c = :participant.Id
        ];

        Test.startTest();
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.createPIUserOrSendNotification.class
        );
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.CreatePIOrSendNotificationHandler.class
        );
        Reminder_Schedule__c schedule = new Reminder_Schedule__c(First_Reminder_day__c = 1);
        insert schedule;

        Trial_Survey__c tsOnlyDelegates = new Trial_Survey__c(
            Active_On_Status__c = PEStatusState.PE_STATUS_RECEIVED,
            Clinical_Trial_Profile__c = ctp.Id,
            Expires_After_Days__c = 999,
            Reminder_Schedule__c = schedule.Id,
            Survey__c = survey.get(0).Id,
            Whose_response_needed__c = 'Any Delegate'
        );
        insert tsOnlyDelegates;

        SurveyInvitation invitationDelegates = SurveyService.getInstance()
            .generateInvitation(
                tsOnlyDelegates,
                pe.Id,
                communityId,
                System.today(),
                UserInfo.getTimeZone()
            );
        insert invitationDelegates;

        TaskService.getInstance()
            .createSurveyTasks(new Map<Id, String>{ invitationDelegates.Id => 'Any Delegate' });

        Contact delegateContact = new Contact(
            FirstName = 'Carlos',
            LastName = 'Allen',
            Email = 'jdavis@somemail.com'
        );
        insert delegateContact;

        Map<Id, List<Id>> invitationSubmitter = new Map<Id, List<Id>>{
            invitationDelegates.Id => new List<Id>{ delegateContact.Id }
        };

        SurveyResponseTriggerHandler.taskStatusChanger(invitationSubmitter, true);
        Test.stopTest();
    }
}
