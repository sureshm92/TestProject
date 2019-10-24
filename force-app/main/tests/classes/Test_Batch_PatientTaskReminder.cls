/**
 * Created by Olga Skrynnikova on 10/23/2019.
 */
@IsTest
public with sharing class Test_Batch_PatientTaskReminder {
    @IsTest
    static void testBatchExecute() {
        initData();
        Participant_Enrollment__c pe = [SELECT Id, Participant_Contact__c FROM Participant_Enrollment__c];
        List<Task> tskList = new List<Task>();
        User user = [
                SELECT
                        Id,
                        ContactId,
                        Contact.Participant_Opt_In_Status_Emails__c
                FROM User
                WHERE ContactId = : pe.Participant_Contact__c
        ];
        Task tsk = new Task(
                Subject = 'Test Name',
                Task_Type__c = 'Not Selected',
                Reminder_Date__c = Datetime.now(),
                Status = 'Open',
                ReminderDateTime = Datetime.now(),
                OwnerId = user.Id
        );
        tskList.add(tsk);

        Contact conList = [SELECT Id, Participant_Opt_In_Status_Emails__c, Email FROM Contact WHERE Email = 'MaxJames@mail.com'];
        conList.Participant_Opt_In_Status_Emails__c = true;
        update conList;


        Test.startTest();
        upsert tsk;
        List<Task> tasks = [
                SELECT Id,
                        Description,
                        OwnerId,
                        Subject,
                        Start_Date__c,
                        Task_Type__c,
                        ReminderDateTime,
                        Reminder_Date__c,
                        Reminder_Schedule__c,
                        Reminder_Schedule__r.First_Reminder_day__c,
                        Reminder_Schedule__r.Second_Reminder_day__c,
                        Reminder_Schedule__r.Use_Final_Template__c,
                        Visible_For__c,
                        WhatId,
                        WhoId
                FROM Task
                WHERE ReminderDateTime <= :Datetime.now()
                AND Is_Reminder_Sent__c = FALSE
                AND Status IN:TaskService.TASK_STATUS_GROUP_AVAILABLE
        ];
        new Batch_PatientTaskReminder().execute(null, tasks);
        Test.stopTest();

        List<Task> taskList = [SELECT Id, Subject, Task_Type__c, WhoId, Reminder_Date__c FROM Task];
        System.assertEquals(2, taskList.size());

    }

    static void initData() {
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

        List<Clinical_Trial_Profile__c> studies = new List<Clinical_Trial_Profile__c>();
        studies.add(new Clinical_Trial_Profile__c(
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
                Logged_Out_Days_Notification__c = 12
        ));
        insert studies;

        List<Study_Site__c> studySites = new List<Study_Site__c>();
        studySites.add(new Study_Site__c(
                Principal_Investigator__c = piContact.Id,
                Clinical_Trial_Profile__c = studies[0].Id,
                Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
                Site__c = studySiteAccount.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false,
                Study_Site_Number__c = 'SS1'
        ));
        insert studySites;

        Participant__c participant = new Participant__c(
                First_Name__c = 'Max',
                Last_Name__c = 'James',
                Birth_Year__c = '1985',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'NY',
                Email__c = 'MaxJames@mail.com'
        );
        insert participant;

        insert new Participant_Enrollment__c(
                Participant__c = participant.Id,
                Screening_ID__c = 'PE1',
                Study_Site__c = studySites[0].Id
        );
    }

}

