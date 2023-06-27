/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class ResStudyTriggerHandler {
    public class PlatformEventProcessor extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            PlatformEventService platformEventService = (PlatformEventService) ClassFactory.newInstance(
                PlatformEventService.class
            );
            platformEventService.remindEventFire((List<Res_study__c>) newList);
        }

        public override void afterDelete(List<SObject> oldList) {
            PlatformEventService platformEventService = (PlatformEventService) ClassFactory.newInstance(
                PlatformEventService.class
            );
            platformEventService.remindEventFire((List<Res_study__c>) oldList);
        }
    }
    public class CertificateResourceProcessor extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            List<SObject> resStudyList = new List<SObject> ();
            notifyParticipantAndDelegateAboutCertificate(newList);
            for(SObject resStudy : newList){
                Res_study__c resourceStudy = (Res_study__c)resStudy;
                if(resourceStudy.Visible_To_PI__c){
                    resStudyList.add(resourceStudy);
                }
            }
            if(resStudyList.size() > 0){
              notifyPIAndDelegateAboutStudyResources(resStudyList);
            }
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            notifyPIAndDelegateAboutUpdatedStudyResources((List<Res_study__c>) newList,
            (Map<Id, Res_study__c>) oldMap);
        }
    }

    // Logic: ----------------------------------------------------------------------------------------------------------

    private static void notifyParticipantAndDelegateAboutCertificate(List<SObject> newList) {
        List<Id> resStudyIds = new List<Id>();
        for (SObject obj : newList)
            resStudyIds.add(obj.Id);

        List<Res_study__c> resStudies = new List<Res_study__c>();
        for (SObject resStudy : [
            SELECT Id, Clinical_Trial_Profile__c, Visible_To_Delegates__c, Visible_To_Participant__c
            FROM Res_study__c
            WHERE
                Resource__r.document_type__c = 'Certificate'
                AND Id IN :resStudyIds
                AND Visible_To_Participant__c = TRUE
                AND Notify_On_Availability__c = TRUE
                AND Clinical_Trial_Profile__r.Study_Documents_Are_Available__c = TRUE
        ]) {
            resStudies.add((Res_study__c) resStudy);
        }

        Map<Id, List<Res_study__c>> resByCTPIds = new Map<Id, List<Res_study__c>>();

        for (Res_study__c resStudy : resStudies) {
            Id ctpId = resStudy.Clinical_Trial_Profile__c;
            if (resByCTPIds.containsKey(ctpId))
                resByCTPIds.get(ctpId).add(resStudy);
            else
                resByCTPIds.put(ctpId, new List<Res_study__c>{ resStudy });
        }

        Map<Id, List<Res_study__c>> participantByResources = new Map<Id, List<Res_study__c>>();
        List<Participant_Enrollment__c> pes = [
            SELECT Id, Participant__r.Contact__c, Clinical_Trial_Profile__c, Participant__c
            FROM Participant_Enrollment__c
            WHERE Clinical_Trial_Profile__c IN :resByCTPIds.keySet()
        ];
        List<Id> participantIds = new List<Id>();
        List<Id> perIdlst = new List<Id>();
        for (Participant_Enrollment__c pe : pes) {
            participantByResources.put(
                pe.Participant__r.Contact__c,
                resByCTPIds.get(pe.Clinical_Trial_Profile__c)
            );
            participantIds.add(pe.Participant__c);
            perIdlst.add(pe.Id);
        }

        PatientDelegateEnrollmentService.PDEWrapper pdewrapper = PatientDelegateEnrollmentService.getDelegatedContactIdsByParticipantIdMap(
            participantIds,perIdlst
        );
        Map<Id, List<Id>> partPerDelegateIds = pdewrapper.delParticipantIds; // Actual participant with list of delegate contact IDs

       /* Map<Id, List<Id>> partPerDelegateIds = PatientDelegateService.getDelegatedContactIdsByParticipantIdMap(
            participantIds
        );*/

        List<Notification__c> notifications = new List<Notification__c>();
        for (Participant_Enrollment__c pe : pes)
            for (Res_study__c res : participantByResources.get(pe.Participant__r.Contact__c)) {
                if (pe.Participant__r.Contact__c != null) {
                    notifications.add(
                        new Notification__c(
                            Recipient__c = pe.Participant__r.Contact__c,
                            WhatId__c = pe.Id,
                            Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_NEW_STDDOC_CERTIFICATE_TYPE,
                            Status__c = NotificationService.NOTIFICATION_STATUS_PENDING
                        )
                    );
                }
                if (
                    !partPerDelegateIds.keySet().isEmpty() &
                    partPerDelegateIds.containsKey(pe.Participant__c) && res.Visible_To_Delegates__c
                ) {
                    for (Id delegateId : partPerDelegateIds.get(pe.Participant__c))
                        notifications.add(
                            new Notification__c(
                                Recipient__c = delegateId,
                                WhatId__c = pe.Id,
                                IsDelegate__c = true,
                                Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_NEW_STDDOC_CERTIFICATE_TYPE,
                                Status__c = NotificationService.NOTIFICATION_STATUS_PENDING
                            )
                        );
                }
            }
        insert notifications;
    }

    private static void notifyPIAndDelegateAboutUpdatedStudyResources(List<Res_study__c> newList, Map<Id, Res_study__c> oldMap) {
        List<SObject> resStudyList = new List<SObject> ();
        for(Sobject resStudy : newList){
            Res_study__c resourceStudy = (Res_study__c)resStudy;
            if (!oldMap.get(resourceStudy.Id).Visible_To_PI__c && resourceStudy.Visible_To_PI__c) {
                resStudyList.add(resourceStudy);
            }
        }
        if(resStudyList.size() > 0 ){
            notifyPIAndDelegateAboutStudyResources(resStudyList);
        }
    }

    private static void notifyPIAndDelegateAboutStudyResources(List<SObject> newList) {          
        List<Id> resStudyIds = new List<Id>();              
        List<Id> lstOfStudy = new List<Id>();
        Map<String, List<Contact>> mapofStudyContactList = new Map<String, List<Contact>>();
        Map<String, Set<Contact>> mapofStudyContactSet = new Map<String, Set<Contact>>();
        Map<String, List<Contact>> mapofStudyContact = new Map<String, List<Contact>>();
        List<Notification__c> allNotificationList = new List<Notification__c>();
        Map<String, String> mapOfCommTemp = new Map<String, String>();
        
        for (SObject obj : newList){
            resStudyIds.add(obj.Id);
        }         
        
        Map<Id, Res_study__c> mapOfResStudy = new Map<Id, Res_study__c>([
            SELECT Id, Clinical_Trial_Profile__c, Clinical_Trial_Profile__r.CommunityTemplate__c
            FROM Res_study__c
            WHERE Visible_To_PI__c = TRUE AND Id IN :resStudyIds
        ]);
        
        for(Id eachRec : mapOfResStudy.keySet()){
            lstOfStudy.add(mapOfResStudy.get(eachRec).Clinical_Trial_Profile__c);
            mapOfCommTemp.put(mapOfResStudy.get(eachRec).Clinical_Trial_Profile__c, mapOfResStudy.get(eachRec).Clinical_Trial_Profile__r.CommunityTemplate__c);
        }     
        
        mapofStudyContactList = BellNotificationsHelper.getContactForStudy(lstOfStudy); 
        for (String key : mapofStudyContactList.keySet()) {
            mapofStudyContactSet.put(key, new Set<Contact>(mapofStudyContactList.get(key)));
        }
        for (String key : mapofStudyContactSet.keySet()) {
            mapofStudyContact.put(key, new List<Contact>(mapofStudyContactSet.get(key)));
        }
        
        for(String eachRec : mapofStudyContact.keySet()){
            Map<String,List<Contact>> contactResultMap =  new Map<String,list<Contact>>{'PI' => mapofStudyContact.get(eachRec)};
                List<Notification__c> notificationList = BellNotificationsHelper.createNotification('BELL_Message_on_Library_Upload_Document', contactResultMap, mapOfCommTemp.get(eachRec), null, false);
            allNotificationList.addAll(notificationList);
        } 
        
        if(allNotificationList.size() > 0 && allNotificationList.size() <= 8000){
            insert allNotificationList;
        }else if(allNotificationList.size() > 0 && allNotificationList.size() > 8000){
            Batch_NotificationInsertion notifyBatch = new Batch_NotificationInsertion(allNotificationList);
            Database.executeBatch(notifyBatch);
        }
    }
}