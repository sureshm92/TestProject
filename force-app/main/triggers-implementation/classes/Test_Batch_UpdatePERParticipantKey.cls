/**
 * Created by Velu on 14-Dec-20.
 */

@IsTest
public class Test_Batch_UpdatePERParticipantKey  {
    @IsTest
    static void testParticipantEnrollments() {
        
        Contact hcpContact;
        List<Account> accounts = new List<Account>();
        Account participantsAccount = new Account(
            Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
        );
        accounts.add(participantsAccount);

        Account piAccount = new Account(Name = 'PI Account', BillingCountry = 'United States');
        accounts.add(piAccount);
        

        Account hcpAccount = new Account(Name = 'HCP Account');
        accounts.add(hcpAccount);

        Account delegateAccount = new Account(
            Name = CommunityService.COMMUNITY_DELEGATE_ACCOUNT_NAME
        );
        accounts.add(delegateAccount);

        Account studySiteAccount = new Account(
            Name = 'Study Site Account',
            BillingLatitude = 41.766594,
            BillingLongitude = -74.991509,
            BillingCountry = 'United States'
        );
        accounts.add(studySiteAccount);
        insert accounts;

        List<Contact> contacts = new List<Contact>();
        Contact piContact = new Contact(
            FirstName = 'PITD',
            LastName = 'PITD',
            Email = 'pi@emil.com',
            MailingCountry = 'United States',
            AccountId = piAccount.Id
        );
        contacts.add(piContact);

        Contact piDelegateContact = new Contact(
            FirstName = 'PIDelTD',
            LastName = 'PIDelTD',
            Email = 'pi_delegate@emil.com',
            AccountId = piAccount.Id,
            userCommunityMode__c = 'PI'
        );
        contacts.add(piDelegateContact);

        hcpContact = new Contact(
            FirstName = 'HCPTD',
            LastName = 'HCPTD',
            Email = 'hcp@emil.com',
            AccountId = hcpAccount.Id,
            MailingLatitude = 40.766594,
            MailingLongitude = -73.991509,
            userCommunytyType__c = CommunityService.USER_MODE_HCP,
            userCommunityMode__c = CommunityService.USER_MODE_HCP
        );

        Contact hcpDelegateContact = new Contact(
            FirstName = 'HCPDelTD',
            LastName = 'HCPDelTD',
            Email = 'hcp_delegate@emil.com',
            AccountId = hcpAccount.Id
        );
        contacts.add(hcpDelegateContact);

        contacts.add(hcpContact);
        Contact ccContact = new Contact(
            FirstName = 'CCTD',
            LastName = 'CCTD',
            Email = 'cc@emil.com',
            AccountId = hcpAccount.Id,
            userCommunytyType__c = CommunityService.USER_MODE_CC,
            userCommunityMode__c = CommunityService.USER_MODE_CC
        );

        contacts.add(ccContact);
        insert contacts;

        Therapeutic_Area__c area = new Therapeutic_Area__c(Name = 'Test TA TD');
        insert area;

        Clinical_Trial_Profile__c study = new Clinical_Trial_Profile__c(
            Protocol_ID__c = 'CTP1',
            Override_Recruitment_Status__c = 'Actively Enrolling',
            //NCT_Number__c = 'NCT99999999',
            Link_to_Pre_screening__c = 'some link',
            //Terms_And_Conditions_ID__c = studyTC.Id,
            Study_Title__c = 'Some Title',
            Study_Code_Name__c = 'Some Code Name',
            Suppress_Participant_Emails__c = false,
            Therapeutic_Area__c = area.Id,
            Synch_with_TMDH__c = true,
            Include_in_RP_trial_search__c = true,
            Patient_Portal_Enabled__c = true,
            Shareback_Settings_On_Participant_Level__c = true,
            Shareback_Availability_Timing__c = 1,
            Visit_Data_Shareback__c = true,
            Visit_Schedule_Is_Available__c = true,
            Tasks_Are_Available__c = true,
            Study_Documents_Are_Available__c = true,
            Video_And_Articles_Are_Available__c = true,
            Travel_Vendor_Is_Available__c = true,
            Relevant_Links_Are_Available__c = true,
            Sponsor_Pays_for_Referral_Activity__c = 'Yes',
            CommunityTemplate__c = CommunityTemplateService.TEMPLATE_DEFAULT,
            Logged_Out_Days_Notification__c = 1
        );
        insert study;

        Study_Site__c studySite = new Study_Site__c(
            Principal_Investigator__c = piContact.Id,
            Clinical_Trial_Profile__c = study.Id,
            Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
            Site__c = studySiteAccount.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false,
            Study_Site_Number__c = 'SS1',
            Billable_Code_CRM_Number__c = 'Test_Billable_Code'
        );
        insert studySite;
        studySite.Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED;
        update studySite;

        List<Participant__c> partList = new List<Participant__c>();
        List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();

        Participant__c participant = new Participant__c(
            First_Name__c = 'ParticipantTD',
            Last_Name__c = 'ParticipantTD',
            Phone__c = '55313535',
            Email__c = 'part1@email.com',
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            Adult__c = true,
            Site__c= piAccount.Id
        );
        Participant__c participant2 = new Participant__c(
            First_Name__c = 'ParticipantTD1',
            Last_Name__c = 'ParticipantTD1',
            Phone__c = '55313538',
            Email__c = 'part2@email.com',
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            Adult__c = true,
            Site__c= piAccount.Id
        );

        partList.add(participant);
        partList.add(participant2);
       
        insert (partList);
        Participant_Enrollment__c pe = new Participant_Enrollment__c(
            //HCP__c = hcpEnrollment.Id,
            Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
            Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
            PI_Contact__c = piContact.Id,
            Study_Site__c = studySite.Id,
            Patient_ID__c = 'SomePatientId1',
            Referral_Source__c = 'HCP',
            Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_RECEIVED,
            Participant__c = participant.Id,
            Screening_ID__c = 'PESCR1'
        );

        peList.add(pe);
        Participant_Enrollment__c pe2 = new Participant_Enrollment__c(
            //HCP__c = hcpEnrollment.Id,
            Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
            Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
            PI_Contact__c = piContact.Id,
            Study_Site__c = studySite.Id,
            Patient_ID__c = 'SomePatientId2',
            Referral_Source__c = 'PI',
            Initial_visit_scheduled_date__c = Date.today(),
            //Initial_visit_occurred_flag__c = true,
            Participant_Status__c = DashboardRemoteNew.PE_STATUS_SUCCESSFULLY_CONTACTED,
            Participant__c = participant2.Id,
            Screening_ID__c = 'PESCR2'
        );

        peList.add(pe2);
        Test.startTest();
        insert peList;
        Test.stopTest();
       
        Batch_UpdatePERParticipantKey  b = new Batch_UpdatePERParticipantKey();
        Database.executeBatch(b);
       
    }
}