/**
 * Created by Igor Iosifov on 2020-02-03.
 */

public with sharing class Batch_ConversationReminder extends Batch_ScheduledAbstract {

    Map<Id, Integer> contactsAndTheirThreads = new Map<Id, Integer>();

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
                ORDER BY Study_Site__c
        ];

        Map<Id, Map<Id, List<Site_Staff__c>>> piWithHisSitesAndTeam = new Map<Id, Map<Id, List<Site_Staff__c>>>();
        for (Site_Staff__c siteStaff : siteStaffs) {
            Id piContactId = siteStaff.Study_Site__r.Principal_Investigator__c;
            if (!piWithHisSitesAndTeam.containsKey(piContactId)) {
                piWithHisSitesAndTeam.put(piContactId, new Map<Id, List<Site_Staff__c>>());
            }
            if (!piWithHisSitesAndTeam.get(piContactId).containsKey(siteStaff.Study_Site__c)) {
                piWithHisSitesAndTeam.get(piContactId).put(siteStaff.Study_Site__c, new List<Site_Staff__c>());
            }
            piWithHisSitesAndTeam.get(piContactId).get(siteStaff.Study_Site__c).add(siteStaff);
        }

        //count pending threads for each delegate and PI
        for (Conversation__c conversation : conversations) {
            Integer unreadConversationCount;

            Id currentPI = conversation.Participant_Enrollment__r.PI_Contact__c;
            unreadConversationCount = contactsAndTheirThreads.get(currentPI) == null ? 0 : contactsAndTheirThreads.get(currentPI);
            contactsAndTheirThreads.put(currentPI, ++unreadConversationCount);

            List<Site_Staff__c> staffs = piWithHisSitesAndTeam.get(currentPI).get(conversation.Participant_Enrollment__r.Study_Site__c);
            if (staffs != null && !staffs.isEmpty()) {
                for (Site_Staff__c siteStaff : staffs) {
                    Id contactId = siteStaff.Site_Contact__c;
                    unreadConversationCount = contactsAndTheirThreads.get(contactId) == null ? 0 : contactsAndTheirThreads.get(contactId);
                    contactsAndTheirThreads.put(contactId, ++unreadConversationCount);
                }
            }
        }
    }

    public override void finish(Database.BatchableContext param1) {
        super.finish(param1);
        // checking if contact has unread conversations or not
        List<Contact> contacts = [SELECT Id, Unread_Conversation_Count__c FROM Contact];
        List<Contact> contactsToUpdate = new List<Contact>();

        for (Contact contact : contacts) {
            //case 1 and 2: if contact doesn't have unread messages
            if (!contactsAndTheirThreads.containsKey(contact.Id)) {
                // we're not updating if field Unread_Conversation_Count is already equals 0
                if (contact.Unread_Conversation_Count__c == 0) {
                    continue;
                } else {
                    contact.Unread_Conversation_Count__c = 0;
                    contactsToUpdate.add(contact);
                }
            } else {
                contact.Unread_Conversation_Count__c = contactsAndTheirThreads.get(contact.Id);
                contactsToUpdate.add(contact);
            }
        }
        update contactsToUpdate;

        //create notification
        List<Notification__c> notifications = new List<Notification__c>();
        for (Id contactId : contactsAndTheirThreads.keySet()) {
            notifications.add(new Notification__c(
                    Recipient__c = contactId,
                    WhatId__c = contactId,
                    Notification_Type__c = NotificationCatalog.MESSAGE_TO_PI_HAS_UNREAD_CONVERSATION));
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