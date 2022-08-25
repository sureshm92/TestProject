@IsTest
public class Test_IntegrationBioMarkerBatchDeletion {
	@TestSetup
    static void init(){
        TestData.loadTestData();
    }
    @IsTest
    static void testIntBioMarkerBatchDel_False() {
        List<Study_Site__c> testStudySites = [SELECT Id,Clinical_Trial_Profile__c,Site__c FROM Study_Site__c Limit 1];
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=testStudySites[0].Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test HCP');
        insert studClTest;
        Datetime myDate = Datetime.newInstance(2022, 12, 1, 12, 30, 2);
        Integration_Biomarker__c biomarkRec = new Integration_Biomarker__c();
        biomarkRec.Data_JSON1__c = '{ "referral_id": "123-4560","referral_language": "en US", "referral_country": "Germany", "site_id": "1235", "protocol_id": "1235", "referral_auto_dialer_consent": "2021-01-12T00:00:00+00:00", "user_feedback": "76"}';
        biomarkRec.Result_JSON1__c = '{"cdr_sob": 0.5, "hc_mci_d_traditional": "dementia", "hc_mci_ml_based": "no-mci", "referral": true}';
        biomarkRec.Assessed_On__c = myDate;
        biomarkRec.BiomarkerVendorReachoutStatus__c = 'Success';
        biomarkRec.Vendor_Source__c = 'KI';
        insert biomarkRec;
		List<RH_Biomarker__c> lstBioMarker = new list<RH_Biomarker__c> ();
        for(Participant_Enrollment__c peRec:[SELECT Id FROM Participant_Enrollment__c limit 10]){
            RH_Biomarker__c objBimarker1 = new RH_Biomarker__c(Assessed_on_datetime__c = '2021-01-20 16:00:00 PM',
            Assessed_On__c = datetime.newInstance(2021, 01, 20, 16, 00, 0),
            Participant_Enrollment__c = peRec.id,
            Integration_Biomarker__c=biomarkRec.Id,                                     
            Referral__c = true,Vendor_Source__c='KI');
        	lstBioMarker.add(objBimarker1);
        }
        insert lstBioMarker;
        Test.startTest();
		Database.executeBatch(new IntegrationBioMarkerBatchDeletion(testStudySites[0].Clinical_Trial_Profile__c,false),10);
        Test.stopTest();
        List<Integration_Biomarker__c> intBioMarkLst=[SELECT Id, Name from Integration_Biomarker__c where Vendor_Source__c='KI' limit 10];
        System.assertEquals(1,intBioMarkLst.size());
        
    }
    @IsTest
    static void testIntBioMarkerBatchDel_True() {
        List<Study_Site__c> testStudySites = [SELECT Id,Clinical_Trial_Profile__c,Site__c FROM Study_Site__c Limit 1];
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=testStudySites[0].Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test HCP');
        insert studClTest;
        Datetime myDate = Datetime.newInstance(2022, 12, 1, 12, 30, 2);
        Integration_Biomarker__c biomarkRec = new Integration_Biomarker__c();
        biomarkRec.Data_JSON1__c = '{ "referral_id": "123-4560","referral_language": "en US", "referral_country": "Germany", "site_id": "1235", "protocol_id": "1235", "referral_auto_dialer_consent": "2021-01-12T00:00:00+00:00", "user_feedback": "76"}';
        biomarkRec.Result_JSON1__c = '{"cdr_sob": 0.5, "hc_mci_d_traditional": "dementia", "hc_mci_ml_based": "no-mci", "referral": true}';
        biomarkRec.Assessed_On__c = myDate;
        biomarkRec.BiomarkerVendorReachoutStatus__c = 'Success';
        biomarkRec.Vendor_Source__c = 'KI';
        insert biomarkRec;
		List<RH_Biomarker__c> lstBioMarker = new list<RH_Biomarker__c> ();
        for(Participant_Enrollment__c peRec:[SELECT Id FROM Participant_Enrollment__c limit 10]){
            RH_Biomarker__c objBimarker1 = new RH_Biomarker__c(Assessed_on_datetime__c = '2021-01-20 16:00:00 PM',
            Assessed_On__c = datetime.newInstance(2021, 01, 20, 16, 00, 0),
            Participant_Enrollment__c = peRec.id,
            Integration_Biomarker__c=biomarkRec.Id,                                     
            Referral__c = true,Vendor_Source__c='KI');
        	lstBioMarker.add(objBimarker1);
        }
        insert lstBioMarker;
        Test.startTest();
		Database.executeBatch(new IntegrationBioMarkerBatchDeletion(testStudySites[0].Clinical_Trial_Profile__c,true),10);
        Test.stopTest();
        List<Integration_Biomarker__c> intBioMarkLst=[SELECT Id, Name from Integration_Biomarker__c where Vendor_Source__c='KI' limit 10];
        System.assertEquals(0,intBioMarkLst.size());
        
    }
    @IsTest
    static void testIntBioMarkerFileBatchDel_False() {
        List<Study_Site__c> testStudySites = [SELECT Id,Clinical_Trial_Profile__c,Site__c FROM Study_Site__c Limit 1];
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=testStudySites[0].Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test HCP');
        insert studClTest;
        Datetime myDate = Datetime.newInstance(2022, 12, 1, 12, 30, 2);
        Integration_Biomarker__c biomarkRec = new Integration_Biomarker__c();
        biomarkRec.Data_JSON1__c = '{ "referral_id": "123-4560","referral_language": "en US", "referral_country": "Germany", "site_id": "1235", "protocol_id": "1235", "referral_auto_dialer_consent": "2021-01-12T00:00:00+00:00", "user_feedback": "76"}';
        biomarkRec.Result_JSON1__c = '{"cdr_sob": 0.5, "hc_mci_d_traditional": "dementia", "hc_mci_ml_based": "no-mci", "referral": true}';
        biomarkRec.Assessed_On__c = myDate;
        biomarkRec.BiomarkerVendorReachoutStatus__c = 'Success';
        biomarkRec.Vendor_Source__c = 'KI';
        insert biomarkRec;
		List<RH_Biomarker__c> lstBioMarker = new list<RH_Biomarker__c> ();
        for(Participant_Enrollment__c peRec:[SELECT Id FROM Participant_Enrollment__c limit 10]){
            RH_Biomarker__c objBimarker1 = new RH_Biomarker__c(Assessed_on_datetime__c = '2021-01-20 16:00:00 PM',
            Assessed_On__c = datetime.newInstance(2021, 01, 20, 16, 00, 0),
            Participant_Enrollment__c = peRec.id,
            Integration_Biomarker__c=biomarkRec.Id,                                     
            Referral__c = true,Vendor_Source__c='KI');
        	lstBioMarker.add(objBimarker1);
        }
        insert lstBioMarker;
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test File BIO',
            PathOnClient = 'testFile.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        contentVersionList.add(contentVersion); 
        insert contentVersionList;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        List<ContentDocumentLink> contentDocList = new List<ContentDocumentLink>();
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = biomarkRec.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        cdl.Visibility = 'AllUsers';
        contentDocList.add(cdl);
        insert contentDocList;
        Test.startTest();
		Database.executeBatch(new IntegrationBioMarkerFileBatchDeletion(testStudySites[0].Clinical_Trial_Profile__c,false),10);
        Test.stopTest();
        List<ContentDocument> conDoc=[SELECT Id from ContentDocument where Title='Test File BIO'limit 5];
        System.assertEquals(1,conDoc.size());
        
    }
    @IsTest
    static void testIntBioMarkerFileBatchDel_True() {
        List<Study_Site__c> testStudySites = [SELECT Id,Clinical_Trial_Profile__c,Site__c FROM Study_Site__c Limit 1];
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=testStudySites[0].Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test HCP');
        insert studClTest;
        Datetime myDate = Datetime.newInstance(2022, 12, 1, 12, 30, 2);
        Integration_Biomarker__c biomarkRec = new Integration_Biomarker__c();
        biomarkRec.Data_JSON1__c = '{ "referral_id": "123-4560","referral_language": "en US", "referral_country": "Germany", "site_id": "1235", "protocol_id": "1235", "referral_auto_dialer_consent": "2021-01-12T00:00:00+00:00", "user_feedback": "76"}';
        biomarkRec.Result_JSON1__c = '{"cdr_sob": 0.5, "hc_mci_d_traditional": "dementia", "hc_mci_ml_based": "no-mci", "referral": true}';
        biomarkRec.Assessed_On__c = myDate;
        biomarkRec.BiomarkerVendorReachoutStatus__c = 'Success';
        biomarkRec.Vendor_Source__c = 'KI';
        insert biomarkRec;
		List<RH_Biomarker__c> lstBioMarker = new list<RH_Biomarker__c> ();
        for(Participant_Enrollment__c peRec:[SELECT Id FROM Participant_Enrollment__c limit 10]){
            RH_Biomarker__c objBimarker1 = new RH_Biomarker__c(Assessed_on_datetime__c = '2021-01-20 16:00:00 PM',
            Assessed_On__c = datetime.newInstance(2021, 01, 20, 16, 00, 0),
            Participant_Enrollment__c = peRec.id,
            Integration_Biomarker__c=biomarkRec.Id,                                     
            Referral__c = true,Vendor_Source__c='KI');
        	lstBioMarker.add(objBimarker1);
        }
        insert lstBioMarker;
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'testFile.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        contentVersionList.add(contentVersion); 
        insert contentVersionList;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        List<ContentDocumentLink> contentDocList = new List<ContentDocumentLink>();
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = biomarkRec.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        cdl.Visibility = 'AllUsers';
        contentDocList.add(cdl);
        insert contentDocList;
        Test.startTest();
		Database.executeBatch(new IntegrationBioMarkerFileBatchDeletion(testStudySites[0].Clinical_Trial_Profile__c,true),10);
        Test.stopTest();
        List<ContentDocument> conDoc=[SELECT Id from ContentDocument where Title='Test File BIO' limit 5];
        System.assertEquals(0,conDoc.size());
        
    }
}