/**
 * Created by Dmytro Pokutnii
 */
public inherited sharing class ResourceDelegate {

    public ResourceService.ResourceWrapperContainer getResources(String resourceType) {

        ResourceService service = (ResourceService) ClassFactory.newInstance(ResourceService.class);
        service.setResourceType(resourceType);
        return ((ResourceArticleVideoService) ClassFactory.newInstance(ResourceArticleVideoService.class))
                .init(service)
                .getResourceWrapperContainer();
    }

    public ResourceService.ResourceWrapperContainer getFavoriteResources(String resourceType) {

        ResourceService service = (ResourceService) ClassFactory.newInstance(ResourceService.class);
        service.setResourceType(resourceType);
        return ((ResourceFavoriteService) ClassFactory.newInstance(ResourceFavoriteService.class))
                .init(service)
                .getResourceWrapperContainer();
    }

    public ResourceService.ResourceWrapperContainer getStudyDocuments() {

        ResourceService service = (ResourceService) ClassFactory.newInstance(ResourceService.class);
        service.setResourceType(ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT);
        return ((ResourceStudyDocumentService) ClassFactory.newInstance(ResourceStudyDocumentService.class))
                .init(service)
                .getResourceWrapperContainer();
    }

    public ResourceService.ResourceWrapperContainer getResourcesById(String resourceId, String resourceType) {

        ResourceService service = (ResourceService) ClassFactory.newInstance(ResourceService.class);
        service.setResourceType(resourceType);
        List<Resource__c> resources = new List<Resource__c>();

        if (ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT.containsIgnoreCase(resourceType)) {
            resources.addAll(((ResourceStudyDocumentService) ClassFactory.newInstance(ResourceStudyDocumentService.class))
                    .init(service, resourceId)
                    .getResources());
        } else {
            resources.addAll(((ResourceArticleVideoService) ClassFactory.newInstance(ResourceArticleVideoService.class))
                    .init(service, resourceId)
                    .getResources());
        }
        return resources.isEmpty()
                ? new ResourceService.ResourceWrapperContainer(Label.Resources_Not_Access_In_Resource)
                : new ResourceService.ResourceWrapperContainer((List<ResourceService.ResourceWrapper>) new List<ResourceService.ResourceDetailWrapper>{
                        new ResourceService.ResourceDetailWrapper(resources[0])
                });
    }

    public void deleteRelatedToStudyDocuments(List<Clinical_Trial_Profile__c> trialProfiles) {

        Set<Id> resourcesForDelete = new Set<Id>();
        List<Res_study__c> relatedResStudies = [
                SELECT Resource__r.Name,
                        Resource__r.Title__c
                FROM Res_study__c
                WHERE (Clinical_Trial_Profile__c
                        IN:trialProfiles) AND Resource__r.RecordType.DeveloperName = :ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT
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
}