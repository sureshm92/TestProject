public inherited sharing class ResourceFavoriteService extends ResourceArticleVideoService {

    public static ResourceFavoriteService getInstance(){
        return (ResourceFavoriteService) ClassFactory.newInstance(ResourceFavoriteService.class);
    }
    
    public override List<Resource__c> getResources() {
        //Filter only favorite resources
        List<Resource__c> resources = super.getResources();
        List<Resource__c> filteredResources = new List<Resource__c>();
        for(Resource__c singleResource : resources) {
            if(!ResourceDecoupler.getResourceActions(singleResource).isEmpty() && ResourceDecoupler.getResourceActions(singleResource)[0].IsFavorite__c) {
                filteredResources.add(singleResource);
            }
        }
        return filteredResources;
    }

    protected override ResourceService.ResourceWrapperContainer getErrorNoResources() {
        return resourceType == ResourceService.RESOURCE_TYPE_ARTICLE ? ResourceService.getErrorNoArticles(true) : ResourceService.getErrorNoVideos(true);
    }

}