public virtual inherited sharing class ResourceStudyRelatedService extends ResourceService {
    private static final List<String> RES_STUDY_FIELDS = new List<String>{
        'Id',
        'Active_On_Status__c',
        'Expires_On_Status__c',
        'Active_After_Days__c',
        'Expires_After_Days__c',
        'Notify_On_Availability__c',
        'Visible_In_Alumni__c',
        'Visible_To_Delegates__c',
        'Visible_To_Participant__c',
        'Visible_To_PI__c',
        'Visible_To_RP__c',
        'Resource__c',
        'Resource__r.Language__c',
        'Resource__r.Content_Type__c',
        'Resource__r.Title__c'
    };

    private Id ctpId;

    public static ResourceStudyRelatedService getInstance() {
        return (ResourceStudyRelatedService) ClassFactory.newInstance(
            ResourceStudyRelatedService.class
        );
    }

    public ResourceService init(
        String resourceType,
        String resourceId,
        String contentClass,
        Id ctpId
    ) {
        this.init(resourceType, resourceId, contentClass,participantData);
        this.ctpId = ctpId;
        return this;
    }

    protected virtual override List<Id> getResourcesIds() {
        if (resourceId != null)
            return new List<Id>{ resourceId };
            List<String> listResourceType= new List<String>();
            listResourceType=resourceType.split(';');
        //Create filter for query:
        String filter = DatabaseService.fieldInValues(
            'Resource__r.RecordType.DeveloperName',
            listResourceType
        );
        if (contentClass != null)
            filter +=
                ' AND ' + DatabaseService.fieldEqual('Resource__r.Content_Class__c', contentClass);
        if (resourceId != null) {
            filter += ' AND ' + DatabaseService.fieldEqual('Resource__c', resourceId);
        } else {
            filter += ' AND ' + DatabaseService.fieldEqual('Clinical_Trial_Profile__c', getCTPId());
        }
        List<Res_study__c> resStudies = (List<Res_study__c>) DatabaseService.query(
            RES_STUDY_FIELDS,
            Res_study__c.getSObjectType(),
            filter
        );

        //split resources
        List<Res_study__c> studyDocumentsResources = new List<Res_study__c>();
        List<Res_study__c> otherResources = new List<Res_study__c>();
        for (Res_study__c rs : resStudies) {
            if (rs.Resource__r.Content_Type__c == 'Study_Document') {
                studyDocumentsResources.add(rs);
            } else {
                otherResources.add(rs);
            }
        }

        List<String> contactPreferredLanguages = ContactService.getPreferredLanguages();
        String userMode= CommunityService.getUserContact().userCommunityMode__c;

        //retrieve languages for study docs
        Map<Id, List<String>> contentLangByResId = new Map<Id, List<String>>();
        Set<Id> studyDocResourceIds = new Set<Id>();
        for (Res_study__c rs : studyDocumentsResources)
            studyDocResourceIds.add(rs.Resource__c);
        if (studyDocumentsResources.size() > 0) {
            List<ContentDocumentLink> contentDocumentLinks = [
                SELECT
                    Id,
                    ContentDocument.Title,
                    LinkedEntityId,
                    ContentDocument.LatestPublishedVersion.LanguageCode__c
                FROM ContentDocumentLink
                WHERE
                    LinkedEntityId IN :studyDocResourceIds
                    AND (ContentDocument.Title IN :contactPreferredLanguages
                    OR ContentDocument.LatestPublishedVersion.LanguageCode__c IN :contactPreferredLanguages)
            ];

            for (ContentDocumentLink content : contentDocumentLinks) {
                if (!contentLangByResId.containsKey(content.LinkedEntityId)) {
                    contentLangByResId.put(content.LinkedEntityId, new List<String>());
                }
                if (contactPreferredLanguages.contains(content.ContentDocument.Title)) {
                    contentLangByResId.get(content.LinkedEntityId)
                        .add(content.ContentDocument.Title);
                } else {
                    contentLangByResId.get(content.LinkedEntityId)
                        .add(content.ContentDocument.LatestPublishedVersion.LanguageCode__c);
                }
            }
        }

        //group other resources by title:
        Map<String, Map<String, Res_study__c>> otherResourceMap = new Map<String, Map<String, Res_study__c>>();
        for (Res_study__c resStudy : otherResources) {
            if (!otherResourceMap.containsKey(resStudy.Resource__r.Title__c))
                otherResourceMap.put(
                    resStudy.Resource__r.Title__c,
                    new Map<String, Res_study__c>()
                );
            otherResourceMap.get(resStudy.Resource__r.Title__c)
                .put(resStudy.Resource__r.Language__c, resStudy);
        }

        //Get Res Study records and filters result resource Ids
        //Study document resources:
        List<Id> resourcesIds = new List<Id>();
        for (Res_study__c resStudy : studyDocumentsResources) {
            if (
                StudyResourceVisibilityService.isResourceVisibleForPE(
                    resStudy,
                    pState.pe,
                    contentLangByResId.get(resStudy.Resource__c),
                    userMode,
                    pState.isDelegate
                )
            )
                resourcesIds.add(resStudy.Resource__c);
        }
        //Other resources:
        for (String resTitle : otherResourceMap.keySet()) {
            Map<String, Res_study__c> resourceTranslationsMap = otherResourceMap.get(resTitle);
            for (String lang : contactPreferredLanguages) {
                Res_study__c resStudy = resourceTranslationsMap.get(lang);
                if (
                    resStudy != null &&
                    StudyResourceVisibilityService.isResourceVisibleForPE(
                        resStudy,
                        pState.pe,
                        new List<String>{ lang },
                        userMode,
                        pState.isDelegate
                    )
                ) {
                    resourcesIds.add(resStudy.Resource__c);
                    break;
                }
            }
        }
        return resourcesIds;
    }

    protected override ResourceService.ResourceWrapperContainer getErrorNoObjectsToFilter() {
        return ResourceService.getErrorMissingStudy();
    }

    protected override Boolean isObjectsToFilterMissing() {
        return (resourceId == null && pState.value == ParticipantService.ParticipantStates.ALUMNI);
    }

    protected Id getCTPId() {
        if (ctpId == null && pState.ctp != null)
            ctpId = pState.ctp.Id;
        return ctpId;
    }
}
