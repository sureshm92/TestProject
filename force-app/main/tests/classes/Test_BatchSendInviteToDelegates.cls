@isTest
Public Class Test_BatchSendInviteToDelegates{
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        TestData.createTCAcceptance();
        Test.stopTest();
    }
    @isTest
    Public Static Void Test_BatchSendInviteToDelegatesMethod(){
        TestData testData = new TestData();
        List<Id> delegateIds = new List<Id>();
        delegateIds.add(testData.participant.Id);
        Clinical_Trial_Profile__c ctpRecord = new Clinical_Trial_Profile__c();
        ctpRecord.Id = testData.ctp.Id;
        ctpRecord.CommunityTemplate__c = 'Janssen';
        update ctpRecord;
        Test.startTest();
            BatchSendInviteToDelegates bc = new BatchSendInviteToDelegates(delegateIds,ctpRecord);
            Id jobid = Database.executeBatch(bc,5);
        Test.stopTest();
    }
    @isTest
    Public Static Void Test_BatchSendInviteToDelegatesMethod1(){
        TestData testData = new TestData();
        Contact delegatecontact = new Contact(
            FirstName = 'Joy',
            LastName = 'JoyDad',
            Email = 'Joypatient@somemail.com',
            AccountId = testData.participant.Contact__r.AccountId,
            Current_Participant_Enrollment__c = testData.pe.Id,
            userCommunityMode__c = CommunityService.USER_MODE_PI,
            userCommunytyType__c = CommunityService.USER_MODE_PI,
            UserCommunityIsDelegate__c = true
        );
        insert delegatecontact;
        Participant__c p = new Participant__c(
            First_Name__c = 'Joy',
            Last_Name__c = 'JoyDad',
            Email__c = 'Joypatient@somemail.com',
            Contact__c = delegatecontact.Id
        );
        insert p;

        Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = delegatecontact.Id,
            Contact__r = delegatecontact,
            Participant__c = p.Id,
            Participant__r = p
        );
        insert patientDelegate;
        User PatientUser = CommunityService.createUser(delegatecontact, null, null, null);
        List<Id> delegateIds = new List<Id>();
        delegateIds.add(p.Id);
        Clinical_Trial_Profile__c ctpRecord = new Clinical_Trial_Profile__c();
        ctpRecord.Id = testData.ctp.Id;
        ctpRecord.CommunityTemplate__c = 'GSK';
        update ctpRecord;
        Test.startTest();
            BatchSendInviteToDelegates bc = new BatchSendInviteToDelegates(delegateIds,ctpRecord);
            Id jobid = Database.executeBatch(bc,5);
        Test.stopTest();
    }
}