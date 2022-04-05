@isTest
public with sharing class BioMarkerRecordControllerTest {
    @testSetup
    public static void testData(){
        TestData.loadTestData();
         Participant_Enrollment__c objpart = [SELECT ID FROM Participant_Enrollment__c 
                                              WHERE  Screening_ID__c = 'PESCR3' limit 1];
        Participant_Enrollment__c objpart2 = [SELECT ID FROM Participant_Enrollment__c 
                                              WHERE  Screening_ID__c = 'PESCR5' limit 1];
        List<RH_Biomarker__c> lstBioMarker = new list<RH_Biomarker__c> ();
        List<Biomarker_Result__c> lstBioMarkerResult = new list<Biomarker_Result__c> ();
        RH_Biomarker__c objBimarker1 = new RH_Biomarker__c(Assessed_on_datetime__c = '2021-01-20 16:00:00 PM',
        Assessed_On__c = datetime.newInstance(2021, 01, 20, 16, 00, 0),
        Participant_Enrollment__c = objpart.id,
        Referral__c = true,Vendor_Source__c='KI');
        lstBioMarker.add(objBimarker1);

        RH_Biomarker__c objBimarker2 = new RH_Biomarker__c(Assessed_on_datetime__c = '2021-01-20 16:00:00 PM',
        Assessed_On__c = datetime.newInstance(2021, 01, 20, 16, 00, 0),
        Participant_Enrollment__c = objpart.id,
        Referral__c = true,Vendor_Source__c='ePR');
        lstBioMarker.add(objBimarker2);

        RH_Biomarker__c objBimarker3 = new RH_Biomarker__c(Assessed_on_datetime__c = '2021-01-20 16:00:00 PM',
        Assessed_On__c = datetime.newInstance(2021, 01, 20, 16, 00, 0),
        Participant_Enrollment__c = objpart2.id,
        Referral__c = true,Vendor_Source__c='KI');
        lstBioMarker.add(objBimarker3);
        
        insert lstBioMarker ;
        
        Biomarker_Result__c objResule1 = new Biomarker_Result__c(Key__c='cdr_sob',Value__c='0.5',Biomarker__c = objBimarker1.id);
        lstBioMarkerResult.add(objResule1);
         Biomarker_Result__c objResule2 = new Biomarker_Result__c(Key__c='hc_mci_d_traditional',Value__c='dementia',Biomarker__c = objBimarker1.id);
        lstBioMarkerResult.add(objResule2);
         Biomarker_Result__c objResule3 = new Biomarker_Result__c(Key__c='cdr_sob',Value__c='0.99',Biomarker__c = objBimarker1.id);
        lstBioMarkerResult.add(objResule3);
         Biomarker_Result__c objResule4 = new Biomarker_Result__c(Key__c='cdr_sob',Value__c='0.11',Biomarker__c = objBimarker2.id);
        lstBioMarkerResult.add(objResule4);
         Biomarker_Result__c objResule5 = new Biomarker_Result__c(Key__c='cdr_sob',Value__c='0.23',Biomarker__c = objBimarker2.id);
        lstBioMarkerResult.add(objResule5);
         Biomarker_Result__c objResule6 = new Biomarker_Result__c(Key__c='hc_mci_d_traditional',Value__c='dementia',Biomarker__c = objBimarker3.id);
        lstBioMarkerResult.add(objResule6);
        
        insert lstBioMarkerResult ;

        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'testFile.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        contentVersionList.add(contentVersion);   
        
        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'testFile.mp3',
            VersionData = Blob.valueOf('Test Content sadas'),
            IsMajorVersion = true
        );
        contentVersionList.add(contentVersion2);
        
        insert contentVersionList;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        system.debug('documents:'+documents);
        
        List<ContentDocumentLink> contentDocList = new List<ContentDocumentLink>();
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = lstBioMarker[0].id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        cdl.Visibility = 'AllUsers';
        contentDocList.add(cdl);

        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = lstBioMarker[0].id;
        cdl1.ContentDocumentId = documents[1].Id;
        cdl1.shareType = 'V';
        cdl1.Visibility = 'AllUsers';
        contentDocList.add(cdl1);

        insert contentDocList;         
    }
    
    @istest
    public static void testGetAssessedDateForPE(){
        test.startTest();
        Participant_Enrollment__c objpart = [SELECT ID FROM Participant_Enrollment__c 
                                              WHERE  Screening_ID__c = 'PESCR3' limit 1];
        BioMarkerRecordController.bioMarkerWrapper objwrapper = BioMarkerRecordController.getAssessedDateForPE(objpart.Id);
        system.assert(objwrapper.mapBiomarkerKeyValue.size()>0);
        test.stopTest();
        
    }
    @isTest
    public static void testGetRelatedMediaFiles() {
        test.startTest();
        Participant_Enrollment__c objpart = [SELECT ID FROM Participant_Enrollment__c 
                                              WHERE  Screening_ID__c = 'PESCR3' limit 1];
        BioMarkerRecordController.MediaFileWrapper[] mediaFileWrapper = BioMarkerRecordController.getRelatedMediaFiles(objpart.Id,'2021-01-20 16:00:00 PM');
        system.assert(mediaFileWrapper.size()>0);
        test.stopTest();
    }
}
