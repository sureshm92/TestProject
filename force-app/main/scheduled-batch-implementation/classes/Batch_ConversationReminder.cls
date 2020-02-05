/**
 * Created by Igor Iosifov on 2020-02-03.
 */

public with sharing class Batch_ConversationReminder extends Batch_ScheduledAbstract {

    public Database.QueryLocator start(Database.BatchableContext param1) {
        Datetime fiveDaysAgo = Datetime.now().addDays(-5);

        return Database.getQueryLocator([
                SELECT Id,
                        Participant_Enrollment__r.PI_Contact__c,
                        Participant_Enrollment__r.Study_Site__c
                FROM Conversation__c
                WHERE haveUnreadForPI__c = TRUE
                AND FirstUnreadDate__c <= :fiveDaysAgo
        ]);
    }

    public void execute(Database.BatchableContext param1, List<Conversation__c> conversations) {
        List<String> pIContacts = new List<String>();
        List<String> studySites = new List<String>();

        for (Conversation__c conversation : conversations) {
            pIContacts.add(conversation.Participant_Enrollment__r.PI_Contact__c);
            studySites.add(conversation.Participant_Enrollment__r.Study_Site__c);
        }

        List<Site_Staff__c> siteStaffs = [
                SELECT Id,
                        Site_Contact__c,
                        Study_Site__r.Principal_Investigator__c,
                        Study_Site__c
                FROM Site_Staff__c
                WHERE Study_Site__r.Principal_Investigator__c IN :pIContacts
                AND Study_Site__c IN :studySites
        ];

        Map<Id, Integer> contactsAndTheirThreads = new Map<Id, Integer>();

        //filling the map with keys
        for (Site_Staff__c siteStaff : siteStaffs) {
            contactsAndTheirThreads.put(siteStaff.Site_Contact__c, 0);
            contactsAndTheirThreads.put(siteStaff.Study_Site__r.Principal_Investigator__c, 0);
        }

        //count pending threads for each delegate and PI
        for (Site_Staff__c siteStaff : siteStaffs) {
            Integer unreadConversationCount;

            Id currentDelegate = siteStaff.Site_Contact__c;
            Id currentPI = siteStaff.Study_Site__r.Principal_Investigator__c;

            // checking if there are no PI's delegates
            if (currentDelegate != currentPI) {
                unreadConversationCount = contactsAndTheirThreads.get(currentDelegate);
                contactsAndTheirThreads.put(currentDelegate, ++unreadConversationCount);
            }

            unreadConversationCount = contactsAndTheirThreads.get(currentPI);
            contactsAndTheirThreads.put(currentPI, ++unreadConversationCount);
        }

        List<Contact> contactsToUpdate = new List<Contact>();
        for (Id contactId : contactsAndTheirThreads.keySet()) {
            Contact contactToUpdate = new Contact(Id = contactId, Unread_Conversation_Count__c = contactsAndTheirThreads.get(contactId));
            contactsToUpdate.add(contactToUpdate);
        }
        update contactsToUpdate;

        //create notification
        List<Notification__c> notifications = new List<Notification__c>();

        for (Id contactId : contactsAndTheirThreads.keySet()) {
            notifications.add(new Notification__c(
                    Recipient__c = contactId,
                    WhatId__c = contactId,
                    Notification_Type__c = NotificationCatalog.MESSAGE_TO_PI_HAS_UNREAD_CONVERSATION));
//                    Status__c = NotificationService.NOTIFICATION_STATUS_PENDING));
        }
        insert notifications;
    }

    public override Type getType() {
        return Batch_ConversationReminder.class;
    }

    public override String getBatchDescription() {
        return 'This job sends Email notification to PI and his delegates if they have messages that are unread for 5 days and more';
    }
}