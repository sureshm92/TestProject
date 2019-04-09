/**
 * created by Dmytro Pokutnii
 */
public with sharing class ResourceService {

    public static final String RESOURCE_SOURCE_STUDY = 'Study-Specific';
    public static final String RESOURCE_SOURCE_PLATFORM = 'Platform-TA';
    public static final String RESOURCE_SOURCE_THIRD_PARTY = '3rd Party';
    @TestVisible
    private static String DEFAULT_LANGUAGE = 'en_US';
    @TestVisible
    private static String RESOURCE_TYPE_ARTICLE = 'Article';
    @TestVisible
    private static String RESOURCE_TYPE_VIDEO = 'Video';

    public ResourceWrapperContainer getResources(String resourceType) {

        Participant__c participant = this.getParticipant(resourceType);
        if (ParticipantDecoupler.getTherapeuticAreaPatients(participant).isEmpty()) {
            return new ResourceWrapperContainer(Label.Resources_No_Therapeutic_Area);
        }
        List<Resource__c> resources = this.getSortedResources(participant, resourceType);
        if (resources.isEmpty()) {
            return new ResourceWrapperContainer((ResourceService.RESOURCE_TYPE_ARTICLE.equalsIgnoreCase(resourceType)) ? Label.Resources_No_Articles : Label.Resources_No_Videos);
        }
        return new ResourceWrapperContainer(this.getResourceWrappers(resources));
    }

    public ResourceWrapperContainer getFavoriteResources(String resourceType) {

        Participant__c participant = this.getParticipant(resourceType);
        if (participant.Resource_Actions__r.isEmpty()) {
            return new ResourceWrapperContainer((ResourceService.RESOURCE_TYPE_ARTICLE.equalsIgnoreCase(resourceType)) ? Label.Resources_No_Favorite_Articles : Label.Resources_No_Favorite_Videos);
        }
        ResourceService.ResourceWrapperContainer container = this.getResources(resourceType);
        if (container.wrappers.isEmpty()) {
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

    public ResourceWrapperContainer getResourcesById(String resourceId, String resourceType) {

        Participant__c participant = this.getParticipant(resourceType);
        if (ParticipantDecoupler.getTherapeuticAreaPatients(participant).isEmpty()) {
            return new ResourceWrapperContainer(Label.Resources_No_Therapeutic_Area);
        }
        List<Resource__c> resources = this.getSortedResources(participant, resourceType);
        if (resources.isEmpty()) {
            return new ResourceWrapperContainer(Label.Resources_Not_Access_In_Resource);
        }
        Map<Id, Resource__c> resourceMap = new Map<Id, Resource__c>(resources);
        if (resourceMap.get(resourceId) != null) {
            return new ResourceWrapperContainer(this.getResourceWrappers(new List<Resource__c>{
                    resourceMap.get(resourceId)
            }));
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
        String orderByClause = 'ORDER BY Posting_Date__c NULLS LAST';
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
        if(trial == null) {
            throw new CommunityServiceException(CommunityService.ERROR_MISSING_STUDY);
        }
        String resStudyQuery = 'SELECT Id, ' +
                'Resource__c ' +
                'FROM Res_study__c ' +
                'WHERE Clinical_Trial_Profile__c = \'' + trial.Id + '\' ' +
                'AND Resource__r.RecordType.DeveloperName = \'' + resourceType + '\'';
        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        List<Res_study__c> studyToResourceJunctions = (List<Res_study__c>) databaseProxy.query(resStudyQuery);
        Set<String> resourcesIds = new Set<String>();
        for(Res_study__c junction : studyToResourceJunctions) {
            resourcesIds.add('\'' + junction.Resource__c + '\'');
        }
        return this.getResources(resourcesIds, participant);
    }

    @TestVisible
    private List<Resource__c> getSortedResources(Participant__c participant, String resourceType) {

        List<Resource__c> resources = new List<Resource__c>();
        String studyTherapeuticAreaId;
        List<Therapeutic_Area_Patient__c> therapeuticAreaPatients = new List<Therapeutic_Area_Patient__c>();
        for (Therapeutic_Area_Patient__c therapeuticAreaPatient : participant.Therapeutic_Area_Patients__r) {
            if (therapeuticAreaPatient.IsRelatedToStudy__c) {
                studyTherapeuticAreaId = therapeuticAreaPatient.Therapeutic_Area__c;
            }
            therapeuticAreaPatients.add(therapeuticAreaPatient);
        }
        if (!String.isBlank(studyTherapeuticAreaId)) {
            resources.addAll(this.getStudySpecificResources(participant, resourceType));
        }
        for (Therapeutic_Area_Patient__c therapeuticAreaPatient : therapeuticAreaPatients) {
            resources.addAll(this.getResources(participant, therapeuticAreaPatient.Therapeutic_Area__c, resourceType, ResourceService.RESOURCE_SOURCE_PLATFORM));
        }
        if (String.isBlank(studyTherapeuticAreaId)) {
            for (Therapeutic_Area_Patient__c therapeuticAreaPatient : therapeuticAreaPatients) {
                resources.addAll(this.getResources(participant, therapeuticAreaPatient.Therapeutic_Area__c, resourceType, ResourceService.RESOURCE_SOURCE_THIRD_PARTY));
            }
        }
        return resources;
    }

    @TestVisible
    private List<ResourceService.ResourceWrapper> getResourceWrappers(List<Resource__c> resources) {
        List<ResourceService.ResourceWrapper> wrappers = new List<ResourceService.ResourceWrapper>();
        for (Resource__c singleResource : resources) {
            ResourceService.ResourceWrapper singleWrapper = new ResourceService.ResourceWrapper(singleResource);
            wrappers.add(singleWrapper);
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

    public class ResourceWrapper {

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
}
