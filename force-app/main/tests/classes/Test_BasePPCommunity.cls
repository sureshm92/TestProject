/**
 * Created by Leonid Bartenev
 *
 * All integration tests for Patient Portal should be here,
 * test data initialised one time in init() method for saving of time
 *
 */

@IsTest(IsParallel=true)
private class Test_BasePPCommunity {

    @IsTest
    static void patientVisitSchedule(){
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(CommunityService.class, StubBuilder.newInstance(CommunityService.class)
            .when('createPortalUsers')
            .then(null)
            .when('createParticipantUsers')
            .then(null)
            .build()
    );
        TestData.loadTestData();
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
        testDataInstance.updatePEStatusEnrollmentSuccess();
        Test.stopTest();
        List<Patient_Visit__c> patientVisits = [
                SELECT Id, Visit_Number__c, Visit_Schedule__c
                FROM Patient_Visit__c
                WHERE Participant_Enrollment__c =: testDataInstance.pe.Id
        ];
        System.assert(patientVisits.size() == 2, 'Patient Visits not created');
    }
    
}