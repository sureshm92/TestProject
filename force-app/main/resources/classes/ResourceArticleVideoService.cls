public virtual inherited sharing class ResourceArticleVideoService extends ResourceService {
    private static ResourceArticleVideoService instance;

    public static ResourceArticleVideoService getInstance() {
        if (instance == null)
            instance = new ResourceArticleVideoService();
        return instance;
    }

    public override virtual List<Resource__c> getResources() {
        List<Resource__c> sortedResources = new List<Resource__c>();
        if (
            pState.value == ParticipantService.ParticipantStates.REFERRAL ||
            pState.value == ParticipantService.ParticipantStates.PARTICIPANT
        ) {
            sortedResources.addAll(
                ResourceStudyRelatedService.getInstance()
                    .init(resourceType, resourceId, ResourceService.RESOURCE_SOURCE_STUDY)
                    .getResources()
            );
        }
        String contentClass = ResourceService.RESOURCE_SOURCE_PLATFORM;
        if (pState.value == ParticipantService.ParticipantStates.ALUMNI)
            contentClass = ResourceService.RESOURCE_SOURCE_THIRD_PARTY;

        if (pState.value == ParticipantService.ParticipantStates.ALUMNI) {
            List<String> therapeuticAreas = new List<String>();
            for (
                Therapeutic_Area_Patient__c tap : ParticipantDecoupler.getTherapeuticAreaPatients()
            ) {
                therapeuticAreas.add(tap.Therapeutic_Area__c);
            }
            sortedResources.addAll(
                ResourceTARelatedService.getInstance()
                    .init(resourceType, resourceId, contentClass, therapeuticAreas)
                    .getResources()
            );
        }
        return sortedResources;
    }

    protected override virtual ResourceService.ResourceWrapperContainer getErrorNoResources() {
        return resourceType == ResourceService.RESOURCE_TYPE_ARTICLE
            ? ResourceService.getErrorNoArticles(false)
            : ResourceService.getErrorNoVideos(false);
    }

    protected override virtual Boolean isObjectsToFilterMissing() {
        return ParticipantDecoupler.getTherapeuticAreaPatients().isEmpty() && pState.ctp == null;
    }
}
