/**
 * Created by Yehor Dobrovolskyi
 */
public without sharing class TrialSearchContainerRemote {


    @AuraEnabled
    public static TrialSearchContainer getSearchCTPs() {
        try {
            TrialSearchHelper helper = (TrialSearchHelper) ClassFactory.newInstance(TrialSearchHelper.class);
            TrialSearchContainer trialSearchContainer = helper.getInitTrialSearchContainer();
            trialSearchContainer.formData = new AddPatientByPIRemote.FormData();
            return trialSearchContainer;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static TrialSearchContainer getFilterSearchCTPs(List<Therapeutic_Area_Patient__c> taps, Boolean isEnrolling, Boolean isNotYetEnrolling) {
        try {
            TrialSearchHelper helper = (TrialSearchHelper) ClassFactory.newInstance(TrialSearchHelper.class);
            TrialSearchContainer trialSearchContainer = helper.getTrialSearchContainer(taps, isEnrolling, isNotYetEnrolling);
            return trialSearchContainer;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public class TrialSearchContainer {
        @AuraEnabled public List<TrialTDO> trialTDOs;
        @AuraEnabled public List<Therapeutic_Area_Patient__c> taps;
        @AuraEnabled public Participant__c participant;
        @AuraEnabled public AddPatientByPIRemote.FormData formData;
        @AuraEnabled public Boolean isAllowed;

        public TrialSearchContainer() {
            this.trialTDOs = new List<TrialSearchContainerRemote.TrialTDO>();
            this.taps = new List<Therapeutic_Area_Patient__c>();
            this.isAllowed = CommunityService.getUserContact().userCommunityDelegateId__c == null &&
                    CommunityService.getUserContact().Current_Participant_Enrollment__c == null;
        }
    }

    public class TrialTDO {
        @AuraEnabled public Clinical_Trial_Profile__c ctp;
        @AuraEnabled public Boolean relatedNotificationExists;
        @AuraEnabled public Boolean isEnrollingCTP;
    }
}