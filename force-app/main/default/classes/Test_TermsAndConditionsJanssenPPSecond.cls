@IsTest(IsParallel=false)
private  class Test_TermsAndConditionsJanssenPPSecond {
 @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        TestData.createTCAcceptance();
        Test.stopTest();
    }
    
    
    
    @isTest
    static void testGetPortalTCalt() {
        TestData testData = new TestData();
        Terms_And_Conditions__c studyTC = [
            SELECT Id
            FROM Terms_And_Conditions__c
            WHERE Active__c != TRUE
        ];
        Terms_And_Conditions__c ppTC = [
            SELECT Id,Name
            FROM Terms_And_Conditions__c
            WHERE T_C_Type__c = 'Privacy Policy'
        ];
        ContentVersion content=new ContentVersion(); 
        content.Title='PrivacyPolicy'; 
        content.PathOnClient='PrivacyPolicy.pdf';
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        content.ContentLocation = 'S';
        content.Description = ppTC.Name; 
        insert content;
        ContentDistribution cdist = new ContentDistribution(
                                        Name = content.Title,
                                        ContentVersionId = content.Id
                                        );
        insert cdist;
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = ppTC.Id; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = [select ContentDocumentId from ContentVersion where id =: content.id].ContentDocumentId;
        conDocLink.Visibility = 'AllUsers';
        insert conDocLink;	
        Terms_And_Conditions__c ppTc1 = new Terms_And_Conditions__c(
                Active__c = true,
                Community_Name__c = 'Janssen Community',
                Language__c = 'en_US',
                Last_Updated_on__c = 'July 10, 2020',
                Policy_Headers__c = 'Test Header 1',
                T_C_Text__c = '<p><b style="font-size: 12pt; font-family: Arial, sans-serif; color: rgb(0, 0, 0);">PRIVACY POLICY</b></p>',
                T_C_Type__c = 'Terms and Conditions',
            	Janssen_Template__c ='2.0'
                 
        	);
    		insert ppTc1;
            Clinical_Trial_Profile__c ctp = [SELECT Id,Terms_And_Conditions_ID__c FROM Clinical_Trial_Profile__c WHERE Id =:testData.ctp.Id LIMIT 1];
            Terms_And_Conditions__c tc = new Terms_And_Conditions__c();
            tc.Master_Terms_And_Conditions__c = ppTc1.Id;
            tc.Id = ctp.Terms_And_Conditions_ID__c;
        	update tc;
        Test.startTest();
        System.runAs(testData.hcpUser) {
            StudyListViewController.getStudyTrialList(CommunityService.USER_MODE_HCP);
            StudyDetailViewController.getTrialDetail(
                testData.ctp.Id,
                CommunityService.USER_MODE_HCP
            );

            //update tc;
            TermsAndConditionsJanssenPPSecond.getOrgDefaultPPTC(true, null);
            TermsAndConditionsJanssenPPSecond.getOrgDefaultPPTC(true, null);
        }
        Test.stopTest();
    }    
    
    @isTest
    static void testGetPortalTC() {
        TestData testData = new TestData();
        Terms_And_Conditions__c studyTC = [
            SELECT Id
            FROM Terms_And_Conditions__c
            WHERE Active__c != TRUE
        ];
        Terms_And_Conditions__c ppTC = [
            SELECT Id,Name
            FROM Terms_And_Conditions__c
            WHERE T_C_Type__c = 'Privacy Policy'
        ];
        ContentVersion content=new ContentVersion(); 
        content.Title='PrivacyPolicy'; 
        content.PathOnClient='PrivacyPolicy.pdf';
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        content.ContentLocation = 'S';
        content.Description = ppTC.Name; 
        insert content;
        ContentDistribution cdist = new ContentDistribution(
                                        Name = content.Title,
                                        ContentVersionId = content.Id
                                        );
        insert cdist;
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = ppTC.Id; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = [select ContentDocumentId from ContentVersion where id =: content.id].ContentDocumentId;
        conDocLink.Visibility = 'AllUsers';
        insert conDocLink;
        Test.startTest();
        System.runAs(testData.hcpUser) {
            StudyListViewController.getStudyTrialList(CommunityService.USER_MODE_HCP);
            StudyDetailViewController.getTrialDetail(
                testData.ctp.Id,
                CommunityService.USER_MODE_HCP
            );
            AccountSettingsController.getInitData(CommunityService.USER_MODE_PI);
            TermsAndConditionsJanssenPPSecond.getPortalTC(false);
            TermsAndConditionsJanssenPPSecond.getTrialTC(testData.ctp.Id);
            TermsAndConditionsJanssenPPSecond.isTCAccepted(studyTC.Id);
            TermsAndConditionsJanssenPPSecond.getOrgDefaultCookieTC();
            TermsAndConditionsJanssenPPSecond.getCookieTC(false);
            
            TermsAndConditionsJanssenPPSecond.getOrgDefaultPrivacyTC(false);
            TermsAndConditionsJanssenPPSecond.getOrgDefaultTCbyCode('CookiePolicy');
            
            List<HelpController.FileContainer> files = new List<HelpController.FileContainer>();
            HelpController.FileContainer file = new HelpController.FileContainer();
            file.base64Data = EncodingUtil.base64Encode(Blob.valueOf('Test file'));
            file.fileName = 'some.txt';
            file.contentType = 'text/plain';
            HelpController.createCase(
                'Some case',
                'Seme Description',
                'Question',
                'Low',
                'Some Reason',
                JSON.serialize(files),
                false,
                false
            );
            InfoModalController.getHCPEnrollmentHistory(testData.hcpEnrollment.Id);
            InfoModalController.getStudySiteHistory(testData.ss.Id);
        }
        Test.stopTest();
    }


    @isTest
    static void testGetPortalDefaultTC() {
        TestData testData = new TestData();
        Test.startTest();
        Terms_And_Conditions__c pp = new Terms_And_Conditions__c();
        pp.Active__c = TRUE; 
        pp.Community_Name__c ='Janssen Community';
        pp.Janssen_Template__c ='2.0';
        pp.T_C_Type__c ='Privacy Policy';
        insert pp;
        Terms_And_Conditions__c pp2 = new Terms_And_Conditions__c();
        pp2.Master_Terms_And_Conditions__c = pp.Id;
        pp2.Language__c = 'en_US';
        insert pp2;
        String query;
        System.runAs(testData.hcpUser) {  
            query = '@Arm'+TermsAndConditionsJanssenPPSecond.getTCQuery(null, null, TermsAndConditionsJanssenPPSecond.PRIVACY_POLICY, false);
            TermsAndConditionsJanssenPPSecond.getOrgDefaultPrivacyTC(false);
            TermsAndConditionsJanssenPPSecond.getOrgDefaultPPTC(false, null);
        }
        system.debug(query);
        //System.assertEquals(query,'ans');
        Test.stopTest();
    }

    @isTest
    static void testGetPortalDefaultCookieTC() {
        TestData testData = new TestData();
        Test.startTest();
        Terms_And_Conditions__c pp = new Terms_And_Conditions__c();
        pp.Active__c = TRUE; 
        pp.Community_Name__c ='Janssen Community';
        pp.Janssen_Template__c ='2.0';
        pp.T_C_Type__c ='Cookie Policy';
        insert pp;
        Terms_And_Conditions__c pp2 = new Terms_And_Conditions__c();
        pp2.Master_Terms_And_Conditions__c = pp.Id;
        pp2.Language__c = 'en_US';
        insert pp2;
        String query;
        System.runAs(testData.hcpUser) {  
            TermsAndConditionsJanssenPPSecond.getCookieTC(false);
        }
        system.debug(query);
        //System.assertEquals(query,'ans');
        Test.stopTest();
    }
    

    
    @isTest
    static void testGetPortalTCtest() {
    Terms_And_Conditions__c ppTc = new Terms_And_Conditions__c(
            Active__c = true,
            Community_Name__c = 'IQVIA Referral Hub',
            Language__c = 'en_US',
            Last_Updated_on__c = 'July 10, 2020',
            Policy_Headers__c = 'Test Header 1',
            T_C_Text__c = '<p><b style="font-size: 12pt; font-family: Arial, sans-serif; color: rgb(0, 0, 0);">PRIVACY POLICY</b></p>',
            T_C_Type__c = 'Privacy Policy'
        );
    insert ppTc;
        test.startTest();
        TermsAndConditionsJanssenPPSecond.setOrgDefaultCookieTC(ppTc.Id);
        TermsAndConditionsJanssenPPSecond.setOrgDefaultPrivacyTC(ppTc.Id);
         test.stopTest();   
    }   
    
    
    @IsTest
    static void basePITest3() {
        TestData testData = new TestData();
        Terms_And_Conditions__c studyTC = [
            SELECT Id
            FROM Terms_And_Conditions__c
            WHERE Active__c != TRUE
        ];
        Test.startTest();
        System.runAs(testData.piUser) {
            TermsAndConditionsJanssenPPSecond.acceptTC(studyTC.Id);
            Action_ChangeHCPStatusByPIRemote.getEnrollmentReasonOptions();
            Action_ChangeHCPStatusByPIRemote.changeHCPEnrollmentStatus(
                testData.hcpEnrollment.Id,
                StudyActions.ACT_HCP_ON_HOLD,
                ''
            );
            Action_ChangeHCPStatusByPIRemote.changeHCPEnrollmentStatus(
                testData.hcpEnrollment.Id,
                StudyActions.ACT_HCP_ACTIVATE_FOR_ALL,
                ''
            );
            Action_ChangePEStatusByPIRemote.getReferralDeclineReasons();
            Action_ChangePEStatusByPIRemote.updatePE(
                JSON.serialize(testData.pe),
                PEStatusState.PE_STATUS_RECEIVED,
                '',
                ''
            );
        }
        Test.stopTest();
    }

   @IsTest
    static void basePitest4(){
        List<Clinical_Trial_Profile__c> listadd = new List<Clinical_Trial_Profile__c>();
        Clinical_Trial_Profile__c cctc = [
            SELECT Id,Protocol_ID__c,Terms_And_Conditions_ID__c,Override_Recruitment_Status__c,NCT_Number__c,Link_to_Pre_screening__c,
            Study_Title__c,Study_Code_Name__c,Suppress_Participant_Emails__c,Synch_with_TMDH__c,Include_in_RP_trial_search__c, Patient_Portal_Enabled__c,
            Shareback_Settings_On_Participant_Level__c,Shareback_Availability_Timing__c,Visit_Data_Shareback__c,Visit_Schedule_Is_Available__c,
            Tasks_Are_Available__c,Study_Documents_Are_Available__c,Video_And_Articles_Are_Available__c,Travel_Vendor_Is_Available__c,
            Relevant_Links_Are_Available__c,Sponsor_Pays_for_Referral_Activity__c,CommunityTemplate__c,Logged_Out_Days_Notification__c,
            Enable_for_Call_Center_Support__c
            FROM Clinical_Trial_Profile__c
        ];
        listadd.add(cctc);
        test.startTest();
        TermsAndConditionsJanssenPPSecond.getTrialsAcceptanceMap(listadd);
        test.stopTest();
    }
}