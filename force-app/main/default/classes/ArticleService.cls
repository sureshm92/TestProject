/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class ArticleService {

    public static void calculateExpirationDateBeforeInsert(List<Resource__c> resources) {
        for (Resource__c resource : resources) {
            if (resource.Expiration_Date__c == null) {
                System.debug('Expiration_Date = null');
                if (resource.Published_Date__c != null) {
                    System.debug('Published_Date =' + resource.Published_Date__c);
                    resource.Expiration_Date__c = resource.Published_Date__c.addMonths(12);
                }
                else {
                    System.debug('Expiration_Date & Published_Date = null');
                    Date createResource = Date.today();
                    resource.Published_Date__c = createResource;
                    resource.Expiration_Date__c = createResource.addMonths(12);
                }
            }
        }
    }

    public static void calculateExpirationDateBeforeUpdate (List<Resource__c> resourcesNew, Map<Id, Resource__c> oldResMap) {
        for (Resource__c resource : resourcesNew) {
            if (resource.Published_Date__c != oldResMap.get(resource.Id).Published_Date__c
                    || resource.Expiration_Date__c != oldResMap.get(resource.Id).Expiration_Date__c) {
                System.debug('Date article change');
                if (resource.Published_Date__c != null) {
                    System.debug('Published_Date :' + resource.Published_Date__c);
                    resource.Expiration_Date__c = resource.Published_Date__c.addMonths(12);
                } else if (resource.Expiration_Date__c != null) {
                    System.debug('Published_Date : null');
                    System.debug('Expiration_Date :' + resource.Expiration_Date__c);
                    resource.Published_Date__c = resource.Expiration_Date__c.addMonths(-12);
                } else {
                    System.debug('Published_Date : null');
                    System.debug('Expiration_Date = null');
                    Date createResource = Date.today();
                    resource.Published_Date__c = createResource;
                    resource.Expiration_Date__c = createResource.addMonths(12);
                }
            }
        }
    }
}