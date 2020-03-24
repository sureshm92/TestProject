/**
 * Created by Yulia Yakushenkova on 24.03.2020.
 */

@IsTest
private class Test_NotificationAvailabilityService {
    @IsTest
    static void test_CTPSObject() {
        TestData.loadTestData();
        TestData td = new TestData();
        List<Id> recipientIds = new List<Id>{td.participant.Contact__c};
        List<String> whatIds = new List<String>{td.ctp.Id};
        Contact contact = [SELECT Id FROM Contact WHERE Id = :recipientIds[0]];
        contact.Participant_Opt_In_Status_Emails__c = true;
        update contact;

        Test.startTest();
        NotificationAvailabilityService service = new NotificationAvailabilityService(recipientIds, whatIds);
        Boolean result = service.isAvailable(whatIds[0], 'Participant', NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL, recipientIds[0]);
        Test.stopTest();

        System.assert(result);
    }

    @IsTest
    static void test_PESObject() {
        TestData.loadTestData();
        TestData td = new TestData();
        List<Id> recipientIds = new List<Id>{td.participant.Contact__c};
        List<String> whatIds = new List<String>{td.pe.Id};
        Contact contact = [SELECT Id FROM Contact WHERE Id = :recipientIds[0]];
        contact.Participant_Opt_In_Status_Emails__c = true;
        update contact;

        Test.startTest();
        NotificationAvailabilityService service = new NotificationAvailabilityService(recipientIds, whatIds);
        Boolean result = service.isAvailable(whatIds[0], 'Participant', NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL, recipientIds[0]);
        Test.stopTest();

        System.assert(result);
    }
}