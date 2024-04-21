/**
 * Created by Nargiz Mamedova on 1/17/2020.
 */

@isTest
private with sharing class Test_MessageConfigurationPanelRemote {
    @TestSetup
    static void init(){
        TestData.loadTestData();
    }

    @IsTest
    static void getItems_test(){
        TestData td = new TestData();

        Test.startTest();
        MessageConfigurationPanelRemote.InitData initData = MessageConfigurationPanelRemote.getInitData(td.ctp.Id);
        MessageConfigurationPanelRemote.getItems(JSON.serialize(initData.searchResponse.studySiteItems), JSON.serialize(initData.filter), JSON.serialize(new PaginationData(15)));
        Test.stopTest();
    }

    @IsTest
    static void selectAllInColumn_test(){
        TestData td = new TestData();

        Test.startTest();
        MessageConfigurationPanelRemote.InitData initData = MessageConfigurationPanelRemote.getInitData(td.ctp.Id);
        MessageConfigurationPanelRemote.selectAllInColumn(true, JSON.serialize(initData.filter), JSON.serialize(new PaginationData(15)), JSON.serialize(initData.searchResponse.studySiteItems), SSMessageConfigResponse.TYPE_SMS);
        Test.stopTest();
    }

    @IsTest
    static void clearAllInColumn_test(){
        TestData td = new TestData();

        Test.startTest();
        MessageConfigurationPanelRemote.InitData initData = MessageConfigurationPanelRemote.getInitData(td.ctp.Id);
        System.debug(JSON.serializePretty(initData.searchResponse.studySiteItems));
        MessageConfigurationPanelRemote.selectAllInColumn(false, JSON.serialize(initData.filter), JSON.serialize(new PaginationData(15)), JSON.serialize(initData.searchResponse.studySiteItems), SSMessageConfigResponse.TYPE_MESSAGE);
        Test.stopTest();
    }

    @IsTest
    static void getInitDataWithException_test() {
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            MessageConfigurationPanelRemote.getInitData(null);
        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }
}