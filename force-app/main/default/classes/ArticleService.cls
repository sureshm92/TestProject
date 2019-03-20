/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class ArticleService {
    public static String HealthDayLogo = 'HealthDay.png';

    public static void calculateExpirationDateBeforeInsert(List<Resource__c> resources) {
        for (Resource__c resource : resources) {
            if (resource.Expiration_Date__c == null) {
                if (resource.Posting_Date__c != null) {
                    resource.Expiration_Date__c = resource.Posting_Date__c.addMonths(12);
                }
                else {
                    Date createResource = Date.today();
                    resource.Posting_Date__c = createResource;
                    resource.Expiration_Date__c = createResource.addMonths(12);
                }
            }
        }
    }

    public static void addDefaultImage(List<Resource__c> resources) {
        for (Resource__c resource : resources) {
            if (String.isBlank(resource.Image__c)) {
                if (!String.isBlank(resource.X3rd_Party_Source__c)) {
                    System.debug(resource.X3rd_Party_Source__c);
                    resource.Image__c = getStaticUrlImage(resource.X3rd_Party_Source__c + '.png');
                } else {
                    resource.Image__c = getStaticUrlImage(HealthDayLogo);
                }
            }
        }
    }

    public static String getStaticUrlImage(String imageName) {
        List<StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModstamp FROM StaticResource WHERE Name = 'PH_Default_Image'];

        // Checking if the result is returned or not
        if(resourceList.size() == 1){

            // Getting namespace
            String namespace = resourceList[0].NamespacePrefix;
            // Resource URL
            return '/resource/' + resourceList[0].SystemModstamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') +  'PH_Default_Image/' + imageName;
        } else {
            return '';
        }
    }

    public static void calculateExpirationDateBeforeUpdate (List<Resource__c> resourcesNew, Map<Id, Resource__c> oldResMap) {
        for (Resource__c resource : resourcesNew) {
            if (resource.Posting_Date__c != oldResMap.get(resource.Id).Posting_Date__c
                    || resource.Expiration_Date__c != oldResMap.get(resource.Id).Expiration_Date__c) {
                if (resource.Posting_Date__c != null) {
                    resource.Expiration_Date__c = resource.Posting_Date__c.addMonths(12);
                } else if (resource.Expiration_Date__c != null) {
                    resource.Posting_Date__c = resource.Expiration_Date__c.addMonths(-12);
                } else {
                    Date createResource = Date.today();
                    resource.Posting_Date__c = createResource;
                    resource.Expiration_Date__c = createResource.addMonths(12);
                }
            }
        }
    }
}