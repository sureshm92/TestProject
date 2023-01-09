/**
 * Created by Yulia Yakushenkova on 1/6/2020. 
 */

public with sharing class Batch_CreateBecomeAdultNotification extends Batch_ScheduledAbstract {
    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator(
            [
                SELECT
                    Id,
                    Participant__c,
                    Participant__r.Id,
                    Participant__r.Birth_Year__c,
                    Participant__r.Birth_Month__c,
                    Participant__r.Birth_Day__c,
                    Participant__r.Adult__c,
                    Participant__r.Mailing_Country_Code__c,
                    Participant__r.Mailing_State_Code__c,
                    Participant__r.Contact__c,
                    Study_Site__r.Principal_Investigator__r.Id
                FROM Participant_Enrollment__c
                WHERE Participant__r.Adult__c = FALSE AND Participant__c != NULL 
            ]
        );
    }

    public void execute(
        Database.BatchableContext param1,
        List<Participant_Enrollment__c> participantEnrollments
    ) {
        List<Participant__c> participants = new List<Participant__c>();
        List<Id> participantIds = new List<Id>();

        System.debug('>>>> Participants enrollment' + JSON.serializePretty(participantEnrollments));
        Map<Id, Participant_Enrollment__c> prtByPEs = new Map<Id, Participant_Enrollment__c>();
        for (Participant_Enrollment__c pe : participantEnrollments) {
            participants.add(pe.Participant__r);
            participantIds.add(pe.Participant__c);
            prtByPEs.put(pe.Participant__r.Id, pe);
        }

        List<Participant__c> nowAdultParticipantOrBecome = calculateParticipantsAgeOfMajority(
            participants
        );
        Map<Id, List<Id>> dlgIdsByPartIds = PatientDelegateService.getDelegatedContactIdsByParticipantIdMap(
            participantIds
        );
        List<Alert__c> alerts = new List<Alert__c>();
        List<Notification__c> notifications = new List<Notification__c>();

        for (Participant__c prt : nowAdultParticipantOrBecome) {
            System.debug('Participant Id ' + prt.Id);
            if (dlgIdsByPartIds.containsKey(prt.Id)) {
                for (Id delId : dlgIdsByPartIds.get(prt.Id)) {
                    alerts.add(
                        new Alert__c(
                            Contact__c = delId,
                            Alert_Code__c = !prt.Adult__c
                                ? Alert.ALERT_CODE_WEEK_BEFORE_PRT_ADULT_DELEGATE
                                : Alert.ALERT_CODE_PRT_BECOME_ADULT_DELEGATE,
                            Record_ID__c = prtByPEs.get(prt.Id).Id
                        )
                    );
                }
            }
            if (
                prt.Adult__c &&
                String.isNotBlank(prtByPEs.get(prt.Id).Study_Site__r.Principal_Investigator__r.Id)
            ) {
                notifications.add(
                    new Notification__c(
                        Recipient__c = prtByPEs.get(prt.Id)
                            .Study_Site__r.Principal_Investigator__r.Id,
                        WhatId__c = prtByPEs.get(prt.Id).Id,
                        Notification_Type__c = NotificationCatalog.MESSAGE_TO_PI_PATIENT_BECOME_ADULT_TYPE,
                        Status__c = NotificationService.NOTIFICATION_STATUS_PENDING
                    )
                );
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

    private static List<Participant__c> calculateParticipantsAgeOfMajority(
        List<Participant__c> participants
    ) {
        List<Age_of_Majority__mdt> ageOfMajorities = [
            SELECT Country_Code__c, State_Code__c, Age__c,MasterLabel
            FROM Age_of_Majority__mdt
            ORDER BY Country_Code__c NULLS LAST, State_Code__c NULLS LAST
        ];
        List<String> lstUS_StateCode = new List<String>();
        List<String> lstNonUSCode = new List<String>();
        for (Age_of_Majority__mdt stcode : ageOfMajorities) {
               if(stcode.Country_Code__c =='US' && stcode.State_Code__c!=null)
               {
                   lstUS_StateCode.add(stcode.State_Code__c);
               }
               if(stcode.Country_Code__c !='US' && stcode.Country_Code__c !=null)
               {
                   lstNonUSCode.add(stcode.Country_Code__c);
               }
         }

        List<Participant__c> nowAdultParticipantOrBecomeSooner = new List<Participant__c>();
        for (Participant__c prt : participants) {
            if (prt.Adult__c || String.isBlank(prt.Birth_Year__c))
                continue;
            try {
                Integer mm = !String.isBlank(prt.Birth_Month__c) ? Integer.valueOf(prt.Birth_Month__c) : 12;
                Integer dd = !String.isBlank(prt.Birth_Day__c) ? Integer.valueOf(prt.Birth_Day__c) : Date.daysInMonth(Integer.valueOf(prt.Birth_Year__c), mm);

                Date birthDate = Date.newInstance(
                    Integer.valueOf(prt.Birth_Year__c),
                    mm,
                    dd
                );

                Integer participantAge = Date.newInstance(
                        2000,
                        birthDate.month(),
                        birthDate.day()
                    ) < Date.newInstance(2000, Date.today().month(), Date.today().day())
                    ? Date.today().year() - birthDate.year()
                    : Date.today().year() - birthDate.year() - 1;

                Integer participantAgePlus7Days = Date.newInstance(
                            2000,
                            birthDate.month(),
                            birthDate.day()
                        )
                        .addDays(-7) ==
                    Date.newInstance(2000, Date.today().month(), Date.today().day())
                    ? Date.today().year() - birthDate.year()
                    : Date.today().year() - birthDate.year() - 1;
                for (Age_of_Majority__mdt ageOfMajority : ageOfMajorities) {
                    if (
                        (prt.Mailing_Country_Code__c == ageOfMajority.Country_Code__c &&
                        (prt.Mailing_State_Code__c == ageOfMajority.State_Code__c ||
                        String.isBlank(ageOfMajority.State_Code__c))) ||
                        (String.isBlank(ageOfMajority.Country_Code__c))
                    ) {
                        
                        if(prt.Mailing_Country_Code__c=='US')
                       {
                               if(lstUS_StateCode.contains(prt.Mailing_State_Code__c ))
                               {
                                   if(prt.Mailing_State_Code__c == ageOfMajority.State_Code__c)
                                   {
                                       
                                        prt.Adult__c = participantAge >= ageOfMajority.Age__c;

                                        if (
                                        (participantAgePlus7Days >= ageOfMajority.Age__c && !prt.Adult__c) ||
                                        prt.Adult__c
                                        ) { 
                                        nowAdultParticipantOrBecomeSooner.add(prt);
                                        break;
                                        }
                                       
                                   }
                               }else{
                                        
                                        prt.Adult__c = participantAge >= ageOfMajority.Age__c;

                                        if (
                                        (participantAgePlus7Days >= ageOfMajority.Age__c && !prt.Adult__c) ||
                                        prt.Adult__c
                                        ) { 
                                        nowAdultParticipantOrBecomeSooner.add(prt);
                                        break;
                                        }
                               }
                        }else{
                            if(lstNonUSCode.contains(prt.Mailing_Country_Code__c ))
                               {
                                   if(prt.Mailing_Country_Code__c == ageOfMajority.Country_Code__c)
                                   {
                                        prt.Adult__c = participantAge >= ageOfMajority.Age__c;

                                        if (
                                        (participantAgePlus7Days >= ageOfMajority.Age__c && !prt.Adult__c) ||
                                        prt.Adult__c
                                        ) { 
                                        nowAdultParticipantOrBecomeSooner.add(prt);
                                        break;
                                        }
                                       
                                   }
                               }else{
                                        prt.Adult__c = participantAge >= ageOfMajority.Age__c;

                                        if (
                                        (participantAgePlus7Days >= ageOfMajority.Age__c && !prt.Adult__c) ||
                                        prt.Adult__c
                                        ) { 
                                        nowAdultParticipantOrBecomeSooner.add(prt);
                                        break;
                                        }
                               }
                        
                        }
                       
                    }
                }
            } catch (Exception e) {
            }
        }
        return nowAdultParticipantOrBecomeSooner;
    }

    public override String getRecommendedIntervalMode() {
        return Batch_ScheduledAbstract.INTERVAL_DAYS;
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 1;
    }
}
