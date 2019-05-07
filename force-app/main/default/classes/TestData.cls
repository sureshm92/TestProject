/**
 * Created by Leonid Bartenev
 */

@IsTest
public class TestData {
    
    User piUser;
    User hcpUser;
    User referralUser;
    User participantUser;
    Participant__c referral;
    Participant__c participant;
    
    public TestData(){
        referral = [SELECT Id, Name FROM Participant__c WHERE Last_Name__c = 'Referral'];
        participant = [SELECT Id, Name FROM Participant__c WHERE Last_Name__c = 'Participant'];
        referralUser = [SELECT Id FROM User WHERE Contact.LastName = :referral.Name];
        participantUser = [SELECT Id FROM User WHERE Contact.LastName = :participant.Name];
        hcpUser = [SELECT Id FROM User WHERE Contact.LastName = 'HCP'];
        piUser = [SELECT Id FROM User WHERE Contact.LastName = 'PI'];
    }
    
    
    public static void loadTestData(){
        Terms_And_Conditions__c portalTC = new Terms_And_Conditions__c(
                Active__c = true
        );
        insert portalTC;
    
        Terms_And_Conditions__c studyTC = new Terms_And_Conditions__c();
        insert studyTC;
    
        Account participantsAccount = new Account(
                Name = 'Participant'
        );
        insert participantsAccount;
    
        Account piAccount = new Account(
                Name = 'PI Account'
        );
        insert piAccount;
    
        Account hcpAccount = new Account(
                Name = 'HCP Account'
        );
        insert hcpAccount;
    
        Account delegateAccount = new Account(
                Name = CommunityService.COMMUNITY_DELEGATE_ACCOUNT_NAME
        );
        insert delegateAccount;
    
        Account studySiteAccount = new Account(
                Name = 'Study Site Account',
                BillingLatitude = 41.766594,
                BillingLongitude = -74.991509
        );
        insert studySiteAccount;
    
        Contact piContact = new Contact(
                FirstName = 'PI',
                LastName = 'PI',
                Email = 'pi@emil.com',
                AccountId = piAccount.Id
        );
        insert piContact;
    
        Contact piDelegateContact = new Contact(
                FirstName = 'PI_Delegate',
                LastName = 'PI_Delegate',
                Email = 'pi_delegate@emil.com',
                AccountId = piAccount.Id,
                userCommunityMode__c = 'PI'
        );
        insert piDelegateContact;
    
        Contact hcpContact = new Contact(
                FirstName = 'HCP',
                LastName = 'HCP',
                Email = 'hcp@emil.com',
                AccountId = hcpAccount.Id,
                MailingLatitude = 40.766594,
                MailingLongitude = -73.991509
        );
        insert hcpContact;
    
        Contact hcpDelegateContact = new Contact(
                FirstName = 'HCP_Delegate',
                LastName = 'HCP_Delegate',
                Email = 'hcp_delegate@emil.com',
                AccountId = hcpAccount.Id
        );
        insert hcpDelegateContact;
        
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
                Participating_in_Digital_Recruitment__c = 'YES',
                Participating_in_Rocket_Referral__c = 'YES'
        );
        insert study;
    
        List<PicklistEntry> pleList = Translation__c.Language__c.getDescribe().getPicklistValues();
        Translation__c studyTranslation = new Translation__c(
                Language__c = pleList[0].value,
                Record_Id__c = study.Id,
                Field_Name__c = 'Study_Title__c',
                Value__c = 'Some translated value'
        );
        insert studyTranslation;
    
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
    
        Site_Staff__c siteStaff = new Site_Staff__c(
                Site_Contact__c = piDelegateContact.Id,
                Delegate_Level__c = DelegateService.DELEGATE_LEVEL_1,
                Study_Site__c = studySite.Id
        );
        insert siteStaff;
    
        Referring_HCP_Staff__c referringHcpStaff = new Referring_HCP_Staff__c(
                Contact__c = hcpDelegateContact.Id,
                Delegate_Level__c = DelegateService.DELEGATE_LEVEL_1,
                HCP_Enrollment__c = hcpEnrollment.Id
        );
        insert referringHcpStaff;
    
        Participant_Enrollment__c mrrPE = new Participant_Enrollment__c(
                HCP__c = hcpEnrollment.Id,
                Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
                Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PENDING,
                PI_Contact__c = piContact.Id,
                Study_Site__c = studySite.Id,
                Patient_ID__c = 'SomePatienntId',
                Referral_Source__c = 'HCP'
        );
        insert mrrPE;
    
        Participant__c participant = new Participant__c(
                First_Name__c = 'Referral',
                Last_Name__c = 'Referral',
                Phone__c = '55313535',
                Email__c = 'part1@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL'
        );
        insert participant;
        Participant_Enrollment__c passedMrrPE = new Participant_Enrollment__c(
                HCP__c = hcpEnrollment.Id,
                Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
                Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
                PI_Contact__c = piContact.Id,
                Study_Site__c = studySite.Id,
                Patient_ID__c = 'SomePatientId1',
                Referral_Source__c = 'HCP',
                Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_REFERRAL_SENT_TO_PI,
                Participant__c = participant.Id
        );
        insert passedMrrPE;
    
        participant = new Participant__c(
                First_Name__c = 'Participant',
                Last_Name__c = 'Participant',
                Phone__c = '13412412',
                Email__c = 'part2@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL'
        );
        insert participant;
        Participant_Enrollment__c pe2 = new Participant_Enrollment__c(
                HCP__c = hcpEnrollment.Id,
                Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
                Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
                PI_Contact__c = piContact.Id,
                Study_Site__c = studySite.Id,
                Patient_ID__c = 'SomePatientId2',
                Referral_Source__c = 'HCP',
                Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_REFERRAL_SENT_TO_PI,
                Participant__c = participant.Id
        );
        insert pe2;
        pe2.Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS;
        update pe2;
    
        Referral_Network__c referralNetwork = new Referral_Network__c(
                Name = 'Test Referral Network'
        );
        insert referralNetwork;
    
        Contact_Referral_Network__c contactReferralNetwork = new Contact_Referral_Network__c(
                ContactId__c = hcpContact.Id,
                ReferralNetworkId__c = referralNetwork.Id
        );
        insert contactReferralNetwork;
    
        Contact_Therapeutic_Area__c contactTherapeuticArea = new Contact_Therapeutic_Area__c(
                ContactId__c = hcpContact.Id,
                TherapeuticAreaId__c = area.Id
        );
        insert contactTherapeuticArea;
    
        User hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        User piUser = [SELECT Id FROM User WHERE ContactId = :piContact.Id];
    
        Terms_And_Conditions_Acceptance__c tc_acceptance = new Terms_And_Conditions_Acceptance__c(
                User__c = hcpUser.Id,
                Terms_And_Conditions__c = studyTC.Id
        );
        insert tc_acceptance;
    }

}