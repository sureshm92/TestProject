/**
 * Created by AlexKetch on 4/16/2019.
 */
@IsTest(IsParallel=true)
public with sharing class Test_ResourceNotifierRemote {
    @isTest
    public static void testRemote() {
        Resource__c r = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r.Posting_Date__c=Date.valueOf(System.now().addDays(-2));
        insert r;
        ResourceNotifierRemote.setUpdateDate(r.Id);
        Resource__c newR = [SELECT Updated_Date__c FROM Resource__c];
        System.assert(newR.Updated_Date__c != null);
    }

}