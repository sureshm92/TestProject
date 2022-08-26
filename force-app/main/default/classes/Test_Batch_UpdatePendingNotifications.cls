@IsTest
private class Test_Batch_UpdatePendingNotifications {
    @IsTest
    static void testBehavior() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
        Contact contactIns = [
            SELECT Id, Email, Language__c, Phone
            FROM Contact
            WHERE Email = 'pi@emil.com'
        ];

        List<Notification__c> notifications = new List<Notification__c>();
        notifications.add(
            new Notification__c(
                Notification_Type__c = NotificationCatalog.Message_to_PT_New_Study_eRP_VT_Type,
                Recipient__c = contactIns.Id,
                WhatId__c = contactIns.Id
            )
        );
        notifications.add(
            new Notification__c(
                Notification_Type__c = NotificationCatalog.Message_to_PT_New_Study_eRP_VT_Type,
                Recipient__c = contactIns.Id,
                WhatId__c = contactIns.Id
            )
        );
        insert notifications;
        Test.startTest();
        DataBase.executeBatch(new Batch_UpdatePendingNotifications());
        Test.stopTest();
    }
}
