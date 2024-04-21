@IsTest
public class Test_ResStudyTriggerHandler {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    
    @IsTest
    static void baseHCPTest() {
        List<Resource__c> resources = new List<Resource__c>();
        
        
        Clinical_Trial_Profile__c t1 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(
            Clinical_Trial_Profile__c.getSObjectType()
        );
        t1.NCT_Number__c = 'NCT00000000';
        t1.Protocol_ID__c = 'NCT00000000';
        t1.Study_Documents_Are_Available__c = true;
        
        Account piAccount = new Account(
            Name = 'PI Account'
        );
        insert piAccount;
        
        Contact piContact = new Contact(
            FirstName = 'PI',
            LastName = 'PI',
            Email = 'pi@emil.com',
            AccountId = piAccount.Id
        );
        
        Account studySiteAccount = new Account(
            Name = 'Study Site Account',
            BillingLatitude = 41.766594,
            BillingLongitude = -74.991509,
            BillingCountryCode = 'US'
        );
        insert studySiteAccount;
        
        Study_Site__c studySite = new Study_Site__c(
            Primary_Key_ePR__c = 'tt123456789_US_123',
            Principal_Investigator__c = piContact.Id,
            Clinical_Trial_Profile__c = t1.Id,
            Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
            Site__c = studySiteAccount.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false,
            Study_Site_Number__c = '123'
        );
        
        //t1.Status__c = 'Completed';
        Clinical_Trial_Profile__c t2 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(
            Clinical_Trial_Profile__c.getSObjectType()
        );
        t2.NCT_Number__c = 'NCT00000001';
        t2.Protocol_ID__c = 'NCT00000001';
        //t2.Status__c = 'Completed';
        Clinical_Trial_Profile__c t3 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(
            Clinical_Trial_Profile__c.getSObjectType()
        );
        t3.NCT_Number__c = 'NCT00000002';
        t3.Protocol_ID__c = 'NCT00000002';

        List<Clinical_Trial_Profile__c> profiles = new List<Clinical_Trial_Profile__c>();

        profiles.add(t1);
        profiles.add(t2);
        profiles.add(t3);
        insert profiles;
        Resource__c r1StudyDoc = (Resource__c) TestDataFactory.getSObject(
            Resource__c.getSObjectType()
        );
        r1StudyDoc.Title__c = 'testStudy';
        r1StudyDoc.Content_Class__c = 'Study-Specific';
        Resource__c r2StudyDoc = (Resource__c) TestDataFactory.getSObject(
            Resource__c.getSObjectType()
        );
        r2StudyDoc.Title__c = 'testStudy2';
        r2StudyDoc.Content_Class__c = 'Study-Specific';
        Resource__c r3 = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r3.Content_Class__c = 'Study-Specific';
        //r3.document_type__c = 'Certificate';
        
        
        Resource__c r4 = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r4.Content_Class__c = 'Study-Specific';
        
        Resource__c r5 = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r5.document_type__c = 'Certificate';
        
        r1StudyDoc.RecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT
        ]
        .Id;
        r2StudyDoc.RecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT
        ]
        .Id;
        r5.RecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT
        ]
        .Id;
        resources.add(r1StudyDoc);
        resources.add(r2StudyDoc);
        resources.add(r3);
        resources.add(r4);
        resources.add(r5);
        insert resources;
        List<Res_study__c> resStudies = new List<Res_study__c>();
        test.startTest();
        Res_study__c resStudy = new Res_study__c();
        resStudy.Resource__c = r1StudyDoc.Id;
        resStudy.Clinical_Trial_Profile__c = t1.Id;

        Res_study__c resStudy1 = new Res_study__c();
        resStudy1.Resource__c = r2StudyDoc.Id;
        resStudy1.Clinical_Trial_Profile__c = t1.Id;
        resStudy1.Visible_To_Participant__c = TRUE;
        resStudy1.Notify_On_Availability__c = TRUE;

        Res_study__c resStudy2 = new Res_study__c();
        resStudy2.Clinical_Trial_Profile__c = t1.Id;
        resStudy2.Resource__c = r3.Id;

        Res_study__c resStudy3 = new Res_study__c();
        resStudy3.Resource__c = r4.Id;
        resStudy3.Clinical_Trial_Profile__c = t1.Id;

        Res_study__c resStudy4 = new Res_study__c();
        resStudy4.Resource__c = r2StudyDoc.Id;
        resStudy4.Clinical_Trial_Profile__c = t3.Id;

        Res_study__c resStudy5 = new Res_study__c();
        resStudy5.Resource__c = r4.Id;
        resStudy5.Clinical_Trial_Profile__c = t1.Id;
		resStudy5.Visible_To_PI__c = true;
        
        Res_study__c resStudy6 = new Res_study__c();
        resStudy6.Resource__c = r5.Id;
        resStudy6.Clinical_Trial_Profile__c = t1.Id;
		resStudy6.Visible_To_Participant__c = true;
        resStudy6.Notify_On_Availability__c = true;
        
        resStudies.add(resStudy);
        resStudies.add(resStudy1);
        resStudies.add(resStudy2);
        resStudies.add(resStudy3);
        resStudies.add(resStudy4);
        resStudies.add(resStudy5);
        resStudies.add(resStudy6);
        insert resStudies;
        test.stopTest();
        for(Res_study__c res: resStudies){
            res.Visible_To_PI__c = true;
        }
        update resStudies;
        delete resStudies;
    }
    
    @IsTest
    static void baseHCPTest2() {
        List<Resource__c> resources = new List<Resource__c>();

        Account piAccount = new Account(
            Name = 'PI Account'
        );
        insert piAccount;
        
        Contact piContact = new Contact(
            FirstName = 'PI',
            LastName = 'PI',
            Email = 'pi@emil.com',
            AccountId = piAccount.Id
        );
        insert piContact;
        
        Contact rpContact = new Contact(
            FirstName = 'RP',
            LastName = 'RP',
            Email = 'rp@emil.com.invalid',
            AccountId = piAccount.Id
        );
        insert rpContact;
        
        Account studySiteAccount = new Account(
            Name = 'Study Site Account',
            BillingLatitude = 41.766594,
            BillingLongitude = -74.991509,
            BillingCountryCode = 'US'
        );
        insert studySiteAccount;
        
        List<Clinical_Trial_Profile__c> profiles = new List<Clinical_Trial_Profile__c>();
		Clinical_Trial_Profile__c t1 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(
            Clinical_Trial_Profile__c.getSObjectType()
        );
        t1.NCT_Number__c = 'NCT00000000';
        t1.Protocol_ID__c = 'NCT00000000';
        t1.Study_Documents_Are_Available__c = true;
        
        profiles.add(t1);
        insert profiles;
        
         Study_Site__c studySite = new Study_Site__c(
            Primary_Key_ePR__c = 'tt123456789_US_123',
            Principal_Investigator__c = piContact.Id,
            Clinical_Trial_Profile__c = t1.Id,
            Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
            Site__c = studySiteAccount.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false,
            Study_Site_Number__c = '123'
        );
        insert studySite;
        
        Site_Staff__c siteStaffPi = new Site_Staff__c(
            Site_Contact__c = piContact.Id,
            Delegate_Level__c = DelegateService.DELEGATE_LEVEL_2,
            Study_Site__c = studySite.Id,
            is_Invited__c = true
        );
        insert siteStaffPi;
        
        Resource__c r1StudyDoc = (Resource__c) TestDataFactory.getSObject(
            Resource__c.getSObjectType()
        );
        r1StudyDoc.Title__c = 'testStudy';
        r1StudyDoc.Content_Class__c = 'Study-Specific';
        Resource__c r2StudyDoc = (Resource__c) TestDataFactory.getSObject(
            Resource__c.getSObjectType()
        );
        r2StudyDoc.Title__c = 'testStudy2';
        r2StudyDoc.Content_Class__c = 'Study-Specific';
        Resource__c r3 = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r3.Content_Class__c = 'Study-Specific';
        //r3.document_type__c = 'Certificate';
        
        
        Resource__c r4 = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r4.Content_Class__c = 'Study-Specific';
        r1StudyDoc.RecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT
        ]
        .Id;
        r2StudyDoc.RecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT
        ]
        .Id;
        resources.add(r1StudyDoc);
        resources.add(r2StudyDoc);
        resources.add(r3);
        resources.add(r4);
        insert resources;
        
        List<Res_study__c> resStudies = new List<Res_study__c>();
        test.startTest();
        

        Res_study__c resStudy1 = new Res_study__c();
        resStudy1.Resource__c = r3.Id;
        resStudy1.Clinical_Trial_Profile__c = t1.Id;
        resStudy1.Visible_To_Participant__c = TRUE;
        resStudy1.Notify_On_Availability__c = TRUE;
		resStudy1.Visible_To_PI__c = true;
      
       
        resStudies.add(resStudy1);
        insert resStudies;
        test.stopTest();
        for(Res_study__c res: resStudies){
            res.Visible_To_PI__c = true;
        }
        update resStudies;
        delete resStudies;
    }

}