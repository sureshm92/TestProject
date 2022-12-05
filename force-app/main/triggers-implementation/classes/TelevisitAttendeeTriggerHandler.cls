public without sharing class TelevisitAttendeeTriggerHandler {
    public class ManageAttendees extends TriggerHandler {
        public override void afterDelete(List<SObject> oldList) {
            notifyAttendeesRemoved(oldList);
        }
        public override void afterInsert(List<SObject> newList) {
            notifyNewAttendees(newList);
        }
    }

    public class TelevisitEventTrigger extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            checkTelevisitEventNotification(newList);
        }
    }

    public class TelevisitAttendeeTrigger extends TriggerHandler {
        public override void afterDelete(List<SObject> oldList) {
            notifyRemovedAttendees(oldList);
        }
        public override void afterInsert(List<SObject> newList) {
            notifyTelevisitAttendees(newList);
        }
    }

    @TestVisible
    private static void notifyNewAttendees(List<Televisit_Attendee__c> attendeeList) {
        //Insert notifications for new attendees
        Map<Id, Televisit_Attendee__c> attendeeTelevisitMap = new Map<Id, Televisit_Attendee__c>();
        Map<Id, Id> attendeeDelTelevisitMap = new Map<Id, Id>();

        Map<Id, List<Patient_Delegate_Enrollment__c>> participantIdsByDelegates = new Map<Id, List<Patient_Delegate_Enrollment__c>>();

        List<Id> allContactIds = new List<Id>();

        for (Televisit_Attendee__c teleAttendee : attendeeList) {
            allContactIds.add(teleAttendee.Contact__c);
        }
        List<Patient_Delegate_Enrollment__c> patientDelegateEnrollmentRecrds = [
            SELECT
                Id,
                    Patient_Delegate__r.Participant__r.Full_Name__c,
                    Patient_Delegate__r.Id,
                    Welcome_Message_Sent__c,
                    Study_Email_Consent__c,
                    Study_SMS_Consent__c,
                    Welcome_Message_Delivered__c,
                    Patient_Delegate__r.Participant__r.Contact__c,
                    Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                    Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_SMS__c,
                    Patient_Delegate__r.Participant__r.First_Name__c,
                    Patient_Delegate__r.Participant__r.Last_Name__c,
                    Patient_Delegate__r.Contact__c,
                    Patient_Delegate__r.Participant__c,   
                    Patient_Delegate__r.Participant_Delegate__r.Id,
                    Patient_Delegate__r.Participant_Delegate__r.First_Name__c,
                    Patient_Delegate__r.Participant_Delegate__r.Last_Name__c,
                    Patient_Delegate__r.Participant_Delegate__r.Email__c,
                    Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                    Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_SMS__c,
                    Status__c,
                    Participant_Enrollment__c,
                    Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c,
                    Participant_Enrollment__r.Name,
                    Participant_Enrollment__r.Clinical_Trial_Profile__c,
                    Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c
                FROM Patient_Delegate_Enrollment__c
                WHERE Patient_Delegate__r.Participant__r.Contact__c IN : allContactIds
        ];
        for (Id conId : allContactIds) {
            if (!participantIdsByDelegates.containsKey(conId)) {
                participantIdsByDelegates.put(conId, new List<Patient_Delegate_Enrollment__c>());
            }
        }
        for (Patient_Delegate_Enrollment__c pd : patientDelegateEnrollmentRecrds) {
            // allContactIds.add(pd.Contact__c);
            participantIdsByDelegates.get(pd.Participant_Enrollment__r.Participant__r.Contact__c).add(pd);
        }
        for (Televisit_Attendee__c attendee : [
            SELECT Id, Contact__c, Televisit__c, Attendee_Type__c
            FROM Televisit_Attendee__c
            WHERE Id IN :attendeeList
        ]) {
            if (attendee.Attendee_Type__c != 'Site Staff' && attendee.Attendee_Type__c != 'PI') {
            attendeeTelevisitMap.put(attendee.Contact__c, attendee);
        }
        }

        createAttendeeNotifications(attendeeTelevisitMap, 'Message_to_PT_Added_Attendee_Type');
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
        Map<Id, Televisit_Attendee__c> delConTeleMap = new Map<Id, Televisit_Attendee__c>();

        for (Televisit_Attendee__c attendee : [
            SELECT Id, Contact__c, Televisit__c, Attendee_Type__c
            FROM Televisit_Attendee__c
            WHERE
                Id IN :attendeeList
                AND Contact__r.UserCommunityIsDelegate__c = TRUE
                AND isDeleted = TRUE
            ALL ROWS
        ]) {
            if (attendee.Attendee_Type__c != 'Site Staff' && attendee.Attendee_Type__c != 'PI') {
            delConTeleMap.put(attendee.Contact__c, attendee);
        }
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
        Map<Id, Televisit_Attendee__c> contactTelevistMap,
        String notificationType
    ) {
        List<Notification__c> notifications = new List<Notification__c>();
        for (Id conId : contactTelevistMap.keySet()) {
            Boolean isdelegate = false;
            if(contactTelevistMap.get(conId).Attendee_Type__c == 'Participant Delegate'){
                isdelegate = true;
            }
            notifications.add(
                new Notification__c(
                    Recipient__c = conId,
                    WhatId__c = contactTelevistMap.get(conId).Televisit__c,
                    Notification_Type__c = notificationType,
                    IsDelegate__c = isdelegate
                )
            );
        }
        Database.insert(notifications);
    }

    @TestVisible
    private static void checkTelevisitEventNotification(List<Televisit_Attendee__c> attendeeList) {
        system.debug('checkTelevisitEventNotification');
        Set<Id> televisitIds = new Set<Id>();
        for(Televisit_Attendee__c teleAttendee : attendeeList){
            if(teleAttendee.Televisit__c!=null)
                televisitIds.add(teleAttendee.Televisit__c);
}
        if(televisitIds.size()>0){
            TelevisitTriggerHandler.createTelevisitEvent(televisitIds);
        }
    }

    @TestVisible
    private static void notifyTelevisitAttendees(List<Televisit_Attendee__c> attendeeList) {
        List<Televisit_Attendee__c> listAttendee = [Select id,Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,Contact__c,Attendee_Type__c from Televisit_Attendee__c 
                                                    where Televisit__r.Status__c = 'Scheduled' AND Id IN:attendeeList AND (Attendee_Type__c = 'PI' OR Attendee_Type__c = 'Site Staff')];
        try{
            List<Notification__c> notifications = new List<Notification__c>();
            for(Televisit_Attendee__c attendee:listAttendee){
                Notification__c notification = new Notification__c();
                notification.Recipient__c = attendee.Contact__c;
                notification.WhatId__c = attendee.Id;
                if(attendee.Televisit__c != null && attendee.Televisit__r.Participant_Enrollment__c != null && 
                   attendee.Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__c != null){
                    if(attendee.Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c == 'Janssen'){
                        notification.Notification_Type__c = 'Message_to_PI_Televisit_Creation_Janssen';
                    }else{
                        notification.Notification_Type__c = 'Message_to_PI_Televisit_Creation';
                    }

                }
                notifications.add(notification);
            }
            if(!notifications.isEmpty()){
                insert notifications;
            }

        }catch(exception ex){
            system.debug('++++++++++++++++'+ex.getMessage());
        }
        
    }
    @TestVisible
    private static void notifyRemovedAttendees(List<Televisit_Attendee__c> attendeeList) {
        List<Notification__c> notifications = new List<Notification__c>();
        for(Televisit_Attendee__c tvAttendeeRecord : [Select id,Televisit__c,Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,Contact__c,Attendee_Type__c from Televisit_Attendee__c 
                                                      where Televisit__r.Status__c = 'Scheduled' AND Id IN:attendeeList AND (Attendee_Type__c = 'PI' OR Attendee_Type__c = 'Site Staff') AND isDeleted = TRUE ALL ROWS]){ 
            Notification__c notification = new Notification__c();
            notification.Recipient__c = tvAttendeeRecord.Contact__c;
            notification.WhatId__c = tvAttendeeRecord.Televisit__c;
            if(tvAttendeeRecord.Televisit__c != null && tvAttendeeRecord.Televisit__r.Participant_Enrollment__c != null && 
                tvAttendeeRecord.Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__c != null){
                if(tvAttendeeRecord.Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c == 'Janssen'){
                    notification.Notification_Type__c = 'Message_to_PI_Televisit_Remove_Janssen';
                }else{
                     notification.Notification_Type__c = 'Message_to_PI_Televisit_Remove';
                }

            }
              notifications.add(notification);                          
        }
        if(notifications != null && notifications.size() > 0){
           insert notifications;
        }
        
    }
}