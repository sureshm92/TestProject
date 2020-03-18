/**
 * Created by thehe on 18.03.2020.
 */

@IsTest
private class Test_Batch_CreatePartLoginNotification {
    @IsTest
    static void testBehavior() {
        TestData.loadTestData();
        TestData td = new TestData();
        td.updatePEStatusEnrollmentSuccess();
        List<Contact> contacts = [
                SELECT
                        Id,
                        Current_Participant_Enrollment__c,
                        Next_Notify_Date__c,
                        Participant_Opt_In_Status_Emails__c
                FROM Contact
                WHERE Next_Notify_Date__c <= :Datetime.now().dateGmt()
                AND Current_Participant_Enrollment__c != NULL
        ];

        Test.startTest();
        Batch_CreateParticipantLoginNotification.createNearestLogOutNotification(contacts);
        Test.stopTest();

        List<Notification__c> notifications = [SELECT Id, Notification_Type__c FROM Notification__c];
        System.assertEquals(NotificationCatalog.MESSAGE_TO_PT_HAS_NOT_LOGGED_IN_TYPE, notifications[0].Notification_Type__c);
    }
}