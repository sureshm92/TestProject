/**
 * Created by Denis Z on 08-Jul-19.
 */

@IsTest(IsParallel=true)
private class Test_IntegrationVisitTriggerHandler {

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
        ParticipantEnrollmentFactory.createParticipantEnrollmentRecords('1','2','3');
        List<Participant_Enrollment__c> peList = [
                SELECT  Id,
                        External_Key__c
                FROM    Participant_Enrollment__c
                WHERE   External_Key__c = '1~2~3'
        ];
        List<Patient_Visit__c> visits = new List<Patient_Visit__c>();
        for(Integer i = 1; i <= 3; i++){
            Patient_Visit__c visit = new Patient_Visit__c();
            visit.Name = 'New Visit' + i;
            visit.Visit_Number__c = i;
            visit.Status__c = 'Pending';
            visit.Participant_Enrollment__c = peList[0].Id;
            visits.add(visit);
        }
        insert visits;
        Test.stopTest();
    }

    @IsTest
    static void visitsUpdateTest() {
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(CommunityService.class, StubBuilder.newInstance(CommunityService.class)
                .when('createPortalUsers')
                .then(null)
                .when('createParticipantUsers')
                .then(null)
                .build()
        );

        List<Integration_Visit__c> externalVisits = new List<Integration_Visit__c>();
        externalVisits.add(createVisit(1,'N'));
        externalVisits.add(createVisit(3,'N'));
        externalVisits.add(createVisit(3.1,'N'));
        insert externalVisits;

        Test.startTest();
        IntegrationVisitTriggerHandler.updateVisits(externalVisits);
        List<Patient_Visit__c> patientVisits = getVisits();
        System.assertEquals(4, patientVisits.size());
        System.assertEquals('Completed', patientVisits[0].Status__c);
        System.assertEquals('Missed', patientVisits[1].Status__c);
        System.assertEquals(false, patientVisits[2].Is_Adhoc__c);
        System.assertEquals(true, patientVisits[3].Is_Adhoc__c);

        externalVisits = new List<Integration_Visit__c>();
        externalVisits.add(createVisit(3.1,'Y'));
        externalVisits.add(createVisit(1,'Y'));
        insert externalVisits;

        IntegrationVisitTriggerHandler.updateVisits(externalVisits);
        patientVisits = getVisits();
        System.assertEquals(3, patientVisits.size());
        System.assertEquals('Missed', patientVisits[0].Status__c);
        Test.stopTest();
    }

    private static Integration_Visit__c createVisit(Decimal visitNumber, String isDeleted){
        Integration_Visit__c visit = new Integration_Visit__c();
        visit.USUBJID__c = '1~2~3';
        visit.SVSTDTC__c = Date.today();
        visit.VISIT__c = 'New Visit' + visitNumber;
        visit.VISITNUM__c = visitNumber;
        visit.IsDeletedInSDH__c = isDeleted;
        return visit;
    }

    private static List<Patient_Visit__c> getVisits(){
        List<Patient_Visit__c> visits = [
                SELECT
                        Id,
                        Name,
                        Is_Adhoc__c,
                        Completed_Date__c,
                        Visit_Number__c,
                        Status__c
                FROM    Patient_Visit__c
                WHERE   Participant_Enrollment__r.External_Key__c = '1~2~3'
                ORDER BY Visit_Number__c
        ];
        return visits;
    }
}