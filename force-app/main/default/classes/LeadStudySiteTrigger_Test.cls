@isTest
public class LeadStudySiteTrigger_Test {
    
     @istest
    public static void testLeadInsert(){
        
       Account piAccount = new Account(Name = 'PI Account');
        insert piAccount;
       Account studySiteAccount = new Account(Name = 'Study Site Account');
        insert studySiteAccount;
       Contact  piContact = new Contact(
            FirstName = 'PI',
            LastName = 'PI',
            Email = 'pi@emil.com',
            AccountId = piAccount.Id
        );
        insert piContact;
        Clinical_Trial_Profile__c study  = new Clinical_Trial_Profile__c(
            Protocol_ID__c = 'tt123456789',
            Override_Recruitment_Status__c = 'Actively Enrolling',
            NCT_Number__c = 'NCT00000001',
            Link_to_Pre_screening__c = 'some link',
            //Terms_And_Conditions_ID__c = studyTC.Id,
            Study_Title__c = 'Some Title',
            Study_Code_Name__c = 'Some Code Name',
            Synch_with_TMDH__c = true
        );
        insert study;
        Study_Site__c studySite = new Study_Site__c(
            Principal_Investigator__c = piContact.Id,
            Clinical_Trial_Profile__c = study.Id,
            Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
            Study_Site_Number__c = '1234567',
            Site__c = studySiteAccount.Id,
            Study_Site_Type__c = 'Virtual'
        );
        insert studySite;
        studySite.Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED;
        update studySite; 
        test.startTest();
        List<Lead> lstLead = new List<Lead> ();
        Lead testLead = new Lead();
        testLead.FirstName = 'HelloTest';
        testLead.LastName = 'Lead';
        testLead.Email = 'test@testHcp.com';
        testLead.Status = 'New';
        testLead.Company = 'HelloTest Lead Comp';
        testLead.Tax_ID__c = '111111';
        testLead.Facility_Classification__c = 'Hospital';
        testLead.HCP_Referral_Source__c = 'ACOE Data';
        //testLead.Lead_CTE__c = 'Some text';

        testLead.Contact_Method_Preference__c = 'Call';
        testLead.POC_First_Name__c = 'POC';
        testLead.POC_Last_Name__c = 'HelloTest';
        testLead.POC_Email__c = 'POC@test.com';
        testLead.POC_Type__c = 'Office Manager';
        testLead.POC_Type_Description__c = '';
        testLead.POC_Phone__c = '444333222';
        testLead.Protocol_Number__c = 'tt123456789';
        testLead.Study_Site_Number__c = '1234567';
        lstLead.add(testLead);
        
        Lead objLead = new Lead();
        objLead.FirstName='testFirstName';
        objLead.LastName='testLastName';
        objLead.PostalCode = '99111';
        objLead.Email = 'test@testHcp.com';
        objLead.Company = 'NewCompany';
        objLead.Tax_ID__c = '56565';
        // objLead.Protocol_Number__c = 'tt123456789';
        objLead.Study_Site_Number__c = '1234567';
          objLead.HCP_Referral_Source__c = 'ACOE Data';
        objLead.Study_Site__c = studySite.id;
        lstLead.add(objLead);
        try{
        insert lstLead;  
        }
        catch(exception ex){
            
        }
        test.stopTest();
    }
    
    
     @istest
    public static void testLeadInsertstudysiteerror(){
        
       Account piAccount = new Account(Name = 'PI Account');
        insert piAccount;
       Account studySiteAccount = new Account(Name = 'Study Site Account');
        insert studySiteAccount;
       Contact  piContact = new Contact(
            FirstName = 'PI',
            LastName = 'PI',
            Email = 'pi@emil.com',
            AccountId = piAccount.Id
        );
        insert piContact;
        Clinical_Trial_Profile__c study  = new Clinical_Trial_Profile__c(
            Protocol_ID__c = 'tt123456789',
            Override_Recruitment_Status__c = 'Actively Enrolling',
            NCT_Number__c = 'NCT00000001',
            Link_to_Pre_screening__c = 'some link',
            //Terms_And_Conditions_ID__c = studyTC.Id,
            Study_Title__c = 'Some Title',
            Study_Code_Name__c = 'Some Code Name',
            Synch_with_TMDH__c = true
        );
        insert study;
        Study_Site__c studySite = new Study_Site__c(
            Principal_Investigator__c = piContact.Id,
            Clinical_Trial_Profile__c = study.Id,
            Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
            Study_Site_Number__c = '1234567',
            Site__c = studySiteAccount.Id,
            Study_Site_Type__c = 'Virtual'
        );
        insert studySite;
        studySite.Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED;
        update studySite; 
        test.startTest();
        List<Lead> lstLead = new List<Lead> ();
        Lead testLead = new Lead();
        testLead.FirstName = 'HelloTest';
        testLead.LastName = 'Lead';
        testLead.Email = 'test@testHcp.com';
        testLead.Status = 'New';
        testLead.Company = 'HelloTest Lead Comp';
        testLead.Tax_ID__c = '111111';
        testLead.Facility_Classification__c = 'Hospital';
        testLead.HCP_Referral_Source__c = 'ACOE Data';
        //testLead.Lead_CTE__c = 'Some text';

        testLead.Contact_Method_Preference__c = 'Call';
        testLead.POC_First_Name__c = 'POC';
        testLead.POC_Last_Name__c = 'HelloTest';
        testLead.POC_Email__c = 'POC@test.com';
        testLead.POC_Type__c = 'Office Manager';
        testLead.POC_Type_Description__c = '';
        testLead.POC_Phone__c = '444333222';
        testLead.Protocol_Number__c = 'tt123456789';
        testLead.Study_Site_Number__c = '1234567';
        lstLead.add(testLead);
        
        Lead objLead = new Lead();
        objLead.FirstName='testFirstName';
        objLead.LastName='testLastName';
        objLead.PostalCode = '99111';
        objLead.Email = 'test@testHcp.com';
        objLead.Company = 'NewCompany';
        objLead.Tax_ID__c = '56565';
         objLead.Protocol_Number__c = 'tt123456789';
        objLead.Study_Site_Number__c = '123456766';
          objLead.HCP_Referral_Source__c = 'ACOE Data';
       // objLead.Study_Site__c = studySite.id; 
        lstLead.add(objLead); 
        try{
        insert lstLead;  
        }
        catch(exception ex){
            
        }
        test.stopTest();
    }
    
    

}