@IsTest
public with sharing class Test_ECOAService {
    public class ECOAServiceMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"siteGuid":"test","ecoaResponseID":"1233"}]');
            res.setStatusCode(200);
            return res;
        }
    }

    public class ECOAServiceStub implements StubProvider {
        public Object handleMethodCall(
            Object stubbedObject,
            String stubbedMethodName,
            Type returnType,
            List<Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs
        ) {
            /*if (stubbedMethodName == 'execute') {
                return null;
            }*/
            return null;
        }
    }
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @IsTest
    private static void testBatchCreateSite() {
        ECOAService.setMock(new ECOAServiceStub());
        Clinical_Trial_Profile__c ctp = [
            SELECT id, Study_GUID__c
            FROM Clinical_Trial_Profile__c
            LIMIT 1
        ];
        ctp.Study_GUID__c = 'testguid123';
        ctp.ECOA_Is_Avaialble__c = true;
        update ctp;
        Test.startTest();
        Database.executebatch(new Batch_CreateECOASite());
        Test.stopTest();
        Batch_CreateECOASite obj1 = new Batch_CreateECOASite();
        obj1.getRecommendedRelaunchInterval();
        obj1.getRecommendedScopeSize();
        obj1.getBatchDescription();
    }
    @IsTest
    private static void testBatchCreateSubject() {
        ECOAService.setMock(new ECOAServiceStub());
        Clinical_Trial_Profile__c ctp = [
            SELECT id, Study_GUID__c
            FROM Clinical_Trial_Profile__c
            LIMIT 1
        ];
        ctp.Study_GUID__c = 'testguid123';
        ctp.ECOA_Is_Avaialble__c = true;
        update ctp;
        Participant_Enrollment__c pe = [
            SELECT id, Subject_GUID__c, Participant_Status__c, Visit_Plan__c
            FROM Participant_Enrollment__c
            WHERE Clinical_Trial_Profile__c = :ctp.id
            LIMIT 1
        ];
        pe.Subject_GUID__c = null;
        pe.Participant_Status__c = 'Enrollment Success';
        update pe;
        Study_Site__c ss = [SELECT id FROM Study_Site__c LIMIT 1];
        ss.ECOA_Site_Guid__c = 'ecosite123';
        update ss;
        Test.startTest();
        Database.executebatch(new Batch_CreateECOASubject());
        Test.stopTest();
        Batch_CreateECOASubject obj1 = new Batch_CreateECOASubject();
        obj1.getRecommendedRelaunchInterval();
        obj1.getRecommendedScopeSize();
        obj1.getBatchDescription();
    }
    @IsTest
    private static void testCreateSubject() {
        TestData testData = new TestData();
        Test.setMock(HttpCalloutMock.class, new ECOAServiceMock());
        testData.ctp.Study_Version_GUID__c = 'test';
        testData.ctp.Study_GUID__c = 'dd';
        update testData.ctp;
        list<Participant_Enrollment__c> pelist = [
            SELECT
                id,
                Participant_Contact__c,
                Clinical_Trial_Profile__c,
                Clinical_Trial_Profile__r.Study_GUID__c,
                Clinical_Trial_Profile__r.Study_Version_GUID__c,
                Study_Site__r.ECOA_Site_Guid__c,
                Visit_Plan__c
            FROM Participant_Enrollment__c
        ];

        ECOAService.createSubject(pelist);
    }
    @IsTest
    private static void testCreateEvent() {
        TestData testData = new TestData();
        Test.setMock(HttpCalloutMock.class, new ECOAServiceMock());
        List<Map<String, String>> requestMapList = new List<Map<String, String>>();
        Map<String, String> ecoaEventMap = new Map<String, String>{
            'studyGuid' => 'per.Clinical_Trial_Profile__r.Study_GUID__c',
            'orgGuid' => 'ECOAService.apiParamsMap.get(ECOAService.ORG_GUID).ParamValue__c',
            'subjectGuid' => 'per.Subject_GUID__c',
            'date' => 'dateValue',
            'dateKey' => 'dateKey'
        };
        requestMapList.add(ecoaEventMap);
        Test.startTest();
        ECOAService.createEcoaEvent(requestMapList);
        Test.stopTest();
    }
    @IsTest
    private static void testgetJWT() {
        try {
            ECOADiariesController.getToken();
        } catch (Exception ex) {
            system.debug('line number:' + ex.getLineNumber());
        }
    }
    @IsTest
    private static void testCreateSite() {
        TestData testData = new TestData();
        Test.setMock(HttpCalloutMock.class, new ECOAServiceMock());
        List<Study_Site__c> lstSites = new List<Study_Site__c>();
        lstSites = [
            SELECT
                id,
                Name,
                Clinical_Trial_Profile__r.Study_GUID__c,
                site__r.billingcountrycode,
                site__r.BillingStreet,
                site__r.BillingCity,
                site__r.billingState,
                Site__r.billingcountry,
                Site__r.BillingPostalCode,
                Clinical_Trial_Profile__c,
                ECOA_Site_Guid__c
            FROM Study_Site__c
            LIMIT 1
        ];
        //lstSites.add(testData.ss);
        Test.startTest();
        ECOAService.createSite(lstSites);
        //ECOAService.getJWTToken();
        Test.stopTest();
    }
}
