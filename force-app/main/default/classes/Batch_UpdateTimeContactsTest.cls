@isTest
public with sharing class Batch_UpdateTimeContactsTest {
    @isTest
    public static void test(){
        Test.startTest();
        TestData.loadTestData();
        TestData testData = new TestData();
        contact con = [select Id from contact limit 1];
        con.IQVIA_Contact_info_storage_consent__c = true;
        con.Participant_Phone_Opt_In_Permit_Phone__c = true;
        con.Participant_Opt_In_Status_SMS__c = true;
        con.Participant_Opt_In_Status_Emails__c = true;
        con.IQVIA_Pre_recorded_Voice_Consent__c = true;
        con.IQVIA_Direct_Mail_Consent__c = true;
        con.IQVIA_Assisted_Dialing_Consent__c = true;
        con.IQVIA_Artificial_Voice_Consent__c = true;
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.UpdateParticipantAndUserEmailsOnEmailChangeHandler.class);
                TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.createNotificationsHandler.class);
                TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.CreateUserForDelegateContactHandler.class);
                TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.SetShowTourDefaultHandler.class);
                TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.PopulateOverrideFields.class);
                TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.CreateUserForCCContactHandler.class);
                TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.UpdateParticipantDetailsHandler.class);
                TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.UpdatePhoneNumberContactsHandler.class);
                TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.UpdateConsentTimeStamps.class);
                TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.ParticipantConsentUpdate.class);
                
        update con;
        Participant__c part = [select Id from Participant__c where contact__c !=null limit 1];
        part.Mailing_Country__c = 'United Kingdom';
        part.Mailing_Country_Code__c = 'GB';
        update part;
        Batch_UpdatetimestampsexistingContacts batch = new Batch_UpdatetimestampsexistingContacts();
        database.executeBatch(batch, 2000);
        Test.stopTest();
    }
    @isTest
    public static void test_ContactBatch(){
        Test.startTest();
        TestData.loadTestData();
        List<String> perIds = new List<String>();
		List<String> perExcludeIds = new List<String>();
        //perIds.add(peList[0].Id);
        //perExcludeIds.add(peList[1].Id);
        Batch_UpdatetimestampsexistingContacts batch = new Batch_UpdatetimestampsexistingContacts(perIds,perExcludeIds);
        database.executeBatch(batch, 2000);
        Test.stopTest();
    }
    
    @isTest
    public static void test_ContactBatch2(){
        Test.startTest();
        TestData.loadTestData();
        List<String> perIds = new List<String>();
		List<String> perExcludeIds = new List<String>();
        Contact con = [select Id,Participant_Phone_Opt_In_Permit_Phone__c from contact limit 1];
        con.Participant_Phone_Opt_In_Permit_Phone__c = true;
        con.IQVIA_Contact_info_storage_consent__c = true;
        con.Participant_Opt_In_Status_SMS__c = true;
        con.Participant_Opt_In_Status_Emails__c = true;
    	con.MailingCountry = 'United Kingdom';
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.updateConsentTimeStamps.class);
        update con;
        Batch_UpdatetimestampsexistingContacts batch = new Batch_UpdatetimestampsexistingContacts(perIds,perExcludeIds);
        database.executeBatch(batch, 2000);
        Test.stopTest();
    }
    @isTest
    public static void test_ContactBatch3(){
        Test.startTest();
        TestData.loadTestData();
        List<String> perIds = new List<String>();
		List<String> perExcludeIds = new List<String>();
        List<Contact> conLst = [select Id,Participant_Phone_Opt_In_Permit_Phone__c from contact limit 2];
        conLst[0].Participant_Phone_Opt_In_Permit_Phone__c = true;
        conLst[0].IQVIA_Contact_info_storage_consent__c = true;
        conLst[0].Participant_Opt_In_Status_SMS__c = true;
        conLst[0].Participant_Opt_In_Status_Emails__c = true;
    	conLst[0].MailingCountry = 'United Kingdom';
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.updateConsentTimeStamps.class);
        update conLst[0];
        perIds.add(conLst[0].Id);
        perExcludeIds.add(conLst[1].Id);
        Batch_UpdatetimestampsexistingContacts batch = new Batch_UpdatetimestampsexistingContacts(perIds,perExcludeIds);
        database.executeBatch(batch, 2000);
        Test.stopTest();
    }
    @isTest
    public static void test_ContactBatch4(){
        Test.startTest();
        TestData.loadTestData();
        List<String> perIds = new List<String>();
		List<String> perExcludeIds = new List<String>();
        List<Contact> conLst = [select Id,Participant_Phone_Opt_In_Permit_Phone__c from contact limit 2];
        conLst[0].Participant_Phone_Opt_In_Permit_Phone__c = true;
        conLst[0].Participant_Opt_In_Status_SMS__c = true;
        conLst[0].Participant_Opt_In_Status_Emails__c = true;
    	conLst[0].MailingCountry = 'United Kingdom';
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.updateConsentTimeStamps.class);
        update conLst[0];
        perIds.add(conLst[0].Id);
        Batch_UpdatetimestampsexistingContacts batch = new Batch_UpdatetimestampsexistingContacts(perIds,perExcludeIds);
        database.executeBatch(batch);
        Test.stopTest();
    }
    @isTest
    public static void test_ContactBatch5(){
        Test.startTest();
        TestData.loadTestData();
        List<String> perIds = new List<String>();
		List<String> perExcludeIds = new List<String>();
        List<Contact> conLst = [select Id,Participant_Phone_Opt_In_Permit_Phone__c from contact limit 2];
        conLst[0].Participant_Phone_Opt_In_Permit_Phone__c = true;
        conLst[0].Participant_Opt_In_Status_SMS__c = true;
        conLst[0].Participant_Opt_In_Status_Emails__c = true;
    	conLst[0].MailingCountry = 'United Kingdom';
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.updateConsentTimeStamps.class);
        update conLst[0];
        perExcludeIds.add(conLst[0].Id);
        Batch_UpdatetimestampsexistingContacts batch = new Batch_UpdatetimestampsexistingContacts(perIds,perExcludeIds);
        database.executeBatch(batch);
        Test.stopTest();
    }
    @isTest
    public static void test_ContactBatch6(){
        Test.startTest();
        TestData.loadTestData();
        List<String> perIds = new List<String>();
		List<String> perExcludeIds = new List<String>();
        Contact con1 = [select Id from contact limit 1];
        Participant__c participant = new Participant__c();
        participant.Email__c = 'Test011@mail.ru';
        participant.First_Name__c = 'testName1';
        participant.Last_Name__c = 'testLastName1';
        participant.Date_of_Birth__c = '2000-04-18';
        participant.Contact__c = con1.Id;
        insert participant;
        //Participant__c participant = [select Id,Mailing_Country_Code__c,Mailing_Country__c,Contact__c from Participant__c  where Contact__c  !=null and Mailing_Country__c!=null limit 1];
        Contact con = [select Id,Participant_Phone_Opt_In_Permit_Phone__c from contact where Id=:participant.Contact__c limit 1];
        con.Participant_Phone_Opt_In_Permit_Phone__c = true;
        con.Participant_Opt_In_Status_SMS__c = true;
        con.Participant_Opt_In_Status_Emails__c = true;
    	con.MailingCountry = 'United Kingdom';
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.updateConsentTimeStamps.class);
        update con;
        perIds.add(con.Id);
        
        Batch_UpdatetimestampsexistingContacts batch = new Batch_UpdatetimestampsexistingContacts(perIds,perExcludeIds);
        database.executeBatch(batch);
        Test.stopTest();
    }
}