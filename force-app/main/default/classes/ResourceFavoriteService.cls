public inherited sharing class ResourceFavoriteService extends ResourceArticleVideoService {

    protected override List<Resource__c> getListOfResources() {
        this.resources = super.getListOfResources();
        List<Resource__c> filteredResources = new List<Resource__c>();
        for(Resource__c singleResource : this.resources) {
            if(!ResourceDecoupler.getResourceActions(singleResource).isEmpty() && ResourceDecoupler.getResourceActions(singleResource)[0].IsFavorite__c) {
                filteredResources.add(singleResource);
            }
        }
        return filteredResources;
    }

    protected override ResourceService.ResourceWrapperContainer getErrorNoResources() {
        return this.resourceType == ResourceService.RESOURCE_TYPE_ARTICLE ? ResourceService.getErrorNoArticles(true) : ResourceService.getErrorNoVideos(true);
    }

    protected override Boolean isObjectsToFilterMissing() {
        return ParticipantDecoupler.getResourceActions(this.participant).isEmpty();
    }
}