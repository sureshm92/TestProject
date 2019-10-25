/**
 * Created by AlexKetch on 4/16/2019.
 */

public with sharing class ClinicalTrialProfileTriggerHandler{

    public class UpdateClinicalTrialProfile extends TriggerHandler{

        public override void beforeInsert(List<SObject> newList){
            overrideStatusChangedBy(newList, null);
            populateOverrideFields(newList);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap){
            overrideStatusChangedBy(newList, (Map<Id, Clinical_Trial_Profile__c>)oldMap);
            populateOverrideFields(newList);
        }

        public override void afterInsert(List<SObject> newList) {
            updateNextNotifyDateByCTP((List<Clinical_Trial_Profile__c>)newList);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap){
            updateClinicalTrialProfile(newList, (Map<Id, Clinical_Trial_Profile__c>)oldMap);
            CTPSendNotificationService ctpService = (CTPSendNotificationService) ClassFactory.newInstance(CTPSendNotificationService.class);
            ctpService.updateRelatedTrialNotifications(newList, (Map<Id, Clinical_Trial_Profile__c>)oldMap);
            ctpService.removeSentNotifications();
            updateNextNotifyDateByCTP((List<Clinical_Trial_Profile__c>)newList);
        }

        public override void beforeDelete(List<SObject> oldList) {
            CTPSendNotificationService ctpService = (CTPSendNotificationService) ClassFactory.newInstance(CTPSendNotificationService.class);
            ctpService.removeRelatedTrialNotificationsOnDelete(oldList);
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
                ctp.Override_Recruitment_Status__c = 'No Longer Enrolling';
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

    public static void updateNextNotifyDateByCTP(List<Clinical_Trial_Profile__c> profiles){
        List<Participant_Enrollment__c> enrollments = [
                SELECT Participant__r.Contact__c
                FROM Participant_Enrollment__c
                WHERE Clinical_Trial_Profile__c IN :profiles
        ];
        List<Id> allContactIds = new List<Id>();
        for (Participant_Enrollment__c pe : enrollments) allContactIds.add(pe.Participant__r.Contact__c);

        List<Patient_Delegate__c> patientDelegates = [
                SELECT Participant__r.Contact__c, Contact__c
                FROM Patient_Delegate__c
                WHERE Participant__r.Contact__c IN :allContactIds
        ];

        Map<Id, List<Patient_Delegate__c>> participantIdsByDelegates = new Map<Id, List<Patient_Delegate__c>>();
        for (Patient_Delegate__c pd : patientDelegates) {
            allContactIds.add(pd.Contact__c);
            if (!participantIdsByDelegates.containsKey(pd.Participant__r.Contact__c)) {
                participantIdsByDelegates.put(pd.Participant__r.Contact__c, new List<Patient_Delegate__c>());
            }
            participantIdsByDelegates.get(pd.Participant__r.Contact__c).add(pd);
        }

        List<User> users = [
                SELECT  ContactId,
                        LastLoginDate
                FROM User
                WHERE ContactId IN :allContactIds
                AND IsActive = TRUE
                AND LastLoginDate != NULL
        ];
        Map<Id, Datetime> lastLoginDateByContactIds = new Map<Id, Datetime>();
        for (User us : users) lastLoginDateByContactIds.put(us.ContactId, us.LastLoginDate);

        List<Contact> contactsForUpdate = new List<Contact>();
        Map<Id, List<Participant_Enrollment__c>> enrollmentsByContactIds = Batch_UpdateNotifyDateOldUsers.getAllPEByContactIds(new List<Id>(participantIdsByDelegates.keySet()));
        for (Id participantContactId : participantIdsByDelegates.keySet()) {
            List<Decimal> minDays = new List<Decimal>();

            for (Participant_Enrollment__c pe : enrollmentsByContactIds.get(participantContactId)) {
                if (pe.Clinical_Trial_Profile__r.Logged_Out_Days_Notification__c == null) {
                    continue;
                } else {
                    minDays.add(pe.Clinical_Trial_Profile__r.Logged_Out_Days_Notification__c);
                }
            }
            if(minDays.isEmpty()) return;
            minDays.sort();
            Integer minDay = (Integer) minDays[0];

            Datetime lastLoginDateForParticipant = lastLoginDateByContactIds.get(participantContactId);
            Date nextNotifyDate = lastLoginDateForParticipant.addDays(minDay).date();
            if (Date.today().daysBetween(nextNotifyDate) < 0)  nextNotifyDate = Date.today().addDays(minDay);
            contactsForUpdate.add(new Contact(
                    Id = participantContactId,
                    Next_Notify_Date__c = nextNotifyDate
            ));

            for (Patient_Delegate__c pd : participantIdsByDelegates.get(participantContactId)) {
                Datetime lastLoginDateForDelegate = lastLoginDateByContactIds.get(pd.Contact__c);
                if(lastLoginDateForDelegate == null) continue;
                Date nextNotifyDateDelegate = lastLoginDateForDelegate.addDays(minDay).date();
                if (Date.today().daysBetween(nextNotifyDateDelegate) < 0)  nextNotifyDateDelegate = Date.today().addDays(minDay);
                contactsForUpdate.add(new Contact(
                        Id = pd.Contact__c,
                        Next_Notify_Date__c = nextNotifyDateDelegate
                ));
            }
        }
        update contactsForUpdate;
    }
}