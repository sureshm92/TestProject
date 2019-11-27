/**
 * Created by dmytro.fedchyshyn on 24.09.2019.
 */

@IsTest
public with sharing class Test_TravelVendorPanelRemote {
    @IsTest
    static void getInitData_test() {
        TestData.loadTestData();
        TestData td = new TestData();
        Clinical_Trial_Profile__c clinicalTrialProfile = [SELECT Id FROM Clinical_Trial_Profile__c];

        Test.startTest();
        TravelVendorPanelRemote.InitData initData = TravelVendorPanelRemote.getInitData(clinicalTrialProfile.Id);
        Test.stopTest();
    }

    @IsTest
    static void getItems_test(){
        TestData.loadTestData();
        TestData td = new TestData();
        Clinical_Trial_Profile__c clinicalTrialProfile = [SELECT Id FROM Clinical_Trial_Profile__c];

        Test.startTest();
        TravelVendorPanelRemote.InitData initData = TravelVendorPanelRemote.getInitData(clinicalTrialProfile.Id);
        TravelVendorPanelRemote.getItems(JSON.serialize(initData.searchResponse.studySiteItems), JSON.serialize(initData.filter), JSON.serialize(new PaginationData(15)));
        Test.stopTest();
    }

    @IsTest
    static void getCtpStudySites_test(){
        TestData.loadTestData();
        TestData td = new TestData();
        Clinical_Trial_Profile__c clinicalTrialProfile = [SELECT Id FROM Clinical_Trial_Profile__c];

        Test.startTest();
        TravelVendorPanelRemote.InitData initData = TravelVendorPanelRemote.getInitData(clinicalTrialProfile.Id);
        TravelVendorPanelRemote.getCtpStudySites(initData.filter);
        Test.stopTest();
    }

    @IsTest
    static void selectAllInColumn_test(){
        TestData.loadTestData();
        TestData td = new TestData();
        Clinical_Trial_Profile__c clinicalTrialProfile = [SELECT Id FROM Clinical_Trial_Profile__c];
        TravelVendor__c travelVendor = new TravelVendor__c(Name = 'Uber', Link_Vendor__c = 'link 1');
        insert travelVendor;

        Test.startTest();
        TravelVendorPanelRemote.InitData initData = TravelVendorPanelRemote.getInitData(clinicalTrialProfile.Id);
        TravelVendorPanelRemote.selectAllInColumn(travelVendor.Id, true, JSON.serialize(initData.filter), JSON.serialize(new PaginationData(15)), JSON.serialize(initData.searchResponse.studySiteItems));
        Test.stopTest();
    }

    @IsTest
    static void clearAllInColumn_test(){
        TestData.loadTestData();
        TestData td = new TestData();
        TravelVendor__c travelVendor = new TravelVendor__c(Name = 'Uber', Link_Vendor__c = 'link 1');
        insert travelVendor;

        Test.startTest();
        TravelVendorPanelRemote.InitData initData = TravelVendorPanelRemote.getInitData(td.ctp.Id);
        System.debug(JSON.serializePretty(initData.searchResponse.studySiteItems));
        TravelVendorPanelRemote.selectAllInColumn(travelVendor.Id, false, JSON.serialize(initData.filter), JSON.serialize(new PaginationData(15)), JSON.serialize(initData.searchResponse.studySiteItems));
        Test.stopTest();
    }

    @IsTest
    static void getVendors_test() {
        TestDataFactory.createDataForTravelSupportTesting();
        List<Study_Site__c> studySites = [SELECT Id FROM Study_Site__c];

        Test.startTest();
        List<TravelVendor__c> vendorSettings = TravelSupportRemote.getVendors(studySites[0].Id);
        Test.stopTest();

        System.assertEquals(4, vendorSettings.size());
    }


    @IsTest
    static void getInitDataStateWithException_test() {
        Boolean isExceptionThrown = false;

        Test.startTest();
        try {
            TravelSupportRemote.getInitData();
        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }

    @IsTest
    static void getVendorsWithException_test() {

        Boolean isExceptionThrown = false;

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(TravelSupportHelper.class, StubBuilder.newInstance(TravelSupportHelper.class)
                .when('getVendors')
                .then(new AuraHandledException('error'))
                .build()
        );

        Test.startTest();
        try {
            TravelSupportRemote.getVendors(null);
        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }

    @IsTest
    static void getInitDataWithException_test() {
        Boolean isExceptionThrown = false;

        Test.startTest();
        try {
            TravelVendorPanelRemote.getInitData(null);
        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }
}