public virtual inherited sharing class ResourceArticleVideoService extends ResourceBasicService {

    public static ResourceArticleVideoService getInstance(){
        return (ResourceArticleVideoService) ClassFactory.newInstance(ResourceArticleVideoService.class);
    }
    
    public override virtual List<Resource__c> getResources() {
        List<Resource__c> sortedResources = new List<Resource__c>();
        if (pState.value == ParticipantService.ParticipantStates.REFERRAL || pState.value == ParticipantService.ParticipantStates.PARTICIPANT) {
            sortedResources.addAll(ResourceStudyRelatedService.getInstance()
                    .init(rService, resourceId, ResourceService.RESOURCE_SOURCE_STUDY)
                    .getResources());
        }
        String contentClass = ResourceService.RESOURCE_SOURCE_PLATFORM;
        if( pState.value == ParticipantService.ParticipantStates.ALUMNI) contentClass = ResourceService.RESOURCE_SOURCE_THIRD_PARTY;
        for (Therapeutic_Area_Patient__c singleTAP : ParticipantDecoupler.getTherapeuticAreaPatients(rService.getParticipant())) {
            sortedResources.addAll(ResourceTARelatedService.getInstance()
                    .init(
                            rService,
                            resourceId,
                            contentClass,
                            singleTAP.Therapeutic_Area__c
                    )
                    .getResources());
        }
        return sortedResources;
    }
    
    protected override virtual ResourceService.ResourceWrapperContainer getErrorNoResources() {
        return rService.getResourceType() == ResourceService.RESOURCE_TYPE_ARTICLE ?
                ResourceService.getErrorNoArticles(false) : ResourceService.getErrorNoVideos(false);
    }

    protected override virtual Boolean isObjectsToFilterMissing() {
        return ParticipantDecoupler.getTherapeuticAreaPatients(rService.getParticipant()).isEmpty() && this.pState.ctp == null;
    }
}