public without sharing class TelevisitAttendeeTriggerHandler {
    public class ManageAttendees extends TriggerHandler {
        public override void afterDelete(List<SObject> oldList) {
            notifyAttendeesRemoved(oldList);
        }
    }

    @TestVisible
    private static void notifyAttendeesRemoved(List<Televisit_Attendee__c> attendeeList) {
        List<Id> contactsToNotify = new List<Id>();
        for (Televisit_Attendee__c attendee : attendeeList) {
            contactsToNotify.add(attendee.Contact__c);
        }
        List<Id> patientDeleToNotify = new List<Id>();
        //Contact Id => List<Patient_Delegate__c>
        Map<Id, List<Patient_Delegate__c>> contactDelegateMap = new Map<Id, List<Patient_Delegate__c>>();
        for (
            Patient_Delegate__c delegate : PatientDelegateService.getPDelegates(contactsToNotify)
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
        if (!contactsToNotify.isEmpty()) {
            createAttendeeNotifications(
                contactsToNotify,
                NotificationCatalog.MESSAGE_TO_PT_AND_DEL_REMOVED_ATTENDEE
            );
        }
        if (!patientDeleToNotify.isEmpty()) {
            createAttendeeNotifications(
                contactsToNotify,
                NotificationCatalog.MESSAGE_TO_DEL_PT_REMOVED_ATTENDEE
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
