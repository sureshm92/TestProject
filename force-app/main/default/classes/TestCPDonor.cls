@IsTest
public class TestCPDonor
{
/* Remove
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
                Protocol_ID__c = '201791',
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
        Translation__c studyTranslation = new Translation__c(
                Language__c = pleList[0].value,
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
                protocolId__c = '201791',
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
                protocolId__c = '201791',
                siteSelected__c = 'SS1',
                Referred_Date__c  = '2019-10-02T10:00:00-05:00',
                referralID__c = '444323423',
                acceptedTermsAndConditions__c = '2019-10-02T10:00:00-05:00'
        );

        iprList.add(ipr);
        iprList.add(ipr2);
       // iprList.add(ipr3);
       //insert iprList;
        
        /*insert new Integration_Patient_Referral__c(
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
        );*/
        
       /* List<Integration_Site_Staff__c> issList = new List<Integration_Site_Staff__c>();
        Integration_Site_Staff__c iss = new Integration_Site_Staff__c(
                Address_Country__c = 'US',
                Zip_Postal_Code__c = '12312',
                protocolId__c = 'CTP1_SS1',
                Mailing_City__c = 'New York',
                Mailing_State__c = 'New York',
                First_Name__c = 'Sumit' ,
                Last_Name__c = 'Surve',
                Phone__c = '9270676867',
                Email__c = 'ursumit701@gmail.com',
                Roles__c = 'STUDY COORDINATOR, PRIMARY',
                Site_Email_Key__c = 'SS1_9270676867_ursumit701@gmail.com',
                Study_Site_Number__c = 'SS1'
        );

        Integration_Site_Staff__c iss2 = new Integration_Site_Staff__c(
                Address_Country__c = 'US',
                Zip_Postal_Code__c = '12312',
                protocolId__c = '201791',
                Mailing_City__c = 'New York',
                Mailing_State__c = 'New York',
                First_Name__c = 'Sabir' ,
                Last_Name__c = 'Khan',
                Phone__c = '9270676868',
                Email__c = 'gulamsabir.khan@quintiles.com',
                Roles__c = 'RECRUITMENT AND RETENTION',
                Site_Email_Key__c = 'SS1_9270676868_gulamsabir.khan@quintiles.com',
                Study_Site_Number__c = 'SS1'
        );

        issList.add(iss);
        issList.add(iss2);
        //insert(issList);*/
/* Remove
        test.stopTest();
        CPDonorReferralFormController.getStudySites('Test');
        CPDonorReferralFormController.getPickListValuesIntoList();
        CPDonorReferralFormController.FileUploadDataEntity testWrap = new CPDonorReferralFormController.FileUploadDataEntity();
        testWrap.fileName='Test11';
        testWrap.base64Data='64';
        testWrap.contentType='pdf';
        
        CPDonorReferralFormController.enrollPatient(Date.today(),ipr3,createFormResultRecord(),JSON.serialize(testWrap));
        CPDonorReferralFormController.checkScheduledMaintenance();
        IntegrationPatientRefCovidTriggerHandler.convertToDelegateContact(ipr3, accounts[0]);
        Form_Results__c formResult = createFormResultRecord(); 
        formResult.Participant_Enrollment__c = ipr3.Participant_Enrollment__c;
        insert formResult;
        createAttachment(formResult.Id);
        SurveyResponseViewController.getSurveyResponse(ipr3.Participant_Enrollment__c);
    }

   /*@IsTest
    static void testCPDonorReferralFormController() 
    {
        //TestData.createPIDelegateUser();
        TestData testDataInst = new TestData();
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_RECEIVED);
        Test.startTest();
        CPDonorReferralFormController.getPickListValuesIntoList();
        CPDonorReferralFormController.enrollPatient(Date.today(),createIntegrationPatientReferral(),createFormResultRecord(),'test');
        Form_Results__c formResult = createFormResultRecord();
        insert formResult;
        createAttachment(formResult.Id);
        SurveyResponseViewController.getSurveyResponse(formResult.Id);
        CPDonorReferralFormController.getStudySites('Test');

        Test.stopTest();
    }*/
   /* Remove
    private static Integration_Patient_Referral__c createIntegrationPatientReferral()
    {
        Integration_Patient_Referral__c newIntegrationPatientReferral = new Integration_Patient_Referral__c();
        newIntegrationPatientReferral.firstName__c = 'Test1';
        newIntegrationPatientReferral.Middle_Initial__c = 'Iqvia';
        newIntegrationPatientReferral.lastName__c = 'Covid19';
        newIntegrationPatientReferral.phone__c = '78788';
        newIntegrationPatientReferral.email__c = 'test@k.com';
        newIntegrationPatientReferral.Address_ZipCode__c = '67909';
        newIntegrationPatientReferral.Delegate_First_Name__c = 'Test2';
        newIntegrationPatientReferral.Delegate_Middle_Name__c = 'Iqviadeligate';
        newIntegrationPatientReferral.Delegate_Last_Name__c = 'Coviddel';
        newIntegrationPatientReferral.Delegate_Daytime_Phone_Number__c = '8888';
        newIntegrationPatientReferral.Delegate_Email_Address__c = 'test23@k.com';
        newIntegrationPatientReferral.BirthDate__c = formatDate(Date.today());
        newIntegrationPatientReferral.Address_Country__c = 'US';
        newIntegrationPatientReferral.acceptedTermsAndConditions__c = formatDate(Date.today());
        newIntegrationPatientReferral.protocolId__c = '201791';
        newIntegrationPatientReferral.Referred_Date__c = formatDate(Date.today());
        newIntegrationPatientReferral.Data_Source__c = 'IQVIA registry';
        newIntegrationPatientReferral.Language_Preference__c = 'en_US';
        newIntegrationPatientReferral.Condition_Of_Interests__c ='Covid-19';
        newIntegrationPatientReferral.siteSelected__c = '203';
        return newIntegrationPatientReferral;
    } 
    
    private static String formatDate(Date d) 
    {
        return d.year() + '-' + d.month() + '-' + d.day();
    }

    private static Form_Results__c createFormResultRecord()
    {
        Form_Results__c formResult = new Form_Results__c();
        formResult.Days_14_of_symptoms__c = true;
        formResult.Consent_to_store_info__c = true;
        formResult.Covid_19_Test_Date__c =  date.today();
        formResult.Estimated_Date_of_first_symptom__c = date.today();
        formResult.Estimated_date_of_last_symptom__c = date.today();
        formResult.Other_Referral_Org__c = 'Covid19';
        //formResult.Participant_Enrollment__c = ;
        formResult.Positive_for_COVID_19__c = true;
        formResult.Referral_Org__c = 'NYS';
        formResult.Refering_Orgs__c = 'NYS';
        return formResult;
    } 
    
    private static Attachment createAttachment(Id formId)  
    {
        Attachment att = new Attachment();
        att.Body=Blob.valueOf('test');
        att.Name='test';
        att.ParentId = formId;
        insert att;
        return att;
    }
    Remove */
}