/**
 * Created by Yehor Dobrovolskyi
 */
@IsTest(IsParallel=true)
public with sharing class Test_ArticleService {
    public static final String X_3PARTY_HEALTH_DAY = 'HealthDay';
    public static final String X_3PARTY_IQVIA = 'IQVIA';
    public static final String HEALTH_DAY_NAME_LOGO = 'HealthDay.png';
    public static final String IQVIA_NAME_LOGO = 'IQVIA.svg';
    public static final String TEST_URL_IMAGE = 'http://localhost/test.png';
    public static final String TEST_NAME_IMAGE = 'test.png';
    private static final String HTML_IFRAME_TAG_BLOCK = '<div><div><iframe src="//localhost"></iframe></div></div>';


    // INSERT TEST

    @IsTest
    public static void testCreateArticleWithoutDate() {
        Resource__c test = getResource();
        System.assertEquals(null, test.Posting_Date__c);
        System.assertEquals(null, test.Expiration_Date__c);
        test = getSelectResource(test.Id);
        System.assertEquals(Date.today(), test.Posting_Date__c);
        System.assertEquals(Date.today().addMonths(12), test.Expiration_Date__c);
    }

    @IsTest
    public static void testCreateArticleWithoutExpDate() {
        Resource__c test = getResource(Date.today(), null);
        System.assertEquals(Date.today(), test.Posting_Date__c);
        System.assertEquals(null, test.Expiration_Date__c);
        test = getSelectResource(test.Id);
        System.assertEquals(Date.today(), test.Posting_Date__c);
        System.assertEquals(Date.today().addMonths(12), test.Expiration_Date__c);
    }

    @IsTest
    public static void testCreateArticleWithoutPublishDate() {
        Resource__c test = getResource(null, Date.today());
        System.assertEquals(null, test.Posting_Date__c);
        System.assertEquals(Date.today(), test.Expiration_Date__c);
        test = getSelectResource(test.Id);
        System.assertEquals(Date.today().addMonths(-12), test.Posting_Date__c);
        System.assertEquals(Date.today(), test.Expiration_Date__c);
    }
    @IsTest
    public static void addRecordTypeTest() {
        Resource__c test = getResource(Date.today(), Date.today().addDays(-12), false);
        test.Content_Type__c = 'Video';
        insert test;
        Resource__c r = [SELECT RecordType.Name FROM Resource__c WHERE Id=:test.Id];
        System.assertEquals('Video',r.RecordType.Name);
        Resource__c test2 = getResource(Date.today(), Date.today().addDays(-12), false);
        test2.Content_Type__c = 'Article';
        insert test2;
        Resource__c r2 = [SELECT RecordType.Name FROM Resource__c WHERE Id=:test2.Id];
        System.assertEquals('Article',r2.RecordType.Name);
        Resource__c test3 = getResource(Date.today(), Date.today().addDays(-12), false);
        test3.Content_Type__c = 'Study_Document';
        insert test3;
        Resource__c r3 = [SELECT RecordType.DeveloperName FROM Resource__c WHERE Id=:test3.Id];
        System.assertEquals('Study_Document',r3.RecordType.DeveloperName);
    }

    @IsTest
    public static void testCreateArticleWrongDate() {
        Resource__c test = getResource(Date.today(), Date.today().addDays(-12));
        System.assertEquals(Date.today(), test.Posting_Date__c);
        System.assertEquals(Date.today().addDays(-12), test.Expiration_Date__c);
        test = getSelectResource(test.Id);
        System.assertEquals(Date.today(), test.Posting_Date__c);
        System.assertEquals(Date.today().addDays(-12), test.Expiration_Date__c);
    }
    @IsTest
    public static void validateDateTestUpdateDateEqPostingDate() {
        Resource__c test = getResource(Date.today(), Date.today().addDays(-12), false);
        test.Updated_Date__c = Date.today();
        insert test;
        test = getSelectResource(test.Id);
        System.assertEquals(null, test.Updated_Date__c);
        test.Updated_Date__c = Date.today().addDays(2);
        update test;
        System.assertEquals(Date.today().addDays(2), test.Updated_Date__c);
    }

    @IsTest
    public static void validateDateUpdateDateNotEqPostingDate() {
        Resource__c test = getResource(Date.today(), Date.today().addDays(-12), false);
        test.Updated_Date__c = Date.today().addDays(2);
        insert test;
        test = getSelectResource(test.Id);
        System.assertEquals(Date.today().addDays(2), test.Updated_Date__c);
        test.Updated_Date__c = null;
        update test;
        test = getSelectResource(test.Id);
        System.assertEquals(null, test.Updated_Date__c);
    }

    @IsTest
    public static void testDefaultLogoHealthDay() {
        Resource__c test = getResource(null, X_3PARTY_HEALTH_DAY);
        System.assertEquals(null, test.Image__c);
        test = getSelectResource(test.Id);
        String[] urlPars = test.Image__c.split('/');
        String name = urlPars[urlPars.size() - 1];
        System.assertEquals(HEALTH_DAY_NAME_LOGO, name);

    }

    @IsTest
    public static void testDefaultWithout3PartySource() {
        Resource__c test = getResource();
        System.assert(String.isBlank(test.Image__c));
        test = getSelectResource(test.Id);
        System.assert(String.isBlank(test.Image__c));

    }

    @IsTest
    public static void testDefaultLogoIQVIA() {
        Resource__c test = getResource(null, X_3PARTY_IQVIA);
        System.assertEquals(null, test.Image__c);
        test = getSelectResource(test.Id);
        String[] urlPars = test.Image__c.split('/');
        String name = urlPars[urlPars.size() - 1];
        System.assertEquals(IQVIA_NAME_LOGO, name);

    }

    @IsTest
    public static void testDefaultLogoWithImage() {
        Resource__c test = getResource(TEST_URL_IMAGE, X_3PARTY_HEALTH_DAY);
        String[] urlPars = test.Image__c.split('/');
        String name = urlPars[urlPars.size() - 1];
        System.assertEquals(TEST_NAME_IMAGE, name);
        test = getSelectResource(test.Id);
        urlPars = test.Image__c.split('/');
        name = urlPars[urlPars.size() - 1];
        System.assertNotEquals(HEALTH_DAY_NAME_LOGO, name);

    }
    // UPDATE TEST

    @IsTest
    public static void testUpdateNullDate() {
        Resource__c test = getResource();
        test = getSelectResource(test.Id);
        System.assertEquals(Date.today(), test.Posting_Date__c);
        System.assertEquals(Date.today().addMonths(12), test.Expiration_Date__c);
        updateResource(test, null, null);
        test = getSelectResource(test.Id);
        System.assertEquals(Date.today(), test.Posting_Date__c);
        System.assertEquals(Date.today().addMonths(12), test.Expiration_Date__c);
    }

    @IsTest
    public static void testUpdateNullExpDate() {
        Resource__c test = getResource();
        test = getSelectResource(test.Id);
        System.assertEquals(Date.today(), test.Posting_Date__c);
        System.assertEquals(Date.today().addMonths(12), test.Expiration_Date__c);
        updateResource(test, Date.today(), null);
        test = getSelectResource(test.Id);
        System.assertEquals(Date.today(), test.Posting_Date__c);
        System.assertEquals(Date.today().addMonths(12), test.Expiration_Date__c);
    }

    @IsTest
    public static void testUpdateNullPublishDate() {
        Resource__c test = getResource();
        test = getSelectResource(test.Id);
        System.assertEquals(Date.today(), test.Posting_Date__c);
        System.assertEquals(Date.today().addMonths(12), test.Expiration_Date__c);
        updateResource(test, Date.today(), null);
        test = getSelectResource(test.Id);
        System.assertEquals(Date.today(), test.Posting_Date__c);
        System.assertEquals(Date.today().addMonths(12), test.Expiration_Date__c);
    }

    @IsTest
    public static void testUpdateWrongDate() {
        Resource__c test = getResource();
        test = getSelectResource(test.Id);
        System.assertEquals(Date.today(), test.Posting_Date__c);
        System.assertEquals(Date.today().addMonths(12), test.Expiration_Date__c);
        updateResource(test, Date.today(), Date.today().addDays(-12));
        test = getSelectResource(test.Id);
        System.assertEquals(Date.today(), test.Posting_Date__c);
        System.assertEquals(Date.today().addDays(-12), test.Expiration_Date__c);
    }

    @IsTest
    public static void testUpdateDefaultLogoWithoutImage() {
        Resource__c test = getResource('http://localhost/test.png', null);
        test = getSelectResource(test.Id);
        String[] urlPars = test.Image__c.split('/');
        String name = urlPars[urlPars.size() - 1];
        System.assertNotEquals(HEALTH_DAY_NAME_LOGO, name);
        updateResource(test, '');
        test = getSelectResource(test.Id);
        System.assert(String.isBlank(test.Image__c));

    }

    @IsTest
    public static void testRemoveSharingBeforeInsert() {
        List<Resource__c> resources = new List<Resource__c>{
                (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object>{
                        'Expiration_Date__c' => Date.today().addDays(12),
                        'Remove_sharing__c' => true
                })
        };
        Test.startTest();
        new ArticleService().updateRemoveSharing(resources);
        Test.stopTest();
        System.assert(!resources[0].Remove_sharing__c);
    }

    @IsTest
    public static void testRemoveSharingBeforeUpdate() {
        Resource__c resourceNew =   (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object>{
                'Id' => TestDataFactory.getFakeId(Resource__c.getSObjectType()),
                'Expiration_Date__c' => Date.today().addDays(12),
                'Remove_sharing__c' => true
        });

        Resource__c resourceOld =   (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object>{
                'Id' => resourceNew.Id,
                'Expiration_Date__c' => Date.today().addDays(-12),
                'Remove_sharing__c' => false
        });
        Test.startTest();
        new ArticleService().updateRemoveSharing(new List<Resource__c>{resourceNew}, new Map<Id, Resource__c>(new List<Resource__c>{resourceOld}));
        Test.stopTest();
        System.assert(!resourceNew.Remove_sharing__c);
    }

    @IsTest
    public static void testParseVideoResource3rdParty() {
        Resource__c res =   (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object>{
                'Content_Class__c' => ResourceService.RESOURCE_SOURCE_THIRD_PARTY,
                'Content_Type__c' => ResourceService.RESOURCE_TYPE_VIDEO,
                'Body__c' => HTML_IFRAME_TAG_BLOCK,
                'Video__c' => ''
        });
        Test.startTest();
        new ArticleService().getUrlVideoFromBody(new List<Resource__c>{
                res
                });
        Test.stopTest();
        System.assertEquals('//localhost', res.Video__c);
        System.assertNotEquals(HTML_IFRAME_TAG_BLOCK, res.Body__c);
    }

    private static Resource__c getResource(Date publishDate
            , Date expDate
            , String imagePath
            , String x3PartySource
            , Boolean iscreate) {
        Resource__c res = new Resource__c(
                Posting_Date__c = publishDate,
                Expiration_Date__c = expDate,
                Content_Type__c = ResourceService.RESOURCE_TYPE_ARTICLE,
                Content_Class__c = ResourceService.RESOURCE_SOURCE_THIRD_PARTY,
                Image__c = imagePath,
                X3rd_Party_Source__c = x3PartySource

        );
        if (iscreate) {
            insert res;
        }
        return res;
    }
    private static Resource__c getResource(Date publishDate, Date expDate) {
        return getResource(publishDate, expDate, null, null, true);
    }
    private static Resource__c getResource(Date publishDate, Date expDate, Boolean isCreate) {
        return getResource(publishDate, expDate, null, null, isCreate);
    }

    private static Resource__c getResource() {
        return getResource(null, null, null, null, true);
    }

    private static Resource__c getResource(String imagePath, String x3rdPartySource) {
        return getResource(null, null, imagePath, x3rdPartySource, true);
    }

    private static void updateResource(Resource__c resource, Date publishDate, Date expDate) {
        resource.Posting_Date__c = publishDate;
        resource.Expiration_Date__c = expDate;
        update resource;
    }

    private static void updateResource(Resource__c resource, String imageName) {
        resource.Image__c = imageName;
        update resource;
    }

    private static Resource__c getSelectResource(Id idRes) {
        return [
                SELECT
                        Posting_Date__c,
                        Expiration_Date__c,
                        Image__c,
                        X3rd_Party_Source__c,
                        Updated_Date__c
                FROM Resource__c
                WHERE Id = :idRes
        ];
    }
}