/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class ArticleService {

    public static void calculateExpirationDate (List<Resource__c> resources) {
        for (Resource__c resource : resources) {
            if (resource.Expiration_Date__c == null) {
                if (resource.Published_Date__c != null) {
                    resource.Expiration_Date__c = resource.Published_Date__c.addMonths(12);
                }
                else {
                    Date createResource = Date.today();
                    resource.Published_Date__c = createResource;
                    resource.Expiration_Date__c = createResource.addMonths(12);
                }
            }
        }
    }
}