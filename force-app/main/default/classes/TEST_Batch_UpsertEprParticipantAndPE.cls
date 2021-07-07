/**
* Created by Digvijay
*/
@IsTest
public class TEST_Batch_UpsertEprParticipantAndPE {
    
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
        
        integer i =1;
        string randomStr = 'IPRUser'+i; 
        Integration_Patient_Referral__c ipr = new Integration_Patient_Referral__c();
        
        ipr.Batch_consideration__c                = 'Not completed';
        ipr.Address_Country__c                    = 'US';
        ipr.Address_State__c                      = 'New York';
        ipr.Address_ZipCode__c                    = '10001';
        ipr.BirthDate__c                          = '1987-03-01';
        ipr.birthYear__c                          = '1987';
        ipr.Data_Source__c                        = 'ePR';
        ipr.Delegate_Daytime_Phone_Number__c      = (system.now().millisecond()+''+system.now().month()+i+''+system.now().hour()+''+system.now().minute()+''+system.now().day()).substring(0,7);
        ipr.Delegate_Email_Address__c             = randomStr+'@dltestm.com';
        ipr.Delegate_First_Name__c                = 'dfn'+randomStr;
        ipr.Delegate_Last_Name__c                 = 'dln'+randomStr;
        ipr.Delegate_Mailing_State__c             = 'New York';
        ipr.Delegate_Zip_Postal_Code__c           = '10001';
        ipr.email__c                              = '04ipremail@gmtesstail.com';
        ipr.firstName__c                          = 'fn'+randomStr;
        ipr.Language_Preference__c                = 'en_US';
        ipr.lastName__c                           = 'ln'+randomStr;
        ipr.phone__c                              = '8343212';
        ipr.protocolId__c                         = 'tt123456789';
        ipr.referralID__c                         = 'rid-'+randomStr;
        ipr.sex__c                                = 'Male';
        ipr.siteSelected__c                       = '123';
        ipr.acceptedTermsAndConditions__c	      = '2020-01-01 10:52:39 AM';
        ipr.Referred_Date__c                      = '2020-01-01 10:52:39 AM';
        INSERT ipr;
        Test.startTest();
        Database.executeBatch(new Batch_UpsertEprParticipantAndPE(), 50);      
        test.stopTest();
        //Valid IPR
        Integration_Patient_Referral__c iprprocessed = [SELECT Id, Error_Message__c, Participant_Enrollment__c FROM Integration_Patient_Referral__c where id=:ipr.id];
        system.assert(iprprocessed.Error_Message__c == null);//No errors is processring ipr records
        system.assert(iprprocessed.Participant_Enrollment__c != null);//participant enrollment record created
    
    }
}