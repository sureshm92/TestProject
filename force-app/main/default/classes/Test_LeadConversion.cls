/**
 * Created by Kryvolap on 23.10.2018.
 */
@isTest
private class Test_LeadConversion {
    static Account piAccount;
    static Account studySiteAccount;

    static Contact piContact;

    static User piUser;

    static Clinical_Trial_Profile__c study;
    static Study_Site__c studySite;

    static Terms_And_Conditions__c studyTC;

    static Lead testLead;
    static National_ID__c natId;
    static Material_Sent__c material;
    static void init() {

        studyTC = new Terms_And_Conditions__c();
        insert studyTC;

        piAccount = new Account(
                Name = 'PI Account'
        );
        insert piAccount;

        studySiteAccount = new Account(
                Name = 'Study Site Account'
        );
        insert studySiteAccount;

        piContact = new Contact(
                FirstName = 'PI',
                LastName = 'PI',
                Email = 'pi@emil.com',
                AccountId = piAccount.Id
        );
        insert piContact;


        study = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'tt123456789',
                Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = 'NCT00000001',
                Link_to_Pre_screening__c = 'some link',
                Terms_And_Conditions_ID__c = studyTC.Id,
                Study_Title__c = 'Some Title',
                Study_Code_Name__c = 'Some Code Name'

        );
        insert study;

        studySite = new Study_Site__c(

                Principal_Investigator__c = piContact.Id,
                Clinical_Trial_Profile__c = study.Id,
                Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
                Study_Site_Number__c = '1234567',
                Site__c = studySiteAccount.Id,
                Is_Virtual_Study_Site__c = true
        );
        insert studySite;
        studySite.Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED;
        update studySite;


        testLead = new Lead();
        testLead.FirstName = 'Test';
        testLead.LastName = 'Lead';
        testLead.Email = 'test@test.com';
        testLead.Status = 'New';
        testLead.Company = 'Test Lead Comp';
        testLead.Tax_ID__c = '111111';
        testLead.Degree__c = 'Doctorate';
        testLead.Facility_Type__c = 'Medical Group';
        testLead.Facility_Classification__c = 'Hospital';
        testLead.HCP_Referral_Source__c = 'ACOE Data';
        //testLead.Lead_CTE__c = 'Some text';
        testLead.OneKey_Code__c = '1234567';
        testLead.OneKey_ID__c = '1234567';
        testLead.Preferred_Reimbursement_Currency__c = 'USD';
        testLead.Previous_Trial_Experience__c = 'Yes';
        testLead.Specialty__c = 'Cardiovascular Disease';
        testLead.Contact_Method_Preference__c='Call';
        testLead.POC_First_Name__c = 'POC';
        testLead.POC_Last_Name__c = 'Test';
        testLead.POC_Email__c = 'POC@test.com';
        testLead.POC_Type__c = 'Office Manager';
        testLead.POC_Type_Description__c = '';
        testLead.POC_Phone__c = '444333222';
        testLead.Protocol_Number__c='tt123456789';
        testLead.Study_Site_Number__c='1234567';
        insert testLead;

        natId = new National_ID__c();
        natId.Lead__c = testLead.Id;
        natId.Name = '1234567890';
        natId.Country_Code__c = 'US';
        insert natId;

        material = new Material_Sent__c();
        material.Material_Sent__c = 'Poster';
        material.Lead__c = testLead.Id;
        insert material;

    }
    @isTest
    static void mainConversionTest() {
        init();
        Test.startTest();
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(testLead.Id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Qualified');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        Test.stopTest();
    }

}