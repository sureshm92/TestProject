/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class TrialSearchContainerRemote {


    @AuraEnabled
    public static TrialSearchContainer getSearchCTPs() {
        try {
            TrialSearchHelper helper = (TrialSearchHelper) ClassFactory.newInstance(TrialSearchHelper.class);
            TrialSearchContainer trialSearchContainer = helper.getTrialSearchContainer();
            return trialSearchContainer;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public class TrialSearchContainer {
        @AuraEnabled
        public List<TrialTDO> trialTDOs;
        @AuraEnabled
        public List<Therapeutic_Area_Patient__c> taps;

    }

    public class TrialTDO {
        @AuraEnabled
        public Clinical_Trial_Profile__c ctp;
        @AuraEnabled
        public List<Therapeutic_Area__c> cois;
        @AuraEnabled
        public Boolean isGreenLine;
    }
}