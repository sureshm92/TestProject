/**
 * Created by Krivo on 26.10.2019.
 */

@IsTest
private class Test_VisitResultSharingPanelRemote {
    @TestSetup
    static void testAll() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @isTest
    static void testVisitSharingPanelMethods() {
        TestData testData = new TestData();
        Test.startTest();

        List<Visit_Result_Type_Sharing__c> visitResultTypeSharings = new List<Visit_Result_Type_Sharing__c>();
        visitResultTypeSharings.add(
            new Visit_Result_Type_Sharing__c(
                Type__c = 'BUN',
                Sharing_Countries__c = 'All',
                Include_Countries__c = false,
                Clinical_Trial_Profile__c = testData.ctp.Id
            )
        );
        visitResultTypeSharings.add(
            new Visit_Result_Type_Sharing__c(
                Type__c = 'Potassium',
                Sharing_Countries__c = 'FR',
                Include_Countries__c = true,
                Clinical_Trial_Profile__c = testData.ctp.Id
            )
        );
        visitResultTypeSharings.add(
            new Visit_Result_Type_Sharing__c(
                Type__c = 'Hemoglobin',
                Sharing_Countries__c = 'CA',
                Include_Countries__c = false,
                Clinical_Trial_Profile__c = testData.ctp.Id
            )
        );
        insert visitResultTypeSharings;

        TriggerHandlerExecutor.bypassHandler(
            ClinicalTrialProfileTriggerHandler.UpdateClinicalTrialProfile.class
        );
        TriggerHandlerExecutor.bypassHandler(
            CTPNotificationTriggerHandler.CreateNotificationHandler.class
        );
        testData.ctp.Shareback_Settings_on_StudySites__c = true;
        update testData.ctp;

        VisitResultSharingSSLookupRemote.searchSSByIds(testData.ss.Id, true, '');
        VisitResultSharingSSLookupRemote.searchSSByTerm(
            testData.ctp.Id,
            testData.ss.Name,
            '',
            true,
            ''
        );
        VisitResultSharingPanelRemote.InitData initData = VisitResultSharingPanelRemote.getInitData(
            testData.ctp.Id
        );
        VisitResultSharingPanelRemote.saveSharingRules(
            JSON.serialize(initData.options),
            JSON.serialize(initData.groups),
            testData.ctp.Id
        );

        testData.ctp.Shareback_Settings_On_Country_Level__c = true;
        testData.ss.Visit_Results_Sharing__c = true;
        update testData.ctp;
        update testData.ss;

        initData = VisitResultSharingPanelRemote.getInitData(testData.ctp.Id);
        VisitResultSharingPanelRemote.VisitResultGroupWrapper groupWrapper = new VisitResultSharingPanelRemote.VisitResultGroupWrapper();
        groupWrapper.visitResults = new List<VisitResultSharingPanelRemote.VisitResultWrapper>();
        groupWrapper.visitResults.add(
            new VisitResultSharingPanelRemote.VisitResultWrapper(
                'Weight',
                'Weight',
                'Countries',
                'CA',
                'WeightDes',
                'WeightDesLabel',
                'Test',
                true
            )
        );
        groupWrapper.visitResults.add(
            new VisitResultSharingPanelRemote.VisitResultWrapper(
                'BUN',
                'BUN',
                'Disabled',
                '',
                'BUNDes',
                'BUNDesLabel',
                'Test',
                true
            )
        );
        initData.groups.add(groupWrapper);
        VisitResultSharingPanelRemote.saveSharingRules(
            JSON.serialize(initData.options),
            JSON.serialize(initData.groups),
            testData.ctp.Id
        );

        testData.ctp.Shareback_Settings_on_StudySites__c = false;
        update testData.ctp;

        initData = VisitResultSharingPanelRemote.getInitData(testData.ctp.Id);

        testData.ctp.Visit_Data_Shareback__c = false;
        update testData.ctp;

        initData = VisitResultSharingPanelRemote.getInitData(testData.ctp.Id);
        VisitResultSharingPanelRemote.saveSharingRules(
            JSON.serialize(initData.options),
            JSON.serialize(initData.groups),
            testData.ctp.Id
        );

        Clinical_Trial_Profile__c testCTP = [
            SELECT Id, Visit_Data_Shareback__c
            FROM Clinical_Trial_Profile__c
            WHERE Id = :testData.ctp.Id
        ];
        Study_Site__c testSS = [
            SELECT Id, Visit_Results_Sharing__c
            FROM Study_Site__c
            WHERE Id = :testData.ss.Id
        ];
        Test.stopTest();

        System.assertEquals(false, testCTP.Visit_Data_Shareback__c);
        System.assertEquals(false, testSS.Visit_Results_Sharing__c);
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
