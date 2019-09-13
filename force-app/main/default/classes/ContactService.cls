/**
 * Created by Leonid Bartenev
 */

public without sharing class ContactService {
    
    public class PastStudyWrapper{
        @AuraEnabled public Participant_Enrollment__c pe;
        @AuraEnabled public List<ResourceService.ResourceWrapper> resourceWrappers;
        
        public PastStudyWrapper(Participant_Enrollment__c pe, List<ResourceService.ResourceWrapper> resourceWrappers){
            this.pe = pe;
            this.resourceWrappers = resourceWrappers;
        }
    }
    
    public static void updateCurrentPEOnContacts(List<Id> contactIds){
        List<Contact> contacts = [
                SELECT Id, Current_Participant_Enrollment__c
                FROM Contact
                WHERE Id IN: contactIds
        ];
        Map<Id, List<Id>> availablePEIdsByContactIdMap = PatientDelegateService.getAvailablePEIdsListByContactIdMap(contactIds);
        for(Contact contact : contacts){
            List<Id> peIds = availablePEIdsByContactIdMap.get(contact.Id);
            if(peIds == null) peIds = new List<Id>();
            if(peIds.size() > 0){
                if(contact.Current_Participant_Enrollment__c == null ||
                        (contact.Current_Participant_Enrollment__c != null &&
                                !peIds.contains(contact.Current_Participant_Enrollment__c))) {
                    contact.Current_Participant_Enrollment__c = peIds[0];
                    System.debug('>>> peId: ' + peIds[0]);
                }
            }else{
                contact.Current_Participant_Enrollment__c = null;
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
    
    public static List<PastStudyWrapper> getPastStudyWrappers(Id contactId){
        List<Id> peIds = PatientDelegateService.getPastPEIdsForContact(contactId);
        List<Participant_Enrollment__c> peList = ParticipantEnrollmentService.getPEnrolmentsCommon(
                CommunityService.USER_MODE_PARTICIPANT,
                ' AND Id IN ' + DatabaseService.listToString(peIds)
        );
        Set<Id> ctpIds = new Set<Id>();
        for(Participant_Enrollment__c pe : peList){
            ctpIds.add(pe.Study_Site__r.Clinical_Trial_Profile__c);
        }
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
                        Visible_In_Alumni__c,
                        Visible_To_Delegates__c,
                        Clinical_Trial_Profile__c,
                        Visible_To_Participant__c,
                        Visible_To_PI__c,
                        Visible_To_RP__c
                FROM Res_study__c
                WHERE Clinical_Trial_Profile__c IN :ctpIds
        ];
        Map<Id, List<Res_study__c>> resStudyByCtpIdMap = new Map<Id, List<Res_study__c>>();
        for(Res_study__c resStudy : resStudyList){
            List<Res_study__c> ctpResStudyList = resStudyByCtpIdMap.get(resStudy.Clinical_Trial_Profile__c);
            if(ctpResStudyList == null) ctpResStudyList = new List<Res_study__c>();
            ctpResStudyList.add(resStudy);
            resStudyByCtpIdMap.put(resStudy.Clinical_Trial_Profile__c, ctpResStudyList);
        }
        List<PastStudyWrapper> pastWrappersList = new List<ContactService.PastStudyWrapper>();
        for(Participant_Enrollment__c pe : peList){
            List<ResourceService.ResourceWrapper> resources = new List<ResourceService.ResourceWrapper>();
            List<Res_study__c> resStudyForCtpList = resStudyByCtpIdMap.get(pe.Study_Site__r.Clinical_Trial_Profile__c);
            if(resStudyForCtpList != null){
                for(Res_study__c resStudy : resStudyForCtpList){
                    if(StudyResourceVisibilityService.isResourceVisibleForPE(resStudy, pe, pe.Participant__r.Contact__c == CommunityService.getUserContact().Id)){
                        resources.add(new ResourceService.ResourceWrapper(resStudy.Resource__r));
                    }
                }
            }
            pastWrappersList.add(new PastStudyWrapper(pe, resources));
            
        }
        return pastWrappersList;
    }
}