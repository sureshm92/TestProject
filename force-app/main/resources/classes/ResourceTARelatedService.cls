public inherited sharing class ResourceTARelatedService extends ResourceService {

    public static ResourceTARelatedService getInstance(){
        return (ResourceTARelatedService) ClassFactory.newInstance(ResourceTARelatedService.class);
    }
    
    protected String therapeuticAreaId;
    
    public ResourceService init(String resourceType, String resourceId, String contentClass, String therapeuticAreaId) {
        init(resourceType, resourceId, contentClass);
        this.therapeuticAreaId = therapeuticAreaId;
        return this;
    }
    
    protected override List<Id> getResourcesIds() {
        List<String> participantLanguages = ContactService.getPreferredLanguages();

        String filter = DatabaseService.fieldEqual('Therapeutic_Area__c', therapeuticAreaId)
                + (contentClass == null ? '' : ('AND' + DatabaseService.fieldEqual('Resource__r.Content_Class__c', contentClass)))
                + (resourceId == null ? '' : ('AND' + DatabaseService.fieldEqual('Resource__c', resourceId)))
                + 'AND' + DatabaseService.fieldEqual('Resource__r.RecordType.DeveloperName', resourceType)
                + 'AND' + DatabaseService.fieldInValues('Resource__r.Language__c', participantLanguages)
        ;
        List<Therapeutic_Area_Assignment__c> assignments = (List<Therapeutic_Area_Assignment__c>)
                DatabaseService.query(new List<String>{
                'Resource__c',
                'Resource__r.Language__c',
                'Resource__r.Title__c'
        }, Therapeutic_Area_Assignment__c.getSObjectType(), filter);

        Map<String, Map<String, Id>> resIdByLangByTitle = new Map<String, Map<String, Id>>();
        for(Therapeutic_Area_Assignment__c ass : assignments) {
            if(!resIdByLangByTitle.containsKey(ass.Resource__r.Title__c)) {
                resIdByLangByTitle.put(ass.Resource__r.Title__c, new Map<String, Id>());
            }

            resIdByLangByTitle.get(ass.Resource__r.Title__c).put(ass.Resource__r.Language__c, ass.Resource__c);
        }

        List<Id> resourcesIds = new List<Id>();
        for(String title : resIdByLangByTitle.keySet()) {
            Map<String, Id> resIdByLang = resIdByLangByTitle.get(title);
            for(String participantLang : participantLanguages) {
                if(resIdByLang.containsKey(participantLang)) {
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
        return this.therapeuticAreaId == null;
    }
}