@isTest 
Public Class Test_NonReferredPatientController{
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        TestData.createTCAcceptance();
        Test.stopTest();
    }
    @isTest
    Public Static Void Test_NonReferredPatientControllerMethod(){
        TestData testData = new TestData();
        List<Id> participantEnrollmentId = new List<Id>();
        participantEnrollmentId.add(testData.pe.Id);
        try{
            NonReferredPatientController.changeStatusToExcludeFromReferring(participantEnrollmentId);
            NonReferredPatientController.getpatientdetails(testData.pe.Id);
        }catch(Exception e){
        
        }
    }
    @isTest
    Public Static Void Test_NonReferredPatientControllerMethod1(){
        List<Id> participantEnrollmentId;
        Id peId;
        try{
            NonReferredPatientController.changeStatusToExcludeFromReferring(participantEnrollmentId);
            NonReferredPatientController.getpatientdetails(peId);
        }catch(Exception e){
        
        }
        
    }
}