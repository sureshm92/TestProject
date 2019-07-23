/**
 * created by Dmytro Pokutnii
 */
public without sharing class ResourceService {

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
    public static final String RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT = 'Study_Document';

    private static final String EXPIRATION_DATE_API_NAME = 'Expiration_Date__c';
    private static final String BYLINE_API_NAME = 'Byline__c';
    private static final String AUTHOR_S_NAME_API_NAME = 'Author_s_Name__c';

    private ParticipantService.ParticipantState pState;
    private Participant__c participant;
    private String resourceType;

    public ResourceService() {
        this.resourceType = ResourceService.RESOURCE_TYPE_ARTICLE;
        this.pState = ((ParticipantService) ClassFactory.newInstance(ParticipantService.class)).getState();
    }

    public ResourceWrapperContainer getResources(String resourceType) {

        this.resourceType = resourceType;
        return ((ResourceArticleVideoService) ClassFactory.newInstance(ResourceArticleVideoService.class))
                .init(this)
                .getResourceWrapperContainer();
    }

    public ResourceWrapperContainer getFavoriteResources(String resourceType) {

        this.resourceType = resourceType;
        return ((ResourceFavoriteService) ClassFactory.newInstance(ResourceFavoriteService.class))
                .init(this)
                .getResourceWrapperContainer();
    }

    public ResourceWrapperContainer getStudyDocuments() {

        this.resourceType = ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT;
        return ((ResourceStudyDocumentService) ClassFactory.newInstance(ResourceStudyDocumentService.class))
                .init(this)
                .getResourceWrapperContainer();
    }

    public Participant__c getParticipant() {
        return (this.participant == null ? this.getParticipant(this.resourceType) : this.participant);
    }

    public String getResourceType() {
        return (this.resourceType == null ? ResourceService.RESOURCE_TYPE_ARTICLE : this.resourceType);
    }

    public ParticipantService.ParticipantState getParticipantState() {
        return this.pState;
    }

    public String getParticipantLanguage() {
        String language = this.getParticipant().Contact__r.Language__c;
        return (String.isBlank(language) ? ResourceService.DEFAULT_LANGUAGE : language);
    }

    public Participant__c getParticipant(String resourceType) {

        String participantId = this.getParticipantId();
        String participantQuery =
                'SELECT Id, ' +
                        'Contact__r.Language__c, ' +
                        'Conditions__c, ' +
                        '(SELECT Id, Therapeutic_Area__c, IsRelatedToStudy__c, Condition_Of_Interest_Order__c FROM Therapeutic_Area_Patients__r ORDER BY Condition_Of_Interest_Order__c), ' +
                        '(SELECT Id, Resource__c FROM Resource_Actions__r WHERE IsFavorite__c = true AND Resource__r.RecordType.DeveloperName = \'' + resourceType + '\') ' +
                        'FROM Participant__c ' +
                        'WHERE Id = \'' + participantId + '\'';
        this.participant = ((List<Participant__c>) ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class)).query(participantQuery))[0];
        return this.participant;
    }

    public String getParticipantId() {
        return this.pState.participant.Id;
    }

    public static ResourceWrapperContainer getErrorMissingStudy() {
        return new ResourceWrapperContainer(CommunityService.ERROR_MISSING_STUDY);
    }

    public static ResourceWrapperContainer getErrorNoStudyDocuments() {
        return new ResourceWrapperContainer(Label.Resources_No_Study_Documents);
    }

    public static ResourceWrapperContainer getErrorNoArticles(Boolean isFavorite) {
        return new ResourceWrapperContainer((isFavorite ? Label.Resources_No_Favorite_Articles : Label.Resources_No_Articles));
    }

    public static ResourceWrapperContainer getErrorNoVideos(Boolean isFavorite) {
        return new ResourceWrapperContainer((isFavorite ? Label.Resources_No_Favorite_Videos : Label.Resources_No_Videos));
    }

    public static ResourceWrapperContainer getErrorUnhandled() {
        return new ResourceWrapperContainer('Unhandled Error.');
    }

    public ResourceWrapperContainer getResourcesById(String resourceId, String resourceType) {

        List<Resource__c> resources = new List<Resource__c>();
        this.resourceType = resourceType;
        if (ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT.containsIgnoreCase(resourceType)) {
            resources.addAll(((ResourceStudyDocumentService) ClassFactory.newInstance(ResourceStudyDocumentService.class))
                    .init(this, resourceId)
                    .getResources());
        } else {
            resources.addAll(((ResourceArticleVideoService) ClassFactory.newInstance(ResourceArticleVideoService.class))
                    .init(this, resourceId)
                    .getResources());
        }
        if (!resources.isEmpty()) {
            return new ResourceWrapperContainer((List<ResourceWrapper>) new List<ResourceDetailWrapper>{
                    new ResourceDetailWrapper(resources[0])
            });
        }
        return new ResourceWrapperContainer(Label.Resources_Not_Access_In_Resource);
    }

    public void deleteRelatedToStudyDocuments(List<Clinical_Trial_Profile__c> trialProfiles) {

        Set<Id> resourcesForDelete = new Set<Id>();
        List<Res_study__c> relatedResStudies = [
                SELECT Resource__r.Name,
                        Resource__r.Title__c
                FROM Res_study__c
                WHERE (Clinical_Trial_Profile__c
                        IN:trialProfiles) AND Resource__r.RecordType.DeveloperName = :RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT
        ];
        if (!relatedResStudies.isEmpty()) {
            for (Res_study__c r : relatedResStudies) {
                resourcesForDelete.add(r.Resource__c);
            }
        }
        List<Res_study__c> NotCompletedProfiles = [
                SELECT Resource__r.Name,
                        Resource__r.Title__c
                FROM Res_study__c
                WHERE (Clinical_Trial_Profile__c NOT IN:trialProfiles)AND Resource__c IN:resourcesForDelete
        ];
        if (!NotCompletedProfiles.isEmpty()) {
            for (Res_study__c r : NotCompletedProfiles) {
                resourcesForDelete.remove(r.Resource__c);
            }
        }
        delete relatedResStudies;
        if (!resourcesForDelete.isEmpty()) {
            Database.delete(new List<Id>(resourcesForDelete));
        }
    }

    public List<Resource__c> getResources(Participant__c participant, String whereClause, String orderByClause) {

        String resourcesQuery =
                'SELECT Id, ' +
                        'Title__c, ' +
                        'Description__c, ' +
                        'Expiration_Date__c, ' +
                        'Image__c, ' +
                        'Video__c, ' +
                        'Body__c, ' +
                        'Updated_Date__c, ' +
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
                        'Version_Date__c, ' +
                        '(SELECT Id, IsFavorite__c, IsVoted__c FROM Resource_Actions__r WHERE Participant__c = \'' + participant.Id + '\') ' +
                        'FROM Resource__c ' +
                        whereClause +
                        (String.isBlank(orderByClause) ? '' : orderByClause + ' ');
        return (List<Resource__c>) ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class)).query(resourcesQuery);
    }

    public ResourceWrapperContainer getResourceWrapperContainer(List<Resource__c> resources) {
        return new ResourceService.ResourceWrapperContainer(this.getResourceWrappers(resources));
    }

    @TestVisible
    private List<ResourceService.ResourceWrapper> getResourceWrappers(List<Resource__c> resources) {
        List<ResourceService.ResourceWrapper> wrappers = new List<ResourceService.ResourceWrapper>();
        Set<Resource__c> resourcesSet = new Set<Resource__c>();
        for (Resource__c singleResource : resources) {
            if (resourcesSet.add(singleResource)) {
                wrappers.add(new ResourceService.ResourceWrapper(singleResource));
            }
        }
        return wrappers;
    }

    public class ResourceWrapperContainer {

        @AuraEnabled
        public List<ResourceWrapper> wrappers;
        @AuraEnabled
        public String errorMessage;

        public ResourceWrapperContainer(String errorMessage) {
            this.errorMessage = errorMessage;
        }

        public ResourceWrapperContainer(List<ResourceWrapper> wrappers) {
            this.wrappers = wrappers;
        }
    }

    public virtual class ResourceWrapper {

        @AuraEnabled
        public Resource__c resource;
        @AuraEnabled
        public Boolean isFavorite = false;
        @AuraEnabled
        public Boolean isVoted = false;

        public ResourceWrapper(Resource__c resource) {
            if (!ResourceDecoupler.getResourceActions(resource).isEmpty()) {
                this.isFavorite = ResourceDecoupler.getResourceActions(resource)[0].IsFavorite__c;
                this.isVoted = ResourceDecoupler.getResourceActions(resource)[0].IsVoted__c;
            }
            this.resource = resource;
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
                resourceFieldApis = getResourceFieldApis(resource.X3rd_Party_Source__c, resource.RecordType.DeveloperName);
            } else {
                resourceFieldApis = getResourceFieldApis(null, resource.RecordType.DeveloperName);
            }
            if (RESOURCE_SOURCE_THIRD_PARTY.equalsIgnoreCase(resource.Content_Class__c) && !String.isBlank(resource.article_external_link__c)) {
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
                        headerFieldWrappers.add(new ResourceFieldWrapper(fieldApi.Field_Api_Name__c, valueField, fieldApi.CSS_Class_Name__c));
                    } else {
                        bodyFieldWrappers.add(new ResourceFieldWrapper(fieldApi.Field_Api_Name__c, valueField, fieldApi.CSS_Class_Name__c));
                    }
                } else if (BYLINE_API_NAME.equalsIgnoreCase(fieldApi.Field_Api_Name__c)) {
                    valueField = resource.get(AUTHOR_S_NAME_API_NAME);
                    if (valueField != null) {
                        bodyFieldWrappers.add(new ResourceFieldWrapper(AUTHOR_S_NAME_API_NAME, valueField, fieldApi.CSS_Class_Name__c));
                    }
                }
            }
        }

        private Resource_Field_Api__mdt[] getResourceFieldApis(String x3rdPartySource, String resourceType) {
            Resource_Field_Api__mdt[] resourceFieldApis = [
                    SELECT Order__c,
                            Resource_Type__c,
                            X3rd_Party_Source__c,
                            Field_Api_Name__c,
                            CSS_Class_Name__c
                    FROM Resource_Field_Api__mdt
                    WHERE X3rd_Party_Source__c = :x3rdPartySource
                    AND Resource_Type__c = :resourceType
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