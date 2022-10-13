@IsTest
public class Batch_UpdateSiteActivationField_Test {
	@TestSetup
    static void init(){
        TestData.loadTestData(); 
        TestData testData = new TestData();
        Contact delegate = new Contact(
            FirstName = 'Patient',
            LastName = 'Delegate',
            Email = 'delegate@somemail.com',
            AccountId = testData.participant.Contact__r.AccountId,
            Current_Participant_Enrollment__c = testData.pe.Id,
            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
            userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
            UserCommunityIsDelegate__c = true
        );
        insert delegate;  
        List<Clinical_Trial_Profile__c> clinicalTrialProfiles = new List<Clinical_Trial_Profile__c>();
        clinicalTrialProfiles.add(
            (Clinical_Trial_Profile__c) TestDataFactory.getSObject(
                Clinical_Trial_Profile__c.getSObjectType(),
                new Map<String, Object>{
                    'Study_Title__c' => 'CTP 1',
                        'Protocol_ID__c' => 'CTP 1',
                        'Study_Code_Name__c' => 'CTP 1',
                        'NCT_Number__c' => 'NCT00000001',
                        
                        'Synch_with_TMDH__c' => true
                        }
            )
        ); 
        insert clinicalTrialProfiles;
       
        
        Account singleAccount = (Account) TestDataFactory.getSObject(Account.getSObjectType());
        insert singleAccount;
        Study_Site__c ss = new Study_Site__c();
        ss.Name = 'Sample';
        ss.Principal_Investigator__c = delegate.Id;
        ss.Clinical_Trial_Profile__c = clinicalTrialProfiles[0].Id;
        ss.Site__c = singleAccount.Id;
        ss.Study_Site_Key__c = 'sample';
        //ss.Override_PI_Referral_Status__c = 'On Hold';
        insert ss;
        Study_Site__c ss1 = new Study_Site__c();
        ss1.Name = 'Sample 12';
        ss1.Principal_Investigator__c = delegate.Id;
        ss1.Clinical_Trial_Profile__c = clinicalTrialProfiles[0].Id;
        ss1.Site__c = singleAccount.Id;
        ss1.Study_Site_Key__c = 'sample12';
        ss1.Override_PI_Referral_Status__c = 'Invitation Sent';
        insert ss1;
        Study_Site__c ss2 = new Study_Site__c();
        ss2.Name = 'Sample 23';
        ss2.Principal_Investigator__c = delegate.Id;
        ss2.Clinical_Trial_Profile__c = clinicalTrialProfiles[0].Id;
        ss2.Site__c = singleAccount.Id;
        ss2.Study_Site_Key__c = 'sample23';
        ss2.Override_PI_Referral_Status__c = 'On Hold';
        insert ss2;
    }
    @isTest
    static void testStatusUpdate(){
        List<String> referralsStatus = new List<String>{'Accepted','Accepted (Admin)','Deactivated (Admin)','Deactivated','Invitation Sent','On Hold (Admin)','On Hold'};
        List<Study_Site__c> ssLst =[select Id,Site_Activation_Status__c, Override_PI_Referral_Status__c  from Study_Site__c where  
        (Override_PI_Referral_Status__c  IN :referralsStatus or Override_PI_Referral_Status__c =null)];
        
        Test.startTest();
        Database.executeBatch(new Batch_UpdateSiteActivationField());
        Test.stopTest();
    }
}