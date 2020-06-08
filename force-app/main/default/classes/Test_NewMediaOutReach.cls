/**
*  @Author : Vicky
*/
@IsTest(IsParallel=false)
private  class Test_NewMediaOutReach {
    
    @IsTest    
    static  void testOutReach() {
        
        Account studySiteAccount = new Account(
            Name = 'Study Site Account',
            BillingCountry = 'United States'
        );
        
        insert studySiteAccount;
        
        Contact piContact = new Contact(
            FirstName = 'PITD',
            LastName = 'PITD',
            Email = 'pi@emil.com',
            MailingCountry = 'United States',
            AccountId = studySiteAccount.Id
        );
        insert piContact;
       
        Clinical_Trial_Profile__c testStudy = new Clinical_Trial_Profile__c(
            Protocol_ID__c = 'tt123456790',
            Override_Recruitment_Status__c = 'Actively Enrolling',
            NCT_Number__c = 'NCT00000002',
            Link_to_Pre_screening__c = 'some link',
            Study_Title__c = 'Some Title',
            Study_Code_Name__c = 'Some Code Name',
            Suppress_Participant_Emails__c = false
        );
        insert testStudy;
        
        Study_Site__c studySite = new Study_Site__c(
            Name = 'Test',
            Principal_Investigator__c = piContact.Id,
            Clinical_Trial_Profile__c = testStudy.Id,
            Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED,
            Site__c = studySiteAccount.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false
        );
        insert studySite;
        Media_Outreach__c mediaOut = new Media_Outreach__c(
            Study_Name__c = studySite.Id,
            Study_Site__c = studySiteAccount.Id,
            Media_Type__c = 'Radio;Television;Social Media;',
            Preferred_contact_method__c = 'test@gmail.com',
            Status__c = 'Requested',
            Requested_Start_Date__c = Date.parse('5/22/2020'),
            Requested_End_Date__c = Date.parse('5/29/2020')
        );
        insert mediaOut;
        List<string> lsstng = new List<string>();
        lsstng.add('Radio');
        lsstng.add('Television');
        lsstng.add('Social Media');
        Note nots = new Note(
            Title = 'Test notes',
            body = 'Test mailing record',
            parentId = mediaOut.Id
        );
        insert nots;
        string start = string.valueof(Date.parse('5/22/2020'));
        string enddt = string.valueof(Date.parse('5/29/2020'));
        Test.startTest();
        newMediaOutReach.getPickListValues('Media_Outreach__c','Media_Type__c');
        newMediaOutReach.inviteNewMedia('Test','Study Site Account','test@gmail.com', lsstng,start,enddt,'Test notes');
        Test.stopTest();
    }
    
    @IsTest
    static  void teststudyCon() {
        
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE Name = 'View All' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'IQVIA Customer Community Plus Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        System.runAs(admin) {
            Account usraccount = new Account( Name = 'Community');
            insert usraccount;
            
            Contact usrcontact = new Contact(AccountId = usraccount.Id, LastName = 'xgeek');
            insert usrcontact;
            
            user_1 = new User( 
                Email = 'yourusername@gmail.com',
                ProfileId = profile_1.Id, 
                UserName = 'yourusername@gmail.com', 
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US',
                ContactId = usrcontact.Id,
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname'
            );
            insert user_1;
        }
        Test.startTest();
        System.runAs(user_1) {
               Account SiteAccount = new Account(
                Name = 'Study Site Account',
                BillingCountry = 'United States'
            );
            
            insert SiteAccount;
            
            Contact con = new Contact(
                FirstName = 'PITD',
                LastName = 'PITD',
                AccountId = SiteAccount.Id
            );
            insert con;
            
            
            Clinical_Trial_Profile__c clinical = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'tt123456790',
                Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = 'NCT00000002',
                Link_to_Pre_screening__c = 'some link',
                Study_Title__c = 'Some Title',
                Study_Code_Name__c = 'Some Code Name',
                Suppress_Participant_Emails__c = false
            );
            insert clinical;
            
            Study_Site__c studySite = new Study_Site__c(
                Name = 'Test',
                Principal_Investigator__c = con.Id,
                Clinical_Trial_Profile__c = clinical.Id,
                Site__c = SiteAccount.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false
            );
            insert studySite;
            newMediaOutReach.getstudyContact();
            newMediaOutReach.getstudyType('Test');
            newMediaOutReach.getstudyData('Test');
        }
        Test.stopTest();
    }
    
}