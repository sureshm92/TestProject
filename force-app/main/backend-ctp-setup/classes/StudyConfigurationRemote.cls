/**
 * Created by Nargiz Mamedova on 12/9/2019.
 */

public with sharing class StudyConfigurationRemote {
    public static final String FEATURE_STUDY_CONFIGURATION = 'Toggle_Feature_Delta';

    public class InitData {
        @AuraEnabled
        public Clinical_Trial_Profile__c ctp;
        @AuraEnabled
        public String user_has_permission = 'no perm';
        @AuraEnabled
        public Boolean noVisitPlansMessage = false;
    }

    @AuraEnabled
    public static InitData getInitData(Id ctpId) {
        InitData initData = new InitData();
        try {
            initData.ctp = [
                SELECT
                    Id,
                    Visit_Schedule_Is_Available__c,
                    Is_Program__c,
                    Study_Documents_Are_Available__c,
                    Video_And_Articles_Are_Available__c,
                    Tasks_Are_Available__c,
                    Travel_Vendor_Is_Available__c,
                    Trial_Match_Is_Available__c,
                    Relevant_Links_Are_Available__c,
                    Received_Until_Consent_Is_Available__c,
                	Delayed_No_Of_Days__c,
                    Enrolled_Or_Randomized_Consent_Available__c,
                    Payment_Is_Available__c,
                    Medical_Vendor_is_Available__c,
                    ECOA_Is_Avaialble__c,
                    Study_GUID__c,
                    Study_Version_GUID__c,
                    Visits_are_Available__c,
                    Televisit_Vendor_is_Available__c, //Televisit
                    IQVIA_Outreach__c,
                    E_Consent_Configuration__c,
                    Status_Milestone_Available__c,
                    CommunityTemplate__c
                FROM Clinical_Trial_Profile__c
                WHERE Id = :ctpId
            ];
            initData.user_has_permission = GetPermissions.getViewMode(FEATURE_STUDY_CONFIGURATION);
            List<Study_Site__c> allSSList = [
                SELECT Id, (SELECT Id FROM StudySiteVisitPlans__r)
                FROM Study_Site__c
                WHERE Clinical_Trial_Profile__c = :ctpId
            ];
            for (Study_Site__c ss : allSSList)
                if (ss.StudySiteVisitPlans__r.isEmpty())
                    initData.noVisitPlansMessage = true;
            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void saveChanges(Clinical_Trial_Profile__c ctp) {
        try {
            update ctp;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }
}