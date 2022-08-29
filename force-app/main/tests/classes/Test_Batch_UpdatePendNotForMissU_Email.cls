@IsTest
public class Test_Batch_UpdatePendNotForMissU_Email {
    @TestSetup
    static void testSetup() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();

        Contact piContact = [
            SELECT Id, Email, Language__c, Phone
            FROM Contact
            WHERE Email = 'pi@emil.com'
        ];

        List<Notification__c> notifications = new List<Notification__c>();

        notifications.add(
            new Notification__c(
                Notification_Type__c = NotificationCatalog.Message_to_PT_has_not_Logged_In_Type,
                Recipient__c = piContact.Id,
                WhatId__c = piContact.Id,
                Status__c = 'Pending'
            )
        );
        insert notifications;
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(notifications[0].Id, yesterday);
    }

    @IsTest
    static void test1() {
        database.executeBatch(new Batch_UpdatePendNotForMissU_EmailSMSPush(), 200);
    }
}
