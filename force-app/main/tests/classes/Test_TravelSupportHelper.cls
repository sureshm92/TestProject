/**
 * Created by dmytro.fedchyshyn on 17.09.2019.
 */

@IsTest
public with sharing class Test_TravelSupportHelper {

    @IsTest
    static void getVendors_test() {
        TravelSupportHelper helper = (TravelSupportHelper) ClassFactory.newInstance(TravelSupportHelper.class);

        createTravelSetting();

        Study_Site__c studySite = [SELECT Id FROM Study_Site__c];

        Test.startTest();
        List<TravelVendorSettings__c> vendorSettings =  helper.getVendors(studySite.Id);
        Test.stopTest();

        System.assertEquals(2, vendorSettings.size());
    }

    @IsTest
    static void getTravelVendorsByIds_test() {
        TravelSupportHelper helper = (TravelSupportHelper) ClassFactory.newInstance(TravelSupportHelper.class);

        createTravelSetting();

        List<TravelVendor__c> travelVendors = [SELECT Id FROM TravelVendor__c WHERE Name = 'Uber'];
        List<Id> vendorIds = new List<Id>();
        vendorIds.add(travelVendors[0].Id);

        Test.startTest();
        helper.getTravelVendorsByIds(vendorIds);
        Test.stopTest();
    }

    @IsTest
    static void deleteTravelSettings_test() {
        TravelSupportHelper helper = (TravelSupportHelper) ClassFactory.newInstance(TravelSupportHelper.class);

        createTravelSetting();

        Clinical_Trial_Profile__c clinicalTrialProfile = [SELECT Id FROM Clinical_Trial_Profile__c];
        List<TravelVendor__c> travelVendors = [SELECT Id FROM TravelVendor__c];
        Set<Id> vendors = new Set<Id>();
        vendors.add(travelVendors[0].Id);

        Test.startTest();
        helper.deleteTravelSettings(clinicalTrialProfile.Id, vendors);
        Test.stopTest();
    }

    private static void createTravelSetting() {
        TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);

        Terms_And_Conditions__c portalTC = new Terms_And_Conditions__c(
                Active__c = true
        );

        insert portalTC;

        List<Account> accounts = new List<Account>();
        Account participantsAccount = new Account(
                Name = 'Participant'
        );
        accounts.add(participantsAccount);

        Account piAccount = new Account(
                Name = 'PI Account'
        );
        accounts.add(piAccount);

        Account hcpAccount = new Account(
                Name = 'HCP Account'
        );
        accounts.add(hcpAccount);

        Account delegateAccount = new Account(
                Name = CommunityService.COMMUNITY_DELEGATE_ACCOUNT_NAME
        );
        accounts.add(delegateAccount);

        Account studySiteAccount = new Account(
                Name = 'Study Site Account',
                BillingLatitude = 41.766594,
                BillingLongitude = -74.991509
        );
        accounts.add(studySiteAccount);
        insert accounts;

        List<Contact> contacts = new List<Contact>();
        Contact piContact = new Contact(
                FirstName = 'PI',
                LastName = 'PI',
                Email = 'pi@emil.com',
                AccountId = piAccount.Id
        );
        contacts.add(piContact);

        Contact hcpContact = new Contact(
                FirstName = 'HCP',
                LastName = 'HCP',
                Email = 'hcp@emil.com',
                AccountId = hcpAccount.Id,
                MailingLatitude = 40.766594,
                MailingLongitude = -73.991509
        );
        contacts.add(hcpContact);
        insert contacts;

        Therapeutic_Area__c area = new Therapeutic_Area__c(Name = 'Test TA');
        insert area;

        Clinical_Trial_Profile__c study = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'CTP1',
                Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = 'NCT99999999',
                Link_to_Pre_screening__c = 'some link',
                Terms_And_Conditions_ID__c = portalTC.Id,
                Study_Title__c = 'Some Title',
                Study_Code_Name__c = 'Some Code Name',
                Suppress_Participant_Emails__c = false,
                Therapeutic_Area__c = area.Id,
                Synch_with_TMDH__c = true,
                Include_in_RP_trial_search__c = true,
                Patient_Portal_Enabled__c = true,
                Shareback_Settings_On_Participant_Level__c = true,
                Shareback_Availability_Timing__c = 1,
                Visit_Data_Shareback__c = true
        );
        insert study;

        List<PicklistEntry> pleList = Translation__c.Language__c.getDescribe().getPicklistValues();
        Translation__c studyTranslation = new Translation__c(
                Language__c = pleList[0].value,
                Record_Id__c = study.Id,
                Field_Name__c = 'Study_Title__c',
                Value__c = 'Some translated value'
        );
        insert studyTranslation;

        Study_Site__c studySite = new Study_Site__c(
                Principal_Investigator__c = piContact.Id,
                Clinical_Trial_Profile__c = study.Id,
                Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
                Site__c = studySiteAccount.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false,
                Study_Site_Number__c = 'SS1'
        );
        insert studySite;
        studySite.Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED;
        update studySite;

        HCP_Enrollment__c hcpEnrollment = new HCP_Enrollment__c(
                Study_Site__c = studySite.Id,
                HCP_Contact__c = hcpContact.Id,
                Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT
        );
        insert hcpEnrollment;
        hcpEnrollment.Status__c = HCPEnrollmentService.HCP_S_ACTIVATED;
        update hcpEnrollment;


        Participant__c participant = new Participant__c(
                First_Name__c = 'Participant',
                Last_Name__c = 'Participant',
                Phone__c = '55313535',
                Email__c = 'part1@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL'
        );
        insert participant;
        Participant_Enrollment__c pe = new Participant_Enrollment__c(
                HCP__c = hcpEnrollment.Id,
                Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
                Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
                PI_Contact__c = piContact.Id,
                Study_Site__c = studySite.Id,
                Patient_ID__c = 'SomePatientId1',
                Referral_Source__c = 'HCP',
                Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_REFERRAL_SENT_TO_PI,
                Participant__c = participant.Id,
                Screening_ID__c = 'PESCR1'
        );
        insert pe;

        Referral_Network__c referralNetwork = new Referral_Network__c(
                Name = 'Test Referral Network'
        );
        insert referralNetwork;

        Contact_Referral_Network__c contactReferralNetwork = new Contact_Referral_Network__c(
                ContactId__c = hcpContact.Id,
                ReferralNetworkId__c = referralNetwork.Id
        );
        insert contactReferralNetwork;

        Contact_Therapeutic_Area__c contactTherapeuticArea = new Contact_Therapeutic_Area__c(
                ContactId__c = hcpContact.Id,
                TherapeuticAreaId__c = area.Id
        );
        insert contactTherapeuticArea;

        User hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];

        Terms_And_Conditions_Acceptance__c tc_acceptance = new Terms_And_Conditions_Acceptance__c(
                User__c = hcpUser.Id,
                Terms_And_Conditions__c = portalTC.Id
        );
        insert tc_acceptance;

        List<TravelVendor__c> travelVendors = new List<TravelVendor__c>{
                new TravelVendor__c(Name = 'Uber', Link_Vendor__c = 'link 1'),
                new TravelVendor__c(Name = 'Uklon', Link_Vendor__c = 'link 2'),
                new TravelVendor__c(Name = 'Kiev Taxi', Link_Vendor__c = 'link 3'),
                new TravelVendor__c(Name = 'Uzbek', Link_Vendor__c = 'link 4')
        };
        insert travelVendors;

        List<TravelVendorSettings__c> travelVendorSettings = new List<TravelVendorSettings__c>{
                new TravelVendorSettings__c(Study_Site__c = studySite.Id, TravelVendor__c = travelVendors[0].Id, isEnable__c = true),
                new TravelVendorSettings__c(Study_Site__c = studySite.Id, TravelVendor__c = travelVendors[1].Id, isEnable__c = true),
                new TravelVendorSettings__c(Study_Site__c = studySite.Id, TravelVendor__c = travelVendors[2].Id, isEnable__c = false),
                new TravelVendorSettings__c(Study_Site__c = studySite.Id, TravelVendor__c = travelVendors[3].Id, isEnable__c = false)
        };
        insert travelVendorSettings;
    }
}