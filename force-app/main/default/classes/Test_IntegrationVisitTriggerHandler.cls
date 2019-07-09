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
        insert visit;
        update visit;
        visit.VISIT__c = 'New Visit01';
        update visit;
    }
}