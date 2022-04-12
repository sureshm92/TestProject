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
            Is_Recurrence_Survey__c = true,
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
        new TrialSurveyTriggerHandler.ExpireSurveyTaskAndInvitations()
            .beforeDelete(new List<Trial_Survey__c>{ ts });
        new TrialSurveyTriggerHandler.UpdateTrialSurveyAndInvitations()
            .beforeInsert(new List<Trial_Survey__c>{ ts });
        // TrialSurveyTriggerHandler.updateTrialSurvey(new List<Trial_Survey__c>{ ts },null);
        delete ts;
        Test.stopTest();
        System.assertEquals(1, taskSize);
    }

    @IsTest
    static void updateTest() {
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
            Is_Recurrence_Survey__c = true,
            Recurrence_Frequency__c = 'Weekly',
            Reminder_in_days_before_the_end_date__c = 3,
            Survey_end_date__c = date.today() + 20,
            Survey_start_date__c = date.today() - 1,
            Is_Midpoint__c = true,
            Whose_response_needed__c = 'Patient only'
        );
        insert ts;

        Trial_Survey__c ts1 = new Trial_Survey__c(
            Active_On_Status__c = PEStatusState.PE_STATUS_RECEIVED,
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Survey__c = survey.get(0).Id,
            Survey_end_date__c = date.today(),
            Survey_start_date__c = date.today() - 1,
            Whose_response_needed__c = 'Patient only'
        );
        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_TRIAL_COMPLETE;
        update testData.pe;
        Map<Id, Trial_Survey__c> oldMap = new Map<Id, Trial_Survey__c>();
        oldMap.put(ts.id, ts1);
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

        new TrialSurveyTriggerHandler.UpdateTrialSurveyAndInvitations()
            .beforeInsert(new List<Trial_Survey__c>{ ts });
        new TrialSurveyTriggerHandler.UpdateTrialSurveyAndInvitations()
            .beforeUpdate(new List<Trial_Survey__c>{ ts }, oldMap);
        new TrialSurveyTriggerHandler.UpdateTrialSurveyAndInvitations()
            .afterUpdate(new List<Trial_Survey__c>{ ts }, oldMap);
        Test.stopTest();
        System.assertEquals(1, taskSize);
    }

    @IsTest
    static void updateTestMethod() {
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
            Is_Recurrence_Survey__c = false,
            Recurrence_Frequency__c = 'Weekly',
            Reminder_in_days_before_the_end_date__c = 3,
            Survey_end_date__c = date.today() + 20,
            Survey_start_date__c = date.today() - 1,
            Is_Midpoint__c = true,
            Whose_response_needed__c = 'Patient only'
        );
        insert ts;

        Trial_Survey__c ts1 = new Trial_Survey__c(
            Active_On_Status__c = PEStatusState.PE_STATUS_RECEIVED,
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Survey__c = survey.get(0).Id,
            Is_Recurrence_Survey__c = true,
            Survey_end_date__c = date.today(),
            Survey_start_date__c = date.today() - 1,
            Whose_response_needed__c = 'Patient only'
        );
        Map<Id, Trial_Survey__c> oldMap = new Map<Id, Trial_Survey__c>();
        oldMap.put(ts.id, ts1);
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

        new TrialSurveyTriggerHandler.UpdateTrialSurveyAndInvitations()
            .beforeUpdate(new List<Trial_Survey__c>{ ts }, oldMap);
        Test.stopTest();
        System.assertEquals(1, taskSize);
    }

    @IsTest
    static void updateTestMethod1() {
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
            Is_Recurrence_Survey__c = true,
            Next_Occurrence_Date__c = date.today() + 1,
            Next_Task_Due_Date__c = date.today() + 6,
            Recurrence_Frequency__c = 'Weekly',
            Reminder_in_days_before_the_end_date__c = 3,
            Survey_end_date__c = date.today() + 2,
            Survey_start_date__c = date.today() - 1,
            Is_Midpoint__c = true,
            Whose_response_needed__c = 'Patient only'
        );
        insert ts;

        Trial_Survey__c ts1 = new Trial_Survey__c(
            Active_On_Status__c = PEStatusState.PE_STATUS_RECEIVED,
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Survey__c = survey.get(0).Id,
            Is_Recurrence_Survey__c = false,
            Survey_end_date__c = date.today() + 20,
            Survey_start_date__c = date.today() - 1,
            Whose_response_needed__c = 'Patient only'
        );

        Map<Id, Trial_Survey__c> oldMap = new Map<Id, Trial_Survey__c>();
        oldMap.put(ts.id, ts1);
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

        new TrialSurveyTriggerHandler.UpdateTrialSurveyAndInvitations()
            .beforeUpdate(new List<Trial_Survey__c>{ ts }, oldMap);
        Test.stopTest();
        System.assertEquals(1, taskSize);
    }
}
