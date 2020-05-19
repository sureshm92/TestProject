/**
 * Created by Denis Z on 09-Jul-19.
 */

@IsTest(IsParallel=true)
private class Test_IntegrationVisitResultHandler {

    @TestSetup
    static void setup() {
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SendDropOutEmailHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SetCurrentEnrollmentHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateUsersOrSendNotificationsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateWelcomeToStudyAlertHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class);
        TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.CreateNotificationHandler.class);

        Test.startTest();
        Account acc = new Account();
        acc.Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME;
        insert acc;
        ParticipantEnrollmentFactory.createParticipantEnrollmentRecords('1', '2', '3');
        List<Participant_Enrollment__c> peList = [
                SELECT Id,
                        External_Key__c
                FROM Participant_Enrollment__c
                WHERE External_Key__c = '1~2~3'
        ];
        Patient_Visit__c visit = new Patient_Visit__c();
        visit.Name = 'New Visit';
        visit.Completed_Date__c = Date.today();
        visit.Participant_Enrollment__c = peList[0].Id;
        visit.SDH_Key__c = '1~2~3' + 'New Visit' + Date.today();
        insert visit;
        Test.stopTest();
    }

    @IsTest
    static void visitResultsUpdateTest() {
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(CommunityService.class, StubBuilder.newInstance(CommunityService.class)
                .when('createPortalUsers')
                .then(null)
                .when('createParticipantUsers')
                .then(null)
                .build()
        );

        IntegrationVisitResultService service = new IntegrationVisitResultService();

        Test.startTest();
        Integration_VisitResult__c externalVisitResult = new Integration_VisitResult__c();
        externalVisitResult.USUBJID__c = '1~2~3';
        externalVisitResult.VISIT__c = 'New Visit';
        externalVisitResult.VSDTC__c = Date.today();
        externalVisitResult.TESTCD__c = 'RBC';
        externalVisitResult.Vital_or_Lab__c = 'Vital';
        externalVisitResult.STNRHI__c = 10;
        externalVisitResult.STUDYID__c = '10';
        externalVisitResult.IsDeletedInSDH__c = 'N';
        insert externalVisitResult;

        service.updateVisitResults(new List<Integration_VisitResult__c> {externalVisitResult});
        System.assertEquals(10, [SELECT Max_Value__c FROM Visit_Result__c][0].Max_Value__c);

        externalVisitResult = new Integration_VisitResult__c();
        externalVisitResult.USUBJID__c = '1~2~3';
        externalVisitResult.VISIT__c = 'New Visit';
        externalVisitResult.VSDTC__c = Date.today();
        externalVisitResult.TESTCD__c = 'RBC';
        externalVisitResult.Vital_or_Lab__c = 'Vital';
        externalVisitResult.STNRHI__c = 11;
        externalVisitResult.STUDYID__c = '10';
        externalVisitResult.IsDeletedInSDH__c = 'N';
        insert externalVisitResult;

        service.updateVisitResults(new List<Integration_VisitResult__c> {externalVisitResult});
        System.assertEquals(1, [SELECT COUNT() FROM Visit_Result__c]);

        externalVisitResult = new Integration_VisitResult__c();
        externalVisitResult.USUBJID__c = '1~2~3';
        externalVisitResult.VISIT__c = 'New Visit';
        externalVisitResult.VSDTC__c = Date.today();
        externalVisitResult.TESTCD__c = 'RBC';
        externalVisitResult.Vital_or_Lab__c = 'Vital';
        externalVisitResult.STNRHI__c = 11;
        externalVisitResult.STUDYID__c = '10';
        externalVisitResult.IsDeletedInSDH__c = 'Y';
        insert externalVisitResult;

        service.updateVisitResults(new List<Integration_VisitResult__c> {externalVisitResult});
        System.assertEquals(0, [SELECT COUNT() FROM Visit_Result__c]);
        Test.stopTest();
    }

    @IsTest
    static void visitResultsBiomarkersTest() {
        IntegrationVisitResultService service = new IntegrationVisitResultService();

        Test.startTest();
        Integration_VisitResult__c externalVisitResult = new Integration_VisitResult__c(
                USUBJID__c = '1~2~3',
                VISIT__c = 'New Visit',
                VSDTC__c = Date.today(),
                TESTCD__c = 'ICOS',
                Vital_or_Lab__c = 'Biomarker',
                STUDYID__c = '10',
                STRESN__c = 1,
                IsDeletedInSDH__c = 'N'
        );
        insert externalVisitResult;
        service.updateVisitResults(new List<Integration_VisitResult__c> {externalVisitResult});
        Test.stopTest();

        System.assertEquals(1, [SELECT Actual_Value__c FROM Visit_Result__c][0].Actual_Value__c);
    }
}