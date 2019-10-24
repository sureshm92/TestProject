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

    private static void updateNextNotifyDateByCTP(List<Clinical_Trial_Profile__c> ctps){
        Database.executeBatch(new Batch_UpdateNotifyDateOldUsers(ctps));
    }
}