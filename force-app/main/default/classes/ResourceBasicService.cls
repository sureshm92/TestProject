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
        this.rService = (ResourceService) ClassFactory.newInstance(ResourceService.class);
        this.resourcesIds = new Set<String>();
        this.resources = new List<Resource__c>();
    }

    public ResourceBasicService() {
    }

    public ResourceBasicService init(String resourceType, Participant__c participant) {
        return this.init(resourceType, participant, null, null, null, null);
    }

    public ResourceBasicService init(String resourceType, String resourceId, Participant__c participant) {
        return this.init(resourceType, participant, null, null, null, resourceId);
    }

    public ResourceBasicService init (String resourceType, Participant__c participant, String contentClass) {
        return this.init(resourceType, participant, null, contentClass, null, null);
    }

    public ResourceBasicService init(String resourceType, Participant__c participant, ParticipantService.ParticipantState pState) {
        return this.init(resourceType, participant, pState, null, null, null);
    }

    public ResourceBasicService init(String resourceType, Participant__c participant, String contentClass, String therapeuticAreaId, String resourceId) {
        return this.init(resourceType, participant, null, contentClass, therapeuticAreaId, resourceId);
    }

    public ResourceBasicService init(String resourceType, Participant__c participant, ParticipantService.ParticipantState pState, String contentClass, String resourceId) {
        return this.init(resourceType, participant, pState, contentClass, null, resourceId);
    }

    public ResourceBasicService init(String resourceType, Participant__c participant, ParticipantService.ParticipantState pState, String contentClass, String therapeuticAreaId, String resourceId) {
        this.resourceType = resourceType;
        this.participant = participant;
        this.contentClass = contentClass;
        this.therapeuticAreaId = therapeuticAreaId;
        this.resourceId = resourceId;
        this.pState = (pState == null ? rService.getParticipantState() : pState);
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
        return 'WHERE Id IN (' + CollectionUtil.joinByComa(CollectionUtil.wrapInApostrophes(this.resourcesIds)) + ') AND Language__c = \'' + rService.getParticipantLanguage(this.participant) + '\' ';
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