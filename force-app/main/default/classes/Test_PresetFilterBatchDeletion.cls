@IsTest
public class Test_PresetFilterBatchDeletion {
	@TestSetup
    static void init() {
        TestData.loadTestData();
    }
    @IsTest
    static void testPresetFilterBatchDelForSinglePF() {
        TestData testData = new TestData();
        
        Set<Id> ctpIds = new Set<Id>();
        Test.startTest();
        List<Clinical_Trial_Profile__c> ctpList = [SELECT Id FROM Clinical_Trial_Profile__c limit 1];
        List<Study_Site__c> ssList = [SELECT Id FROM Study_Site__c limit 1];
        Preset_Filter__c presetFilter = new Preset_Filter__c(
            User_Preset__c = testData.piUser.id,
            Source__c='test',
            Status__c='test',
            Ethnicity__c='test,test',
            StudyId__c=ctpList[0].id,
            Study_Site_Id__c=ssList[0].id,
            Default_Preset__c=true,
            Community_Name__c='Default'
            
        );
        insert presetFilter;
        Database.executeBatch(new PresetFilterBatchDeletion(ctpList[0].Id,true),10);
        Test.stopTest();
        List<Preset_Filter__c> presetLst=[SELECT Id from Preset_Filter__c where User_Preset__c=:testData.piUser.id];
        System.assertEquals(0,presetLst.size());
    }
    @IsTest
    static void testPresetFilterBatchDelForMultiplePF() {
        TestData testData = new TestData();
        
        Set<Id> ctpIds = new Set<Id>();
        Test.startTest();
        List<Clinical_Trial_Profile__c> ctpList = [SELECT Id FROM Clinical_Trial_Profile__c limit 1];
        List<Study_Site__c> ssList = [SELECT Id FROM Study_Site__c limit 1];
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=ctpList[0].Id,Clinical_Trial_Profile_Name__c='test booking');
        insert studClTest;
        Preset_Filter__c presetFilter = new Preset_Filter__c(
            User_Preset__c = testData.piUser.id,
            Source__c='test',
            Status__c='test',
            Ethnicity__c='test,test',
            StudyId__c=ctpList[0].id+';'+ctpList[0].id,
            Study_Site_Id__c=ssList[0].id+';'+ctpList[0].id,
            Default_Preset__c=true,
            Community_Name__c='Default'
            
        );
        insert presetFilter;
        /*Preset_Filter__c presetFilter1 = new Preset_Filter__c(
            User_Preset__c = testData.piUser.id,
            Source__c='test',
            Status__c='test',
            Ethnicity__c='test,test',
            StudyId__c=ctpList[0].id,
            Study_Site_Id__c=ssList[0].id,
            Default_Preset__c=true,
            Community_Name__c='Default'
            
        );
        insert presetFilter1;*/
        Database.executeBatch(new PresetFilterBatchDeletion(ctpList[0].Id,false),10);
        Test.stopTest();
        List<Preset_Filter__c> presetLst=[SELECT Id from Preset_Filter__c where User_Preset__c=:testData.piUser.id];
        System.assertEquals(1,presetLst.size());
    }
}