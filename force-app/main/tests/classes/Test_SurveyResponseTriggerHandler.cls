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
        TestData testData = new TestData();

        Test.startTest();
        Reminder_Schedule__c schedule = new Reminder_Schedule__c(First_Reminder_day__c = 1);
        insert schedule;

        Trial_Survey__c tsAllSee = new Trial_Survey__c(
            Active_On_Status__c = PEStatusState.PE_STATUS_RECEIVED,
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Expires_After_Days__c = 999,
            Reminder_Schedule__c = schedule.Id,
            Survey__c = survey.get(0).Id,
            Whose_response_needed__c = 'Patient or any Delegate'
        );
        insert tsAllSee;

        SurveyInvitation invitationAll = SurveyService.getInstance()
            .generateInvitation(tsAllSee, testData.pe.Id, communityId, System.today(), UserInfo.getTimeZone());
        insert invitationAll;

        TaskService.getInstance()
            .createSurveyTasks(
                new Map<Id, String>{ invitationAll.Id => 'Patient or any Delegate' }
            );

        Map<Id, List<Id>> invitationSubmitter = new Map<Id, List<Id>>{
            invitationAll.Id => new List<Id>{ testData.pe.Participant_Contact__c }
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
        TestData testData = new TestData();

        Test.startTest();
        Reminder_Schedule__c schedule = new Reminder_Schedule__c(First_Reminder_day__c = 1);
        insert schedule;

        Trial_Survey__c tsOnlyDelegates = new Trial_Survey__c(
            Active_On_Status__c = PEStatusState.PE_STATUS_RECEIVED,
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Expires_After_Days__c = 999,
            Reminder_Schedule__c = schedule.Id,
            Survey__c = survey.get(0).Id,
            Whose_response_needed__c = 'Any Delegate'
        );
        insert tsOnlyDelegates;

        SurveyInvitation invitationDelegates = SurveyService.getInstance()
            .generateInvitation(tsOnlyDelegates, testData.pe.Id, communityId,System.today(),UserInfo.getTimeZone());
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