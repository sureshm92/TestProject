@isTest
public class HCPInviteControllerNew_Test {
    
    @testSetup
    public static void testData(){
        Terms_And_Conditions__c studyTC = new Terms_And_Conditions__c(T_C_Text__c='testTextTerms',
                                                                     Active__c=True,Language__c='en_US',
                                                                      Community_Name__c='IQVIA Referral Hub'
                                                                      ,T_C_Type__c='Terms and Conditions');
        insert studyTC;
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
            Terms_And_Conditions_ID__c = studyTC.Id,
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
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'AdminUser',
            Email = 'adminuser@test.com',
            Username = 'adminuser@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert U;
        
        List<Lead> lstLead = new List<Lead> ();
        Lead testLead = new Lead();
        testLead.FirstName = 'HelloTest';
        testLead.LastName = 'Lead';
        testLead.Email = 'test@testHcp.com';
        testLead.Status = 'New';
        testLead.Company = 'HelloTest Lead Comp';
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
        objLead.OneKey_Code__c = '91121';
        objLead.Tax_ID__c = '56565';
        objLead.OneKey_ID__c = '1100991';
         objLead.Protocol_Number__c = 'tt123456789';
        objLead.Study_Site_Number__c = '1234567';
        lstLead.add(objLead);
        
        insert lstLead;  
    }
    
