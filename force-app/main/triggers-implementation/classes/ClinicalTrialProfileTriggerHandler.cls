/**
 * Created by AlexKetch on 4/16/2019.
 */

public with sharing class ClinicalTrialProfileTriggerHandler{

    public class UpdateClinicalTrialProfile extends TriggerHandler{

        public override void beforeInsert(List<SObject> newList){
            overrideStatusChangedBy(newList, null);
            populateOverrideFields(newList);
            updateShortCommunityName(newList, null);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap){
            overrideStatusChangedBy(newList, (Map<Id, Clinical_Trial_Profile__c>)oldMap);
            populateOverrideFields(newList);
            populateDateOnTrialComplete(newList, (Map<Id, Clinical_Trial_Profile__c>)oldMap);
            updateShortCommunityName(newList, (Map<Id, Clinical_Trial_Profile__c>)oldMap);
        }

        public override void afterInsert(List<SObject> newList) {
            updateNextNotifyDateByCTP((List<Clinical_Trial_Profile__c>)newList);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap){
            updateClinicalTrialProfile(newList, (Map<Id, Clinical_Trial_Profile__c>)oldMap);
            deleteTravelVendors(newList, (Map<Id, Clinical_Trial_Profile__c>)oldMap);
            updateNextNotifyDateByCTP((List<Clinical_Trial_Profile__c>)newList);
        }

        public override void beforeDelete(List<SObject> oldList) {
        }
    }

    private static void updateClinicalTrialProfile(List<SObject> newList, Map<Id, Clinical_Trial_Profile__c> oldMap) {
        ClinicalTrialProfileService service = (ClinicalTrialProfileService) ClassFactory.newInstance(ClinicalTrialProfileService.class);
        service.deleteRelatedToStudyDocuments((List<Clinical_Trial_Profile__c>) newList,(Map<Id, Clinical_Trial_Profile__c>)oldMap);
        service.addDeleteTherapeuticAreasOnParticipants((List<Clinical_Trial_Profile__c>) newList, (Map<Id, Clinical_Trial_Profile__c>)oldMap);
    }

    private static void overrideStatusChangedBy(List<SObject> newList, Map<Id, Clinical_Trial_Profile__c> oldMap) {
        Profile profile = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()];
        String profileName = profile.Name;
        for(Clinical_Trial_Profile__c ctp : (List<Clinical_Trial_Profile__c>)newList){
            if((oldMap == null && ctp.Override_Recruitment_Status__c  != null) ||
                    (oldMap != null && oldMap.get(ctp.Id).Override_Recruitment_Status__c != ctp.Override_Recruitment_Status__c)) {
                ctp.Override_Status_Updated_By__c = profileName;
            }
        }
    }

    private static void populateOverrideFields(List<Clinical_Trial_Profile__c> newList) {
        for(Clinical_Trial_Profile__c ctp : newList){
            if((ctp.Recruitment_Status__c == 'Enrolling' || ctp.Recruitment_Status__c == 'Open to Enrollment') && ctp.Override_Status_Updated_By__c != 'IQVIA SPNL'){
                ctp.Override_Recruitment_Status__c = 'Actively Enrolling';
            } else if((ctp.Recruitment_Status__c == 'Closed Follow-up / In Analysis' ||
                    ctp.Recruitment_Status__c == 'Completed' ||
                    ctp.Recruitment_Status__c == 'Enrollment Closed') &&
                    ctp.Override_Status_Updated_By__c != 'IQVIA SPNL'){
                ctp.Override_Recruitment_Status__c = 'Enrollment Closed';
            } else if(ctp.Recruitment_Status__c == 'Discontinued'){
                ctp.Override_Recruitment_Status__c = TrialService.STATUS_NO_LONGER_ENROLLING;
            } else if(ctp.Recruitment_Status__c == 'In Development' ||
                    ctp.Recruitment_Status__c == 'On Hold' ||
                    ctp.Recruitment_Status__c == 'Planning'){
                ctp.Override_Recruitment_Status__c = 'On Hold';
            }
            if(ctp.Detailed_Description__c != null && ctp.Override_Description__c == null){
                ctp.Override_Description__c = ctp.Detailed_Description__c;
            }
        }
    }

    private static void deleteTravelVendors(List<Clinical_Trial_Profile__c> newList, Map<Id, Clinical_Trial_Profile__c> oldMap){
        List<Id> ctpIdsForUpdate = new List<Id>();
        for (Clinical_Trial_Profile__c ctp : newList){
            Clinical_Trial_Profile__c ctpOld = oldMap.get(ctp.Id);
            if(!ctp.Travel_Vendor_Is_Available__c && ctpOld.Travel_Vendor_Is_Available__c) {
                ctpIdsForUpdate.add(ctp.Id);
            }
        }

        List<TravelVendorSettings__c> travelVendorSettingsToDelete = [
                SELECT Id
                FROM TravelVendorSettings__c
                WHERE Study_Site__r.Clinical_Trial_Profile__c IN: ctpIdsForUpdate
        ];
        delete travelVendorSettingsToDelete;
        SettingStoreService.deleteSettings('TravelVendorSetupFilter' , ctpIdsForUpdate);
    }

    private static void updateNextNotifyDateByCTP(List<Clinical_Trial_Profile__c> trialProfiles){
        List<Participant_Enrollment__c> enrollments = [
                SELECT Participant__r.Contact__c
                FROM Participant_Enrollment__c
                WHERE Clinical_Trial_Profile__c IN:trialProfiles
                AND Participant_Status__c IN: PEStatusState.PE_STATUS_GROUP_IN_PROGRESS_ALL
                AND Clinical_Trial_Profile__r.Logged_Out_Days_Notification__c != NULL
        ];

        List<Id> allContactsIds = new List<Id>();
        List<Id> participantContIds = new List<Id>();
        for(Participant_Enrollment__c pe : enrollments) {
            Id contactId = pe.Participant__r.Contact__c;
            allContactsIds.add(contactId);
            participantContIds.add(contactId);
        }

        List<Patient_Delegate__c> patientDelegates = [
                SELECT
                        Id,
                        Contact__c,
                        Contact__r.Next_Notify_Date__c,
                        Participant__r.Contact__c
                FROM Patient_Delegate__c
                WHERE Participant__r.Contact__c IN:participantContIds
        ];

        Map<Id, Id> partCntByDelegateCnt = new Map<Id, Id>();
        for(Patient_Delegate__c pd : patientDelegates) {
            partCntByDelegateCnt.put(pd.Contact__c, pd.Participant__r.Contact__c);
            allContactsIds.add(pd.Contact__c);
        }

        List<User> users = [
                SELECT
                        Id,
                        ContactId,
                        Contact.UserCommunityIsDelegate__c,
                        LastLoginDate
                FROM User
                WHERE IsActive = TRUE
                AND LastLoginDate != NULL
                AND ContactId != NULL
                AND ContactId IN:allContactsIds
        ];

        Map<Id, Integer> nearestNotificationByContactIds = ParticipantService.getNearestLogOutNotification(participantContIds);
        List<Contact> forUpdateContacts = new List<Contact>();
        for(User user : users) {
            Integer daysToNotify;
            if(user.Contact.UserCommunityIsDelegate__c && partCntByDelegateCnt.containsKey(user.ContactId)) {
                if(nearestNotificationByContactIds.containsKey(partCntByDelegateCnt.get(user.ContactId))) {
                    daysToNotify = nearestNotificationByContactIds.get(partCntByDelegateCnt.get(user.ContactId));
                }
            } else if(nearestNotificationByContactIds.containsKey(user.ContactId)){
                daysToNotify = nearestNotificationByContactIds.get(user.ContactId);
            }

            if(daysToNotify == null) continue;
            Date nextNotifyDate = user.LastLoginDate.addDays(daysToNotify).dateGmt();
            forUpdateContacts.add(new Contact(
                    Id = user.ContactId,
                    Next_Notify_Date__c = nextNotifyDate
            ));
        }

        if(!forUpdateContacts.isEmpty()) update forUpdateContacts;
    }

    private static void populateDateOnTrialComplete(List<SObject> newList, Map<Id, Clinical_Trial_Profile__c> oldMap) {
        for(Object obj : newList){
            Clinical_Trial_Profile__c ctp = (Clinical_Trial_Profile__c) obj;
            if(oldMap != null && ctp.Status__c == ClinicalTrialProfileService.STATUS_COMPLETED
                && oldMap.get(ctp.Id).Status__c != ctp.Status__c) {
                ctp.Trial_Complete__c = Date.today();
            }
        }
    }

    private static void updateShortCommunityName(List<SObject> newList, Map<Id, Clinical_Trial_Profile__c> oldMap) {
        for(Clinical_Trial_Profile__c ctp : (List<Clinical_Trial_Profile__c>)newList){
            if((oldMap == null && String.isEmpty(ctp.ShortCommunityName__c) && String.isNotEmpty(ctp.CommunityTemplate__c)) ||
                    (oldMap != null && oldMap.get(ctp.Id).CommunityTemplate__c != ctp.CommunityTemplate__c)) {
                CommunityTemplate template = CommunityTemplateService.getTemplate(ctp.CommunityTemplate__c);
                ctp.ShortCommunityName__c = template.shortCommunityName;
            }
        }
    }
}