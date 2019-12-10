public inherited sharing class ResourceContentClassService {

    public void deleteRelatedObjects(List<Resource__c> newList, Map<Id, Resource__c> oldMap) {

        Id studyDocumentRecordTypeId = SchemaUtil.getRecordTypeIdByName(ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT, Resource__c.getSObjectType());
        List<Resource__c> resourcesToProcess = new List<Resource__c>();
        for (Resource__c singleResource : newList) {
            if (singleResource.RecordTypeId != studyDocumentRecordTypeId && singleResource.Content_Class__c != oldMap.get(singleResource.Id).Content_Class__c) {
                resourcesToProcess.add(singleResource);
            }
        }
        if (!resourcesToProcess.isEmpty()) {
            this.deleteRelatedObjects(new Map<Id, Resource__c>(resourcesToProcess).keySet());
        }
    }

    private void deleteRelatedObjects(Set<Id> resourcesIds) {

        String resourcesQuery =
                'SELECT Id, ' +
                        '(SELECT Id FROM Therapeutic_Area_Assignments__r), ' +
                        '(SELECT Id FROM Study__r) ' +
                        'FROM Resource__c ' +
                        'WHERE Id IN (' + String.join(CollectionUtil.wrapInApostrophes(resourcesIds), ', ') + ')';
        List<Resource__c> resources = (List<Resource__c>) ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class)).query(resourcesQuery);
        List<SObject> objectsToDelete = new List<SObject>();
        for (Resource__c singleResource : resources) {
            objectsToDelete.addAll(singleResource.Therapeutic_Area_Assignments__r);
            objectsToDelete.addAll(singleResource.Study__r);
        }
        delete objectsToDelete;
    }
}