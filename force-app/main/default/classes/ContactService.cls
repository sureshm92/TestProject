/**
 * Created by Leonid Bartenev
 */

public without sharing class ContactService {

    public class PastStudyWrapper {
        @AuraEnabled public Clinical_Trial_Profile__c ctp;
        @AuraEnabled public Participant_Enrollment__c pe;
        @AuraEnabled public List<ResourceService.ResourceWrapper> resourceWrappers;

        public PastStudyWrapper(Clinical_Trial_Profile__c ctp, Participant_Enrollment__c pe, List<ResourceService.ResourceWrapper> resourceWrappers) {
            this.ctp = ctp;
            this.pe = pe;
            this.resourceWrappers = resourceWrappers;
        }
    }

    /**
     * applyRelevantNames() this method substitutes the FirstName and LastName field values in all related objects of type Contact
     * found in the specified SObject (or List<SObject>) with the relevant values in fields FirstName and LastName from object Participant
     * in case if it exists for the parent Contact
     *
     * @param obj
     */
    public static void applyRelevantNames(SObject obj) {
        applyRelevantNames(new List<SObject>{
                obj
        });
    }
    public static void applyRelevantNames(List<SObject> objects) {
        try {
            // collecting all related objects including all nested ones
            List<SObject> aggregateObjects = new List<SObject>();
            for (SObject obj : objects) {
                aggregateObjects.addAll(SObjectHelper.getAllSObjects(obj));
            }

            // select SObjects only of type Contact
            SObjectType contactType = Schema.getGlobalDescribe().get('Contact');
            Map<Id, Contact> contacts = new Map<Id, Contact>();
            for (SObject obj : aggregateObjects) {
                if (obj.getSObjectType() != contactType) continue;              // skip SObjects of non Contact type
                contacts.put(obj.Id, (Contact) obj);
            }

            // query Participants and replace FirstName and LastName fields if they exist
            for (Participant__c participant : [SELECT First_Name__c, Last_Name__c, Contact__c FROM Participant__c WHERE Contact__c IN :contacts.keySet()]) {
                contacts.get(participant.Contact__c).FirstName = participant.First_Name__c;
                contacts.get(participant.Contact__c).LastName = participant.Last_Name__c;
            }
        } catch (Exception e) {
            System.debug('EXCEPTION: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public static void updateCurrentPEOnContacts(List<Id> contactIds) {
        List<Contact> contacts = [
                SELECT Id, Current_Participant_Enrollment__c
                FROM Contact
                WHERE Id IN:contactIds
        ];
        Map<Id, List<Id>> availablePEIdsByContactIdMap = PatientDelegateService.getAvailablePEIdsListByContactIdMap(contactIds);
        for (Contact contact : contacts) {
            List<Id> peIds = availablePEIdsByContactIdMap.get(contact.Id);
            if (peIds == null) peIds = new List<Id>();
            if (peIds.size() == 0) {
                contact.Current_Participant_Enrollment__c = null;
            } else if (!peIds.contains(contact.Current_Participant_Enrollment__c)) {
                contact.Current_Participant_Enrollment__c = peIds[0];
            }
        }
        update contacts;
    }

    public static Participant_Enrollment__c getCurrentPE(Id contactId) {
        Contact contact = [
                SELECT Id,
                        Current_Participant_Enrollment__r.Participant__r.Full_Name__c,
                        Current_Participant_Enrollment__r.Participant__r.First_Name__c,
                        Current_Participant_Enrollment__r.Participant__r.Last_Name__c,
                        Current_Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c
                FROM Contact
                WHERE Id = :contactId
        ];
        return contact.Current_Participant_Enrollment__r;
    }

    public static List<PastStudyWrapper> getPastStudyWrappers(Id contactId) {
        List<Id> peIds = PatientDelegateService.getPastPEIdsForContact(contactId);
        if (peIds == null) return new List<PastStudyWrapper>();
        List<Participant_Enrollment__c> peList = ParticipantEnrollmentService.getPEnrolmentsCommon(
                CommunityService.USER_MODE_PARTICIPANT,
                ' AND Id IN ' + DatabaseService.listToString(peIds)
        );
        Set<Id> ctpIds = new Set<Id>();
        for (Participant_Enrollment__c pe : peList) {
            ctpIds.add(pe.Study_Site__r.Clinical_Trial_Profile__c);
        }
        Map<Id, Clinical_Trial_Profile__c> ctpMap = new Map<Id, Clinical_Trial_Profile__c>(TrialService.getTrials(new List<Id>(ctpIds)));
        List<Res_study__c> resStudyList = [
                SELECT Id,
                        Name,
                        Active_On_Status__c,
                        Expires_On_Status__c,
                        Active_After_Days__c,
                        Expires_After_Days__c,
                        Notify_On_Availability__c,
                        Resource__c,
                        Resource__r.Title__c,
                        Resource__r.RecordType.DeveloperName,
                        Visible_In_Alumni__c,
                        Visible_To_Delegates__c,
                        Clinical_Trial_Profile__c,
                        Visible_To_Participant__c,
                        Visible_To_PI__c,
                        Visible_To_RP__c
                FROM Res_study__c
                WHERE Clinical_Trial_Profile__c IN :ctpIds
        ];
        List<Id> resourceIds = new List<Id>();
        for (Res_study__c resStudy : resStudyList) resourceIds.add(resStudy.Resource__c);
        Map<Id, List<ContentDocumentLinkService.TranslatedContentItem>> translatedItemsMap =
                ((ContentDocumentLinkService) ClassFactory.newInstance(ContentDocumentLinkService.class)).getTranslatedItemsForResources(resourceIds);

        Map<Id, List<Res_study__c>> resStudyByCtpIdMap = new Map<Id, List<Res_study__c>>();
        Set<Id> resStudyResourceIds = new Set<Id>();
        for (Res_study__c resStudy : resStudyList) {
            List<Res_study__c> ctpResStudyList = resStudyByCtpIdMap.get(resStudy.Clinical_Trial_Profile__c);
            if (ctpResStudyList == null) ctpResStudyList = new List<Res_study__c>();
            ctpResStudyList.add(resStudy);
            resStudyByCtpIdMap.put(resStudy.Clinical_Trial_Profile__c, ctpResStudyList);
            resStudyResourceIds.add(resStudy.Resource__c);
        }
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        if (resStudyResourceIds.size() > 0) {
            contentDocumentLinks = [
                    SELECT Id, ContentDocument.Title, LinkedEntityId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId IN:resStudyResourceIds
            ];
        }

        Map<Id, List<String>> contentLangByResId = new Map<Id, List<String>>();
        for (ContentDocumentLink content : contentDocumentLinks) {
            if (!contentLangByResId.containsKey(content.LinkedEntityId)) {
                contentLangByResId.put(content.LinkedEntityId, new List<String>());
            }
            contentLangByResId.get(content.LinkedEntityId).add(content.ContentDocument.Title);
        }

        List<PastStudyWrapper> pastWrappersList = new List<ContactService.PastStudyWrapper>();
        for (Participant_Enrollment__c pe : peList) {
            List<ResourceService.ResourceWrapper> resources = new List<ResourceService.ResourceWrapper>();
            List<Res_study__c> resStudyForCtpList = resStudyByCtpIdMap.get(pe.Study_Site__r.Clinical_Trial_Profile__c);
            if (resStudyForCtpList != null) {
                for (Res_study__c resStudy : resStudyForCtpList) {
                    Boolean isDelegate = pe.Participant__r.Contact__c != CommunityService.getUserContact().Id;
                    if (StudyResourceVisibilityService.isResourceVisibleForPE(
                            resStudy, pe, contentLangByResId.get(resStudy.Resource__c),
                            CommunityService.USER_MODE_PARTICIPANT, isDelegate)) {
                        resources.add(new ResourceService.ResourceWrapper(resStudy.Resource__r, translatedItemsMap.get(resStudy.Resource__c)));
                    }
                }
            }
            pastWrappersList.add(new PastStudyWrapper(ctpMap.get(pe.Clinical_Trial_Profile__c), pe, resources));

        }
        return pastWrappersList;
    }

    public static void updateNextNotifyDate(Id cntId, Datetime lastLoginDateByContactId, Boolean isDelegate) {
        Id participant = cntId;
        if (isDelegate) {
            Patient_Delegate__c delegate = [SELECT Id, Contact__c, Participant__r.Contact__c FROM Patient_Delegate__c WHERE Contact__c = :cntId];
            participant = delegate.Participant__r.Contact__c;
        }
        Map<Id, Integer> idDecimalMap = ParticipantService.getNearestLogOutNotification(new List<Id>{cntId});
        update new Contact(Id = cntId, Next_Notify_Date__c = lastLoginDateByContactId.addDays(idDecimalMap.get(cntId)).date());
    }
}
