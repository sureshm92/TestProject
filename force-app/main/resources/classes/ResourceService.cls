/**
 * created by Dmytro Pokutnii
 */
public virtual without sharing class ResourceService {
    public static final String RESOURCE_SOURCE_STUDY = 'Study-Specific';
    public static final String RESOURCE_SOURCE_PLATFORM = 'Platform-TA';
    public static final String RESOURCE_SOURCE_THIRD_PARTY = '3rd Party';
    public static final String RESOURCE_STUDY_DOCUMENT = 'Study Document';
    public static final String X3_RD_PARTY_NOT_SOURCE = 'N/A';
    public static final String X_3PARTY_HEALTH_DAY = 'HealthDay';
    public static final String X_3PARTY_IQVIA = 'IQVIA';
    public static final String DEFAULT_LANGUAGE = 'en_US';
    public static final String RESOURCE_TYPE_ARTICLE = 'Article';
    public static final String RESOURCE_TYPE_VIDEO = 'Video';
    public static final String RESOURCE_TYPE_DOCUMENT = 'Document';
    public static final String RESOURCE_TYPE_RELEVANT_LINK = 'Relevant_Link';
    public static final String RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT = 'Study_Document';

    private static final String EXPIRATION_DATE_API_NAME = 'Expiration_Date__c';
    private static final String BYLINE_API_NAME = 'Byline__c';
    private static final String AUTHOR_S_NAME_API_NAME = 'Author_s_Name__c';

    protected ParticipantService.ParticipantState pState;
    protected Participant__c participant;
    protected String resourceType;
    protected String contentClass;
    protected String resourceId;
    protected String participantData;

    public static ResourceService getInstance() {
        return (ResourceService) ClassFactory.newInstance(ResourceService.class);
    }

    public ResourceService() {
        resourceType = ResourceService.RESOURCE_TYPE_ARTICLE;
    }

    public ResourceService init(String resourceType) {
        return init(resourceType, null, null,null);
    }

    public ResourceService init(String resourceType, String resourceId) {
        return init(resourceType, resourceId, null,null);
    }
    public ResourceService ppinit(String resourceType, String participantData) {
        return init(resourceType, resourceId, null, participantData);
    }

    public ResourceService init(
        String resourceType,
        String resourceId,
        String contentClass,
        String participantData
    ) {
        this.resourceType = resourceType;
        this.resourceId = resourceId;
        this.contentClass = contentClass;
        this.participantData=participantData;
        if (participantData != null) {
            this.pstate = (ParticipantService.ParticipantState) JSON.deserialize(
                participantData,
                ParticipantService.ParticipantState.class
            );
            this.participant = pState.participant;
        }
        if (this.participant == null) {
            this.pState = ((ParticipantService) ClassFactory.newInstance(ParticipantService.class))
                .getState();
            this.participant = pState.participant;
        }

        return this;
    }

    public ResourceService.ResourceWrapperContainer getResourceWrapperContainer() {
        Boolean isFilterDataMissing = isObjectsToFilterMissing() && resourceId != null;
        if (isFilterDataMissing) {
            return getErrorNoObjectsToFilter();
        } else {
            List<Resource__c> resources = getResources();
            if (resources.size() > 0) {
                return getResourceWrapperContainer(resources);
            } else {
                return getErrorNoResources();
            }
        }
    }

    public virtual List<Resource__c> getResources() {
        List<Resource__c> resources = new List<Resource__c>();
        if (resourceId != null && isObjectsToFilterMissing())
            return resources;
        List<Id> resourcesIds;
        if (resourceId != null) {
            resourcesIds = new List<Id>{ resourceId };
        } else {
            resourcesIds = getResourcesIds();
        }
        if (resourcesIds.size() > 0) {
            String whereClause =
                'WHERE Id IN (' +
                CollectionUtil.joinByComa(CollectionUtil.wrapInApostrophes(resourcesIds)) +
                ')';
            if (Site.getMasterLabel() == 'IQVIA Patient Portal') {
                whereClause =
                    whereClause +
                    ' ' +
                    'AND  (Expiration_Date__c > TODAY OR Expiration_Date__c = NULL)';
                resources = getResources(whereClause, getPPOrderByClause());
            } else {
                resources = getResources(whereClause, getOrderByClause());
            }
        }
        return resources;
    }

    protected virtual List<Id> getResourcesIds() {
        return new List<Id>();
    }

    protected virtual String getOrderByClause() {
        return 'ORDER BY Posting_Date__c DESC NULLS LAST';
    }

    protected virtual String getPPOrderByClause() {
        return 'ORDER BY CreatedDate DESC NULLS LAST';
    }

    protected virtual ResourceService.ResourceWrapperContainer getErrorNoResources() {
        return new ResourceService.ResourceWrapperContainer('Unhandled Error.');
    }

    protected virtual ResourceService.ResourceWrapperContainer getErrorNoObjectsToFilter() {
        return this.getErrorNoResources();
    }

    protected virtual Boolean isObjectsToFilterMissing() {
        return true;
    }

    public String getParticipantLanguage() {
        String language = pState.participant.Contact__r.Language__c;
        return (String.isBlank(language) ? ResourceService.DEFAULT_LANGUAGE : language);
    }

    public Participant__c getParticipant(String resourceType) {
        String participantId = pState.participant.Id;
        String participantQuery =
            'SELECT Id, ' +
            'Contact__r.Language__c, ' +
            'Conditions__c, ' +
            '(SELECT Id, Therapeutic_Area__c, IsRelatedToStudy__c, Condition_Of_Interest_Order__c FROM Therapeutic_Area_Patients__r ORDER BY Condition_Of_Interest_Order__c), ' +
            '(SELECT Id, Resource__c FROM Resource_Actions__r WHERE IsFavorite__c = true AND Resource__r.RecordType.DeveloperName = \'' +
            resourceType +
            '\') ' +
            'FROM Participant__c ' +
            'WHERE Id = \'' +
            participantId +
            '\'';
        this.participant = ((List<Participant__c>) ((DatabaseProxy) ClassFactory.newInstance(
                DatabaseProxy.class
            ))
            .query(participantQuery, true))[0];
        return this.participant;
    }

    public static ResourceWrapperContainer getErrorMissingStudy() {
        return new ResourceWrapperContainer(CommunityService.ERROR_MISSING_STUDY);
    }

    public static ResourceWrapperContainer getErrorNoStudyDocuments() {
        return new ResourceWrapperContainer(Label.Resources_No_Study_Documents);
    }

    public static ResourceWrapperContainer getErrorNoArticles(Boolean isFavorite) {
        return new ResourceWrapperContainer(
            (isFavorite ? Label.Resources_No_Favorite_Articles : Label.Resources_No_Articles)
        );
    }

    public static ResourceWrapperContainer getErrorNoVideos(Boolean isFavorite) {
        return new ResourceWrapperContainer(
            (isFavorite ? Label.Resources_No_Favorite_Videos : Label.Resources_No_Videos)
        );
    }

    public static ResourceWrapperContainer getErrorUnhandled() {
        return new ResourceWrapperContainer('Unhandled Error.');
    }

    public List<Resource__c> getResources(String whereClause, String orderByClause) {
        Id participantId;
        List<String> COIsOfParticipant = new List<String>();
        if (participant != null) {
            participantId = participant.Id;
            List<Therapeutic_Area_Patient__c> therapeuticAreaPatients = [
                SELECT Therapeutic_Area__r.Name
                FROM Therapeutic_Area_Patient__c
                WHERE Participant__c = :participant.Id
            ];
            for (Therapeutic_Area_Patient__c tap : therapeuticAreaPatients) {
                COIsOfParticipant.add(
                    '\'' +
                    tap.Therapeutic_Area__r.Name.replaceAll('\'', '\\\\\'') +
                    '\''
                );
            }
        }
        String resourcesQuery =
            'SELECT Id, ' +
            'Title__c, ' +
            'Description__c, ' +
            'Expiration_Date__c, ' +
            'Image__c, ' +
            'Video__c, ' +
            'Body__c, ' +
            'Updated_Date__c, ' +
            'CreatedDate, ' +
            'RecordType.DeveloperName, ' +
            'Content_Class__c, ' +
            'Content_Type__c, ' +
            'document_type__c, ' +
            'Image_Subtitle__c, ' +
            'article_external_link__c, ' +
            'Subtitle__c, ' +
            'Byline__c, ' +
            'Author_s_Name__c, ' +
            'URL_Part__c, ' +
            'Copyright__c, ' +
            'X3rd_Party_Source__c, ' +
            'Image_Title__c, ' +
            'Source__c, ' +
            ((participantId != null && !COIsOfParticipant.isEmpty())
                ? '(SELECT Id, Therapeutic_Area__r.Name FROM Therapeutic_Area_Assignments__r WHERE Therapeutic_Area__r.Name IN ' +
                  COIsOfParticipant +
                  '), '
                : '') +
            (participantId != null
                ? '(SELECT Id, IsFavorite__c, IsVoted__c FROM Resource_Actions__r WHERE Participant__c = \'' +
                  participantId +
                  '\'), '
                : '') +
            'Version_Date__c ' +
            'FROM Resource__c ' +
            whereClause +
            ' ' +
            (String.isBlank(orderByClause) ? '' : orderByClause + ' ');
        System.debug('>>> Resources Query: ' + resourcesQuery);
        return (List<Resource__c>) ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class))
            .query(resourcesQuery, true);
    }

    public ResourceWrapperContainer getResourceWrapperContainer(List<Resource__c> resources) {
        return new ResourceService.ResourceWrapperContainer(this.getResourceWrappers(resources));
    }

    public static List<ResourceWrapper> sortResourcesByCOI(List<ResourceWrapper> resourceWrappers) {
        List<ResourceComparing> resourceComparings = new List<ResourceComparing>();
        for (ResourceWrapper rw : resourceWrappers) {
            resourceComparings.add(new ResourceComparing(rw));
        }
        resourceComparings.sort();

        List<ResourceWrapper> rwSorted = new List<ResourceWrapper>();
        for (ResourceComparing rc : resourceComparings) {
            rwSorted.add(rc.res1);
        }
        return rwSorted;
    }
    public static List<ResourceWrapper> sortUpdateResourcesByCOI(
        List<ResourceWrapper> resourceWrappers
    ) {
        List<ResourceUpdateComparing> resourceComparings = new List<ResourceUpdateComparing>();
        for (ResourceWrapper rw : resourceWrappers) {
            resourceComparings.add(new ResourceUpdateComparing(rw));
        }
        resourceComparings.sort();

        List<ResourceWrapper> rwSorted = new List<ResourceWrapper>();
        for (ResourceUpdateComparing rc : resourceComparings) {
            rwSorted.add(rc.res1);
        }
        return rwSorted;
    }
    public static List<ResourceWrapper> sortResourcesByCreatedDate(
        List<ResourceWrapper> resourceWrappers
    ) {
        List<ResourceSorting> resourceSortings = new List<ResourceSorting>();
        for (ResourceWrapper rw : resourceWrappers) {
            resourceSortings.add(new ResourceSorting(rw));
        }
        resourceSortings.sort();

        List<ResourceWrapper> rwSorted = new List<ResourceWrapper>();
        for (ResourceSorting rc : resourceSortings) {
            rwSorted.add(rc.res1);
        }
        return rwSorted;
    }

    public static List<ResourceWrapper> removeTranslations(List<ResourceWrapper> resourceWrappers) {
        List<String> availableLanForUser = ContactService.getPreferredLanguages();

        for (ResourceWrapper c : resourceWrappers) {
            List<ContentDocumentLinkService.TranslatedContentItem> translationsOfSD = new List<ContentDocumentLinkService.TranslatedContentItem>();
            for (ContentDocumentLinkService.TranslatedContentItem translation : c.translations) {
                if (availableLanForUser.contains(translation.languageCode))
                    translationsOfSD.add(translation);
            }
            c.translations = translationsOfSD;
        }
        return resourceWrappers;
    }

    @TestVisible
    private List<ResourceService.ResourceWrapper> getResourceWrappers(List<Resource__c> resources) {
        List<Id> resourceIds = new List<Id>();
        for (Resource__c resource : resources)
            resourceIds.add(resource.Id);
        Map<Id, List<ContentDocumentLinkService.TranslatedContentItem>> translatedItemsMap = ((ContentDocumentLinkService) ClassFactory.newInstance(
                ContentDocumentLinkService.class
            ))
            .getTranslatedItemsForResources(resourceIds);
        List<ResourceService.ResourceWrapper> wrappers = new List<ResourceService.ResourceWrapper>();
        Set<Resource__c> resourcesSet = new Set<Resource__c>();
        for (Resource__c singleResource : resources) {
            if (resourcesSet.add(singleResource)) {
                if (translatedItemsMap.containsKey(singleResource.Id)) {
                    wrappers.add(
                        new ResourceService.ResourceWrapper(
                            singleResource,
                            translatedItemsMap.get(singleResource.Id)
                        )
                    );
                }
            }
        }
        return wrappers;
    }

    public class ResourceWrapperContainer {
        @AuraEnabled
        public List<ResourceWrapper> wrappers = new List<ResourceService.ResourceWrapper>();
        @AuraEnabled
        public String errorMessage;

        public ResourceWrapperContainer(String errorMessage) {
            this.errorMessage = errorMessage;
        }

        public ResourceWrapperContainer(List<ResourceWrapper> wrappers) {
            this.wrappers = wrappers;
        }
    }

    public virtual class ResourceComparing implements Comparable {
        public ResourceService.ResourceWrapper res1;

        public ResourceComparing(ResourceService.ResourceWrapper res1) {
            this.res1 = res1;
        }

        public Integer compareTo(Object param1) {
            ResourceComparing res2 = (ResourceComparing) param1;

            Integer returnValue = 0; // The return value of 0 indicates that both elements are equal.
            if (
                res1.resource.Therapeutic_Area_Assignments__r.size() <
                res2.res1.resource.Therapeutic_Area_Assignments__r.size()
            ) {
                returnValue = 1; // Set return value to a positive value.
            } else if (
                res1.resource.Therapeutic_Area_Assignments__r.size() >
                res2.res1.resource.Therapeutic_Area_Assignments__r.size()
            ) {
                returnValue = -1; // Set return value to a negative value.
            }

            return returnValue;
        }
    }
    public virtual class ResourceUpdateComparing implements Comparable {
        public ResourceService.ResourceWrapper res1;

        public ResourceUpdateComparing(ResourceService.ResourceWrapper res1) {
            this.res1 = res1;
        }

        public Integer compareTo(Object param1) {
            ResourceUpdateComparing res2 = (ResourceUpdateComparing) param1;

            Integer returnValue = 0; // The return value of 0 indicates that both elements are equal.
            if (
                res1.resource.Content_Type__c != RESOURCE_TYPE_RELEVANT_LINK &&
                res2.res1.resource.Content_Type__c != RESOURCE_TYPE_RELEVANT_LINK
            ) {
                if (
                    res1.resource.Therapeutic_Area_Assignments__r?.size() <
                    res2.res1.resource.Therapeutic_Area_Assignments__r?.size()
                ) {
                    returnValue = 1;
                } else if (
                    res1.resource.Therapeutic_Area_Assignments__r?.size() <
                    res2.res1.resource.Therapeutic_Area_Assignments__r?.size()
                ) {
                    returnValue = -1;
                }
            } else if (
                res1.resource.Content_Type__c == RESOURCE_TYPE_RELEVANT_LINK &&
                res2.res1.resource.Content_Type__c == RESOURCE_TYPE_RELEVANT_LINK
            ) {
                if (
                    res1.therapeuticAssignments?.size() < res2.res1.therapeuticAssignments?.size()
                ) {
                    returnValue = 1;
                } else if (
                    res1.therapeuticAssignments?.size() < res2.res1.therapeuticAssignments?.size()
                ) {
                    returnValue = -1;
                }
            } else if (res1.resource.Content_Type__c == RESOURCE_TYPE_RELEVANT_LINK) {
                if (
                    res1.therapeuticAssignments?.size() <
                    res2.res1.resource.Therapeutic_Area_Assignments__r?.size()
                ) {
                    returnValue = 1;
                } else if (
                    res1.therapeuticAssignments?.size() <
                    res2.res1.resource.Therapeutic_Area_Assignments__r?.size()
                ) {
                    returnValue = -1;
                }
            } else {
                if (
                    res1.resource.Therapeutic_Area_Assignments__r?.size() <
                    res2.res1.therapeuticAssignments?.size()
                ) {
                    returnValue = 1;
                } else if (
                    res1.resource.Therapeutic_Area_Assignments__r?.size() <
                    res2.res1.therapeuticAssignments?.size()
                ) {
                    returnValue = -1;
                }
            }

            return returnValue;
        }
    }
    public virtual class ResourceSorting implements Comparable {
        public ResourceService.ResourceWrapper res1;

        public ResourceSorting(ResourceService.ResourceWrapper res1) {
            this.res1 = res1;
        }

        public Integer compareTo(Object param1) {
            ResourceSorting res2 = (ResourceSorting) param1;

            Integer returnValue = 0; // The return value of 0 indicates that both elements are equal.
            if (res1.resource.CreatedDate < res2.res1.resource.CreatedDate) {
                returnValue = 1; // Set return value to a positive value.
            } else if (res1.resource.CreatedDate > res2.res1.resource.CreatedDate) {
                returnValue = -1; // Set return value to a negative value.
            }

            return returnValue;
        }
    }
    public static Integer getUpdatesCounter(List<ResourceWrapper> resourceWrappers) {
        Integer counter = 0;
        List<LoginHistory> lastLoginList = [
            SELECT loginTime, Status
            FROM LoginHistory
            WHERE userId = :UserInfo.getUserId()
            ORDER BY LoginTime DESC
            LIMIT 7
        ];
        Datetime lastLogin;
        if (lastLoginList.size() > 1) {
            //get last successful logintime as we can't filter on status field
            for (Integer i = 1; i < lastLoginList.size(); i++) {
                if (lastLoginList[i].Status == 'Success') {
                    lastlogin = lastLoginList[i].loginTime;
                }
                break;
            }
            for (ResourceWrapper rw : resourceWrappers) {
                if (rw.resource.CreatedDate > lastlogin) {
                    counter++;
                }
            }
        }

        return counter;
    }
    public virtual class TherapeuticAssignments {
        @AuraEnabled
        public String resource = '';
        @AuraEnabled
        public String id = '';
        @AuraEnabled
        public String therapeuticArea = '';
    }

    public virtual class ResourceWrapper {
        @AuraEnabled
        public Resource__c resource;
        @AuraEnabled
        public List<TherapeuticAssignments> therapeuticAssignments;
        @AuraEnabled
        public Boolean isFavorite = false;
        @AuraEnabled
        public Boolean isVoted = false;
        @AuraEnabled
        public List<ContentDocumentLinkService.TranslatedContentItem> translations;
        @AuraEnabled
        public Id thumbnailDocId;

        public ResourceWrapper(Resource__c resource) {
            if (!ResourceDecoupler.getResourceActions(resource).isEmpty()) {
                this.isFavorite = ResourceDecoupler.getResourceActions(resource)[0].IsFavorite__c;
                this.isVoted = ResourceDecoupler.getResourceActions(resource)[0].IsVoted__c;
            }
            this.resource = resource;
        }

        public ResourceWrapper(
            Resource__c resource,
            List<ContentDocumentLinkService.TranslatedContentItem> translations
        ) {
            this(resource);
            this.translations = translations;
            if (translations != null && translations.size() > 0) {
                thumbnailDocId = translations[0].contentId;
            }
            for (ContentDocumentLinkService.TranslatedContentItem tci : translations) {
                if (UserInfo.getLanguage() == tci.languageCode) {
                    thumbnailDocId = tci.contentId;
                    break;
                }
            }
        }
    }

    public class ResourceDetailWrapper extends ResourceWrapper {
        @AuraEnabled
        public List<ResourceFieldWrapper> headerFieldWrappers = new List<ResourceFieldWrapper>();
        @AuraEnabled
        public List<ResourceFieldWrapper> bodyFieldWrappers = new List<ResourceFieldWrapper>();
        @AuraEnabled
        public String shareMessage;
        @AuraEnabled
        public Boolean isShareable;

        private Boolean cutList = false;

        public ResourceDetailWrapper(Resource__c resource) {
            super(resource);
            loadDataResource(resource);
        }

        private void loadDataResource(Resource__c resource) {
            Resource_Field_Api__mdt[] resourceFieldApis;
            if (X_3PARTY_HEALTH_DAY.equalsIgnoreCase(resource.X3rd_Party_Source__c)) {
                resourceFieldApis = getResourceFieldApis(
                    resource.X3rd_Party_Source__c,
                    resource.RecordType.DeveloperName
                );
            } else {
                resourceFieldApis = getResourceFieldApis(null, resource.RecordType.DeveloperName);
            }
            if (
                RESOURCE_SOURCE_THIRD_PARTY.equalsIgnoreCase(resource.Content_Class__c) &&
                !String.isBlank(resource.article_external_link__c)
            ) {
                shareMessage = this.getShareMessage();
                this.isShareable = true;
            }
            for (Resource_Field_Api__mdt fieldApi : resourceFieldApis) {
                if (EXPIRATION_DATE_API_NAME.equalsIgnoreCase(fieldApi.Field_Api_Name__c)) {
                    cutList = true;
                    continue;
                }
                Object valueField = resource.get(fieldApi.Field_Api_Name__c);
                if (valueField != null) {
                    if (!cutList) {
                        headerFieldWrappers.add(
                            new ResourceFieldWrapper(
                                fieldApi.Field_Api_Name__c,
                                valueField,
                                fieldApi.CSS_Class_Name__c
                            )
                        );
                    } else {
                        bodyFieldWrappers.add(
                            new ResourceFieldWrapper(
                                fieldApi.Field_Api_Name__c,
                                valueField,
                                fieldApi.CSS_Class_Name__c
                            )
                        );
                    }
                } else if (BYLINE_API_NAME.equalsIgnoreCase(fieldApi.Field_Api_Name__c)) {
                    valueField = resource.get(AUTHOR_S_NAME_API_NAME);
                    if (valueField != null) {
                        bodyFieldWrappers.add(
                            new ResourceFieldWrapper(
                                AUTHOR_S_NAME_API_NAME,
                                valueField,
                                fieldApi.CSS_Class_Name__c
                            )
                        );
                    }
                }
            }
        }

        private Resource_Field_Api__mdt[] getResourceFieldApis(
            String x3rdPartySource,
            String resourceType
        ) {
            Resource_Field_Api__mdt[] resourceFieldApis = [
                SELECT
                    Order__c,
                    Resource_Type__c,
                    X3rd_Party_Source__c,
                    Field_Api_Name__c,
                    CSS_Class_Name__c
                FROM Resource_Field_Api__mdt
                WHERE X3rd_Party_Source__c = :x3rdPartySource AND Resource_Type__c = :resourceType
                ORDER BY Order__c
            ];
            return resourceFieldApis;
        }
        private String getShareMessage() {
            return Label.Resources_social;
        }
    }

    public class ResourceFieldWrapper {
        @AuraEnabled
        public String apyName;
        @AuraEnabled
        public Object valueField;
        @AuraEnabled
        public String cssClassName;

        public ResourceFieldWrapper(String apyName, Object valueField, String cssClassName) {
            this.apyName = apyName;
            this.valueField = valueField;
            this.cssClassName = cssClassName;
        }
    }
}
