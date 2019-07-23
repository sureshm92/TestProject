public inherited sharing class ResourceTARelatedService extends ResourceBasicService {

    protected override Boolean initResourcesIds() {

        String therapeuticAreaAssignmentsQuery =
                'SELECT Id, ' +
                        'Resource__c ' +
                        'FROM Therapeutic_Area_Assignment__c ' +
                        'WHERE Therapeutic_Area__c = \'' + therapeuticAreaId + '\' ' +
                        (this.contentClass == null ? '' : ('AND Resource__r.Content_Class__c = \'' + this.contentClass + '\' ')) +
                        (this.resourceId == null ? '' : ('AND Resource__c = \'' + this.resourceId + '\' ')) +
                        'AND Resource__r.RecordType.DeveloperName = \'' + this.resourceType + '\' ' +
                        'AND Resource__r.Language__c = \'' + rService.getParticipantLanguage() + '\' ';
        List<Therapeutic_Area_Assignment__c> assignments = (List<Therapeutic_Area_Assignment__c>) ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class))
                .query(therapeuticAreaAssignmentsQuery);
        for (Therapeutic_Area_Assignment__c assignment : assignments) {
            this.resourcesIds.add(assignment.Resource__c);
        }
        return !(this.resourcesIds == null || this.resourcesIds.isEmpty());
    }

    protected override ResourceService.ResourceWrapperContainer getErrorNoObjectsToFilter() {
        return ResourceService.getErrorUnhandled();
    }

    protected override Boolean isObjectsToFilterMissing() {
        return this.therapeuticAreaId == null;
    }
}