@isTest
public with sharing class Batch_UpdatetimestampsforexistingPERTest {
    @isTest
    public static void test(){
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
        Participant_Enrollment__History[] ah =  [Select ParentId, Field, OldValue, NewValue from Participant_Enrollment__History where ParentId = :pe.Id limit 200];
        system.debug('++++++++'+ah.size());
        Batch_UpdatetimestampsforexistingPER batch = new Batch_UpdatetimestampsforexistingPER();
        database.executeBatch(batch, 200);
    }
}