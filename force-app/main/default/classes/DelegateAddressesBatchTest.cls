@isTest(IsParallel=true)
public class DelegateAddressesBatchTest {
	
     public static void createData() {
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
         
		Contact newDelegate = new Contact(
        	LastName = 'TestDelegate'
        );
        contacts.add(newDelegate);
        insert contacts;
        
        List<Terms_And_Conditions__c> tcList = new List<Terms_And_Conditions__c>();
        Terms_And_Conditions__c portalTC = new Terms_And_Conditions__c(
                Active__c = true
        );
        tcList.add(portalTC);
    
        Terms_And_Conditions__c studyTC = new Terms_And_Conditions__c();
        tcList.add(studyTC);
        insert tcList; 
         
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
         
        Study_Site__c studySite = new Study_Site__c(
                Principal_Investigator__c = piContact.Id,
                Clinical_Trial_Profile__c = study.Id,
                Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
                Site__c = studySiteAccount.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false
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
        
        List<HCP_Enrollment__c> enrollments = new List<HCP_Enrollment__c>();
        enrollments = [SELECT id FROM HCP_Enrollment__c];
        List <Referring_HCP_Staff__c> listOfStaff = new List<Referring_HCP_Staff__c>();
        for(Integer i = 0; i < 10; i++){
            Referring_HCP_Staff__c staffItem = new Referring_HCP_Staff__c(
            	Contact__c = newDelegate.id,
                HCP_Enrollment__c = enrollments[0].id,
                Delegate_Level__c = i == 6 ? 'Level 1' : 'Level 2'
            );
            listOfStaff.add(staffItem);
        }
         insert listOfStaff;
	}
    
    @isTest
    public static void testDelegatesUpdates(){
       ClassFactory.putStubTypeByClassName(CommunityService.class, StubBuilder.newInstance(CommunityService.class)
               .when('createPortalUsers')
               .then(null)
               .when('createParticipantUsers')
               .then(null)
               .build()
       );
        createData();
        Test.startTest();
	 	DelegateAddressesBatch bt = new DelegateAddressesBatch();
		Database.executeBatch(bt);  
        Test.stopTest();
       
    }
}