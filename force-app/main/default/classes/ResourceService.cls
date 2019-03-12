public with sharing class ResourceService {

    private static String DEFAULT_LANGUAGE = 'en_US';

    public ResourceWrapperContainer getResources(String resourceType) {

        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        String participantId = CommunityService.getParticipantId();
        String participantQuery =
                'SELECT Id, ' +
                        'Contact__r.Language__c, ' +
                        '(SELECT Id, Therapeutic_Area__c, IsRelatedToStudy__c FROM Therapeutic_Area_Patients__r) ' +
                        'FROM Participant__c ' +
                        'WHERE Id = \'' + participantId + '\'';
        Participant__c participant = ((List<Participant__c>) databaseProxy.query(participantQuery))[0];

//		if (participant.Therapeutic_Area_Patients__r.isEmpty()) {
//			throw new AuraHandledException('Therapeutic Area is not defined');
//		}

        //todo add a logic to filter resources by TA and COI
        List<String> resourcesIds = new List<String>();
        List<Resource__c> resources = [SELECT Id FROM Resource__c WHERE RecordType.DeveloperName = :resourceType];
        for (Resource__c singleResource : resources) {
            resourcesIds.add('\'' + singleResource.Id + '\'');
        }
        resources = this.getResources(resourcesIds, this.getParticipantLanguage(participant), participant.Id);
        if (resources.isEmpty()) {
            return new ResourceWrapperContainer(('Article'.equalsIgnoreCase(resourceType)) ? Label.Resources_No_Articles : Label.Resources_No_Videos);
        }
        return new ResourceWrapperContainer(this.getResourceWrappers(resources));
    }

    public ResourceWrapperContainer getFavoriteResources(String resourceType) {

        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        String participantId = CommunityService.getParticipantId();
        String participantQuery =
                'SELECT Id, ' +
                        'Contact__r.Language__c, ' +
                        '(SELECT Id, Resource__c FROM Resource_Actions__r WHERE IsFavorite__c = true' + ' AND Resource__r.RecordType.DeveloperName = \'' + resourceType + '\')' +
                        'FROM Participant__c ' +
                        'WHERE Id = \'' + participantId + '\'';
        Participant__c participant = ((List<Participant__c>) databaseProxy.query(participantQuery))[0];

        List<String> resourcesIds = new List<String>();
        if (participant.Resource_Actions__r.isEmpty()) {
            return new ResourceWrapperContainer(('Article'.equalsIgnoreCase(resourceType)) ? Label.Resources_No_Favorite_Articles : Label.Resources_No_Favorite_Videos);
        }
        for (Resource_Action__c singleAction : participant.Resource_Actions__r) {
            resourcesIds.add('\'' + singleAction.Resource__c + '\'');
        }

        List<Resource__c> resources = this.getResources(resourcesIds, this.getParticipantLanguage(participant), participantId);
        if (resources.isEmpty()) {
            return new ResourceWrapperContainer(('Article'.equalsIgnoreCase(resourceType)) ? Label.Resources_No_Favorite_Articles : Label.Resources_No_Favorite_Videos);
        }

        return new ResourceWrapperContainer(this.getResourceWrappers(resources));
    }

    public List<ResourceService.ResourceWrapper> getResourcesById(String resourceId) {

        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        String participantId = CommunityService.getParticipantId();
        System.debug('participantId : ' + participantId);
        String participantQuery =
                'SELECT Id, ' +
                        'Contact__r.Language__c ' +
                        'FROM Participant__c ' +
                        'WHERE Id = \'' + participantId + '\'';
        System.debug(participantQuery);
        Participant__c participant = ((List<Participant__c>) databaseProxy.query(participantQuery))[0];
        System.debug('Participant: ' + participant);
        List<String> resourcesIds = new List<String>{
                '\'' + resourceId + '\''
        };

        return this.getResourceWrappers(this.getResources(resourcesIds, this.getParticipantLanguage(participant), participantId));
    }

    private List<Resource__c> getResources(List<String> resourcesIds, String language, String participantId) {

        if (resourcesIds.isEmpty()) {
            return new List<Resource__c>();
        }
        String resourcesQuery =
                'SELECT Id, ' +
                        '(SELECT Id, ' +
                        'Subject__c, ' +
                        'Description__c, ' +
                        'Resource__r.Expiration_Date__c, ' +
                        'Resource__r.Image__c, ' +
                        'Resource__r.Video__c, ' +
                        'Content_Text__c, ' +
                        'Resource__r.RecordType.DeveloperName ' +
                        'FROM Resource_Versions__r ' +
                        'WHERE Language__c = \'' + language + '\'), ' +
                        '(SELECT Id, IsFavorite__c, IsVoted__c FROM Resource_Actions__r WHERE Participant__c = \'' + participantId + '\') ' +
                        'FROM Resource__c ' +
                        'WHERE Id IN (' + String.join(resourcesIds, ', ') + ') ' +
                        'ORDER BY Published_Date__c';
        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        return (List<Resource__c>) databaseProxy.query(resourcesQuery);
    }

//	public List<ResourceService.ResourceWrapper> getStudySpecificResources(String resourceType, Participant__c participant) {
//
//		String language = participant.Contact__r.Language__c;
//		if (String.isBlank(language)) {
//			language = ResourceService.DEFAULT_LANGUAGE;
//		}
//
//		List<String> therapeuticAreasIds = new List<String>();
//		for (Therapeutic_Area_Patient__c therapeuticAreaPatient : participant.Therapeutic_Area_Patients__r) {
//			therapeuticAreasIds.add(therapeuticAreaPatient.Therapeutic_Area__c);
//		}
//
//		DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
//		String therapeuticAreaAssignmentsQuery =
//				'SELECT Id, ' +
//						'Resource__c ' +
//						'FROM Therapeutic_Area_Assignment__c ' +
//				'WHERE Therapeutic_Area__c = IN (' + String.join(therapeuticAreasIds, ', ') + ') AND Resource__c.RecordType.DeveloperName = \'' + resourceType + '\'';
//
//		List<String> resourcesIds = new List<String>();
//		List<Therapeutic_Area_Assignment__c> assignments = (List<Therapeutic_Area_Assignment__c>) databaseProxy.query(therapeuticAreaAssignmentsQuery);
//		for (Therapeutic_Area_Assignment__c assignment : assignments) {
//			resourcesIds.add(assignment.Resource__c);
//		}
//		if (resourcesIds.isEmpty()) {
//			throw new AuraHandledException('There is no resources for this Therapeutic Area');
//		}
//		String resourcesQuery =
//				'SELECT Id, ' +
//						'(SELECT Id, Subject__c, Description__c, Body__c, Resource__r.Expiration_Date__c, Resource__r.Video__c FROM Resource_Versions__r WHERE Language__c = ' + language + '), ' +
//						'(SELECT Id, IsFavorite__c, IsVoted__c FROM Resource_Actions__r WHERE Participant__c = ' + participant.Id + ')' +
//						'FROM Resource__c ' +
//						'WHERE Id IN (' + String.join(resourcesIds, ', ') + ') ' +
//						'ORDER BY Publish_Date__c';
//		List<Resource__c> resources = (List<Resource__c>) databaseProxy.query(resourcesQuery);
//		return this.getResourceWrappers(resources);
//	}
//
//	public List<ResourceService.ResourceWrapper> getPlatformSpecificResources(String resourceType, Participant__c participant) {
//
//		List<ResourceService.ResourceWrapper> wrappers = this.getStudySpecificResources(resourceType, participant);
//		return null;
//		//return ResourceService.orderResourcesByTherapeuticArea(wrappers, participant.Therapeutic_Area_Patients__r);
//	}

    private List<ResourceService.ResourceWrapper> getResourceWrappers(List<Resource__c> resources) {
        List<ResourceService.ResourceWrapper> wrappers = new List<ResourceService.ResourceWrapper>();
        for (Resource__c singleResource : resources) {
            if (singleResource.Resource_Versions__r.isEmpty()) {
                continue;
            }
            ResourceService.ResourceWrapper singleWrapper = new ResourceService.ResourceWrapper(singleResource);
            wrappers.add(singleWrapper);
        }

        return wrappers;
    }

    private String getParticipantLanguage(Participant__c participant) {
        String language = participant.Contact__r.Language__c;
        if (String.isBlank(language)) {
            language = ResourceService.DEFAULT_LANGUAGE;
        }
        return language;
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
        public String resourceId;
        @AuraEnabled
        public Boolean isFavorite = false;
        @AuraEnabled
        public Boolean isVoted = false;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public String body;
        @AuraEnabled
        public String image;
        @AuraEnabled
        public Date expirationDate;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String video;

        public ResourceWrapper(Resource__c resource) {
            if (!resource.Resource_Actions__r.isEmpty()) {
                isFavorite = resource.Resource_Actions__r[0].IsFavorite__c;
                isVoted = resource.Resource_Actions__r[0].IsVoted__c;
            }
            Resource_Version__c version = resource.Resource_Versions__r[0];
            title = (version.Subject__c.length() > 55) ? version.Subject__c.substring(0, 52) + '...' : version.Subject__c;
            description = (version.Description__c.length() > 120) ? version.Description__c.substring(0, 117) + '...' : version.Description__c;
            image = version.Resource__r.Image__c;
            expirationDate = version.Resource__r.Expiration_Date__c;
            type = version.Resource__r.RecordType.DeveloperName;
            resourceId = version.Resource__c;
            video = version.Resource__r.Video__c;
            body = version.Content_Text__c;
        }
    }
}