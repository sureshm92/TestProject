/**
 * Created by Olga Skrynnikova on 12/10/2019.
 */

@IsTest
private class Test_NotificationService {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        TestData.createTCAcceptance();

        Test.stopTest();
    }
    @IsTest
    static void getTopicListOrCreateNewTest() {
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

        //        List<Contact> contacts = new List<Contact>();
        //        Contact piContact = new Contact(
        //                FirstName = 'PI',
        //                LastName = 'PI',
        //                Email = 'pi@emil.com',
        //                AccountId = piAccount.Id
        //        );
        //        contacts.add(piContact);
        //        insert contacts;
        ////        Therapeutic_Area__c tp = new Therapeutic_Area__c(Name = 'Immunology');
        ////        insert tp;
        //        Clinical_Trial_Profile__c ctp = new Clinical_Trial_Profile__c(
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
        //                Logged_Out_Days_Notification__c = 12
        //        );
        //        Test.startTest();
        //        try {
        //            insert ctp;
        //        } catch (DmlException e) {
        //            System.debug('WRONG <<<< ' + e.getMessage());
        //        }
        //        Test.stopTest();
    }

    @IsTest
    static void test_checkHCPNotificationType() {
        Test.startTest();
        TestData testData = new TestData();
        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_REFERRAL_ACCEPTED;
        NotificationService.checkHCPNotificationType(testData.pe, false);

        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_REFERRAL_DECLINED;
        NotificationService.checkHCPNotificationType(testData.pe, false);

        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_REFERRAL_ON_HOLD;
        NotificationService.checkHCPNotificationType(testData.pe, false);
        Test.stopTest();
    }

    @IsTest
    static void test_checkPatientNotificationType() {
        Test.startTest();
        TestData testData = new TestData();
        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_REFERRAL_ACCEPTED;
        NotificationService.checkPatientNotificationType(testData.pe, false);

        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_REFERRAL_DECLINED;
        NotificationService.checkPatientNotificationType(testData.pe, false);

        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_REFERRAL_ON_HOLD;
        NotificationService.checkPatientNotificationType(testData.pe, false);

        Test.stopTest();
    }

    @IsTest
    static void test_checkPatientNotificationVTType() {
        Test.startTest();
        TestData testData = new TestData();
        Participant_Enrollment__c pe = [
            SELECT
                Id,
                Participant_Status__c,
                Referral_Source__c,
                Clinical_Trial_Profile__r.Patient_Portal_Enabled__c
            FROM Participant_Enrollment__c
            WHERE Id = :testData.pe.Id
        ];
        pe.Referral_Source__c = 'HCP';

        pe.Participant_Status__c = PEStatusState.PE_STATUS_REFERRAL_ACCEPTED;
        NotificationService.checkPatientNotificationVTType(pe);

        pe.Participant_Status__c = PEStatusState.PE_STATUS_REFERRAL_DECLINED;
        NotificationService.checkPatientNotificationVTType(pe);

        pe.Participant_Status__c = PEStatusState.PE_STATUS_REFERRAL_ON_HOLD;
        NotificationService.checkPatientNotificationVTType(pe);

        pe.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = true;
        pe.Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS;
        NotificationService.checkPatientNotificationVTType(pe);
        Test.stopTest();
    }
    @IsTest
    static void test_checkPatientNotificationVT() {
        Test.startTest();
        TestData testData = new TestData();
        Participant_Enrollment__c pe = [
            SELECT
                Id,
                Participant_Status__c,
                Referral_Source__c,
                Clinical_Trial_Profile__r.Patient_Portal_Enabled__c
            FROM Participant_Enrollment__c
            WHERE Id = :testData.pe.Id
        ];
        pe.Referral_Source__c = 'HCP';

        pe.Participant_Status__c = PEStatusState.PE_STATUS_RECEIVED;
        update pe;
        NotificationService.checkPatientNotificationVTType(pe);
        Test.stopTest();
    }

    @IsTest
    static void test_checkPatientNotificationVTT() {
        Test.startTest();
        TestData testData = new TestData();
        Participant_Enrollment__c pe = [
            SELECT
                Id,
                Participant_Status__c,
                Referral_Source__c,
                Clinical_Trial_Profile__r.Patient_Portal_Enabled__c
            FROM Participant_Enrollment__c
            WHERE Id = :testData.pe.Id
        ];
        pe.Referral_Source__c = 'ePR';

        pe.Participant_Status__c = PEStatusState.PE_STATUS_RECEIVED;
        update pe;
        NotificationService.checkPatientNotificationVTType(pe);
        Test.stopTest();
    }

    @IsTest
    static void test_getTopicOrCreateNew() {
        Test.startTest();
        TestData testData = new TestData();
        Participant_Enrollment__c pe = [
            SELECT
                Id,
                Participant_Status__c,
                Referral_Source__c,
                Clinical_Trial_Profile__r.Patient_Portal_Enabled__c
            FROM Participant_Enrollment__c
            WHERE Id = :testData.pe.Id
        ];

        Topic__c topic = NotificationService.getTopicOrCreateNew(null);
        Test.stopTest();
    }

    @IsTest
    static void test_getTopicListOrCreateNewByCOI() {
        Test.startTest();
        Account account = (Account) TestDataFactory.getSObject(
            Account.getSObjectType(),
            new Map<String, Object>{ 'Name' => CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME }
        );
        Participant__c participant = (Participant__c) TestDataFactory.getSObject(
            Participant__c.getSObjectType()
        );
        Therapeutic_Area__c ta = (Therapeutic_Area__c) TestDataFactory.getSObject(
            Therapeutic_Area__c.getSObjectType()
        );
        insert new List<SObject>{ account, participant, ta };

        Therapeutic_Area_Patient__c tap = (Therapeutic_Area_Patient__c) TestDataFactory.getSObject(
            Therapeutic_Area_Patient__c.getSObjectType(),
            new Map<String, Object>{
                'Participant__c' => participant.Id,
                'Therapeutic_Area__c' => ta.Id,
                'Condition_Of_Interest_Order__c' => 0
            }
        );

        List<Therapeutic_Area_Patient__c> tapList = new List<Therapeutic_Area_Patient__c>();
        tapList.add(tap);
        List<Topic__c> res = NotificationService.getTopicListOrCreateNewByCOI(tapList);
        Test.stopTest();
    }
    @isTest
    static void test_getTopicListOrCreateNew() {
        Test.startTest();
        TestData testData = new TestData();
        Participant_Enrollment__c pe = [
            SELECT Id, Clinical_Trial_Profile__c
            FROM Participant_Enrollment__c
            WHERE Id = :testData.pe.Id
        ];

        Clinical_Trial_Profile__c ct = [
            SELECT Id, Therapeutic_Area__c
            FROM Clinical_Trial_Profile__c
            WHERE Id = :pe.Clinical_Trial_Profile__c
        ];

        List<Clinical_Trial_Profile__c> ctpList = new List<Clinical_Trial_Profile__c>();
        ctpList.add(ct);

        List<Topic__c> topics = NotificationService.getTopicListOrCreateNew(ctpList);
        Test.stopTest();
    }
    @isTest
    static void test_getTopicListOrCreateNewByCTPId() {
        Test.startTest();
        TestData testData = new TestData();
        Participant_Enrollment__c pe = [
            SELECT Id, Clinical_Trial_Profile__c
            FROM Participant_Enrollment__c
            WHERE Id = :testData.pe.Id
        ];

        Clinical_Trial_Profile__c ct = [
            SELECT Id, Therapeutic_Area__c
            FROM Clinical_Trial_Profile__c
            WHERE Id = :pe.Clinical_Trial_Profile__c
        ];

        List<Clinical_Trial_Profile__c> ctpList = new List<Clinical_Trial_Profile__c>();
        ctpList.add(ct);

        List<Topic__c> topics = NotificationService.getTopicListOrCreateNewByCTPId(ctpList);
        Test.stopTest();
    }

    @isTest
    static void test_sendNotifications_v1() {
        Test.startTest();
        TestData testData = new TestData();
        Contact piContact = [
            SELECT Id, Email, Language__c, Phone
            FROM Contact
            WHERE Id = :testData.pe.Participant_Contact__c
        ];
        piContact.Language__c = 'en_US';
        piContact.Phone = '+77777777777';
        piContact.Participant_Opt_In_Status_Emails__c = true;

        List<Contact> contacts = new List<Contact>();
        contacts.add(piContact);
        update contacts;

        Task task = new Task();
        task.Subject = 'test';
        task.Reminder_Date__c = Datetime.now();
        task.ReminderDateTime = Datetime.now();
        task.Activity_Datetime__c = Datetime.now().addDays(1);
        task.OwnerId = testData.participantUser.Id;
        task.Visible_For__c = 'Delegates';

        insert task;

        List<Notification__c> notifications = new List<Notification__c>();
        notifications.add(
            new Notification__c(
                Notification_Type__c = 'Message_to_HCP_Patient_Accepted_Type',
                Recipient__c = testData.pe.Participant_Contact__c,
                WhatId__c = testData.pe.Id,
                StartDate__c = Date.today(),
                Task_Id__c = task.Id
            )
        );
        /*        notifications.add(
new Notification__c(
Notification_Type__c = 'Message_to_HCP_Patient_Accepted_Type',
Recipient__c = testData.pe.Participant_Contact__c,
WhatId__c = task.Id,
Task_Id__c=task.Id
)
);
notifications.add(
new Notification__c(
Notification_Type__c = 'Message_to_PT_StdDoc_Certificate_Type',
Recipient__c = testData.pe.Participant_Contact__c, 
WhatId__c = testData.pe.Id, 
Task_Id__c=task.Id
)
);*/

        insert notifications;

        try {
            NotificationService.sendNotifications(notifications);
        } catch (Exception e) {
        }

        Test.stopTest();
    }

    @isTest
    static void test_sendNotifications_v2() {
        Test.startTest();
        TestData testData = new TestData();
        Contact piContact = [
            SELECT Id, Email, Language__c, Phone
            FROM Contact
            WHERE Id = :testData.pe.Participant_Contact__c
        ];
        piContact.Language__c = 'en_US';
        piContact.Phone = '+77777777777';

        List<Contact> contacts = new List<Contact>();
        contacts.add(piContact);
        update contacts;

        Task task = new Task();
        task.Subject = 'test';
        task.Reminder_Date__c = Datetime.now();
        task.ReminderDateTime = Datetime.now();
        task.Activity_Datetime__c = Datetime.now().addDays(1);
        task.OwnerId = testData.participantUser.Id;
        task.Visible_For__c = 'Delegates';

        insert task;

        Topic__c topic = new Topic__c();
        topic.TopicId__c = 'rga134';

        insert topic;

        List<Notification__c> notifications = new List<Notification__c>();
        notifications.add(
            new Notification__c(
                Notification_Type__c = 'Message_to_PI_Access_Level_Changed_Type',
                WhatId__c = piContact.Id,
                Task_Id__c = task.Id,
                Topic__c = topic.Id,
                Recipient__c = testData.pe.Participant_Contact__c
            )
        );
        insert notifications;

        try {
            NotificationService.sendNotifications(notifications);
        } catch (Exception e) {
        }

        Test.stopTest();
    }

    @isTest
    static void test_sendNotification_v3() {
        Test.startTest();
        TestData testData = new TestData();
        Contact piContact = [
            SELECT Id, Email, Language__c, Phone
            FROM Contact
            WHERE Id = :testData.pe.Participant_Contact__c
        ];
        piContact.Language__c = 'en_US';
        piContact.Phone = '+77777777777';

        List<Contact> contacts = new List<Contact>();
        contacts.add(piContact);
        update contacts;

        Task task = new Task();
        task.Subject = 'test';
        task.Reminder_Date__c = Datetime.now();
        task.ReminderDateTime = Datetime.now();
        task.Activity_Datetime__c = Datetime.now().addDays(1);
        task.OwnerId = testData.participantUser.Id;
        task.Visible_For__c = 'Delegates';

        insert task;

        Topic__c topic = new Topic__c();
        topic.TopicId__c = 'rga134';

        insert topic;

        List<Notification__c> notifications = new List<Notification__c>();
        notifications.add(
            new Notification__c(
                Notification_Type__c = 'Message_To_PT_New_Message_Type',
                WhatId__c = testData.pe.Id,
                Task_Id__c = task.Id,
                Topic__c = topic.Id
                //  Recipient__c = testData.pe.Participant_Contact__c
            )
        );
        insert notifications;

        try {
            NotificationService.sendNotifications(notifications);
        } catch (Exception e) {
        }

        Test.stopTest();
    }

    @isTest
    static void test_sendNotifications_v4() {
        Test.startTest();
        TestData testData = new TestData();
        Contact piContact = [
            SELECT Id, Email, Language__c, Phone, Participant_Opt_In_Status_SMS__c
            FROM Contact
            WHERE Id = :testData.pe.Participant_Contact__c
        ];
        piContact.Language__c = 'en_US';
        piContact.Phone = '+77777777777';
        piContact.Participant_Opt_In_Status_SMS__c = true;

        update piContact;

        Task task = new Task();
        task.Subject = 'test';
        task.Reminder_Date__c = Datetime.now();
        task.ReminderDateTime = Datetime.now();
        task.Activity_Datetime__c = Datetime.now().addDays(1);
        task.OwnerId = testData.participantUser.Id;
        task.Visible_For__c = 'Delegates';
        insert task;

        Clinical_Trial_Profile__c ctP = [
            SELECT Id, Suppress_Participant_Emails__c
            FROM Clinical_Trial_Profile__c
            WHERE Id = :testData.ctp.Id
        ];
        ctP.Suppress_Participant_Emails__c = false;
        update ctP;

        List<Notification__c> notifications = new List<Notification__c>();
        notifications.add(
            new Notification__c(
                Notification_Type__c = 'Message_to_PT_COI_Ctp_Start_Enroll_Type',
                Recipient__c = testData.piContact.Id,
                WhatId__c = testData.ctp.Id,
                StartDate__c = Date.today(),
                Task_Id__c = task.Id
            )
        );
        insert notifications;

        try {
            NotificationService.sendNotifications(notifications);
        } catch (Exception e) {
        }

        Test.stopTest();
    }

    @isTest
    static void test_sendNotifications_v5() {
        Test.startTest();
        TestData testdat = new TestData();
        Contact piContact = [
            SELECT Id, Email, Language__c, Phone
            FROM Contact
            WHERE Email = 'pi@emil.com'
        ];
        piContact.Language__c = 'en_US';
        piContact.Phone = '+77777777777';

        List<Contact> contacts = new List<Contact>();
        contacts.add(piContact);
        update contacts;

        List<Notification__c> notifications = new List<Notification__c>();
        notifications.add(
            new Notification__c(
                Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_DATA_AVAILABLE_TYPE,
                Recipient__c = piContact.Id,
                WhatId__c = testdat.pe.Id,
                StartDate__c = Date.today()
            )
        );

        insert notifications;
        try {
            NotificationService.sendNotifications(notifications);
        } catch (Exception e) {
        }

        Test.stopTest();
    }

    @isTest
    static void test_sendNotifications_v6() {
        Test.startTest();
        TestData testdat = new TestData();
        Contact piContact = [
            SELECT
                Id,
                Email,
                Language__c,
                Phone,
                UserCommunityIsDelegate__c,
                Participant_Opt_In_Status_Emails__c
            FROM Contact
            WHERE Id = :testdat.pe.Participant_Contact__c
        ];
        piContact.Language__c = 'en_US';
        piContact.Phone = '+77777777777';
        piContact.UserCommunityIsDelegate__c = false;
        piContact.Participant_Opt_In_Status_Emails__c = true;

        List<Contact> contacts = new List<Contact>();
        contacts.add(piContact);
        update contacts;

        Study_Site__c s = [
            SELECT Id, Suppress_Participant_Emails__c
            FROM Study_Site__c
            WHERE id = :testdat.pe.Study_Site__r.Id
        ];
        s.Suppress_Participant_Emails__c = false;
        update s;

        Task task = new Task();
        task.Subject = 'test';
        task.Reminder_Date__c = Datetime.now();
        task.ReminderDateTime = Datetime.now();
        task.Activity_Datetime__c = Datetime.now().addDays(1);
        task.OwnerId = testDat.participantUser.Id;
        task.Visible_For__c = 'Delegates';
        insert task;

        List<Notification__c> notifications = new List<Notification__c>();
        notifications.add(
            new Notification__c(
                Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_DATA_AVAILABLE_TYPE,
                Recipient__c = piContact.Id,
                WhatId__c = testdat.pe.Id,
                Task_Id__c = task.Id,
                StartDate__c = Date.today()
            )
        );

        insert notifications;
        try {
            NotificationService.sendNotifications(notifications);
        } catch (Exception e) {
        }

        Test.stopTest();
    }
}
