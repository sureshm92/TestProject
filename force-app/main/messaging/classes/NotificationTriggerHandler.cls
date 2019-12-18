/**
 * Created by Olga Skrynnikova on 11/19/2019.
 */

public without sharing class NotificationTriggerHandler {

    // Handlers: -------------------------------------------------------------------------------------------------------

    public class CheckFieldsHandler extends TriggerHandler {

        public override void beforeInsert(List<SObject> newList) {
            checkFieldsForNotification(newList);
        }

        public override void afterInsert(List<SObject> newList) {
            sendNotificationToRecipient(newList);
        }
    }

    public class CreateHCPEnrollmentsForRPInWhiteListHandler extends TriggerHandler{

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createHCPEnrollmentsForRPInWhiteList(newList, (Map<Id, Study_Site__c>)oldMap);
        }

    }

    public class SendEmailIfSSWasChanged extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            sendEmailIfSSWasChanged((List<Participant_Enrollment__c>) newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }
    }

    // Logic: ----------------------------------------------------------------------------------------------------------

    private static void checkFieldsForNotification(List<Notification__c> newList) {
        for (Notification__c n : newList) {
            if (NotificationService.getNotificationType(n.Notification_Type__c) == null) {
                n.addError('Wrong type of Notification ' + n.Notification_Type__c);
            }
        }
    }

    @TestVisible
    private static void sendNotificationToRecipient(List<Notification__c> newList) {
        List<Notification__c> notificationsForMassEmail = new List<Notification__c>();
        List<Notification__c> nonTopicNotifications = new List<Notification__c>();
        List<Id> whatIds = new List<Id>();

        for (Notification__c n : newList) {
            whatIds.add(n.WhatId__c);
            if (n.Recipient__c == null && n.Topic__c != null) {
                notificationsForMassEmail.add(n);
            }else {
                nonTopicNotifications.add(n);
            }
        }

        NotificationAvailabilityService availabilityService = new NotificationAvailabilityService(whatIds);
        List<Notification__c> emailNotifications = new List<Notification__c>();
        List<Notification__c> smsNotifications = new List<Notification__c>();
        List<Notification__c> pushNotifications = new List<Notification__c>();
        List<Send_Result__c> sendResults = new List<Send_Result__c>();

        for (Notification__c n : nonTopicNotifications) {
            Notification_Type__mdt notificationType = NotificationService.getNotificationType(n.Notification_Type__c);
            for(Notification_Target__mdt nt: notificationType.Notification_Targets__r){
                if (availabilityService.isAvailable(n.WhatId__c, notificationType.Recipient_Type__c, nt.Target_Type__c, n.Recipient__c)) {
                    if (nt.Target_Type__c == NotificationService.NOTIFICATION_TARGET_TYPE_EMAIL) {
                        emailNotifications.add(n);
                    } else if (nt.Target_Type__c == NotificationService.NOTIFICATION_TARGET_TYPE_SMS) {
                        smsNotifications.add(n);
                    } else if (nt.Target_Type__c == NotificationService.NOTIFICATION_TARGET_TYPE_PUSH) {
                        pushNotifications.add(n);
                    }
               }else{
                    sendResults.add(new Send_Result__c(
                            Notification__c = n.Id,
                            Target_Type__c = nt.Target_Type__c,
                            Status__c = NotificationService.STATUS_SKIPPED));
                }
            }

        }
        insert sendResults;

        EmailService.send(emailNotifications);
        SMSService.send(smsNotifications);
        if (notificationsForMassEmail.size() > 0) {
            for (Notification__c n : notificationsForMassEmail) {
                Database.executeBatch(new Batch_MassEmailPatient(n));
            }
        }
    }

    private static void createHCPEnrollmentsForRPInWhiteList(List<Study_Site__c> newList, Map<Id, Study_Site__c> oldMap){
        Set<Id> PIds = new Set<Id>();
        Map<Id, Study_Site__c> acceptedStudySites = new Map<Id,Study_Site__c>();
        for(Study_Site__c ss : newList){
            if((ss.Override_PI_Referral_Status__c == StudySiteService.PI_S_ACCEPTED ||
                    ss.Override_PI_Referral_Status__c == StudySiteService.PI_S_ACCEPTED_A) &&
                    ss.Override_PI_Referral_Status__c != oldMap.get(ss.id).Override_PI_Referral_Status__c){
                PIds.add(ss.Principal_Investigator__c);
                acceptedStudySites.put(ss.Id,ss);
            }
        }
        List<PI_RP_Relationship__c> prrList = [
                SELECT Id,
                        PI_Contact__c,
                        RP_Contact__c,
                        RP_Contact__r.AccountId
                FROM PI_RP_Relationship__c
                WHERE PI_Contact__c IN :PIds
        ];
        Set<Id> hcpIds = new Set<Id>();
        for(PI_RP_Relationship__c rpp : prrList){
            hcpIds.add(rpp.RP_Contact__c);
        }
        List<HCP_Enrollment__c> enrollmentList = [
                SELECt ID,
                        Name,
                        Study_Site__c,
                        HCP_Contact__c
                FROM HCP_Enrollment__c
                WHERE Study_Site__c IN :acceptedStudySites.keySet() AND HCP_Contact__c IN :hcpIds
        ];
        Set<String> exceptionList = new Set<String>();
        for(HCP_Enrollment__c enroll : enrollmentList){
            exceptionList.add(enroll.HCP_Contact__c + '' + enroll.Study_Site__c);
        }
        List<HCP_enrollment__c> enrollmentsList = new List<HCP_Enrollment__c>();
        for(PI_RP_Relationship__c prr : prrList){
            for(Study_Site__c ss : acceptedStudySites.values()){
                if(!exceptionList.contains(prr.RP_Contact__c +''+ ss.Id)) {
                    enrollmentsList.add(new HCP_Enrollment__c(
                            HCP_Contact__c = prr.RP_Contact__c,
                            HCP_Account__c = prr.RP_Contact__r.AccountId,
                            Status__c = HCPEnrollmentService.HCP_S_ACTIVATED,
                            Study_Site__c = ss.Id
                    ));
                }
            }
        }
        if(!enrollmentsList.isEmpty()) insert enrollmentsList;
    }

    @TestVisible
    private static void sendEmailIfSSWasChanged(List<Participant_Enrollment__c> newList, Map<Id, Participant_Enrollment__c> oldMap) {
        List<Notification__c> notificationList = new List<Notification__c>();
        List<Id> peIds = new List<Id>();
        for (Participant_Enrollment__c pe : newList) {
            if (pe.Study_Site__c != oldMap.get(pe.Id).Study_Site__c) {
                peIds.add(pe.Id);
            }
        }
        for (Participant_Enrollment__c pe : [
                SELECT Id,
                        Study_Site__c,
                        Study_Site__r.Principal_Investigator__c,
                        Participant_Contact__c
                FROM Participant_Enrollment__c
                WHERE Id IN :peIds
        ]) {
            notificationList.add(new Notification__c(
                    Notification_Type__c = 'Message_to_PT_SS_Was_Changed_Type',
                    Recipient__c = pe.Participant_Contact__c,
                    WhatId__c = pe.Id));
            notificationList.add(new Notification__c(
                    Notification_Type__c = 'Message_to_PI_SS_Was_Changed_Type',
                    Recipient__c = pe.Study_Site__r.Principal_Investigator__c,
                    WhatId__c = pe.Id));
        }
        if(!notificationList.isEmpty()) insert notificationList;
    }
}
