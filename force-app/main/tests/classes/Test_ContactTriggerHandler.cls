/*
Test Class for ContactTriggerHandler
*/
@IsTest
public class Test_ContactTriggerHandler {
    @isTest
    private static void test(){ 
        List<Contact> contactList = new List<Contact>();
         Map<Id, Contact> contactOldMap = new  Map<Id, Contact>();
        Contact partContact = new Contact(
            FirstName = 'PITD',
            LastName = 'PITD',
            Email = 'pi@emil.com',
            Language__c = 'en_US',
            MailingCountry = 'United States',
            Participant_Opt_In_Status_SMS__c=false,
            MailingCountryCode='US',
            Phone='123',
            UserCommunityIsDelegate__c=true,
            MobilePhone='1223',
            is_Invalid_number__c=false
        );
        contactList.add(partContact);
        insert partContact;
        Participant__c participant = new Participant__c(
            First_Name__c = 'ParticipantTD',
            Last_Name__c = 'ParticipantTD',
            Phone__c = '55313535',
            Email__c = 'pi@emil.com',
            Preferred_Language__c = 'en_US',
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            Mailing_Zip_Postal_Code__c = '2733',
            Adult__c = true,
            Contact__c = partContact.Id
        );
        insert participant;
        Test.startTest();
        partContact.MailingStateCode = null;
        partContact.MailingCountry='India';
        partContact.MailingCountryCode='IN';
        partContact.MailingState = null;
        partContact.MailingPostalCode = '3733';
        partContact.Language__c = 'ru';
        partContact.Participant_Opt_In_Status_SMS__c=true;
        partContact.MobilePhone='12223';
        partContact.is_Invalid_number__c=true;
        update partContact;

        
        
        contactOldMap.put(partContact.Id,partContact);
        Participant__c newValPart = [SELECT Id,Mailing_Zip_Postal_Code__c FROM Participant__c WHERE Id =:participant.Id];
        ContactTriggerHandler.updateParticipantAndUserEmailsOnEmailChange(contactList,contactOldMap);
        Test.stopTest();
        system.assertEquals(newValPart.Mailing_Zip_Postal_Code__c, partContact.MailingPostalCode);
        //system.assertNOtEquals(contactOldMap.Mailing_Zip_Postal_Code__c, partContact.MailingPostalCode);
    }
     @isTest
    private static void test1(){ 
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.createNotificationsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.UpdatePhoneNumberContactsHandler.class);
        List<Contact> contactList = new List<Contact>();
        Set<id> contactListSet = new Set<id>();
        Map<Id, Contact> contactOldMap = new  Map<Id, Contact>();
        Contact partContact = new Contact(
            FirstName = 'PITD',
            LastName = 'PITD',
            Email = 'pi@emil.com',
            Language__c = 'en_US',
            MailingCountry = 'United States',
            Participant_Opt_In_Status_SMS__c=true,
            Welcome_Message_Sent__c=false,
            Welcome_Message_Delivered__c=false,
            MobilePhone='1223',
            is_Invalid_number__c=false,
            userCommunityMode__c='CC',
            Participant_Phone_Opt_In_Permit_Phone__c=false,
            UserCommunityIsDelegate__c=true
        );
       
        
        insert partContact;

        
        CC_Staff__c cstaff = new CC_Staff__c(
            Contact__c = partContact.id,
            CC_Staff_Status__c = 'Invited'
        );
        insert cstaff;
       

        contactOldMap.put(partContact.Id,partContact);
        Contact pcon = new Contact(
            FirstName = 'PTest',
            LastName = 'PTest',
            Email = 'PTest@emil.com',
            Language__c = 'en_US',
            MailingCountry = 'United States'
           
        );
       insert pcon;

        
        contactListSet.add(partContact.id);

        Participant__c participant1 = new Participant__c(
            First_Name__c = 'ParticipantTDD',
            Last_Name__c = 'ParticipantTDD',
            Phone__c = '553135355',
            Email__c = 'piD@emil.com',
            Preferred_Language__c = 'en_US',
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            Mailing_Zip_Postal_Code__c = '2733',
            Adult__c = true,
            Contact__c = pcon.Id
           
        );
        insert participant1;

