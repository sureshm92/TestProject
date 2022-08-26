@IsTest(SeeAllData=true)
public class Test_ReminderScheduleBatchDeletion {

    @IsTest
    static void testReminderScheduleBatchDel_false() {
    
        TestData.loadTestData();
        Test.startTest();
        List<Survey> survey = [SELECT Id FROM Survey WHERE ActiveVersionId != NULL LIMIT 1];
        
        if (survey.isEmpty())
            return;

        TriggerHandlerExecutor.bypassHandler(
            TaskTriggerHandler.SendImmediateEmailsForTaskCodeHandler.class
        );
        
        TestData testData = new TestData();
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=testData.ctp.Id,Clinical_Trial_Profile_Name__c='test surveyInvt');
        insert studClTest;
        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS;
        update testData.pe;
        List<Reminder_Schedule__c> remSchLst= new List<Reminder_Schedule__c>();
        Reminder_Schedule__c schedule = new Reminder_Schedule__c(First_Reminder_day__c = 1);
        remSchLst.add(schedule);
        Reminder_Schedule__c schedule2 = new Reminder_Schedule__c(First_Reminder_day__c = 1);
        remSchLst.add(schedule2);
        insert remSchLst;
        List<Trial_Survey__c> triSurveyLst= new List<Trial_Survey__c>();
        Trial_Survey__c tsAllSee = new Trial_Survey__c(
            Active_After_Days__c = 0,
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Expires_After_Days__c = 999,
            Survey__c = survey.get(0).Id,
            RecordTypeId = Schema.sObjectType.Trial_Survey__c.getRecordTypeInfosByName().get('Status based').getRecordTypeId(),
            Whose_response_needed__c = 'Patient or any Delegate',
            Reminder_Schedule__c=schedule.Id
        );
        triSurveyLst.add(tsAllSee);
        Trial_Survey__c tsAllSee1 = new Trial_Survey__c(
            Active_After_Days__c = 0,
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Expires_After_Days__c = 999,
            Survey__c = survey.get(0).Id,
            RecordTypeId = Schema.sObjectType.Trial_Survey__c.getRecordTypeInfosByName().get('Status based').getRecordTypeId(),
            Whose_response_needed__c = 'Patient or any Delegate',
            Reminder_Schedule__c=schedule2.Id
        );
        triSurveyLst.add(tsAllSee1);
        insert triSurveyLst;
        Database.executeBatch(new ReminderScheduleBatchDeletion(testData.ctp.Id),10);
        Test.stopTest();        
        List<Reminder_Schedule__c> remScheLst=[SELECT Id from Reminder_Schedule__c where Id in:remSchLst];
        System.assertEquals(2,remScheLst.size());
        List<ContentDocumentLink> contentDocLinkList = [
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :studClTest.Id
        ];
        System.assertEquals(1, contentDocLinkList.size());
  }
    @IsTest
    static void testReminderScheduleBatchDel_true() {
        TestData.loadTestData();
        Test.startTest();
        List<Survey> survey = [SELECT Id FROM Survey WHERE ActiveVersionId != NULL LIMIT 1];
        if (survey.isEmpty())
            return;

        TriggerHandlerExecutor.bypassHandler(
            TaskTriggerHandler.SendImmediateEmailsForTaskCodeHandler.class
        );
        TestData testData = new TestData();
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=testData.ctp.Id,Clinical_Trial_Profile_Name__c='test surveyInvt');
        insert studClTest;
        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS;
        update testData.pe;
        List<Reminder_Schedule__c> remSchLst= new List<Reminder_Schedule__c>();
        Reminder_Schedule__c schedule = new Reminder_Schedule__c(First_Reminder_day__c = 1,Use_Final_Template__c=true);
        remSchLst.add(schedule);
        Reminder_Schedule__c schedule2 = new Reminder_Schedule__c(First_Reminder_day__c = 1,Use_Final_Template__c=true);
        remSchLst.add(schedule2);
        insert remSchLst;
        List<Trial_Survey__c> triSurveyLst= new List<Trial_Survey__c>();
        Trial_Survey__c tsAllSee = new Trial_Survey__c(
            Active_After_Days__c = 0,
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Expires_After_Days__c = 999,
            Survey__c = survey.get(0).Id,
            RecordTypeId = Schema.sObjectType.Trial_Survey__c.getRecordTypeInfosByName().get('Status based').getRecordTypeId(),
            Whose_response_needed__c = 'Patient or any Delegate',
            Reminder_Schedule__c=schedule.Id
        );
        triSurveyLst.add(tsAllSee);
        Trial_Survey__c tsAllSee1 = new Trial_Survey__c(
            Active_After_Days__c = 0,
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Expires_After_Days__c = 999,
            Survey__c = survey.get(0).Id,
            RecordTypeId = Schema.sObjectType.Trial_Survey__c.getRecordTypeInfosByName().get('Status based').getRecordTypeId(),
            Whose_response_needed__c = 'Patient or any Delegate',
            Reminder_Schedule__c=schedule2.Id
        );
        triSurveyLst.add(tsAllSee1);
        insert triSurveyLst;
        Database.executeBatch(new ReminderScheduleBatchDeletion(testData.ctp.Id,true),10);
        Test.stopTest();
        List<Reminder_Schedule__c> remScheLst=[SELECT Id from Reminder_Schedule__c where Id in:remSchLst limit 5];
        System.assertEquals(0,remScheLst.size());
  }
}