   @isTest
    public static void testcheckDuplicateLead(){
        Lead testLead = [SELECT ID FROM LEAD WHERE POC_Email__c = 'POC@test.com' LIMIT 1];
         Test.startTest();
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(testLead.Id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Qualified and Send Invitation');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        String strLead = HCPInviteControllerNew.checkDuplicateLead(testLead.ID);
        System.assert(strLead != 'false');
        HCPInviteControllerNew.PortalDetails objHCPInvite = HCPInviteControllerNew.getPortalTermsDetail();
        System.assert(objHCPInvite.strCommunityDetails != Null);
        test.stopTest(); 
    }
    
    @isTest
    public static void testValidateConvertLead(){
        Lead testLead = [SELECT ID,FirstName,LastName,PostalCode,isConverted FROM LEAD WHERE POC_Email__c = 'POC@test.com' LIMIT 1];
         Test.startTest();
         String strData = HCPInviteControllerNew.validateAndConvertLead(testLead.firstname,testLead.LastName
                                                      ,testLead.PostalCode,testLead.Id);
        Lead testLeadAfterConvert = [SELECT ID,FirstName,LastName,PostalCode,isConverted FROM LEAD WHERE POC_Email__c = 'POC@test.com' LIMIT 1];
        System.assertEquals(true, testLeadAfterConvert.isConverted);
        System.assert(strData != 'UserAlreadyThere');
        
        test.stopTest(); 
    } 
    
    @isTest
    public static void testacceptTerms(){
        User objUser  = [Select id from user where Email = 'adminuser@test.com'];
        Terms_And_Conditions__c objTerms = [SELECT ID FROM Terms_And_Conditions__c LIMIT 1];
        test.startTest();
        HCPInviteControllerNew.acceptTerms(objUser.Id, objTerms.id);
        test.stopTest();
    }
    
   @isTest
    public static void testValidateConvertLead_Duplicate(){
        Lead testLead = [SELECT ID,FirstName,LastName,PostalCode,isConverted FROM LEAD WHERE POC_Email__c = 'POC@test.com' LIMIT 1];
         Lead testLead_2 = [SELECT ID,FirstName,LastName,PostalCode,isConverted FROM LEAD WHERE FirstName='testFirstName' LIMIT 1];
        
         Test.startTest();
        String strData = HCPInviteControllerNew.validateAndConvertLead(testLead.firstname,testLead.LastName
                                                      ,testLead.PostalCode,testLead.Id);
         String strData_2 = HCPInviteControllerNew.validateAndConvertLead(testLead_2.firstname,testLead_2.LastName
                                                      ,testLead_2.PostalCode,testLead_2.Id); 
        System.assert(strData_2 == 'UserAlreadyThere');
        
        test.stopTest(); 
    }  
    
    @isTest
    public static void testcheckPassword(){
        Lead testLead = [SELECT ID,FirstName,LastName,PostalCode,isConverted FROM LEAD WHERE POC_Email__c = 'POC@test.com' LIMIT 1];
        System.assertEquals(false, testLead.isConverted);
         Test.startTest();
         String strData = HCPInviteControllerNew.validateAndConvertLead(testLead.firstname,testLead.LastName
                                                      ,testLead.PostalCode,testLead.Id);
        User objUser = [SELECT ID FROM User where UserName='test@testhcp.com' LIMIT 1];
        HCPInviteControllerNew.checkPassword(objUser.id,'test@123','test@1234');
        test.stopTest(); 
    }
    
     @isTest
    public static void testsaveUserData(){
        Lead testLead = [SELECT ID,FirstName,LastName,PostalCode,isConverted FROM LEAD WHERE POC_Email__c = 'POC@test.com' LIMIT 1];
        User objAdminUser = [SELECT ID FROM User where Email = 'adminuser@test.com'];
        System.assertEquals(false, testLead.isConverted);
         Test.startTest();
        system.runAs(objAdminUser){
         String strData = HCPInviteControllerNew.validateAndConvertLead(testLead.firstname,testLead.LastName
                                                      ,testLead.PostalCode,testLead.Id);
        }
        User objUser = [SELECT ID,contactId FROM User where UserName='test@testhcp.com' LIMIT 1];
        Contact ObjContact = [SELECT Name,email from contact where id=:objUser.ContactId];
        HCPInviteControllerNew.GetContactUserWrapper objWrapper = new HCPInviteControllerNew.GetContactUserWrapper();
        objWrapper.objCurrentContact = ObjContact;
        objWrapper.ObjCurrentUser = objUser;
        objWrapper.strPassword = 'vicky@1234';
        objWrapper.strConfrmPassword = 'vicky@1234';
        HCPInviteControllerNew.saveUserData(JSON.serialize(objWrapper),true);
        test.stopTest(); 
    }
    
     @isTest
    public static void testsaveUserDataException(){
        Lead testLead = [SELECT ID,FirstName,LastName,PostalCode,isConverted FROM LEAD WHERE POC_Email__c = 'POC@test.com' LIMIT 1];
       
        System.assertEquals(false, testLead.isConverted);
         Test.startTest();
        
         String strData = HCPInviteControllerNew.validateAndConvertLead(testLead.firstname,testLead.LastName
                                                      ,testLead.PostalCode,testLead.Id);
        
        User objUser = [SELECT ID,contactId FROM User where UserName='test@testhcp.com' LIMIT 1];
        Contact ObjContact = [SELECT Name,email from contact where id=:objUser.ContactId];
        HCPInviteControllerNew.GetContactUserWrapper objWrapper = new HCPInviteControllerNew.GetContactUserWrapper();
        objWrapper.objCurrentContact = ObjContact;
        objWrapper.ObjCurrentUser = objUser;
        objWrapper.strPassword = 'vicky@1234';
        objWrapper.strConfrmPassword = 'vicky@1234';
        HCPInviteControllerNew.saveUserData(JSON.serialize(objWrapper),true);
        test.stopTest(); 
    }
    
     @isTest
    public static void testgetInitUserDetails(){
        Lead testLead = [SELECT ID,FirstName,LastName,PostalCode,isConverted FROM LEAD WHERE POC_Email__c = 'POC@test.com' LIMIT 1];
        System.assertEquals(false, testLead.isConverted);
         Test.startTest();
         String strData = HCPInviteControllerNew.validateAndConvertLead(testLead.firstname,testLead.LastName
                                                      ,testLead.PostalCode,testLead.Id);
        User objUser = [SELECT ID FROM User where UserName='test@testhcp.com' LIMIT 1];
        HCPInviteControllerNew.getInitUserDetails(objUser.id);
        test.stopTest(); 
    }
    
    
    

}