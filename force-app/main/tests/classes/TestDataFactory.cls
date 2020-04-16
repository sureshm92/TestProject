public class TestDataFactory {

    private static final Map<SObjectType, Map<String, Object>> REQUIRED_FIELDS = new Map<SObjectType, Map<String, Object>>{
            Account.getSObjectType() => new Map<String, Object>{
                    'Name' => 'Test Name'
            },

            Clinical_Trial_Profile__c.getSObjectType() => new Map<String, Object>{
                    'Protocol_ID__c' => 'test protocol Id',
                    'Study_Title__c' => 'Test Study Title',
                    'Study_Code_Name__c' => 'Test Study Code Name',
                    'NCT_Number__c' => 'NCT00000000',
                    'Synch_with_TMDH__c' => true
            },

            Contact.getSObjectType() => new Map<String, Object>{
                    'LastName' => 'Test Last Name'
            },

            ContentVersion.getSObjectType() => new Map<String, Object>{
                    'Title' => 'Test Title',
                    'VersionData' => Blob.valueOf('Test Data'),
                    'PathOnClient' => 'Test.pdf'
            },

            Participant_Enrollment__c.getSObjectType() => new Map<String, Object>{
                    'Medical_Record_Review_Status__c' => 'Pass',
                    'Pre_screening_Status__c' => 'Pass',
                    'Patient_ID__c' => '12345678',
                    'Participant_Status__c' => 'Received',
                    'Referral_Source__c' => 'HCP'
            },

            Participant__c.getSObjectType() => new Map<String, Object>{
                    'First_Name__c' => 'Test Participant First Name',
                    'Last_Name__c' => 'Test Participant Last Name',
                    'Email__c' => 'test@test.com',
                    'Phone__c' => '13241321223',
                    'Mailing_Country_Code__c' => 'US',
                    'Mailing_State_Code__c' => 'NY',
                    'Mailing_Zip_Postal_Code__c' => '1234231234',
                    'Preferred_Language__c' => 'en_US',
                    'Adult__c' => true
            },

            Resource_Action__c.getSObjectType() => new Map<String, Object>{
                    'IsFavorite__c' => true,
                    'IsVoted__c' => true
            },

            Resource__c.getSObjectType() => new Map<String, Object>{
                    'Title__c' => 'Test subject',
                    'Description__c' => 'Test description',
                    'Language__c' => 'en_US',
                    'Posting_Date__c' => Date.today(),
                    'Expiration_Date__c' => Date.today().addDays(1)
            },

            Study_Site__c.getSObjectType() => new Map<String, Object>{
                    'Name' => 'Test Study Name',
                    'Study_Site_Key__c' => '12132123132313',
                    'Override_PI_Referral_Status__c' => 'Invitation Sent'
            },

            Therapeutic_Area_Patient__c.getSObjectType() => new Map<String, Object>{
                    'Condition_Of_Interest_Order__c' => 0
            },

            Therapeutic_Area__c.getSObjectType() => new Map<String, Object>{
                    'Name' => 'Test Name'
            }
    };

    public static Integer fakeId_num = 1;

    public static String getFakeId(Schema.SObjectType sObjectType) {
        String result = String.valueOf(fakeId_num++);
        return sObjectType.getDescribe().getKeyPrefix() +
                '0'.repeat(12 - result.length()) + result;
    }

    /*getter without parameters - with default values for required fields*/

    public static SObject getSObject(Schema.SObjectType sObjectType) {
        return TestDataFactory.getSObjectWithFilledFields(sObjectType.newSObject(), TestDataFactory.REQUIRED_FIELDS.get(sObjectType));
    }

    /*getter with parameters*/

    public static SObject getSObject(Schema.SObjectType sObjectType, Map<String, Object> fieldValuesByNames) {
        return TestDataFactory.getSObjectWithFilledFields(TestDataFactory.getSObject(sObjectType), fieldValuesByNames);
    }

    private static SObject getSObjectWithFilledFields(SObject record, Map<String, Object> fieldValuesByNames) {
        if (fieldValuesByNames == null) {
            System.debug('-------------------FIELD VALUES BY NAMES MAP IS EMPTY-----------------------');
            return record;
        }
        for (String fieldName : fieldValuesByNames.keySet()) {
            if (fieldName.containsIgnoreCase('__r')) {
                record.putSObject(fieldName, (SObject) fieldValuesByNames.get(fieldName));
            } else {
                record.put(fieldName, fieldValuesByNames.get(fieldName));
            }
        }
        return record;
    }

    public static void createDataForTravelSupportTesting() {

        createInitData();

        Study_Site__c studySite = [SELECT Id FROM Study_Site__c LIMIT 1];
        List<TravelVendor__c> travelVendors = new List<TravelVendor__c>{
                new TravelVendor__c(Name = 'Uber', Link_Vendor__c = 'link 1'),
                new TravelVendor__c(Name = 'Uklon', Link_Vendor__c = 'link 2'),
                new TravelVendor__c(Name = 'Kiev Taxi', Link_Vendor__c = 'link 3'),
                new TravelVendor__c(Name = 'Uzbek', Link_Vendor__c = 'link 4')
        };
        insert travelVendors;

        List<TravelVendorSettings__c> travelVendorSettings = new List<TravelVendorSettings__c>{
                new TravelVendorSettings__c(Study_Site__c = studySite.Id, TravelVendor__c = travelVendors[0].Id, isEnable__c = true, Is_Manual__c = true),
                new TravelVendorSettings__c(Study_Site__c = studySite.Id, TravelVendor__c = travelVendors[1].Id, isEnable__c = true, By_Country__c = true),
                new TravelVendorSettings__c(Study_Site__c = studySite.Id, TravelVendor__c = travelVendors[2].Id, isEnable__c = false, Is_Manual__c = true, By_Country__c = true),
                new TravelVendorSettings__c(Study_Site__c = studySite.Id, TravelVendor__c = travelVendors[3].Id, isEnable__c = false)
        };
        insert travelVendorSettings;
    }

    public static void createInitData() {
        bypassTriggers();

        Terms_And_Conditions__c portalTC = new Terms_And_Conditions__c(
                Active__c = true
        );

        insert portalTC;

        List<Account> accounts = new List<Account>();
        Account participantsAccount = new Account(
                Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
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
                FirstName = 'PI',
                LastName = 'PI',
                Email = 'pi@emil.com',
                AccountId = piAccount.Id
        );
        contacts.add(piContact);

        Contact hcpContact = new Contact(
                FirstName = 'HCP',
                LastName = 'HCP',
                Email = 'hcp@emil.com',
                AccountId = hcpAccount.Id,
                MailingLatitude = 40.766594,
                MailingLongitude = -73.991509
        );
        contacts.add(hcpContact);
        insert contacts;

        Therapeutic_Area__c area = new Therapeutic_Area__c(Name = 'Test TA');
        insert area;

        Clinical_Trial_Profile__c study = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'CTP1',
                Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = 'NCT99999999',
                Link_to_Pre_screening__c = 'some link',
                Terms_And_Conditions_ID__c = portalTC.Id,
                Study_Title__c = 'Some Title',
                Study_Code_Name__c = 'Some Code Name',
                Suppress_Participant_Emails__c = false,
                Therapeutic_Area__c = area.Id,
                Synch_with_TMDH__c = true,
                Include_in_RP_trial_search__c = true,
                Patient_Portal_Enabled__c = true,
                Shareback_Settings_On_Participant_Level__c = true,
                Shareback_Availability_Timing__c = 1,
                Visit_Data_Shareback__c = true
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
                Approved_Lng__c = 'en_US',
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
                First_Name__c = 'Participant',
                Last_Name__c = 'Participant',
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
    }

    private static void bypassTriggers() {
        TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(NotificationTriggerHandler.class);

        TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.SendEmailIfSSWasChanged.class);
        TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.CreateNotificationHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateWelcomeToStudyAlertHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateParticipantForDelegateHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class);
    }
}