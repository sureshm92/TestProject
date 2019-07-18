/**
 * Created by Denis Z on 08-Jul-19.
 */

@IsTest
private class Test_IntegrationVisitTriggerHandler {

    @TestSetup
    static void setup() {
        Account acc = new Account();
        acc.Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME;
        insert acc;
        //ParticipantEnrollmentFactory.createParticipantEnrollmentRecords('1','2','3');
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
        visit.SVSTDTC__c = Date.today().addDays(-1);
        update visit;
        visit.VISIT__c = 'New Visit01';
        update visit;
        visit.VISIT__c = 'New Visit02';
        visit.VISITNUM__c = 2;
        update visit;
        Test.stopTest();
        System.assertEquals(2, getVisits().size());
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