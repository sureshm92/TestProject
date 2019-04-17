/**
 * Created by AlexKetch on 4/16/2019.
 */
@isTest
public with sharing class Test_SchemaUtil {

    @isTest
    public static void postitiveTest() {
        Resource__c r = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r.RecordTypeId = SchemaUtil.getRecordTypeIdByName('Article', Resource__c.getSObjectType());
        insert r;
        String s = SchemaUtil.getRecordTypeBySobjectId(r.Id);
        String s2 = SchemaUtil.getRecordTypeById(r.RecordTypeId,Resource__c.getSObjectType());
        System.assertEquals('Article',s);
        System.assertEquals('Article',s2);
    }
}