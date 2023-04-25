/**
 * Created by Leonid Bartenev testing
 */

@IsTest
public class TestData {
    public User piUser;
    public User hcpUser;
    public User participantUser;
    public User hcpDelUser;
    public User piDelUser;
    public User ccUser;
    public Participant__c referral;
    public Participant__c participant;
    public Clinical_Trial_Profile__c ctp;
    public Study_Site__c ss;
    public Participant_Study_Enrollment__c pse; //ONLY FOR DEPLOY
    public Participant_Enrollment__c pe;
    public HCP_Enrollment__c hcpEnrollment;
    public Contact piContact;
    public Contact piDelegateContact;
    private static Contact hcpContact;
    private static Terms_And_Conditions__c studyTC;
    private static List<String> necessaryTriggersForLoadTestData = new List<String>(); // these triggers are necessary for correct work of loadTestData()
    private static List<String> necessaryTriggersForMostTests = new List<String>(); // these triggers are necessary for correct work of almost all tests

    public TestData() {
        
        participant = [
            SELECT
                Id,
                Name,
                First_Name__c,
                Last_Name__c,
                Email__c,
                Status__c,
                Balance__c,
                Contact__c,
                Mailing_Country_Code__c,
                Mailing_Country__c,
                Contact__r.AccountId
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];

        List<String> contactLastNames = new List<String>{
            participant.Name,
            'HCPTD',
            'PITD',
            'HCPDelTD',
            'PIDelTD',
            'CCID'
        };
        List<User> users = [
            SELECT Id, ContactId, LastName
            FROM User
            WHERE Contact.LastName IN :contactLastNames
        ];
        for (User user : users) {
            if (user.LastName == 'PITD')
                piUser = user;
            if (user.LastName == 'HCPTD')
                hcpUser = user;
            if (user.LastName == 'PIDelTD')
                piDelUser = user;
            if (user.LastName == 'HCPDelTD')
                hcpDelUser = user;
            if (user.LastName == participant.Name) 
                participantUser = user;
            if (user.LastName == 'CCID')
                ccUser = user;
        }
        ctp = [
            SELECT
                Id,
                Therapeutic_Area__c,
                Study_Code_Name__c,
                Study_Title__c,
                Protocol_ID__c,
                Patient_Portal_Enabled__c,
                Terms_and_Conditions__c,
                Initial_Visit_Required__c,
                Participant_Workflow_Final_Step__c,
                Final_Consent_Required__c,
                Enable_for_Call_Center_Support__c,
                Link_to_Medical_Record_Review__c,
                Link_to_Pre_screening__c
            FROM Clinical_Trial_Profile__c
            WHERE NCT_Number__c = 'NCT99999999'
        ];
        ss = [
            SELECT
                Id,
                Visit_Results_Sharing__c,
                Name,
                Principal_Investigator__c,
                Enable_for_Call_Center_Support__c,
                Clinical_Trial_Profile__c
            FROM Study_Site__c
            WHERE Clinical_Trial_Profile__c = :ctp.Id
        ];
        pe = [
            SELECT
                Id,
                Name,
                External_Key__c,
                Participant_Contact__c,
                Participant_Status__c,
                Participant_Contact__r.Visit_Results_OptIn__c,
                Clinical_Trial_Profile__r.Shareback_Availability_Timing__c,
                Initial_visit_scheduled_date__c,
                Initial_visit_occurred_date__c,
                Initial_visit_scheduled_time__c,
                Initial_visit_occurred_flag__c,
                Initial_visit_scheduled_flag__c,
                Screening_ID__c,
                Participant__c,
                Medical_Record_Review_Completed_Date__c,
                Study_Site__r.Principal_Investigator__c,
                Study_Site__r.Principal_Investigator__r.Name,
                Study_Site__r.Principal_Investigator__r.Title,
                Participant__r.Mailing_Country_Code__c,
                Participant__r.Mailing_Country__c,
                Participant__r.Mailing_Zip_Postal_Code__c,
            	Participant__r.Mailing_State__c
            FROM Participant_Enrollment__c
            WHERE Participant__c = :participant.Id
        ];
        hcpEnrollment = [
            SELECT
                Id,
                Orientation_Date__c,
                HCP_Contact__c,
                Study_Site__c,
                Study_Site__r.Principal_Investigator__c,
                HCP_Contact__r.AccountId,
                Study_Site__r.Clinical_Trial_Profile__c
            FROM HCP_Enrollment__c
            WHERE HCP_Contact__r.LastName = 'HCPTD'
            LIMIT 1
        ];
        List<String> emailList = new List<String>{'pi@emil.com','pi_delegate@emil.com'};
        List<Contact> contactList = [SELECT Id, Name,Email FROM Contact WHERE Email IN: emailList LIMIT 2 ];
        for(Contact con:contactList) {
            if(con.email == 'pi@emil.com') {
                piContact = con;
            } else {
                piDelegateContact = con;
            }
        }
    }

