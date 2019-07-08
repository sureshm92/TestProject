/**
 * Created by Denis Z on 08-Jul-19.
 */

@IsTest
private class Test_PatientVisitResultTriggerHandler {

    @TestSetup
    static void setup() {
        ParticipantEnrollmentFactory.createParticipantStudyEnrollmentRecords('1',2,3,3);
    }

    @IsTest
    static void visitResultsUpdateTest() {
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
        Integration_VisitResult__c externalVisitResult = new Integration_VisitResult__c();
        externalVisitResult.External_Key__c = '1~2~3';
        externalVisitResult.VISIT__c = 'New Visit';
        externalVisitResult.VSDTC__c = Date.today();
        externalVisitResult.STUDYID__c = '1';
        externalVisitResult.TESTCD__c = 'RBC';
        externalVisitResult.USUBJID__c = '1';
        externalVisitResult.Vital_or_Lab__c = 'Vital';
        insert externalVisitResult;
        update externalVisitResult;
    }

}