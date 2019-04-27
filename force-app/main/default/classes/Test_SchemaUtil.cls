/**
 * Created by AlexKetch on 4/16/2019.
 */
@isTest
public with sharing class Test_SchemaUtil {

    @isTest
    public static void positiveTest() {
        Resource__c r = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r.RecordTypeId = SchemaUtil.getRecordTypeIdByName('Article', Resource__c.getSObjectType());
        insert r;
        String s = SchemaUtil.getRecordTypeNameBySObjectId(r.Id);
        String s2 = SchemaUtil.getRecordTypeNameById(r.RecordTypeId,Resource__c.getSObjectType());
        String s3 = SchemaUtil.getRecordTypeDeveloperNameById(r.RecordTypeId,Resource__c.getSObjectType());
        String s4 = SchemaUtil.getRecordTypeDeveloperNameBySObjectId(r.Id);
        System.assertEquals('Article',s);
        System.assertEquals('Article',s2);
        System.assertEquals('Article',s3);
        System.assertEquals('Article',s4);
    }
}