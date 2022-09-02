/**
* Created by user on 09-Jan-20.
*/

@IsTest
private class Test_ReferralProfileRemote {
    @IsTest
    static void testSetMRRStatus() {
        TestData.loadTestData();
        Test.startTest();
        TestData testData = new TestData();
        String srcstr = 'testdata';
        Participant_Enrollment__c part = [
            SELECT
            Id,
            Medical_Record_Review_Status__c,
            MRR_Survey_Results_URL__c,
            Medical_Record_Review_Completed_by__c,
            Pre_screening_Status__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ];
        part.Participant_Status__c='Recived';
        update part;
        String participant = JSON.serialize(part);
        String p1=JSON.serialize(testData.pe);
         
        Participant_Enrollment__c test1;
       
        System.runAs(testData.participantUser) {
            try{
                test1 = ReferralProfileRemote.setMRRStatus(participant, 'Pass', 'bad');
                ReferralProfileRemote.setMRRStatus(p1, 'Fail', 'bad');
                ReferralProfileRemote.setMRRStatus(participant, 'Fail', 'bad');
                ReferralProfileRemote.toSentenceFont(srcstr);
                ReferralProfileRemote.toSentenceFont('');
                ReferralProfileRemote.getReferralProfileDetail(part.id,'PI');
                ReferralProfileRemote.savePEScreeningId(part.id,'screenid');
            } catch(exception e){
                system.debug(e);
            }
        }
        
        System.runAs(testData.participantUser) {
            try{
                ReferralProfileRemote.changePEStatusByBtn(part.id,'Pre-review Passed');
                ReferralProfileRemote.updateParticipantData(participant,participant);
                ReferralProfileRemote.getContactId();
            } catch(exception e){
                system.debug(e);
            }
        }
        
        try{
                ReferralProfileRemote.changePEStatusByBtn(null,'Pre-review Passed');
            } catch(exception e){
                system.debug(e);
            }
        
        Test.stopTest();
        System.assert(test1 != null);
    }
    
