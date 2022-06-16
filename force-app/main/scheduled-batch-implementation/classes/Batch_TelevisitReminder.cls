public without sharing class Batch_TelevisitReminder extends Batch_ScheduledAbstract {
    public Database.QueryLocator start(Database.BatchableContext param1) {
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
                    ((Attendee_Type__c = 'PI'
                    OR Attendee_Type__c = 'Site Staff')
                    AND Televisit__r.Status__c = 'Scheduled'
                    AND Is_Second_Reminder_Sent__c = FALSE
                    AND ((Is_First_Reminder_Sent__c = FALSE
                    AND Televisit__r.Visit_Date_Time__c >= :Datetime.now().addDays(1)
                    AND Televisit__r.Visit_Date_Time__c <= :Datetime.now().addDays(1).addMinutes(2))
                    OR (Televisit__r.Visit_Date_Time__c >= :Datetime.now().addHours(1)
                    AND Televisit__r.Visit_Date_Time__c <= :Datetime.now()
                        .addHours(1)
                        .addMinutes(2))))
                    OR ((Attendee_Type__c = 'Participant Delegate'
                    OR Attendee_Type__c = 'Participant')
                    AND Televisit__r.Status__c = 'Scheduled'
                    AND ((Is_First_Reminder_Sent__c = FALSE
                    AND Televisit__r.Visit_Date_Time__c <= :Datetime.now().addDays(1).addMinutes(4)
                    AND Televisit__r.Visit_Date_Time__c >= :Datetime.now()
                        .addDays(1)
                        .addMinutes(-4))
                    OR (Is_Second_Reminder_Sent__c = FALSE
                    AND Televisit__r.Visit_Date_Time__c >= :Datetime.now()
                        .addHours(1)
                        .addMinutes(-4)
                    AND Televisit__r.Visit_Date_Time__c <= :Datetime.now()
                        .addHours(1)
                        .addMinutes(4))))
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
        Map<Id, Id> attendeeDayTelevisitMap = new Map<Id, Id>();
        Map<Id, Id> attendeeDayDelTelevisitMap = new Map<Id, Id>();
        Map<Id, Id> attendeeHourTelevisitMap = new Map<Id, Id>();
        Map<Id, Id> attendeeHourDelTelevisitMap = new Map<Id, Id>();
        Map<Id, List<Patient_Delegate__c>> participantIdsByDelegates = new Map<Id, List<Patient_Delegate__c>>();
        for (Televisit_Attendee__c teleAttendee : attendeeList) {
            allContactIds.add(teleAttendee.Contact__c);
        }
        List<Patient_Delegate__c> patientDelegates = [
            SELECT Participant__r.Contact__c, Contact__c, Primary_Delegate__c
            FROM Patient_Delegate__c
            WHERE Participant__r.Contact__c IN :allContactIds
        ];
        for (Id conId : allContactIds) {
            if (!participantIdsByDelegates.containsKey(conId)) {
                participantIdsByDelegates.put(conId, new List<Patient_Delegate__c>());
            }
        }
        for (Patient_Delegate__c pd : patientDelegates) {
            participantIdsByDelegates.get(pd.Participant__r.Contact__c).add(pd);
        }
        for (Televisit_Attendee__c attendee : attendeeList) {
            Notification__c notification = new Notification__c();
            notification.Recipient__c = attendee.Contact__c;
            notification.WhatId__c = attendee.Id;
            if (
                attendee.Televisit__r.Visit_Date_Time__c >= Datetime.now().addHours(1) &&
                attendee.Televisit__r.Visit_Date_Time__c <= Datetime.now().addHours(1).addMinutes(2)
            ) {
                if (
                    attendee.Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c ==
                    'Janssen'
                ) {
                    notification.Notification_Type__c = 'Message_to_PI_Televisit_Reminder_Two_Jan';
                } else if (
                    attendee.Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c ==
                    'GSK'
                ) {
                    notification.Notification_Type__c = 'Message_to_PI_Televisit_Reminder_Two_GSK';
                } else {
                    notification.Notification_Type__c = 'Message_to_PI_Televisit_Reminder_Two';
                }
            } else {
                if (
                    attendee.Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c ==
                    'Janssen'
                ) {
                    notification.Notification_Type__c = 'Message_To_PI_Televisit_Reminder_Janssen';
                } else if (
                    attendee.Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c ==
                    'GSK'
                ) {
                    notification.Notification_Type__c = 'Message_To_PI_Televisit_Reminder_GSK';
                } else {
                    notification.Notification_Type__c = 'Message_To_PI_Televisit_Reminder';
                }
            }
            if (attendee.Attendee_Type__c != 'Site Staff' && attendee.Attendee_Type__c != 'PI') {
                if (
                    attendee.Televisit__r.Visit_Date_Time__c.dateGmt() ==
                    Datetime.now().addDays(1).dateGmt()
                ) {
                    attendee.Is_First_Reminder_Sent__c = true;

                    attendeeDayTelevisitMap.put(attendee.Contact__c, attendee.Id);
                    Id delContactId = TelevisitTriggerHandler.getPrimaryDelegateContactId(
                        participantIdsByDelegates,
                        attendee.Contact__c
                    );
                    if (delContactId != null) {
                        attendeeDayDelTelevisitMap.put(delContactId, attendee.Id);
                    }
                }
                if (
                    attendee.Televisit__r.Visit_Date_Time__c.dateGmt() == Datetime.now().dateGmt()
                ) {
                    attendeeHourTelevisitMap.put(attendee.Contact__c, attendee.Id);
                    attendee.Is_Second_Reminder_Sent__c = true;
                    Id delContactId = TelevisitTriggerHandler.getPrimaryDelegateContactId(
                        participantIdsByDelegates,
                        attendee.Contact__c
                    );
                    if (delContactId != null) {
                        attendeeHourDelTelevisitMap.put(delContactId, attendee.Id);
                    }
                }
            }

            notifications.add(notification);
        }
        if (attendeeDayTelevisitMap != null || !attendeeDayTelevisitMap.isEmpty()) {
            notifications.addAll(
                createAttendeeNotifications(
                    attendeeDayTelevisitMap,
                    NotificationCatalog.MESSAGE_TO_PT_TELEVISIT_DAY_REMINDER_TYP
                )
            );
        }
        if (attendeeDayDelTelevisitMap != null || !attendeeDayDelTelevisitMap.isEmpty()) {
            notifications.addAll(
                createAttendeeNotifications(
                    attendeeDayDelTelevisitMap,
                    NotificationCatalog.MESSAGE_TO_PT_TELEVISIT_DAY_REMINDER_DEL
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
        if (attendeeHourDelTelevisitMap != null || !attendeeHourDelTelevisitMap.isEmpty()) {
            notifications.addAll(
                createAttendeeNotifications(
                    attendeeHourDelTelevisitMap,
                    NotificationCatalog.MESSAGE_TO_PT_TELEVISIT_HOUR_REMINDER_DE
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
                    t.Televisit__r.Visit_Date_Time__c >= Datetime.now().addHours(1) &&
                    t.Televisit__r.Visit_Date_Time__c <= Datetime.now().addHours(1).addMinutes(2)
                ) {
                    t.Is_Second_Reminder_Sent__c = true;
                } else {
                    t.Is_First_Reminder_Sent__c = true;
                }
            }
        }
    }

    private List<Notification__c> createAttendeeNotifications(
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
