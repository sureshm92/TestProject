/**
 * Created by Nargiz Mamedova on 12/13/2019.
 */

public without sharing class RelevantLinksRemote {
    public class InitData{
        @AuraEnabled public Boolean linksAvailable;
        @AuraEnabled public List<Resource__c> resources;
    }

    @AuraEnabled
    public static InitData getInitData() {
        try {
            InitData initData = new InitData();
            initData.resources = new List<Resource__c>();
            initData.linksAvailable = false;
            List<Participant_Enrollment__c> enrollments;
            ParticipantService.ParticipantState ps = ParticipantService.getInstance().getState();
            if (ps.value == ParticipantService.ParticipantStates.ALUMNI) {
                List<Id> peIds = PatientDelegateService.getPastPEIdsForContact(CommunityService.getInstance().getCurrentContactId());
                enrollments = [
                        SELECT Id, Clinical_Trial_Profile__c, Clinical_Trial_Profile__r.Relevant_Links_Are_Available__c,
                                Study_Site__r.Site__r.BillingCountryCode, Participant_Status__c, Study_Site__r.Approved_Lng__c
                        FROM Participant_Enrollment__c
                        WHERE Id IN: peIds AND Clinical_Trial_Profile__r.Relevant_Links_Are_Available__c = TRUE
                ];
            } else {
                enrollments = new List<Participant_Enrollment__c>();
                if (ps.ctp.Relevant_Links_Are_Available__c) enrollments.add(ps.pe);
            }
            List<Id> ctpIds = new List<Id>();
            if(enrollments.size() > 0) initData.linksAvailable = true;
            for(Participant_Enrollment__c pe : enrollments) ctpIds.add(pe.Clinical_Trial_Profile__c);
            List<Res_study__c> resStudies = [
                    SELECT Id, Resource__r.URL__c, Resource__r.Title__c, Resource__r.Countries__c, Visible_To_Participant__c,
                            Active_On_Status__c, Expires_On_Status__c, Visible_To_Delegates__c,
                            Active_After_Days__c, Expires_After_Days__c, Visible_In_Alumni__c
                    FROM Res_study__c
                    WHERE Clinical_Trial_Profile__c IN: ctpIds
                    AND Resource__r.Content_Type__c = 'Relevant_Link'
            ];
            for (Res_study__c rs : resStudies) {
                for(Participant_Enrollment__c pe : enrollments){
                    if(rs.Resource__r.Countries__c.contains(pe.Study_Site__r.Site__r.BillingCountryCode)
                            && StudyResourceVisibilityService.isResourceVisibleForPE(rs, pe, ContactService.getPreferredLanguages(),
                            CommunityService.getUserContact().userCommunityMode__c, ps.isDelegate)){
                        initData.resources.add(rs.Resource__r);
                    }
                }
            }
            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }
}