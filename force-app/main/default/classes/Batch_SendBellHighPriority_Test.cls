// Test class for Batch_SendNotificationBellHighPriority

@isTest
public without sharing class Batch_SendBellHighPriority_Test {
    static List<String> status = new List<String>();
    @TestSetup
    static void init(){
        TestData.loadTestData();
        
        status.add('Received');
        status.add('Pre-review Passed');
        status.add('In Wash Out Period');
        status.add('Successfully Contacted');
        status.add('Contact Attempted');
        status.add('Eligibility Passed');
        status.add('Screening Passed');
        status.add('Screening In Progress');
        status.add('Screening Passed');
        status.add('Screening Failed');
        status.add('Screening In Progress - Wash Out Period');
        status.add('Ready to Screen');
        status.add('Enrollment Success');
        status.add('Randomization Success');
        status.add('Pre-review Failed');
        status.add('Unable to Reach');
        status.add('Contacted - Not Suitable');
        status.add('Eligibility Failed');
        status.add('Declined Consent');
        status.add('Unable to Screen');
        status.add('Withdrew Consent');
        status.add('Withdrew Consent After Screening');
        status.add('Enrollment Failed');
        status.add('Randomization Failed');
        status.add('Randomization Success');
        status.add('Treatment Period Started');
        status.add('Follow-Up Period Started');
        status.add('Participation Complete');
        status.add('Trial Complete');
        status.add('Declined Final Consent');
    }
    
    @isTest static void testgetListViewData() {
        // TestData.loadTestData();
        TestData testData = new TestData();
        List<Clinical_Trial_Profile__c> ctpList = new List<Clinical_Trial_Profile__c>();
        List<Study_Site__c> ssList = new List<Study_Site__c>();
        List<String> ctpIdList = new List<String>();
        List<Id> ssIdList = new List<Id>();
        
        
        ctpList = [SELECT Id FROM Clinical_Trial_Profile__c];
        ssList = [SELECT Id FROM Study_Site__c];
        
        ctpIdList.add(ctpList[0].Id); 
        ssIdList.add(ssList[0].Id);
        Test.startTest();
        Participant_Enrollment__c partEnroll = [
            SELECT Id, Participant__c, Show_Referring_Provider__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ]; 
        partEnroll.Clinical_Trial_Profile__c=ctpList[0].id;
        partEnroll.Study_Site__c=ssList[0].Id;
        partEnroll.Participant_Status__c='Received';
        partEnroll.Referral_Source__c='Principal Investigator';
        update partEnroll;
        Participant_Enrollment_Status_History__c pehistory1 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Eligibility Passed',
            Additional_Notes__c = 'Test Notes testing testclass code on this date by test user',
            ParticipantEnrollment__c = partEnroll.Id,
            Non_Enrollment_Reason__c= 'PI Decision',
            Notes__c='Test Notes testing testclass code on this date by test user'
        );
        insert pehistory1;
        Batch_SendNotificationBellHighPriority baa = new Batch_SendNotificationBellHighPriority(); 
        Database.executeBatch(baa);
        
        Test.stopTest();
    }
    @IsTest
    public static void runTest() {
        Terms_And_Conditions__c portalTC = new Terms_And_Conditions__c(Active__c = true);
        insert portalTC;

        List<Account> accounts = new List<Account>();
        Account participantsAccount = new Account(
            Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
        );
        insert participantsAccount;

        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE Name = 'View All' LIMIT 1];
        Profile profile_1 = [
            SELECT Id
            FROM Profile
            WHERE Name = 'IQVIA Customer Community Plus Login User'
            LIMIT 1
        ];
        User admin = [
            SELECT Id, Username, UserRoleId
            FROM User
            WHERE
                Profile.Name = 'System Administrator'
                AND UserRoleId = :userRole_1.Id
                AND IsActive = TRUE
            LIMIT 1
        ];
        User user_1;
        Contact contact_1;
        Contact contact_2;
        Account account_1;
        System.runAs(admin) {
            account_1 = new Account(Name = 'Community', BillingCountry = 'United States');
            insert account_1;

            contact_1 = new Contact(AccountId = account_1.Id, LastName = 'xgeek');
            insert contact_1;
            
            contact_2 = new Contact(AccountId = account_1.Id, LastName = 'xgeek');
            insert contact_2;

            user_1 = new User(
                Email = 'yourusername@gmail.com',
                ProfileId = profile_1.Id,
                UserName = 'yourusername@gmail.com',
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ContactId = contact_1.Id,
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname'
            );
            insert user_1;
        }
        Test.startTest();
      

        Clinical_Trial_Profile__c clinical = new Clinical_Trial_Profile__c(
            Protocol_ID__c = 'tt123456790',
            Override_Recruitment_Status__c = 'Actively Enrolling',
            NCT_Number__c = 'NCT00000002',
            Link_to_Pre_screening__c = 'some link',
            Study_Title__c = 'Some Title',
            Study_Code_Name__c = 'Some Code Name',
            Suppress_Participant_Emails__c = false,
            Bell_Notification_Reminder__c = 0
        );
        insert clinical;

        Study_Site__c studySite = new Study_Site__c(
            Name = 'Test',
            Study_Site_Phone__c = '0000034445',
            Principal_Investigator__c = contact_1.Id,
            Clinical_Trial_Profile__c = clinical.Id,
            Site__c = account_1.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false,
            Override_PI_Referral_Status__c  = 'Accepted'
        );
        insert studySite;
        
           Site_Staff__c siteStaff = new Site_Staff__c(
            Site_Contact__c = contact_2.Id,
            Delegate_Level__c = DelegateService.DELEGATE_LEVEL_1,
            Study_Site__c = studySite.Id,
            is_Invited__c = true
        );
        insert siteStaff;
        
       
        

        HCP_Enrollment__c hcpEnrollment = new HCP_Enrollment__c(
            Study_Site__c = studySite.Id,
            HCP_Contact__c = contact_1.Id,
            Status__c = HCPEnrollmentService.HCP_S_ACTIVATION_PENDING
        );
        insert hcpEnrollment;

        Participant__c participant = new Participant__c(
            First_Name__c = 'ParticipantTD',
            Last_Name__c = 'ParticipantTD',
            Phone__c = '55313535',
            Email__c = 'part1@email.com',
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            age__c = 23,
            site__c = account_1.id,
            Gender_Technical__c = 'Male',
            // Present_Age__c = 24,
            Adult__c = true,
            Ethnicity__c = ''
        );
        insert participant;

        Participant_Enrollment__c pe = new Participant_Enrollment__c(
            HCP__c = hcpEnrollment.Id,
            Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
            Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
            PI_Contact__c = contact_1.Id,
            Study_Site__c = studySite.Id,
            Patient_ID__c = 'SomePatientId1',
            Referral_Source__c = 'HCP',
            Source_Type__c = 'Referring Provider',
            HighRisk_Indicator__c = 'Yes',
            Participant__c = participant.Id,
            Screening_ID__c = 'PESCR1',
            Comorbidities__c = 'Yes',
            Participant_Status__c = 'Contact Attempted',
            Initial_visit_scheduled_flag__c = false,
            High_Priority__c = true
        );
        insert pe;
        Participant_Enrollment_Status_History__c pesh = new Participant_Enrollment_Status_History__c(
            Date__c = date.today(),
            ParticipantEnrollment__c = pe.Id,
            Status__c = 'Contact Attempted'
           
        );
       insert pesh;
        Batch_SendNotificationBellHighPriority baa = new Batch_SendNotificationBellHighPriority(); 
        Database.executeBatch(baa);
    }
    
}