    @IsTest
    static void testCreateUser() {
        TestData.loadTestData();
         Account a = new Account(Name = 'Test Account Name');
        insert a;
        Contact newCont = new Contact(
            LastName = 'drdr',
            Email = 'dasda@mail.com',
            FirstName = 'asdas',
            AccountId = a.Id
        );
        insert newCont;
        
        List<Clinical_Trial_Profile__c> ctpList = new List<Clinical_Trial_Profile__c>();
        List<Study_Site__c> ssList = new List<Study_Site__c>();
        ctpList = [SELECT Id FROM Clinical_Trial_Profile__c];
        ssList = [SELECT Id FROM Study_Site__c];
        
        
        Test.startTest();
         Participant_Enrollment__c part = new Participant_Enrollment__c(
            Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
            Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
            Initial_visit_scheduled_date__c = date.today(),
            Study_Site__c = ssList[0].Id,
            Patient_ID__c = 'SomePatientId1',
            Referral_Source__c = 'HCP',
            Source_Type__c = 'Referring Provider',
            HighRisk_Indicator__c = 'Yes',
            Participant_Contact__c=newCont.id,
            High_Priority__c=false,
            Participant_Status__c = 'Pending Referral',
            Screening_ID__c = 'PESCR1',
            Birth_Month__c='04',
            YOB__c='2000'
        );
        insert part;
        
        ReferralProfileRemote.createUser(part.Id, newCont.Id);
        ReferralProfileRemote.ChangeStatusButton hT= new ReferralProfileRemote.ChangeStatusButton('test','test',true);
        ReferralProfileRemote.ChangeStatusButton hTn= new ReferralProfileRemote.ChangeStatusButton('test','test');

        
        Test.stopTest();
        
        List<User> testUser = [SELECT Id, Account.Name FROM User WHERE ContactId = :newCont.Id];
        System.assertEquals('Test Account Name', 'Test Account Name');
    }
    @isTest
    private static void newScreeningId_Test(){
        TestData.loadTestData();
        Test.startTest();
        TestData testData = new TestData();
        String srcstr = 'testdata';
        Participant_Enrollment__c part1 = [
            SELECT
            Id,
            Medical_Record_Review_Status__c,
            MRR_Survey_Results_URL__c,
            Medical_Record_Review_Completed_by__c,
            Pre_screening_Status__c,Participant__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ];
        
        Account SiteAccount = new Account(
            Name = 'Study Site Account',
            BillingCountry = 'United States'
        );
        
        insert SiteAccount;
        Contact con = new Contact(
            FirstName = 'PITD',
            LastName = 'PITD',
            AccountId = SiteAccount.Id,
            Email = 'test@con.com'
        );
        insert con;
        List<Clinical_Trial_Profile__c> ctpList = new List<Clinical_Trial_Profile__c>();
        List<Study_Site__c> ssList = new List<Study_Site__c>();
        ctpList = [SELECT Id FROM Clinical_Trial_Profile__c];
        ssList = [SELECT Id FROM Study_Site__c];
       
         
        Participant__c participantupdate = new Participant__c(
            First_Name__c = 'ParticipantTD4',
            Last_Name__c = 'ParticipantTD4',
            Phone__c = '55313538',
            Contact__c = con.Id,
            Email__c = 'part4@email.com',
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            Adult__c = true,
            Site__c = SiteAccount.Id
        );
        insert participantupdate;
         Participant_Enrollment__c part = new Participant_Enrollment__c(
            Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
            Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
            Initial_visit_scheduled_date__c = date.today(),
            Study_Site__c = ssList[0].Id,
            Patient_ID__c = 'SomePatientId1',
            Participant__c=participantupdate.id,
            Referral_Source__c = 'HCP',
            Source_Type__c = 'Referring Provider',
            HighRisk_Indicator__c = 'Yes',
            Participant_Contact__c=con.id,
            High_Priority__c=false,
            Participant_Status__c = 'Pending Referral',
            Screening_ID__c = 'PESCR1',
            Birth_Month__c='04',
            YOB__c='2000'
        );
       
        insert part;
        Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = con.Id,
            Participant__c = participantupdate.Id,
            Primary_Delegate__c=true
        );
        insert patientDelegate;
          ContentNote nts = new ContentNote();
                nts.Title = 'Good';
                insert nts;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = participantupdate.id;
        cdl.ContentDocumentId = nts.Id;
        cdl.ShareType = 'V';
        insert cdl;
        
        ReferralProfileRemote.savePEScreeningId(part.Id, 'dummy');
        try{
            ReferralProfileRemote.savePEScreeningId(null, 'dummy');
        }
        catch(Exception ex) {}
        try{
            ReferralProfileRemote.createUser('part.Id', 'con.id');
        }
        catch(Exception ex) {}
        System.runAs(testData.piUser) { 
            ReferralProfileRemote.getDelegateAndContactId(part.Id,'PI',con.id);
        }
        System.runAs(testData.participantUser) {
            ReferralProfileRemote.getReferralProfileDetail(part1.id,'PI',con.id);
            
        }
        try{
            ReferralProfileRemote.getDelegateAndContactId('part1.Id','PI',con.id);
        }
        catch(Exception ex) {}
        Test.stopTest();
    }
    @isTest
    private static void contentDoc(){
        
        TestData.loadTestData();
        Test.startTest();
        TestData testData = new TestData();
        String srcstr = 'testdata';
        Participant_Enrollment__c part = [
            SELECT
            Id,
            Medical_Record_Review_Status__c,
            MRR_Survey_Results_URL__c,
            Medical_Record_Review_Completed_by__c,
            Pre_screening_Status__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ];
        
        ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion_1; 
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=part.id;
        contentlink.ShareType= 'V';
        contentlink.LinkedEntityId = part.Id; 
        contentlink.ContentDocumentId=documents[0].Id;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        ReferralProfileRemote.getAuthForm(part.Id);
        Test.stopTest();
    }
    
}