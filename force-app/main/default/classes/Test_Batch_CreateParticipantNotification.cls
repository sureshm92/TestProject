/**
 * Created by Julia Kazakevich on 20-Sep-19.
 */

@IsTest
public without sharing class Test_Batch_CreateParticipantNotification {
//    @IsTest
//    static void testBatchExecution() {
//        List<Account> accounts = new List<Account>();
//        Account participantsAccount = new Account(
//                Name = 'Participant'
//        );
//        accounts.add(participantsAccount);
//        Account piAccount = new Account(
//                Name = 'PI Account'
//        );
//        accounts.add(piAccount);
//        Account studySiteAccount = new Account(
//                Name = 'Study Site Account',
//                BillingCountryCode = 'US'
//        );
//        accounts.add(studySiteAccount);
//        insert accounts;
//
//        List<Contact> contacts = new List<Contact>();
//        Contact piContact = new Contact(
//                FirstName = 'PI',
//                LastName = 'PI',
//                Email = 'pi@emil.com',
//                AccountId = piAccount.Id,
//                Participant_Opt_In_Status_Emails__c = true,
//                Next_Notify_Date__c = Date.today()
//        );
//        contacts.add(piContact);
//        insert contacts;
//
//        List<Clinical_Trial_Profile__c> studies = new List<Clinical_Trial_Profile__c>();
//        studies.add(new Clinical_Trial_Profile__c(
//                Protocol_ID__c = 'CTP1',
//                Override_Recruitment_Status__c = 'Actively Enrolling',
//                NCT_Number__c = 'NCT99999999',
//                Link_to_Pre_screening__c = 'some link',
//                Study_Title__c = 'Some Title',
//                Study_Code_Name__c = 'Some Code Name',
//                Suppress_Participant_Emails__c = false,
//                Participating_in_Digital_Recruitment__c = 'YES',
//                Participating_in_Rocket_Referral__c = 'YES',
//                Participating_in_Patient_Portal__c = 'Yes',
//                Shareback_Settings_On_Participant_Level__c = true,
//                Shareback_Availability_Timing__c = 1,
//                Visit_Data_Shareback__c = true,
//                Synch_with_TMDH__c = true,
//                Patient_Portal_Enabled__c = TRUE
//        ));
//        insert studies;
//
//        List<Study_Site__c> studySites = new List<Study_Site__c>();
//        studySites.add(new Study_Site__c(
//                Principal_Investigator__c = piContact.Id,
//                Clinical_Trial_Profile__c = studies[0].Id,
//                Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
//                Site__c = studySiteAccount.Id,
//                Study_Site_Type__c = 'Traditional',
//                Suppress_Participant_Emails__c = false,
//                Study_Site_Number__c = 'SS1'
//        ));
//        insert studySites;
//
//        Participant__c participant = new Participant__c(
//                First_Name__c = 'Max',
//                Last_Name__c = 'James',
//                Birth_Year__c = '1985',
//                Mailing_Country_Code__c = 'US',
//                Mailing_State_Code__c = 'NY',
//                Email__c = 'MaxJames@mail.com'
//        );
//        insert participant;
//
//        insert new Participant_Enrollment__c(
//                Participant__c = participant.Id,
//                Screening_ID__c = 'PE1',
//                Study_Site__c = studySites[0].Id
//        );
//
//        Participant__c part1 = [SELECT Contact__c FROM Participant__c WHERE Id =: participant.Id];
//        Contact con = new Contact(Id = part1.Contact__c, Next_Notify_Date__c = Date.today(), Participant_Opt_In_Status_Emails__c = true);
//        update con;
//
//        Test.startTest();
//        Database.executeBatch(new Batch_UserAfterOneYearNotification());
//        Test.stopTest();
//    }
//
//   	@IsTest
//    static void testCreateDate() {
//        Test.startTest();
//        TestData.loadTestData();
//
//        List<User> users = [
//                SELECT
//                        ContactId,
//                        Contact.Current_Participant_Enrollment__c,
//                        Contact.Participant_Opt_In_Status_Emails__c,
//                        Contact.Profile_Update_Years_Notification__c,
//                        CreatedDate
//                FROM User
//                WHERE CreatedDate =: Datetime.now().addYears(-1)
//                AND Contact.userCommunityMode__c =: CommunityService.USER_MODE_PARTICIPANT
//                AND Contact.Current_Participant_Enrollment__c != NULL
//                AND IsActive = TRUE
//        ];
//        new Batch_UserAfterOneYearNotification().execute(null, users);
//        Test.stopTest();
//
//    }
//
//    @IsTest
//    static void testdataBecomesAvailiable() {
//        Test.startTest();
//        TestData.loadTestData();
//        TestData testData = new TestData();
//
//        testData.ss.Visit_Results_Sharing__c = true;
//        update testData.ss;
//
//        testData.ctp.Visit_Data_Shareback__c = true;
//        testData.ctp.Shareback_Availability_Timing__c = 0.0;
//        update testData.ctp;
//
//        testData.pe.Participant_Contact__r.Visit_Results_Opt_In__c = true;
//        testData.pe.Participant_Contact__r.Participant_Opt_In_Status_Emails__c = true;
//        update testData.pe.Participant_Contact__r;
//
//        List<Visit_Result_Type_Sharing__c> visitResultTypeSharings = new List<Visit_Result_Type_Sharing__c>();
//        visitResultTypeSharings.add(new Visit_Result_Type_Sharing__c(
//                Clinical_Trial_Profile__c = testData.ctp.Id,
//                Include_Countries__c = true,
//                Type__c = 'Calcium',
//                Sharing_Countries__c = 'US'
//        ));
//        visitResultTypeSharings.add(new Visit_Result_Type_Sharing__c(
//                Clinical_Trial_Profile__c = testData.ctp.Id,
//                Include_Countries__c = true,
//                Type__c = 'BUN',
//                Sharing_Countries__c = 'US'
//        ));
//        insert visitResultTypeSharings;
//
//        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
//        insert vp;
//
//        Visit__c visit = new Visit__c(Visit_Plan__c = vp.Id);
//        insert visit;
//
//        Patient_Visit__c patientVisit = new Patient_Visit__c(
//                Participant_Enrollment__c = testData.pe.Id,
//                Status__c = 'Completed',
//                Visit__c = visit.Id,
//                Visit_Number__c = 1,
//                Completed_Date__c = Date.newInstance(2019, 12, 17)
//        );
//        insert patientVisit;
//
//        List<Visit_Result__c> visitResults = new List<Visit_Result__c>();
//        visitResults.add(new Visit_Result__c(
//                Actual_Value__c = 0.01,
//                Patient_Visit__c = patientVisit.Id,
//                Result_Type__c = 'Calcium'
//        ));
//        visitResults.add(new Visit_Result__c(
//                Actual_Value__c = 0.5,
//                Patient_Visit__c = patientVisit.Id,
//                Result_Type__c = 'BUN'
//        ));
//        insert visitResults;
//
//        Database.executeBatch(new Batch_DataBecomesAvailable());
//        Test.stopTest();
//
//    }
}