/**
 * Created by Olga Skrynnikova on 12/10/2019.
 */

@IsTest
private class Test_NotificationService {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        TestData.createTCAcceptance();
        Test.stopTest();
    }    
    @IsTest
    static void getTopicListOrCreateNewTest() {
        //        List<Account> accounts = new List<Account>();
        //        Account participantsAccount = new Account(
        //                Name = 'Participant'
        //        );
        //        accounts.add(participantsAccount);
        //        Account piAccount = new Account(
        //                Name = 'PI Account'
        //        );
        //        accounts.add(piAccount);
        //        Account studySiteAccount = new Account(
        //                Name = 'Study Site Account',
        //                BillingCountryCode = 'US'
        //        );
        //        accounts.add(studySiteAccount);
        //        insert accounts;
        //
        //        List<Contact> contacts = new List<Contact>();
        //        Contact piContact = new Contact(
        //                FirstName = 'PI',
        //                LastName = 'PI',
        //                Email = 'pi@emil.com',
        //                AccountId = piAccount.Id
        //        );
        //        contacts.add(piContact);
        //        insert contacts;
        ////        Therapeutic_Area__c tp = new Therapeutic_Area__c(Name = 'Immunology');
        ////        insert tp;
        //        Clinical_Trial_Profile__c ctp = new Clinical_Trial_Profile__c(
        //                Protocol_ID__c = 'CTP1',
        //                Override_Recruitment_Status__c = 'Actively Enrolling',
        //                NCT_Number__c = 'NCT99999999',
        //                Link_to_Pre_screening__c = 'some link',
        //                Study_Title__c = 'Some Title',
        //                Study_Code_Name__c = 'Some Code Name',
        //                Suppress_Participant_Emails__c = false,
        //                Participating_in_Digital_Recruitment__c = 'YES',
        //                Participating_in_Rocket_Referral__c = 'YES',
        //                Participating_in_Patient_Portal__c = 'Yes',
        //                Shareback_Settings_On_Participant_Level__c = true,
        //                Shareback_Availability_Timing__c = 1,
        //                Visit_Data_Shareback__c = true,
        //                Synch_with_TMDH__c = true,
        //                Logged_Out_Days_Notification__c = 12
        //        );
        //        Test.startTest();
        //        try {
        //            insert ctp;
        //        } catch (DmlException e) {
        //            System.debug('WRONG <<<< ' + e.getMessage());
        //        }
        //        Test.stopTest();
    }
    
    @IsTest
    static void test_checkHCPNotificationType() {
        TestData testData = new TestData();
        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_REFERRAL_ACCEPTED;
        NotificationService.checkHCPNotificationType(testData.pe, false);
        
        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_REFERRAL_DECLINED;
        NotificationService.checkHCPNotificationType(testData.pe, false);
        
        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_REFERRAL_ON_HOLD;
        NotificationService.checkHCPNotificationType(testData.pe, false);
    }

    @IsTest
    static void test_checkPatientNotificationType() {
        TestData testData = new TestData();
        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_REFERRAL_ACCEPTED;
        NotificationService.checkPatientNotificationType(testData.pe, false);
        
        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_REFERRAL_DECLINED;
        NotificationService.checkPatientNotificationType(testData.pe, false);
        
        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_REFERRAL_ON_HOLD;
        NotificationService.checkPatientNotificationType(testData.pe, false);
    }

    @IsTest
    static void test_checkPatientNotificationVTType() {
        TestData testData = new TestData();
		Participant_Enrollment__c pe = [SELECT Id,Participant_Status__c,Referral_Source__c,
                                        Clinical_Trial_Profile__r.Patient_Portal_Enabled__c 
                                        FROM Participant_Enrollment__c WHERE Id =:testData.pe.Id];
        pe.Referral_Source__c = 'HCP';
        
        pe.Participant_Status__c = PEStatusState.PE_STATUS_REFERRAL_ACCEPTED;
        NotificationService.checkPatientNotificationVTType(pe);
        
        pe.Participant_Status__c = PEStatusState.PE_STATUS_REFERRAL_DECLINED;
        NotificationService.checkPatientNotificationVTType(pe);
        
        pe.Participant_Status__c = PEStatusState.PE_STATUS_REFERRAL_ON_HOLD;
        NotificationService.checkPatientNotificationVTType(pe);

        pe.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = true;
        pe.Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS;
        NotificationService.checkPatientNotificationVTType(pe);        
    }
    
}