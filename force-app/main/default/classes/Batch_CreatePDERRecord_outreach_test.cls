@isTest
public class Batch_CreatePDERRecord_outreach_test {
    
     @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    
    @istest
    public static void testBatch()
    {
         TestData testData = new TestData(); 
        Participant__c participant = testData.participant;
        Contact cnt = [SELECT Id FROM Contact WHERE LastName = :participant.Name LIMIT 1];
        Participant_Enrollment__c objPart = [SELECT ID,Clinical_Trial_Profile__c FROM Participant_Enrollment__c 
                                             WHERE Participant__c =:participant.id limit 1];
        update new Clinical_Trial_Profile__c(id=objPart.Clinical_Trial_Profile__c,IQVIA_Outreach__c = true);
        
        cnt.IQVIA_Artificial_Voice_Consent_Time__c = date.newInstance(2022, 12, 24);
        cnt.IQVIA_Assisted_Dialing_Consent_Time__c = date.newInstance(2023, 01, 24);
        cnt.IQVIA_Direct_Mail_Consent_Time__c = date.newInstance(2022, 12, 26);
        cnt.IQVIA_Email_Consent_Time__c = date.newInstance(2022, 12, 29);
        cnt.IQVIA_PI_Storage_Consent_Time__c = date.newInstance(2023, 02, 20);
        cnt.IQVIA_Phone_Consent_Time__c = date.newInstance(2022, 12, 24);
        cnt.IQVIA_Pre_recorded_Calls_Consent_Time__c = date.newInstance(2022, 12, 24);
         cnt.IQVIA_SMS_Consent_Time__c = date.newInstance(2022, 12, 24);
          TriggerHandlerExecutor.bypassHandler( ContactTriggerHandler.UpdateParticipantAndUserEmailsOnEmailChangeHandler.class);
         TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.createNotificationsHandler.class );
        
        TriggerHandlerExecutor.bypassHandler( ContactTriggerHandler.CreateUserForDelegateContactHandler.class);
         TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.SetShowTourDefaultHandler.class);
         TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.PopulateOverrideFields.class);
         TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.CreateUserForCCContactHandler.class);
         TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.UpdateParticipantDetailsHandler.class);
         TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.UpdatePhoneNumberContactsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.ParticipantConsentUpdate.class);
         TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.UpdateConsentTimeStamps.class);
        update cnt;
        Patient_Delegate__c ptDelegateRef = new Patient_Delegate__c();
        ptDelegateRef.Participant__c = participant.Id;
        ptDelegateRef.Contact__c = cnt.Id;
        insert ptDelegateRef;
        List<Patient_Delegate_Enrollment__c> objPDER = [SELECT id from Patient_Delegate_Enrollment__c where Patient_Delegate__c=:ptDelegateRef.id];
        system.assert(objPDER.isEmpty());
        Test.startTest();
        List<Id> lstPD = new list<Id> ();
        database.executeBatch(new Batch_CreatePDERRecord_IqviaOutReach(lstPD));  
        test.stopTest();
        list<Patient_Delegate_Enrollment__c> objPDERafterBatch = [SELECT id from Patient_Delegate_Enrollment__c where Patient_Delegate__c=:ptDelegateRef.id];
        system.assert(!objPDERafterBatch.isEmpty());
        
    }
     @istest
    public static void testBatchConstructor()
    {
         TestData testData = new TestData(); 
        Participant__c participant = testData.participant;
        Contact cnt = [SELECT Id FROM Contact WHERE LastName = :participant.Name LIMIT 1];
        Participant_Enrollment__c objPart = [SELECT ID,Clinical_Trial_Profile__c FROM Participant_Enrollment__c 
                                             WHERE Participant__c =:participant.id limit 1];
        update new Clinical_Trial_Profile__c(id=objPart.Clinical_Trial_Profile__c,IQVIA_Outreach__c = true);
        
        cnt.IQVIA_Artificial_Voice_Consent_Time__c = date.newInstance(2022, 12, 24);
        cnt.IQVIA_Assisted_Dialing_Consent_Time__c = date.newInstance(2023, 01, 24);
        cnt.IQVIA_Direct_Mail_Consent_Time__c = date.newInstance(2022, 12, 26);
        cnt.IQVIA_Email_Consent_Time__c = date.newInstance(2022, 12, 29);
        cnt.IQVIA_PI_Storage_Consent_Time__c = date.newInstance(2023, 02, 20);
        cnt.IQVIA_Phone_Consent_Time__c = date.newInstance(2022, 12, 24);
        cnt.IQVIA_Pre_recorded_Calls_Consent_Time__c = date.newInstance(2022, 12, 24);
         cnt.IQVIA_SMS_Consent_Time__c = date.newInstance(2022, 12, 24);
          TriggerHandlerExecutor.bypassHandler( ContactTriggerHandler.UpdateParticipantAndUserEmailsOnEmailChangeHandler.class);
         TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.createNotificationsHandler.class );
        
        TriggerHandlerExecutor.bypassHandler( ContactTriggerHandler.CreateUserForDelegateContactHandler.class);
         TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.SetShowTourDefaultHandler.class);
         TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.PopulateOverrideFields.class);
         TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.CreateUserForCCContactHandler.class);
         TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.UpdateParticipantDetailsHandler.class);
         TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.UpdatePhoneNumberContactsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.ParticipantConsentUpdate.class);
         TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.UpdateConsentTimeStamps.class);
        update cnt;
        Patient_Delegate__c ptDelegateRef = new Patient_Delegate__c();
        ptDelegateRef.Participant__c = participant.Id;
        ptDelegateRef.Contact__c = cnt.Id;
        insert ptDelegateRef;
        List<Patient_Delegate_Enrollment__c> objPDER = [SELECT id from Patient_Delegate_Enrollment__c where Patient_Delegate__c=:ptDelegateRef.id];
        system.assert(objPDER.isEmpty());
        Test.startTest();
        List<Id> lstPD = new list<Id> ();
        lstPD.add(ptDelegateRef.id);
        database.executeBatch(new Batch_CreatePDERRecord_IqviaOutReach(lstPD)); 
        test.stopTest();
        list<Patient_Delegate_Enrollment__c> objPDERafterBatch = [SELECT id from Patient_Delegate_Enrollment__c where Patient_Delegate__c=:ptDelegateRef.id];
        system.assert(!objPDERafterBatch.isEmpty());
        
    }

}