public with sharing class ContentDocumentLinkService {

    public List<ContentDocumentLink> getContentDocumentLinksByResourcesIds(Set<String> resourcesIdsSet) {

        if (resourcesIdsSet.isEmpty()) {
            return new List<ContentDocumentLink>();
        }
        List<String> resourcesIds = new List<String>();
        for (String resourceId : resourcesIdsSet) {
            resourcesIds.add('\'' + resourceId + '\'');
        }
        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        String documentLinksQuery =
                'SELECT ContentDocument.LatestPublishedVersion.Title, ' +
                        'ContentDocument.LatestPublishedVersion.VersionData ' +
                        'FROM ContentDocumentLink ' +
                        'WHERE LinkedEntityId IN (' + String.join(resourcesIds, ', ') + ') ' +
                        'ORDER BY ContentDocument.CreatedDate DESC';
        return (List<ContentDocumentLink>) databaseProxy.query(documentLinksQuery);
    }

    public void extendSharingToAllUsers(List<ContentDocumentLink> links) {

        for (ContentDocumentLink singleLink : links) {
            if (singleLink.LinkedEntityId.getSobjectType() == Resource__c.getSObjectType() &&
                    SchemaUtil.getRecordTypeDeveloperNameBySObjectId(singleLink.LinkedEntityId) == ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT) {
                singleLink.ShareType = 'I';
                singleLink.Visibility = 'AllUsers';
            }
        }
    }
}