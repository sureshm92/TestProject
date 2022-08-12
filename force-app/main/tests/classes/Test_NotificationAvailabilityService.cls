/**
 * Created by Yulia Yakushenkova on 24.03.2020.
 */

@IsTest
private class Test_NotificationAvailabilityService {
    @TestSetup
    static void makeData() {
        TestData.loadTestData();
    }
    @isTest
    static void testCTPSObject() {
        TestData td = new TestData();
        List<Id> recipientIds = new List<Id>{ td.participant.Contact__c };
        List<String> whatIds = new List<String>{ td.ctp.Id };
        Contact contact = [SELECT Id FROM Contact WHERE Id = :recipientIds[0]];
        contact.Participant_Opt_In_Status_Emails__c = true;
        update contact;

        Test.startTest();
        NotificationAvailabilityService service = new NotificationAvailabilityService(
            recipientIds,
            whatIds
        );
        Boolean result = service.isAvailable(
            whatIds[0],
            'Participant',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[0],
            null
        );
        Test.stopTest();

        System.assert(result);
    }

    @isTest
    static void testParticipantObject() {
        TestData td = new TestData();
        List<Id> recipientIds = new List<Id>{ td.participant.Contact__c };
        List<String> whatIds = new List<String>{ td.participant.Id };
        Contact contact = [SELECT Id FROM Contact WHERE Id = :recipientIds[0]];
        contact.Participant_Opt_In_Status_Emails__c = true;
        update contact;

        Test.startTest();
        NotificationAvailabilityService service = new NotificationAvailabilityService(
            recipientIds,
            whatIds
        );
        Boolean result = service.isAvailable(
            whatIds[0],
            'Participant',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[0],
            null
        );
        Boolean resultNull = service.isAvailable(
            null,
            'Participant',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[0],
            null
        );
        Test.stopTest();

        System.assert(result);
    }

    @isTest
    static void testTaskObject() {
        TestData td = new TestData();
        Test.startTest();
        Datetime dateNow = Datetime.now();
        List<Id> recipientIds = new List<Id>{ td.participant.Contact__c };
        Task task = new Task();
        task.Subject = 'test';
        task.Reminder_Date__c = dateNow;
        task.ReminderDateTime = dateNow;
        task.Activity_Datetime__c = Datetime.now().addDays(1);
        //task.OwnerId = td.participantUser.Id;
        task.Visible_For__c = 'Owner;Delegates';
        insert task;
        List<String> whatIds = new List<String>{ task.Id };
        Contact contact = [SELECT Id FROM Contact WHERE Id = :recipientIds[0]];
        contact.Participant_Opt_In_Status_Emails__c = true;
        update contact;

        NotificationAvailabilityService service = new NotificationAvailabilityService(
            recipientIds,
            whatIds
        );
        Boolean result = service.isAvailable(
            whatIds[0],
            'Participant',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[0],
            null
        );
        Test.stopTest();

        System.assert(result);
    }

    @isTest
    static void testCaseObject() {
        TestData td = new TestData();
        List<Id> recipientIds = new List<Id>{ td.participant.Contact__c };
        Case newCase = new Case();
        newCase.Status = 'New';
        newCase.Origin = 'Web';
        newCase.Description = 'Description';
        newCase.ContactId = td.participant.Contact__c;
        insert newCase;
        List<String> whatIds = new List<String>{ newCase.Id };
        Contact contact = [SELECT Id FROM Contact WHERE Id = :recipientIds[0]];
        contact.Participant_Opt_In_Status_Emails__c = true;
        update contact;

        Test.startTest();
        NotificationAvailabilityService service = new NotificationAvailabilityService(
            recipientIds,
            whatIds
        );
        Boolean result = service.isAvailable(
            whatIds[0],
            'Participant',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[0],
            null
        );
        Test.stopTest();

        System.assert(result);
    }

    @isTest
    static void testPEObject() {
        TestData td = new TestData();
        List<Id> recipientIds = new List<Id>{
            td.participant.Contact__c,
            td.hcpEnrollment.HCP_Contact__c,
            td.piContact.Id
        };
        List<String> whatIds = new List<String>{ td.pe.Id };
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Id IN :recipientIds];
        contacts[0].Participant_Opt_In_Status_Emails__c = true;
        contacts[1].HCP_Opt_In_Patient_Status_Emails__c = true;
        contacts[1].HCP_Opt_In_Referral_Status_Emails__c = true;
        update contacts;

        Test.startTest();
        NotificationAvailabilityService service = new NotificationAvailabilityService(
            recipientIds,
            whatIds
        );
        Boolean resultPartcipant = service.isAvailable(
            whatIds[0],
            'Participant',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[0],
            null
        );
        //For HCP
        Boolean resultHCP = service.isAvailable(
            whatIds[0],
            'HCP',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[1],
            null
        );
        //For PI
        Boolean resultPI = service.isAvailable(
            whatIds[0],
            'PI',
            NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL,
            recipientIds[2],
            null
        );
        Test.stopTest();

        System.assertEquals(resultPartcipant, false);
        System.assert(resultHCP);
        System.assert(resultPI);
    }
}
