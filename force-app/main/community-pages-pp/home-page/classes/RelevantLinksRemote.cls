/**
 * Created by Nargiz Mamedova on 12/13/2019.
 */

public without sharing class RelevantLinksRemote {
    public class InitData {
        @AuraEnabled public Boolean linksAvailable = false;
        @AuraEnabled public List<LinksWrapper> linksWrappers = new List<LinksWrapper>();
    }

    public class LinksWrapper {
        @AuraEnabled public LabelValueItem type;
        @AuraEnabled public List<ResourceService.ResourceWrapper> resources = new List<ResourceService.ResourceWrapper>();
    }

    @AuraEnabled
    public static InitData getInitData() {
        try {
            InitData initData = new InitData();
            Set<String> types = new Set<String>();
            List<Id> ctpIds = new List<Id>();

            ParticipantService.ParticipantState ps = ParticipantService.getInstance().getState();
            List<Participant_Enrollment__c> enrollments = getEnrollments(ps);
            if (enrollments.size() > 0) initData.linksAvailable = true;
            for (Participant_Enrollment__c pe : enrollments) ctpIds.add(pe.Clinical_Trial_Profile__c);

            List<Res_study__c> resStudies = [
                    SELECT Id, Clinical_Trial_Profile__c, Resource__c,
                            Resource__r.URL__c,Resource__r.Title__c,
                            Resource__r.Type__c, Resource__r.Content_Type__c,
                            Resource__r.Countries__c, Resource__r.Languages__c,
                            Visible_To_Participant__c, Visible_To_Delegates__c, Visible_In_Alumni__c,
                            Expires_After_Days__c, Expires_On_Status__c,
                            Active_On_Status__c, Active_After_Days__c
                    FROM Res_study__c
                    WHERE Clinical_Trial_Profile__c IN:ctpIds
                    AND Resource__r.Content_Type__c = 'Relevant_Link'
            ];

            List<Id> resourceIdsVisibleForParticipant = new List<Id>();
            for (Res_study__c rs : resStudies) {
                for (Participant_Enrollment__c pe : enrollments) {
                    if (rs.Clinical_Trial_Profile__c == pe.Clinical_Trial_Profile__c &&
                            (rs.Resource__r.Countries__c == null || rs.Resource__r.Countries__c.contains(pe.Study_Site__r.Site__r.BillingCountryCode))
                            && StudyResourceVisibilityService.isResourceVisibleForPE(rs, pe, ContactService.getPreferredLanguages(),
                            CommunityService.getUserContact().userCommunityMode__c, ps.isDelegate)) {
                        resourceIdsVisibleForParticipant.add(rs.Resource__c);
                        types.add(rs.Resource__r.Type__c);
                    }
                }
            }

            List<Id> COIsOfParticipant = new List<Id>();
            List<Therapeutic_Area_Patient__c> therapeuticAreaPatients = [
                    SELECT Id, Therapeutic_Area__c
                    FROM Therapeutic_Area_Patient__c
                    WHERE Participant__c = :ps.participant.Id
            ];
            for (Therapeutic_Area_Patient__c tap : therapeuticAreaPatients) COIsOfParticipant.add(tap.Therapeutic_Area__c);

            List<Resource__c> resourcesVisibleForParticipant = [
                    SELECT Id, Title__c, Type__c, URL__c, (SELECT Id, Therapeutic_Area__c FROM Therapeutic_Area_Assignments__r WHERE Therapeutic_Area__c IN:COIsOfParticipant)
                    FROM Resource__c
                    WHERE Id IN:resourceIdsVisibleForParticipant
            ];
            TranslateHelper.translate(resourcesVisibleForParticipant);

            List<LabelValueItem> typeLabelValues = getTranslatedTypes(Resource__c.Type__c.getDescribe().getPicklistValues());
            for (LabelValueItem t : typeLabelValues) {
                LinksWrapper lw = new LinksWrapper();
                for (Resource__c res : resourcesVisibleForParticipant) {
                    if (res.Type__c.equals(t.value)) {
                        lw.resources.add(new ResourceService.ResourceWrapper(res));
                    }
                }

                if (!lw.resources.isEmpty()) {
                    lw.type = t;
                    lw.resources = ResourceService.sortResourcesByCOI(lw.resources);
                    initData.linksWrappers.add(lw);
                }
            }

            if (initData.linksAvailable && initData.linksWrappers.isEmpty()) {
                LinksWrapper lw = new LinksWrapper();
                lw.type = new LabelValueItem(
                        TranslateHelper.getPickListLabel(Resource__c.Type__c, 'Relevant Links'),
                        'Relevant Links');
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
            if (participantState.isDelegate) currentContactId = PatientDelegateService.getParticipantByDelegateContactId(currentContactId).Contact__c;

            List<Id> peIds = PatientDelegateService.getPastPEIdsForContact(currentContactId);
            if (peIds != null) {
                enrollments = [
                        SELECT Id, Days_After_Enrolled__c, Participant_Status__c, Clinical_Trial_Profile__c,
                                Clinical_Trial_Profile__r.Relevant_Links_Are_Available__c, Study_Site__r.Approved_Lng__c,
                                Study_Site__r.Site__r.BillingCountryCode
                        FROM Participant_Enrollment__c
                        WHERE Id IN:peIds AND Clinical_Trial_Profile__r.Relevant_Links_Are_Available__c = TRUE
                ];
            }
        } else {
            enrollments = new List<Participant_Enrollment__c>();
            if (participantState.ctp.Relevant_Links_Are_Available__c) enrollments.add(participantState.pe);
        }
        return enrollments;
    }

    public static List<LabelValueItem> getTranslatedTypes(List<PicklistEntry> types) {
        List<LabelValueItem> translatedTypes = new List<LabelValueItem>();
        for (PicklistEntry t : types) {
            if (!t.getValue().equals('None')) translatedTypes.add(new LabelValueItem(t.getLabel(), t.getValue()));
        }
        return translatedTypes;
    }
}