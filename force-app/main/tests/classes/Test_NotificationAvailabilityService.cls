/**
 * Created by Yulia Yakushenkova on 24.03.2020.
 */

@IsTest
private class Test_NotificationAvailabilityService {
    @TestSetup
    static void makeData() {
        TriggerHandlerExecutor.bypassHandler(
            TriggerHandlerExecutor.contextExecuteHandler.class            
        );
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.createPIUserOrSendNotification.class
        );
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.CreatePIOrSendNotificationHandler.afterInsert.class
        );
        TriggerHandlerExecutor.execute(StudySiteTriggerHandler.CreatePIOrSendNotificationHandler.class);
        TestData.loadTestData();
        Test.startTest();
        Participant__c participant = [
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
        // List<Id> idList=new List<Id>{participant.Contact__c };
        // Contact contact = [SELECT Id FROM Contact WHERE Id = :participant.Contact__c  ];
        // System.debug('contact====>'+contact);
        //contact.Participant_Opt_In_Status_Emails__c = true;
        HCP_Enrollment__c hcpEnrollment = [
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

        Contact piContact = [
            SELECT Id, Name, Email
            FROM Contact
            WHERE Email = 'pi@emil.com'
            LIMIT 1
        ];
        List<Id> recipientIds = new List<Id>{
            participant.Contact__c,
            hcpEnrollment.HCP_Contact__c,
            piContact.Id
        };
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Id IN :recipientIds];
        for (Contact con : contacts) {
            con.Participant_Opt_In_Status_Emails__c = true;
            con.HCP_Opt_In_Patient_Status_Emails__c = true;
            con.HCP_Opt_In_Referral_Status_Emails__c = true;
        }
        update contacts;
        Test.stopTest();
    }
    @isTest
    static void testCTPSObject() {
        Participant__c participant = [
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
        Clinical_Trial_Profile__c ctp = [SELECT Id FROM Clinical_Trial_Profile__c LIMIT 1];
        List<Id> recipientIds = new List<Id>{ participant.Contact__c };
        List<String> whatIds = new List<String>{ ctp.Id };
        Contact contact = [
            SELECT Id
            FROM Contact
            WHERE Id = :recipientIds[0] AND Participant_Opt_In_Status_Emails__c = TRUE
        ];
        System.debug('contact====>' + contact);
        User users = [
            SELECT Id, ContactId, LastName
            FROM User
            WHERE ContactId = :contact.Id
        ];
        users.timezonesidkey='Asia/Kolkata';
        update users;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Community_PP'];
		insert new PermissionSetAssignment(AssigneeId = users.id, PermissionSetId = ps.Id);
        Test.startTest();
        NotificationAvailabilityService service = new NotificationAvailabilityService(
            recipientIds,
            whatIds
        );
        Notification_Type__mdt notificationType = NotificationService.getNotificationType(
            'Msg_To_PT_Platform_Lvl_Welcme_Msg'
        );
        Boolean result = service.isAvailable(
            whatIds[0],
            'Participant',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[0],
            notificationType,
            null
        );
        service.getOrgWideEmail(contact.Id,whatIds[0],'Study Specific');
        Test.stopTest();
    }

    @isTest
    static void testTaskObject() {
        TestData testData=new TestData();
        Participant__c participant = [
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
        Test.startTest();
        Datetime dateNow = Datetime.now();
        List<Id> recipientIds = new List<Id>{ participant.Contact__c };
        Task task = new Task();
        task.Subject = 'test';
        task.Reminder_Date__c = dateNow;
        task.ReminderDateTime = dateNow;
        task.Activity_Datetime__c = Datetime.now().addDays(1);
        task.whatId = participant.Id;
        task.Visible_For__c = 'Owner;Delegates';
        task.Community_Template_Name__c='PatientPortal';
        insert task;
        List<String> whatIds = new List<String>{ task.Id };
        Contact contact = [SELECT Id FROM Contact WHERE Id = :recipientIds[0]];
        contact.Participant_Opt_In_Status_Emails__c = true;
        contact.Is_Patient_User_Created__c = true;
        update contact;

        NotificationAvailabilityService service = new NotificationAvailabilityService(
            recipientIds,
            whatIds
        );
        Notification_Type__mdt notificationType = NotificationService.getNotificationType(
            'Msg_To_PT_Platform_Lvl_Welcme_Msg'
        );
        Boolean result = service.isAvailable(
            whatIds[0],
            'Participant',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[0],
            notificationType,
            null
        );
        service.getOrgWideEmail(contact.Id,whatIds[0],'Study Specific');
        service.isJanssenPPTemplate(whatIds[0]);
        service.isUpdatedPPTemplate(whatIds[0],contact.Id);
        Test.stopTest();

        //System.assert(result);
    }

    @isTest
    static void testCaseObject() {
        Participant__c participant = [
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
        List<Id> recipientIds = new List<Id>{ participant.Contact__c };
        Case newCase = new Case();
        newCase.Status = 'New';
        newCase.Origin = 'Web';
        newCase.Description = 'Description';
        newCase.ContactId = participant.Contact__c;
        insert newCase;
        List<String> whatIds = new List<String>{ newCase.Id };
        Contact contact = [SELECT Id FROM Contact WHERE Id = :recipientIds[0]];
        contact.Participant_Opt_In_Status_Emails__c = true;
        contact.Is_Patient_User_Created__c = true;
        update contact;

        Test.startTest();
        NotificationAvailabilityService service = new NotificationAvailabilityService(
            recipientIds,
            whatIds
        );
        Notification_Type__mdt notificationType = NotificationService.getNotificationType(
            'Msg_To_PT_Platform_Lvl_Welcme_Msg'
        );
        Boolean result = service.isAvailable(
            whatIds[0],
            'Participant',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[0],
            notificationType,
            null
        );
        Test.stopTest();

        //System.assert(result);
    }

    @isTest
    static void testPEObject() {
        TestData testData=new TestData();
        Participant__c participant = [
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

        Participant_Enrollment__c pe = [
            SELECT Id,Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c,Study_Site__r.Clinical_Trial_Profile__r.PPTemplate__c
            FROM Participant_Enrollment__c
            WHERE Screening_ID__c = 'PESCR1'
            LIMIT 1
        ];
        pe.Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c = 'Janssen';
        pe.Study_Site__r.Clinical_Trial_Profile__r.PPTemplate__c='PP 2.0';
        update pe;
        Contact delegatecontact = new Contact(
            FirstName = 'Joy',
            LastName = 'JoyDad',
            Email = 'Joypatient@somemail.com',
            AccountId = testData.participant.Contact__r.AccountId,
            Current_Participant_Enrollment__c =pe.Id,
            userCommunityMode__c = CommunityService.USER_MODE_PI,
            userCommunytyType__c = CommunityService.USER_MODE_PI,
            UserCommunityIsDelegate__c = true
        );
        insert delegatecontact;
        Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = delegatecontact.Id,
            Contact__r = delegatecontact,
            Participant__c =participant.Id,
            Participant__r =participant
        );
        insert patientDelegate;
        Patient_delegate_enrollment__c patientEnrollment =new Patient_delegate_enrollment__c(
            Participant_Enrollment__c = pe.Id,
            Patient_Delegate__c= patientDelegate.id,
            Study_Email_Consent__c=true,
            Study_SMS_Consent__c=true,
            Study_Phone_Consent__c=true,
            Study_Direct_Mail_Consent__c=true
        ); 
        insert patientEnrollment;

        List<Id> recipientIds = new List<Id>{ participant.Contact__c,delegatecontact.Id };
        List<String> whatIds = new List<String>{ pe.Id };

        Test.startTest();
        Notification_Type__mdt notificationType = NotificationService.getNotificationType(
            'Msg_To_PT_Platform_Lvl_Welcme_Msg'
        );
        NotificationAvailabilityService service = new NotificationAvailabilityService(
            recipientIds,
            whatIds
        );

        Boolean resultPartcipant = service.isAvailable(
            whatIds[0],
            'Participant',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[0],
            notificationType,
            null
        );
		service.getOrgWideEmail(participant.Contact__c,whatIds[0],'Study Specific');
        service.isJanssenPPTemplate(whatIds[0]);
        service.isUpdatedPPTemplate(whatIds[0],participant.Contact__c);
        Test.stopTest();

        System.assertEquals(resultPartcipant, false);
    }

    @isTest
    static void testPEObject2() {
        HCP_Enrollment__c hcpEnrollment = [
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
        List<Id> recipientIds = new List<Id>{ hcpEnrollment.HCP_Contact__c };
        Participant_Enrollment__c pe = [
            SELECT Id
            FROM Participant_Enrollment__c
            WHERE Screening_ID__c = 'PESCR1'
            LIMIT 1
        ];
        List<String> whatIds = new List<String>{ pe.Id };
        Test.startTest();
        Notification_Type__mdt notificationType = NotificationService.getNotificationType(
            'Msg_To_PT_Platform_Lvl_Welcme_Msg'
        );
        NotificationAvailabilityService service = new NotificationAvailabilityService(
            recipientIds,
            whatIds
        );

        Boolean resultPartcipant = service.isAvailable(
            whatIds[0],
            'HCP',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[0],
            notificationType,
            null
        );

        Test.stopTest();
    }

    @isTest
    static void testPEObject3() {
        Contact piContact = [
            SELECT Id, Name, Email
            FROM Contact
            WHERE Email = 'pi@emil.com'
            LIMIT 1
        ];

        List<Id> recipientIds = new List<Id>{ piContact.Id };
        Participant_Enrollment__c pe = [
            SELECT Id
            FROM Participant_Enrollment__c
            WHERE Screening_ID__c = 'PESCR1'
            LIMIT 1
        ];
        List<String> whatIds = new List<String>{ pe.Id };
        Test.startTest();
        Notification_Type__mdt notificationType = NotificationService.getNotificationType(
            'Msg_To_PT_Platform_Lvl_Welcme_Msg'
        );
        NotificationAvailabilityService service = new NotificationAvailabilityService(
            recipientIds,
            whatIds
        );

        Boolean resultPartcipant = service.isAvailable(
            whatIds[0],
            'PI',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[0],
            notificationType,
            null
        );

        Test.stopTest();
    }
    @isTest
    static void otherObjectsSendNotification() {
        TriggerHandlerExecutor.bypassHandler(TelevisitTriggerHandler.NotifyAttendees.class);
        TriggerHandlerExecutor.bypassHandler(TelevisitTriggerHandler.TelevisitEventTrigger.class);
        TriggerHandlerExecutor.bypassHandler(TelevisitTriggerHandler.TelevisitRescheduleTrigger.class);
        TestData testData=new TestData();
        Test.startTest();
        Participant__c participant = [
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
        List<Id> recipientIds = new List<Id>{ participant.Contact__c };
        HCP_Enrollment__c hcpEnrollment = [ SELECT Id FROM HCP_Enrollment__c WHERE HCP_Contact__r.LastName = 'HCPTD' LIMIT 1];
        Contact contact = [SELECT Id FROM Contact WHERE Id = :recipientIds[0]];
        contact.Participant_Opt_In_Status_Emails__c = true;
        contact.Is_Patient_User_Created__c = true;
        update contact;
        Televisit__c tVisits = new Televisit__c(
                Duration__c = '30 minutes',
                Title__c = 'Visit 0',
                Visit_Date__c = Date.newInstance(2022, 4, 29),
                Start_Time__c = Time.newInstance(8, 0, 0, 0),
            	Participant_Enrollment__c=testData.pe.Id
            );
        insert tVisits;
        Televisit__c tel=[select id,Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,Participant_Enrollment__r.Clinical_Trial_Profile__r.PPTemplate__c from Televisit__c where id=:tVisits.Id];
        tel.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c='Janssen';
        tel.Participant_Enrollment__r.Clinical_Trial_Profile__r.PPTemplate__c ='PP 2.0';
        update tel;
        Televisit_Attendee__c taObj = new Televisit_Attendee__c();
        taObj.Attendee_Type__c = 'Participant';
        taObj.Televisit__c = tVisits.Id;
        taObj.Contact__c = testData.pe.Participant_Contact__c;
        insert taObj;
        List<String> whatIds = new List<String>
        {participant.Id,
         hcpEnrollment.Id,
         contact.Id,
         testData.ss.Id,
         tVisits.id,
         taObj.Id};
        NotificationAvailabilityService service = new NotificationAvailabilityService(
            recipientIds,
            whatIds
        );
        Notification_Type__mdt notificationType = NotificationService.getNotificationType(
            'Msg_To_PT_Platform_Lvl_Welcme_Msg'
        );
        //for objType = Participant
        Boolean resultPart = service.isAvailable(
            whatIds[0],
            'Participant',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[0],
            notificationType,
            null
        );
        //for objType = HCPEnrollment
        Boolean resultHCP = service.isAvailable(
            whatIds[1],
            'Participant',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[0],
            notificationType,
            null
        );
        //for recipientType = HCP and ObjectType =HCPEnrollment
        Boolean resultHCPEnrollment = service.isAvailable(
            whatIds[1],
            'HCP',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[0],
            notificationType,
            null
        );
        //For recipientType = HCP and ObjectType =Contact
        Boolean resultHCPCon = service.isAvailable(
            whatIds[2],
            'HCP',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[0],
            notificationType,
            null
        );
        //For objType = Contact
        Boolean resultCon = service.isAvailable(
            whatIds[2],
            'Participant',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[0],
            notificationType,
            null
        );
        //For recipientType = PI and objType = Contact
        Boolean resultPICon = service.isAvailable(
            whatIds[2],
            'PI',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[0],
            notificationType,
            null
        );
        //For objType = Study Site
        Boolean resultStudySite = service.isAvailable(
            whatIds[3],
            'Participant',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[0],
            notificationType,
            null
        );
        //For recipientType = PI objType = Study Site
        Boolean resultPIStudySite = service.isAvailable(
            whatIds[3],
            'PI',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[0],
            notificationType,
            null
        );
        //For objType = Televisit
        Boolean resultTelevisit = service.isAvailable(
            whatIds[4],
            'Participant',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[0],
            notificationType,
            null
        );
        //For recipientType = PI and objType = Televisit
        Boolean resultPITelevisit = service.isAvailable(
            whatIds[4],
            'PI',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[0],
            notificationType,
            null
        );
        //For objType = TelevisitAttendee
        Boolean resultTelevisitAtt = service.isAvailable(
            whatIds[5],
            'Participant',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[0],
            notificationType,
            null
        );
        //For recipientType = PI and objType = TelevisitAttendee
        Boolean resultPITelevisitAtt = service.isAvailable(
            whatIds[5],
            'PI',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[0],
            notificationType,
            null
        );
        //For objType = NULL
        Boolean resultObjNull = service.isAvailable(
            null,
            'Participant',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[0],
            notificationType,
            null
        );
        service.getOrgWideEmail(contact.Id,whatIds[3],'Study Specific');
        service.isJanssenPPTemplate(whatIds[4]);
        service.isJanssenPPTemplate(whatIds[5]);
        Test.stopTest();
    }
}