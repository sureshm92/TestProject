public without sharing class TelevisitAttendeeTriggerHandler {
    public class ManageAttendees extends TriggerHandler {
        public override void afterDelete(List<SObject> oldList) {
            notifyAttendeesRemoved(oldList);
        }
    }

    @TestVisible
    private static void notifyAttendeesRemoved(List<Televisit_Attendee__c> attendeeList) {
        /*
         * Scenarios -
         * Participant as attendee (For minor) - will not occur
         * Participant Delegate as attendee
         * Notfication to delegate when participant is removed - will not occur
         */
        List<Id> allAttendeeContactIds = new List<Id>();
        List<Id> delegateAttendeeConIds = new List<Id>();
        //List<Id> patientDeleToNotify = new List<Id>();

        for (Televisit_Attendee__c attendee : attendeeList) {
            allAttendeeContactIds.add(attendee.Contact__c);
        }

        delegateAttendeeConIds.addAll(
            new Map<Id, Contact>(
                    [
                        SELECT Id
                        FROM Contact
                        WHERE Id IN :allAttendeeContactIds AND UserCommunityIsDelegate__c = TRUE
                    ]
                )
                .keySet()
        );
        if (!delegateAttendeeConIds.isEmpty()) {
            createAttendeeNotifications(
                delegateAttendeeConIds,
                NotificationCatalog.MESSAGE_TO_PT_REMOVED_ATTENDEE_TYPE
            );
        }
    }

    @TestVisible
    private static void createAttendeeNotifications(
        List<Id> attendeeContactIds,
        String notificationType
    ) {
        List<Notification__c> notifications = new List<Notification__c>();
        for (Id conId : attendeeContactIds) {
            notifications.add(
                new Notification__c(
                    Recipient__c = conId,
                    WhatId__c = 'Televisit_Attendee__c',
                    Notification_Type__c = notificationType
                )
            );
        }
        Database.insert(notifications);
    }
}
