@isTest
public class IntegrationSiteStaffBatchDeletionTest {
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
        Clinical_Trial_Profile__c clinical = [SELECT ID, Protocol_ID__c FROM Clinical_Trial_Profile__c LIMIT 1];
        Study_Site__c studySite = [SELECT Id FROM Study_Site__c LIMIT 1];
        
        List<Integration_Site_Staff__c> issList = new List<Integration_Site_Staff__c>();
        Integration_Site_Staff__c iss = new Integration_Site_Staff__c(
                Address_Country__c = 'US',
                Zip_Postal_Code__c = '12312',
                protocolId__c = clinical.Protocol_ID__c,
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
                protocolId__c = clinical.Protocol_ID__c,
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
        
        Database.executeBatch(new IntegrationSiteStaffBatchDeletion(clinical.Id));
        Test.stopTest();
    }
}