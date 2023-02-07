/**
* Created by Yulia Yakushenkova on 24.03.2020.
*/

@IsTest
private class Test_NotificationAvailabilityService {
    @TestSetup
    static void makeData() {
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
        
        Contact piContact = [SELECT Id, Name,Email FROM Contact WHERE Email='pi@emil.com' LIMIT 1 ];
        List<Id> recipientIds = new List<Id>{
            participant.Contact__c,
                hcpEnrollment.HCP_Contact__c,
                piContact.Id
                };   
                    List<Contact> contacts = [SELECT Id FROM Contact WHERE Id IN :recipientIds];
        for(Contact con:contacts){
            con.Participant_Opt_In_Status_Emails__c = true;
            con.HCP_Opt_In_Patient_Status_Emails__c = true;
            con.HCP_Opt_In_Referral_Status_Emails__c = true;}
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
        Clinical_Trial_Profile__c ctp=[Select Id from Clinical_Trial_Profile__c limit 1];
        List<Id> recipientIds = new List<Id>{ participant.Contact__c };
            List<String> whatIds = new List<String>{ ctp.Id };
                Contact contact = [SELECT Id FROM Contact WHERE Id = :recipientIds[0] AND Participant_Opt_In_Status_Emails__c=TRUE ];
        System.debug('contact====>'+contact);
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
    }
    
    @isTest
    static void testTaskObject() {
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
        task.whatId=participant.Id;
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
        
        System.assert(result);
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
        
        System.assert(result);
    }
    
    @isTest
    static void testPEObject() {
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
        
        Participant_Enrollment__c pe=[Select Id from Participant_Enrollment__c where Screening_ID__c='PESCR1' LIMIT 1];
        
        List<Id> recipientIds = new List<Id>{
            participant.Contact__c
                
                };
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
        List<Id> recipientIds = new List<Id>{
            hcpEnrollment.HCP_Contact__c
                };
                    Participant_Enrollment__c pe=[Select Id from Participant_Enrollment__c where Screening_ID__c='PESCR1' LIMIT 1];
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
        
        Contact piContact = [SELECT Id, Name,Email FROM Contact WHERE Email='pi@emil.com' LIMIT 1 ];
        
        List<Id> recipientIds = new List<Id>{
            piContact.Id
                };
                    Participant_Enrollment__c pe=[Select Id from Participant_Enrollment__c where Screening_ID__c='PESCR1' LIMIT 1];
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
    
    
    
}