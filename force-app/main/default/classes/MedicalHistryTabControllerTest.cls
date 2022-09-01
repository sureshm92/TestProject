@isTest
public with sharing class MedicalHistryTabControllerTest {

    @testSetup
    public static void testData(){
        TestData.loadTestData();    
        //TestData testData = new TestData();
        Clinical_Trial_Profile__c ctp = [
            SELECT
                Id,
                Therapeutic_Area__c,
                Study_Code_Name__c,
                Study_Title__c,
                Protocol_ID__c,
                Patient_Portal_Enabled__c,
                Terms_and_Conditions__c,
                Initial_Visit_Required__c,
                Participant_Workflow_Final_Step__c,
                Final_Consent_Required__c,
                Enable_for_Call_Center_Support__c,
                Medical_Vendor_is_Available__c
            FROM Clinical_Trial_Profile__c
            WHERE NCT_Number__c = 'NCT99999999'
        ];
        Participant_Enrollment__c per = [SELECT
        Id,
        Name,
        External_Key__c,
        Participant_Contact__c,
        Participant_Status__c,
        Participant_Contact__r.Visit_Results_OptIn__c,
        Initial_visit_scheduled_date__c,
        Initial_visit_occurred_date__c,
        Initial_visit_scheduled_time__c,
        Initial_visit_occurred_flag__c,
        Initial_visit_scheduled_flag__c,
        Screening_ID__c,
        Participant__c,
        Study_Site__c,
        Medical_Record_Review_Completed_Date__c,
        Study_Site__r.Principal_Investigator__c,
        Study_Site__r.Principal_Investigator__r.Name,
        Study_Site__r.Principal_Investigator__r.Title
    FROM Participant_Enrollment__c WHERE Clinical_Trial_Profile__c=:ctp.Id LIMIT 1];

        Medical_Record_Vendor__c vendor = new Medical_Record_Vendor__c();
        vendor.Name = 'Human API';
        vendor.Default_Country__c = 'US';
        vendor.Description__c = 'Test Description';
        vendor.Medical_Vendor__c = 'HumanApi';

        insert vendor;

        MedicalVendorSettings__c settings = new MedicalVendorSettings__c();
        settings.By_Country__c = false;
        settings.Is_Manual__c = false;
        settings.Study_Site__c = per.Study_Site__c;
        settings.Medical_Record_Vendor__c = vendor.Id;

        insert settings;

        ctp.Medical_Vendor_is_Available__c = true;

        byPassTriggersMethod();
        update ctp;
        List<RH_Biomarker__c> lstBioMarker = new list<RH_Biomarker__c> ();
        List<Biomarker_Result__c> lstBioMarkerResult = new list<Biomarker_Result__c> ();
        RH_Biomarker__c objBimarker1 = new RH_Biomarker__c(Assessed_on_datetime__c = '2021-01-20 16:00:00 PM',
        Assessed_On__c = datetime.newInstance(2021, 01, 20, 16, 00, 0),
        Participant_Enrollment__c = per.id,
        Referral__c = true,Vendor_Source__c='KI');
        lstBioMarker.add(objBimarker1);

        RH_Biomarker__c objBimarker2 = new RH_Biomarker__c(Assessed_on_datetime__c = '2021-01-20 16:00:00 PM',
        Assessed_On__c = datetime.newInstance(2021, 01, 20, 16, 00, 0),
        Participant_Enrollment__c = per.id,
        Referral__c = true,Vendor_Source__c='ePR');
        lstBioMarker.add(objBimarker2);

        insert lstBiomarker;

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

        insert lstBioMarkerResult;

        List<Comorbidities__c> comList = new List<Comorbidities__c>();
        Id recTypedId = Schema.SObjectType.Comorbidities__c.getRecordTypeInfosByName().get('Comorbidity').getRecordTypeId();
        Comorbidities__c comor = new Comorbidities__c();
        comor.Comorbidity_Name__c = 'cancer';
        comor.RecordTypeId = recTypedId;
        comList.add(comor);

        Comorbidities__c comor1 = new Comorbidities__c();
        comor1.Comorbidity_Name__c = 'BP';
        comor1.RecordTypeId = recTypedId;
        comList.add(comor1);

        Comorbidities__c comor2 = new Comorbidities__c();
        comor2.Comorbidity_Name__c = 'test';
        comor2.RecordTypeId = recTypedId;
        comList.add(comor2);

        insert comList;

    }

    @isTest
    static void testMedicalHistoryControllerDetails() {
        List<Participant_Enrollment__c> objpart = [SELECT Id,Participant__r.BMI__c,Comorbidities__c,HighRisk_Indicator__c,High_Priority__c,Referral_Source__c,Participant__c
        ,Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c,Study_Site__c,Unique_HumanId__c,MRR_Survey_Results_URL__c FROM Participant_Enrollment__c ];

        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        byPassTriggersMethod();
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
        cdl.LinkedEntityId = objpart[0].Participant__c;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        cdl.Visibility = 'AllUsers';
        contentDocList.add(cdl);

        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = objpart[1].Participant__c;
        cdl1.ContentDocumentId = documents[1].Id;
        cdl1.shareType = 'V';
        cdl1.Visibility = 'AllUsers';
        contentDocList.add(cdl1);
        
        insert contentDocList;
        Map<String,String> comMap = new Map<String,String>();
        List<Map<String,String>> comListMap = new List<Map<String,String>>();
        Map<String,String> comDelMap = new Map<String,String>();
        List<Map<String,String>> comDelListMap = new List<Map<String,String>>();
        List<Comorbidities__c> comList = [SELECT Id, Comorbidity_Name__c FROM Comorbidities__c];
       
        for(Comorbidities__c com : comList){
            if(com.Comorbidity_Name__c == 'cancer' || com.Comorbidity_Name__c == 'BP') {
                comMap.put('Id',com.Id);
                comMap.put('Comorbidity_Name__c',com.Comorbidity_Name__c);
                comListMap.add(comMap);
            } else {
                comDelMap.put('Id',com.Id);
                comDelMap.put('Comorbidity_Name__c',com.Comorbidity_Name__c);
                comDelListMap.add(comDelMap);
            }
        }
        String comString = JSON.serialize(comListMap);
        String comDelString = JSON.serialize(comDelListMap);
        System.debug('comString:'+comString);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HumanAPIcontrollerMock());
        MedicalHistryTabController.medicalHistryWrapper wrapper = new MedicalHistryTabController.medicalHistryWrapper();
        wrapper = MedicalHistryTabController.getPEDetails(objpart[0].Id);
        System.assertEquals(null,wrapper.BMI);
        MedicalHistryTabController.medicalHistryWrapper wrapper1 = new MedicalHistryTabController.medicalHistryWrapper();
        wrapper1 = MedicalHistryTabController.fetchfilterbiomarkerResult('2021-01-20 16:00:00 PM',objpart[0].Id);
        System.assert(wrapper1.lstBiomarkerResultWrapper.size()>0);
        MedicalHistryTabController.medicalHistryWrapper wrapper2 = new MedicalHistryTabController.medicalHistryWrapper();
        wrapper2 = MedicalHistryTabController.requestAuthorizeMedicalRecords(objpart[0].Id);
        System.assert(String.isNotBlank(wrapper2.strRequestMedicalReturn));
        List<Participant_Enrollment__History> history = MedicalHistryTabController.getEnrollmentRequestHistory(objpart[0].Id);
        System.assert(history.size()==0);
        //MedicalHistryTabController.getSurveyResponsecovid(objpart[0].Id);
        MedicalHistryTabController.medicalHistryWrapper wrapper3 = new MedicalHistryTabController.medicalHistryWrapper();
        MedicalHistryTabController.saveParticipantData('2.1',false,false,comString,'[]',objpart[0].Id);
        System.assert(wrapper3!= null);
        MedicalHistryTabController.saveParticipantData('2.1',false,true,comString,comDelString,objpart[0].Id);
        try{
            MedicalHistryTabController.saveParticipantData('2.1',false,true,comString,'',objpart[0].Id);
        }catch(Exception ex){}
        Test.stopTest();
    }

    @isTest
    static void testMedicalHistoryControllerDetails_Update() {
        List<Participant_Enrollment__c> objpart = [SELECT Id,Participant__r.BMI__c,Comorbidities__c,HighRisk_Indicator__c,High_Priority__c,Referral_Source__c,Participant__c
            ,Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c,Study_Site__c,Unique_HumanId__c,MRR_Survey_Results_URL__c FROM Participant_Enrollment__c ];

        objPart[0].HighRisk_Indicator__c = 'yes';
        byPassTriggersMethod();
        update objPart;
        Map<String,String> comMap = new Map<String,String>();
        List<Map<String,String>> comListMap = new List<Map<String,String>>();
        Map<String,String> comDelMap = new Map<String,String>();
        List<Map<String,String>> comDelListMap = new List<Map<String,String>>();
        List<Comorbidities__c> comList = [SELECT Id, Comorbidity_Name__c FROM Comorbidities__c];
        
        for(Comorbidities__c com : comList){
            if(com.Comorbidity_Name__c == 'cancer' || com.Comorbidity_Name__c == 'BP') {
                comMap.put('Id',com.Id);
                comMap.put('Comorbidity_Name__c',com.Comorbidity_Name__c);
                comListMap.add(comMap);
            } else {
                comDelMap.put('Id',com.Id);
                comDelMap.put('Comorbidity_Name__c',com.Comorbidity_Name__c);
                comDelListMap.add(comDelMap);
            }
        }
        String comString = JSON.serialize(comListMap);
        String comDelString = JSON.serialize(comDelListMap);
        Form_Results__c results = new Form_Results__c(
            Days_14_of_symptoms__c = true,
            Consent_to_store_info__c=true,
            Covid_19_Test_Date__c = System.today()-10,
            Positive_for_COVID_19__c=true,
            Participant_Enrollment__c=objpart[0].Id,
            Estimated_Date_of_first_symptom__c=System.today()-17,
            Estimated_date_of_last_symptom__c=System.today()+10
        );
        insert results;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HumanAPIcontrollerMock());
        MedicalHistryTabController.medicalHistryWrapper wrapper = new MedicalHistryTabController.medicalHistryWrapper();
        wrapper = MedicalHistryTabController.getPEDetails(objpart[0].Id);
        MedicalHistryTabController.saveParticipantData('',false,true,comString,comDelString,objpart[0].Id);
        String survey = MedicalHistryTabController.getSurveyResponsecovid(objpart[0].Id);   
        System.assert(String.isNotBlank(survey));     
        Test.stopTest();
    }

    static void byPassTriggersMethod() {
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.prepareAdditionalFields.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.UpdateParticipantInitialVisit.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateMissingStatuses.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SendFOVtoAPI.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.UnenrollorCancelPer.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PETriggerHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
        );        
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.CreateNotificationHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ClinicalTrialProfileTriggerHandler.UpdateClinicalTrialProfile.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.CreateWelcomeToStudyAlertHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.CreateUserForDelegateContactHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.CreateUserForCCContactHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.UpdateParticipantAndUserEmailsOnEmailChangeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.UpdateParticipantDetailsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.UpdatePEAndContactLastNameHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateTriggerHandler.CreatePrimaryDelegateForMinor.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateTriggerHandler.CreateNewAssignmentNotification.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContentDocumentLinkTriggerHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.changeUserEmailOnParticipantEmailChangehandlerType.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.UpdateNameOnPE.class
        );
    }
}