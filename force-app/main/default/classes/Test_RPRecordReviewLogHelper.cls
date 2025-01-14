@isTest
public class Test_RPRecordReviewLogHelper {
   
    @isTest
    public static void TestM1(){
       
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
                Email = 'yourusername1@gmail.com',
                ProfileId = profile_1.Id,
                UserName = 'yourusername1@gmail.com',
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
            // Present_Age__c =
            Adult__c = true
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
            Participant_Status__c = 'Pending Referral',
            Participant__c = participant.Id,
            Screening_ID__c = 'PESCR1',
            Birth_Month__c='04',
            YOB__c='2000'
        );
        insert pe;
		System.runAs(user_1) {
            set<string> ctpids = new set<string>{clinical.id};
        
            RPRecordReviewLogHelper.getStudyDetails(contact_1.id);
            RPRecordReviewLogHelper.getStudies('HCP',contact_1.id);
            RPRecordReviewLogHelper.checkNeedsGuardian('US','NY','04','2000');
           
            RPRecordReviewLogHelper.checkDelegateAge('US','NY', '2000');
            RPRecordReviewLogHelper.getMonthWithZero();
            RPRecordReviewLogHelper.getMonthWithoutZero();
            RPRecordReviewLogHelper.getYear();
            RPRecordReviewLogHelper.getYear();
            //RPRecordReviewLogHelper.getSelectedStudySite(contact_1.id,clinical.id);
            RPRecordReviewLogHelper.getStudySiteDetails(ctpids );
            RPRecordReviewLogHelper.getContact(contact_1.id);
             try
            {
              RPRecordReviewLogHelper.getHCPInitData(clinical.id,'HCP');
            }
            catch (AuraHandledException e)
            {
              system.debug('Error handled');
            }
        }
        Test.stopTest();
        
    }
}