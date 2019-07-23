public virtual inherited sharing class ResourceBasicService {

    protected ResourceService rService;
    protected String resourceType;
    protected String contentClass;
    protected Set<String> resourcesIds;
    protected Participant__c participant;
    protected ParticipantService.ParticipantState pState;
    protected List<Resource__c> resources;
    protected ResourceService.ResourceWrapperContainer wrapperContainer;
    protected String therapeuticAreaId;
    protected String resourceId;

    {
        this.resourcesIds = new Set<String>();
        this.resources = new List<Resource__c>();
    }

    public ResourceBasicService() {
    }

    public ResourceBasicService init(ResourceService rService) {
        return this.init(rService, null, null, null);
    }

    public ResourceBasicService init(ResourceService rService, String resourceId) {
        return this.init(rService, resourceId, null, null);
    }

    public ResourceBasicService init(ResourceService rService, String resourceId, String contentClass) {
        return this.init(rService, resourceId, contentClass, null);
    }

    public ResourceBasicService init(ResourceService rService, String resourceId, String contentClass, String therapeuticAreaId) {
        this.rService = (rService == null ? (ResourceService) ClassFactory.newInstance(ResourceService.class) : rService);
        this.resourceId = resourceId;
        this.contentClass = contentClass;
        this.therapeuticAreaId = therapeuticAreaId;
        this.resourceType = rService.getResourceType();
        this.participant = rService.getParticipant();
        this.pState = rService.getParticipantState();
        this.initResourceWrapperContainer();
        return this;
    }

    public ResourceService.ResourceWrapperContainer getResourceWrapperContainer() {
        return this.wrapperContainer;
    }

    public List<Resource__c> getResources() {
        return resources;
    }

    protected virtual List<Resource__c> getListOfResources() {
        String whereClause = this.getWhereClause();
        String orderByClause = this.getOrderByClause();
        return rService.getResources(this.participant, whereClause, orderByClause);
    }

    protected virtual void initResourceWrapperContainer() {
        this.wrapperContainer = isObjectsToFilterMissing()
                ? this.getErrorNoObjectsToFilter()
                :(this.initResourcesIds() && this.initResources())
                        ? rService.getResourceWrapperContainer(this.resources)
                        : this.getErrorNoResources();
    }

    protected virtual Boolean initResources() {
        this.resources = this.getListOfResources();
        return !(this.resources == null || this.resources.isEmpty());
    }

    protected virtual Boolean initResourcesIds() {
        return false;
    }

    protected virtual String getWhereClause() {
        return 'WHERE Id IN (' + CollectionUtil.joinByComa(CollectionUtil.wrapInApostrophes(this.resourcesIds)) + ') AND Language__c = \'' + rService.getParticipantLanguage() + '\' ';
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