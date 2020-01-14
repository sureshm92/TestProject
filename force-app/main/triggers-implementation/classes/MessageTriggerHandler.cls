/**
 * Created by Igor Malyuta on 24.12.2019.
 */

public without sharing class MessageTriggerHandler {

    public class SendEmailHandler extends TriggerHandler {

        public override void afterInsert(List<SObject> newList) {
            sendEmails(JSON.serialize(newList));
        }
    }

    @TestVisible
    @Future
    private static void sendEmails(String messagesJSON) {
        List<Message__c> messages = (List<Message__c>) JSON.deserialize(messagesJSON, (List<Message__c>.class));
        List<Id> conversationIds = new List<Id>();
        for(Message__c mes : messages) conversationIds.add(mes.Conversation__c);

        Map<Id, Conversation__c> conversationMap = new Map<Id, Conversation__c>([
                SELECT
                        Id,
                        haveUnreadForParticipant__c,
                        haveUnreadForPI__c,
                        Participant_Enrollment__c,
                        Participant_Enrollment__r.Participant_Contact__c,
                        Participant_Enrollment__r.Study_Site__r.Principal_Investigator__c,
                        Participant_Enrollment__r.Study_Site__c
                FROM Conversation__c
                WHERE Id IN: conversationIds
        ]);

        List<Id> participantConIds = new List<Id>();
        List<Id> piContactIds = new List<Id>();
        for(Conversation__c con : conversationMap.values()) {
            participantConIds.add(con.Participant_Enrollment__r.Participant_Contact__c);
            piContactIds.add(con.Participant_Enrollment__r.Study_Site__r.Principal_Investigator__c);
        }

//        Map<Id, List<Contact>> delegatedCntsByParticipant =
//                PatientDelegateService.getDelegatedCntsByParticipantCnt(participantConIds, new List<String>());

        List<Site_Staff__c> siteStaff = [
                SELECT Site_Contact__c, Study_Site__r.Principal_Investigator__c
                FROM Site_Staff__c
                WHERE Study_Site__r.Principal_Investigator__c IN:piContactIds
        ];
        Map<Id, List<Id>> staffContactByPI = new Map<Id, List<Id>>();
        for(Site_Staff__c staff : siteStaff) {
            Id piContact = staff.Study_Site__r.Principal_Investigator__c;
            if(!staffContactByPI.containsKey(piContact)) staffContactByPI.put(piContact, new List<Id>());
            staffContactByPI.get(piContact).add(staff.Site_Contact__c);
        }

        List<Notification__c> notifications = new List<Notification__c>();
        for(Message__c mes : messages) {
            Id headRecipientId;
            String notificationType;
            Conversation__c conversation = conversationMap.get(mes.Conversation__c);
            if(conversation.haveUnreadForPI__c) {
                notificationType = NotificationService.MESSAGE_TO_PI_NEW_MESSAGE_TYPE;
                headRecipientId = conversation.Participant_Enrollment__r.Study_Site__r.Principal_Investigator__c;

                notifications.add(new Notification__c(
                        Recipient__c = headRecipientId,
                        WhatId__c = conversation.Participant_Enrollment__c,
                        Notification_Type__c = notificationType
                ));

                List<Id> staffContactIds = staffContactByPI.get(headRecipientId);
                if (staffContactIds != null) {
                    for(Id staffConId : staffContactByPI.get(headRecipientId)) {
                        notifications.add(new Notification__c(
                                Recipient__c = staffConId,
                                WhatId__c = conversation.Participant_Enrollment__c,
                                Notification_Type__c = notificationType
                        ));
                    }
                }
            } else if(conversation.haveUnreadForParticipant__c) {

            }
        }

        if(!notifications.isEmpty()) insert notifications;
    }
}