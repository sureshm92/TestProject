/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class TrialSearchContainerRemote {


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

    @AuraEnabled
    public static void createTrialNotification(Id ctpId){
        try {
            TrialSearchHelper helper = (TrialSearchHelper) ClassFactory.newInstance(TrialSearchHelper.class);
            helper.createTrialNotification(ctpId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public class TrialSearchContainer {
        @AuraEnabled
        public List<TrialTDO> trialTDOs;
        @AuraEnabled
        public List<Therapeutic_Area_Patient__c> taps;
        @AuraEnabled
        public Participant__c participant;
        @AuraEnabled
        public AddPatientByPIRemote.FormData formData;

    }

    public class TrialTDO {
        @AuraEnabled
        public Clinical_Trial_Profile__c ctp;
//        @AuraEnabled
//        public List<Therapeutic_Area__c> cois;
        @AuraEnabled
        public Boolean isEnrollingCTP;
    }
}