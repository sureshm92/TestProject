public inherited sharing class ResourceTARelatedService extends ResourceService {
    public static ResourceTARelatedService getInstance() {
        return (ResourceTARelatedService) ClassFactory.newInstance(ResourceTARelatedService.class);
    }

    protected String therapeuticAreaId;
    protected List<String> therapeuticAreas;

    public ResourceService init(
        String resourceType,
        String resourceId,
        String contentClass,
        String therapeuticAreaId
    ) {
        init(resourceType, resourceId, contentClass);
        this.therapeuticAreaId = therapeuticAreaId;
        return this;
    }

    public ResourceService init(
        String resourceType,
        String resourceId,
        String contentClass,
        List<String> therapeuticAreas
    ) {
        init(resourceType, resourceId, contentClass);
        this.therapeuticAreas = therapeuticAreas;
        return this;
    }

    protected override List<Id> getResourcesIds() {
        List<String> participantLanguages = ContactService.getPreferredLanguages();
        List<String> listResourceType= new List<String>();
            listResourceType=resourceType.split(';');
        if (therapeuticAreaId == null && (therapeuticAreas == null || therapeuticAreas.size() == 0))
            return new List<Id>();
        String filter =
            (therapeuticAreas.isEmpty()
                ? DatabaseService.fieldEqual('Therapeutic_Area__c', therapeuticAreaId)
                : DatabaseService.fieldInValues('Therapeutic_Area__c', therapeuticAreas)) +
            (contentClass == null
                ? ''
                : ('AND' +
                  DatabaseService.fieldEqual('Resource__r.Content_Class__c', contentClass))) +
            (resourceId == null
                ? ''
                : ('AND' + DatabaseService.fieldEqual('Resource__c', resourceId))) +
            'AND' +
            DatabaseService.fieldInValues('Resource__r.RecordType.DeveloperName', listResourceType) +
            'AND' +
            DatabaseService.fieldInValues('Resource__r.Language__c', participantLanguages);
        List<Therapeutic_Area_Assignment__c> assignments = (List<Therapeutic_Area_Assignment__c>) DatabaseService.query(
            new List<String>{ 'Resource__c', 'Resource__r.Language__c', 'Resource__r.Title__c' },
            Therapeutic_Area_Assignment__c.getSObjectType(),
            filter
        );

        Map<String, Map<String, Id>> resIdByLangByTitle = new Map<String, Map<String, Id>>();
        for (Therapeutic_Area_Assignment__c ass : assignments) {
            if (!resIdByLangByTitle.containsKey(ass.Resource__r.Title__c)) {
                resIdByLangByTitle.put(ass.Resource__r.Title__c, new Map<String, Id>());
            }

            resIdByLangByTitle.get(ass.Resource__r.Title__c)
                .put(ass.Resource__r.Language__c, ass.Resource__c);
        }

        List<Id> resourcesIds = new List<Id>();
        for (String title : resIdByLangByTitle.keySet()) {
            Map<String, Id> resIdByLang = resIdByLangByTitle.get(title);
            for (String participantLang : participantLanguages) {
                if (resIdByLang.containsKey(participantLang)) {
                    resourcesIds.add(resIdByLang.get(participantLang));
                    break;
                }
            }
        }

        return resourcesIds;
    }

    protected override ResourceService.ResourceWrapperContainer getErrorNoObjectsToFilter() {
        return ResourceService.getErrorUnhandled();
    }

    protected override Boolean isObjectsToFilterMissing() {
        if (
            (CommunityService.getContactUserMode(CommunityService.getUserContact().Id) ==
            CommunityService.USER_MODE_PI) || 
            (CommunityService.getContactUserMode(CommunityService.getUserContact().Id) == CommunityService.USER_MODE_HCP)
        ) {
            return false;
        }
        return (this.therapeuticAreaId == null) && (this.therapeuticAreas.isEmpty());
    }
}
