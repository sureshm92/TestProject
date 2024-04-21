@isTest
private class Test_ResourceTriggerHandler {
    
    @isTest
    static void testBeforeInsert() {
        List<Resource__c> newList = new List<Resource__c>();
        Test.startTest();
        ResourceTriggerHandler.ArticleResourceProcessor processor = new ResourceTriggerHandler.ArticleResourceProcessor();
        processor.beforeInsert(newList);
        Test.stopTest();
    }
    
    @isTest
    static void testBeforeUpdate() {
        Resource__c r = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r.Posting_Date__c = Date.valueOf(System.now().addDays(-2));
        insert r;
        List<Resource__c> newList = new List<Resource__c>();
        Map<Id, Resource__c> oldMap = new Map<Id, Resource__c>();
        Test.startTest();
        ResourceTriggerHandler.ArticleResourceProcessor processor = new ResourceTriggerHandler.ArticleResourceProcessor();
        processor.beforeUpdate(newList, oldMap);
        Test.stopTest();
    }
    
    @isTest
    static void testAfterInsert() {
        TestData.loadTestData();
        TestData td = new TestData();
        Resource__c r = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r.Resource_Visibility__c = 'RP';
        insert r;
        List<Resource__c> newList = new List<Resource__c>();
        for(Resource__c newres : [select id,Content_Class__c,Resource_Visibility__c from Resource__c where id=:r.id]){
            newres.Posting_Date__c = Date.valueOf(System.now().addDays(-2));
            newres.Resource_Visibility__c = 'PI';
            newList.add(newres);
        }   
        update newList;
        contact con = new contact();
            con.lastname = 'TestLN';
            con.Email = 'test@abcdghh.com';
            insert con;
        List<Study_Site__c> lstOfStaff = new List<Study_Site__c>();
        List<Site_Staff__c> lstOfSiteStaff = new List<Site_Staff__c>();
        Test.startTest();
        ResourceTriggerHandler.ArticleResourceProcessor processor = new ResourceTriggerHandler.ArticleResourceProcessor();
        processor.afterInsert(newList);
        Test.stopTest();
    }
    
    @isTest
    static void testAfterUpdate() {
        Resource__c r = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r.Posting_Date__c = Date.valueOf(System.now().addDays(-2));
        insert r;
        List<Resource__c> newList = new List<Resource__c>();
        Map<Id, Resource__c> oldMap = new Map<Id, Resource__c>();
        ResourceTriggerHandler.ArticleResourceProcessor articleResourceProcessor = new ResourceTriggerHandler.ArticleResourceProcessor();
        Test.startTest();
        articleResourceProcessor.afterUpdate(newList, (Map<Id, SObject>) oldMap);
        Test.stopTest();
        
    }
    
}