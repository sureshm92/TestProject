/**
 * Created by Nargiz Mamedova on 12/13/2019.
 */

public without sharing class RelevantLinksRemote {
    public class InitData {
        @AuraEnabled
        public Boolean linksAvailable = false;
        @AuraEnabled
        public List<LinksWrapper> linksWrappers = new List<LinksWrapper>();
    }

    public class InitDataNew {
        @AuraEnabled
        public Boolean linksAvailable = false;

        @AuraEnabled
        public Boolean relevantLinksAreAvailable = false;
        @AuraEnabled
        public Boolean studyDocumentsAreAvailable = false;
        @AuraEnabled
        public Boolean videoAndArticlesAreAvailable = false;
        @AuraEnabled
        public List<ResourceService.ResourceWrapper> resources = new List<ResourceService.ResourceWrapper>();
        @AuraEnabled
        public Boolean isDelegate = false;
        @AuraEnabled
        public string participantStateValue;
    }

    public class LinksWrapper {
        @AuraEnabled
        public LabelValueItem type;
        @AuraEnabled
        public List<ResourceService.ResourceWrapper> resources = new List<ResourceService.ResourceWrapper>();
    }

    @AuraEnabled
    public static InitData getInitData() {
        try {
            String contentType = ResourceService.RESOURCE_TYPE_RELEVANT_LINK;
            List<Id> COIsOfParticipant = new List<Id>();
            InitData initData = new InitData();

            ParticipantService.ParticipantState ps = ParticipantService.getInstance().getState();
            List<Participant_Enrollment__c> enrollments = getEnrollments(ps);
            List<String> preferredLanguages = ContactService.getPreferredLanguages();

            List<Therapeutic_Area_Patient__c> therapeuticAreaPatients = [
                SELECT Id, Therapeutic_Area__c
                FROM Therapeutic_Area_Patient__c
                WHERE Participant__c = :ps.participant.Id
            ];
            for (Therapeutic_Area_Patient__c tap : therapeuticAreaPatients)
                COIsOfParticipant.add(tap.Therapeutic_Area__c);

            List<Resource__c> resourcesVisibleForParticipant = getStudySpecificResources(
                contentType,
                enrollments,
                preferredLanguages,
                COIsOfParticipant,
                ps.isDelegate
            );
            if (ps.value == ParticipantService.ParticipantStates.ALUMNI) {
                resourcesVisibleForParticipant.addAll(
                    getCOIResources(contentType, COIsOfParticipant, preferredLanguages)
                );
                if (!resourcesVisibleForParticipant.isEmpty())
                    initData.linksAvailable = true;
            } else {
                if (enrollments.size() > 0)
                    initData.linksAvailable = true;
            }

            TranslateHelper.translate(resourcesVisibleForParticipant);
            List<LabelValueItem> typeLabelValues = getTranslatedTypes(
                Resource__c.Type__c.getDescribe().getPicklistValues()
            );
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
                    'Relevant Links'
                );
                initData.linksWrappers.add(lw);
            }

            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static InitDataNew getInitDataNew() {
        try {
            String contentType = ResourceService.RESOURCE_TYPE_RELEVANT_LINK;
            List<Id> COIsOfParticipant = new List<Id>();
            InitDataNew initDataNew = new InitDataNew();

            ParticipantService.ParticipantState ps = ParticipantService.getInstance().getState();
            List<Participant_Enrollment__c> enrollments = getEnrollments(ps);
            List<String> preferredLanguages = ContactService.getPreferredLanguages();

            //getting ctp value from ParticipantState for ctp toggles
            initDataNew.relevantLinksAreAvailable = ps.ctp.Relevant_Links_Are_Available__c;
            initDataNew.studyDocumentsAreAvailable = ps.ctp.Study_Documents_Are_Available__c;
            initDataNew.videoAndArticlesAreAvailable = ps.ctp.Video_And_Articles_Are_Available__c;
            initDataNew.isDelegate = ps.isDelegate;
            initDataNew.participantStateValue = String.valueOf(ps.value);

            List<Therapeutic_Area_Patient__c> therapeuticAreaPatients = [
                SELECT Id, Therapeutic_Area__c
                FROM Therapeutic_Area_Patient__c
                WHERE Participant__c = :ps.participant.Id
            ];
            for (Therapeutic_Area_Patient__c tap : therapeuticAreaPatients)
                COIsOfParticipant.add(tap.Therapeutic_Area__c);

            List<Resource__c> resourcesVisibleForParticipant = new List<Resource__c>();
            if (
                (ps.value != ParticipantService.ParticipantStates.ALUMNI &&
                initDataNew.relevantLinksAreAvailable) ||
                ps.value == ParticipantService.ParticipantStates.ALUMNI
            ) {
                //study specific relevant links
                resourcesVisibleForParticipant = getStudySpecificResources(
                    contentType,
                    enrollments,
                    preferredLanguages,
                    COIsOfParticipant,
                    ps.isDelegate
                );
            }

            if (
                (ps.value == ParticipantService.ParticipantStates.ALUMNI &&
                ps.isDelegate == false) || !initDataNew.relevantLinksAreAvailable
            ) {
                //platform level relevant links
                resourcesVisibleForParticipant.addAll(
                    getCOIResources(contentType, COIsOfParticipant, preferredLanguages)
                );
                if (!resourcesVisibleForParticipant.isEmpty())
                    initDataNew.linksAvailable = true;
            } else {
                if (enrollments.size() > 0)
                    initDataNew.linksAvailable = true;
            }

            TranslateHelper.translate(resourcesVisibleForParticipant);
            List<LabelValueItem> typeLabelValues = getTranslatedTypes(
                Resource__c.Type__c.getDescribe().getPicklistValues()
            );

            for (Resource__c res : resourcesVisibleForParticipant) {
                ResourceService.ResourceWrapper rw = new ResourceService.ResourceWrapper(res);
                initDataNew.resources.add(rw);
            }

            initDataNew.resources = ResourceService.sortResourcesByCOI(initDataNew.resources);
            return initDataNew;
        } catch (Exception e) {
            return (InitDataNew) AuraHelper.throwException(e);
        }
    }

    private static List<Resource__c> getStudySpecificResources(
        String contentType,
        List<Participant_Enrollment__c> enrollments,
        List<String> preferredLanguages,
        List<Id> coiIds,
        Boolean isDelegate
    ) {
        List<Resource__c> resourcesVisibleForParticipant = new List<Resource__c>();
        List<Id> ctpIds = new List<Id>();
        for (Participant_Enrollment__c pe : enrollments)
            ctpIds.add(pe.Clinical_Trial_Profile__c);

        if (ctpIds != null && ctpIds.size() > 0) {
            List<Res_study__c> resStudies = [
                SELECT
                    Id,
                    Clinical_Trial_Profile__c,
                    Resource__c,
                    Resource__r.URL__c,
                    Resource__r.Title__c,
                    Resource__r.Type__c,
                    Resource__r.Content_Type__c,
                    Resource__r.Countries__c,
                    Resource__r.Languages__c,
                    Visible_To_Participant__c,
                    Visible_To_Delegates__c,
                    Visible_To_PI__c,
                    Visible_To_RP__c,
                    Visible_In_Alumni__c,
                    Expires_After_Days__c,
                    Expires_On_Status__c,
                    Active_On_Status__c,
                    Active_After_Days__c
                FROM Res_study__c
                WHERE
                    Clinical_Trial_Profile__c IN :ctpIds
                    AND Resource__r.Content_Type__c = :contentType
            ];

            List<Id> resourceIdsVisibleForParticipant = new List<Id>();
            for (Res_study__c rs : resStudies) {
                for (Participant_Enrollment__c pe : enrollments) {
                    if (
                        rs.Clinical_Trial_Profile__c == pe.Clinical_Trial_Profile__c &&
                        StudyResourceVisibilityService.isResourceVisibleForPE(
                            rs,
                            pe,
                            preferredLanguages,
                            CommunityService.getUserContact().userCommunityMode__c,
                            isDelegate
                        )
                    ) {
                        resourceIdsVisibleForParticipant.add(rs.Resource__c);
                    }
                }
            }

            resourcesVisibleForParticipant = [
                SELECT
                    Id,
                    Title__c,
                    Type__c,
                    URL__c,
                    description__c,
                    CreatedDate,
                    (
                        SELECT Id, Therapeutic_Area__c
                        FROM Therapeutic_Area_Assignments__r
                        WHERE Therapeutic_Area__c IN :coiIds
                    )
                FROM Resource__c
                WHERE Id IN :resourceIdsVisibleForParticipant
                ORDER BY CreatedDate DESC
            ];
        }
        return resourcesVisibleForParticipant;
    }

    private static Set<Resource__c> getCOIResources(
        String contentType,
        List<Id> coiIds,
        List<String> preferredLanguages
    ) {
        Set<Resource__c> coiResources = new Set<Resource__c>();
        List<Id> resWithResStudyIds = new List<Id>();
        List<Id> taaResIds = new List<Id>();
        List<Id> coiResIds = new List<Id>();

        List<Therapeutic_Area_Assignment__c> taAssignments = [
            SELECT Resource__c
            FROM Therapeutic_Area_Assignment__c
            WHERE Therapeutic_Area__c IN :coiIds
        ];
        for (Therapeutic_Area_Assignment__c taa : taAssignments)
            taaResIds.add(taa.Resource__c);

        List<Res_study__c> resStudies = [
            SELECT Id, Resource__c
            FROM Res_study__c
            WHERE Resource__c IN :taaResIds AND Resource__r.Content_Type__c = :contentType
        ];
        for (Res_study__c rs : resStudies)
            resWithResStudyIds.add(rs.Resource__c);

        for (Id res : taaResIds) {
            if (!resWithResStudyIds.contains(res))
                coiResIds.add(res);
        }

        List<Resource__c> resources = [
            SELECT
                Id,
                Title__c,
                Type__c,
                URL__c,
                Languages__c,
                description__c,
                (
                    SELECT Id, Therapeutic_Area__c
                    FROM Therapeutic_Area_Assignments__r
                    WHERE Therapeutic_Area__c IN :coiIds
                )
            FROM Resource__c
            WHERE Id IN :coiResIds AND Content_Type__c = :contentType
            ORDER BY CreatedDate DESC
        ];

        for (Resource__c res : resources) {
            for (String lang : preferredLanguages) {
                if (res.Languages__c.contains(lang))
                    coiResources.add(res);
            }
        }
        return coiResources;
    }

    private static List<Participant_Enrollment__c> getEnrollments(
        ParticipantService.ParticipantState participantState
    ) {
        List<Participant_Enrollment__c> enrollments = new List<Participant_Enrollment__c>();
        if (participantState.value == ParticipantService.ParticipantStates.ALUMNI) {
            Id currentContactId = CommunityService.getInstance().getCurrentContactId();
            if (participantState.isDelegate)
                currentContactId = PatientDelegateService.getParticipantByDelegateContactId(
                        currentContactId
                    )
                    .Contact__c;

            List<Id> peIds = PatientDelegateService.getPastPEIdsForContact(currentContactId);
            if (peIds != null) {
                enrollments = [
                    SELECT
                        Id,
                        Days_After_Enrolled__c,
                        Participant_Status__c,
                        Clinical_Trial_Profile__c,
                        Clinical_Trial_Profile__r.Relevant_Links_Are_Available__c,
                        Study_Site__r.Approved_Lng__c,
                        Study_Site__r.Site__r.BillingCountryCode
                    FROM Participant_Enrollment__c
                    WHERE
                        Id IN :peIds
                        AND Clinical_Trial_Profile__r.Relevant_Links_Are_Available__c = TRUE
                ];
            }
        } else {
            enrollments = new List<Participant_Enrollment__c>();
            if (participantState.ctp.Relevant_Links_Are_Available__c)
                enrollments.add(participantState.pe);
        }
        return enrollments;
    }

    private static List<LabelValueItem> getTranslatedTypes(List<PicklistEntry> types) {
        List<LabelValueItem> translatedTypes = new List<LabelValueItem>();
        for (PicklistEntry t : types) {
            if (!t.getValue().equals('None'))
                translatedTypes.add(new LabelValueItem(t.getLabel(), t.getValue()));
        }
        return translatedTypes;
    }
}
