/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class ArticleService {
    public static final String HEALTH_DAY_NAME_LOGO = 'HealthDay.png';
    public static final String IQVIA_NAME_LOGO = 'IQVIA.svg';
    public static final String PH_FOLDER_LOGO = 'PH_Default_Image';

    public void calculateExpirationDate(List<Resource__c> resources) {
        for (Resource__c resource : resources) {
            if (ResourceService.RESOURCE_SOURCE_THIRD_PARTY.equalsIgnoreCase(resource.Content_Class__c)) {
                this.calculateExpirationDate(resource);
            }
        }
    }

    public void calculateExpirationDate(List<Resource__c> resourcesNew, Map<Id, Resource__c> oldResMap) {
        for (Resource__c resource : resourcesNew) {
            if (ResourceService.RESOURCE_SOURCE_THIRD_PARTY.equalsIgnoreCase(resource.Content_Class__c)) {
                this.calculateExpirationDate(resource, oldResMap.get(resource.Id));
            }
        }
    }

    public void assignTherapeuticAreas(List<Resource__c> resources) {

        TherapeuticAreaService tAService = (TherapeuticAreaService) ClassFactory.newInstance(TherapeuticAreaService.class);
        TherapeuticAreaAssignmentService tAAService = (TherapeuticAreaAssignmentService) ClassFactory.newInstance(TherapeuticAreaAssignmentService.class);
        Set<String> tANames = new Set<String>();
        List<Resource__c> resourcesToProcess = new List<Resource__c>();
        for (Resource__c singleResource : resources) {
            if (String.isNotBlank(singleResource.Content_Class__c)) {
                if (ResourceService.RESOURCE_SOURCE_THIRD_PARTY.containsIgnoreCase(singleResource.Content_Class__c)) {
                    tANames.addAll(tAService.getTANamesOnResource(singleResource));
                    resourcesToProcess.add(singleResource);
                }
            }
        }
        if (!tANames.isEmpty()) {
            List<Therapeutic_Area__c> therapeuticAreas = tAService.getThirdPartyCOIsByNames(tANames, true);
            tAAService.createTAAsForResources(therapeuticAreas, resourcesToProcess);
        }
    }

    public void assignTherapeuticAreas(List<Resource__c> newResources, Map<Id, Resource__c> oldResourcesByIds) {

        TherapeuticAreaService tAService = (TherapeuticAreaService) ClassFactory.newInstance(TherapeuticAreaService.class);
        TherapeuticAreaAssignmentService tAAService = (TherapeuticAreaAssignmentService) ClassFactory.newInstance(TherapeuticAreaAssignmentService.class);
        Set<String> tANames = new Set<String>();
        List<Resource__c> resourcesToProcess = new List<Resource__c>();
        for (Resource__c singleResource : newResources) {
            if (String.isNotBlank(singleResource.Content_Class__c)) {
                if (ResourceService.RESOURCE_SOURCE_THIRD_PARTY.containsIgnoreCase(singleResource.Content_Class__c)) {
                    tANames.addAll(tAService.getTANamesOnResource(singleResource));
                    resourcesToProcess.add(singleResource);
                }
            }
        }
        if (!tANames.isEmpty()) {
            List<Therapeutic_Area__c> therapeuticAreas = tAService.getThirdPartyCOIsByNames(tANames, true);
            tAAService.createDeleteTAAs(resourcesToProcess, oldResourcesByIds, therapeuticAreas);
        }
    }

    public void addDefaultImage(List<Resource__c> resources) {
        for (Resource__c resource : resources) {
            if (String.isBlank(resource.Image__c)) {
                if (ResourceService.RESOURCE_SOURCE_THIRD_PARTY.equalsIgnoreCase(resource.Content_Class__c)
                        && !ResourceService.X3_RD_PARTY_NOT_SOURCE.equalsIgnoreCase(resource.X3rd_Party_Source__c) &&
                        !String.isBlank(resource.X3rd_Party_Source__c)) {
                    if (resource.X3rd_Party_Source__c.equalsIgnoreCase(ResourceService.X_3PARTY_HEALTH_DAY)) {
                        resource.Image__c = getStaticUrlImage(HEALTH_DAY_NAME_LOGO);
                    }
                    if (resource.X3rd_Party_Source__c.equalsIgnoreCase(ResourceService.X_3PARTY_IQVIA)) {
                        resource.Image__c = getStaticUrlImage(IQVIA_NAME_LOGO);
                    }
                }
            }
        }
    }
    public void validateUpdatedDate(List<Resource__c> resources) {
        for (Resource__c resource : resources) {
            if (resource.Updated_Date__c != null && resource.Posting_Date__c != null) {
                if (resource.Updated_Date__c.isSameDay(resource.Posting_Date__c)) {
                    resource.Updated_Date__c = null;
                }
            }

        }
    }

    public String getStaticUrlImage(String imageName) {
        List<StaticResource> resourceList = [
                SELECT Name,
                        NamespacePrefix,
                        SystemModstamp
                FROM StaticResource
                WHERE Name = :PH_FOLDER_LOGO
        ];
        if (resourceList.size() == 1) {
            String namespace = resourceList[0].NamespacePrefix;
            return '/resource/' + resourceList[0].SystemModstamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + PH_FOLDER_LOGO + '/' + imageName;
        } else {
            return '';
        }
    }

    private void calculateExpirationDate(Resource__c resource) {
        if (resource.Expiration_Date__c == null) {
            if (resource.Posting_Date__c != null) {
                resource.Expiration_Date__c = resource.Posting_Date__c.addMonths(12);
            } else {
                Date createResource = Date.today();
                resource.Posting_Date__c = createResource;
                resource.Expiration_Date__c = createResource.addMonths(12);
            }
        } else if (resource.Posting_Date__c == null) {
            resource.Posting_Date__c = resource.Expiration_Date__c.addMonths(-12);
        }
    }

    private void calculateExpirationDate(Resource__c newResource, Resource__c oldResource) {
        if (newResource.Posting_Date__c != oldResource.Posting_Date__c
                || newResource.Expiration_Date__c != oldResource.Expiration_Date__c) {
            calculateExpirationDate(newResource);
        }
    }
}