/**
 * Created by Nargiz Mamedova on 12/13/2019.
 */

public without sharing class RelevantLinksRemote {
    @AuraEnabled
    public static List<Resource__c> getInitData() {
        try {
            ParticipantService.ParticipantState ps = ParticipantService.getInstance().getState();
            List<Res_study__c> resStudies = [
                    SELECT Id, Resource__r.URL__c, Resource__r.Title__c,
                            Visible_To_Participant__c, Active_On_Status__c, Expires_On_Status__c, Visible_To_Delegates__c,
                            Active_After_Days__c, Expires_After_Days__c, Visible_In_Alumni__c
                    FROM Res_study__c
                    WHERE Clinical_Trial_Profile__c = :ps.ctp.Id
                    AND Resource__r.Content_Type__c = 'Relevant_Link'
                    AND Resource__r.Countries__c INCLUDES( :ps.pe.Study_Site__r.Site__r.BillingCountryCode)
            ];

            List<Resource__c> resources = new List<Resource__c>();
            for (Res_study__c rs : resStudies) {
                if (StudyResourceVisibilityService.isResourceVisibleForPE(rs, ps.pe, ContactService.getPreferredLanguages(),
                        CommunityService.getUserContact().userCommunityMode__c, ps.isDelegate)) {
                    resources.add(rs.Resource__r);
                }
            }
            return resources;
        } catch (Exception e) {
            return (List<Resource__c>) AuraHelper.throwException(e);
        }
    }
}