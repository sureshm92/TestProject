/**
 * Created by Leonid Bartenev
 */

@IsTest
public class TestData {

    public User piUser;
    public User hcpUser;
    public User participantUser;
    public User hcpDelUser;
    public User piDelUser;
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
                SELECT Id, Name, First_Name__c, Last_Name__c, Email__c, Status__c, Balance__c, Contact__c, Contact__r.AccountId
                FROM Participant__c
                WHERE Last_Name__c = 'ParticipantTD'
        ];

        List<String> contactLastNames = new List<String>{
                participant.Name,
                'HCPTD',
                'PITD',
                'HCPDelTD',
                'PIDelTD'
        };
        List<User> users = [
                SELECT Id, ContactId, LastName
                FROM User
                WHERE Contact.LastName IN:contactLastNames
        ];
        for (User user : users) {
            if (user.LastName == 'PITD') piUser = user;
            if (user.LastName == 'HCPTD') hcpUser = user;
            if (user.LastName == 'PIDelTD') piDelUser = user;
            if (user.LastName == 'HCPDelTD') hcpDelUser = user;
            if (user.LastName == participant.Name) participantUser = user;
        }
        ctp = [
                SELECT Id, Therapeutic_Area__c,
                        Study_Code_Name__c,
                        Patient_Portal_Enabled__c,
                        Terms_and_Conditions__c,
                        Initial_Visit_Required__c,
                        Participant_Workflow_Final_Step__c,
                        Final_Consent_Required__c
                FROM Clinical_Trial_Profile__c
                WHERE NCT_Number__c = 'NCT99999999'
        ];
        ss = [
                SELECT Id, Visit_Results_Sharing__c, Name,
                        Principal_Investigator__c
                FROM Study_Site__c
                WHERE Clinical_Trial_Profile__c = :ctp.Id
        ];
        pe = [
                SELECT Id,
                        Participant_Contact__c,Participant_Status__c,
                        Participant_Contact__r.Visit_Results_Opt_In__c,
                        Initial_visit_scheduled_date__c,
                        Initial_visit_occurred_date__c,
                        Initial_visit_scheduled_time__c,
                        Initial_visit_occurred_flag__c,
                        Initial_visit_scheduled_flag__c,
                        Screening_ID__c, Medical_Record_Review_Completed_Date__c,
                        Study_Site__r.Principal_Investigator__c,
                        Study_Site__r.Principal_Investigator__r.Name,
                        Study_Site__r.Principal_Investigator__r.Title
                FROM Participant_Enrollment__c
                WHERE Participant__c = :participant.Id
        ];
        hcpEnrollment = [
                SELECT Id, Orientation_Date__c, HCP_Contact__c
                FROM HCP_Enrollment__c
                WHERE HCP_Contact__r.LastName = 'HCPTD'
                LIMIT 1
        ];
        piContact = [SELECT Id,Name FROM Contact WHERE Email = 'pi@emil.com' LIMIT 1];
        
        piDelegateContact = [SELECT Id,Name FROM Contact WHERE Email = 'pi_delegate@emil.com' LIMIT 1];
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

    public void createSSTravelVendors() {
        TravelVendor__c tv = new TravelVendor__c(Name = 'Test TV', Link_Vendor__c = 'Some link');
        insert(tv);
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
        if(bypass) bypassTriggers(externalExecuteTriggerNames);

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
                Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
        );
        accounts.add(participantsAccount);

        Account piAccount = new Account(
                Name = 'PI Account',
                BillingCountry = 'United States'
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
                Logged_Out_Days_Notification__c = 1
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
                Study_Site_Number__c = 'SS1',
                Billable_Code_CRM_Number__c = 'Test_Billable_Code'
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
                Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_RECEIVED,
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

        Participant_Enrollment__c peForContactUpdate = [SELECT Id, Participant_Contact__c FROM Participant_Enrollment__c WHERE Id = :pe.Id];
        Contact contactForUpdate = [SELECT Id, Current_Participant_Enrollment__c FROM Contact WHERE Id = :peForContactUpdate.Participant_Contact__c];
        contactForUpdate.Current_Participant_Enrollment__c = pe.Id;
        contactForUpdate.Next_Notify_Date__c = Datetime.now().dateGmt();
        update contactForUpdate;
    }

    @IsTest
    static void runAllTriggers() {
        if (necessaryTriggersForLoadTestData.isEmpty()) prepareTriggersLists();

        for (String name : necessaryTriggersForMostTests) TriggerHandlerExecutor.bypassHandler(Type.forName(name)); // bypass triggers that work in loadTestData()

        loadTestData(false, null);
    }

    private static void prepareTriggersLists() {
        necessaryTriggersForLoadTestData.add('ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler');
        necessaryTriggersForLoadTestData.add('ParticipantTriggerHandler.CreateContactsForParticipantsHandler');

        necessaryTriggersForMostTests.add('HCPEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler');
        necessaryTriggersForMostTests.add('HCPEnrollmentTriggerHandler.CreateHCPUserOrSendNotificationHandler');
        necessaryTriggersForMostTests.add('ParticipantTriggerHandler.UpdatePEAndContactLastNameHandler');
        necessaryTriggersForMostTests.add('StudySiteTriggerHandler.CreatePIOrSendNotificationHandler');
        necessaryTriggersForMostTests.add('StudySiteTriggerHandler.SwitchContactUserModeHandler');
        necessaryTriggersForMostTests.add('ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler');
        necessaryTriggersForMostTests.add('ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR');
        necessaryTriggersForMostTests.add('ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandle');
        necessaryTriggersForMostTests.add('ParticipantEnrollmentSHTriggerHandler.UpdatePEHandler');
        necessaryTriggersForMostTests.add('ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler');

    }

    private static void bypassTriggers(List<String> externalExecuteTriggerNames) {
        List<ApexTrigger> triggers = [
                SELECT Id,
                        Name,
                        Body
                FROM ApexTrigger
        ];
        List<String> bypassTriggerNames = new List<String>();
        for (ApexTrigger apexTrigger : triggers) {
            List<String> codeStrings = String.valueOf(apexTrigger.Body).split(';');
            for (String codeString : codeStrings) {
                if (!codeString.contains('execute')) continue;
                String open = 'execute(';
                String close = '.class';
                bypassTriggerNames.add(codeString.substringBetween(open, close));
            }
        }
        if (necessaryTriggersForLoadTestData.isEmpty()) prepareTriggersLists();

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

    public static void createPIDelegateUser(){
        Contact delegateContact = [SELECT Id FROM Contact WHERE LastName = 'PIDelTD' LIMIT 1];
        ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createPortalUsers(new Set<Id>{
                delegateContact.Id
        });
    }

    public static void createHCPEWaitingAcceptance(){
        Account hcpAccount = [SELECT Id FROM Account  WHERE Name = 'HCP Account' LIMIT 1];
        Contact hcpPAContact = new Contact(
                FirstName = 'HCPPATD',
                LastName = 'HCPPATD',
                Email = 'hcp_pending@emil.com',
                AccountId = hcpAccount.Id
        );
        insert hcpPAContact;
        Study_Site__c studySite = [SELECT Id FROM Study_Site__c WHERE Study_Site_Number__c = 'SS1' LIMIT 1];
        HCP_Enrollment__c hcpEnrollment = new HCP_Enrollment__c(
                Study_Site__c = studySite.Id,
                HCP_Contact__c = hcpPAContact.Id,
                Status__c = HCPEnrollmentService.HCP_S_ACTIVATION_PENDING
        );
        insert hcpEnrollment;

    }
}