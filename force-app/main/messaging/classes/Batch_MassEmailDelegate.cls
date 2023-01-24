/**
 * Created by Olga Skrynnikova on 12/6/2019.
 */ 

public without sharing class Batch_MassEmailDelegate implements Database.Batchable<SObject>, Database.Stateful {
    private Notification__c notification;
    private List<Id> processedContacts;

    public Batch_MassEmailDelegate(Notification__c notification, List<Id> processedContacts) {
        this.notification = notification;
        this.processedContacts = processedContacts;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(
            [
                SELECT Id, Email, Participant_Opt_In_Status_Emails__c
                FROM Contact
                WHERE Id IN :processedContacts
            ]
        );
    }

    public void execute(Database.BatchableContext bc, List<SObject> sObjects) {
        Map<Id, List<Contact>> delegatesContactById = PatientDelegateEnrollmentService.getDelegatedCntsByParticipantCnt(
            processedContacts,
            new List<String>{ 'Email', 'Participant_Opt_In_Status_Emails__c' }
        ); 
        List<Notification__c> notificationsForMassEmailDelegate = new List<Notification__c>();
        for (Id delId : delegatesContactById.keySet()) {
            notificationsForMassEmailDelegate.add(
                new Notification__c(
                    WhatId__c = notification.WhatId__c,
                    Recipient__c = delId,
                    IsDelegate__c = true,
                    Notification_Type__c = notification.Notification_Type__c,
                    Status__c = NotificationService.NOTIFICATION_STATUS_PENDING
                )
            );
        }

        try {
            insert notificationsForMassEmailDelegate;
        } catch (DmlException e) {
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}
