/**
 * Created by Igor Malyuta on 15.05.2019.
 */

public without sharing class Batch_PatientTaskReminder extends Batch_ScheduledAbstract {

    public void execute(Database.BatchableContext param1, List<SObject> tasks) {
        SendEmailToParticipant.sendEmailNotificationWithDelegates(tasks);
        checkReminder(tasks);
        update tasks;
    }

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT Id,
                        OwnerId,
                        Subject,
                        Survey_Invitation__c,
                        Start_Date__c,
                        Task_Type__c,
                        ReminderDateTime,
                        Reminder_Date__c,
                        Reminder_Schedule__c,
                        Reminder_Schedule__r.First_Reminder_day__c,
                        Reminder_Schedule__r.Second_Reminder_day__c,
                        Reminder_Schedule__r.Use_Final_Template__c,
                        Visible_For__c,
                        WhatId,
                        WhoId
                FROM Task
                WHERE ReminderDateTime <= :Datetime.now()
                AND Is_Reminder_Sent__c = FALSE
                AND Status IN:TaskService.TASK_STATUS_GROUP_AVAILABLE
        ]);
    }

    public override Type getType() {
        return Batch_PatientTaskReminder.class;
    }

    private void checkReminder(List<Task> tasks) {
        Set<Id> contactIds = new Set<Id>();
        for(Task t : tasks) contactIds.add(t.WhoId);
        Map<Id, TimeZone> timeZonesByUser = DateTimeConverterUtil.getUsersTimezoneMap(contactIds);

        for (Task t : tasks) {
            t.Is_Reminder_Sent__c = true;
            if (t.Reminder_Schedule__c == null) continue;

            Integer secondReminder = (Integer) t.Reminder_Schedule__r.Second_Reminder_day__c;
            if (secondReminder != null) {
                Datetime startDT = Datetime.newInstanceGmt(t.Start_Date__c, t.Reminder_Date__c.timeGmt());
                Datetime reminderDate = DateTimeConverterUtil.addDaysInUserTimeZone(startDT, t.WhoId, secondReminder);

                if (t.Reminder_Date__c < reminderDate) {
                    t.Reminder_Date__c = reminderDate;
                    t.ReminderDateTime = DateTimeConverterUtil.convertUserDatetimeToGMT(reminderDate, timeZonesByUser.get(t.OwnerId));
                    t.Is_Reminder_Sent__c = false;
                }
            }
        }
    }
}