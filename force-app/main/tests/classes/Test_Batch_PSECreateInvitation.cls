/**
 * Created by Igor Malyuta on 01.08.2019.
 */

@IsTest(SeeAllData=true)
private class Test_Batch_PSECreateInvitation {
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
        testData.pe.Clinical_Trial_Profile__c = testData.ctp.Id;
        update testData.pe;

        Reminder_Schedule__c schedule = new Reminder_Schedule__c(First_Reminder_day__c = 1);
        insert schedule;

        Trial_Survey__c tsAllSee = new Trial_Survey__c(
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Survey__c = survey.get(0).Id,
            Survey_start_date__c = date.today() - 1,
            Survey_end_date__c = date.today(),
            Next_Occurrence_Date__c = date.today() - 1,
            Whose_response_needed__c = 'Patient or any Delegate'
        );
        
 		insert tsAllSee;
        
		List<Participant_Enrollment__c> enrollments = [
            SELECT
                Id,
                Clinical_Trial_Profile__c,
                Clinical_Trial_Profile__r.CommunityTemplate__c,
                Days_After_Enrolled__c,
                Participant_Contact__c,
                Participant_Status__c
            FROM Participant_Enrollment__c
            WHERE Id = :testData.pe.Id
        ];
		 
        Batch_PSECreateInvitation b = new Batch_PSECreateInvitation();
        b.start(null);
        b.execute(null, enrollments);
        b.finalAction();
        b.getType();
        b.getBatchDescription();
        b.getRecommendedIntervalMode();
        b.getRecommendedRelaunchInterval();
        
    }
    
    @IsTest
    static void testBehavior1() {
        List<Survey> survey = [SELECT Id FROM Survey WHERE ActiveVersionId != NULL LIMIT 1];
        if (survey.isEmpty())
            return;

        TriggerHandlerExecutor.bypassHandler(
            TaskTriggerHandler.SendImmediateEmailsForTaskCodeHandler.class
        );
        Test.startTest();
        TestData.loadTestData();
        Trial_Survey__c tsAllSee1 = new Trial_Survey__c();
      //  tsAllSee1.Next_Task_Due_Date__c = date.today()+2;
        //tsAllSee1.Survey_end_date__c = date.today();
        //tsAllSee1.Recurrence_Frequency__c = 'Daily';
        //tsAllSee1.Survey__c = survey[0].id;
       // tsAllSee1.Clinical_Trial_Profile__c = testData.ctp.Id;
        
      //  insert tsAllSee1;
        Batch_PSECreateInvitation bpi = new Batch_PSECreateInvitation();
        bpi.updateTrialSurvey(tsAllSee1);
        Test.stopTest();

        TestData testData = new TestData();

        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS;
        testData.pe.Clinical_Trial_Profile__c = testData.ctp.Id;
        update testData.pe;

        Reminder_Schedule__c schedule = new Reminder_Schedule__c(First_Reminder_day__c = 1);
        insert schedule;

        Trial_Survey__c tsAllSee = new Trial_Survey__c(
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Survey__c = survey.get(0).Id,
            Survey_start_date__c = date.today() - 1,
            Survey_end_date__c = date.today().addDays(5),
            Is_Recurrence_Survey__c = true,
            Next_Task_Due_Date__c = date.today()+3,
            
            Recurrence_Frequency__c = 'Weekly',
            Reminder_in_days_before_the_end_date__c = 2,
            Next_Occurrence_Date__c = date.today() ,
            Next_Occurrence_Reminder__c = date.today().addDays(2),
            Whose_response_needed__c = 'Patient or any Delegate'
        );
               
        insert tsAllSee;
       
        
		List<Participant_Enrollment__c> enrollments = [
            SELECT
                Id,
                Clinical_Trial_Profile__c,
                Clinical_Trial_Profile__r.CommunityTemplate__c,
                Days_After_Enrolled__c,
                Participant_Contact__c,
                Participant_Status__c
            FROM Participant_Enrollment__c
            WHERE Id = :testData.pe.Id
        ];
		
        SurveyInvitation svyInv = new SurveyInvitation(
            Participant_Enrollment__c = enrollments[0].id, 
            ExpireDateTime__c = Datetime.now() - 1, 
            Trial_Survey__c = tsAllSee.id,
            SurveyId = tsAllSee.Survey__c,
            Survey__c = tsAllSee.Survey__c,
            Name = tsAllSee.Survey__r.Name + ':TS:' + tsAllSee.Id,
            IsTrialSurvey__c = true
        );
        insert svyInv;
        
        Batch_PSECreateInvitation b = new Batch_PSECreateInvitation();
        b.start(null);
        b.execute(null, enrollments);
        b.finalAction();
        b.getType();
        b.getBatchDescription();
        b.getRecommendedIntervalMode();
        b.getRecommendedRelaunchInterval();
       
        bpi.updateTrialSurvey(tsAllSee);
    }
}