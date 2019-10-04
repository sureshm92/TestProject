public virtual inherited sharing class ResourceStudyRelatedService extends ResourceService {
    
    private static final List<String> RES_STUDY_FIELDS = new List<String>{
            'Id',
            'Active_On_Status__c',
            'Expires_On_Status__c',
            'Active_After_Days__c',
            'Expires_After_Days__c',
            'Notify_On_Availability__c',
            'Visible_In_Alumni__c',
            'Visible_To_Delegates__c',
            'Visible_To_Participant__c',
            'Visible_To_PI__c',
            'Visible_To_RP__c',
            'Resource__c'
    };
    
    private Id ctpId;
    
    public static ResourceStudyRelatedService getInstance(){
        return (ResourceStudyRelatedService) ClassFactory.newInstance(ResourceStudyRelatedService.class);
    }
    
    public ResourceService init(String resourceType, String resourceId, String contentClass, Id ctpId) {
        this.init(resourceType, resourceId, contentClass);
        this.ctpId = ctpId;
        return this;
    }
    
    
    protected virtual override List<Id> getResourcesIds() {
        //Create filter for query:
        String filter = DatabaseService.fieldEqual('Resource__r.RecordType.DeveloperName', resourceType);
        if(contentClass != null) filter += ' AND ' + DatabaseService.fieldEqual('Resource__r.Content_Class__c', contentClass);
        if(resourceId != null) {
            filter += ' AND ' + DatabaseService.fieldEqual('Resource__c', resourceId);
        }else{
            filter += ' AND ' + DatabaseService.fieldEqual('Clinical_Trial_Profile__c', getCTPId());
        }
        //Get Res Study records and filters result resource Ids
        List<Id> resourcesIds = new List<Id>();
        List<Res_study__c> resStudies = (List<Res_study__c>) DatabaseService.query(RES_STUDY_FIELDS, Res_study__c.getSObjectType(), filter);
        for (Res_study__c resStudy : resStudies) {
            if(resourceId != null || StudyResourceVisibilityService.isResourceVisibleForPE(
                    resStudy, pState.pe, CommunityService.getContactUserMode(CommunityService.getUserContact().Id), pState.isDelegate))
            {
                resourcesIds.add(resStudy.Resource__c);
            }
        }
        return resourcesIds;
    }
    
    protected override ResourceService.ResourceWrapperContainer getErrorNoObjectsToFilter() {
        return ResourceService.getErrorMissingStudy();
    }
    
    protected override Boolean isObjectsToFilterMissing() {
        return (resourceId == null && pState.value == ParticipantService.ParticipantStates.ALUMNI);
    }
    
    protected Id getCTPId(){
        if(ctpId == null && pState.ctp != null)ctpId = pState.ctp.Id;
        return ctpId;
    }
}