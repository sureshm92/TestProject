/**
 * Created by Yulia Yakushenkova on 1/6/2020.
 */

public with sharing class Batch_CreateBecomeAdultNotification extends Batch_ScheduledAbstract {

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT
                        Id,
                        Participant__c,
                        Participant__r.Id,
                        Participant__r.Date_of_Birth__c,
                        Participant__r.Adult__c,
                        Participant__r.Mailing_Country_Code__c,
                        Participant__r.Mailing_State_Code__c,
                        Participant__r.Contact__c,
                        Study_Site__r.Principal_Investigator__r.Id
                FROM Participant_Enrollment__c
                WHERE Participant__r.Adult__c = FALSE
                AND Participant__c != NULL
        ]);
    }

    public void execute(Database.BatchableContext param1, List<Participant_Enrollment__c> participantEnrollments) {
        List<Participant__c> participants = new List<Participant__c>();
        List<Id> participantIds = new List<Id>();

        System.debug('>>>> Participants enrollment' + JSON.serializePretty(participantEnrollments));
        Map<Id, Participant_Enrollment__c> prtByPEs = new Map<Id, Participant_Enrollment__c>();
        for (Participant_Enrollment__c pe : participantEnrollments) {
            participants.add(pe.Participant__r);
            participantIds.add(pe.Participant__c);
            prtByPEs.put(pe.Participant__r.Id, pe);
        }

        List<Participant__c> nowAdultParticipantOrBecome = calculateParticipantsAgeOfMajority(participants);
        Map<Id, List<Id>> dlgIdsByPartIds = PatientDelegateService.getDelegatedContactIdsByParticipantIdMap(participantIds);
        List<Alert__c> alerts = new List<Alert__c>();
        List<Notification__c> notifications = new List<Notification__c>();

        for (Participant__c prt : nowAdultParticipantOrBecome) {
            if (dlgIdsByPartIds.containsKey(prt.Id)) {
                for (Id delId : dlgIdsByPartIds.get(prt.Id)) {
                    alerts.add(new Alert__c(
                            Contact__c = delId,
                            Alert_Code__c = !prt.Adult__c ? Alert.ALERT_CODE_WEEK_BEFORE_PRT_ADULT_DELEGATE : Alert.ALERT_CODE_PRT_BECOME_ADULT_DELEGATE,
                            Record_ID__c = prtByPEs.get(prt.Id).Id
                    ));
                }
            }
            if (prt.Adult__c && String.isNotBlank(prtByPEs.get(prt.Id).Study_Site__r.Principal_Investigator__r.Id)) {
                notifications.add(new Notification__c(
                        Recipient__c = prtByPEs.get(prt.Id).Study_Site__r.Principal_Investigator__r.Id,
                        WhatId__c = prtByPEs.get(prt.Id).Id,
                        Notification_Type__c = NotificationCatalog.MESSAGE_TO_PI_PATIENT_BECOME_ADULT_TYPE,
                        Status__c = NotificationService.NOTIFICATION_STATUS_PENDING
                ));
            }
        }

        insert alerts;
        insert notifications;
        update nowAdultParticipantOrBecome;
    }

    public override Type getType() {
        return Batch_CreateBecomeAdultNotification.class;
    }

    public override String getBatchDescription() {
        return 'This job sends Email notification to participant and PI after participant has become adult';
    }

    private static List<Participant__c> calculateParticipantsAgeOfMajority(List<Participant__c> participants) {
        Map<String, Age_of_Majority__mdt> codesByAges = new Map<String, Age_of_Majority__mdt>();
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
        for (Age_of_Majority__mdt mdt : ageOfMajorities) codesByAges.put(mdt.Country_Code__c, mdt);

        List<Participant__c> nowAdultParticipantOrBecomeSooner = new List<Participant__c>();
        for (Participant__c prt : participants) {
            if (prt.Adult__c || String.isBlank(prt.Date_of_Birth__c)) continue;
            try {
                Date birthDate = Date.newInstance(
                        Integer.valueOf(prt.Date_of_Birth__c.substring(0, 4)),
                        Integer.valueOf(prt.Date_of_Birth__c.substring(5, 7)),
                        Integer.valueOf(prt.Date_of_Birth__c.substring(8, 10)));

                Integer participantAge =
                        Date.newInstance(2000, birthDate.month(), birthDate.day()) <
                                Date.newInstance(2000, Date.today().month(), Date.today().day()) ?
                                Date.today().year() - birthDate.year() : Date.today().year() - birthDate.year() - 1;

                Integer participantAgePlus7Days = Date.newInstance(2000, birthDate.month(), birthDate.day()).addDays(-7) ==
                        Date.newInstance(2000, Date.today().month(), Date.today().day()) ?
                        Date.today().year() - birthDate.year() : Date.today().year() - birthDate.year() - 1;

                Age_of_Majority__mdt ageOfMajority = codesByAges.get(prt.Mailing_Country_Code__c) != null ?
                        codesByAges.get(prt.Mailing_Country_Code__c) : codesByAges.get(null);
                if ((prt.Mailing_Country_Code__c == ageOfMajority.Country_Code__c
                        && (prt.Mailing_State_Code__c == ageOfMajority.State_Code__c || String.isBlank(ageOfMajority.State_Code__c)))
                        || (String.isBlank(ageOfMajority.Country_Code__c))) {
                    prt.Adult__c = participantAge >= ageOfMajority.Age__c;
                    if (participantAgePlus7Days >= ageOfMajority.Age__c && !prt.Adult__c) nowAdultParticipantOrBecomeSooner.add(prt); else if (prt.Adult__c) nowAdultParticipantOrBecomeSooner.add(prt);
                }
            } catch (Exception e) {
            }
        }
        return nowAdultParticipantOrBecomeSooner;
    }
}