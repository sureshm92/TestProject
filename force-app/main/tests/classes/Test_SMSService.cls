/**
 * Created by Igor Iosifov on 2020-03-24.
 */

@IsTest
public with sharing class Test_SMSService {
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
        piContact.Language__c = 'en_US';
        piContact.Phone = '+77777777777';

        Contact hcpContact = [
            SELECT Id, Email, Language__c, Phone
            FROM Contact
            WHERE Email = 'hcp@emil.com'
        ];
        hcpContact.Language__c = 'en_US';
        hcpContact.Phone = '+7888888888';

        List<Contact> contacts = new List<Contact>();
        contacts.add(piContact);
        contacts.add(hcpContact);
        update contacts;

        delete [SELECT Id FROM Notification__c];

        List<Notification__c> notifications = new List<Notification__c>();
        notifications.add(
            new Notification__c(
                Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_DATA_AVAILABLE_TYPE,
                Recipient__c = piContact.Id,
                WhatId__c = piContact.Id
            )
        );
        notifications.add(
            new Notification__c(
                Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_NEW_STDDOC_TYPE,
                Recipient__c = hcpContact.Id,
                WhatId__c = hcpContact.Id
            )
        );
        insert notifications;
    }

    @IsTest
    static void sendTest() {
        List<Notification__c> notifications = [
            SELECT Id, WhatId__c, Notification_Type__c, Recipient__c
            FROM Notification__c
        ];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RemoteCallHttpCalloutMock());
        SMSService.send(notifications);
        //System.enqueueJob(new Test_SMSService());
        Test.stopTest();

        List<Send_Result__c> sendResults = [
            SELECT Id, Status__c
            FROM Send_Result__c
            WHERE Status__c != 'Sent'
        ];
        System.assert(sendResults.isEmpty());
    }
}
