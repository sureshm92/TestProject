public virtual inherited sharing class ResourceBasicService {

    protected ResourceService rService;
    protected String contentClass;
    protected ParticipantService.ParticipantState pState;
    protected String therapeuticAreaId;
    protected String resourceId;

    public ResourceBasicService init(ResourceService rService) {
        return this.init(rService, null, null, null);
    }

    public ResourceBasicService init(ResourceService rService, String resourceId) {
        System.debug('>>> 3');
        return this.init(rService, resourceId, null, null);
    }

    public ResourceBasicService init(ResourceService rService, String resourceId, String contentClass) {
        return this.init(rService, resourceId, contentClass, null);
    }

    public ResourceBasicService init(ResourceService rService, String resourceId, String contentClass, String therapeuticAreaId) {
        this.rService = (rService == null ? ResourceService.getInstance() : rService);
        this.resourceId = resourceId;
        this.contentClass = contentClass;
        this.therapeuticAreaId = therapeuticAreaId;
        this.pState = rService.getParticipantState();
        return this;
    }

    public ResourceService.ResourceWrapperContainer getResourceWrapperContainer() {
        if(isObjectsToFilterMissing()){
            return getErrorNoObjectsToFilter();
        }else{
            List<Resource__c> resources = getResources();
            if(resources.size() > 0){
                return rService.getResourceWrapperContainer(getResources());
            }else{
                return getErrorNoResources();
            }
        }
    }

    public virtual List<Resource__c> getResources() {
        List<Resource__c> resources = new List<Resource__c>();
        if(isObjectsToFilterMissing()) return resources;
        List<Id> resourcesIds = getResourcesIds();
        if(resourcesIds.size() > 0) {
            String whereClause = 'WHERE Id IN (' + CollectionUtil.joinByComa(CollectionUtil.wrapInApostrophes(resourcesIds)) + ')';
            resources = rService.getResources(rService.getParticipant(), whereClause, getOrderByClause());
        }
        return resources;
    }

    protected virtual List<Id> getResourcesIds() {
        return new List<Id>();
    }

    protected virtual String getOrderByClause() {
        return 'ORDER BY Posting_Date__c DESC NULLS LAST';
    }

    protected virtual ResourceService.ResourceWrapperContainer getErrorNoResources() {
        return new ResourceService.ResourceWrapperContainer('Unhandled Error.');
    }

    protected virtual ResourceService.ResourceWrapperContainer getErrorNoObjectsToFilter() {
        return this.getErrorNoResources();
    }

    protected virtual Boolean isObjectsToFilterMissing() {
        return true;
    }
}