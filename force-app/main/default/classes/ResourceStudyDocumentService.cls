public inherited sharing class ResourceStudyDocumentService extends ResourceStudyRelatedService {

    protected override String getOrderByClause() {
        return 'ORDER BY Version_Date__c DESC NULLS LAST';
    }

    protected override ResourceService.ResourceWrapperContainer getErrorNoResources() {
        return ResourceService.getErrorNoStudyDocuments();
    }
}