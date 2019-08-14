/**
 * Created by Leonid Bartenev
 *
 * All integration tests for Patient Portal should be here,
 * test data initialised one time in init() method for saving of time
 *
 */

@IsTest
private class Test_BasePPCommunity {
    
    @TestSetup
    static void setup(){
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateUsersOrSendNotificationsHandler.class);
        TestData.loadTestData();
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

        TestData testDataInstance = new TestData();
        testDataInstance.ctp.Visit_Plan__c = vp.Id;
        update testDataInstance.ctp;

        testDataInstance.pe.Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS;
        update testDataInstance.pe;

        Test.stopTest();
        List<Patient_Visit__c> patientVisits = [
                SELECT Id, Visit_Number__c, Visit_Schedule__c
                FROM Patient_Visit__c
                WHERE Participant_Enrollment__c =: testDataInstance.pe.Id
        ];
        System.assert(patientVisits.size() == 2, 'Patient Visits not created');
    }
}