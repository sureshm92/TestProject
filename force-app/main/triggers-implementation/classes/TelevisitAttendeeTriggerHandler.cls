public without sharing class TelevisitAttendeeTriggerHandler {
    public class ManageAttendees extends TriggerHandler {
        public override void afterDelete(List<SObject> oldList) {
            notifyAttendeesRemoved(oldList);
        }
        public override void afterInsert(List<SObject> newList) {
            notifyNewAttendees(newList);
        }
    }

    @TestVisible
    private static void notifyNewAttendees(List<Televisit_Attendee__c> attendeeList) {
        //Insert notifications for new attendees
        Map<Id, Id> attendeeTelevisitMap = new Map<Id, Id>();
        Map<Id, Id> attendeeDelTelevisitMap = new Map<Id, Id>();

        Map<Id, List<Patient_Delegate__c>> participantIdsByDelegates = new Map<Id, List<Patient_Delegate__c>>();

        List<Id> allContactIds = new List<Id>();

        for (Televisit_Attendee__c teleAttendee : attendeeList) {
            allContactIds.add(teleAttendee.Contact__c);
        }
        List<Patient_Delegate__c> patientDelegates = [
            SELECT Participant__r.Contact__c, Contact__c, Primary_Delegate__c
            FROM Patient_Delegate__c
            WHERE Participant__r.Contact__c IN :allContactIds
        ];
        for (Patient_Delegate__c pd : patientDelegates) {
            // allContactIds.add(pd.Contact__c);
            participantIdsByDelegates.get(pd.Participant__r.Contact__c).add(pd);
        }
        for (Televisit_Attendee__c attendee : [
            SELECT Id, Contact__c, Televisit__c
            FROM Televisit_Attendee__c
            WHERE
                Id IN :attendeeList
                AND Contact__r.UserCommunityIsDelegate__c = TRUE
                AND isDeleted = TRUE
            ALL ROWS
        ]) {
            attendeeTelevisitMap.put(attendee.Contact__c, attendee.Televisit__c);
            Id delContactId = TelevisitTriggerHandler.getPrimaryDelegateContactId(
                participantIdsByDelegates,
                attendee.Contact__c
            );
            if (delContactId != null) {
                attendeeDelTelevisitMap.put(delContactId, attendee.Televisit__c);
            }
        }

        createAttendeeNotifications(attendeeTelevisitMap, 'Message_to_PT_Added_Attendee_Type');
        createAttendeeNotifications(
            attendeeDelTelevisitMap,
            'Message_to_PT_Added_Attendee_Del_Type'
        );
    }

    @TestVisible
    private static void notifyAttendeesRemoved(List<Televisit_Attendee__c> attendeeList) {
        /*
         * Scenarios :
         * --------------------------------------------------------------------
         * 1. Participant as attendee (For minor) - will not occur
         * 2. Participant Delegate as attendee
         * 3. Notfication to delegate when participant is removed - will not occur
         */
        //Contact Id => Televisit Id
        Map<Id, Id> delConTeleMap = new Map<Id, Id>();

        for (Televisit_Attendee__c attendee : [
            SELECT Id, Contact__c, Televisit__c
            FROM Televisit_Attendee__c
            WHERE
                Id IN :attendeeList
                AND Contact__r.UserCommunityIsDelegate__c = TRUE
                AND isDeleted = TRUE
            ALL ROWS
        ]) {
            delConTeleMap.put(attendee.Contact__c, attendee.Televisit__c);
        }
        if (!delConTeleMap.isEmpty()) {
            createAttendeeNotifications(
                delConTeleMap,
                NotificationCatalog.MESSAGE_TO_PT_REMOVED_ATTENDEE_TYPE
            );
        }
    }

    @TestVisible
    private static void createAttendeeNotifications(
        Map<Id, Id> contactTelevistMap,
        String notificationType
    ) {
        List<Notification__c> notifications = new List<Notification__c>();
        for (Id conId : contactTelevistMap.keySet()) {
            notifications.add(
                new Notification__c(
                    Recipient__c = conId,
                    WhatId__c = contactTelevistMap.get(conId),
                    Notification_Type__c = notificationType
                )
            );
        }
        Database.insert(notifications);
    }
}
