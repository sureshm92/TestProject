/**
 * Created by Nargiz Mamedova on 1/17/2020.
 */

@IsTest
private with sharing class Test_StudyConfigurationRemote {
    @TestSetup
    static void init(){
        TestData.loadTestData();
    }

    @IsTest
    static void saveChanges(){
        TestData td = new TestData();

        Test.startTest();
        StudyConfigurationRemote.InitData initData = StudyConfigurationRemote.getInitData(td.ctp.Id);
        initData.ctp.Relevant_Links_Are_Available__c = true;
        StudyConfigurationRemote.saveChanges(initData.ctp);

        List<LookupSearchResult> studySites = StudySiteSearchLookup.searchSSByTerm(td.ctp.Id, td.ss.Name, '', 'US');
        studySites = StudySiteSearchLookup.searchSSByIds(td.ss.Id);
        Test.stopTest();
    }

    @IsTest
    static void getInitDataWithException_test() {
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            StudyConfigurationRemote.getInitData(null);
        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }

    @IsTest
    static void saveChangesException_test() {
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            StudyConfigurationRemote.saveChanges(null);
        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }
}