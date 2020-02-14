/**
 * Created by Nargiz Mamedova on 12/13/2019.
 */

public without sharing class RelevantLinksRemote {
    public class InitData{
        @AuraEnabled public Boolean linksAvailable = false;
        @AuraEnabled public List<LinksWrapper> linksWrappers = new List<LinksWrapper>();
    }

    public class LinksWrapper {
        @AuraEnabled public String type = '';
        @AuraEnabled public List<Resource__c> resources = new List<Resource__c>();
    }

    @AuraEnabled
    public static InitData getInitData() {
        try {
            InitData initData = new InitData();
            Set<String> types = new Set<String>();
            List<Id> ctpIds = new List<Id>();

            ParticipantService.ParticipantState ps = ParticipantService.getInstance().getState();
            List<Participant_Enrollment__c> enrollments = getEnrollments(ps);
            if(enrollments.size() > 0) initData.linksAvailable = true;
            for(Participant_Enrollment__c pe : enrollments) ctpIds.add(pe.Clinical_Trial_Profile__c);

            List<Res_study__c> resStudies = [
                    SELECT Id, Resource__r.URL__c, Resource__r.Title__c, Resource__r.Countries__c, Resource__r.Type__c,
                            Resource__r.Languages__c, Resource__r.Content_Type__c, Clinical_Trial_Profile__c,
                            Expires_After_Days__c, Expires_On_Status__c, Active_On_Status__c,  Active_After_Days__c,
                            Visible_To_Participant__c, Visible_To_Delegates__c, Visible_In_Alumni__c
                    FROM Res_study__c
                    WHERE Clinical_Trial_Profile__c IN: ctpIds
                    AND Resource__r.Content_Type__c = 'Relevant_Link'
            ];
            TranslateHelper.translate(resStudies);

            List<Res_study__c> resStudiesVisibleForParticipant = new List<Res_study__c>();
            for (Res_study__c rs : resStudies) {
                for(Participant_Enrollment__c pe : enrollments){
                    if(rs.Clinical_Trial_Profile__c == pe.Clinical_Trial_Profile__c &&
                            (rs.Resource__r.Countries__c == null || rs.Resource__r.Countries__c.contains(pe.Study_Site__r.Site__r.BillingCountryCode))
                            && StudyResourceVisibilityService.isResourceVisibleForPE(rs, pe, ContactService.getPreferredLanguages(),
                            CommunityService.getUserContact().userCommunityMode__c, ps.isDelegate)){
                        resStudiesVisibleForParticipant.add(rs);
                        types.add(rs.Resource__r.Type__c);
                    }
                }
            }

            for(String t : types) {
                LinksWrapper lw = new LinksWrapper();
                if(t.equals('None')) lw.type = Label.Home_Page_RelevantLinks_Title;
                else lw.type = t;

                for(Res_study__c rs : resStudiesVisibleForParticipant) {
                    if(rs.Resource__r.Type__c.equals(t)) lw.resources.add(rs.Resource__r);
                }
                initData.linksWrappers.add(lw);
            }

            if(initData.linksAvailable && initData.linksWrappers.isEmpty()) {
                LinksWrapper lw = new LinksWrapper();
                lw.type = Label.Home_Page_RelevantLinks_Title;
                initData.linksWrappers.add(lw);
            }

            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    private static List<Participant_Enrollment__c> getEnrollments(ParticipantService.ParticipantState participantState) {
        List<Participant_Enrollment__c> enrollments = new List<Participant_Enrollment__c>();
        if (participantState.value == ParticipantService.ParticipantStates.ALUMNI) {
            Id currentContactId = CommunityService.getInstance().getCurrentContactId();
            if(participantState.isDelegate) currentContactId = PatientDelegateService.getParticipantByDelegateContactId(currentContactId).Contact__c;

            List<Id> peIds = PatientDelegateService.getPastPEIdsForContact(currentContactId);
            if(peIds != null) {
                enrollments = [
                        SELECT Id, Clinical_Trial_Profile__c, Clinical_Trial_Profile__r.Relevant_Links_Are_Available__c,
                                Study_Site__r.Site__r.BillingCountryCode, Participant_Status__c, Study_Site__r.Approved_Lng__c
                        FROM Participant_Enrollment__c
                        WHERE Id IN: peIds AND Clinical_Trial_Profile__r.Relevant_Links_Are_Available__c = TRUE
                ];
            }
        } else {
            enrollments = new List<Participant_Enrollment__c>();
            if (participantState.ctp.Relevant_Links_Are_Available__c) enrollments.add(participantState.pe);
        }
        return enrollments;
    }
}