/**
 * Created by Denis Shpilevsky
 */
@IsTest
private class Test_IntegrationReferralTrigger {

	@TestSetup
	private static void testSetup(){
		List<Terms_And_Conditions__c> tcList = new List<Terms_And_Conditions__c>();
        Terms_And_Conditions__c portalTC = new Terms_And_Conditions__c(
                Active__c = true
        );
        tcList.add(portalTC);
    
        Terms_And_Conditions__c studyTC = new Terms_And_Conditions__c();
        tcList.add(studyTC);
        insert tcList;
    
        List<Account> accounts = new List<Account>();
        Account participantsAccount = new Account(
                Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
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
                BillingLongitude = -74.991509,
                BillingCountryCode = 'US'
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
                Protocol_ID__c = 'tt123456789',
                Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = 'NCT00000001',
                Link_to_Pre_screening__c = 'some link',
                Terms_And_Conditions_ID__c = studyTC.Id,
                Study_Title__c = 'Some Title',
                Study_Code_Name__c = 'Some Code Name',
                Suppress_Participant_Emails__c = false,
                Therapeutic_Area__c = area.Id,
                Synch_with_TMDH__c = true,
                Include_in_RP_trial_search__c = true,
                Patient_Portal_Enabled__c = true
        );
        insert study;
    
        List<PicklistEntry> pleList = Translation__c.Language__c.getDescribe().getPicklistValues();
        String langCode;
        for(PicklistEntry ple : pleList) {
            langCode = ple.getValue();
            if(TranslateHelper.isLanguageSupported(ple.getValue())) break;
        }
        
        Translation__c studyTranslation = new Translation__c(
                Language__c = langCode,
                Record_Id__c = study.Id,
                Field_Name__c = 'Study_Title__c',
                Value__c = 'Some translated value'

        );
        insert studyTranslation;
    
        Study_Site__c studySite = new Study_Site__c(
                Primary_Key_ePR__c = 'tt123456789_US_123',
                Principal_Investigator__c = piContact.Id,
                Clinical_Trial_Profile__c = study.Id,
                Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
                Site__c = studySiteAccount.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false,
                Study_Site_Number__c = '123'
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
        
	}
	
	@IsTest
	private static void testNewAndAdditionalParticipant() {
        Test.startTest();
        Study_Site__c studySite = [SELECT Id, Primary_Key_ePR__c FROM Study_Site__c];
        System.debug('>>> ' + studySite.Primary_Key_ePR__c);
        Integration_Patient_Referral__c testRecord = new Integration_Patient_Referral__c(
            firstName__c = 'FirstName',
            lastName__c = 'LastName',
            email__c = 'test@mail.com',
            phone__c = '12357890',
            protocolId__c = 'tt123456789',
            siteSelected__c = '123',
            Address_State__c = 'New York',
            referralID__c = '453453',
            Address_ZipCode__c = '34545',
            Address_Country__c = 'US',
            Language_Preference__c = 'en_US',
            Referred_Date__c = '2019-10-02T10:00:00-05:00',
            Data_Source__c = 'Company',
            acceptedTermsAndConditions__c = '2019-10-02T10:00:00-05:00'
        );
        insert testRecord;
        Test.stopTest();

        Integration_Patient_Referral__c testRecord2 = new Integration_Patient_Referral__c(
            firstName__c = 'FirstName',
            lastName__c = 'LastName',
            email__c = 'test@mail.com',
            phone__c = '123578910',
            protocolId__c = 'tt123456789',
            siteSelected__c = '123',
            Address_State__c = 'New York',
            referralID__c = '453453',
            Address_ZipCode__c = '34545', 
            Address_Country__c = 'US', 
            Language_Preference__c = 'en_US', 
            Referred_Date__c = '2019-10-02T10:00:00-05:00', 
            Data_Source__c = 'Company', 
            acceptedTermsAndConditions__c = '2019-10-02T10:00:00-05:00'
        );
        insert testRecord2;
        System.assertEquals([SELECT Id FROM Participant__c].size(), 1);
    }

    @IsTest
    private static void testIncorrectData() {
        Test.startTest();
        Integration_Patient_Referral__c testRecord = new Integration_Patient_Referral__c();
        try{
            insert testRecord;
        }catch(Exception e){}
        Test.stopTest();
        System.assertEquals([SELECT Id FROM Participant__c].size(), 0);
    }

    @IsTest
    private static void testNewAndAdditionalParticipantBirthData() {
        Test.startTest();
        Integration_Patient_Referral__c testRecord = new Integration_Patient_Referral__c(
            firstName__c = 'FirstName',
            lastName__c = 'LastName',
            email__c = 'test@mail.com',
            phone__c = '12357890',
            protocolId__c = 'tt123456789',
            siteSelected__c = '123',
            birthYear__c = '1982',
            Address_State__c = 'New York',
            referralID__c = '453453',
            Address_ZipCode__c = '34545', 
            Address_Country__c = 'US', 
            Language_Preference__c = 'en_US', 
            Referred_Date__c = '2019-10-02T10:00:00-05:00', 
            Data_Source__c = 'Company', 
            acceptedTermsAndConditions__c = '2019-10-02T10:00:00-05:00'
        );
        insert testRecord;
        Test.stopTest();

        Integration_Patient_Referral__c testRecord2 = new Integration_Patient_Referral__c(
            firstName__c = 'FirstName',
            lastName__c = 'LastName',
            email__c = 'test@mail.com',
            phone__c = '123578910',
            protocolId__c = 'tt123456789',
            siteSelected__c = '123',
            birthYear__c = '1982',
            Address_State__c = 'New York',
            referralID__c = '453453',
            Address_ZipCode__c = '34545', 
            Address_Country__c = 'US', 
            Language_Preference__c = 'en_US', 
            Referred_Date__c = '2019-10-02T10:00:00-05:00', 
            Data_Source__c = 'Company', 
            acceptedTermsAndConditions__c = '2019-10-02T10:00:00-05:00'
        );
        insert testRecord2;
        System.assertEquals([SELECT Id FROM Participant__c].size(), 1);
    }

    @IsTest
    private static void testDuplicateContact() {
        Test.startTest();
        List<Study_Site__c> sites = [SELECT Id, Primary_Key_ePR__c FROM Study_Site__c ];
        System.debug(sites);
        Integration_Patient_Referral__c testRecord = new Integration_Patient_Referral__c(
            firstName__c = 'PI',
            lastName__c = 'PI',
            birthYear__c = '2018',
            email__c = 'pi@emil.com',
            phone__c = '12357890',
            protocolId__c = 'tt123456789',
            siteSelected__c = '123',
            Address_State__c = 'New York',
            referralID__c = '453453',
            Address_ZipCode__c = '34545', 
            Address_Country__c = 'US', 
            Language_Preference__c = 'en_US', 
            Referred_Date__c = '2019-10-02T10:00:00-05:00', 
            Data_Source__c = 'Company', 
            acceptedTermsAndConditions__c = '2019-10-02T10:00:00-05:00'
        );
        insert testRecord;
        Test.stopTest();
        System.assertEquals([SELECT Id FROM Participant__c].size(), 1);
    }
}