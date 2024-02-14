public without sharing class Batch_TelevisitReminder extends Batch_ScheduledAbstract {
    Map<Id,Televisit__c> firstremindermap = new Map<Id,Televisit__c>();
    Map<Id,Televisit__c> secondremindermap = new Map<Id,Televisit__c>();
    public Database.QueryLocator start(Database.BatchableContext param1) {
        Set<Id> televisitidset = new Set<Id>();
        List<Televisit__c> televisitlist = [Select id,Visit_Date_Time__c,Participant_Enrollment__r.Study_Site__r.First_Reminder__c,Participant_Enrollment__r.Study_Site__r.Second_Reminder__c
        from Televisit__c where Status__c = 'Scheduled'
        AND (Participant_Enrollment__r.Study_Site__r.First_Reminder__c != null OR Participant_Enrollment__r.Study_Site__r.Second_Reminder__c != null)
        AND ((Visit_Date_Time__c >=: Datetime.now().addMinutes(-3) AND Visit_Date_Time__c <=: Datetime.now().addMinutes(3))
        OR Visit_Date_Time__c >=: Datetime.now().addMinutes(57) )
        ];
        for(Televisit__c tv:televisitlist){
            if(tv.Visit_Date_Time__c >= system.now().addHours(integer.valueof(tv.Participant_Enrollment__r.Study_Site__r.First_Reminder__c)).addMinutes(-3) &&
               tv.Visit_Date_Time__c <= system.now().addHours(integer.valueof(tv.Participant_Enrollment__r.Study_Site__r.First_Reminder__c)).addMinutes(3)){

                firstremindermap.put(tv.id,tv);
                televisitidset.add(tv.id);
            }

            if(tv.Visit_Date_Time__c >= system.now().addHours(integer.valueof(tv.Participant_Enrollment__r.Study_Site__r.Second_Reminder__c)).addMinutes(-3) &&
               tv.Visit_Date_Time__c <= system.now().addHours(integer.valueof(tv.Participant_Enrollment__r.Study_Site__r.Second_Reminder__c)).addMinutes(3)){

                secondremindermap.put(tv.id,tv);
                televisitidset.add(tv.id);
            }

        }
        return Database.getQueryLocator(
            [
                SELECT
                    Id,
                    Attendee_Type__c,
                    Contact__c,
                    Firstname__c,
                    Lastname__c,
                    Televisit_Scheduled_Date__c,
                    User__c,
                    Televisit__r.Visit_Date_Time__c,
                    Televisit__r.Status__c,
                    Televisit__r.Title__c,
                    Is_Second_Reminder_Sent__c,
                    Is_First_Reminder_Sent__c,
                    Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c
                FROM Televisit_Attendee__c
                WHERE
                    (Attendee_Type__c = 'PI'
                    OR Attendee_Type__c = 'Site Staff' 
                    OR Attendee_Type__c = 'Participant Delegate'
                    OR Attendee_Type__c = 'Participant') 
                    AND (Is_Second_Reminder_Sent__c = false or Is_First_Reminder_Sent__c = false)
                    AND Televisit__c IN:televisitidset
            ]
        );
    }
    public void execute(Database.BatchableContext param1, List<SObject> attendeeList) {
        sendRemindersParticipantTeam(attendeeList);
        checkReminder(attendeeList);
        update attendeeList;
    }

    private void sendRemindersParticipantTeam(List<Televisit_Attendee__c> attendeeList) {
        List<Notification__c> notifications = new List<Notification__c>();
        List<Id> allContactIds = new List<Id>();
        Map<Id, Televisit_Attendee__c> attendeeDayTelevisitMap = new Map<Id, Televisit_Attendee__c>();
        Map<Id, Televisit_Attendee__c> attendeeHourTelevisitMap = new Map<Id, Televisit_Attendee__c>();
        Map<Id, List<Patient_Delegate__c>> participantIdsByDelegates = new Map<Id, List<Patient_Delegate__c>>();

        for (Televisit_Attendee__c attendee : attendeeList) {
            Notification__c notification = new Notification__c();
            notification.Recipient__c = attendee.Contact__c;
            notification.WhatId__c = attendee.Id;
            if(
                secondremindermap.keyset().contains(attendee.Televisit__c) && !attendee.Is_Second_Reminder_Sent__c && 
                (attendee.Attendee_Type__c == 'PI' || attendee.Attendee_Type__c == 'Site Staff')
            ){
                if(attendee.Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c == 'Janssen'){
                    notification.Notification_Type__c = 'Message_to_PI_Televisit_Reminder_Two_Jan';
                }else{
                    notification.Notification_Type__c = 'Message_to_PI_Televisit_Reminder_Two';
                }
            }
            if(
                firstremindermap.keyset().contains(attendee.Televisit__c) && !attendee.Is_First_Reminder_Sent__c &&
                (attendee.Attendee_Type__c == 'PI' || attendee.Attendee_Type__c == 'Site Staff')
            ){
                if(attendee.Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c == 'Janssen'){
                    notification.Notification_Type__c = 'Message_To_PI_Televisit_Reminder_Janssen';
                }else{
                    notification.Notification_Type__c = 'Message_To_PI_Televisit_Reminder';
                } 
            }
            if (attendee.Attendee_Type__c != 'Site Staff' && attendee.Attendee_Type__c != 'PI') {
                if (
                    firstremindermap.keyset().contains(attendee.Televisit__c) && !attendee.Is_First_Reminder_Sent__c
                ) {
                    attendee.Is_First_Reminder_Sent__c = true;

                    attendeeDayTelevisitMap.put(attendee.Contact__c, attendee);
                }
                if (
                    secondremindermap.keyset().contains(attendee.Televisit__c) && !attendee.Is_Second_Reminder_Sent__c
                ) {
                    attendeeHourTelevisitMap.put(attendee.Contact__c, attendee);
                    attendee.Is_Second_Reminder_Sent__c = true;
                }
            }
            if(!String.isEmpty(notification.Notification_Type__c)){
                notifications.add(notification);
            }
        }
        if (attendeeDayTelevisitMap != null || !attendeeDayTelevisitMap.isEmpty()) {
            notifications.addAll(
                createAttendeeNotifications(
                    attendeeDayTelevisitMap,
                    NotificationCatalog.MESSAGE_TO_PT_TELEVISIT_DAY_REMINDER_TYP
                )
            );
        }

        if (attendeeHourTelevisitMap != null || !attendeeHourTelevisitMap.isEmpty()) {
            notifications.addAll(
                createAttendeeNotifications(
                    attendeeHourTelevisitMap,
                    NotificationCatalog.MESSAGE_TO_PT_TELEVISIT_HOUR_REMINDER_TY
                )
            );
        }

        if (!notifications.isEmpty()) {
            insert notifications;
        }
    }

    private void checkReminder(List<Televisit_Attendee__c> attendeeList) {
        for (Televisit_Attendee__c t : attendeeList) {
            if (t.Attendee_Type__c == 'PI' || t.Attendee_Type__c == 'Site Staff') {
                if (
                    secondremindermap.keyset().contains(t.Televisit__c)
                ) {
                    t.Is_Second_Reminder_Sent__c = true;
                } 
                if(
                    firstremindermap.keyset().contains(t.Televisit__c)
                ) {
                    t.Is_First_Reminder_Sent__c = true;
                }
            }
        }
    }

    private List<Notification__c> createAttendeeNotifications(
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
                    WhatId__c = contactTelevistMap.get(conId).Id,
                    Notification_Type__c = notificationType,
                    IsDelegate__c = isdelegate
                )
            );
        }
        return notifications;
    }

    public override Type getType() {
        return Batch_TelevisitReminder.class;
    }

    public override String getBatchDescription() {
        return 'Sends Email Reminders about upcoming televisits';
    }

    public override String getRecommendedIntervalMode() {
        return Batch_ScheduledAbstract.INTERVAL_DAYS;
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 1;
    }
}