/**
* Created by Digvijay
*/
@IsTest
public class TEST_Batch_UpsertEprParticipantAndPE {
    
    @TestSetup
    private static void testSetup(){
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
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
        
        Contact cont = new Contact(
            FirstName = 'fnTest1',
            LastName = 'lnTest1',
            Email = '04ipremail@gmtesstail.com',
            AccountId = hcpAccount.Id,
            MailingLatitude = 40.766594,
            MailingLongitude = -73.991509
        );
        contacts.add(cont);
        
        insert contacts;
        
        Therapeutic_Area__c area = new Therapeutic_Area__c(Name = 'Test TA');
        insert area;
        
        List<Clinical_Trial_Profile__c> ctpList = new List<Clinical_Trial_Profile__c>();
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
        ctpList.add(study);
        
        Clinical_Trial_Profile__c study1 = new Clinical_Trial_Profile__c(
            Protocol_ID__c = 'tt1234567810',
            Override_Recruitment_Status__c = 'Actively Enrolling',
            NCT_Number__c = 'NCT00000011',
            Link_to_Pre_screening__c = 'some link',
            Terms_And_Conditions_ID__c = studyTC.Id,
            Study_Title__c = 'Some Title Test',
            Study_Code_Name__c = 'Some Code Name Test',
            Suppress_Participant_Emails__c = false,
            Therapeutic_Area__c = area.Id,
            Synch_with_TMDH__c = true,
            Include_in_RP_trial_search__c = true,
            Patient_Portal_Enabled__c = true
        );
        ctpList.add(study1);
        
        Insert ctpList;
        //insert study;
        
        List<PicklistEntry> pleList = Translation__c.Language__c.getDescribe().getPicklistValues();
        String langCode;
        for(PicklistEntry ple : pleList) {
            langCode = ple.getValue();
            if(TranslateHelper.isLanguageSupported(ple.getValue())) break;
        }
        
        Translation__c studyTranslation = new Translation__c(
            Language__c = langCode,
            Record_Id__c = ctpList[0].Id,
            Field_Name__c = 'Study_Title__c',
            Value__c = 'Some translated value'
            
        );
        insert studyTranslation;
        
        List<Study_Site__c> ssList = new List<Study_Site__c>();
        Study_Site__c studySite = new Study_Site__c(
            Primary_Key_ePR__c = 'tt123456789_US_123',
            Principal_Investigator__c = piContact.Id,
            Clinical_Trial_Profile__c = ctpList[0].Id,
            Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
            Site__c = studySiteAccount.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false,
            Study_Site_Number__c = '123'
        );
        ssList.add(studySite);
            
          Study_Site__c studySite1 = new Study_Site__c(
            Primary_Key_ePR__c = 'tt1234567810_US_1231',
            Principal_Investigator__c = piContact.Id,
            Clinical_Trial_Profile__c = ctpList[1].Id,
            Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
            Site__c = studySiteAccount.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false,
            Study_Site_Number__c = '1231'
        );
        ssList.add(studySite1);
        insert ssList;
        //insert studySite;
        //studySite.Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED;
        ssList[0].Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED;
        ssList[1].Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED;
        update ssList;
        //update studySite;
        
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
        String test1 = 'Test';
        List<Integration_Patient_Referral__c> iprList = new List<Integration_Patient_Referral__c>();
        Integration_Patient_Referral__c ipr = new Integration_Patient_Referral__c();
        
        ipr.Batch_consideration__c                = 'Not completed';
        ipr.Address_Country__c                    = 'US';
        ipr.Address_State__c                      = 'New York';
        ipr.Address_ZipCode__c                    = '10001';
        ipr.BirthDate__c                          = '1987-03-01';
        ipr.birthYear__c                          = '1987';
        ipr.Data_Source__c                        = 'ePR';
        ipr.Delegate_Daytime_Phone_Number__c      = (system.now().millisecond()+''+system.now().month()+i+''+system.now().hour()+''+system.now().minute()+''+system.now().day()).substring(0,7);
        ipr.Delegate_Email_Address__c             = test1+'@dltestm.com';
        ipr.Delegate_First_Name__c                = 'dfn'+test1;
        ipr.Delegate_Last_Name__c                 = 'dln'+test1;
        ipr.Delegate_Mailing_State__c             = 'New York';
        ipr.Delegate_Zip_Postal_Code__c           = '10001';
        ipr.email__c                              = '04ipremail@gmtesstail.com';
        ipr.firstName__c                          = 'fn'+test1;
        ipr.Language_Preference__c                = 'en_US';
        ipr.lastName__c                           = 'ln'+test1;
        ipr.phone__c                              = '8343212';
        ipr.protocolId__c                         = 'tt123456789';
        ipr.referralID__c                         = 'rid-'+'1230011';
        ipr.sex__c                                = 'Male';
        ipr.siteSelected__c                       = '123';
        ipr.acceptedTermsAndConditions__c         = '2020-01-01 10:52:39 AM';
        ipr.Referred_Date__c                      = '2020-01-01 10:52:39 AM';
        
        iprList.add(ipr);
        
        //Inserting Duplicate Participant
        Integration_Patient_Referral__c ipr1 = new Integration_Patient_Referral__c();
        
        ipr1.Batch_consideration__c                = 'Not completed';
        ipr1.Address_Country__c                    = 'US';
        ipr1.Address_State__c                      = 'Alabama';
        ipr1.Address_ZipCode__c                    = '10001';
        ipr1.BirthDate__c                          = '1987-03-01';
        ipr1.birthYear__c                          = '1987';
        ipr1.Data_Source__c                        = 'ePR';
        ipr1.Delegate_Daytime_Phone_Number__c      = (system.now().millisecond()+''+system.now().month()+i+''+system.now().hour()+''+system.now().minute()+''+system.now().day()).substring(0,7);
        ipr1.Delegate_Email_Address__c             = 'pi@emil.com';
        ipr1.Delegate_First_Name__c                = 'PITD';
        ipr1.Delegate_Last_Name__c                 = 'PITD';
        ipr1.Delegate_Mailing_State__c             = 'New York';
        ipr1.Delegate_Zip_Postal_Code__c           = '10001';
        ipr1.email__c                              = 'part2@email.com';
        ipr1.firstName__c                          = 'ParticipantTD1';
        ipr1.Language_Preference__c                = 'en_US';
        ipr1.lastName__c                           = 'ParticipantTD1';
        ipr1.phone__c                              = '55313538';
        ipr1.protocolId__c                         = 'tt123456789';
        ipr1.referralID__c                         = 'rid-'+'123001';
        ipr1.sex__c                                = 'Male';
        ipr1.siteSelected__c                       = '123';
        ipr1.acceptedTermsAndConditions__c        = '2020-01-01 10:52:39 AM';
        ipr1.Referred_Date__c                      = '2020-01-01 10:52:39 AM';
        ipr1.Delegate_Alternative_Phone_Number__c      ='232423242';
        iprList.add(ipr1);
        
        Integration_Patient_Referral__c ipr2 = new Integration_Patient_Referral__c();
        
        ipr2.Batch_consideration__c                = 'Not completed';
        ipr2.Address_Country__c                    = 'US';
        ipr2.Address_State__c                      = 'Alabama';
        ipr2.Address_ZipCode__c                    = '10001';
        ipr2.BirthDate__c                          = '1987-03-01';
        ipr2.birthYear__c                          = '1987';
        ipr2.Data_Source__c                        = 'ePR';
        ipr2.Delegate_Daytime_Phone_Number__c      = (system.now().millisecond()+''+system.now().month()+i+''+system.now().hour()+''+system.now().minute()+''+system.now().day()).substring(0,7);
        ipr2.Delegate_Email_Address__c             = 'hcp@emil.com';
        ipr2.Delegate_First_Name__c                = 'HCPTD';
        ipr2.Delegate_Last_Name__c                 = 'HCPTD';
        ipr2.Delegate_Mailing_State__c             = 'New York';
        ipr2.Delegate_Zip_Postal_Code__c           = '10001';
        ipr2.email__c                              = 'part2@email.com';
        ipr2.firstName__c                          = 'ParticipantTD1';
        ipr2.Language_Preference__c                = 'en_US';
        ipr2.lastName__c                           = 'ParticipantTD1';
        ipr2.phone__c                              = '55313538';
        ipr2.protocolId__c                         = 'tt123456789';
        ipr2.referralID__c                         = 'rid-'+'123001';
        ipr2.sex__c                                = 'Male';
        ipr2.siteSelected__c                       = '123';
        ipr2.acceptedTermsAndConditions__c        = '2020-01-01 10:52:39 AM';
        ipr2.Referred_Date__c                      = '2020-01-01 10:52:39 AM';
        ipr2.Delegate_Phone_Number_Type__c            ='Mobile';
        ipr2.Delegate_Alternative_Phone_Number__c      ='232423242';
        iprList.add(ipr2);
        
        
        Integration_Patient_Referral__c ipr3 = new Integration_Patient_Referral__c();
        
        ipr3.Batch_consideration__c                = 'Not completed';
        ipr3.Address_Country__c                    = 'US';
        ipr3.Address_State__c                      = 'Alabama';
        ipr3.Address_ZipCode__c                    = '10001';
        ipr3.BirthDate__c                          = '1987-03-01';
        ipr3.birthYear__c                          = '1987';
        ipr3.Data_Source__c                        = 'ePR';
        ipr3.Delegate_Daytime_Phone_Number__c      = (system.now().millisecond()+''+system.now().month()+i+''+system.now().hour()+''+system.now().minute()+''+system.now().day()).substring(0,7);
        ipr3.Delegate_Email_Address__c             = 'pi_delegate@emil.com';
        ipr3.Delegate_First_Name__c                = 'PIDelTD';
        ipr3.Delegate_Last_Name__c                 = 'PIDelTD';
        ipr3.Delegate_Mailing_State__c             = 'New York';
        ipr3.Delegate_Zip_Postal_Code__c           = '10001';
        ipr3.email__c                              = 'part2@email.com';
        ipr3.firstName__c                          = 'ParticipantTD1';
        ipr3.Language_Preference__c                = 'en_US';
        ipr3.lastName__c                           = 'ParticipantTD1';
        ipr3.phone__c                              = '55313538';
        ipr3.protocolId__c                         = 'tt123456789';
        ipr3.referralID__c                         = 'rid-'+'123001';
        ipr3.sex__c                                = 'Male';
        ipr3.siteSelected__c                       = '123';
        ipr3.acceptedTermsAndConditions__c        = '2020-01-01 10:52:39 AM';
        ipr3.Referred_Date__c                      = '2020-01-01 10:52:39 AM';
        ipr3.Delegate_Phone_Number_Type__c            ='Home';
        ipr3.Delegate_Alternative_Phone_Number__c      ='232423242';
        iprList.add(ipr3);
            
        Insert iprList;
        List<Participant__c>  parLsit  = [Select id,Date_Of_Birth__c, Mailing_Zip_Postal_Code__c from participant__c where Email__c='part2@email.com'];
        parLsit[0].Mailing_Zip_Postal_Code__c = '10001';
          parLsit[0].Date_Of_Birth__c = '1987-03-01';
        update parLsit;
        contact c =[select id,email,FirstName,LastName from contact where email='pi@emil.com'][0];
        system.debug('*******c:'+c);
        system.debug('********iprList: '+iprList);
        //INSERT ipr;
        Test.startTest();
        Database.executeBatch(new Batch_UpsertEprParticipantAndPE(), 7);      
        test.stopTest();
        //Valid IPR
        Integration_Patient_Referral__c iprprocessed = [SELECT Id, Error_Message__c, Participant_Enrollment__c FROM Integration_Patient_Referral__c where id=:ipr.id];
        system.assert(iprprocessed.Error_Message__c == null);//No errors is processring ipr records
        system.assert(iprprocessed.Participant_Enrollment__c != null);//participant enrollment record created
        
    
    }
    @IsTest
    private static void testNewAndAdditionalParticipant1() {
        
        integer i =1;
        string randomStr = 'IPRUser'+i; 
        String test1 = 'Test';
        List<Integration_Patient_Referral__c> iprList = new List<Integration_Patient_Referral__c>();
        Integration_Patient_Referral__c ipr = new Integration_Patient_Referral__c();
        
        ipr.Batch_consideration__c                = 'Not completed';
        ipr.Address_Country__c                    = 'US';
        ipr.Address_State__c                      = 'New York';
        ipr.Address_ZipCode__c                    = '10001';
        ipr.BirthDate__c                          = '1987-03-01';
        ipr.birthYear__c                          = '1987';
        ipr.Data_Source__c                        = 'ePR';
        ipr.Delegate_Daytime_Phone_Number__c      = (system.now().millisecond()+''+system.now().month()+i+''+system.now().hour()+''+system.now().minute()+''+system.now().day()).substring(0,7);
        ipr.Delegate_Email_Address__c             = test1+'@dltestm.com';
        ipr.Delegate_First_Name__c                = 'dfn'+test1;
        ipr.Delegate_Last_Name__c                 = 'dln'+test1;
        ipr.Delegate_Mailing_State__c             = 'New York';
        ipr.Delegate_Zip_Postal_Code__c           = '10001';
        ipr.email__c                              = '04ipremail@gmtesstail.com';
        ipr.firstName__c                          = 'fn'+test1;
        ipr.Language_Preference__c                = 'en_US';
        ipr.lastName__c                           = 'ln'+test1;
        ipr.phone__c                              = '8343212';
        ipr.protocolId__c                         = 'tt123456789';
        ipr.referralID__c                         = 'rid-'+'1230011';
        ipr.sex__c                                = 'Male';
        ipr.siteSelected__c                       = '123';
        ipr.acceptedTermsAndConditions__c         = '2020-01-01 10:52:39 AM';
        ipr.Referred_Date__c                      = '2020-01-01 10:52:39 AM';
        
        iprList.add(ipr);
        
        //Inserting Duplicate Participant
        Integration_Patient_Referral__c ipr1 = new Integration_Patient_Referral__c();
        
        ipr1.Batch_consideration__c                = 'Not completed';
        ipr1.Address_Country__c                    = 'US';
        ipr1.Address_State__c                      = 'Alabama';
        ipr1.Address_ZipCode__c                    = '10001';
        ipr1.BirthDate__c                          = '1987-03-01';
        ipr1.birthYear__c                          = '1987';
        ipr1.Data_Source__c                        = 'ePR';
        ipr1.Delegate_Daytime_Phone_Number__c      = (system.now().millisecond()+''+system.now().month()+i+''+system.now().hour()+''+system.now().minute()+''+system.now().day()).substring(0,7);
        ipr1.Delegate_Email_Address__c             = 'pi@emil.com';
        ipr1.Delegate_First_Name__c                = 'PITD';
        ipr1.Delegate_Last_Name__c                 = 'PITD';
        ipr1.Delegate_Mailing_State__c             = 'New York';
        ipr1.Delegate_Zip_Postal_Code__c           = '10001';
        ipr1.email__c                              = 'part2@email.com';
        ipr1.firstName__c                          = 'ParticipantTD1';
        ipr1.Language_Preference__c                = 'en_US';
        ipr1.lastName__c                           = 'ParticipantTD1';
        ipr1.phone__c                              = '55313538';
        ipr1.protocolId__c                         = 'tt123456789';
        ipr1.referralID__c                         = 'rid-'+'123001';
        ipr1.sex__c                                = 'Male';
        ipr1.siteSelected__c                       = '123';
        ipr1.acceptedTermsAndConditions__c        = '2020-01-01 10:52:39 AM';
        ipr1.Referred_Date__c                      = '2020-01-01 10:52:39 AM';
        ipr1.Delegate_Alternative_Phone_Number__c      ='232423242';
        ipr1.Delegate_Phone_Number_Type__c            ='Home';
        iprList.add(ipr1);
        
                   
        Insert iprList;
        List<Participant__c>  parLsit  = [Select id,Date_Of_Birth__c, Mailing_Zip_Postal_Code__c from participant__c where Email__c='part2@email.com'];
        parLsit[0].Mailing_Zip_Postal_Code__c = '10001';
          parLsit[0].Date_Of_Birth__c = '1987-03-01';
        update parLsit;
        contact c =[select id,email,FirstName,LastName from contact where email='pi@emil.com'][0];
        system.debug('*******c:'+c);
        system.debug('********iprList: '+iprList);
        //INSERT ipr;
        Test.startTest();
        Database.executeBatch(new Batch_UpsertEprParticipantAndPE(), 7);      
        test.stopTest();
        //Valid IPR
        Integration_Patient_Referral__c iprprocessed = [SELECT Id, Error_Message__c, Participant_Enrollment__c FROM Integration_Patient_Referral__c where id=:ipr.id];
        system.assert(iprprocessed.Error_Message__c == null);//No errors is processring ipr records
        system.assert(iprprocessed.Participant_Enrollment__c != null);//participant enrollment record created
        
    
    }
    @IsTest
    private static void testNewAndAdditionalParticipant2() {
        
        integer i =1;
        string randomStr = 'IPRUser'+i; 
        String test1 = 'Test';
        List<Integration_Patient_Referral__c> iprList = new List<Integration_Patient_Referral__c>();
        Integration_Patient_Referral__c ipr = new Integration_Patient_Referral__c();
        
        ipr.Batch_consideration__c                = 'Not completed';
        ipr.Address_Country__c                    = 'US';
        ipr.Address_State__c                      = 'New York';
        ipr.Address_ZipCode__c                    = '10001';
        ipr.BirthDate__c                          = '1987-03-01';
        ipr.birthYear__c                          = '1987';
        ipr.Data_Source__c                        = 'ePR';
        ipr.Delegate_Daytime_Phone_Number__c      = (system.now().millisecond()+''+system.now().month()+i+''+system.now().hour()+''+system.now().minute()+''+system.now().day()).substring(0,7);
        ipr.Delegate_Email_Address__c             = test1+'@dltestm.com';
        ipr.Delegate_First_Name__c                = 'dfn'+test1;
        ipr.Delegate_Last_Name__c                 = 'dln'+test1;
        ipr.Delegate_Mailing_State__c             = 'New York';
        ipr.Delegate_Zip_Postal_Code__c           = '10001';
        ipr.email__c                              = '04ipremail@gmtesstail.com';
        ipr.firstName__c                          = 'fn'+test1;
        ipr.Language_Preference__c                = 'en_US';
        ipr.lastName__c                           = 'ln'+test1;
        ipr.phone__c                              = '8343212';
        ipr.protocolId__c                         = 'tt123456789';
        ipr.referralID__c                         = 'rid-'+'1230011';
        ipr.sex__c                                = 'Male';
        ipr.siteSelected__c                       = '123';
        ipr.acceptedTermsAndConditions__c         = '2020-01-01 10:52:39 AM';
        ipr.Referred_Date__c                      = '2020-01-01 10:52:39 AM';
        
        iprList.add(ipr);
        
        //Inserting Duplicate Participant
        Integration_Patient_Referral__c ipr1 = new Integration_Patient_Referral__c();
        
        ipr1.Batch_consideration__c                = 'Not completed';
        ipr1.Address_Country__c                    = 'US';
        ipr1.Address_State__c                      = 'Alabama';
        ipr1.Address_ZipCode__c                    = '10001';
        ipr1.BirthDate__c                          = '1987-03-01';
        ipr1.birthYear__c                          = '1987';
        ipr1.Data_Source__c                        = 'ePR';
        ipr1.Delegate_Daytime_Phone_Number__c      = (system.now().millisecond()+''+system.now().month()+i+''+system.now().hour()+''+system.now().minute()+''+system.now().day()).substring(0,7);
        ipr1.Delegate_Email_Address__c             = 'pi@emil.com';
        ipr1.Delegate_First_Name__c                = 'PITD';
        ipr1.Delegate_Last_Name__c                 = 'PITD';
        ipr1.Delegate_Mailing_State__c             = 'New York';
        ipr1.Delegate_Zip_Postal_Code__c           = '10001';
        ipr1.email__c                              = 'part2@email.com';
        ipr1.firstName__c                          = 'ParticipantTD1';
        ipr1.Language_Preference__c                = 'en_US';
        ipr1.lastName__c                           = 'ParticipantTD1';
        ipr1.phone__c                              = '55313538';
        ipr1.protocolId__c                         = 'tt123456789';
        ipr1.referralID__c                         = 'rid-'+'123001';
        ipr1.sex__c                                = 'Male';
        ipr1.siteSelected__c                       = '123';
        ipr1.acceptedTermsAndConditions__c        = '2020-01-01 10:52:39 AM';
        ipr1.Referred_Date__c                      = '2020-01-01 10:52:39 AM';
        ipr1.Delegate_Alternative_Phone_Number__c      ='232423242';
        ipr1.Delegate_Phone_Number_Type__c            ='Mobile';
        iprList.add(ipr1);
        
        
        Insert iprList;
        List<Participant__c>  parLsit  = [Select id,Date_Of_Birth__c, Mailing_Zip_Postal_Code__c from participant__c where Email__c='part2@email.com'];
        parLsit[0].Mailing_Zip_Postal_Code__c = '10001';
          parLsit[0].Date_Of_Birth__c = '1987-03-01';
        update parLsit;
        contact c =[select id,email,FirstName,LastName from contact where email='pi@emil.com'][0];
        system.debug('*******c:'+c);
        system.debug('********iprList: '+iprList);
        //INSERT ipr;
        Test.startTest();
        Database.executeBatch(new Batch_UpsertEprParticipantAndPE(), 7);      
        test.stopTest();
        //Valid IPR
        Integration_Patient_Referral__c iprprocessed = [SELECT Id, Error_Message__c, Participant_Enrollment__c FROM Integration_Patient_Referral__c where id=:ipr.id];
        system.assert(iprprocessed.Error_Message__c == null);//No errors is processring ipr records
        system.assert(iprprocessed.Participant_Enrollment__c != null);//participant enrollment record created
        
    
    }
    
    
    @IsTest
    private static void testParticipantExisitingInRH() {
        
        integer i =1;
        string randomStr = 'IPRUser'+i; 
        String test1 = 'Test';
        
        Study_Site__c studySite = [select Id,Principal_Investigator__c,Site__c from Study_Site__c limit 1];
        Participant__c participant4 = new Participant__c(
            First_Name__c = 'ParticipantTD4',
            Last_Name__c = 'ParticipantTD4',
            Phone__c = '55313538',
            Email__c = 'part4@email.com',
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            Adult__c = true,
            Site__c = studySite.Site__c
        );
        insert participant4;
        
        Participant_Enrollment__c pe1 = new Participant_Enrollment__c(
            Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
            Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
            PI_Contact__c = studySite.Principal_Investigator__c,
            Study_Site__c = studySite.Id,
            Patient_ID__c = 'SomePatientId2',
            Referral_Source__c = 'PI',
            Initial_visit_scheduled_date__c = Date.today(),
            Initial_visit_occurred_flag__c = true,
            Participant_Status__c = DashboardRemoteNew.PE_STATUS_SUCCESSFULLY_CONTACTED,
            Participant__c = participant4.Id,
            Screening_ID__c = 'PESCR2'
        );
        //insert pe1;
        pe1 = [select Id,Name from Participant_Enrollment__c limit 1];
        List<Integration_Patient_Referral__c> iprList = new List<Integration_Patient_Referral__c>();
        Integration_Patient_Referral__c ipr = new Integration_Patient_Referral__c();
        
        ipr.Batch_consideration__c                = 'Not completed';
        ipr.Address_Country__c                    = 'US';
        ipr.Address_State__c                      = 'New York';
        ipr.Address_ZipCode__c                    = '10001';
        ipr.BirthDate__c                          = '1987-03-01';
        ipr.birthYear__c                          = '1987';
        ipr.Data_Source__c                        = 'ePR';
        ipr.Delegate_Daytime_Phone_Number__c      = (system.now().millisecond()+''+system.now().month()+i+''+system.now().hour()+''+system.now().minute()+''+system.now().day()).substring(0,7);
        ipr.Delegate_Email_Address__c             = test1+'@dltestm.com';
        ipr.Delegate_First_Name__c                = 'dfn'+test1;
        ipr.Delegate_Last_Name__c                 = 'dln'+test1;
        ipr.Delegate_Mailing_State__c             = 'New York';
        ipr.Delegate_Zip_Postal_Code__c           = '10001';
        ipr.email__c                              = '04ipremail@gmtesstail.com';
        ipr.firstName__c                          = 'fn'+test1;
        ipr.Language_Preference__c                = 'en_US';
        ipr.lastName__c                           = 'ln'+test1;
        ipr.phone__c                              = '8343212';
        ipr.protocolId__c                         = 'tt123456789';
        ipr.referralID__c                         = 'rid-'+'1230011';
        ipr.sex__c                                = 'Male';
        ipr.siteSelected__c                       = '123';
        ipr.acceptedTermsAndConditions__c         = '2020-01-01 10:52:39 AM';
        ipr.Referred_Date__c                      = '2020-01-01 10:52:39 AM';
        ipr.UTM_campaignName__c                   = pe1.Name;
        iprList.add(ipr);
        
        Insert iprList;
        
        Test.startTest();
        Database.executeBatch(new Batch_UpsertEprParticipantAndPE(), 7);      
        test.stopTest();
        Integration_Patient_Referral__c iprprocessed = [SELECT Id, Error_Message__c, Participant_Enrollment__c FROM Integration_Patient_Referral__c where id=:ipr.id];
        system.assert(iprprocessed.Error_Message__c == null);//No errors is processring ipr records
        system.assert(iprprocessed.Participant_Enrollment__c != null);//participant enrollment record created
    }
    
    
    @IsTest
    private static void testParticipantExisitingInRH1() {
        
        integer i =1;
        string randomStr = 'IPRUser'+i; 
        String test1 = 'Test';
        
        Account piAccount = new Account(
            Name = 'PI Account'
        );
        insert piAccount;
        
        Contact piContact = new Contact(
            FirstName = 'PI',
            LastName = 'PI',
            Email = '04ipremail@gmtesstail.com',
            AccountId = piAccount.Id,
            Birthdate = Date.valueOf('1987-03-01')
        );
        
        insert piContact;
        
        Study_Site__c studySite = [select Id,Principal_Investigator__c,Site__c from Study_Site__c limit 1];
        Participant__c participant4 = new Participant__c(
            First_Name__c = 'PI',
            Last_Name__c = 'PI',
            Phone__c = '8343212',
            Email__c = '04ipremail@gmtesstail.com',
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            Adult__c = true,
            Site__c = studySite.Site__c,
            Date_of_Birth__c = '1987-03-01',
            Contact__c = piContact.Id,
            Mailing_Zip_Postal_Code__c = '12345'
        );
        insert participant4;
        
        Participant_Enrollment__c pe1 = new Participant_Enrollment__c(
            Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
            Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
            //PI_Contact__c = studySite.Principal_Investigator__c,
            PI_Contact__c = piContact.Id,
            Study_Site__c = studySite.Id,
            Patient_ID__c = 'SomePatientId2',
            Referral_Source__c = 'PI',
            Initial_visit_scheduled_date__c = Date.today(),
            Initial_visit_occurred_flag__c = true,
            Participant_Status__c = DashboardRemoteNew.PE_STATUS_SUCCESSFULLY_CONTACTED,
            Participant__c = participant4.Id,
            Screening_ID__c = 'PESCR2'
        );
        //insert pe1;
        pe1 = [select Id,Name from Participant_Enrollment__c limit 1];
        List<Integration_Patient_Referral__c> iprList = new List<Integration_Patient_Referral__c>();
        Integration_Patient_Referral__c ipr = new Integration_Patient_Referral__c();
        
        ipr.Batch_consideration__c                = 'Not completed';
        ipr.Address_Country__c                    = 'US';
        ipr.Address_State__c                      = 'New York';
        ipr.Address_ZipCode__c                    = '12345';
        ipr.BirthDate__c                          = '1987-03-01';
        ipr.birthYear__c                          = '1987';
        ipr.Data_Source__c                        = 'ePR';
        ipr.Delegate_Daytime_Phone_Number__c      = (system.now().millisecond()+''+system.now().month()+i+''+system.now().hour()+''+system.now().minute()+''+system.now().day()).substring(0,7);
        ipr.Delegate_Email_Address__c             = test1+'@dltestm.com';
        ipr.Delegate_First_Name__c                = 'dfn'+test1;
        ipr.Delegate_Last_Name__c                 = 'dln'+test1;
        ipr.Delegate_Mailing_State__c             = 'New York';
        ipr.Delegate_Zip_Postal_Code__c           = '10001';
        ipr.email__c                              = '04ipremail@gmtesstail.com';
        ipr.firstName__c                          = 'PI';
        ipr.Language_Preference__c                = 'en_US';
        ipr.lastName__c                           = 'PI';
        ipr.phone__c                              = '8343212';
        ipr.protocolId__c                         = 'tt123456789';
        ipr.referralID__c                         = 'rid-'+'1230011';
        ipr.sex__c                                = 'Male';
        ipr.siteSelected__c                       = '123';
        ipr.acceptedTermsAndConditions__c         = '2020-01-01 10:52:39 AM';
        ipr.Referred_Date__c                      = '2020-01-01 10:52:39 AM';
        ipr.UTM_campaignName__c                   = pe1.Name;
        iprList.add(ipr);
        
        Insert iprList;
        
        Test.startTest();
        Database.executeBatch(new Batch_UpsertEprParticipantAndPE(), 7);      
        test.stopTest();
        Integration_Patient_Referral__c iprprocessed = [SELECT Id, Error_Message__c, Participant_Enrollment__c FROM Integration_Patient_Referral__c where id=:ipr.id];
        system.assert(iprprocessed.Error_Message__c == null);//No errors is processring ipr records
        system.assert(iprprocessed.Participant_Enrollment__c != null);//participant enrollment record created
    }
    
