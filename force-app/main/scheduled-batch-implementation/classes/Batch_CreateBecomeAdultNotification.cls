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
                        Participant__r.Contact__c,
                        Study_Site__r.Principal_Investigator__r.Id
                FROM Participant_Enrollment__c
                WHERE Participant__r.Adult__c = FALSE
        ]);
    }

    public void execute(Database.BatchableContext param1, List<Participant_Enrollment__c> participantEnrollments) {
        List<Participant__c> prtForUpdate = new List<Participant__c>();
        Map<Id, Participant_Enrollment__c> prtByPEs = new Map<Id, Participant_Enrollment__c>();
        for (Participant_Enrollment__c pe : participantEnrollments) {
            if (pe.Participant__r.Date_of_Birth__c.length() > 9) {
                prtForUpdate.add(pe.Participant__r);
                prtByPEs.put(pe.Participant__r.Id, pe);
            }
        }

        prtForUpdate = ParticipantService.checkParticipantsAgeOfMajority(prtForUpdate);
        List<Notification__c> notifications = new List<Notification__c>();

        for (Participant__c prt : prtForUpdate) {
            if (prt.Adult__c) {
                Participant_Enrollment__c pe = prtByPEs.get(prt.Id);
                // put here field and populate for front view (PI should see something like notification)
                notifications.add(new Notification__c(
                        Recipient__c = prt.Contact__c,
                        WhatId__c = pe.Id,
                        Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_PATIENT_BECOME_ADULT_TYPE,
                        Status__c = NotificationService.NOTIFICATION_STATUS_PENDING
                ));
                if (String.isNotBlank(prtByPEs.get(prt.Id).Study_Site__r.Principal_Investigator__r.Id)) {
                    notifications.add(new Notification__c(
                            Recipient__c = pe.Study_Site__r.Principal_Investigator__r.Id,
                            WhatId__c = pe.Id,
                            Notification_Type__c = NotificationCatalog.MESSAGE_TO_PI_PATIENT_BECOME_ADULT_TYPE,
                            Status__c = NotificationService.NOTIFICATION_STATUS_PENDING
                    ));
                }
            }
        }
        insert notifications;
        update prtForUpdate;
    }

    public override Type getType() {
        return Batch_CreateBecomeAdultNotification.class;
    }

    public override String getBatchDescription() {
        return 'This job sends Email notification to participant and PI after participant has become adult';
    }
}