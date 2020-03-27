/**
 * Created by Krivo on 26.10.2019.
 */

@IsTest
private class Test_VisitResultSharingPanelRemote {

    @IsTest
    static void testAll() {
        TestData.loadTestData();
        TestData testData = new TestData();

        List<Visit_Result_Type_Sharing__c> visitResultTypeSharings = new List<Visit_Result_Type_Sharing__c>();
        visitResultTypeSharings.add(new Visit_Result_Type_Sharing__c(
                Type__c = 'BUN',
                Sharing_Countries__c = 'All',
                Include_Countries__c = false,
                Clinical_Trial_Profile__c = testData.ctp.Id
        ));
        visitResultTypeSharings.add(new Visit_Result_Type_Sharing__c(
                Type__c = 'Potassium',
                Sharing_Countries__c = 'FR',
                Include_Countries__c = true,
                Clinical_Trial_Profile__c = testData.ctp.Id
        ));
        visitResultTypeSharings.add(new Visit_Result_Type_Sharing__c(
                Type__c = 'Hemoglobin',
                Sharing_Countries__c = 'CA',
                Include_Countries__c = false,
                Clinical_Trial_Profile__c = testData.ctp.Id
        ));
        insert visitResultTypeSharings;

        testData.ctp.Shareback_Settings_on_StudySites__c = true;
        update testData.ctp;

        Test.startTest();
        VisitResultSharingSSLookupRemote.searchSSByIds(testData.ss.Id, true, '');
        VisitResultSharingSSLookupRemote.searchSSByTerm(testData.ctp.Id, testData.ss.Name, '', true, '');
        VisitResultSharingPanelRemote.InitData initData = VisitResultSharingPanelRemote.getInitData(testData.ctp.Id);
        VisitResultSharingPanelRemote.saveSharingRules(JSON.serialize(initData.options), JSON.serialize(initData.groups), testData.ctp.Id);

        testData.ctp.Shareback_Settings_On_Country_Level__c = true;
        testData.ss.Visit_Results_Sharing__c = true;
        update testData.ctp;
        update testData.ss;

        initData = VisitResultSharingPanelRemote.getInitData(testData.ctp.Id);
        VisitResultSharingPanelRemote.VisitResultGroupWrapper groupWrapper = new VisitResultSharingPanelRemote.VisitResultGroupWrapper();
        groupWrapper.visitResults = new List<VisitResultSharingPanelRemote.VisitResultWrapper>();
        groupWrapper.visitResults.add(new VisitResultSharingPanelRemote.VisitResultWrapper('Weight', 'Weight', 'Countries', 'CA'));
        groupWrapper.visitResults.add(new VisitResultSharingPanelRemote.VisitResultWrapper('BUN', 'BUN', 'Disabled', ''));
        initData.groups.add(groupWrapper);
        VisitResultSharingPanelRemote.saveSharingRules(JSON.serialize(initData.options), JSON.serialize(initData.groups), testData.ctp.Id);

        testData.ctp.Shareback_Settings_on_StudySites__c = false;
        update testData.ctp;

        initData = VisitResultSharingPanelRemote.getInitData(testData.ctp.Id);

        testData.ctp.Visit_Data_Shareback__c = false;
        update testData.ctp;

        initData = VisitResultSharingPanelRemote.getInitData(testData.ctp.Id);
        VisitResultSharingPanelRemote.saveSharingRules(JSON.serialize(initData.options), JSON.serialize(initData.groups), testData.ctp.Id);
        Test.stopTest();
    }

    @IsTest
    static void getInitDataWithException_test() {
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            VisitResultSharingPanelRemote.getInitData(null);
        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }

    @IsTest
    static void saveSharingRulesWithException_test() {
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            VisitResultSharingPanelRemote.saveSharingRules(null, null, null);
        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }
}