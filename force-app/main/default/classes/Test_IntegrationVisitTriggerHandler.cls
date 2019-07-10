/**
 * Created by user on 08-Jul-19.
 */

@IsTest
private class Test_IntegrationVisitTriggerHandler {

    @TestSetup
    static void setup() {
        ParticipantEnrollmentFactory.createParticipantStudyEnrollmentRecords('1',2,3,3);
    }

    @IsTest
    static void visitsUpdateTest() {
        Integration_Visit__c visit = new Integration_Visit__c();
        visit.External_Key__c = '1~2~3';
        visit.SVSTDTC__c = Date.today();
        visit.VISIT__c = 'New Visit';
        visit.VISITNUM__c = 1;
        Test.startTest();
        insert visit;
        System.assertEquals('New Visit', getVisits()[0].Name);
        visit.SVSTDTC__c = Date.today().addDays(-1);
        update visit;
        System.assertEquals(Date.today().addDays(-1), getVisits()[0].Completed_Date__c);
        visit.VISIT__c = 'New Visit01';
        update visit;
        System.assertEquals(1, getVisits().size());
        visit.VISIT__c = 'New Visit02';
        visit.VISITNUM__c = 2;
        update visit;
        System.assertEquals(2, getVisits().size());
        Test.stopTest();
    }

    private static List<Patient_Visit__c> getVisits(){
        List<Patient_Visit__c> visits = [
                SELECT
                        Id,
                        Name,
                        Is_Adhoc__c,
                        Completed_Date__c
                FROM    Patient_Visit__c
                WHERE   Participant_Study_Enrollment__r.External_Key__c = '1~2~3'
        ];
        return visits;
    }
}