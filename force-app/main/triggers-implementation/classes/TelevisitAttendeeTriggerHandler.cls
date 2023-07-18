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

    public class TelevisitUpdateWrapper {
        public String notificationType;
        public Televisit_Attendee__c televisitAttendee;
    }

    @TestVisible
    private static void notifyNewAttendees(List<Televisit_Attendee__c> attendeeList) {
        //Insert notifications for new attendees
        Map<Id, Televisit_Attendee__c> attendeeTelevisitMap = new Map<Id, Televisit_Attendee__c>();
        Map<Id, TelevisitUpdateWrapper> updateTelevisitMap = new Map<Id, TelevisitUpdateWrapper>();

        for (Televisit_Attendee__c attendee : [
            SELECT
                Id,
                Contact__c,
                Televisit__c,
                Attendee_Type__c,
                Televisit__r.Participant_Enrollment__c,
                Televisit__r.Participant_Enrollment__r.Participant__c,
                Televisit__r.Participant_Enrollment__r.Participant__r.Contact__c,
                Televisit__r.Participant_Enrollment__r.Participant__r.Has_Studies_In_Progress__c
            FROM Televisit_Attendee__c
            WHERE Id IN :attendeeList
        ]) {
            if (attendee.Attendee_Type__c != 'Site Staff' && attendee.Attendee_Type__c != 'PI') {
                TelevisitUpdateWrapper teleVisitWrapperObj = new TelevisitUpdateWrapper();
                attendeeTelevisitMap.put(attendee.Contact__c, attendee);
                teleVisitWrapperObj.notificationType = NotificationCatalog.UPDATE_TO_PT_TELEVISIT_SCHEDULED;
                teleVisitWrapperObj.televisitAttendee = attendee;
                updateTelevisitMap.put(attendee.Contact__c, teleVisitWrapperObj);
            }
        }
        List<Notification__c> updateNotificationsList = getUpdateNotifications(updateTelevisitMap);
        createAttendeeNotifications(
            attendeeTelevisitMap,
            'Message_to_PT_Added_Attendee_Type',
            updateNotificationsList
        );
    }

    public static List<Notification__c> getUpdateNotifications(
        Map<Id, TelevisitUpdateWrapper> attendeeTelevisitMap
                ) {
        List<Id> idList = new List<Id>();
        List<String> notificationTypesList = new List<String>();
        List<Notification__c> updatedNotificationList = new List<Notification__c>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>(
            [
                SELECT Id, (SELECT Id, Has_Studies_In_Progress__c FROM Participants__r)
                FROM Contact
                WHERE Id IN :attendeeTelevisitMap.keySet()
            ]
        );
        for (Id conId : attendeeTelevisitMap.keySet()) {
            if (contactMap.get(conId).Participants__r[0].Has_Studies_In_Progress__c) {
                idList.add(
                    attendeeTelevisitMap.get(conId)
                        .televisitAttendee.Televisit__r.Participant_Enrollment__c
                );
                } else {
                idList.add(contactMap.get(conId).Participants__r[0].Id);
            }
            notificationTypesList.add(attendeeTelevisitMap.get(conId).notificationType);
        }
        List<Notification__c> exisistingNotificationList = [
            SELECT Id, Target_Record_Ids__c, WhatId__c, Recipient__c, Notification_Type__c
            FROM Notification__c
            WHERE
                Notification_Type__c = :notificationTypesList
                AND WhatId__c IN :idList
                AND Recipient__c IN :attendeeTelevisitMap.keySet()
                AND Status__c != 'Processed'
        ];
        for (Id conId : attendeeTelevisitMap.keySet()) {
            Boolean needtoCreate = true;
            for (Notification__c notificationObj : exisistingNotificationList) {
                if (
                    notificationObj.Recipient__c == conId &&
                    notificationObj.WhatId__c ==
                    attendeeTelevisitMap.get(conId)
                        .televisitAttendee.Televisit__r.Participant_Enrollment__c &&
                    notificationObj.Notification_Type__c ==
                    attendeeTelevisitMap.get(conId).notificationType
                ) {
                    needtoCreate = false;
                    if (
                        !notificationObj.Target_Record_Ids__c.contains(
                            attendeeTelevisitMap.get(conId).televisitAttendee.Televisit__c
                        )
                    ) {
                        List<Id> targetIds = notificationObj.Target_Record_Ids__c.split(',');
                        targetIds.add(
                            attendeeTelevisitMap.get(conId).televisitAttendee.Televisit__c
                        );
                        notificationObj.Target_Record_Ids__c = gettrimmedTargetRecordIds(targetIds);
                        }
                    updatedNotificationList.add(
                        new Notification__c(
                            Id = notificationObj.Id,
                            Target_Record_Ids__c = notificationObj.Target_Record_Ids__c
                        )
                    );
                }
                if (
                    notificationObj.Recipient__c == conId &&
                    notificationObj.WhatId__c == contactMap.get(conId).Participants__r[0].Id &&
                    notificationObj.Notification_Type__c ==
                    attendeeTelevisitMap.get(conId).notificationType
                ) {
                    needtoCreate = false;
                    String targetRecordIdStr = notificationObj.Target_Record_Ids__c.contains(
                                    attendeeTelevisitMap.get(conId).televisitAttendee.Televisit__c
                                )
                                ? notificationObj.Target_Record_Ids__c
                                : notificationObj.Target_Record_Ids__c +
                                ',' +
                          attendeeTelevisitMap.get(conId).televisitAttendee.Televisit__c;
                    List<Id> targetIds = targetRecordIdStr.split(',');

                    updatedNotificationList.add(
                        new Notification__c(
                            Id = notificationObj.Id,
                            Target_Record_Ids__c = gettrimmedTargetRecordIds(targetIds)
                        )
                    );
                }
            }
            if (needtoCreate) {
                Id whatId = contactMap.get(conId).Participants__r[0].Has_Studies_In_Progress__c
                    ? attendeeTelevisitMap.get(conId)
                          .televisitAttendee.Televisit__r.Participant_Enrollment__c
                    : contactMap.get(conId).Participants__r[0].Id;

                updatedNotificationList.add(
                    new Notification__c(
                        Recipient__c = conId,
                        WhatId__c = whatId,
                        Notification_Type__c = attendeeTelevisitMap.get(conId).notificationType,
                        Target_Record_Ids__c = '' +
                            attendeeTelevisitMap.get(conId).televisitAttendee.Televisit__c
                    )
                );
            }
        }

        return updatedNotificationList;
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
            List<String> notificationsTypeList = new List<String>();
            List<Id> scheduledCons = new List<Id>();
            List<Id> delcontactsList = new List<Id>();
            notificationsTypeList.add(NotificationCatalog.UPDATE_TO_PT_TELEVISIT_SCHEDULED);
            notificationsTypeList.add(NotificationCatalog.UPDATE_TO_PT_TELEVISIT_RESCHEDULED);
            for (Televisit_Attendee__c attendee : [
                SELECT Id, Televisit__c, Contact__r.Id, Contact__c
                FROM Televisit_Attendee__c
                WHERE Televisit__r.Status__c = 'Scheduled' AND Contact__c IN :delConTeleMap.keySet()
            ]) {
                scheduledCons.add(attendee.Contact__c);
            }
            for (Id keyId : delConTeleMap.keySet()) {
                if (!scheduledCons.contains(keyId)) {
                    delcontactsList.add(keyId);
                }
            }
            List<Notification__c> notificationsList = [
                SELECT Id, Status__c
                FROM Notification__c
                WHERE
                    Recipient__c IN :delcontactsList
                    AND Notification_Type__c IN :notificationsTypeList
            ];
            if (!notificationsList.isEmpty()) {
                for (Notification__c notificationObj : notificationsList) {
                    notificationObj.Status__c = 'Processed';
                }
                update notificationsList;
        }
    }
    }

    @TestVisible
    private static void createAttendeeNotifications(
        Map<Id, Televisit_Attendee__c> contactTelevistMap,
        String notificationType,
        List<Notification__c> updateNotifications
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
        if (!updateNotifications.isEmpty()) {
            notifications.addAll(updateNotifications);
        }
        Database.upsert(notifications);
    }
    @TestVisible
    private static String gettrimmedTargetRecordIds(List<Id> targetIds) {
        Integer idLength = targetIds.size() - 13;
        if (targetIds.size() > 13 && idLength > 0) {
            for (Integer i = 0; i < idLength; i++) {
                targetIds.remove(0);
            }
        }
        if (!targetIds.isEmpty()) {
            return String.join(targetIds, ',');
        }
        return '';
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