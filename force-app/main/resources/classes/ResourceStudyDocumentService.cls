public virtual inherited sharing class ResourceStudyDocumentService extends ResourceStudyRelatedService {

    public static ResourceStudyDocumentService getInstance(){
        return (ResourceStudyDocumentService) ClassFactory.newInstance(ResourceStudyDocumentService.class);
    }
    
    protected override String getOrderByClause() {
        return 'ORDER BY Version_Date__c DESC NULLS LAST';
    }

    protected override ResourceService.ResourceWrapperContainer getErrorNoResources() {
        return ResourceService.getErrorNoStudyDocuments();
    }
}