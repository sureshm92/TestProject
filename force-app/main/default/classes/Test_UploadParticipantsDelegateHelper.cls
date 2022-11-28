@isTest
public class Test_UploadParticipantsDelegateHelper {
    @IsTest
    private static void testWrapperCreartion() {
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateTriggerHandler.CreateNewAssignmentNotification.class
        );
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
        System.runAs(admin) {
            Account usraccount = new Account(Name = 'Community');
            insert usraccount;

            Contact usrcontact = new Contact(AccountId = usraccount.Id, LastName = 'xgeek');
            insert usrcontact;

            user_1 = new User(
                Email = 'yourusername@gmail.com',
                ProfileId = profile_1.Id,
                UserName = 'yourusername@gmail.com',
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ContactId = usrcontact.Id,
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname'
            );
            insert user_1;
            TriggerHandlerExecutor.bypassHandler(
                StudySiteTriggerHandler.AssignCommunityPermissionsForUser.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantTriggerHandler.CreateNewAssignmentNotification.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantTriggerHandler.CreateReactivatedNotification.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantTriggerHandler.SetDefaultPatientDelegateStatusHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantTriggerHandler.UpdatePermissionSetAssignments.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantTriggerHandler.CreatePrimaryDelegateForMinor.class
            );
        }
        Test.startTest();
        System.runAs(user_1) {
            Account SiteAccount = new Account(
                Name = 'Study Site Account',
                BillingCountry = 'United States'
            );

            insert SiteAccount;
            Contact con = new Contact(
                FirstName = 'ParticipantTD',
                LastName = 'ParticipantTD',
                AccountId = SiteAccount.Id
            );
            insert con;

            Contact delegatecontact = new Contact(
                FirstName = 'delegateparticipant',
                LastName = 'delegatepart',
                AccountId = SiteAccount.Id
            );
            insert delegatecontact;

            // List<Clinical_Trial_Profile__c> clinicalLST = new List<Clinical_Trial_Profile__c>();
            Clinical_Trial_Profile__c clinical = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'tt123456790',
                Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = 'NCT00000002',
                Link_to_Pre_screening__c = 'some link',
                Study_Title__c = 'Some Title',
                Study_Code_Name__c = 'Some Code Name',
                Suppress_Participant_Emails__c = false,
                IQVIA_Outreach__c = true
            );
            insert clinical;

