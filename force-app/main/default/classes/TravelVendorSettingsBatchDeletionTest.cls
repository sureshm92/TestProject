@isTest
public class TravelVendorSettingsBatchDeletionTest {
	@testsetup
    public static void dataSetup() {
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
        Account account_1;
        System.runAs(admin) {
            account_1 = new Account(Name = 'Community', BillingCountry = 'United States');
            insert account_1;

            contact_1 = new Contact(AccountId = account_1.Id, LastName = 'xgeek');
            insert contact_1;

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
            Suppress_Participant_Emails__c = false
        );
        insert clinical;

        Study_Site__c studySite = new Study_Site__c(
            Name = 'Test',
            Study_Site_Phone__c = '0000034445',
            Principal_Investigator__c = contact_1.Id,
            Clinical_Trial_Profile__c = clinical.Id,
            Site__c = account_1.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false
        );
        insert studySite;

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
            Initial_visit_scheduled_date__c = date.today(),
            Study_Site__c = studySite.Id,
            Patient_ID__c = 'SomePatientId1',
            Referral_Source__c = 'HCP',
            Source_Type__c = 'Referring Provider',
            HighRisk_Indicator__c = 'Yes',
            Participant__c = participant.Id,
            Screening_ID__c = 'PESCR1',
            Comorbidities__c = 'Yes'
        );
        insert pe;
        Participant_Enrollment_Status_History__c pesh = new Participant_Enrollment_Status_History__c(
            Date__c = date.today(),
            ParticipantEnrollment__c = pe.Id,
            Status__c = 'Contact Attempted'
        );
       insert pesh;
    }
    @IsTest
    public static void runTest() {
        Test.startTest();
        Clinical_Trial_Profile__c clinical = [SELECT ID FROM Clinical_Trial_Profile__c LIMIT 1];
        Study_Site__c studySite = [SELECT Id FROM Study_Site__c LIMIT 1];
        List<TravelVendor__c> travelVendors = new List<TravelVendor__c>{
            new TravelVendor__c(Name = 'Uber', Link_Vendor__c = 'link 1'),
            new TravelVendor__c(Name = 'Uklon', Link_Vendor__c = 'link 2'),
            new TravelVendor__c(Name = 'Kiev Taxi', Link_Vendor__c = 'link 3'),
            new TravelVendor__c(Name = 'Uzbek', Link_Vendor__c = 'link 4')
        };
        insert travelVendors;

        List<TravelVendorSettings__c> travelVendorSettings = new List<TravelVendorSettings__c>{
            new TravelVendorSettings__c(
                Study_Site__c = studySite.Id,
                TravelVendor__c = travelVendors[0].Id,
                isEnable__c = true,
                Is_Manual__c = true
            ),
            new TravelVendorSettings__c(
                Study_Site__c = studySite.Id,
                TravelVendor__c = travelVendors[1].Id,
                isEnable__c = true,
                By_Country__c = true
            ),
            new TravelVendorSettings__c(
                Study_Site__c = studySite.Id,
                TravelVendor__c = travelVendors[2].Id,
                isEnable__c = false,
                Is_Manual__c = true,
                By_Country__c = true
            ),
            new TravelVendorSettings__c(
                Study_Site__c = studySite.Id,
                TravelVendor__c = travelVendors[3].Id,
                isEnable__c = false
            )
        };
        insert travelVendorSettings;
        
        Database.executeBatch(new TravelVendorSettingsBatchDeletion(clinical.Id));
        Test.stopTest();
    }
     @IsTest
    public static void runTest2() {
        Test.startTest();
        Clinical_Trial_Profile__c clinical = [SELECT ID FROM Clinical_Trial_Profile__c LIMIT 1];
        Study_Site__c studySite = [SELECT Id FROM Study_Site__c LIMIT 1];
        List<TravelVendor__c> travelVendors = new List<TravelVendor__c>{
            new TravelVendor__c(Name = 'Uber', Link_Vendor__c = 'link 1'),
            new TravelVendor__c(Name = 'Uklon', Link_Vendor__c = 'link 2'),
            new TravelVendor__c(Name = 'Kiev Taxi', Link_Vendor__c = 'link 3'),
            new TravelVendor__c(Name = 'Uzbek', Link_Vendor__c = 'link 4')
        };
        insert travelVendors;

        List<TravelVendorSettings__c> travelVendorSettings = new List<TravelVendorSettings__c>{
            new TravelVendorSettings__c(
                Study_Site__c = studySite.Id,
                TravelVendor__c = travelVendors[0].Id,
                isEnable__c = true,
                Is_Manual__c = true
            ),
            new TravelVendorSettings__c(
                Study_Site__c = studySite.Id,
                TravelVendor__c = travelVendors[1].Id,
                isEnable__c = true,
                By_Country__c = true
            ),
            new TravelVendorSettings__c(
                Study_Site__c = studySite.Id,
                TravelVendor__c = travelVendors[2].Id,
                isEnable__c = false,
                Is_Manual__c = true,
                By_Country__c = true
            ),
            new TravelVendorSettings__c(
                Study_Site__c = studySite.Id,
                TravelVendor__c = travelVendors[3].Id,
                isEnable__c = false
            )
        };
        insert travelVendorSettings;
        
        Database.executeBatch(new TravelVendorSettingsBatchDeletion(clinical.Id, false));
        Test.stopTest();
    }
}