/**
 * Created by Leonid Bartenev
 */

@IsTest
private class Test_IntegrationPatientReferralHandler {
    
    @IsTest
    static void testAll() {
    
        List<Account> accounts = new List<Account>();
        Account participantsAccount = new Account(
                Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
        );
        accounts.add(participantsAccount);
        Account piAccount = new Account(
                Name = 'PI Account'
        );
        accounts.add(piAccount);
        Account studySiteAccount = new Account(
                Name = 'Study Site Account',
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
        insert contacts;
        
        Clinical_Trial_Profile__c study = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'CTP1',
                Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = 'NCT99999999',
                Link_to_Pre_screening__c = 'some link',
                Study_Title__c = 'Some Title',
                Study_Code_Name__c = 'Some Code Name',
                Suppress_Participant_Emails__c = false,
                Participating_in_Digital_Recruitment__c = 'YES',
                Participating_in_Rocket_Referral__c = 'YES',
                Participating_in_Patient_Portal__c = 'Yes',
                Shareback_Settings_On_Participant_Level__c = true,
                Shareback_Availability_Timing__c = 1,
                Visit_Data_Shareback__c = true,
                Synch_with_TMDH__c = true
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
                Name = 'Some Study Site1',
                Principal_Investigator__c = piContact.Id,
                Clinical_Trial_Profile__c = study.Id,
                Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
                Site__c = studySiteAccount.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false,
                Study_Site_Number__c = 'SS1',
                Study_Site_Key__c = '1111'
        );
        insert studySite;
        
        studySite.Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED;
    
        Participant__c participantWithBY = new Participant__c(
                First_Name__c = 'Max',
                Last_Name__c = 'James',
                Birth_Year__c = '1985',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'NY',
                Email__c = 'MaxJames@mail.com'
        );
        insert participantWithBY;
        
        Contact exitedContact = new Contact(
                FirstName = 'Leo',
                LastName = 'Win',
                Email = 'leo@mail.com',
                AccountId = participantsAccount.Id
        );
        insert exitedContact;
    
    
        Test.startTest();
        List<Integration_Patient_Referral__c> iprList = new List<Integration_Patient_Referral__c>();
        Integration_Patient_Referral__c ipr = new Integration_Patient_Referral__c(
                Address_Country__c = 'US',
                Address_State__c = 'New York',
                Address_ZipCode__c = '2152',
                birthYear__c = '2000',
                Data_Source__c = 'Autorecruitment',
                email__c = 'some@dssd.cre',
                firstName__c = 'Nezz',
                lastName__c = 'Weg',
                Language_Preference__c = 'en_US',
                phone__c = '31444244214',
                protocolId__c = 'CTP1',
                siteSelected__c = 'SS1',
                Referred_Date__c  = '2019-10-02T10:00:00-05:00',
                referralID__c = '1234343242',
                acceptedTermsAndConditions__c = '2019-10-02T10:00:00-05:00'
        );
        Integration_Patient_Referral__c ipr2 = new Integration_Patient_Referral__c(
                Address_Country__c = 'US',
                Address_State__c = 'New York',
                Address_ZipCode__c = '34234',
                birthYear__c = '1985',
                Data_Source__c = 'Autorecruitment',
                email__c = 'MaxJames@mail.com',
                Middle_Initial__c = 'S',
                firstName__c = 'Max',
                lastName__c = 'Weg',
                Language_Preference__c = 'en_US',
                phone__c = '13245215333',
                protocolId__c = 'CTP1',
                siteSelected__c = 'SS1',
                Referred_Date__c  = '2019-10-02T10:00:00-05:00',
                referralID__c = '1232141212',
                acceptedTermsAndConditions__c = '2019-10-02T10:00:00-05:00'
        );
        Integration_Patient_Referral__c ipr3 = new Integration_Patient_Referral__c(
                Address_Country__c = 'US',
                Address_State__c = 'New York',
                Address_ZipCode__c = '12312',
                birthYear__c = '1985',
                Data_Source__c = 'Autorecruitment',
                email__c = 'leo@mail.com',
                firstName__c = 'Leo',
                lastName__c = 'Wide',
                Language_Preference__c = 'en_US',
                phone__c = '321234243',
                protocolId__c = 'CTP1',
                siteSelected__c = 'SS1',
                Referred_Date__c  = '2019-10-02T10:00:00-05:00',
                referralID__c = '444323423',
                acceptedTermsAndConditions__c = '2019-10-02T10:00:00-05:00'
        );

        iprList.add(ipr);
        iprList.add(ipr2);
        iprList.add(ipr3);
        insert iprList;
        
        insert new Integration_Patient_Referral__c(
                Address_Country__c = 'US',
                Address_State__c = 'New York',
                Address_ZipCode__c = '12312',
                birthYear__c = '1985',
                Data_Source__c = '23AndMe',
                email__c = 'leo@mail.com',
                firstName__c = 'Leo',
                lastName__c = 'Wide',
                Language_Preference__c = 'en_US',
                phone__c = '321234243',
                protocolId__c = 'CTP1',
                siteSelected__c = 'SS1',
                Referred_Date__c  = '2019-10-02T10:00:00-05:00',
                referralID__c = '4443234231',
                acceptedTermsAndConditions__c = '2019-10-02T10:00:00-05:00'
        );
        
        test.stopTest();

        System.assert([SELECT Id, Middle_Name__c FROM Participant__c WHERE Email__c = 'maxjames@mail.com'].Middle_Name__c == 'S');
        System.assert([SELECT Id, Secondary_Source__c FROM Participant__c WHERE Email__c = 'some@dssd.cre'].Secondary_Source__c == 'Autorecruitment');
        System.assert([SELECT Id, Contact__c FROM Participant__c WHERE Email__c = 'leo@mail.com'].Contact__c == exitedContact.Id);
        
        String refSource = [SELECT Id, Secondary_Source__c FROM Participant__c WHERE Email__c = 'leo@mail.com'].Secondary_Source__c;
        System.assert(refSource.contains('Autorecruitment'));
        System.assert(refSource.contains('23AndMe'));
    }
    
}