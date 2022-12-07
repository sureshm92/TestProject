public virtual inherited sharing class ResourceStudyDocumentService extends ResourceStudyRelatedService {
    public static ResourceStudyDocumentService getInstance() {
        return (ResourceStudyDocumentService) ClassFactory.newInstance(
            ResourceStudyDocumentService.class
        );
    }

    @TestVisible
    protected override String getOrderByClause() {
        if (Site.getMasterLabel() == 'IQVIA Patient Portal') {
            return 'ORDER BY CreatedDate DESC NULLS LAST';
        } else {
            return 'ORDER BY Version_Date__c DESC NULLS LAST';
        }
    }

    @TestVisible
    protected override ResourceService.ResourceWrapperContainer getErrorNoResources() {
        return ResourceService.getErrorNoStudyDocuments();
    }
}