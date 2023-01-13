public without sharing class TelevisitAttendeeTriggerHandler {
    public class ManageAttendees extends TriggerHandler {
        public override void afterDelete(List<SObject> oldList) {
            notifyAttendeesRemoved(oldList);
        }
        public override void afterInsert(List<SObject> newList) {
            notifyNewAttendees(newList);
            sendBellNotificationToNewAttendees(newList);
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
            if (contactTelevistMap.get(conId).Attendee_Type__c == 'Participant Delegate') {
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
        for (Televisit_Attendee__c teleAttendee : attendeeList) {
            if (teleAttendee.Televisit__c != null)
                televisitIds.add(teleAttendee.Televisit__c);
        }
        if (televisitIds.size() > 0) {
            TelevisitTriggerHandler.createTelevisitEvent(televisitIds);
        }
    }

    @TestVisible
    private static void notifyTelevisitAttendees(List<Televisit_Attendee__c> attendeeList) {
        List<Televisit_Attendee__c> listAttendee = [Select id,Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,Contact__c,Attendee_Type__c from Televisit_Attendee__c
                                                    where Televisit__r.Status__c = 'Scheduled' AND Id IN:attendeeList AND (Attendee_Type__c = 'PI' OR Attendee_Type__c = 'Site Staff')];
        try{
            List<Notification__c> notifications = new List<Notification__c>();
            for (Televisit_Attendee__c attendee : listAttendee) {
                Notification__c notification = new Notification__c();
                notification.Recipient__c = attendee.Contact__c;
                notification.WhatId__c = attendee.Id;
                if(attendee.Televisit__c != null && attendee.Televisit__r.Participant_Enrollment__c != null &&
                   attendee.Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__c != null){
                    if(attendee.Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c == 'Janssen'){
                        notification.Notification_Type__c = 'Message_to_PI_Televisit_Creation_Janssen';
                    } else {
                        notification.Notification_Type__c = 'Message_to_PI_Televisit_Creation';
                    }
                }
                notifications.add(notification);
            }
            if (!notifications.isEmpty()) {
                insert notifications;
            }
        } catch (exception ex) {
            system.debug('++++++++++++++++' + ex.getMessage());
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
                } else {
                    notification.Notification_Type__c = 'Message_to_PI_Televisit_Remove';
                }
            }
              notifications.add(notification);
        }
        if (notifications != null && notifications.size() > 0) {
            insert notifications;
        }

    }

    /*
     * @description: This will be used to trigger Bell Notification when Televisit Attendee is added/ Televisit is created
     *                  created for RH-9302
     * @created: November 09, 2022
     * @param: attendeeList - list of Tele visit attendee that triggered
     */
    @TestVisible
    private static void sendBellNotificationToNewAttendees(List<Televisit_Attendee__c> attendeeList){
        Set<Id> tvaContactIdSet = new Set<Id>();
        Set<Id> attendeeIdSet =  (new Map<Id,Televisit_Attendee__c>(attendeeList) ).keySet();
        Set<Id> ssIdSet = new Set<Id>();
        Televisit_Attendee__c tva ;
        Map<Id,Televisit_Attendee__c> attendeeMap = new Map<Id,Televisit_Attendee__c>([SELECT Id,Contact__c,Televisit__r.Participant_Enrollment__c,
                                                                                                Televisit__r.Participant_Enrollment__r.Study_Site__c,
                                                                                                Televisit__r.Participant_Enrollment__r.Name,
                                                                                                Televisit__r.Participant_Enrollment__r.Participant__r.First_Name__c,
                                                                                                Televisit__r.Participant_Enrollment__r.Participant__r.Last_Name__c,
                                                                                                Televisit__r.Participant_Enrollment__r.Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c
                                                                                                 FROM Televisit_Attendee__c
                                                                                                WHERE Id IN :attendeeIdSet]);

        for(Televisit_Attendee__c attendee : attendeeMap.values() ){
            tva = attendee;
            if(attendee.Televisit__r.Participant_Enrollment__r != null && attendee.Televisit__r.Participant_Enrollment__r.Study_Site__c != null){
                ssIdSet.add(attendee.Televisit__r.Participant_Enrollment__r.Study_Site__c);
            }
            tvaContactIdSet.add(attendee.Contact__c);
        }
        if(ssIdSet.size() > 0){
            List<Notification_Target__mdt> notificationMdt = BellNotificationsHelper.getTarget('BELL_Message_on_TeleVisit');
            List<String> userGroupList = new List<String>();

            for(Notification_target__mdt mdt : notificationMdt){
                usergroupList.add(mdt.Target_User_Group__c);
            }
            Map<String,List<Contact> > resMap = BellNotificationsHelper.getRecipientVsContact(usergroupList,new List<Id>(ssIdSet).get(0),null);
            Map<String,List<Contact> > bellNotificationRecipientMap =  new Map<String,List<Contact> >();
            for(String key : resMap.keySet() ){
                List<Contact> conList = resMap.get(key);
                bellNotificationRecipientMap.put(key,new List<Contact>() );
                for(Contact con: conList){
                    if(tvaContactIdSet.contains(con.Id) ){
                        bellNotificationRecipientMap.get(key).add(con);
                    }
                }
            }
            //remove current user contact from above map
            Id currentUserContactId = UserContext.getUserContactId();
            String key = BellNotificationsHelper.getCurrentUserLevelByStudySite(String.valueOf(currentUserContactId),
                                                                                String.valueOf(new List<Id>(ssIdSet).get(0) )
                                                                                );
            if(bellNotificationRecipientMap.containsKey(key)){
                Integer index = bellNotificationRecipientMap.get(key).indexOf(new Contact(Id = currentUserContactId) );
                if(index >= 0){
                    bellNotificationRecipientMap.get(key).remove(index);
                }
            }
            List<Notification__c> notificationList = BellNotificationsHelper.createNotification('BELL_Message_on_TeleVisit',
                                                                                                    bellNotificationRecipientMap,
                                                                                                    tva.Televisit__r.Participant_Enrollment__r.Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                                                                                                    tva.Televisit__r.Participant_Enrollment__c,
                                                                                                    true);

        }
    }
}
