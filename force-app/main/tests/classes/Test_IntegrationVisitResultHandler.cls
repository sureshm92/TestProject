/**
 * Created by Denis Z on 09-Jul-19.
 */

@IsTest
private class Test_IntegrationVisitResultHandler {

    @TestSetup
    static void setup() {
        Account acc = new Account();
        acc.Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME;
        insert acc;
        ParticipantEnrollmentFactory.createParticipantEnrollmentRecords('1','2','3');
        List<Participant_Study_Enrollment__c> pseList = [
                SELECT  Id,
                        External_Key__c
                FROM    Participant_Study_Enrollment__c
                WHERE   External_Key__c = '1~2~3'
        ];
        Patient_Visit__c visit = new Patient_Visit__c();
        visit.Name = 'New Visit';
        visit.Completed_Date__c = Date.today();
        visit.Participant_Study_Enrollment__c = pseList[0].Id;
        insert visit;
    }

    @IsTest
    static void visitResultsUpdateTest() {
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
        IntegrationVisitResultTriggerHandler.updateVisitResults(new List<Integration_VisitResult__c> {externalVisitResult});
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
        IntegrationVisitResultTriggerHandler.updateVisitResults(new List<Integration_VisitResult__c> {externalVisitResult});
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
        IntegrationVisitResultTriggerHandler.updateVisitResults(new List<Integration_VisitResult__c> {externalVisitResult});
        System.assertEquals(0, [SELECT COUNT() FROM Visit_Result__c]);
        Test.stopTest();
    }

}