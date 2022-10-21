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
}