@isTest
Public Class TeleVisitRemoteTest{
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        TestData.createTCAcceptance();
        Test.stopTest();
    }

    @isTest
    Public Static Void TeleVisitRemoteTestMethod1(){
    
        //TestData.loadTestData();
        TestData td = new TestData();
        String exceptionMessage;
        ParticipantService.ParticipantState participantState;
        ParticipantService.ParticipantState ptState;
        Test.startTest();
        System.runAs(td.participantUser) {
            participantState = ParticipantService.getParticipantState();
            ptState = ParticipantService.getInstance().getState();
        }
        try {
            ParticipantService.getParticipantFullName(getPE(null).Participant__r.Contact__c);
        } catch (ParticipantService.ParticipantServiceException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(ParticipantService.ParticipantStates.REFERRAL, participantState.value);
        System.assertEquals(ParticipantService.ParticipantStates.REFERRAL, ptState.value);
        System.assertEquals('This contact hasn\'t participant!', exceptionMessage);
        
        TeleVisitRemote.getVisits('Scheduled',true);
        TeleVisitRemote.getVisits('Scheduled',false);
        TeleVisitRemote.getVisits('Completed',true);
        //TeleVisitRemote.getVisits('Completed',false);
        TeleVisitRemote.getTeleVisits('Scheduled');
        TeleVisitRemote.getTeleVisits('Completed');

    }
    
    static Participant_Enrollment__c getPE(String partStatus) {
        if (partStatus == null)
            partStatus = PEStatusState.PE_STATUS_REFERRAL_DECLINED;

        Terms_And_Conditions__c tc = new Terms_And_Conditions__c(Active__c = false);  
        
        Clinical_Trial_Profile__c trial = new Clinical_Trial_Profile__c(
            Id = TestDataFactory.getFakeId(Clinical_Trial_Profile__c.getSObjectType()),
            Protocol_ID__c = 'Prot-333',
            NCT_Number__c = 'NCT02804789',
            Therapeutic_Area__r = new Therapeutic_Area__c(Name = 'Test Area'),
            Patient_Portal_Enabled__c = true,
            Terms_And_Conditions_ID__r = tc,
            Televisit_Vendor_is_Available__c = true,
            Visit_Plan__c = TestDataFactory.getFakeId(Visit_Plan__c.getSObjectType())
        );

        Contact patientContact = new Contact(
            FirstName = 'Richard',
            LastName = 'Wilson',
            Email = 'r.wilson@gmail.com',
            userCommunityMode__c = 'Participant'
        );

        Participant__c participant = new Participant__c(
            Id = TestDataFactory.getFakeId(Participant__c.getSObjectType()),
            First_Name__c = patientContact.FirstName,
            Contact__r = patientContact
        );
        
        Contact pi = new Contact(
            FirstName = 'Joseph',
            LastName = 'Davis PI And HCP',
            Email = 'jdavis@somemail.com'
        );

        Study_Site__c studySite = new Study_Site__c(
            Name = 'Test SS1',
            Clinical_Trial_Profile__c = trial.Id,
            Clinical_Trial_Profile__r = trial,
            Site__r = new Account(Name = 'Clinic'),
            Principal_Investigator__r = pi,
            Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
            Study_Site_Key__c = '12132123132313',
            Study_Site_Phone__c = '+1(232) 222-3434'
        );
        
        return new Participant_Enrollment__c(
            Participant_Status__c = partStatus,
            Participant__c = participant.Id,
            Participant__r = participant,
            Clinical_Trial_Profile__c = trial.Id,
            Clinical_Trial_Profile__r = trial,
            Study_Site__r = studySite,
            Study_Site__c = TestDataFactory.getFakeId(Study_Site__c.getSObjectType())
        );
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
    
    @isTest
    static void service_call() {

        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        
        List<Televisit__c> lstTV = new List<Televisit__c>();
        TestData testData = new TestData();
        
        List<String> participantEnrollmentId = new List<String>();
        participantEnrollmentId.add(testData.pe.Id);
        
        Clinical_Trial_Profile__c ctp = new Clinical_Trial_Profile__c();
        ctp = testData.ctp;
        ctp.Televisit_Vendor_is_Available__c = true;
        update ctp;
        
        
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
        
        Televisit_Attendee__c ta = new Televisit_Attendee__c();
        ta.Firstname__c = 'test';
        ta.Lastname__c = 'test';
        ta.Attendee_Type__c = 'PI';
        ta.User__c = UserInfo.getUserId();
        ta.Televisit__c = tv.id;
        ta.Contact__c = testData.piDelegateContact.Id;
        insert ta;  
        
        Televisit_Attendee__c ta1 = new Televisit_Attendee__c();
        ta1.Firstname__c = 'test';
        ta1.Lastname__c = 'test';
        ta1.Attendee_Type__c = 'Participant';
        ta1.User__c = UserInfo.getUserId();
        ta1.Televisit__c = tv.id;
        ta1.Contact__c = testData.piContact.Id;
        insert ta1;
        
        TelevisitVendorSettings__c vs = new TelevisitVendorSettings__c();
        vs.isEnable__c = true;
        vs.Study_Site__c = testData.pe.Study_Site__c; 
        insert vs;
      
        lstTV.add(tv);
        lstTV.add(tv1);
        
        List<Televisit__c> televisits = [select Duration__c,Participant_Enrollment__r.Study_Site__c,Status__c,
                                         Meeting_URL__c,Visit_Date_Time__c,Visit_End_Date_Time__c,Title__c,Visit_Date__c,Start_Time__c,
                                         (select Firstname__c,Lastname__c,Attendee_Type__c,User__c,Televisit__c,Contact__c from Televisit_Attendee__r )
                                         from Televisit__c ];
        TeleVisitRemote.generateVisitWrappers(televisits);
        Test.StopTest();
    }

}