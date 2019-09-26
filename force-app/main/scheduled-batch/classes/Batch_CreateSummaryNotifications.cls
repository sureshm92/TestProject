/**
 * Created by Igor Malyuta on 11.09.2019.
 */

public without sharing class Batch_CreateSummaryNotifications extends Batch_ScheduledAbstract{

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT
                        Active_After_Days__c,
                        Active_On_Status__c,
                        Clinical_Trial_Profile__c,
                        Expires_After_Days__c,
                        Expires_On_Status__c,
                        Id,
                        Notify_On_Availability__c,
                        Resource__c,
                        Resource__r.Language__c,
                        Visible_In_Alumni__c,
                        Visible_To_Delegates__c,
                        Visible_To_Participant__c
                FROM Res_study__c
                WHERE Notify_On_Availability__c = TRUE
                AND Visible_To_Participant__c = TRUE
                AND Resource__r.Content_Type__c = 'Study_Document'
        ]);
    }

    public void execute(Database.BatchableContext param1, List<Res_study__c> resStudies) {
        Map<Id, List<Res_study__c>> resStudyByCtp = new Map<Id, List<Res_study__c>>();
        Set<String> resLangs = new Set<String>();
        for(Res_study__c res : resStudies) {
            if(!resStudyByCtp.containsKey(res.Clinical_Trial_Profile__c)) {
                resStudyByCtp.put(res.Clinical_Trial_Profile__c, new List<Res_study__c>());
            }
            resStudyByCtp.get(res.Clinical_Trial_Profile__c).add(res);
            resLangs.add(res.Resource__r.Language__c);
        }

        List<Participant_Enrollment__c> enrollment = [
                SELECT
                        Id,
                        Clinical_Trial_Profile__c,
                        Days_After_Enrolled__c,
                        Participant_Contact__c,
                        Participant_Contact__r.Language__c,
                        Participant_Contact__r.Participant_Opt_In_Status_Emails__c,
                        Participant_Contact__r.Resource_Notifications__c,
                        Participant_Status__c
                FROM Participant_Enrollment__c
                WHERE Clinical_Trial_Profile__c IN: resStudyByCtp.keySet()
                AND Study_Site__r.Approved_Lng__c IN: resLangs
        ];

        List<Contact> contactToNotify = new List<Contact>();
        for(Participant_Enrollment__c pe : enrollment) {
            List<Contact> peContacts = new List<Contact>();
            peContacts.add(pe.Participant_Contact__r);
            peContacts.addAll(PatientDelegateService.getDelegateContacts(pe.Participant_Contact__c));

            for(Res_study__c res : resStudyByCtp.get(pe.Clinical_Trial_Profile__c)) {
                for(Contact contact : peContacts) {
                    Boolean isDelegate = pe.Participant_Contact__c != contact.Id;
                    if(StudyResourceVisibilityService.isResourceVisibleForPE(res, pe, isDelegate)) {
                        if(needNotify(contact, res.Resource__c)) contactToNotify.add(contact);
                    }
                }
            }
        }

        if(!contactToNotify.isEmpty()) {
            SendEmailToParticipant.sendPlainSummaryNotifications(contactToNotify, SendEmailToParticipant.PATIENT_PLAIN_SUMMARY);
            update contactToNotify;
        }
    }

    public override Type getType() {
        return Batch_CreateSummaryNotifications.class;
    }

    private Boolean needNotify(Contact contact, Id resourceId) {
        Boolean notify = false;
        if(contact.Resource_Notifications__c == null) {
            contact.Resource_Notifications__c = resourceId;
            notify = true;
        } else {
            List<String> resourceIds = contact.Resource_Notifications__c.split(';');
            if(!resourceIds.contains(resourceId)) {
                contact.Resource_Notifications__c += ';' + resourceId;
                notify = true;
            }
        }

        return notify;
    }
}