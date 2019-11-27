/**
 * Created by dmytro.fedchyshyn on 24.09.2019.
 */

@IsTest
public with sharing class Test_TravelVendorPanelRemote {
    @IsTest
    static void getInitData_test() {

//        TestDataFactory.createDataForTravelSupportTesting();
        TestData.loadTestData();
        TestData td = new TestData();

        Clinical_Trial_Profile__c clinicalTrialProfile = [SELECT Id FROM Clinical_Trial_Profile__c];

        Test.startTest();
        TravelVendorPanelRemote.InitData initData = TravelVendorPanelRemote.getInitData(clinicalTrialProfile.Id);
        Test.stopTest();
//        System.assertEquals('SS1', initData.searchResponse);
    }

//    @IsTest
//    static void getFilteredItems_test() {
//
//       TestDataFactory.createDataForTravelSupportTesting();
//
//        Clinical_Trial_Profile__c clinicalTrialProfile = [SELECT Id FROM Clinical_Trial_Profile__c];
//        List<TravelVendor__c> travelVendors = [SELECT Id FROM TravelVendor__c];
//        List<Id> vendorIds = new List<Id>();
//        for (TravelVendor__c travelVendor : travelVendors) {
//            vendorIds.add(travelVendor.Id);
//        }
//
//        Test.startTest();
//        List<TravelVendorPanelRemote.VendorItem> vendorItems = TravelVendorPanelRemote.getFilteredItems(clinicalTrialProfile.Id, null, null, vendorIds, true);
//        Test.stopTest();
//
//        System.assertEquals('SS1', vendorItems[0].studySite.Study_Site_Number__c);
//    }

//    @IsTest
//    static void saveData_test() {
//
//        TestDataFactory.createDataForTravelSupportTesting();
//
//        Clinical_Trial_Profile__c clinicalTrialProfile = [SELECT Id FROM Clinical_Trial_Profile__c];
//        Study_Site__c studySite = [SELECT Id FROM Study_Site__c];
//
//        List<TravelVendor__c> travelVendors = [SELECT Id FROM TravelVendor__c];
//        List<TravelVendorSettings__c> travelVendorSettings = new List<TravelVendorSettings__c>{
//                new TravelVendorSettings__c(Study_Site__c = studySite.Id, TravelVendor__c = travelVendors[0].Id, isEnable__c = true, Is_Manual__c = true),
//                new TravelVendorSettings__c(Study_Site__c = studySite.Id, TravelVendor__c = travelVendors[1].Id, isEnable__c = true, By_Country__c = true),
//                new TravelVendorSettings__c(Study_Site__c = studySite.Id, TravelVendor__c = travelVendors[2].Id, isEnable__c = false, Is_Manual__c = true, By_Country__c = true)
//        };
//
//        Test.startTest();
//        TravelVendorPanelRemote.saveData(clinicalTrialProfile.Id, travelVendorSettings);
//        Test.stopTest();
//
//        List<TravelVendor__c> newTravelVendors = [SELECT Id FROM TravelVendor__c];
//
//        System.assertEquals(4, newTravelVendors.size());
//    }

//    @IsTest
//    static void createVendor_test() {
//
//        TravelVendor__c travelVendor = new TravelVendor__c(Name = 'Uber', Link_Vendor__c = 'test_link.com');
//
//
//        Test.startTest();
//        TravelVendor__c vendor = TravelVendorPanelRemote.createVendor(travelVendor);
//        Test.stopTest();
//
//        System.assertEquals('Uber', vendor.Name);
//    }

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

//    @IsTest
//    static void saveDataWithException_test() {
//        Boolean isExceptionThrown = false;
//
//        ClassFactory.clearStubTypesByClassNamesMap();
//        ClassFactory.putStubTypeByClassName(TravelSupportHelper.class, StubBuilder.newInstance(TravelSupportHelper.class)
//                .when('deleteTravelSettings')
//                .then(new AuraHandledException('error'))
//                .build()
//        );
//
//        Test.startTest();
//        try {
//            TravelVendorPanelRemote.saveData(null, null);
//        } catch (Exception e) {
//            isExceptionThrown = true;
//            System.assert(e.getTypeName() == 'System.AuraHandledException');
//        }
//        Test.stopTest();
//        System.assert(true, isExceptionThrown);
//    }

//    @IsTest
//    static void getFilteredItemsWithException_test() {
//        Boolean isExceptionThrown = false;
//
//        Test.startTest();
//        try {
//            TravelVendorPanelRemote.getFilteredItems(null, null, null, null, false);
//        } catch (Exception e) {
//            isExceptionThrown = true;
//            System.assert(e.getTypeName() == 'System.AuraHandledException');
//        }
//        Test.stopTest();
//        System.assert(true, isExceptionThrown);
//    }

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