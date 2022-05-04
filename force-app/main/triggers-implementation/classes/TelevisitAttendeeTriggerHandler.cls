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
        /*
        //Contact Id => List<Patient_Delegate__c>
        Map<Id, List<Patient_Delegate__c>> contactDelegateMap = new Map<Id, List<Patient_Delegate__c>>();
        for (
            Patient_Delegate__c delegate : PatientDelegateService.getPDelegates(
                allAttendeeContactIds
            )
        ) {
            if (contactDelegateMap.containsKey(delegate.Participant__r.Contact__r.Id)) {
                contactDelegateMap.get(delegate.Participant__r.Contact__r.Id).add(delegate);
            } else {
                contactDelegateMap.put(
                    delegate.Participant__r.Contact__r.Id,
                    new List<Patient_Delegate__c>{ delegate }
                );
            }
        }
        if (!contactDelegateMap.isEmpty()) {
            //Look for number of delegates
            for (Id ptConId : contactDelegateMap.keySet()) {
                if (contactDelegateMap.get(ptConId).size() == 1) {
                    //Sole delegate should be notified
                    patientDeleToNotify.add(contactDelegateMap.get(ptConId)[0].Contact__c);
                } else if (contactDelegateMap.get(ptConId).size() > 1) {
                    //For multiple delegates notify primary delegate
                    for (Patient_Delegate__c del : contactDelegateMap.get(ptConId)) {
                        if (del.Primary_Delegate__c) {
                            patientDeleToNotify.add(del.Contact__c);
                            break;
                        }
                    }
                }
            }
        }
        if (!participantContactsToNotifiy.isEmpty()) {
            createAttendeeNotifications(
                participantContactsToNotifiy,
                NotificationCatalog.MESSAGE_TO_PT_REMOVED_ATTENDEE_TYPE
            );
        }
        if (!patientDeleToNotify.isEmpty()) {
            createAttendeeNotifications(
                patientDeleToNotify,
                NotificationCatalog.MESSAGE_TO_PT_REMOVED_ATTENDEE_DEL_TYPE
            );
        }*/
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
