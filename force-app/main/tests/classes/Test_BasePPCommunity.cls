/**
 * Created by Leonid Bartenev
 *
 * All integration tests for Patient Portal should be here,
 * test data initialised one time in init() method for saving of time
 *
 */

@IsTest(IsParallel=true)
private class Test_BasePPCommunity {
    
    @TestSetup
    public static void init(){
        ClassFactory.putStubTypeByClassName(CommunityService.class, StubFactory.newInstance(CommunityService.class)
                .when('createPortalUsers')
                .then(null)
                .when('createParticipantUsers')
                .then(null)
                .getInstance()
        );
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateUsersOrSendNotificationsHandler.class);
        TestData.loadTestData();
    }
    
    @IsTest
    static void pseCreationTest() {
        Test.startTest();
        TestData testDataInstance = new TestData();
        testDataInstance.createPSE();
        Test.stopTest();
        System.assert(testDataInstance.pe.Screening_ID__c == testDataInstance.pse.Screening_ID__c, 'ScreeningId not copied from PE to PSE');
    }
    
    @IsTest
    static void patientVisitSchedule(){
        Test.startTest();
        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test VP');
        insert vp;
        List<Visit__c> visits = new List<Visit__c>{
                new Visit__c(
                        Visit_Plan__c = vp.Id,
                        Order__c = 1,
                        Visit_Number__c = 1
                ),
                new Visit__c(
                        Visit_Plan__c = vp.Id,
                        Order__c = 2,
                        Visit_Number__c = 2
                )
        };
        insert visits;
        TriggerHandlerExecutor.bypassHandler(PatientVisitTriggerHandler.UpdateMissedVisits.class);
        TestData testDataInstance = new TestData();
        testDataInstance.ctp.Visit_Plan__c = vp.Id;
        update testDataInstance.ctp;
        testDataInstance.createPSE();
        Test.stopTest();
        List<Patient_Visit__c> patientVisits = [
                SELECT Id, Visit_Number__c, Visit_Schedule__c
                FROM Patient_Visit__c
                WHERE Participant_Study_Enrollment__c =: testDataInstance.pse.Id
        ];
        System.assert(patientVisits.size() == 2, 'Patient Visits not created');
    }
    
}