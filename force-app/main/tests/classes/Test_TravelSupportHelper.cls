/**
 * Created by dmytro.fedchyshyn on 17.09.2019.
 */

@IsTest
public with sharing class Test_TravelSupportHelper {

    @TestSetup
    static void setup() {
        Test.startTest();
        TestDataFactory.createDataForTravelSupportTesting();
        Test.stopTest();
    }

    @IsTest
    static void getVendors_test() {
        Study_Site__c studySite = [SELECT Id FROM Study_Site__c];

        Test.startTest();
        List<TravelVendor__c> vendorSettings = TravelSupportHelper.getVendors(studySite.Id);
        Test.stopTest();

        System.assertEquals(4, vendorSettings.size());
    }

    @IsTest
    static void deleteTravelSettings_test() {
        TravelSupportHelper helper = (TravelSupportHelper) ClassFactory.newInstance(TravelSupportHelper.class);

        Clinical_Trial_Profile__c clinicalTrialProfile = [SELECT Id FROM Clinical_Trial_Profile__c];
        List<TravelVendor__c> travelVendors = [SELECT Id FROM TravelVendor__c];
        Set<Id> vendors = new Set<Id>();
        vendors.add(travelVendors[0].Id);

        Test.startTest();
        helper.deleteTravelSettings(clinicalTrialProfile.Id, vendors);
        Test.stopTest();

        List<TravelVendor__c> expectedTravelVendors = [SELECT Id FROM TravelVendor__c];
        System.assertEquals(4, expectedTravelVendors.size());
    }

    @IsTest
    static void getVendorItemsWithOutAnyCountryCodeOrStudySite_test() {
        TravelSupportHelper helper = (TravelSupportHelper) ClassFactory.newInstance(TravelSupportHelper.class);

        Clinical_Trial_Profile__c clinicalTrialProfile = [SELECT Id FROM Clinical_Trial_Profile__c];

        Test.startTest();
        List<TravelVendorPanelRemote.VendorItem> items = helper.getVendorItems(null, clinicalTrialProfile.Id, null, null, false);
        Test.stopTest();

        System.assertEquals('SS1', items[0].studySite.Study_Site_Number__c);
    }

    @IsTest
    static void getVendorItemsWithStudySite_test() {
        TravelSupportHelper helper = (TravelSupportHelper) ClassFactory.newInstance(TravelSupportHelper.class);

        Clinical_Trial_Profile__c clinicalTrialProfile = [SELECT Id FROM Clinical_Trial_Profile__c];
        List<TravelVendor__c> travelVendors = [SELECT Id FROM TravelVendor__c];
        List<Study_Site__c> studySites = [SELECT Id FROM Study_Site__c];
        List<Id> vendors = new List<Id>();
        List<String> studySiteIds = new List<String>();
        vendors.add(travelVendors[0].Id);
        for (Study_Site__c studySite : studySites) {
            studySiteIds.add(studySite.Id);
        }
        Test.startTest();
        List<TravelVendorPanelRemote.VendorItem> items = helper.getVendorItems(null, clinicalTrialProfile.Id, studySiteIds, vendors, false);
        Test.stopTest();

        System.assertEquals('SS1' ,items[0].studySite.Study_Site_Number__c);
    }

    @IsTest
    static void getVendorItemsWithCountryCode_test() {
        TravelSupportHelper helper = (TravelSupportHelper) ClassFactory.newInstance(TravelSupportHelper.class);

        Clinical_Trial_Profile__c clinicalTrialProfile = [SELECT Id FROM Clinical_Trial_Profile__c];
        List<TravelVendor__c> travelVendors = [SELECT Id FROM TravelVendor__c];
        List<Id> vendors = new List<Id>();
        List<String> countryCodes = new List<String>();
        vendors.add(travelVendors[0].Id);
        countryCodes.add('US');
        Test.startTest();
        List<TravelVendorPanelRemote.VendorItem> items = helper.getVendorItems(countryCodes, clinicalTrialProfile.Id, null, vendors, false);
        Test.stopTest();
    }

    @IsTest
    static void getInitData_test() {
        TravelSupportHelper helper = (TravelSupportHelper) ClassFactory.newInstance(TravelSupportHelper.class);

        Clinical_Trial_Profile__c clinicalTrialProfile = [SELECT Id FROM Clinical_Trial_Profile__c];


        Test.startTest();
        List<TravelVendorPanelRemote.VendorItem> vendorItems = helper.getInitData(clinicalTrialProfile.Id);
        Test.stopTest();

        System.assertEquals(vendorItems[0].vendorSettings.size(), 4);
    }

    @IsTest
    static void fillVendorSettingsWithStub_test() {
        TravelSupportHelper helper = (TravelSupportHelper) ClassFactory.newInstance(TravelSupportHelper.class);

        Clinical_Trial_Profile__c clinicalTrialProfile = [SELECT Id FROM Clinical_Trial_Profile__c];
        List<TravelVendor__c> travelVendors = [SELECT Id FROM TravelVendor__c];
        TravelVendor__c razor = new TravelVendor__c(Name = 'Razor', Link_Vendor__c = 'razor.com');
        insert razor;

        List<Id> vendorIds = new List<Id>();
        for (TravelVendor__c travelVendor : travelVendors) {
            vendorIds.add(travelVendor.Id);
        }
        vendorIds.add(razor.Id);

        Test.startTest();
        List<TravelVendorPanelRemote.VendorItem> vendorItems = helper.getInitData(clinicalTrialProfile.Id);
        helper.fillVendorSettingsWithStub(vendorIds, vendorItems);
        Test.stopTest();

        System.assertEquals(vendorItems[0].vendorSettings.size(), 5);
    }
}