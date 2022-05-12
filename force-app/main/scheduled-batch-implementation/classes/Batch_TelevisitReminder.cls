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
                Is_First_Reminder_Sent__c
                FROM Televisit_Attendee__c
                WHERE
                (Attendee_Type__c = 'PI' OR Attendee_Type__c = 'Site Staff') AND
                Televisit__r.Status__c = 'Scheduled' AND Is_Second_Reminder_Sent__c = false AND 
                (
                    (
                        Is_First_Reminder_Sent__c = false AND 
                        Televisit__r.Visit_Date_Time__c >= :Datetime.now().addDays(1) AND 
                        Televisit__r.Visit_Date_Time__c <=:Datetime.now().addDays(1).addMinutes(2)
                    ) OR 
                    (
                        Televisit__r.Visit_Date_Time__c >= :Datetime.now().addHours(1) AND 
                        Televisit__r.Visit_Date_Time__c <= :Datetime.now().addHours(1).addMinutes(2)
                    )
                )
                
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
        for (Televisit_Attendee__c attendee : attendeeList) {
            Notification__c notification = new Notification__c();
            notification.Recipient__c = attendee.Contact__c;
            notification.WhatId__c = attendee.Id;
            if(
                attendee.Televisit__r.Visit_Date_Time__c >= Datetime.now().addHours(1) &&
                attendee.Televisit__r.Visit_Date_Time__c <= Datetime.now().addHours(1).addMinutes(2)
            ){
                notification.Notification_Type__c = 'Message_to_PI_Televisit_Reminder_Two';
            }else{
                notification.Notification_Type__c = 'Message_To_PI_Televisit_Reminder'; 
            }
            
            notifications.add(notification);
        }
        
        if (!notifications.isEmpty()){
            insert notifications;
        }
    }
    
    private void checkReminder(List<Televisit_Attendee__c> attendeeList) {
        
        for (Televisit_Attendee__c t : attendeeList) {
            if( t.Televisit__r.Visit_Date_Time__c >= Datetime.now().addHours(1) &&
               t.Televisit__r.Visit_Date_Time__c <= Datetime.now().addHours(1).addMinutes(2)
              ){
                  t.Is_Second_Reminder_Sent__c = true;
              }else{
                  t.Is_First_Reminder_Sent__c = true;
              }
        }
    }
    
    public override Type getType() {
        return Batch_PatientTaskReminder.class;
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