            Study_Site__c studySite = new Study_Site__c(
                Name = 'Test',
                //Principal_Investigator__c = con.Id,
                Clinical_Trial_Profile__c = clinical.Id,
                Site__c = SiteAccount.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false
            );
            insert studySite;
            Participant__c participant = new Participant__c(
                First_Name__c = 'ParticipantTD33',
                Last_Name__c = 'ParticipantTD34',
                Phone__c = '9611637898',
                Email__c = 'part1@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL',
                age__c = 23,
                site__c = SiteAccount.id,
                Contact__c = con.Id,
                Gender_Technical__c = 'Male',
                Adult__c = true,
                Ethnicity__c = ''
            );
            insert participant;
            TriggerHandlerExecutor.bypassHandler(
                ParticipantTriggerHandler.PrepareCityStateFieldsHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantTriggerHandler.CreateContactsForParticipantsHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantTriggerHandler.UpdateContactDetailsFromParticipant.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantTriggerHandler.CheckBecomesAdultHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantTriggerHandler.UpdatePEAndContactLastNameHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantTriggerHandler.ChangeUserEmailOnParticipantEmailChangeHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdateNameOnPE.class);
            Participant__c delparticipant = new Participant__c(
                First_Name__c = 'delegateparticipant',
                Last_Name__c = 'delegatepart',
                Email__c = 'testpart@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL',
                age__c = 23,
                site__c = SiteAccount.id,
                Contact__c = delegatecontact.Id
            );
            insert delparticipant;

            Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
                Contact__c = delegatecontact.Id,
                Contact__r = delegatecontact,
                Participant__c = participant.Id,
                Participant__r = participant,
                Status__c = 'Disconnected',
                Is_Created_by_Bulk_Import__c = true
            );
            insert patientDelegate;

            Account minorSiteAccount = new Account(
                Name = 'Study Site Account',
                BillingCountry = 'United States'
            );

            insert minorSiteAccount;

            Contact minorcont = new Contact(
                FirstName = 'ParticipantTD11',
                LastName = 'ParticipantTD12',
                AccountId = minorSiteAccount.Id
            );
            insert minorcont;
            Contact delegateMinorContact = new Contact(
                FirstName = 'delegateparticipant22',
                LastName = 'delegatepart14',
                AccountId = minorSiteAccount.Id
            );
            insert delegateMinorContact;

            Participant__c minorParticipant = new Participant__c(
                First_Name__c = 'ParticipantTD11',
                Last_Name__c = 'ParticipantTD12',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL',
                age__c = 10,
                site__c = minorSiteAccount.id,
                Contact__c = minorcont.Id,
                Gender_Technical__c = 'Male',
                Adult__c = false,
                Ethnicity__c = ''
            );
            insert minorParticipant;

            Participant_Enrollment__c receiveenrollment = new Participant_Enrollment__c();
            receiveenrollment.Medical_Record_Review_Status__c = 'Pass';
            receiveenrollment.Pre_screening_Status__c = 'Pass';
            receiveenrollment.Participant_Name__c = minorParticipant.First_Name__c;
            receiveenrollment.Participant_Surname__c = minorParticipant.Last_Name__c;
            receiveenrollment.Patient_ID__c = '12345678';
            receiveenrollment.Participant_Status__c = 'Received';
            receiveenrollment.Referral_Source__c = 'Participant';
            receiveenrollment.Study_Site__c = studySite.Id;
            receiveenrollment.Participant__c = minorParticipant.Id;
            
            try{
                insert receiveenrollment;
            
            receiveenrollment.Participant_Name__c = participant.First_Name__c;
            receiveenrollment.Participant_Surname__c = participant.Last_Name__c;
            receiveenrollment.Participant__c = participant.Id;
            update receiveenrollment;
            
            }catch (Exception e){
                
            }


            TriggerHandlerExecutor.bypassHandler(
                ParticipantTriggerHandler.UpdateContactDetailsFromParticipant.class
            );
            TriggerHandlerExecutor.bypassHandler(
                PatientDelegateTriggerHandler.CreateNewAssignmentNotification.class
            );
            TriggerHandlerExecutor.bypassHandler(
                PatientDelegateTriggerHandler.CreateReactivatedNotification.class
            );
            TriggerHandlerExecutor.bypassHandler(
                PatientDelegateTriggerHandler.SetDefaultPatientDelegateStatusHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
            );
            TriggerHandlerExecutor.bypassHandler(
                PatientDelegateTriggerHandler.CreatePrimaryDelegateForMinor.class
            );

            Participant__c minorDelParticipant = new Participant__c(
                First_Name__c = 'delegateparticipant22',
                Last_Name__c = 'delegatepart14',
                Phone__c = '565656565656',
                Email__c = 'minordelegate@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL',
                age__c = 23,
                site__c = minorSiteAccount.id,
                Contact__c = delegateMinorContact.Id,
                Phone_Type__c = 'Home',
                Alternative_Phone_Number__c = '3333333333'
            );
            insert minorDelParticipant;
            Patient_Delegate__c minorpatientDelegate = new Patient_Delegate__c(
                Contact__c = delegateMinorContact.Id,
                Contact__r = delegateMinorContact,
                Participant__c = minorParticipant.Id,
                Participant__r = minorParticipant,
                Status__c = 'Disconnected',
                Is_Created_by_Bulk_Import__c = true
            );
            insert minorpatientDelegate;

            Contact minorPhBlankContact = new Contact(
                FirstName = 'Albert',
                LastName = 'Thomas',
                AccountId = minorSiteAccount.Id
            );
            insert minorPhBlankContact;
            Contact delegateMinorPhBlankContact = new Contact(
                FirstName = 'delegateparticipant44',
                LastName = 'delegatepart45',
                AccountId = minorSiteAccount.Id
            );
            insert delegateMinorPhBlankContact;

            Participant__c minorPhBlankParticipant = new Participant__c(
                First_Name__c = 'Albert',
                Last_Name__c = 'Thomas',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL',
                age__c = 10,
                site__c = minorSiteAccount.id,
                Contact__c = minorPhBlankContact.Id,
                Gender_Technical__c = 'Male',
                Adult__c = false,
                Ethnicity__c = ''
            );
            insert minorPhBlankParticipant;

            Participant__c minorPhBlankDelegate = new Participant__c(
                First_Name__c = 'delegateparticipant44',
                Last_Name__c = 'delegatepart45',
                Email__c = 'minorPhBlank@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL',
                site__c = minorSiteAccount.id,
                Contact__c = delegateMinorPhBlankContact.Id,
                Phone_Type__c = 'Home',
                Alternative_Phone_Number__c = '3333333333'
            );
            insert minorPhBlankDelegate;

            Patient_Delegate__c minorPhBlankpatientDelegate = new Patient_Delegate__c(
                Contact__c = delegateMinorPhBlankContact.Id,
                Contact__r = delegateMinorPhBlankContact,
                Participant__c = minorPhBlankParticipant.Id,
                Participant__r = minorPhBlankParticipant,
                Status__c = 'Disconnected',
                Is_Created_by_Bulk_Import__c = true
            );
            insert minorPhBlankpatientDelegate;

            Patient_Delegate__c minorPhBlankpatientDelegateAlt = new Patient_Delegate__c(
                Contact__c = delegateMinorPhBlankContact.Id,
                Contact__r = delegateMinorPhBlankContact,
                Participant__c = minorParticipant.Id,
                Participant__r = minorParticipant,
                Status__c = 'Disconnected',
                Is_Created_by_Bulk_Import__c = true,
                Primary_Delegate__c = true            
            );
            insert minorPhBlankpatientDelegateAlt;
            
            Contact contactDupCheck = new Contact(
                FirstName = 'dell001',
                LastName = 'Hp001',
                Email = 'dell+567@email.com',
                AccountId = minorSiteAccount.Id
            );
            insert contactDupCheck;

            Participant__c participantDupCheck = new Participant__c(
                First_Name__c = 'dell001',
                Last_Name__c = 'Hp001',
                Email__c = 'dell+567@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL',
                age__c = 23,
                site__c = SiteAccount.id,
                Birth_Year__c = '1990',
                Contact__c = contactDupCheck.Id
            );
            insert participantDupCheck;

            Patient_Delegate__c patientDrefDupCheck = new Patient_Delegate__c(
                Contact__c = contactDupCheck.Id,
                Contact__r = contactDupCheck,
                Participant__c = participant.Id,
                Participant__r = participant,
                Status__c = 'Disconnected',
                Is_Created_by_Bulk_Import__c = true
            );
            insert patientDrefDupCheck;

            Contact mergeContact = new Contact(
                FirstName = 'AIQH001',
                LastName = 'Human002',
                Email = 'AIQHuman+677@email.com',
                AccountId = minorSiteAccount.Id
            );
            insert mergeContact;

            Participant__c mergeParticipant = new Participant__c(
                First_Name__c = 'AIQH001',
                Last_Name__c = 'Human002',
                Phone__c = '8977777777',
                Email__c = 'AIQHuman+677@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL',
                age__c = 40,
                site__c = SiteAccount.id,
                Contact__c = mergeContact.Id,
                Alternative_Phone_Number__c = '2121212121'
            );
            insert mergeParticipant;

            Patient_Delegate__c mergePatientDelegate = new Patient_Delegate__c(
                Contact__c = mergeContact.Id,
                Contact__r = mergeContact,
                Participant__c = mergeParticipant.Id,
                Participant__r = mergeParticipant,
                Status__c = 'Disconnected',
                Is_Created_by_Bulk_Import__c = true
            );
            insert mergePatientDelegate;

            list<UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper> delegateWrpaaerLST = new List<UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper>();

            ReferHealthcareProviderRemote.HealthcareProvider ddInfo1 = ReferHealthcareProviderRemote.checkDuplicate(
                null,
                'datarecord+001@email.com',
                'data001',
                'record002',
                null
            );
            UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper delegateNullCheck = new UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper();
            delegateNullCheck.DelegateYOB = participantDupCheck.Birth_Year__c;
            //participantDupCheck.Attestation__c = true;
            delegateNullCheck.DelegateFirstName = participantDupCheck.First_Name__c;
            delegateNullCheck.DelegateLastName = participantDupCheck.Last_Name__c;
            // delegateNullCheck.DelegatePhoneType ='Home';
            //pWrapper.DelegatePhoneNo = delparticipant.Phone__c;
            delegateNullCheck.mainparticipant = participant;
            delegateNullCheck.mainparticipant.Adult__c = participant.Adult__c;
            delegateWrpaaerLST.add(delegateNullCheck);

            ReferHealthcareProviderRemote.HealthcareProvider ddInfo = ReferHealthcareProviderRemote.checkDuplicate(
                null,
                'testpart@email.com',
                'delegateparticipant',
                'delegatepart',
                null
            );
            UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper pWrapper = new UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper();
            pWrapper.DelegateYOB = delparticipant.Email__c;
            pWrapper.DelegateFirstName = delparticipant.First_Name__c;
            pWrapper.DelegateLastName = delparticipant.Last_Name__c;
            pWrapper.DelegatePhoneType = 'Home';
            //pWrapper.DelegatePhoneNo = delparticipant.Phone__c;
            pWrapper.mainparticipant = participant;
            pWrapper.mainparticipant.Adult__c = participant.Adult__c;
            pWrapper.isParticipantAdult = true;
            delegateWrpaaerLST.add(pWrapper);

            UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper minorpWrapper = new UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper();
            minorpWrapper.DelegateEmail = minorPhBlankDelegate.Email__c;
            minorpWrapper.DelegateFirstName = minorPhBlankDelegate.First_Name__c;
            minorpWrapper.DelegateLastName = minorPhBlankDelegate.Last_Name__c;
            minorpWrapper.DelegatePhoneType = 'Home';
            //minorpWrapper.DelegatePhoneNo = minorPhBlankDelegate.Phone__c;
            minorpWrapper.mainparticipant = minorPhBlankParticipant;
            minorpWrapper.mainparticipant.Adult__c = minorPhBlankParticipant.Adult__c;
            minorpWrapper.isParticipantAdult = false;
            delegateWrpaaerLST.add(minorpWrapper);

            UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper minorPhNotBlank = new UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper();
            minorPhNotBlank.DelegateEmail = minorDelParticipant.Email__c;
            minorPhNotBlank.DelegateFirstName = minorDelParticipant.First_Name__c;
            minorPhNotBlank.DelegateLastName = minorDelParticipant.Last_Name__c;
            minorPhNotBlank.DelegatePhoneType = minorDelParticipant.Phone_Type__c;
            minorPhNotBlank.DelegatePhoneNo = minorDelParticipant.Phone__c;
            minorPhNotBlank.ParticipantPhoneNo = minorDelParticipant.Alternative_Phone_Number__c;
            minorPhNotBlank.mainparticipant = minorParticipant;
            minorPhNotBlank.mainparticipant.Adult__c = minorParticipant.Adult__c;
            minorPhNotBlank.isParticipantAdult = false;
            delegateWrpaaerLST.add(minorPhNotBlank);

            UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper participantdelegate = new UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper();
            participantdelegate.DelegateYOB = mergeParticipant.Email__c;
            participantdelegate.DelegateFirstName = mergeParticipant.First_Name__c;
            participantdelegate.DelegateLastName = mergeParticipant.Last_Name__c;
            participantdelegate.DelegatePhoneType = 'Home';
            pWrapper.DelegatePhoneNo = mergeParticipant.Phone__c;
            participantdelegate.mainparticipant = minorParticipant;
            // participantdelegate.mainparticipant.Adult__c = minorParticipant.Adult__c;
            participantdelegate.isParticipantAdult = false;
            delegateWrpaaerLST.add(participantdelegate);

            List<List<String>> csvLines = new List<List<String>>();
            List<String> csvFileLines = new List<String>();
            csvFileLines.add('a');
            csvFileLines.add('b');
            csvFileLines.add('c');
            List<String> csvFileLines2 = new List<String>();
            csvFileLines2.add('a');
            csvFileLines2.add('b');
            csvFileLines2.add('c');
            List<String> csvFileLines3 = new List<String>();
            csvFileLines3.add('a');
            csvFileLines3.add('b');
            csvFileLines3.add('c');
            csvLines.add(csvFileLines);
            csvLines.add(csvFileLines2);
            csvLines.add(csvFileLines3);

            System.assertEquals(false, participantdelegate.isParticipantAdult);
            System.assertEquals(true, pWrapper.isParticipantAdult);
            System.assertEquals('Home', participantdelegate.DelegatePhoneType);
            System.assertEquals(participant, pWrapper.mainparticipant);
            System.assertEquals(false, minorpWrapper.isParticipantAdult);
            System.assertEquals(false, minorPhNotBlank.isParticipantAdult);

            UploadParticipantsDelegateHelper.getCleanMessage(csvLines, 1);
            UploadParticipantsDelegateHelper.createPatientDelegate(null, null);
            UploadParticipantsDelegateHelper.updateDelegateRecords(delegateWrpaaerLST);
            UploadParticipantsDelegateHelper.createDelegateRecords(
                delegateWrpaaerLST,
                studySite,
                csvLines,
                true,
                true,
                true,
                true
            );
        }
        Test.stopTest();
    }
    @IsTest
    private static void testWrapperCreartionDuplicate() {
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateTriggerHandler.CreateNewAssignmentNotification.class
        );
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
        System.runAs(admin) {
            Account usraccount = new Account(Name = 'Community');
            insert usraccount;

            Contact usrcontact = new Contact(AccountId = usraccount.Id, LastName = 'xgeek');
            insert usrcontact;

            user_1 = new User(
                Email = 'yourusername@gmail.com',
                ProfileId = profile_1.Id,
                UserName = 'yourusername@gmail.com',
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ContactId = usrcontact.Id,
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname'
            );
            insert user_1;
            TriggerHandlerExecutor.bypassHandler(
                StudySiteTriggerHandler.AssignCommunityPermissionsForUser.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantTriggerHandler.CreateNewAssignmentNotification.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantTriggerHandler.CreateReactivatedNotification.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantTriggerHandler.SetDefaultPatientDelegateStatusHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantTriggerHandler.UpdatePermissionSetAssignments.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantTriggerHandler.CreatePrimaryDelegateForMinor.class
            );
        }
        Test.startTest();
        System.runAs(user_1) {
            Account SiteAccount = new Account(
                Name = 'Study Site Account',
                BillingCountry = 'United States'
            );

            insert SiteAccount;
            Contact con = new Contact(
                FirstName = 'ParticipantTD',
                LastName = 'ParticipantTD',
                AccountId = SiteAccount.Id
            );
            insert con;

            Contact delegatecontact = new Contact(
                FirstName = 'delegateparticipant',
                LastName = 'delegatepart',
                AccountId = SiteAccount.Id
            );
            insert delegatecontact;

            // List<Clinical_Trial_Profile__c> clinicalLST = new List<Clinical_Trial_Profile__c>();
            Clinical_Trial_Profile__c clinical = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'tt123456790',
                Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = 'NCT00000002',
                Link_to_Pre_screening__c = 'some link',
                Study_Title__c = 'Some Title',
                Study_Code_Name__c = 'Some Code Name',
                Suppress_Participant_Emails__c = false,
                IQVIA_Outreach__c = true
            );
            insert clinical;

            Study_Site__c studySite = new Study_Site__c(
                Name = 'Test',
                //Principal_Investigator__c = con.Id,
                Clinical_Trial_Profile__c = clinical.Id,
                Site__c = SiteAccount.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false
            );
            insert studySite;
            Participant__c participant = new Participant__c(
                First_Name__c = 'ParticipantTD33',
                Last_Name__c = 'ParticipantTD34',
                Phone__c = '9611637898',
                Email__c = 'part1@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL',
                age__c = 23,
                site__c = SiteAccount.id,
                Contact__c = con.Id,
                Gender_Technical__c = 'Male',
                Adult__c = true,
                Ethnicity__c = ''
            );
            insert participant;
            
            Participant__c participant1 = new Participant__c(
                First_Name__c = 'ParticipantTD33',
                Last_Name__c = 'ParticipantTD34',
                Phone__c = '9611637898',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL',
                age__c = 23,
                site__c = SiteAccount.id,
                Contact__c = con.Id,
                Gender_Technical__c = 'Male',
                Adult__c = false,
                Ethnicity__c = ''
            );
            insert participant1;
            TriggerHandlerExecutor.bypassHandler(
                ParticipantTriggerHandler.PrepareCityStateFieldsHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantTriggerHandler.CreateContactsForParticipantsHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantTriggerHandler.UpdateContactDetailsFromParticipant.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantTriggerHandler.CheckBecomesAdultHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantTriggerHandler.UpdatePEAndContactLastNameHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantTriggerHandler.ChangeUserEmailOnParticipantEmailChangeHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdateNameOnPE.class);
            Participant__c delparticipant = new Participant__c(
                First_Name__c = 'delegateparticipant',
                Last_Name__c = 'delegatepart',
                Email__c = 'testpart@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL',
                age__c = 23,
                site__c = SiteAccount.id,
                Contact__c = delegatecontact.Id
            );
            insert delparticipant;

            Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
                Contact__c = delegatecontact.Id,
                Contact__r = delegatecontact,
                Participant__c = participant.Id,
                Participant__r = participant,
                Status__c = 'Disconnected',
                Is_Created_by_Bulk_Import__c = true
            );
            insert patientDelegate;
            Patient_Delegate__c patientDelegate1 = new Patient_Delegate__c(
                Contact__c = delegatecontact.Id,
                Contact__r = delegatecontact,
                Participant__c = participant1.Id,
                Participant__r = participant1,
                Status__c = 'Disconnected',
                Is_Created_by_Bulk_Import__c = true
            );
            insert patientDelegate1;

            Account minorSiteAccount = new Account(
                Name = 'Study Site Account',
                BillingCountry = 'United States'
            );

            insert minorSiteAccount;

            Contact minorcont = new Contact(
                FirstName = 'ParticipantTD11',
                LastName = 'ParticipantTD12',
                AccountId = minorSiteAccount.Id
            );
            insert minorcont;
            Contact delegateMinorContact = new Contact(
                FirstName = 'delegateparticipant22',
                LastName = 'delegatepart14',
                AccountId = minorSiteAccount.Id
            );
            insert delegateMinorContact;

            Participant__c minorParticipant = new Participant__c(
                First_Name__c = 'ParticipantTD11',
                Last_Name__c = 'ParticipantTD12',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL',
                age__c = 10,
                site__c = minorSiteAccount.id,
                Contact__c = minorcont.Id,
                Gender_Technical__c = 'Male',
                Adult__c = false,
                Ethnicity__c = ''
            );
            insert minorParticipant;

            Participant_Enrollment__c receiveenrollment = new Participant_Enrollment__c();
            receiveenrollment.Medical_Record_Review_Status__c = 'Pass';
            receiveenrollment.Pre_screening_Status__c = 'Pass';
            receiveenrollment.Participant_Name__c = minorParticipant.First_Name__c;
            receiveenrollment.Participant_Surname__c = minorParticipant.Last_Name__c;
            receiveenrollment.Patient_ID__c = '12345678';
            receiveenrollment.Participant_Status__c = 'Received';
            receiveenrollment.Referral_Source__c = 'Participant';
            receiveenrollment.Study_Site__c = studySite.Id;
            receiveenrollment.Participant__c = minorParticipant.Id;

            try{
                insert receiveenrollment;
            
            
            

            receiveenrollment.Participant_Name__c = participant.First_Name__c;
            receiveenrollment.Participant_Surname__c = participant.Last_Name__c;
            receiveenrollment.Participant__c = participant.Id;
            update receiveenrollment;
            }catch (Exception e){
            
            }

            TriggerHandlerExecutor.bypassHandler(
                ParticipantTriggerHandler.UpdateContactDetailsFromParticipant.class
            );
            TriggerHandlerExecutor.bypassHandler(
                PatientDelegateTriggerHandler.CreateNewAssignmentNotification.class
            );
            TriggerHandlerExecutor.bypassHandler(
                PatientDelegateTriggerHandler.CreateReactivatedNotification.class
            );
            TriggerHandlerExecutor.bypassHandler(
                PatientDelegateTriggerHandler.SetDefaultPatientDelegateStatusHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
            );
            TriggerHandlerExecutor.bypassHandler(
                PatientDelegateTriggerHandler.CreatePrimaryDelegateForMinor.class
            );

            Participant__c minorDelParticipant = new Participant__c(
                First_Name__c = 'delegateparticipant22',
                Last_Name__c = 'delegatepart14',
                Phone__c = '565656565656',
                Email__c = 'minordelegate@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL',
                age__c = 23,
                site__c = minorSiteAccount.id,
                Contact__c = delegateMinorContact.Id,
                Phone_Type__c = 'Home',
                Alternative_Phone_Number__c = '3333333333'
            );
            insert minorDelParticipant;
            Patient_Delegate__c minorpatientDelegate = new Patient_Delegate__c(
                Contact__c = delegateMinorContact.Id,
                Contact__r = delegateMinorContact,
                Participant__c = minorParticipant.Id,
                Participant__r = minorParticipant,
                Status__c = 'Disconnected',
                Is_Created_by_Bulk_Import__c = true
            );
            insert minorpatientDelegate;

            Contact minorPhBlankContact = new Contact(
                FirstName = 'Albert',
                LastName = 'Thomas',
                AccountId = minorSiteAccount.Id
            );
            insert minorPhBlankContact;
            Contact delegateMinorPhBlankContact = new Contact(
                FirstName = 'delegateparticipant44',
                LastName = 'delegatepart45',
                AccountId = minorSiteAccount.Id
            );
            insert delegateMinorPhBlankContact;

            Contact delegateMinorPhBlankContactAlt = new Contact(
                FirstName = 'delegateparticipant46',
                LastName = 'delegatepart46',
                AccountId = minorSiteAccount.Id
            );
            insert delegateMinorPhBlankContactAlt;            
            
            Participant__c minorPhBlankParticipant = new Participant__c(
                First_Name__c = 'Albert',
                Last_Name__c = 'Thomas',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL',
                age__c = 10,
                site__c = minorSiteAccount.id,
                Contact__c = minorPhBlankContact.Id,
                Gender_Technical__c = 'Male',
                Adult__c = false,
                Ethnicity__c = ''
            );
            insert minorPhBlankParticipant;

            Participant__c minorPhBlankDelegate = new Participant__c(
                First_Name__c = 'delegateparticipant44',
                Last_Name__c = 'delegatepart45',
                Email__c = 'minorPhBlank@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL',
                site__c = minorSiteAccount.id,
                Contact__c = delegateMinorPhBlankContact.Id,
                Phone_Type__c = 'Home',
                Alternative_Phone_Number__c = '3333333333'
            );
            insert minorPhBlankDelegate;

            Participant__c minorPhBlankDelegateAlt = new Participant__c(
                First_Name__c = 'delegateparticipant46',
                Last_Name__c = 'delegatepart46',
                Email__c = 'minorPhBlank@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL',
                site__c = minorSiteAccount.id,
                Contact__c = delegateMinorPhBlankContactAlt.Id,
                Phone_Type__c = 'Home',
                Alternative_Phone_Number__c = '3333333333'
            );
            insert minorPhBlankDelegateAlt;
            
            Patient_Delegate__c minorPhBlankpatientDelegate = new Patient_Delegate__c(
                Contact__c = delegateMinorPhBlankContact.Id,
                Contact__r = delegateMinorPhBlankContact,
                Participant__c = minorPhBlankParticipant.Id,
                Participant__r = minorPhBlankParticipant,
                Status__c = 'Disconnected',
                Is_Created_by_Bulk_Import__c = true
            );
            insert minorPhBlankpatientDelegate;
            
            Patient_Delegate__c minorPhBlankpatientDelegateAlt = new Patient_Delegate__c(
                Contact__c = delegateMinorPhBlankContactAlt.Id,
                Contact__r = delegateMinorPhBlankContactAlt,
                Participant__c = minorPhBlankParticipant.Id,
                Participant__r = minorPhBlankParticipant,
                Status__c = 'Disconnected',
                Is_Created_by_Bulk_Import__c = true,
                Primary_Delegate__c = true
            );
            insert minorPhBlankpatientDelegateAlt;

            
            Contact contactDupCheck = new Contact(
                FirstName = 'dell001',
                LastName = 'Hp001',
                Email = 'dell+567@email.com',
                AccountId = minorSiteAccount.Id
            );
            insert contactDupCheck;

            Participant__c participantDupCheck = new Participant__c(
                First_Name__c = 'dell001',
                Last_Name__c = 'Hp001',
                Email__c = 'dell+567@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL',
                age__c = 23,
                site__c = SiteAccount.id,
                Birth_Year__c = '1990',
                Contact__c = contactDupCheck.Id
            );
            insert participantDupCheck;

            Patient_Delegate__c patientDrefDupCheck = new Patient_Delegate__c(
                Contact__c = contactDupCheck.Id,
                Contact__r = contactDupCheck,
                Participant__c = participant.Id,
                Participant__r = participant,
                Status__c = 'Disconnected',
                Is_Created_by_Bulk_Import__c = true
            );
            insert patientDrefDupCheck;

            Contact mergeContact = new Contact(
                FirstName = 'AIQH001',
                LastName = 'Human002',
                Email = 'AIQHuman+677@email.com',
                AccountId = minorSiteAccount.Id
            );
            insert mergeContact;

            Participant__c mergeParticipant = new Participant__c(
                First_Name__c = 'AIQH001',
                Last_Name__c = 'Human002',
                Phone__c = '8977777777',
                Email__c = 'AIQHuman+677@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL',
                age__c = 40,
                site__c = SiteAccount.id,
                Contact__c = mergeContact.Id,
                Alternative_Phone_Number__c = '2121212121'
            );
            insert mergeParticipant;

            Patient_Delegate__c mergePatientDelegate = new Patient_Delegate__c(
                Contact__c = mergeContact.Id,
                Contact__r = mergeContact,
                Participant__c = mergeParticipant.Id,
                Participant__r = mergeParticipant,
                Status__c = 'Disconnected',
                Is_Created_by_Bulk_Import__c = true
            );
            insert mergePatientDelegate;

            list<UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper> delegateWrpaaerLST = new List<UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper>();

            ReferHealthcareProviderRemote.HealthcareProvider ddInfo1 = ReferHealthcareProviderRemote.checkDuplicate(
                null,
                'datarecord+001@email.com',
                'data001',
                'record002',
                null
            );
            UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper delegateNullCheck = new UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper();
            delegateNullCheck.DelegateYOB = participantDupCheck.Birth_Year__c;
            //participantDupCheck.Attestation__c = true;
            delegateNullCheck.DelegateFirstName = participantDupCheck.First_Name__c;
            delegateNullCheck.DelegateLastName = participantDupCheck.Last_Name__c;
            // delegateNullCheck.DelegatePhoneType ='Home';
            //pWrapper.DelegatePhoneNo = delparticipant.Phone__c;
            delegateNullCheck.mainparticipant = participant;
            delegateNullCheck.mainparticipant.Adult__c = participant.Adult__c;
            delegateWrpaaerLST.add(delegateNullCheck);

            ReferHealthcareProviderRemote.HealthcareProvider ddInfo = ReferHealthcareProviderRemote.checkDuplicate(
                null,
                'testpart@email.com',
                'delegateparticipant',
                'delegatepart',
                null
            );
            UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper pWrapper = new UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper();
            pWrapper.DelegateYOB = delparticipant.Email__c;
            pWrapper.DelegateFirstName = delparticipant.First_Name__c;
            pWrapper.DelegateLastName = delparticipant.Last_Name__c;
            pWrapper.DelegatePhoneType = 'Home';
            //pWrapper.DelegatePhoneNo = delparticipant.Phone__c;
            pWrapper.mainparticipant = participant;
            pWrapper.mainparticipant.Adult__c = participant.Adult__c;
            pWrapper.isParticipantAdult = true;
            delegateWrpaaerLST.add(pWrapper);
            
            UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper pWrapper1 = new UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper();
            pWrapper1.DelegateYOB = delparticipant.Email__c;
            pWrapper1.DelegateFirstName = delparticipant.First_Name__c;
            pWrapper1.DelegateLastName = delparticipant.Last_Name__c;
            pWrapper1.DelegatePhoneType = 'Home';
            //pWrapper.DelegatePhoneNo = delparticipant.Phone__c;
            pWrapper1.mainparticipant = participant1;
            pWrapper1.mainparticipant.Adult__c = participant.Adult__c;
            pWrapper1.isParticipantAdult = true;
            delegateWrpaaerLST.add(pWrapper1);
            
            UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper minorpWrapper = new UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper();
            minorpWrapper.DelegateEmail = minorPhBlankDelegate.Email__c;
            minorpWrapper.DelegateFirstName = minorPhBlankDelegate.First_Name__c;
            minorpWrapper.DelegateLastName = minorPhBlankDelegate.Last_Name__c;
            minorpWrapper.DelegatePhoneType = 'Home';
            //minorpWrapper.DelegatePhoneNo = minorPhBlankDelegate.Phone__c;
            minorpWrapper.mainparticipant = minorPhBlankParticipant;
            minorpWrapper.mainparticipant.Adult__c = minorPhBlankParticipant.Adult__c;
            minorpWrapper.isParticipantAdult = false;
            delegateWrpaaerLST.add(minorpWrapper);

            UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper minorPhNotBlank = new UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper();
            minorPhNotBlank.DelegateEmail = minorDelParticipant.Email__c;
            minorPhNotBlank.DelegateFirstName = minorDelParticipant.First_Name__c;
            minorPhNotBlank.DelegateLastName = minorDelParticipant.Last_Name__c;
            minorPhNotBlank.DelegatePhoneType = minorDelParticipant.Phone_Type__c;
            minorPhNotBlank.DelegatePhoneNo = minorDelParticipant.Phone__c;
            minorPhNotBlank.ParticipantPhoneNo = minorDelParticipant.Alternative_Phone_Number__c;
            minorPhNotBlank.mainparticipant = minorParticipant;
            minorPhNotBlank.mainparticipant.Adult__c = minorParticipant.Adult__c;
            minorPhNotBlank.isParticipantAdult = false;
            delegateWrpaaerLST.add(minorPhNotBlank);

            UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper participantdelegate = new UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper();
            participantdelegate.DelegateYOB = mergeParticipant.Email__c;
            participantdelegate.DelegateFirstName = mergeParticipant.First_Name__c;
            participantdelegate.DelegateLastName = mergeParticipant.Last_Name__c;
            participantdelegate.DelegatePhoneType = 'Home';
            pWrapper.DelegatePhoneNo = mergeParticipant.Phone__c;
            participantdelegate.mainparticipant = minorParticipant;
            // participantdelegate.mainparticipant.Adult__c = minorParticipant.Adult__c;
            participantdelegate.isParticipantAdult = false;
            delegateWrpaaerLST.add(participantdelegate);           
            delegateWrpaaerLST.add(participantdelegate); 
            List<List<String>> csvLines = new List<List<String>>();
            List<String> csvFileLines = new List<String>();
            csvFileLines.add('a');
            csvFileLines.add('b');
            csvFileLines.add('c');
            List<String> csvFileLines2 = new List<String>();
            csvFileLines2.add('a');
            csvFileLines2.add('b');
            csvFileLines2.add('c');
            List<String> csvFileLines3 = new List<String>();
            csvFileLines3.add('a');
            csvFileLines3.add('b');
            csvFileLines3.add('c');
            csvLines.add(csvFileLines);
            csvLines.add(csvFileLines2);
            csvLines.add(csvFileLines3);

            System.assertEquals(false, participantdelegate.isParticipantAdult);
            System.assertEquals(true, pWrapper.isParticipantAdult);
            System.assertEquals('Home', participantdelegate.DelegatePhoneType);
            System.assertEquals(participant, pWrapper.mainparticipant);
            System.assertEquals(false, minorpWrapper.isParticipantAdult);
            System.assertEquals(false, minorPhNotBlank.isParticipantAdult);

            UploadParticipantsDelegateHelper.getCleanMessage(csvLines, 1);
            UploadParticipantsDelegateHelper.createPatientDelegate(null, null);
            UploadParticipantsDelegateHelper.updateDelegateRecords(delegateWrpaaerLST);
            UploadParticipantsDelegateHelper.createDelegateRecords(
                delegateWrpaaerLST,
                studySite,
                csvLines,
                true,
                true,
                true,
                true
            );
        }
        Test.stopTest();
    }
}