/**
 * Created by Yehor Dobrovolskyi
 */
@IsTest
public with sharing class Test_ArticleService {
    public static final String X_3PARTY_HEALTH_DAY = 'HealthDay';
    public static final String X_3PARTY_IQVIA = 'IQVIA';
    public static final String HEALTH_DAY_NAME_LOGO = 'HealthDay.png';
    public static final String IQVIA_NAME_LOGO = 'IQVIA.svg';
    public static final String TEST_URL_IMAGE = 'http://localhost/test.png';
    public static final String TEST_NAME_IMAGE = 'test.png';


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
    public static void testCreateArticleWrongDate() {
        Resource__c test = getResource(Date.today(), Date.today().addDays(-12));
        System.assertEquals(Date.today(), test.Posting_Date__c);
        System.assertEquals(Date.today().addDays(-12), test.Expiration_Date__c);
        test = getSelectResource(test.Id);
        System.assertEquals(Date.today(), test.Posting_Date__c);
        System.assertEquals(Date.today().addMonths(12), test.Expiration_Date__c);
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
        System.assertEquals(Date.today().addMonths(12), test.Expiration_Date__c);
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

    private static Resource__c getResource(Date publishDate, Date expDate, String imagePath, String x3PartySource) {
        Resource__c res = new Resource__c(
                Name = 'Res-Tes',
                Posting_Date__c = publishDate,
                Expiration_Date__c = expDate,
                Resource_Type__c = 'Articles',
                Content_Class__c = '3rd Party',
                Image__c = imagePath,
                X3rd_Party_Source__c = x3PartySource

        );
        insert res;
        return res;
    }
    private static Resource__c getResource(Date publishDate, Date expDate) {
        return getResource(publishDate, expDate, null, null);
    }

    private static Resource__c getResource() {
        return getResource(null, null, null, null);
    }

    private static Resource__c getResource(String imagePath, String x3rdPartySource) {
        return getResource(null, null, imagePath, x3rdPartySource);
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
                        X3rd_Party_Source__c
                FROM Resource__c
                WHERE Id = :idRes
        ];
    }
}