    public User createPatientDelegate() {
        Contact delegate = new Contact(
            FirstName = 'Patient',
            LastName = 'Delegate',
            Email = 'jsmith@somemail.com',
            AccountId = participant.Contact__r.AccountId,
            Current_Participant_Enrollment__c = pe.Id,
            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
            userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
            UserCommunityIsDelegate__c = true
        );
        insert delegate;
        Participant__c p = new Participant__c(
            First_Name__c = 'Patient',
            Last_Name__c = 'Delegate',
            Contact__c = delegate.Id
        );
        insert p;

        Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = delegate.Id,
            Contact__r = delegate,
            Participant__c = participant.Id,
            Participant__r = participant
        );
        insert patientDelegate;

        User delegateUser = CommunityService.createUser(delegate, null, null, null);
        return delegateUser;
    }

    public User createDelegateData() {
        Contact delegatecontact = new Contact(
            FirstName = 'Joy',
            LastName = 'JoyDad',
            Email = 'Joypatient@somemail.com',
            AccountId = participant.Contact__r.AccountId,
            Current_Participant_Enrollment__c = pe.Id,
            userCommunityMode__c = CommunityService.USER_MODE_PI,
            userCommunytyType__c = CommunityService.USER_MODE_PI,
            UserCommunityIsDelegate__c = true
        );
        insert delegatecontact;
        Participant__c p = new Participant__c(
            First_Name__c = 'Joy',
            Last_Name__c = 'JoyDad',
            Email__c = 'Joypatient@somemail.com',
            Contact__c = delegatecontact.Id
        );
        insert p;

        Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = delegatecontact.Id,
            Contact__r = delegatecontact,
            Participant__c = p.Id,
            Participant__r = p
        );
        insert patientDelegate;

        User PatientUser = CommunityService.createUser(delegatecontact, null, null, null);
        return PatientUser;
    }

    public void createSSTravelVendors() {
        TravelVendor__c tv = new TravelVendor__c(Name = 'Test TV', Link_Vendor__c = 'Some link');
        insert (tv);
        insert new TravelVendorSettings__c(Study_Site__c = ss.Id, TravelVendor__c = tv.Id);
    }

    public void updatePEStatusEnrollmentSuccess() {
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

    /**
       loadTestData() is suitable for most cases (almost all triggers are off)

       @param List<String> externalExecuteTriggerNames - The list of triggers' names you need to execute additionally.

     */
    public static void loadTestData() {
        loadTestData(true, null);
    }

    public static void loadTestData(Boolean bypass, List<String> externalExecuteTriggerNames) {
        if (bypass)
            bypassTriggersNew(externalExecuteTriggerNames);
            
            List<Terms_And_Conditions__c> tcList = new List<Terms_And_Conditions__c>();
            Terms_And_Conditions__c ppTc = new Terms_And_Conditions__c(
                Active__c = true,
                Community_Name__c = 'IQVIA Referral Hub',
                Language__c = 'en_US',
                Last_Updated_on__c = 'July 10, 2020',
                Policy_Headers__c = 'Test Header 1',
                T_C_Text__c = '<p><b style="font-size: 12pt; font-family: Arial, sans-serif; color: rgb(0, 0, 0);">PRIVACY POLICY</b></p>',
                T_C_Type__c = 'Privacy Policy'
            );
            tcList.add(ppTc);
            
            studyTC = new Terms_And_Conditions__c();
            tcList.add(studyTC);
            insert tcList;
            
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
                AccountId = piAccount.Id,
                userCommunytyType__c = 'PI'
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
            contacts.add(hcpContact);
            
            Contact hcpDelegateContact = new Contact(
                FirstName = 'HCPDelTD',
                LastName = 'HCPDelTD',
                Email = 'hcp_delegate@emil.com',
                AccountId = hcpAccount.Id
            );
            contacts.add(hcpDelegateContact);
            
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
                Relevant_Links_Are_Available__c = true,
                Sponsor_Pays_for_Referral_Activity__c = 'Yes',
                CommunityTemplate__c = CommunityTemplateService.TEMPLATE_DEFAULT,
                Logged_Out_Days_Notification__c = 1,
                Enable_for_Call_Center_Support__c = true
            );
            insert study;
            
            List<PicklistEntry> pleList = Translation__c.Language__c.getDescribe().getPicklistValues();
            String langCode;
            for (PicklistEntry ple : pleList) {
                langCode = ple.getValue();
                if (TranslateHelper.isLanguageSupported(ple.getValue()))
                    break;
            }
            Translation__c studyTranslation = new Translation__c(
                Language__c = langCode,
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
                Study_Site_Number__c = 'SS1',
                Billable_Code_CRM_Number__c = 'Test_Billable_Code',
                Enable_for_Call_Center_Support__c = true
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
            
            RP_Delegate_Relationship__c rpDelegate = new RP_Delegate_Relationship__c(
                Referring_Provider__c = hcpDelegateContact.Id,
                Delegate_Access_Level__c = DelegateService.DELEGATE_LEVEL_1,
                Delegate__c = hcpContact.Id
            );
            insert rpDelegate;
            
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
                Site__c = piAccount.Id
            );
            Participant__c participant2 = new Participant__c(
                First_Name__c = 'ParticipantTD1',
                Last_Name__c = 'ParticipantTD1',
                Phone__c = '55313538',
                Email__c = 'part2@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL',
                Adult__c = true,
                Site__c = piAccount.Id
            );
            
            Participant__c participant3 = new Participant__c(
                First_Name__c = 'ParticipantTD3',
                Last_Name__c = 'ParticipantTD3',
                Phone__c = '55313530',
                Email__c = 'part3@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL',
                Adult__c = true,
                Site__c = piAccount.Id
            );
            
            Participant__c participant4 = new Participant__c(
                First_Name__c = 'ParticipantTD4',
                Last_Name__c = 'ParticipantTD4',
                Phone__c = '55313538',
                Email__c = 'part4@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL',
                Adult__c = true,
                Site__c = piAccount.Id
            );
            
            Participant__c participant5 = new Participant__c(
                First_Name__c = 'ParticipantTD5',
                Last_Name__c = 'ParticipantTD5',
                Phone__c = '55313535',
                Email__c = 'part5@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL',
                Adult__c = true,
                Site__c = piAccount.Id
            );
            
            Participant__c participant6 = new Participant__c(
                First_Name__c = 'ParticipantTD6',
                Last_Name__c = 'ParticipantTD6',
                Phone__c = '55313536',
                Email__c = 'part6@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL',
                Adult__c = true,
                Site__c = piAccount.Id
            );
            
            partList.add(participant);
            partList.add(participant2);
            partList.add(participant3);
            partList.add(participant4);
            partList.add(participant5);
            partList.add(participant6);
            
            insert (partList);
            Participant_Enrollment__c pe = new Participant_Enrollment__c(
                HCP__c = hcpEnrollment.Id,
                Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
                Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
                PI_Contact__c = piContact.Id,
                Study_Site__c = studySite.Id,
                Patient_ID__c = 'SomePatientId1',
                Referral_Source__c = 'HCP',
                Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_RECEIVED,
                Participant__c = participant.Id,
                Screening_ID__c = 'PESCR1',
                Invited_To_PP_Date__c = system.now(),
                Participant_Status_Last_Changed_Date__c=system.now()
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
                Screening_ID__c = 'PESCR2',
                Participant_Status_Last_Changed_Date__c=system.now()
            );
            
            peList.add(pe2);
            
            Participant_Enrollment__c pe3 = new Participant_Enrollment__c(
                //HCP__c = hcpEnrollment.Id,
                Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
                Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
                PI_Contact__c = piContact.Id,
                Study_Site__c = studySite.Id,
                Patient_ID__c = 'SomePatientId3',
                Referral_Source__c = 'PI',
                //Initial_visit_scheduled_date__c = Date.today()+1,
                Initial_visit_occurred_flag__c = true,
                Participant_Status__c = DashboardRemoteNew.STATUS_SCREENING_IN_PROGRESS,
                Participant__c = participant3.Id,
                Screening_ID__c = 'PESCR3',
                Participant_Status_Last_Changed_Date__c=system.now()
            );
            
            peList.add(pe3);
            
            Participant_Enrollment__c pe4 = new Participant_Enrollment__c(
                //HCP__c = hcpEnrollment.Id,
                //Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
                //Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
                PI_Contact__c = piContact.Id,
                Study_Site__c = studySite.Id,
                Patient_ID__c = 'SomePatientId4',
                Referral_Source__c = 'PI',
                //Initial_visit_scheduled_date__c = Date.today()-1,
                //Initial_visit_occurred_flag__c = true,
                Participant_Status__c = DashboardRemoteNew.STATUS_SCREENING_IN_PROGRESS,
                Participant__c = participant4.Id,
                Screening_ID__c = 'PESCR4',
                Participant_Status_Last_Changed_Date__c=system.now()
            );
            peList.add(pe4);
            
            Participant_Enrollment__c pe5 = new Participant_Enrollment__c(
                //HCP__c = hcpEnrollment.Id,
                Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
                Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
                PI_Contact__c = piContact.Id,
                Study_Site__c = studySite.Id,
                Patient_ID__c = 'SomePatientId5',
                Referral_Source__c = 'PI',
                Initial_visit_scheduled_date__c = Date.today() - 1,
                Initial_visit_occurred_flag__c = true,
                Participant_Status__c = DashboardRemoteNew.STATUS_UNABLE_TO_SCREEN,
                Participant__c = participant5.Id,
                Screening_ID__c = 'PESCR5',
                Participant_Status_Last_Changed_Date__c=system.now()
            );
            peList.add(pe5);
            
            Participant_Enrollment__c pe6 = new Participant_Enrollment__c(
                //HCP__c = hcpEnrollment.Id,
                Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
                Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
                PI_Contact__c = piContact.Id,
                Study_Site__c = studySite.Id,
                Patient_ID__c = 'SomePatientId6',
                Referral_Source__c = 'PI',
                Initial_visit_scheduled_date__c = Date.today(),
                Initial_visit_occurred_flag__c = true,
                Participant_Status__c = DashboardRemoteNew.STATUS_SCREENING_PASSED,
                Participant__c = participant6.Id,
                Screening_ID__c = 'PESCR6',
                Participant_Status_Last_Changed_Date__c=system.now()
            );
            peList.add(pe6);
            insert peList;
            
            Participant_Enrollment_Status_History__c pesh = new Participant_Enrollment_Status_History__c();
            pesh.Date__c = Datetime.now();
            pesh.Status__c = ParticipantEnrollmentService.PART_STATUS_RECEIVED;
            pesh.Notes__c = peList[0].Last_Status_Changed_Notes__c;
            pesh.ParticipantEnrollment__c = peList[0].Id;
            insert pesh;
            
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
            
            Participant_Enrollment__c peForContactUpdate = [
                SELECT Id, Participant_Contact__c
                FROM Participant_Enrollment__c
                WHERE Id = :pe.Id
            ];
            Contact contactForUpdate = [
                SELECT Id, Current_Participant_Enrollment__c
                FROM Contact
                WHERE Id = :peForContactUpdate.Participant_Contact__c
            ];
            contactForUpdate.Current_Participant_Enrollment__c = pe.Id;
            contactForUpdate.Next_Notify_Date__c = Datetime.now().dateGmt();
            update contactForUpdate;
        }
        
        public static void runAllTriggers() {
            if (necessaryTriggersForLoadTestData.isEmpty())
                prepareTriggersLists();
            
            for (String name : necessaryTriggersForMostTests)
                TriggerHandlerExecutor.bypassHandler(Type.forName(name)); // bypass triggers that work in loadTestData()
            
            loadTestData(false, null);
        }

    private static void prepareTriggersLists() {
        necessaryTriggersForLoadTestData.add(
            'ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler'
        );
        necessaryTriggersForLoadTestData.add(
            'ParticipantTriggerHandler.CreateContactsForParticipantsHandler'
        );
        necessaryTriggersForMostTests.add(
            'HCPEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler'
        );
        necessaryTriggersForMostTests.add(
            'HCPEnrollmentTriggerHandler.CreateHCPUserOrSendNotificationHandler'
        );
        necessaryTriggersForMostTests.add(
            'ParticipantTriggerHandler.UpdatePEAndContactLastNameHandler'
        );
        necessaryTriggersForMostTests.add(
            'StudySiteTriggerHandler.CreatePIOrSendNotificationHandler'
        );
        necessaryTriggersForMostTests.add('StudySiteTriggerHandler.SwitchContactUserModeHandler');
        necessaryTriggersForMostTests.add(
            'ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler'
        );
        necessaryTriggersForMostTests.add('ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR');
        necessaryTriggersForMostTests.add(
            'ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandle'
        );
        necessaryTriggersForMostTests.add('ParticipantEnrollmentSHTriggerHandler.UpdatePEHandler');
        necessaryTriggersForMostTests.add(
            'ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler'
        );
    }
    private static void bypassTriggersNew(List<String> externalExecuteTriggerNames) {
        TriggerHandlerExecutor.bypassHandler(AlertTriggerHandler.ValidateFieldsHandler.class);
        TriggerHandlerExecutor.bypassHandler(CCStaffTriggerHandler.UpdateContactOnStatusChange.class);
        TriggerHandlerExecutor.bypassHandler(ClinicalTrialProfileTriggerHandler.UpdateClinicalTrialProfile.class);
        TriggerHandlerExecutor.bypassHandler(ClinicalTrialProfileTriggerHandler.manageBypassedFieldsForTMDH.class);
        TriggerHandlerExecutor.bypassHandler(CTPNotificationTriggerHandler.CreateNotificationHandler.class);
        TriggerHandlerExecutor.bypassHandler(ContactReferralNetworkTriggerHandler.SyncContactInterestedSites.class);
        TriggerHandlerExecutor.bypassHandler(ContactTherapeuticAreaTriggerHandler.SyncContactInterestedTopics.class);
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.UpdateParticipantAndUserEmailsOnEmailChangeHandler.class);
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.createNotificationsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.CreateUserForDelegateContactHandler.class);
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.SetShowTourDefaultHandler.class);
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.PopulateOverrideFields.class);
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.CreateUserForCCContactHandler.class);
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.UpdateParticipantDetailsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.UpdatePhoneNumberContactsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.ParticipantConsentUpdate.class);
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.UpdateConsentTimeStamps.class);
        TriggerHandlerExecutor.bypassHandler(ContentDocumentLinkTriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(ContentDocumentTriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(CTCTriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(EcoaTaskConfigTriggerHandler.MarkEcoaTaskCompleted.class);
        TriggerHandlerExecutor.bypassHandler(HCPEnrollmentTriggerHandler.DeleteStatusHistoryOnDeleteHandler.class);
        TriggerHandlerExecutor.bypassHandler(HCPEnrollmentTriggerHandler.SwitchContactUserModeHandler.class);
        TriggerHandlerExecutor.bypassHandler(HCPEnrollmentTriggerHandler.CreateStatusHistoryHandler.class);
        TriggerHandlerExecutor.bypassHandler(HCPEnrollmentTriggerHandler.CreateRecruitingHCPStaffModeHandler.class);
        TriggerHandlerExecutor.bypassHandler(HCPEnrollmentTriggerHandler.CheckReimbursableActivities.class);
        TriggerHandlerExecutor.bypassHandler(HCPEnrollmentTriggerHandler.SendNotificationForActivatedHCPEHandler.class);
        TriggerHandlerExecutor.bypassHandler(HCPEnrollmentTriggerHandler.SendNotificationForDeclinedHCPEHandler.class);
        TriggerHandlerExecutor.bypassHandler(IntegrationPatientTriggerHandler.UpdatePatientsHandler.class);
        TriggerHandlerExecutor.bypassHandler(IntegrationPatientReferralTriggerHandler.CheckRequiredFieldsAndUpsertParticipantAndPEHandler.class);
        TriggerHandlerExecutor.bypassHandler(IprEprTriggerHandler.CheckRequiredFieldsAndUpsertParticipantAndPEHandler.class);
        TriggerHandlerExecutor.bypassHandler(IntegrationSiteStaffTriggerHandler.CheckRequiredFieldsAndUpsertSiteStaff.class);
        TriggerHandlerExecutor.bypassHandler(IntegrationTrialMatchTriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(IntegrationVisitResultTriggerHandler.CheckProcessedRecordsHandler.class);
        TriggerHandlerExecutor.bypassHandler(IntegrationVisitTriggerHandler.CheckProcessedRecordsHandler.class);
        TriggerHandlerExecutor.bypassHandler(LLRHeventTriggerHandler.SendFOVtoAPI.class);
        TriggerHandlerExecutor.bypassHandler(MessageTriggerHandler.SendEmailHandler.class);
        TriggerHandlerExecutor.bypassHandler(NationalIdTriggerHandler.PrepareCityStateFieldsHandler.class);
        TriggerHandlerExecutor.bypassHandler(NotificationTriggerHandler.CheckFieldsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.UpdatePERReEngaged.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.CreateWelcomeToStudyAlertHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.UpdateLastChangedAdditionalNotes.class);
        TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class);
        TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.SendEmailIfSSWasChanged.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.createNotifications.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class);
        TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.CreateNotificationHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SendFOVtoAPI.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.UnenrollorCancelPer.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.UpdateParticipantInitialVisit.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateMissingStatuses.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.EcoaEvents.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.DefaultEcoaTask.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.UpdatePatientConsent.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.StudyConsentTimestamps.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantStudyEnrollmentTriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(PSETriggerHandler.SetDefaultFieldsBeforeUpsertHandler.class);
        TriggerHandlerExecutor.bypassHandler(PSETriggerHandler.ProcessStatusHistoryHandler.class);
        TriggerHandlerExecutor.bypassHandler(PSETriggerHandler.DeactivateDeceasedUsersHandler.class);
        TriggerHandlerExecutor.bypassHandler(PSETriggerHandler.CreateWelcomeToStudyAlertHandler.class);
        TriggerHandlerExecutor.bypassHandler(PSETriggerHandler.SendDropOutEmailHandler.class);
        TriggerHandlerExecutor.bypassHandler(PSETriggerHandler.CreateStatusBasedInvitations.class);
        TriggerHandlerExecutor.bypassHandler(PSETriggerHandler.CreateVisitsScheduleHandler.class);
        TriggerHandlerExecutor.bypassHandler(PSETriggerHandler.HideSurveyTasks.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.CheckDuplicatesHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.PrepareCityStateFieldsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdateContactDetailsFromParticipant.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.CheckBecomesAdultHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.ChangeUserEmailOnParticipantEmailChangeHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdateNameOnPE.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdateParticipantAge.class);
        TriggerHandlerExecutor.bypassHandler(PatientDelegateTriggerHandler.SetDefaultPatientDelegateStatusHandler.class);
        TriggerHandlerExecutor.bypassHandler(PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class);
        TriggerHandlerExecutor.bypassHandler(PatientDelegateTriggerHandler.CreateNewAssignmentNotification.class);
        TriggerHandlerExecutor.bypassHandler(PatientDelegateTriggerHandler.CreateReactivatedNotification.class);
        TriggerHandlerExecutor.bypassHandler(PatientDelegateTriggerHandler.CreatePrimaryDelegateForMinor.class);
        TriggerHandlerExecutor.bypassHandler(PatientVisitTriggerHandler.updateEcoaEvents.class);
        TriggerHandlerExecutor.bypassHandler(PSEStatusHistoryTriggerHandler.UpdatePSEStatusOnHistoryChangeHandler.class);
        TriggerHandlerExecutor.bypassHandler(RecurringTaskTriggerHandler.UpdateRecurringTaskonEndDateChange.class);
        TriggerHandlerExecutor.bypassHandler(ResourceTriggerHandler.ArticleResourceProcessor.class);
        TriggerHandlerExecutor.bypassHandler(ResStudyTriggerHandler.PlatformEventProcessor.class);
        TriggerHandlerExecutor.bypassHandler(ResStudyTriggerHandler.CertificateResourceProcessor.class);
        TriggerHandlerExecutor.bypassHandler(RPDelegateRelationshipTriggerHandler.DeactivateUserWhenLastDelegationRemovedHandler.class);
        TriggerHandlerExecutor.bypassHandler(SendResultTriggerHandler.updatewelcomeMsgflagsHandler.class);
        TriggerHandlerExecutor.bypassHandler(SiteStaffTriggerHandler.DuplicateSiteStaffHandler.class);
        TriggerHandlerExecutor.bypassHandler(SiteStaffTriggerHandler.DeactivateUserWhenLastDelegationRemovedHandler.class);
        TriggerHandlerExecutor.bypassHandler(SiteStaffTriggerHandler.RemoveConversationSharesHandler.class);
        TriggerHandlerExecutor.bypassHandler(SiteStaffTriggerHandler.AssignCommunitymodeAndTypeHandler.class);
        TriggerHandlerExecutor.bypassHandler(SMSDeliveryStatusTriggerHandler.processDeliveryReciptforSMS.class);
        TriggerHandlerExecutor.bypassHandler(SMSOptOutTriggerHandler.optOutSMS.class);
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.PrepareAdditionalFieldsHandler.class);
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.DeleteStatusHistoryOnDeleteHandler.class);
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.CreateStatusHistoryHandler.class);
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.CreateHCPEnrollmentsForRPInWhiteListHandler.class);
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.SetSuppressEmailsFieldAccordingToStudy.class);
        //TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.AssignCommunityPermissionsForUser.class);
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.SetEnableCCSupportFieldAccordingToStudy.class);
        TriggerHandlerExecutor.bypassHandler(TaskTriggerHandler.CheckTaskFieldsWithTaskCodeHandler.class);
        TriggerHandlerExecutor.bypassHandler(TaskTriggerHandler.SendImmediateEmailsForTaskCodeHandler.class);
        TriggerHandlerExecutor.bypassHandler(TelevisitAttendeeTriggerHandler.ManageAttendees.class);
        TriggerHandlerExecutor.bypassHandler(TelevisitAttendeeTriggerHandler.TelevisitEventTrigger.class);
        TriggerHandlerExecutor.bypassHandler(TelevisitAttendeeTriggerHandler.TelevisitAttendeeTrigger.class);
        TriggerHandlerExecutor.bypassHandler(TelevisitTriggerHandler.NotifyAttendees.class);
        TriggerHandlerExecutor.bypassHandler(TelevisitTriggerHandler.TelevisitEventTrigger.class);
        TriggerHandlerExecutor.bypassHandler(TelevisitTriggerHandler.TelevisitRescheduleTrigger.class);
        TriggerHandlerExecutor.bypassHandler(TermsAndConditionsTriggerHandler.ActivePortalFieldsHandler.class);
        TriggerHandlerExecutor.bypassHandler(TherapeuticAreaAssignmentTriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(TherapeuticAreaPatientTriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(TherapeuticAreaTriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(TranslationTriggerHandler.CheckFieldsConsistencyHandler.class);
        TriggerHandlerExecutor.bypassHandler(TravelVendorSettingsTriggerHandler.CreatePreEnrollmentVisits.class);
        TriggerHandlerExecutor.bypassHandler(TrialSurveyTriggerHandler.ExpireSurveyTaskAndInvitations.class);
        TriggerHandlerExecutor.bypassHandler(TrialSurveyTriggerHandler.UpdateTrialSurveyAndInvitations.class);
        //TriggerHandlerExecutor.bypassHandler(ECOASubjectsEventTriggerHandler.ECOACreateEvent.class);
        TriggerHandlerExecutor.bypassHandler(UserTriggerHandler.UpdateEmailOnRelatedContactsHandler.class);
        TriggerHandlerExecutor.bypassHandler(UserTriggerHandler.UpdateLanguageOnRelatedContactsHandler.class);
        TriggerHandlerExecutor.bypassHandler(UserTriggerHandler.CreateCompleteYourProfileTaskHandler.class);
        TriggerHandlerExecutor.bypassHandler(UserTriggerHandler.AssignCommunityPermissionSetToUserHandler.class);
        TriggerHandlerExecutor.bypassHandler(UserTriggerHandler.AssignPendingTasksHandler.class);
        TriggerHandlerExecutor.bypassHandler(VisitTriggerHandler.DeletePatientVisitOnVisitDeletionHandler.class);
        TriggerHandlerExecutor.bypassHandler(VisitTriggerHandler.InsertPatientVisitOnVisitInsertionHandler.class);
        TriggerHandlerExecutor.bypassHandler(VisitTriggerHandler.UpdateExistingPatientVisits.class);
    }
    private static void bypassTriggers(List<String> externalExecuteTriggerNames) {
        List<ApexTrigger> triggers = [SELECT Id, Name, Body FROM ApexTrigger];
        List<String> bypassTriggerNames = new List<String>();
        for (ApexTrigger apexTrigger : triggers) {
            List<String> codeStrings = String.valueOf(apexTrigger.Body).split(';');
            for (String codeString : codeStrings) {
                if (!codeString.contains('execute'))
                    continue;
                String open = 'execute(';
                String close = '.class';
                bypassTriggerNames.add(codeString.substringBetween(open, close));
            }
        }
       
        if (necessaryTriggersForLoadTestData.isEmpty())
            prepareTriggersLists();

        List<String> executeTriggerNames = new List<String>();
        executeTriggerNames.addAll(necessaryTriggersForLoadTestData);
        executeTriggerNames.addAll(necessaryTriggersForMostTests);

        if (externalExecuteTriggerNames != null && !externalExecuteTriggerNames.isEmpty()) {
            executeTriggerNames.addAll(externalExecuteTriggerNames);
        }
        for (String name : executeTriggerNames) {
            if (bypassTriggerNames.contains(name)) {
                bypassTriggerNames.remove(bypassTriggerNames.indexOf(name));
            }
        }
        try {
            for (String name : bypassTriggerNames) {            
                TriggerHandlerExecutor.bypassHandler(Type.forName(name));
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public static void createTCAcceptance() {
        User hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];

        Terms_And_Conditions_Acceptance__c tc_acceptance = new Terms_And_Conditions_Acceptance__c(
            User__c = hcpUser.Id,
            Terms_And_Conditions__c = studyTC.Id
        );
        insert tc_acceptance;
    }

    public static void createPIDelegateUser() {
        Contact delegateContact = [SELECT Id FROM Contact WHERE LastName = 'PIDelTD' LIMIT 1];
        ((CommunityService) ClassFactory.newInstance(CommunityService.class))
            .createPortalUsers(new Set<Id>{ delegateContact.Id });
    }

    public static void createHCPEWaitingAcceptance() {
        Account hcpAccount = [SELECT Id FROM Account WHERE Name = 'HCP Account' LIMIT 1];
        Contact hcpPAContact = new Contact(
            FirstName = 'HCPPATD',
            LastName = 'HCPPATD',
            Email = 'hcp_pending@emil.com',
            AccountId = hcpAccount.Id
        );
        insert hcpPAContact;
        Study_Site__c studySite = [
            SELECT Id
            FROM Study_Site__c
            WHERE Study_Site_Number__c = 'SS1'
            LIMIT 1
        ];
        HCP_Enrollment__c hcpEnrollment = new HCP_Enrollment__c(
            Study_Site__c = studySite.Id,
            HCP_Contact__c = hcpPAContact.Id,
            Status__c = HCPEnrollmentService.HCP_S_ACTIVATION_PENDING
        );
        insert hcpEnrollment;
    }

    public static void createIncentiveProgram() {
        Study_Site__c studySite = [
            SELECT Id, Clinical_Trial_Profile__c
            FROM Study_Site__c
            WHERE Study_Site_Number__c = 'SS1'
            LIMIT 1
        ];
        Incentive_Plan__c plan = new Incentive_Plan__c();
        plan.Plan_Name__c = 'Test IP1';
        plan.Clinical_Trial_Profile__c = studySite.Clinical_Trial_Profile__c;
        insert plan;
        Incentive_Plan_Task__c task = new Incentive_Plan_Task__c();
        task.Incentive_Task_Catalog__c = IncentiveTaskCatalog.INCENTIVE_TASK_PRE_SCREENING;
        task.Incentive_Plan__c = plan.Id;
        task.Enabled__c = true;
        task.IQVIA_Supported__c = true;
        task.Points__c = 15;
        insert task;
        Study_Incentive_Plan__c sip = new Study_Incentive_Plan__c();
        sip.Incentive_Plan__c = plan.Id;
        sip.Study_Site__c = studySite.Id;
        insert sip;
    }

    public static void createTelevisits() {
        List<Televisit__c> tVisits = new List<Televisit__c>{
            new Televisit__c(
                Duration__c = '30 minutes',
                Title__c = 'Visit 0',
                Visit_Date__c = Date.newInstance(2022, 4, 29),
                Start_Time__c = Time.newInstance(8, 0, 0, 0)
                //Visit_Date_Time__c  = ''
            ),
            new Televisit__c(
                Duration__c = '30 minutes',
                Title__c = 'Visit 1',
                Visit_Date__c = Date.newInstance(2022, 5, 10),
                Start_Time__c = Time.newInstance(8, 0, 0, 0)
                //Visit_Date_Time__c  = ''
            ),
            new Televisit__c(
                Duration__c = '30 minutes',
                Title__c = 'Visit 2',
                Visit_Date__c = Date.newInstance(2022, 5, 17),
                Start_Time__c = Time.newInstance(8, 0, 0, 0)
                //Visit_Date_Time__c  = ''
            )
        };
        insert tVisits;
    }

    public static void addAttendees(Id tvId, List<Id> contactIds) {
    }
}