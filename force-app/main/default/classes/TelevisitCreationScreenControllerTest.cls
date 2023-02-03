@isTest
Public Class TelevisitCreationScreenControllerTest{
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        TestData.createTCAcceptance();
        Test.stopTest();
    }
    
    @isTest 
    Public Static Void TestMethod1(){
        TestData testData = new TestData();
        List<String> participantEnrollmentId = new List<String>();
        participantEnrollmentId.add(testData.pe.Id);
        Clinical_Trial_Profile__c ctp = new Clinical_Trial_Profile__c();
        ctp = testData.ctp;
        Study_Site__c ss = new Study_Site__c();
        ss = testData.ss;
            
        
        try{
            TelevisitCreationScreenController.televisistPrerequisiteCheck(participantEnrollmentId[0]);
            ctp.Televisit_Vendor_is_Available__c = true;
            update ctp;
            TelevisitVendorSettings__c vendor = new TelevisitVendorSettings__c();
            vendor.Study_Site__c = ss.id;
            vendor.isEnable__c = true;
            insert vendor;
            TelevisitCreationScreenController.televisistPrerequisiteCheck(participantEnrollmentId[0]);
            TelevisitCreationScreenController.fetchTelevisitRecord('Scheduled',participantEnrollmentId[0]);
        }catch(Exception e){
        
        } 
    }
    
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('[{"session_id":"test"}]');
            res.setStatusCode(200);
            return res;
        }
    }
    static testMethod void service_call() {

        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();

        TestData testData = new TestData();
        List<String> participantEnrollmentId = new List<String>();
        participantEnrollmentId.add(testData.pe.Id);
        Clinical_Trial_Profile__c ctp = new Clinical_Trial_Profile__c();
        ctp = testData.ctp;
        Study_Site__c ss = new Study_Site__c();
        ss = testData.ss;
        Televisit__c tv = new Televisit__c();
        tv.Duration__c = '15 minutes';
        tv.Participant_Enrollment__c = participantEnrollmentId[0];
        tv.Status__c = 'Scheduled';
        tv.Visit_Date_Time__c = system.now();
        tv.Visit_End_Date_Time__c = system.now()+(15/1440);
        tv.Title__c = 'Test Televisit';
        tv.Meeting_URL__c = '123';
        tv.Visit_Date_Time__c = system.now();
        tv.Visit_End_Date_Time__c = system.now()+(15/1440);
        insert tv;
        Televisit__c tv1 = new Televisit__c();
        tv1.Duration__c = '15 minutes';
        tv1.Participant_Enrollment__c = participantEnrollmentId[0];
        tv1.Status__c = 'Completed';
        tv1.Meeting_URL__c = '123';
        tv1.Visit_Date_Time__c = system.now();
        tv1.Visit_End_Date_Time__c = system.now()+(15/1440);
        tv1.Title__c = 'Test Televisit1';
        insert tv1;
        List<Televisit_Attendee__c> taList = new List<Televisit_Attendee__c>();
        Televisit_Attendee__c ta = new Televisit_Attendee__c();
        ta.Firstname__c = 'test';
        ta.Lastname__c = 'test';
        ta.Attendee_Type__c = 'PI';
        ta.User__c = UserInfo.getUserId();
        ta.Televisit__c = tv.id;
        ta.Contact__c = testData.piDelegateContact.Id;
        taList.add(ta);
        Televisit_Attendee__c ta1 = new Televisit_Attendee__c();
        ta1.Firstname__c = 'test';
        ta1.Lastname__c = 'test';
        ta1.Attendee_Type__c = 'Participant';
        ta1.User__c = UserInfo.getUserId();
        ta1.Televisit__c = tv.id;
        ta1.Contact__c = testData.piContact.Id;
        taList.add(ta1); 
        insert taList;
        tv.Visit_Date_Time__c = system.now()+(15/1440);
        tv.Visit_End_Date_Time__c = system.now()+(30/1440);
        update tv;
        
        tv1.Visit_Date_Time__c = system.now()+(15/1440);
        tv1.Visit_End_Date_Time__c = system.now()+(30/1440);
        update tv1;
        
        tv1.Visit_Date_Time__c = system.now()-(15/1440);
        tv1.Visit_End_Date_Time__c = system.now()-(30/1440);
        update tv1;
        
        testData.createPatientDelegate();
        
        TelevisitCreationScreenController.fetchTelevisitRecord('Scheduled',participantEnrollmentId[0]);
        TelevisitCreationScreenController.fetchTelevisitRecord('Canceled/Completed',participantEnrollmentId[0]);
        TelevisitCreationScreenController.fetchAttendees(participantEnrollmentId[0]);
        TelevisitCreationScreenController.fetchParticipantDetails(participantEnrollmentId[0]);
        TelevisitCreationScreenController.cancelTelevisit(tv.id);
        TelevisitCreationScreenController.fetchSelectedAttendees(tv.id);
        
        String json='[{"id":"'+testData.piContact.Id+'"}]';
		String json1='[{"attendeeId":"'+taList[0].id+'"}]';
        
        TelevisitCreationScreenController.insertTelevisitRecord('{"title":"1111111","duration":"15 minutes","startTime":"02:15:00.000","visitDate":"2022-07-18"}');
        TelevisitCreationScreenController.updateAttendees(tv.id,json1,json);
        TelevisitCreationScreenController.addNewAttendees(tv.id,json);
        TelevisitTriggerHandler.createTelevisitEvent();
        TelevisitCreationScreenController.insertTelevisitRecord('{"attendeesList":'+json+',"id":"","title":"1111111","duration":"15 minutes","startTime":"02:15:00.000","visitDate":"2022-07-18"}');
        Test.StopTest();
	}
        
}