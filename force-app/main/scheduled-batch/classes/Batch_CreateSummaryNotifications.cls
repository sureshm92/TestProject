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
                        Participant_Contact__r.Resource_Notifications__c,
                        Participant_Status__c
                FROM Participant_Enrollment__c
                WHERE Clinical_Trial_Profile__c IN: resStudyByCtp.keySet()
                AND Study_Site__r.Approved_Lng__c IN: resLangs
        ];

        Map<Id, Boolean> contactToNotify = new Map<Id, Boolean>();
        List<Contact> contactToUpdate = new List<Contact>();
        for(Participant_Enrollment__c pe : enrollment) {
            Boolean notify = false;

            List<String> resourceNotificationIds;
            if(pe.Participant_Contact__r.Resource_Notifications__c != null) {
                resourceNotificationIds = pe.Participant_Contact__r.Resource_Notifications__c.split(';');
            } else {
                resourceNotificationIds = new List<String>();
            }

            for(Res_study__c res : resStudyByCtp.get(pe.Clinical_Trial_Profile__c)) {
                if(resourceNotificationIds.contains(res.Resource__c)) break;

                if(PEStatusState.PE_STATUS_GROUP_ALUMNI.contains(pe.Participant_Status__c) && !res.Visible_In_Alumni__c) {
                    break;
                }

                if(pe.Participant_Contact__r.Language__c != res.Resource__r.Language__c) { //Add IRB logic here
                    break;
                }


                if(res.Active_After_Days__c != null) { //Days based
                    if(pe.Days_After_Enrolled__c >= res.Active_After_Days__c) {
                        if(res.Expires_After_Days__c == null ||
                                ( (res.Active_After_Days__c + res.Expires_After_Days__c) > pe.Days_After_Enrolled__c)) {
                            notify = true;
                        }
                    }
                } else if(res.Active_On_Status__c != null) { //Status based
                    if(PEStatusState.PE_ORDERED_STATUSES.get(pe.Participant_Status__c) >=
                            PEStatusState.PE_ORDERED_STATUSES.get(res.Active_On_Status__c)) {
                        if(pe.Participant_Status__c != res.Expires_On_Status__c) {
                            notify = true;
                        }
                    }
                }

                if(notify) {
                    contactToNotify.put(pe.Participant_Contact__c, res.Visible_To_Delegates__c);
                    pe.Participant_Contact__r.Resource_Notifications__c += ';' + res.Resource__c;
                }
            }

            if(notify) {
                contactToUpdate.add(pe.Participant_Contact__r);
                notify = false;
            }
        }

        if(!contactToUpdate.isEmpty()) {
            SendEmailToParticipant.sendPlainSummaryNotifications(contactToNotify);
            update contactToUpdate;
        }
    }

    public override Type getType() {
        return Batch_CreateSummaryNotifications.class;
    }
}