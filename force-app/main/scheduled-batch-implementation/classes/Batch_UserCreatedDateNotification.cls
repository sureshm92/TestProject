/**
 * Created by Julia Kazakevich on 19-Sep-19.
 * Refactored by Igor Malyuta on 27-Oct-19
 */ 

public without sharing class Batch_UserCreatedDateNotification extends Batch_ScheduledAbstract {
    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator(
            [
                SELECT
                    ContactId,
                    Contact.Current_Participant_Enrollment__c,
                    Contact.Next_Profile_Update_DT__c
                FROM User
                WHERE
                    Contact.Next_Profile_Update_DT__c <= :Datetime.now()
                    AND Contact.userCommunityMode__c = :CommunityService.USER_MODE_PARTICIPANT
                    AND Contact.Current_Participant_Enrollment__c != NULL
                    AND IsActive = TRUE
            ]
        );
    }

    public void execute(Database.BatchableContext param1, List<User> users) {
        List<Contact> contactsToBeNotified = new List<Contact>();
        for (User user : users)
            contactsToBeNotified.add(user.Contact);
        List<Notification__c> notifications = new List<Notification__c>();
        if (!contactsToBeNotified.isEmpty()) {
            for (Contact contactObj : contactsToBeNotified) {
                notifications.add(
                    new Notification__c(
                        Recipient__c = contactObj.Id,
                        WhatId__c = contactObj.Current_Participant_Enrollment__c,
                        Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_ONE_YEAR_TYPE,
                        Status__c = NotificationService.NOTIFICATION_STATUS_PENDING
                    )
                );
                if (contactObj.Next_Profile_Update_DT__c != null) {
                    contactObj.Next_Profile_Update_DT__c = Datetime.now().addYears(1);
                }
            }
            update contactsToBeNotified;
            insert notifications;
        }
    }

    public override Type getType() {
        return Batch_UserCreatedDateNotification.class;
    }

    public override String getBatchDescription() {
        return 'This job sends annual Emails to participants to remind them to update their profiles';
    }

    public override String getRecommendedIntervalMode() {
        return Batch_ScheduledAbstract.INTERVAL_DAYS;
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 1;
    }
}
