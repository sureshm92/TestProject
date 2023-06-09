/**
 * Created by dmytro.fedchyshyn on 24.09.2019.
 */

@IsTest
private with sharing class Test_TravelVendorPanelRemote {
    @TestSetup
    static void init() {
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SendDropOutEmailHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateWelcomeToStudyAlertHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.CreateNotificationHandler.class
        );
        TestData.loadTestData();
    }

    @IsTest
    static void getInitData_test() {
        TestData td = new TestData();
        Clinical_Trial_Profile__c clinicalTrialProfile = [SELECT Id FROM Clinical_Trial_Profile__c];

        Test.startTest();
        TravelVendorPanelRemote.InitData initData = TravelVendorPanelRemote.getInitData(td.ctp.Id);
        Test.stopTest();
    }

    @IsTest
    static void getItems_test() {
        TestData td = new TestData();
        Clinical_Trial_Profile__c clinicalTrialProfile = [SELECT Id FROM Clinical_Trial_Profile__c];

        Test.startTest();
        TravelVendorPanelRemote.InitData initData = TravelVendorPanelRemote.getInitData(
            clinicalTrialProfile.Id
        );
        TravelVendorPanelRemote.getItems(
            JSON.serialize(initData.searchResponse.studySiteItems),
            JSON.serialize(initData.filter),
            JSON.serialize(new PaginationData(15))
        );
        Test.stopTest();
    }

    @IsTest
    static void selectAllInColumn_test() {
        TestData td = new TestData();
        Clinical_Trial_Profile__c clinicalTrialProfile = [SELECT Id FROM Clinical_Trial_Profile__c];
        TravelVendor__c travelVendor = new TravelVendor__c(
            Name = 'Uber',
            Link_Vendor__c = 'link 1'
        );
        insert travelVendor;

        Test.startTest();
        TravelVendorPanelRemote.InitData initData = TravelVendorPanelRemote.getInitData(
            clinicalTrialProfile.Id
        );
        TravelVendorPanelRemote.selectAllInColumn(
            travelVendor.Id,
            true,
            JSON.serialize(initData.filter),
            JSON.serialize(new PaginationData(15)),
            JSON.serialize(initData.searchResponse.studySiteItems)
        );
        Test.stopTest();
    }

    @IsTest
    static void clearAllInColumn_test() {
        TestData td = new TestData();
        TravelVendor__c travelVendor = new TravelVendor__c(
            Name = 'Uber',
            Link_Vendor__c = 'link 1'
        );
        insert travelVendor;

        Test.startTest();
        TravelVendorPanelRemote.InitData initData = TravelVendorPanelRemote.getInitData(td.ctp.Id);
        System.debug(JSON.serializePretty(initData.searchResponse.studySiteItems));
        TravelVendorPanelRemote.selectAllInColumn(
            travelVendor.Id,
            false,
            JSON.serialize(initData.filter),
            JSON.serialize(new PaginationData(15)),
            JSON.serialize(initData.searchResponse.studySiteItems)
        );
        Test.stopTest();
    }

    @IsTest
    static void getVendors_test() {
        TestData testDataInstance = new TestData();
        testDataInstance.createSSTravelVendors();
        Test.startTest();
        List<TravelVendor__c> vendorSettings;
        System.runAs(testDataInstance.participantUser) {
            vendorSettings = TravelSupportRemote.getAvailableVendorsForSS();
        }
        Test.stopTest();
        System.assertEquals(1, vendorSettings.size());
    }

    @IsTest
    static void getVendorsWithException_test() {
        Boolean isExceptionThrown = false;
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(
            TravelSupportHelper.class,
            StubBuilder.newInstance(TravelSupportHelper.class)
                .when('getVendors')
                .then(new AuraHandledException('error'))
                .build()
        );

        Test.startTest();
        try {
            TravelSupportRemote.getAvailableVendorsForSS();
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
