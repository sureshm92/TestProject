/**
 * Created by Yulia Yakushenkova on 1/6/2020.
 */

public with sharing class Batch_CreateBecomeAdultNotification extends Batch_ScheduledAbstract {

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT
                        Id,
                        Participant__r.Id,
                        Participant__r.Date_of_Birth__c,
                        Participant__r.Adult__c,
                        Participant__r.Mailing_Country_Code__c,
                        Participant__r.Mailing_State_Code__c,
                        Participant__r.Contact__c
                FROM Participant_Enrollment__c
                WHERE Participant__r.Adult__c != TRUE
        ]);
    }

    public void execute(Database.BatchableContext param1, List<Participant_Enrollment__c> participantEnrollments) {
        List<Participant__c> prtForCheck = new List<Participant__c>();
        for (Participant_Enrollment__c pe : participantEnrollments)
            if(String.isNotBlank(pe.Participant__r.Date_of_Birth__c)) prtForCheck.add(pe.Participant__r);

        Map<Id, Boolean> isMajorityParticipants = isAgeOfMajorityMap(prtForCheck);

        List<Participant__c> adultParticipants = new List<Participant__c>();
        List<Notification__c> notifications = new List<Notification__c>();

        for (Participant_Enrollment__c pe : participantEnrollments) {
            if(isMajorityParticipants.containsKey(pe.Participant__c)) {
                pe.Participant__r.Adult__c = isMajorityParticipants.get(pe.Participant__c);
                // put here field and populate for front view (PI should see something like notification)
                adultParticipants.add(pe.Participant__r);
                notifications.add(new Notification__c(
                        Recipient__c = pe.Participant__r.Contact__c,
                        WhatId__c = pe.Id,
                        Notification_Type__c = NotificationService.MESSAGE_TO_PT_PATIENT_BECOME_ADULT,
                        Status__c = NotificationService.NOTIFICATION_STATUS_PENDING
                ));
            }
        }
        insert notifications;
        update adultParticipants;
    }

    public override Type getType() {
        return Batch_CreateBecomeAdultNotification.class;
    }

    public override String getBatchDescription() {
        return 'This job sends Email notification to participant and PI after participant has become adult';
    }

    public static Map<Id, Boolean> isAgeOfMajorityMap(List<Participant__c> participants) {
        List<Age_of_Majority__mdt> ageOfMajorities = [
                SELECT
                        Country_Code__c,
                        State_Code__c,
                        Age__c
                FROM Age_of_Majority__mdt
                ORDER BY
                        Country_Code__c NULLS LAST,
                        State_Code__c NULLS LAST
        ];

        Map<Id, Boolean> resultByPartIds = new Map<Id, Boolean>();
        for (Age_of_Majority__mdt mdt : ageOfMajorities) {
            Integer[] iterators = new Integer[]{};
            for (Participant__c prt : participants) {
                Date birthDate = Date.newInstance(
                        Integer.valueOf(prt.Date_of_Birth__c.substring(0, 4)),
                        Integer.valueOf(prt.Date_of_Birth__c.substring(5, 7)),
                        Integer.valueOf(prt.Date_of_Birth__c.substring(8, 10)));
                Integer participantAge =
                        Date.newInstance(2000, birthDate.month(), birthDate.day()) <
                                Date.newInstance(2000, Date.today().month(), Date.today().day()) ?
                                Date.today().year() - birthDate.year() : Date.today().year() - birthDate.year() - 1;

                if ((prt.Mailing_Country_Code__c == mdt.Country_Code__c
                        && (prt.Mailing_State_Code__c == mdt.State_Code__c || String.isBlank(mdt.State_Code__c)))
                        || (String.isBlank(mdt.Country_Code__c))) {
                    resultByPartIds.put(prt.Id, participantAge >= mdt.Age__c);
                    iterators.add(participants.indexOf(prt));
                }
            }
            iterators.sort();
            for (Integer i = iterators.size() - 1; i >= 0; i--) participants.remove(iterators[i]);
        }
        return resultByPartIds;
    }
}