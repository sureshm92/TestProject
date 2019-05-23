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
    public static String DEFAULT_LANGUAGE = 'en_US';
    public static String RESOURCE_TYPE_ARTICLE = 'Article';
    public static String RESOURCE_TYPE_VIDEO = 'Video';
    public static String RESOURCE_TYPE_DOCUMENT = 'Document';
    public static String RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT = 'Study_Document';
    private static final String EXPIRATION_DATE_API_NAME = 'Expiration_Date__c';
    private static final String BYLINE_API_NAME = 'Byline__c';
    private static final String AUTHOR_S_NAME_API_NAME = 'Author_s_Name__c';

    public ResourceWrapperContainer getResources(String resourceType) {

        Participant__c participant = this.getParticipant(resourceType);
        if (ParticipantDecoupler.getTherapeuticAreaPatients(participant).isEmpty()) {
            return new ResourceWrapperContainer((ResourceService.RESOURCE_TYPE_ARTICLE.equalsIgnoreCase(resourceType)) ? Label.Resources_No_Articles : Label.Resources_No_Videos);
        }
        List<Resource__c> resources = this.getSortedResources(participant, resourceType);
        if (resources.isEmpty()) {
            return new ResourceWrapperContainer((ResourceService.RESOURCE_TYPE_ARTICLE.equalsIgnoreCase(resourceType)) ? Label.Resources_No_Articles : Label.Resources_No_Videos);
        }
        return new ResourceWrapperContainer(this.getResourceWrappers(resources));
    }

    public ResourceWrapperContainer getFavoriteResources(String resourceType) {

        Participant__c participant = this.getParticipant(resourceType);
        if (ParticipantDecoupler.getResourceActions(participant).isEmpty()) {
            return new ResourceWrapperContainer((ResourceService.RESOURCE_TYPE_ARTICLE.equalsIgnoreCase(resourceType)) ? Label.Resources_No_Favorite_Articles : Label.Resources_No_Favorite_Videos);
        }
        ResourceService.ResourceWrapperContainer container = this.getResources(resourceType);
        if (container.wrappers == null || container.wrappers.isEmpty()) {
            return new ResourceWrapperContainer((ResourceService.RESOURCE_TYPE_ARTICLE.equalsIgnoreCase(resourceType)) ? Label.Resources_No_Favorite_Articles : Label.Resources_No_Favorite_Videos);
        }
        /*get only favorite resources from all available and sorted resources*/
        List<ResourceService.ResourceWrapper> wrappers = new List<ResourceService.ResourceWrapper>();
        for (ResourceService.ResourceWrapper wrapper : container.wrappers) {
            if (wrapper.isFavorite) {
                wrappers.add(wrapper);
            }
        }
        if (wrappers.isEmpty()) {
            return new ResourceWrapperContainer((ResourceService.RESOURCE_TYPE_ARTICLE.equalsIgnoreCase(resourceType)) ? Label.Resources_No_Favorite_Articles : Label.Resources_No_Favorite_Videos);
        }
        return new ResourceWrapperContainer(wrappers);
    }

    public ResourceWrapperContainer getStudyDocuments() {

        ParticipantService.ParticipantState participantState = ParticipantService.getParticipantState();
        if (participantState.ctp == null) {
            return new ResourceWrapperContainer(CommunityService.ERROR_MISSING_STUDY);
        }
        List<Resource__c> resources = this.getStudyDocuments(participantState);
        if (resources == null || resources.isEmpty()) {
            return new ResourceWrapperContainer(Label.Resources_No_Study_Documents);
        }
        return new ResourceWrapperContainer(this.getResourceWrappers(resources));
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

    public ResourceWrapperContainer getResourcesById(String resourceId, String resourceType) {
        Participant__c participant = this.getParticipant(resourceType);
        ParticipantService.ParticipantState participantState = ParticipantService.getParticipantState();
        List<Resource__c> resources = new List<Resource__c>();
        if (ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT.containsIgnoreCase(resourceType)) {
            if (participantState.ctp != null) {
                resources = this.getStudyDocuments(participantState);
            }
        } else if (!ParticipantDecoupler.getTherapeuticAreaPatients(participant).isEmpty()) {
            resources = this.getSortedResources(participant, resourceType);
        }
        if (!resources.isEmpty()) {
            Map<Id, Resource__c> resourceMap = new Map<Id, Resource__c>(new List<Resource__c>(new Set<Resource__c>(resources)));
            if (resourceMap.get(resourceId) != null) {
                return new ResourceWrapperContainer((List<ResourceWrapper>) new List<ResourceDetailWrapper>{
                        new ResourceDetailWrapper(resourceMap.get(resourceId))
                });
            }
        }
        return new ResourceWrapperContainer(Label.Resources_Not_Access_In_Resource);
    }

    public Participant__c getParticipant() {
        return this.getParticipant(ResourceService.RESOURCE_TYPE_ARTICLE);
    }

    public ParticipantService.ParticipantState getParticipantState() {
        return ParticipantService.getParticipantState();
    }

    @TestVisible
    private List<Resource__c> getStudyDocuments(ParticipantService.ParticipantState participantState) {

        Set<String> resourcesIdsSet = this.getRelatedToStudyResourcesIds(participantState.ctp.Id, ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT);

        if (resourcesIdsSet.isEmpty()) {
            return new List<Resource__c>();
        }
        List<String> resourcesIds = new List<String>();
        resourcesIds.addAll(resourcesIdsSet);

        String whereClause = 'WHERE Id IN (' + String.join(resourcesIds, ', ') + ')';
        String orderByClause = 'ORDER BY Version_Date__c DESC NULLS LAST';
        return this.getResources(participantState.participant, whereClause, orderByClause);
    }

    @TestVisible
    private List<Resource__c> getResources(Participant__c participant, String whereClause, String orderByClause) {

        String language = this.getParticipantLanguage(participant);
        if (String.isBlank(whereClause)) {
            whereClause = 'WHERE Language__c = \'' + language + '\' ';
        } else {
            whereClause += ' AND Language__c = \'' + language + '\' ';
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
        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        return (List<Resource__c>) databaseProxy.query(resourcesQuery);
    }

    @TestVisible
    private List<Resource__c> getResources(Set<String> resourcesIdsSet, Participant__c participant) {

        if (resourcesIdsSet.isEmpty()) {
            return new List<Resource__c>();
        }
        List<String> resourcesIds = new List<String>();
        resourcesIds.addAll(resourcesIdsSet);

        String whereClause = 'WHERE Id IN (' + String.join(resourcesIds, ', ') + ')';
        String orderByClause = 'ORDER BY Posting_Date__c DESC NULLS LAST';
        return this.getResources(participant, whereClause, orderByClause);
    }

    @TestVisible
    private List<Resource__c> getResources(Participant__c participant, Id therapeuticAreaId, String resourceType, String resourceSource) {

        String therapeuticAreaAssignmentsQuery =
                'SELECT Id, ' +
                        'Resource__c ' +
                        'FROM Therapeutic_Area_Assignment__c ' +
                        'WHERE Therapeutic_Area__c = \'' + therapeuticAreaId + '\' AND ' +
                        'Resource__r.Content_Class__c = \'' + resourceSource + '\' AND ' +
                        'Resource__r.RecordType.DeveloperName = \'' + resourceType + '\'';
        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        List<Therapeutic_Area_Assignment__c> assignments = (List<Therapeutic_Area_Assignment__c>) databaseProxy.query(therapeuticAreaAssignmentsQuery);
        Set<String> resourcesIds = new Set<String>();
        for (Therapeutic_Area_Assignment__c assignment : assignments) {
            resourcesIds.add('\'' + assignment.Resource__c + '\'');
        }
        return this.getResources(resourcesIds, participant);
    }

    @TestVisible
    private List<Resource__c> getStudySpecificResources(Participant__c participant, String resourceType) {

        Clinical_Trial_Profile__c trial = ParticipantService.getParticipantState().ctp;
        if (trial == null) {
            throw new CommunityServiceException(CommunityService.ERROR_MISSING_STUDY);
        }
        return this.getResources(this.getRelatedToStudyResourcesIds(trial.Id, resourceType), participant);
    }

    @TestVisible
    private Set<String> getRelatedToStudyResourcesIds(String studyId, String resourceType) {

        String resStudyQuery = 'SELECT Id, ' +
                'Resource__c ' +
                'FROM Res_study__c ' +
                'WHERE Clinical_Trial_Profile__c = \'' + studyId + '\' ' +
                'AND Resource__r.RecordType.DeveloperName = \'' + resourceType + '\'';
        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        List<Res_study__c> studyToResourceJunctions = (List<Res_study__c>) databaseProxy.query(resStudyQuery);
        Set<String> resourcesIds = new Set<String>();
        for (Res_study__c junction : studyToResourceJunctions) {
            resourcesIds.add('\'' + junction.Resource__c + '\'');
        }
        return resourcesIds;
    }

    @TestVisible
    private List<Resource__c> getSortedResources(Participant__c participant, String resourceType) {

        ParticipantService pService = (ParticipantService) ClassFactory.newInstance(ParticipantService.class);
        ParticipantService.ParticipantState pState = pService.getState();
        List<Resource__c> resources = new List<Resource__c>();
        String studyTherapeuticAreaId;
        List<Therapeutic_Area_Patient__c> therapeuticAreaPatients = new List<Therapeutic_Area_Patient__c>();
        for (Therapeutic_Area_Patient__c therapeuticAreaPatient : ParticipantDecoupler.getTherapeuticAreaPatients(participant)) {
            if (therapeuticAreaPatient.IsRelatedToStudy__c) {
                studyTherapeuticAreaId = therapeuticAreaPatient.Therapeutic_Area__c;
            }
            therapeuticAreaPatients.add(therapeuticAreaPatient);
        }
        if (!String.isBlank(studyTherapeuticAreaId) && pState.value != ParticipantService.ParticipantStates.ALUMNI) {
            resources.addAll(this.getStudySpecificResources(participant, resourceType));
        }
        for (Therapeutic_Area_Patient__c therapeuticAreaPatient : therapeuticAreaPatients) {
            resources.addAll(this.getResources(participant, therapeuticAreaPatient.Therapeutic_Area__c, resourceType, ResourceService.RESOURCE_SOURCE_PLATFORM));
        }
        if (String.isBlank(studyTherapeuticAreaId) || pState.value == ParticipantService.ParticipantStates.ALUMNI) {
            for (Therapeutic_Area_Patient__c therapeuticAreaPatient : therapeuticAreaPatients) {
                resources.addAll(this.getResources(participant, therapeuticAreaPatient.Therapeutic_Area__c, resourceType, ResourceService.RESOURCE_SOURCE_THIRD_PARTY));
            }
        }
        return resources;
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

    @TestVisible
    private Participant__c getParticipant(String resourceType) {
        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        CommunityService cService = (CommunityService) ClassFactory.newInstance(CommunityService.class);
        String participantId = cService.getParticipantId();
        String participantQuery =
                'SELECT Id, ' +
                        'Contact__r.Language__c, ' +
                        'Conditions__c, ' +
                        '(SELECT Id, Therapeutic_Area__c, IsRelatedToStudy__c, Condition_Of_Interest_Order__c FROM Therapeutic_Area_Patients__r ORDER BY Condition_Of_Interest_Order__c), ' +
                        '(SELECT Id, Resource__c FROM Resource_Actions__r WHERE IsFavorite__c = true' + ' AND Resource__r.RecordType.DeveloperName = \'' + resourceType + '\') ' +
                        'FROM Participant__c ' +
                        'WHERE Id = \'' + participantId + '\'';
        return ((List<Participant__c>) databaseProxy.query(participantQuery))[0];
    }

    @TestVisible
    private String getParticipantLanguage(Participant__c participant) {
        return (String.isBlank(participant.Contact__r.Language__c) ? ResourceService.DEFAULT_LANGUAGE : participant.Contact__r.Language__c);
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
            if ((RESOURCE_SOURCE_THIRD_PARTY.equalsIgnoreCase(resource.Content_Class__c) && X_3PARTY_HEALTH_DAY.equalsIgnoreCase(resource.X3rd_Party_Source__c)) && !String.isBlank(resource.article_external_link__c)) {
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