/**
 * Created by AlexKetch on 4/16/2019.
 */

public with sharing class ResourceNotifierRemote {
    
    @auraEnabled
    public static void setUpdateDate(String recordId) {
        Resource__c res = new Resource__c(Id = recordId, Updated_Date__c = Date.valueOf(System.now()));
        System.debug('res>>'+res);
        update res;
    }

}