public virtual inherited sharing class ResourceArticleVideoService extends ResourceBasicService {

    protected override virtual List<Resource__c> getListOfResources() {

        List<Resource__c> sortedResources = new List<Resource__c>();
        if (this.pState.value == ParticipantService.ParticipantStates.REFERRAL || this.pState.value == ParticipantService.ParticipantStates.PARTICIPANT) {
            sortedResources.addAll(((ResourceStudyRelatedService) ClassFactory.newInstance(ResourceStudyRelatedService.class))
                    .init(this.rService, this.resourceId, ResourceService.RESOURCE_SOURCE_STUDY)
                    .getResources());
        }
        for (Therapeutic_Area_Patient__c singleTAP : ParticipantDecoupler.getTherapeuticAreaPatients(this.participant)) {
            sortedResources.addAll(((ResourceTARelatedService) ClassFactory.newInstance(ResourceTARelatedService.class))
                    .init(
                            this.rService,
                            this.resourceId,
                            (this.pState.value == ParticipantService.ParticipantStates.ALUMNI ? ResourceService.RESOURCE_SOURCE_THIRD_PARTY : ResourceService.RESOURCE_SOURCE_PLATFORM),
                            singleTAP.Therapeutic_Area__c
                    )
                    .getResources());
        }
        return sortedResources;
    }

    protected override Boolean initResourcesIds() {
        return true;
    }

    protected override virtual ResourceService.ResourceWrapperContainer getErrorNoResources() {
        return this.resourceType == ResourceService.RESOURCE_TYPE_ARTICLE ? ResourceService.getErrorNoArticles(false) : ResourceService.getErrorNoVideos(false);
    }

    protected override virtual Boolean isObjectsToFilterMissing() {
        return ParticipantDecoupler.getTherapeuticAreaPatients(this.participant).isEmpty() && this.pState.ctp == null;
    }
}