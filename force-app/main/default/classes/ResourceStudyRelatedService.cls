public virtual inherited sharing class ResourceStudyRelatedService extends ResourceBasicService {
    
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
    
    protected override Boolean initResourcesIds() {
        //Create filter for query:
        String filter = DatabaseService.fieldEqual('Resource__r.RecordType.DeveloperName', resourceType);
        if(contentClass != null) filter += ' AND ' + DatabaseService.fieldEqual('Resource__r.Content_Class__c', contentClass);
        if(resourceId != null) {
            filter += ' AND ' + DatabaseService.fieldEqual('Resource__c', resourceId);
        }else{
            filter += ' AND ' + DatabaseService.fieldEqual('Clinical_Trial_Profile__c', pState.ctp.Id);
        }
        //Get Res Study records and filters result resource Ids
        List<Res_study__c> resStudies = (List<Res_study__c>) DatabaseService.query(RES_STUDY_FIELDS, Res_study__c.getSObjectType(), filter);
        for (Res_study__c resStudy : resStudies) {
            if(StudyResourceVisibilityService.isResourceVisibleForPE(resStudy, pState.pe, pState.isDelegate)) this.resourcesIds.add(resStudy.Resource__c);
        }
        return !(this.resourcesIds == null || this.resourcesIds.isEmpty());
    }
    
    protected override ResourceService.ResourceWrapperContainer getErrorNoObjectsToFilter() {
        return ResourceService.getErrorMissingStudy();
    }
    
    protected override Boolean isObjectsToFilterMissing() {
        return (this.pState.ctp == null || this.pState.value == ParticipantService.ParticipantStates.ALUMNI);
    }
}