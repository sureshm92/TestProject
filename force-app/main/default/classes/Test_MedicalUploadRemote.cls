@IsTest
private with sharing class Test_MedicalUploadRemote {
    @TestSetup
    static void init(){
        TestData.loadTestData();
    }
    
    @IsTest
    static void getInitData_test() {
        TestData td = new TestData();
        Clinical_Trial_Profile__c clinicalTrialProfile = [SELECT Id FROM Clinical_Trial_Profile__c];
        Study_Site__c studySite = [SELECT Id FROM Study_Site__c];
        Test.startTest();
        MedicalRecordUploadRemote.InitData initData = MedicalRecordUploadRemote.getInitData(td.ctp.Id);
        Test.stopTest();
    }

    @IsTest
    static void getItems_test(){
        TestData td = new TestData();
        Clinical_Trial_Profile__c clinicalTrialProfile = [SELECT Id FROM Clinical_Trial_Profile__c];

        Test.startTest();
        MedicalRecordUploadRemote.InitData initData = MedicalRecordUploadRemote.getInitData(clinicalTrialProfile.Id);
        MedicalRecordUploadRemote.getItems(JSON.serialize(initData.searchResponse.studySiteItems), JSON.serialize(initData.filter), JSON.serialize(new PaginationData(15)));
        Test.stopTest();
    }
    
    @IsTest
    static void selectAllInColumn_test(){
        TestData td = new TestData();
        Clinical_Trial_Profile__c clinicalTrialProfile = [SELECT Id FROM Clinical_Trial_Profile__c];
        Medical_Record_Vendor__c medicalVendor = new Medical_Record_Vendor__c(Name = 'Rybr');
        insert medicalVendor;

        Test.startTest();
        MedicalRecordUploadRemote.InitData initData = MedicalRecordUploadRemote.getInitData(clinicalTrialProfile.Id);
        MedicalRecordUploadRemote.selectAllInColumn(medicalVendor.Id, true, JSON.serialize(initData.filter), JSON.serialize(new PaginationData(15)), JSON.serialize(initData.searchResponse.studySiteItems));
        Test.stopTest();
    }

    @IsTest
    static void clearAllInColumn_test(){
        TestData td = new TestData();
        Medical_Record_Vendor__c medicalVendor = new Medical_Record_Vendor__c(Name = 'Ruby Hospital');
        insert medicalVendor;

        Test.startTest();
        MedicalRecordUploadRemote.InitData initData = MedicalRecordUploadRemote.getInitData(td.ctp.Id);
        System.debug(JSON.serializePretty(initData.searchResponse.studySiteItems));
        MedicalRecordUploadRemote.selectAllInColumn(medicalVendor.Id, false, JSON.serialize(initData.filter), JSON.serialize(new PaginationData(15)), JSON.serialize(initData.searchResponse.studySiteItems));
        Test.stopTest();
    }

    


    

}