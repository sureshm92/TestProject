/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class ArticleService {

    public static void calculateExpirationDateBeforeInsert(List<Resource__c> resources) {
        for (Resource__c resource : resources) {
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
    }

    public static void calculateExpirationDateBeforeUpdate(List<Resource__c> resourcesNew, Map<Id, Resource__c> oldResMap) {
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