/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class ArticleService {
    private static final String X3_RD_PARTY_NOT_SOURCE = 'N/A';
    private static final String CONTENT_CLASS_3_RD_PARTY = '3rd Party';
    public static final String X_3PARTY_HEALTH_DAY = 'HealthDay';
    public static final String X_3PARTY_IQVIA = 'IQVIA';
    public static final String HEALTH_DAY_NAME_LOGO = 'HealthDay.png';
    public static final String IQVIA_NAME_LOGO = 'IQVIA.svg';

    public static void calculateExpirationDateBeforeInsert(List<Resource__c> resources) {
        for (Resource__c resource : resources) {
            if (ResourceService.RESOURCE_SOURCE_THIRD_PARTY.equalsIgnoreCase(resource.Content_Class__c)) {
                ArticleService.calculateExpirationDateBeforeInsert(resource);
            }
        }

    }

    public static void calculateExpirationDateBeforeUpdate(List<Resource__c> resourcesNew, Map<Id, Resource__c> oldResMap) {
        for (Resource__c resource : resourcesNew) {
            if (ResourceService.RESOURCE_SOURCE_THIRD_PARTY.equalsIgnoreCase(resource.Content_Class__c)) {
                ArticleService.calculateExpirationDateBeforeUpdate(resource, oldResMap.get(resource.Id));
            }
        }
    }

    public static void addDefaultImage(List<Resource__c> resources) {
        for (Resource__c resource : resources) {
            if (String.isBlank(resource.Image__c)) {
                if (CONTENT_CLASS_3_RD_PARTY.equalsIgnoreCase(resource.Content_Class__c)
                        && !X3_RD_PARTY_NOT_SOURCE.equalsIgnoreCase(resource.X3rd_Party_Source__c) &&
                        !String.isBlank(resource.X3rd_Party_Source__c)) {
                    System.debug(resource.X3rd_Party_Source__c);
                    if (resource.X3rd_Party_Source__c.equalsIgnoreCase(X_3PARTY_HEALTH_DAY)) {
                        resource.Image__c = getStaticUrlImage(HEALTH_DAY_NAME_LOGO);
                    }
                    if (resource.X3rd_Party_Source__c.equalsIgnoreCase(X_3PARTY_IQVIA)) {
                        resource.Image__c = getStaticUrlImage(IQVIA_NAME_LOGO);
                    }
                }
            }
        }
    }

    public static String getStaticUrlImage(String imageName) {
        List<StaticResource> resourceList = [SELECT Name, NamespacePrefix, SystemModstamp FROM StaticResource WHERE Name = 'PH_Default_Image'];

        // Checking if the result is returned or not
        if (resourceList.size() == 1) {

            // Getting namespace
            String namespace = resourceList[0].NamespacePrefix;
            // Resource URL
            return '/resource/' + resourceList[0].SystemModstamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + 'PH_Default_Image/' + imageName;
        } else {
            return '';
        }
    }

    private static void calculateExpirationDateBeforeInsert(Resource__c resource) {
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
        } else if (resource.Posting_Date__c > resource.Expiration_Date__c) {
            resource.Expiration_Date__c = resource.Posting_Date__c.addMonths(12);

        }
    }

    private static void calculateExpirationDateBeforeUpdate(Resource__c newResource, Resource__c oldResource) {
        if (newResource.Posting_Date__c != oldResource.Posting_Date__c
                || newResource.Expiration_Date__c != oldResource.Expiration_Date__c) {
                if (newResource.Posting_Date__c != null) {
                    newResource.Expiration_Date__c = newResource.Posting_Date__c.addMonths(12);
                } else if (newResource.Expiration_Date__c != null) {
                    newResource.Posting_Date__c = newResource.Expiration_Date__c.addMonths(-12);
                } else {
                    Date createResource = Date.today();
                    newResource.Posting_Date__c = createResource;
                    newResource.Expiration_Date__c = createResource.addMonths(12);
                }
        }
    }

}