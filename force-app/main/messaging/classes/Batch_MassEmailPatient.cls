/**
 * Created by Olga Skrynnikova on 12/6/2019.
 */ 

public without sharing class Batch_MassEmailPatient implements Database.Batchable<SObject>, Database.Stateful {
    private Notification__c notification;
    private List<Id> processedContacts;

    public Batch_MassEmailPatient(Notification__c notification) {
        this.notification = notification;
        processedContacts = new List<Id>();
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(
            [
                SELECT Id, Contact__c, Topic__c
                FROM Contact_Topic__c
                WHERE Topic__c = :notification.Topic__c
            ]
        );
    }

    public void execute(Database.BatchableContext bc, List<Contact_Topic__c> contactTopics) {
        List<Id> partContIds = new List<Id>();
        for (Contact_Topic__c con : contactTopics)
            partContIds.add(con.Contact__c);

        List<Notification__c> notificationsForPatients = new List<Notification__c>();
        for (Id conId : partContIds) {
            notificationsForPatients.add(
                new Notification__c(
                    WhatId__c = notification.WhatId__c,
                    Recipient__c = conId,
                    Notification_Type__c = notification.Notification_Type__c,
                    Status__c = NotificationService.NOTIFICATION_STATUS_PENDING
                )
            );
        }

        try {
            insert notificationsForPatients;
        } catch (DmlException e) {
        }
    }

    public void finish(Database.BatchableContext bc) {
        Database.executeBatch(new Batch_MassEmailDelegate(notification, processedContacts));
    }
}
