@IsTest
private with sharing class Test_MedicalVendorRemote {
    @TestSetup
    static void init(){
        TestData.loadTestData();
    }
    
    @IsTest
    static void getInitData_test() {
        Test.startTest();
        TestData td = new TestData();
        Clinical_Trial_Profile__c clinicalTrialProfile = [SELECT Id FROM Clinical_Trial_Profile__c];
        Study_Site__c studySite = [SELECT Id FROM Study_Site__c];
        MedicalRecordVendorPanelRemote.InitData initData = MedicalRecordVendorPanelRemote.getInitData(td.ctp.Id);
        MedicalRecordVendorPanelRemote.getVendors(studySite.Id);
        Test.stopTest();
    }

    @IsTest
    static void getItems_test(){
        Test.startTest();
        TestData td = new TestData();
        Clinical_Trial_Profile__c clinicalTrialProfile = [SELECT Id FROM Clinical_Trial_Profile__c];

        MedicalRecordVendorPanelRemote.InitData initData = MedicalRecordVendorPanelRemote.getInitData(clinicalTrialProfile.Id);
        MedicalRecordVendorPanelRemote.getItems(JSON.serialize(initData.searchResponse.studySiteItems), JSON.serialize(initData.filter), JSON.serialize(new PaginationData(15)));
        Test.stopTest();
    }
    
    @IsTest
    static void selectAllInColumn_test(){
        Test.startTest();
        TestData td = new TestData();
        Clinical_Trial_Profile__c clinicalTrialProfile = [SELECT Id FROM Clinical_Trial_Profile__c];
        Medical_Record_Vendor__c medicalVendor = new Medical_Record_Vendor__c(Name = 'Rybr');
        insert medicalVendor;

        MedicalRecordVendorPanelRemote.InitData initData = MedicalRecordVendorPanelRemote.getInitData(clinicalTrialProfile.Id);
        MedicalRecordVendorPanelRemote.selectAllInColumn(medicalVendor.Id, true, JSON.serialize(initData.filter), JSON.serialize(new PaginationData(15)), JSON.serialize(initData.searchResponse.studySiteItems));
        MedicalRecordVendorPanelRemote.deleteMedicalVendor(medicalVendor.Id,JSON.serialize(initData.filter), JSON.serialize(new PaginationData(15)));
        Test.stopTest();
    }

    @IsTest
    static void clearAllInColumn_test(){
        Test.startTest();
        TestData td = new TestData();
        Medical_Record_Vendor__c medicalVendor = new Medical_Record_Vendor__c(Name = 'Ruby Hospital');
        insert medicalVendor;

        MedicalRecordVendorPanelRemote.InitData initData = MedicalRecordVendorPanelRemote.getInitData(td.ctp.Id);
        System.debug(JSON.serializePretty(initData.searchResponse.studySiteItems));
        MedicalRecordVendorPanelRemote.selectAllInColumn(medicalVendor.Id, false, JSON.serialize(initData.filter), JSON.serialize(new PaginationData(15)), JSON.serialize(initData.searchResponse.studySiteItems));
        Test.stopTest();
    }

    


    

}