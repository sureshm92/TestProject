/**
 * Created by Yehor Dobrovolskyi
 */
@IsTest
public with sharing class Test_ArticleService {

    // INSERT TEST

    @IsTest
    public static void testCreateArticleWithoutDate() {
        Resource__c test = getResource(null, null);
        System.assertEquals(null, test.Published_Date__c);
        System.assertEquals(null, test.Expiration_Date__c);
        test = getSelectResource(test.Id);
        System.assertEquals(Date.today(), test.Published_Date__c);
        System.assertEquals(Date.today().addMonths(12), test.Expiration_Date__c);
    }

    @IsTest
    public static void testCreateArticleWithoutExpDate() {
        Resource__c test = getResource(Date.today(), null);
        System.assertEquals(Date.today(), test.Published_Date__c);
        System.assertEquals(null, test.Expiration_Date__c);
        test = getSelectResource(test.Id);
        System.assertEquals(Date.today(), test.Published_Date__c);
        System.assertEquals(Date.today().addMonths(12), test.Expiration_Date__c);
    }

    @IsTest
    public static void testCreateArticleWithoutPublishDate() {
        Resource__c test = getResource(null, Date.today());
        System.assertEquals(null, test.Published_Date__c);
        System.assertEquals(Date.today(), test.Expiration_Date__c);
        test = getSelectResource(test.Id);
        System.assertEquals(Date.today().addMonths(-12), test.Published_Date__c);
        System.assertEquals(Date.today(), test.Expiration_Date__c);
    }

    @IsTest
    public static void testCreateArticleWrongDate() {
        Resource__c test = getResource(Date.today(), Date.today().addDays(-12));
        System.assertEquals(Date.today(), test.Published_Date__c);
        System.assertEquals(Date.today().addDays(-12), test.Expiration_Date__c);
        test = getSelectResource(test.Id);
        System.assertEquals(Date.today(), test.Published_Date__c);
        System.assertEquals(Date.today().addMonths(12), test.Expiration_Date__c);
    }
    // UPDATE TEST

    @IsTest
    public static void testUpdateNullDate() {
        Resource__c test = getResource();
        test = getSelectResource(test.Id);
        System.assertEquals(Date.today(), test.Published_Date__c);
        System.assertEquals(Date.today().addMonths(12), test.Expiration_Date__c);
        updateResource(test, null, null);
        test = getSelectResource(test.Id);
        System.assertEquals(Date.today(), test.Published_Date__c);
        System.assertEquals(Date.today().addMonths(12), test.Expiration_Date__c);
    }

    @IsTest
    public static void testUpdateNullExpDate() {
        Resource__c test = getResource();
        test = getSelectResource(test.Id);
        System.assertEquals(Date.today(), test.Published_Date__c);
        System.assertEquals(Date.today().addMonths(12), test.Expiration_Date__c);
        updateResource(test, Date.today(), null);
        test = getSelectResource(test.Id);
        System.assertEquals(Date.today(), test.Published_Date__c);
        System.assertEquals(Date.today().addMonths(12), test.Expiration_Date__c);
    }

    @IsTest
    public static void testUpdateNullPublishDate() {
        Resource__c test = getResource();
        test = getSelectResource(test.Id);
        System.assertEquals(Date.today(), test.Published_Date__c);
        System.assertEquals(Date.today().addMonths(12), test.Expiration_Date__c);
        updateResource(test, Date.today(), null);
        test = getSelectResource(test.Id);
        System.assertEquals(Date.today(), test.Published_Date__c);
        System.assertEquals(Date.today().addMonths(12), test.Expiration_Date__c);
    }

    @IsTest
    public static void testUpdateWrongDate() {
        Resource__c test = getResource();
        test = getSelectResource(test.Id);
        System.assertEquals(Date.today(), test.Published_Date__c);
        System.assertEquals(Date.today().addMonths(12), test.Expiration_Date__c);
        updateResource(test, Date.today(), Date.today().addDays(-12));
        test = getSelectResource(test.Id);
        System.assertEquals(Date.today(), test.Published_Date__c);
        System.assertEquals(Date.today().addMonths(12), test.Expiration_Date__c);
    }

    public static Resource__c getResource(Date publishDate, Date expDate) {
        Resource__c res = new Resource__c(
                Name = 'Res-Tes',
                Published_Date__c = publishDate,
                Expiration_Date__c = expDate,
                Resource_Type__c = 'Articles',
                Resource_Source__c = 'Study - Specific'
        );
        insert res;
        return res;
    }
    public static Resource__c getResource() {
        return getResource(null, null);
    }

    public static void updateResource(Resource__c resource, Date publishDate, Date expDate) {
        resource.Published_Date__c = publishDate;
        resource.Expiration_Date__c = expDate;
        update resource;
    }

    public static Resource__c getSelectResource(Id idRes) {
        return [
                SELECT
                        Published_Date__c,
                        Expiration_Date__c
                FROM Resource__c
                WHERE Id = :idRes
        ];
    }
}