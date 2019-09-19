/**
 * Created by dmytro.fedchyshyn on 17.09.2019.
 */

@IsTest
public with sharing class Test_TravelSupportHelper {

    @IsTest
    static void getVendors_test() {
        TravelSupportHelper helper = (TravelSupportHelper) ClassFactory.newInstance(TravelSupportHelper.class);
        Test_TravelSupportHelper.createTravelSetting();

        Study_Site__c studySite = [SELECT Id FROM Study_Site__c];
        Test.startTest();
        helper.getVendors(studySite.Id);
        Test.stopTest();
    }

    @IsTest
    static void getTravelVendorsByIds_test() {
        TravelSupportHelper helper = (TravelSupportHelper) ClassFactory.newInstance(TravelSupportHelper.class);
        Test_TravelSupportHelper.createTravelSetting();

        List<TravelVendor__c> travelVendors = [SELECT Id FROM TravelVendor__c WHERE Name = 'Uber'];
        List<Id> vendorIds = new List<Id>();
        vendorIds.add(travelVendors[0].Id);

        Test.startTest();
        helper.getTravelVendorsByIds(vendorIds);
        Test.stopTest();
    }

    @IsTest
    static void deleteTravelSettings_test() {
        TravelSupportHelper helper = (TravelSupportHelper) ClassFactory.newInstance(TravelSupportHelper.class);
        Test_TravelSupportHelper.createTravelSetting();

        Clinical_Trial_Profile__c clinicalTrialProfile = [SELECT Id FROM Clinical_Trial_Profile__c];
        List<TravelVendor__c> travelVendors = [SELECT Id FROM TravelVendor__c];
        Set<Id> vendors = new Set<Id>();
        vendors.add(travelVendors[0].Id);

        Test.startTest();
        helper.deleteTravelSettings(clinicalTrialProfile.Id, vendors);
        Test.stopTest();
    }

    private static void createTravelSetting() {
        Account account = new Account(Name = 'Johny');
        insert account;
        Contact contact = new Contact(LastName = 'Billy', Email = 'myNameIsBilly@mail.ru');
        insert contact;

        Clinical_Trial_Profile__c clinicalTrialProfile = new Clinical_Trial_Profile__c(Protocol_ID__c = '1122334', Study_Title__c = 'Test study title');
        insert clinicalTrialProfile;

        List<Study_Site__c> studySites = new List<Study_Site__c>{
                new Study_Site__c(Name = 'Study Site 1', Site__c = account.Id, Principal_Investigator__c = contact.Id,
                        Study_Site_Key__c = '1122334455', Clinical_Trial_Profile__c = clinicalTrialProfile.Id)
        };
        insert studySites;

        List<TravelVendor__c> travelVendors = new List<TravelVendor__c>{
                new TravelVendor__c(Name = 'Uber', Link_Vendor__c = 'link 1'),
                new TravelVendor__c(Name = 'Uklon', Link_Vendor__c = 'link 2'),
                new TravelVendor__c(Name = 'Kiev Taxi', Link_Vendor__c = 'link 3'),
                new TravelVendor__c(Name = 'Uzbek', Link_Vendor__c = 'link 4')
        };
        insert travelVendors;

        List<TravelVendorSettings__c> travelVendorSettings = new List<TravelVendorSettings__c>{
                new TravelVendorSettings__c(Study_Site__c = studySites[0].Id, TravelVendor__c = travelVendors[0].Id),
                new TravelVendorSettings__c(Study_Site__c = studySites[0].Id, TravelVendor__c = travelVendors[1].Id),
                new TravelVendorSettings__c(Study_Site__c = studySites[0].Id, TravelVendor__c = travelVendors[2].Id),
                new TravelVendorSettings__c(Study_Site__c = studySites[0].Id, TravelVendor__c = travelVendors[3].Id)
        };
        insert travelVendorSettings;
    }
}