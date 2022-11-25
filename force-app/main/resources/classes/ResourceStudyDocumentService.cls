public virtual inherited sharing class ResourceStudyDocumentService extends ResourceStudyRelatedService {
    public static ResourceStudyDocumentService getInstance() {
        return (ResourceStudyDocumentService) ClassFactory.newInstance(
            ResourceStudyDocumentService.class
        );
    }

    protected override String getOrderByClause() {
        Participant_Enrollment__c currentPE = ParticipantContext.getCurrentPE();
        if (currentPE != null && 
            currentPE.Clinical_Trial_Profile__r.CommunityTemplate__c ==
            CommunityTemplateService.TEMPLATE_PP
        ) {
            return 'ORDER BY CreatedDate DESC NULLS LAST';
        } else {
            return 'ORDER BY Version_Date__c DESC NULLS LAST';
        }
    }

    protected override ResourceService.ResourceWrapperContainer getErrorNoResources() {
        return ResourceService.getErrorNoStudyDocuments();
    }
}
