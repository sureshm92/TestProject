/**
 * Created by Nargiz Mamedova on 1/17/2020.
 */

@IsTest
private with sharing class Test_PaymentVendorPanelRemote {
    @TestSetup
    static void init(){
        TestData.loadTestData();
    }

    @IsTest
    static void getItems_test(){
        TestData td = new TestData();

        Test.startTest();
        PaymentVendorPanelRemote.InitData initData = PaymentVendorPanelRemote.getInitData(td.ctp.Id);
        PaymentVendorPanelRemote.getItems(JSON.serialize(initData.searchResponse.studySiteItems), JSON.serialize(initData.filter), JSON.serialize(new PaginationData(15)));
        Test.stopTest();
    }

    @IsTest
    static void selectAllInColumn_test(){
        TestData td = new TestData();
        Payment_Vendor__c paymentVendor = new Payment_Vendor__c(Name = 'Qiwi', Link_Vendor__c = 'link 1');
        insert paymentVendor;

        Test.startTest();
        PaymentVendorPanelRemote.InitData initData = PaymentVendorPanelRemote.getInitData(td.ctp.Id);
        PaymentVendorPanelRemote.selectAllInColumn(paymentVendor.Id, true, JSON.serialize(initData.filter), JSON.serialize(new PaginationData(15)), JSON.serialize(initData.searchResponse.studySiteItems));
        Test.stopTest();
    }

    @IsTest
    static void clearAllInColumn_test(){
        TestData td = new TestData();
        Payment_Vendor__c paymentVendor = new Payment_Vendor__c(Name = 'Qiwi', Link_Vendor__c = 'link 1');
        insert paymentVendor;

        Test.startTest();
        PaymentVendorPanelRemote.InitData initData = PaymentVendorPanelRemote.getInitData(td.ctp.Id);
        System.debug(JSON.serializePretty(initData.searchResponse.studySiteItems));
        PaymentVendorPanelRemote.selectAllInColumn(paymentVendor.Id, false, JSON.serialize(initData.filter), JSON.serialize(new PaginationData(15)), JSON.serialize(initData.searchResponse.studySiteItems));
        Test.stopTest();
    }

    @IsTest
    static void getInitDataWithException_test() {
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            PaymentVendorPanelRemote.getInitData(null);
        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }
}