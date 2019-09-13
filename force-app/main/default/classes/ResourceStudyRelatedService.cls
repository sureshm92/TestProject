public virtual inherited sharing class ResourceStudyRelatedService extends ResourceBasicService {

    protected override Boolean initResourcesIds() {

        String resStudyQuery =
                'SELECT Id, ' +
                        'Active_After_Days__c,' +
                        'Active_On_Status__c,' +
                        'Expires_After_Days__c,' +
                        'Notify_On_Availability__c,' +
                        'Visible_In_Alumni__c,' +
                        'Visible_To_Participant__c,' +
                        'Visible_To_PI__c,' +
                        'Visible_To_RP__c,' +
                        'Resource__c ' +
                'FROM Res_study__c ' +
                'WHERE Clinical_Trial_Profile__c = \'' + pState.ctp.Id + '\' ' +
                'AND Resource__r.RecordType.DeveloperName = \'' + this.resourceType + '\' ' +
                (this.contentClass == null ? '' : ('AND Resource__r.Content_Class__c = \'' + this.contentClass + '\' ')) +
                (this.resourceId == null ? '' : ('AND Resource__c = \'' + this.resourceId + '\' ')) +
                'AND Resource__r.Language__c = \'' + rService.getParticipantLanguage() + '\' ';
        List<Res_study__c> resStudies = (List<Res_study__c>) ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class)).query(resStudyQuery, true);
        for (Res_study__c junction : resStudies) {
            if(StudyResourceVisibilityService.isResourceVisibleForPE(junction, pState.pe)) this.resourcesIds.add(junction.Resource__c);
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