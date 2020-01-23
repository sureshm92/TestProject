/**
 * Created by Leonid Bartenev
 */

@IsTest
public class TestData {
    
    public User piUser;
    public User hcpUser;
    public User participantUser;
    public Participant__c referral;
    public Participant__c participant;
    public Clinical_Trial_Profile__c ctp;
    public Study_Site__c ss;
    public Participant_Study_Enrollment__c pse; //ONLY FOR DEPLOY
    public Participant_Enrollment__c pe;
    public HCP_Enrollment__c hcpEnrollment;
    private static Contact hcpContact;
    private static Terms_And_Conditions__c studyTC;
    public TestData(){
        participant = [
                SELECT Id, Name
                FROM Participant__c
                WHERE Last_Name__c = 'ParticipantTD'
        ];
        List<String> contactLastNames = new List<String>{
                participant.Name,
                'HCPTD',
                'PITD'
        };
        List<User> users = [
                SELECT Id, ContactId, LastName
                FROM User
                WHERE Contact.LastName IN: contactLastNames
        ];
        for(User user : users){
            if(user.LastName == 'PITD') piUser = user;
            if(user.LastName == 'HCPTD') hcpUser = user;
            if(user.LastName == participant.Name) participantUser = user;
        }
        ctp = [
                SELECT Id, Therapeutic_Area__c,
                        Patient_Portal_Enabled__c,
                        Terms_and_Conditions__c
                FROM Clinical_Trial_Profile__c
                WHERE NCT_Number__c = 'NCT99999999'
        ];
        ss = [
                SELECT Id, Visit_Results_Sharing__c,
                        Principal_Investigator__c
                FROM Study_Site__c
                WHERE Clinical_Trial_Profile__c =: ctp.Id
        ];
        pe = [
                SELECT Id,
                        Participant_Contact__c,
                        Participant_Contact__r.Visit_Results_Opt_In__c,
                        Screening_ID__c
                FROM Participant_Enrollment__c
                WHERE Participant__c =: participant.Id
        ];
        hcpEnrollment = [
                SELECT Id
                FROM HCP_Enrollment__c
                WHERE HCP_Contact__r.LastName = 'HCPTD' LIMIT 1
        ];
    }

    public void createSSTravelVendors(){
        TravelVendor__c tv = new TravelVendor__c(Name = 'Test TV', Link_Vendor__c = 'Some link');
        insert(tv);
        insert new TravelVendorSettings__c(Study_Site__c = ss.Id, TravelVendor__c = tv.Id);
    }

    public void updatePEStatusEnrollmentSuccess(){
        pe.Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS;
        update pe;
    }

    /**
     * Fill Enrolled_Date__c on PE
     * @param status some of PEStatusState
     */
    public void updatePEStatusThroughHistory(String status) {
        Participant_Enrollment_Status_History__c history = new Participant_Enrollment_Status_History__c(
                Date__c = Datetime.now(),
                Status__c = status,
                ParticipantEnrollment__c = pe.Id
        );
        insert history;
    }
    
    public static void loadTestData(){
        TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
        
        List<Terms_And_Conditions__c> tcList = new List<Terms_And_Conditions__c>();
        Terms_And_Conditions__c portalTC = new Terms_And_Conditions__c(
                Active__c = true
        );
        tcList.add(portalTC);
    
        studyTC = new Terms_And_Conditions__c();
        tcList.add(studyTC);
        insert tcList;
    
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
                FirstName = 'PITD',
                LastName = 'PITD',
                Email = 'pi@emil.com',
                AccountId = piAccount.Id
        );
        contacts.add(piContact);

        hcpContact = new Contact(
                FirstName = 'HCPTD',
                LastName = 'HCPTD',
                Email = 'hcp@emil.com',
                AccountId = hcpAccount.Id,
                MailingLatitude = 40.766594,
                MailingLongitude = -73.991509
        );
        contacts.add(hcpContact);
        insert contacts;
        
        Therapeutic_Area__c area = new Therapeutic_Area__c(Name = 'Test TA TD');
        insert area;
    
        Clinical_Trial_Profile__c study = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'CTP1',
                Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = 'NCT99999999',
                Link_to_Pre_screening__c = 'some link',
                Terms_And_Conditions_ID__c = studyTC.Id,
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
                Relevant_Links_Are_Available__c = true
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
                Suppress_Participant_Emails__c = false,
                Study_Site_Number__c = 'SS1'
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
        
    
        Participant__c participant = new Participant__c(
                First_Name__c = 'ParticipantTD',
                Last_Name__c = 'ParticipantTD',
                Phone__c = '55313535',
                Email__c = 'part1@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL',
                Adult__c = true
        );
        insert participant;
        Participant_Enrollment__c pe = new Participant_Enrollment__c(
                HCP__c = hcpEnrollment.Id,
                Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
                Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
                PI_Contact__c = piContact.Id,
                Study_Site__c = studySite.Id,
                Patient_ID__c = 'SomePatientId1',
                Referral_Source__c = 'HCP',
                Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_REFERRAL_SENT_TO_PI,
                Participant__c = participant.Id,
                Screening_ID__c = 'PESCR1'
        );
        insert pe;
        
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

        Participant_Enrollment__c peForContactUpdate = [SELECT Id, Participant_Contact__c FROM Participant_Enrollment__c WHERE Id =: pe.Id];
        Contact contactForUpdate = [SELECT Id, Current_Participant_Enrollment__c FROM Contact WHERE Id =: peForContactUpdate.Participant_Contact__c];
        contactForUpdate.Current_Participant_Enrollment__c = pe.Id;
        update contactForUpdate;

    }

    public static void createTCAcceptance() {
        User hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];

        Terms_And_Conditions_Acceptance__c tc_acceptance = new Terms_And_Conditions_Acceptance__c(
                User__c = hcpUser.Id,
                Terms_And_Conditions__c = studyTC.Id
        );
        insert tc_acceptance;
    }

}
