public without sharing class TelevisitAttendeeTriggerHandler {
    public class ManageAttendees extends TriggerHandler {
        public override void afterDelete(List<SObject> oldList) {
            notifyAttendeesRemoved(oldList);
        }
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