        Participant__c participant = new Participant__c(
            First_Name__c = 'ParticipantTD',
            Last_Name__c = 'ParticipantTD',
            Phone__c = '55313535',
            Email__c = 'pi@emil.com',
            Preferred_Language__c = 'en_US',
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            Mailing_Zip_Postal_Code__c = '2733',
            Adult__c = true,
            Contact__c = partContact.Id
           
        );
        insert participant;
 

        Participant__c p = new Participant__c(
            First_Name__c = 'Patient',
            Last_Name__c = 'Delegate',
            Email__c = 'delegate@somemail.com',
            Contact__c = pcon.Id
        );
        insert p;   

        Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = partContact.Id,
            Contact__r = partContact,
            Participant__c = participant.Id,
            Participant__r = participant,
            Participant_Delegate__c = p.Id,
            Participant_Delegate__r = p,
            Primary_Delegate__c = true,
            Status__c='Active'
        );
        
        insert patientDelegate;

        
        
        
        Test.startTest();
       
        partContact.MailingStateCode = null;
        partContact.MailingState = null;
        partContact.MailingPostalCode = '3733';
        partContact.Language__c = 'ru';
        partContact.MobilePhone='15223';
        partContact.is_Invalid_number__c=true;
        partContact.Participant_Phone_Opt_In_Permit_Phone__c=true;
        update partContact;

        contactList.add(partContact);
      
        Participant__c newValPart = [SELECT Id,Mailing_Zip_Postal_Code__c FROM Participant__c WHERE Id =:participant.Id];
	    ContactTriggerHandler.platformLevelNotifications(contactListSet,contactOldMap,contactList,'Mobile');
        ContactTriggerHandler.platformLevelNotifications(contactListSet,contactOldMap,contactList,'smsoptin');
        ContactTriggerHandler.updateParticipantConsent(contactList,contactOldMap);
        ContactTriggerHandler.updateParticipantConsent(contactList,null);
        ContactTriggerHandler.setShowTourDefault(contactList);
        ContactTriggerHandler.createUserForCCContact(contactList);
        //ContactTriggerHandler.createTaskToUpdatePhoneNumber(contactList,contactOldMap);
        //ContactTriggerHandler.retryWelcomeMsg(contactList,contactOldMap);
        //ContactTriggerHandler.createUserForDelegateContact(contactList);
        contactList[0].Participant_Phone_Opt_In_Permit_Phone__c = false;
        ContactTriggerHandler.updateParticipantConsent(contactList,null);
        pcon.Participant_Phone_Opt_In_Permit_Phone__c = true;
        contactOldMap.put(partContact.Id, pcon);
        ContactTriggerHandler.updateParticipantConsent(contactList,contactOldMap);
        contactList[0].Participant_Phone_Opt_In_Permit_Phone__c = true;
        contactOldMap.get(partContact.Id).Participant_Phone_Opt_In_Permit_Phone__c = false;
        ContactTriggerHandler.updateParticipantConsent(contactList,contactOldMap);
        
        Test.stopTest();
        system.assertEquals(newValPart.Mailing_Zip_Postal_Code__c, partContact.MailingPostalCode);
        //system.assertNOtEquals(contactOldMap.Mailing_Zip_Postal_Code__c, partContact.MailingPostalCode);
    }
    @isTest
    private static void test2(){ 
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateMissingStatuses.class);

        List<Contact> contactList = new List<Contact>();
         Map<Id, Contact> contactOldMap = new  Map<Id, Contact>();
        Contact partContact = new Contact(
            FirstName = 'PITD',
            LastName = 'PITD',
            Email = 'pi@emil.com',
            Language__c = 'en_US',
            MailingCountry = 'United States',
            Participant_Opt_In_Status_SMS__c=false,
            MailingCountryCode='US',
            Phone='123',
            UserCommunityIsDelegate__c=false,
            MobilePhone='1223',
            is_Invalid_number__c=false,
            IQVIA_Pre_recorded_Voice_Consent__c=true,
            IQVIA_Contact_info_storage_consent__c=true,
            Participant_Phone_Opt_In_Permit_Phone__c=true,
            Participant_Opt_In_Status_Emails__c=true,
            IQVIA_Direct_Mail_Consent__c=true,
            IQVIA_Assisted_Dialing_Consent__c=true,
            IQVIA_Artificial_Voice_Consent__c=true
        );
        contactList.add(partContact);
        insert partContact;

        Participant__c participant = new Participant__c(
            First_Name__c = 'ParticipantTD',
            Last_Name__c = 'ParticipantTD',
            Phone__c = '55313535',
            Email__c = 'pi@emil.com',
            Preferred_Language__c = 'en_US',
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            Mailing_Zip_Postal_Code__c = '2733',
            Adult__c = true,
            Contact__c = partContact.Id
        );
        insert participant;


        Contact pcon = new Contact(
            FirstName = 'PTest',
            LastName = 'PTest',
            Email = 'PTest@emil.com',
            Language__c = 'en_US',
            MailingCountry = 'United States'
           
        );
        contactList.add(pcon);
       insert pcon;


       

        Account  account_1 = new Account(Name = 'Community', BillingCountry = 'United States');
        insert account_1;

        Clinical_Trial_Profile__c clinical = new Clinical_Trial_Profile__c(
            Protocol_ID__c = 'tt123456790',
            Override_Recruitment_Status__c = 'Actively Enrolling',
            NCT_Number__c = 'NCT00000002',
            Link_to_Pre_screening__c = 'some link',
            Study_Title__c = 'Some Title',
            Study_Code_Name__c = 'Some Code Name',
            Suppress_Participant_Emails__c = false
        );
        insert clinical;

        Study_Site__c studySite = new Study_Site__c(
            Name = 'Test',
            Study_Site_Phone__c = '0000034445',
            Clinical_Trial_Profile__c = clinical.Id,
            Site__c = account_1.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false
        );
        insert studySite;
        Participant_Enrollment__c pe = new Participant_Enrollment__c(
            Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
            Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
            Initial_visit_scheduled_date__c = date.today(),
            Patient_ID__c = 'SomePatientId1',
            Referral_Source__c = 'HCP',
            Study_Site__c=studySite.id,
            Source_Type__c = 'Referring Provider',
            HighRisk_Indicator__c = 'Yes',
            Participant__c = participant.Id,
            Screening_ID__c = 'PESCR1',
            Comorbidities__c = 'Yes'
        );
        insert pe;

        
        Participant__c p = new Participant__c(
            First_Name__c = 'Patient',
            Last_Name__c = 'Delegate',
            Email__c = 'delegate@somemail.com',
            Contact__c = pcon.Id
        );
        insert p;  

        Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = partContact.Id,
            Contact__r = partContact,
            Participant__c = participant.Id,
            Participant__r = participant,
            Participant_Delegate__c = p.Id,
            Participant_Delegate__r = p,
            Primary_Delegate__c = true,
            Status__c='Active'
        );
        
        insert patientDelegate;

        ParticipantEnrollmentPatientDelJunction__c peJun = new ParticipantEnrollmentPatientDelJunction__c(
            Patient_Delegate_Contact__c=patientDelegate.Contact__c,
            Welcome_Message_Sent__c=false,
            Welcome_Message_Delivered__c=false,
            Participant_Enrollment__c=pe.id
        );
        insert peJun;
        

        Task t = new Task();
        t.WhoId = partContact.id;
        t.subject = TaskService.TASK_CODE_UPDATE_YOUR_PHONE_NUMBER;
        insert t;

        Test.startTest();
        partContact.MailingStateCode = 'MH';
        partContact.MailingCountry='India';
        partContact.MailingCountryCode='IN';
        partContact.MailingPostalCode = '3733';
        partContact.Language__c = 'ru';
        partContact.Participant_Opt_In_Status_SMS__c=true;
        partContact.MobilePhone='12223';
        partContact.is_Invalid_number__c=true;
        partContact.IQVIA_Pre_recorded_Voice_Consent__c=false;
        partContact.Participant_Phone_Opt_In_Permit_Phone__c=false;
        partContact.Participant_Opt_In_Status_Emails__c=false;
        partContact.IQVIA_Direct_Mail_Consent__c=false;
        partContact.IQVIA_Assisted_Dialing_Consent__c=false;
        partContact.IQVIA_Artificial_Voice_Consent__c=false;
        update partContact;

       
        
        
        
        contactOldMap.put(partContact.Id,partContact);
        Participant__c newValPart = [SELECT Id,Mailing_Zip_Postal_Code__c FROM Participant__c WHERE Id =:participant.Id];
        Test.stopTest();
        system.assertEquals(newValPart.Mailing_Zip_Postal_Code__c, partContact.MailingPostalCode);
        //system.assertNOtEquals(contactOldMap.Mailing_Zip_Postal_Code__c, partContact.MailingPostalCode);
    }
    @isTest
    private static void test3(){ 
        List<Contact> contactList = new List<Contact>();
         Map<Id, Contact> contactOldMap = new  Map<Id, Contact>();
        Contact partContact = new Contact(
            FirstName = 'PITD',
            LastName = 'PITD',
            Email = 'pi@emil.com',
            Language__c = 'en_US',
            MailingCountry = 'United States',
            Participant_Opt_In_Status_SMS__c=true,
            MailingCountryCode='US',
            Phone='123',
            UserCommunityIsDelegate__c=true,
            MobilePhone='1223',
            is_Invalid_number__c=false,
            Participant_Phone_Opt_In_Permit_Phone__c=false
        );
        contactList.add(partContact);
        insert partContact;
        Participant__c participant = new Participant__c(
            First_Name__c = 'ParticipantTD',
            Last_Name__c = 'ParticipantTD',
            Phone__c = '55313535',
            Email__c = 'pi@emil.com',
            Preferred_Language__c = 'en_US',
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            Mailing_Zip_Postal_Code__c = '2733',
            Adult__c = true,
            Contact__c = partContact.Id
        );
        insert participant;
        Test.startTest();
        partContact.MailingStateCode = null;
        partContact.MailingCountry='India';
        partContact.MailingCountryCode='IN';
        partContact.MailingState = null;
        partContact.MailingPostalCode = '3733';
        partContact.Language__c = 'ru';
        partContact.Participant_Opt_In_Status_SMS__c=false;
        partContact.Participant_Phone_Opt_In_Permit_Phone__c=true;
        partContact.MobilePhone='12223';
        partContact.is_Invalid_number__c=true;
        update partContact;

        
        
        contactOldMap.put(partContact.Id,partContact);
        Participant__c newValPart = [SELECT Id,Mailing_Zip_Postal_Code__c FROM Participant__c WHERE Id =:participant.Id];
        ContactTriggerHandler.updateParticipantConsent(contactList,null);
        Test.stopTest();
        system.assertEquals(newValPart.Mailing_Zip_Postal_Code__c, partContact.MailingPostalCode);
        //system.assertNOtEquals(contactOldMap.Mailing_Zip_Postal_Code__c, partContact.MailingPostalCode);
    }

    @isTest
    private static void test4(){ 

        List<Contact> contactList = new List<Contact>();
        Map<Id, Contact> contactOldMap = new  Map<Id, Contact>();
        Contact partContact = new Contact(
            FirstName = 'PITD',
            LastName = 'PITD',
            Email = 'pi@emil.com',
            Language__c = 'en_US',
            MailingCountry = 'United States',
            Participant_Opt_In_Status_SMS__c=true,
            MailingCountryCode='US',
            Phone='123',
            UserCommunityIsDelegate__c=true,
            MobilePhone='1223',
            is_Invalid_number__c=false,
            Participant_Phone_Opt_In_Permit_Phone__c=false
        );
        contactList.add(partContact);
        insert partContact;
        Participant__c participant = new Participant__c(
            First_Name__c = 'ParticipantTD',
            Last_Name__c = 'ParticipantTD',
            Phone__c = '55313535',
            Email__c = 'pi@emil.com',
            Preferred_Language__c = 'en_US',
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            Mailing_Zip_Postal_Code__c = '2733',
            Adult__c = true,
            Contact__c = partContact.Id
        );
        insert participant;
        Test.startTest();
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.createNotificationsHandler.class);
        partContact.is_Invalid_number__c=true;
        try {
            update partContact;
        } catch (Exception e) {
            System.debug('error');
        }
        Test.stopTest();
    }

    @isTest
    private static void test5(){ 
        List<Contact> contactList = new List<Contact>();
        Map<Id, Contact> contactOldMap = new  Map<Id, Contact>();
        Contact partContact = new Contact(
            FirstName = 'PITD',
            LastName = 'PITD',
            Email = 'pi@emil.com',
            Language__c = 'en_US',
            MailingCountry = 'United States',
            Participant_Opt_In_Status_SMS__c=true,
            MailingCountryCode='US',
            Phone='123',
            UserCommunityIsDelegate__c=true,
            MobilePhone='1223',
            is_Invalid_number__c=false,
            Participant_Phone_Opt_In_Permit_Phone__c=false
        );
        contactList.add(partContact);
        insert partContact;
        Participant__c participant = new Participant__c(
            First_Name__c = 'ParticipantTD',
            Last_Name__c = 'ParticipantTD',
            Phone__c = '55313535',
            Email__c = 'pi@emil.com',
            Preferred_Language__c = 'en_US',
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            Mailing_Zip_Postal_Code__c = '2733',
            Adult__c = true,
            Contact__c = partContact.Id
        );
        insert participant;

        Account  account_1 = new Account(Name = 'Community', BillingCountry = 'United States');
        insert account_1;

        Clinical_Trial_Profile__c clinical = new Clinical_Trial_Profile__c(
            Protocol_ID__c = 'tt123456790',
            Override_Recruitment_Status__c = 'Actively Enrolling',
            NCT_Number__c = 'NCT00000002',
            Link_to_Pre_screening__c = 'some link',
            Study_Title__c = 'Some Title',
            Study_Code_Name__c = 'Some Code Name',
            Suppress_Participant_Emails__c = false
        );
        insert clinical;

        Study_Site__c studySite = new Study_Site__c(
            Name = 'Test',
            Study_Site_Phone__c = '0000034445',
            Clinical_Trial_Profile__c = clinical.Id,
            Site__c = account_1.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false
        );
        insert studySite;
        Participant_Enrollment__c pe = new Participant_Enrollment__c(
            Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
            Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
            Initial_visit_scheduled_date__c = date.today(),
            Patient_ID__c = 'SomePatientId1',
            Referral_Source__c = 'HCP',
            Study_Site__c=studySite.id,
            Source_Type__c = 'Referring Provider',
            HighRisk_Indicator__c = 'Yes',
            Participant__c = participant.Id,
            Screening_ID__c = 'PESCR1',
            Comorbidities__c = 'Yes'
        );
        insert pe;

        Contact pcon = new Contact(
            FirstName = 'PTest',
            LastName = 'PTest',
            Email = 'PTest@emil.com',
            Language__c = 'en_US',
            MailingCountry = 'United States'
        );
        insert pcon;
        
        Participant__c p = new Participant__c(
            First_Name__c = 'Patient',
            Last_Name__c = 'Delegate',
            Email__c = 'delegate@somemail.com',
            Contact__c = pcon.Id
        );
        insert p;  

        Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = partContact.Id,
            Contact__r = partContact,
            Participant__c = participant.Id,
            Participant__r = participant,
            Participant_Delegate__c = p.Id,
            Participant_Delegate__r = p,
            Primary_Delegate__c = true,
            Status__c='Active'
        );
        
        insert patientDelegate;

        ParticipantEnrollmentPatientDelJunction__c peJun = new ParticipantEnrollmentPatientDelJunction__c(
            Patient_Delegate_Contact__c=patientDelegate.Contact__c,
            Welcome_Message_Sent__c=false,
            Welcome_Message_Delivered__c=false,
            Participant_Enrollment__c=pe.id
        );
        insert peJun;

        Test.startTest();
        partContact.MobilePhone='12223';
        partContact.is_Invalid_number__c=true;
        update partContact;
        try {
            insert new Contact(
                FirstName = 'PTest001',
                LastName = 'PTest001',
                Email = 'PTest001@emil.com',
                Language__c = 'en_US',
                MailingCountry = 'United States',
                primaryContact__c = partContact.Id
            );
        } catch(Exception ex){}
        Test.stopTest();
    }
}