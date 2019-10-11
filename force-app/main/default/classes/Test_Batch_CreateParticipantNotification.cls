/**
 * Created by Julia Kazakevich on 20-Sep-19.
 */

@IsTest
public without sharing class Test_Batch_CreateParticipantNotification {
    @IsTest
    static void testBatchExecution() {
        List<Account> accounts = new List<Account>();
        Account participantsAccount = new Account(
                Name = 'Participant'
        );
        accounts.add(participantsAccount);
        Account piAccount = new Account(
                Name = 'PI Account'
        );
        accounts.add(piAccount);
        Account studySiteAccount = new Account(
                Name = 'Study Site Account',
                BillingCountryCode = 'US'
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
        insert contacts;

        Clinical_Trial_Profile__c study = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'CTP1',
                Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = 'NCT99999999',
                Link_to_Pre_screening__c = 'some link',
                Study_Title__c = 'Some Title',
                Study_Code_Name__c = 'Some Code Name',
                Suppress_Participant_Emails__c = false,
                Participating_in_Digital_Recruitment__c = 'YES',
                Participating_in_Rocket_Referral__c = 'YES',
                Participating_in_Patient_Portal__c = 'Yes',
                Shareback_Settings_On_Participant_Level__c = true,
                Shareback_Availability_Timing__c = 1,
                Visit_Data_Shareback__c = true,
                Synch_with_TMDH__c = true,
                Logged_Out_Days_Notification__c = 3
        );
        insert study;

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

        Participant__c participant = new Participant__c(
                First_Name__c = 'Max',
                Last_Name__c = 'James',
                Birth_Year__c = '1985',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'NY',
                Email__c = 'MaxJames@mail.com'
        );
        insert participant;
        Participant__c part1 = [SELECT Contact__c FROM Participant__c WHERE Id =: participant.Id];
        Contact con = new Contact(Id = part1.Contact__c, Next_Notify_Date__c = Date.today());
        update con;

        Participant_Enrollment__c participantEnrollment = new Participant_Enrollment__c(
                Participant__c = participant.Id,
                Screening_ID__c = 'PE1',
                Study_Site__c = studySite.Id
        );
        insert participantEnrollment;

        Test.startTest();
        Database.executeBatch(new Batch_CreateParticipantLoginNotification());
        Test.stopTest();

        Participant__c part = [
                SELECT Id, Contact__r.Next_Notify_Date__c
                FROM Participant__c
        ];

        System.assertEquals(Date.today().addDays(3), part.Contact__r.Next_Notify_Date__c);
    }
    
   	@IsTest
    static void testCreateDate() {
        Test.startTest();
        TestData.loadTestData();

        List<Participant__c> participants = [
            SELECT  Id,
                        Name,
                        Contact__c,
                        Contact__r.Profile_Update_Years_Notification__c
            FROM Participant__c
        ];
        new Batch_UserCreatedDateNotification().execute(null, participants);
        Test.stopTest();

    }

    @IsTest
    static void testdataBecomesAvailiable() {
        Test.startTest();
        TestData.loadTestData();

        List<Patient_Visit__c> participants = [
                SELECT  Id,
                        Completed_Date__c,
                        Participant_Enrollment__c,
                        Participant_Enrollment__r.Participant__r.Mailing_Country_Code__c,
                        Participant_Enrollment__r.Clinical_Trial_Profile__c,
                        Participant_Enrollment__r.Clinical_Trial_Profile__r.Shareback_Availability_Timing__c,
                        Participant_Enrollment__r.Participant_Contact__r.Visit_Results_Opt_In__c,
                        Visit_Number__c, (
                        SELECT
                                Id,
                                Actual_Value__c,
                                Max_Value__c,
                                Measurement__c,
                                Min_Value__c,
                                Patient_Visit__r.Completed_Date__c,
                                Patient_Visit__r.Notified__c,
                                Patient_Visit__r.Participant_Enrollment__r.Participant_Contact__c,
                                Result_Type__c
                        FROM Visit_Results__r
                )
                FROM Patient_Visit__c
                WHERE Status__c = 'Completed'
                AND Notified__c = false
                ORDER BY Visit_Number__c, Completed_Date__c
        ];
        new Batch_DataBecomesAvailable().execute(null, participants);
        Test.stopTest();

    }

    @IsTest
    static void testChangeFieldInCTP() {
        List<Account> accounts = new List<Account>();
        Account participantsAccount = new Account(
                Name = 'Participant'
        );
        accounts.add(participantsAccount);
        Account piAccount = new Account(
                Name = 'PI Account'
        );
        accounts.add(piAccount);
        Account studySiteAccount = new Account(
                Name = 'Study Site Account',
                BillingCountryCode = 'US'
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
        insert contacts;

        Clinical_Trial_Profile__c study = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'CTP1',
                Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = 'NCT99999999',
                Link_to_Pre_screening__c = 'some link',
                Study_Title__c = 'Some Title',
                Study_Code_Name__c = 'Some Code Name',
                Suppress_Participant_Emails__c = false,
                Participating_in_Digital_Recruitment__c = 'YES',
                Participating_in_Rocket_Referral__c = 'YES',
                Participating_in_Patient_Portal__c = 'Yes',
                Shareback_Settings_On_Participant_Level__c = true,
                Shareback_Availability_Timing__c = 1,
                Visit_Data_Shareback__c = true,
                Synch_with_TMDH__c = true
        );
        insert study;

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

        Participant__c participant = new Participant__c(
                First_Name__c = 'Max',
                Last_Name__c = 'James',
                Birth_Year__c = '1985',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'NY',
                Email__c = 'MaxJames@mail.com'
        );
        insert participant;
        Participant__c part1 = [SELECT Contact__c FROM Participant__c WHERE Id =: participant.Id];
        Contact con = new Contact(Id = part1.Contact__c, Next_Notify_Date__c = Date.today());
        update con;

        Participant_Enrollment__c participantEnrollment = new Participant_Enrollment__c(
                Participant__c = participant.Id,
                Screening_ID__c = 'PE1',
                Study_Site__c = studySite.Id
        );
        insert participantEnrollment;

        Test.startTest();
        Database.executeBatch(new Batch_CreateParticipantLoginNotification());
        study.Logged_Out_Days_Notification__c = 3;
        update study;
        Database.executeBatch(new Batch_CreateParticipantLoginNotification());
        Test.stopTest();

        Participant__c part = [
                SELECT Id, Contact__r.Next_Notify_Date__c
                FROM Participant__c
        ];

        System.assertEquals(Date.today().addDays(3), part.Contact__r.Next_Notify_Date__c);
    }
}