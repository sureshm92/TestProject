@isTest
public with sharing class Batch_UpdatetimestampsforexistingPERTest {
    @isTest
    public static void test(){
        Test.startTest();
        TestData.loadTestData();
        TestData testData = new TestData();
        Participant_Enrollment__c pe = new Participant_Enrollment__c();
        pe.id = testData.pe.Id;
        pe.Permit_Mail_Email_contact_for_this_study__c = true;
        pe.Permit_Voice_Text_contact_for_this_study__c = true;
        pe.Permit_SMS_Text_for_this_study__c = true;
        pe.Permit_IQVIA_to_contact_about_study__c = true;
        pe.Study_Email_Consent_Time__c = null;
        pe.Study_Phone_Consent_Time__c = null;
        pe.Study_SMS_Consent_Time__c = null;
        pe.Study_PI_Storage_Consent_Time__c = null;
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.StudyConsentTimestamps.class);
        update pe;
        Participant_Enrollment__c pe1 = [select Id,Participant__c from Participant_Enrollment__c limit 1];
        Participant__c part = new Participant__c();
        part.Id = pe1.Participant__c;
        part.Mailing_Country__c = 'United Kingdom';
        part.Mailing_Country_Code__c = 'GB';
        update part;
        List<String> perIds = new List<String>();
		List<String> perExcludeIds = new List<String>();
        Batch_UpdatetimestampsforexistingPER batch = new Batch_UpdatetimestampsforexistingPER(perIds,perExcludeIds);
        database.executeBatch(batch, 2000);
        Test.stopTest();
    }
    @isTest
    public static void test_ExcludeId(){
        Test.startTest();
        TestData.loadTestData();
        TestData testData = new TestData();
        Participant_Enrollment__c pe = new Participant_Enrollment__c();
        pe.id = testData.pe.Id;
        pe.Permit_Mail_Email_contact_for_this_study__c = true;
        pe.Permit_Voice_Text_contact_for_this_study__c = true;
        pe.Permit_SMS_Text_for_this_study__c = true;
        pe.Permit_IQVIA_to_contact_about_study__c = true;
        pe.Study_Email_Consent_Time__c = null;
        pe.Study_Phone_Consent_Time__c = null;
        pe.Study_SMS_Consent_Time__c = null;
        pe.Study_PI_Storage_Consent_Time__c = null;
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.StudyConsentTimestamps.class);
        update pe;
        Participant_Enrollment__c pe1 = [select Id,Participant__c from Participant_Enrollment__c limit 1];
        Participant__c part = new Participant__c();
        part.Id = pe1.Participant__c;
        part.Mailing_Country__c = 'United Kingdom';
        part.Mailing_Country_Code__c = 'GB';
        update part;
        List<String> perIds = new List<String>();
		List<String> perExcludeIds = new List<String>();
        perExcludeIds.add(pe.Id);
        Batch_UpdatetimestampsforexistingPER batch = new Batch_UpdatetimestampsforexistingPER(perIds,perExcludeIds);
        database.executeBatch(batch, 2000);
        Test.stopTest();
    }
    @isTest
    public static void test_Include(){
        Test.startTest();
        TestData.loadTestData();
        TestData testData = new TestData();
        Participant_Enrollment__c pe = new Participant_Enrollment__c();
        pe.id = testData.pe.Id;
        pe.Permit_Mail_Email_contact_for_this_study__c = true;
        pe.Permit_Voice_Text_contact_for_this_study__c = true;
        pe.Permit_SMS_Text_for_this_study__c = true;
        pe.Permit_IQVIA_to_contact_about_study__c = true;
        pe.Study_Email_Consent_Time__c = null;
        pe.Study_Phone_Consent_Time__c = null;
        pe.Study_SMS_Consent_Time__c = null;
        pe.Study_PI_Storage_Consent_Time__c = null;
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.StudyConsentTimestamps.class);
        update pe;
        Participant_Enrollment__c pe1 = [select Id,Participant__c from Participant_Enrollment__c limit 1];
        Participant__c part = new Participant__c();
        part.Id = pe1.Participant__c;
        part.Mailing_Country__c = 'United Kingdom';
        part.Mailing_Country_Code__c = 'GB';
        update part;
        List<String> perIds = new List<String>();
		List<String> perExcludeIds = new List<String>();
        perIds.add(pe.Id);
        Batch_UpdatetimestampsforexistingPER batch = new Batch_UpdatetimestampsforexistingPER(perIds,perExcludeIds);
        database.executeBatch(batch, 2000);
        Test.stopTest();
    }
    @isTest
    public static void test_MultiInputs(){
        Test.startTest();
        TestData.loadTestData();
        TestData testData = new TestData();
        Participant_Enrollment__c pe = new Participant_Enrollment__c();
        pe.id = testData.pe.Id;
        pe.Permit_Mail_Email_contact_for_this_study__c = true;
        pe.Permit_Voice_Text_contact_for_this_study__c = true;
        pe.Permit_SMS_Text_for_this_study__c = true;
        pe.Permit_IQVIA_to_contact_about_study__c = true;
        pe.Study_Email_Consent_Time__c = null;
        pe.Study_Phone_Consent_Time__c = null;
        pe.Study_SMS_Consent_Time__c = null;
        pe.Study_PI_Storage_Consent_Time__c = null;
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.StudyConsentTimestamps.class);
        update pe;
        List<Participant_Enrollment__c> peList = [select Id,Participant__c from Participant_Enrollment__c limit 2];
        Participant__c part = new Participant__c();
        part.Id = peList[0].Participant__c;
        part.Mailing_Country__c = 'United Kingdom';
        part.Mailing_Country_Code__c = 'GB';
        update part;
        List<String> perIds = new List<String>();
		List<String> perExcludeIds = new List<String>();
        perIds.add(peList[0].Id);
        perExcludeIds.add(peList[1].Id);
        Batch_UpdatetimestampsforexistingPER batch = new Batch_UpdatetimestampsforexistingPER(perIds,perExcludeIds);
        database.executeBatch(batch, 2000);
        Test.stopTest();
    }
    
    
    
}