     @IsTest
    private static void testParticipantExisitingInRH2() {
        
        integer i =1;
        string randomStr = 'IPRUser'+i; 
        String test1 = 'Test';
        
        Account piAccount = new Account(
            Name = 'PI Account'
        );
        insert piAccount;
        
        Contact piContact = new Contact(
            FirstName = 'PI1',
            LastName = 'PI1',
            Email = '04ipremail@gmtesstail.com1',
            AccountId = piAccount.Id,
            Birthdate = Date.valueOf('1987-04-01')
        );
        
        insert piContact;
        
        Study_Site__c studySite = [select Id,Principal_Investigator__c,Site__c from Study_Site__c limit 1];
        Participant__c participant4 = new Participant__c(
            First_Name__c = 'PI',
            Last_Name__c = 'PI',
            Phone__c = '8343212',
            Email__c = '04ipremail@gmtesstail.com',
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            Adult__c = true,
            Site__c = studySite.Site__c,
            Date_of_Birth__c = '1987-03-01',
            Contact__c = null,
            Mailing_Zip_Postal_Code__c = '12345'
        );
        insert participant4;
        
        Participant_Enrollment__c pe1 = new Participant_Enrollment__c(
            Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
            Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
            //PI_Contact__c = studySite.Principal_Investigator__c,
            PI_Contact__c = null,
            Study_Site__c = studySite.Id,
            Patient_ID__c = 'SomePatientId2',
            Referral_Source__c = 'PI',
            Initial_visit_scheduled_date__c = Date.today(),
            Initial_visit_occurred_flag__c = true,
            Participant_Status__c = DashboardRemoteNew.PE_STATUS_SUCCESSFULLY_CONTACTED,
            Participant__c = participant4.Id,
            Screening_ID__c = 'PESCR2'
        );
        //insert pe1;
        pe1 = [select Id,Name from Participant_Enrollment__c limit 1];
        List<Integration_Patient_Referral__c> iprList = new List<Integration_Patient_Referral__c>();
        Integration_Patient_Referral__c ipr = new Integration_Patient_Referral__c();
        
        ipr.Batch_consideration__c                = 'Not completed';
        ipr.Address_Country__c                    = 'US';
        ipr.Address_State__c                      = 'New York';
        ipr.Address_ZipCode__c                    = '12345';
        ipr.BirthDate__c                          = '1987-03-01';
        ipr.birthYear__c                          = '1987';
        ipr.Data_Source__c                        = 'ePR';
        ipr.Delegate_Daytime_Phone_Number__c      = (system.now().millisecond()+''+system.now().month()+i+''+system.now().hour()+''+system.now().minute()+''+system.now().day()).substring(0,7);
        ipr.Delegate_Email_Address__c             = test1+'@dltestm.com';
        ipr.Delegate_First_Name__c                = 'dfn'+test1;
        ipr.Delegate_Last_Name__c                 = 'dln'+test1;
        ipr.Delegate_Mailing_State__c             = 'New York';
        ipr.Delegate_Zip_Postal_Code__c           = '10001';
        ipr.email__c                              = '04ipremail@gmtesstail.com';
        ipr.firstName__c                          = 'PI';
        ipr.Language_Preference__c                = 'en_US';
        ipr.lastName__c                           = 'PI';
        ipr.phone__c                              = '8343212';
        ipr.protocolId__c                         = 'tt123456789';
        ipr.referralID__c                         = 'rid-'+'1230011';
        ipr.sex__c                                = 'Male';
        ipr.siteSelected__c                       = '123';
        ipr.acceptedTermsAndConditions__c         = '2020-01-01 10:52:39 AM';
        ipr.Referred_Date__c                      = '2020-01-01 10:52:39 AM';
        ipr.UTM_campaignName__c                   = pe1.Name;
        iprList.add(ipr);
        
        Insert iprList;
        
        Test.startTest();
        Database.executeBatch(new Batch_UpsertEprParticipantAndPE(), 7);      
        test.stopTest();
        Integration_Patient_Referral__c iprprocessed = [SELECT Id, Error_Message__c, Participant_Enrollment__c FROM Integration_Patient_Referral__c where id=:ipr.id];
        system.assert(iprprocessed.Error_Message__c == null);//No errors is processring ipr records
        system.assert(iprprocessed.Participant_Enrollment__c != null);//participant enrollment record created
    }
}