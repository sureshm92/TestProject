public inherited sharing class ResourceTARelatedService extends ResourceService {

    public static ResourceTARelatedService getInstance(){
        return (ResourceTARelatedService) ClassFactory.newInstance(ResourceTARelatedService.class);
    }
    
    protected override List<Id> getResourcesIds() {
        String therapeuticAreaAssignmentsQuery =
                'SELECT Id, ' +
                        'Resource__c ' +
                        'FROM Therapeutic_Area_Assignment__c ' +
                        'WHERE Therapeutic_Area__c = \'' + therapeuticAreaId + '\' ' +
                        (contentClass == null ? '' : ('AND Resource__r.Content_Class__c = \'' + contentClass + '\' ')) +
                        (resourceId == null ? '' : ('AND Resource__c = \'' + resourceId + '\' ')) +
                        'AND Resource__r.RecordType.DeveloperName = \'' + resourceType + '\' ' +
                        'AND Resource__r.Language__c = \'' + getParticipantLanguage() + '\' ';
        List<Therapeutic_Area_Assignment__c> assignments = (List<Therapeutic_Area_Assignment__c>) ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class))
                .query(therapeuticAreaAssignmentsQuery, true);
        List<Id> resourcesIds = new List<Id>();
        for (Therapeutic_Area_Assignment__c assignment : assignments) {
            resourcesIds.add(assignment.Resource__c);
        }
        return resourcesIds;
    }

    protected override ResourceService.ResourceWrapperContainer getErrorNoObjectsToFilter() {
        return ResourceService.getErrorUnhandled();
    }

    protected override Boolean isObjectsToFilterMissing() {
        return this.therapeuticAreaId == null;
    }
}