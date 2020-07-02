//Created by Sumit/Sabir/Mari for Covid 19
public without sharing class CPDonorReferralFormController 
{
    public class FileUploadDataEntity
    {
        public String fileName{get;set;}
        public String base64Data{get;set;}
        public String contentType{get;set;}
    }
    
    public class InitData{
        @AuraEnabled public Clinical_Trial_Profile__c trial;
        @AuraEnabled public List<StudySiteService.StudySiteDistanceWrapper> studies;
        @AuraEnabled public List<AccountWrapper> markers;
        @AuraEnabled public Map<String, StudyActions.Action> actions;
        @AuraEnabled public List<LabelValueItem> countries;
        //public Map<String, List<LabelValueItem>> statesByCountryMap;
        @AuraEnabled public List<LabelValueItem> countriesLVList = CountryStateUtil.getCountries();
        @AuraEnabled public Map<String, List<LabelValueItem>> statesByCountryMap = CountryStateUtil.getStatesByCountryMap();
    }
    
    public class AccountWrapper{
       @AuraEnabled public Account clinic;
       @AuraEnabled public String name;
       @AuraEnabled public String addrStreet;
       @AuraEnabled public String addrCity;
       @AuraEnabled public String siteType;
       @AuraEnabled public Account ssAccount;
    }

    
    Public static Set<string> integrationPatientReferralIds = new Set<string>();
    //method to get study site details
    @AuraEnabled
    public static String getStudySites(String studyName)
    {
        String protocolId = System.Label.CPD_Protocol_ID; // 'C19NYBC'
        List<Study_Site__c> studySites = [Select Id, Name, Protocol_ID__c, Study_Site_Number__c, Clinical_Trial_Profile__r.Study_Code_Name__c,Site__r.BillingAddress,Site__r.BillingStreet,Site__r.BillingCity,Site__r.BillingCountry,Site__r.BillingPostalCode,Site__r.BillingState From Study_Site__c Where Clinical_Trial_Profile__r.Protocol_ID__c =: protocolId AND Study_Site_Number__c != null  AND Override_PI_Referral_Status__c ='Accepted'];
       /* Clinical_Trial_Profile__c ctp = [Select Id, Name, Protocol_ID__c From Clinical_Trial_Profile__c WHERE Protocol_ID__c = 'C19NYBC' ];
        InitData initData = new InitData();
        initData.trial = TrialService.getInstance().getTrialImpl(ctp.Id);
        
        StudySiteService.SiteFilterData siteFilterData = StudySiteService.getInstance().getSiteFilterDataImpl(ctp.Id, Null);

        StudySiteService.SiteFilter siteFilter = new StudySiteService.SiteFilter(siteFilterData);
        List<StudySiteService.StudySiteDistanceWrapper> studiesTemp = StudySiteService.getInstance().getStudySitesWithDistance(siteFilter, null);
        initData.markers = new List<CPDonorReferralFormController.AccountWrapper>();
        initData.studies = new List<StudySiteService.StudySiteDistanceWrapper>();
        for(StudySiteService.StudySiteDistanceWrapper siteWrapper : studiesTemp){
			initData.studies.add(siteWrapper);
			AccountWrapper aw = new AccountWrapper();
			aw.clinic = siteWrapper.site.Principal_Investigator__r.Account;
			aw.ssAccount = siteWrapper.site.Site__r;
			aw.name = siteWrapper.site.Name;
			aw.siteType = siteWrapper.siteType;
			initData.markers.add(aw);
            }
        initData.countries = CountryStateUtil.getCountries();
        initData.statesByCountryMap = CountryStateUtil.getStatesByCountryMap();*/
        return JSON.serialize(studySites);
    }

    @AuraEnabled
    public static Map<String, List<LabelValueItem>> getStateMapByCountry(){
        List<LabelValueItem> countriesLVList = CountryStateUtil.getCountries();
        Map<String, List<LabelValueItem>> statesByCountryMap = CountryStateUtil.getStatesByCountryMap(); 
        return statesByCountryMap;
    }
    
    @AuraEnabled
    public static List<String> getPickListValuesIntoList(){
        List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Form_Results__c.Refering_Orgs__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		}     
		return pickListValuesList;
    }

    @AuraEnabled
    public static void CreateDummyCovidAccount(Integration_Patient_Referral__c intPatientReferral)
    {
        Account newAccount = new Account(
        Name = 'Dummy-Covid-19',
        BillingState= intPatientReferral.Address_State__c,
        BillingCountry = 'United States',
        BillingCountryCode ='US',
        BillingPostalCode = intPatientReferral.Address_ZipCode__c);
        insert newAccount; 
    }

    //Enroll new patient and create new Integration Patient Referral record
    
    @AuraEnabled
    public static void enrollPatient(Date birthDate, Integration_Patient_Referral__c intPatientReferral, Form_Results__c formResult, String fileData) 
    {
        Savepoint sp = Database.setSavepoint();
        try
        {
            Integration_Patient_Referral__c newIntegrationPatientReferral = new Integration_Patient_Referral__c();
            newIntegrationPatientReferral = intPatientReferral;
            newIntegrationPatientReferral.BirthDate__c = formatDateOfBirth(birthDate);
            newIntegrationPatientReferral.Address_Country__c = CPD_ConstantUtil.addressCountry;// 'US';
            newIntegrationPatientReferral.acceptedTermsAndConditions__c = formatDate(Date.today());
            newIntegrationPatientReferral.protocolId__c = CPD_ConstantUtil.protocolId; // 'C19NYBC';
            newIntegrationPatientReferral.Referred_Date__c = formatDate(Date.today());
            newIntegrationPatientReferral.Data_Source__c = CPD_ConstantUtil.dataSource;// 'IQVIA registry';
            newIntegrationPatientReferral.Language_Preference__c = CPD_ConstantUtil.languagePreference;// 'en_US';
            newIntegrationPatientReferral.Condition_Of_Interests__c = CPD_ConstantUtil.conditionOfIntrest;// 'Covid-19';
            newIntegrationPatientReferral.birthYear__c = String.valueOf(birthDate.year()) ;
            //newIntegrationPatientReferral.siteSelected__c = 'LF010';
            //newIntegrationPatientReferral.referralID__c = newIntegrationPatientReferral.siteSelected__c + '_' + newIntegrationPatientReferral.ePRPatient_ID_Number__c;
            //newIntegrationPatientReferral.Address_State__c = 'New York';
            //newIntegrationPatientReferral.Address_Country__c = 'US';
            newIntegrationPatientReferral.Delegate_Mailing_State__c = CPD_ConstantUtil.delegateMailingState; // 'New York';


            //Only get intended field values and Avoid client side injected values.
            Integration_Patient_Referral__c IntegrationInstance = (Integration_Patient_Referral__c) CPDonorReferralFormHelper.getCleanSObject(newIntegrationPatientReferral, 'Integration_Patient_Referral__c');
          
            //Create Integration Patient Referral Record.
            Insert IntegrationInstance;
           
            //Get Part Participant Enrollment
            Integration_Patient_Referral__c ipr = [Select Id, Participant_Enrollment__r.Participant_Contact__c,Participant_Enrollment__c FROM Integration_Patient_Referral__c Where Id=: IntegrationInstance.Id Limit 1];
            //For create form result and Attachment record 
            createFormResult(formResult, fileData, ipr);
        }
        catch(Exception e)
        {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    private static void createFormResult(Form_Results__c formResult, String fileData,Integration_Patient_Referral__c ipr)
    {
        //Assign new form result
        Form_Results__c newFormResult = new Form_Results__c();
        newFormResult = formResult;
        newFormResult.Participant_Enrollment__c = ipr.Participant_Enrollment__c;
        //Only get intended field values and Avoid client side injected values.
        Form_Results__c formResultInstance = (Form_Results__c) CPDonorReferralFormHelper.getCleanSObject(newFormResult, 'Form_Results__c');
        //For create form result record 
        insert formResultInstance;  
        //For create Attachment record 
        if(fileData != null)
        {
            createAttachmentFile(formResultInstance, fileData);
        }
    }

    private static void createAttachmentFile(Form_Results__c newFormResult, String fileData)
    {
        CPDonorReferralFormController.FileUploadDataEntity objFileData = (CPDonorReferralFormController.FileUploadDataEntity) JSON.deserialize(fileData, CPDonorReferralFormController.FileUploadDataEntity.class);
        objFileData.base64Data = EncodingUtil.urlDecode(objFileData.base64Data, 'UTF-8');
        Attachment attachmentRec = new Attachment();
        attachmentRec.parentId = newFormResult.Id;
        attachmentRec.Body = EncodingUtil.base64Decode(objFileData.base64Data);
        attachmentRec.Name = objFileData.fileName;
        attachmentRec.ContentType = objFileData.contentType; 
        insert attachmentRec;
    }

    @AuraEnabled
    public static boolean checkScheduledMaintenance()
    {
        return CPDonorReferralFormHelper.checkScheduledMaintenance();
    }

    private static String formatDate(Date d) 
    {
        return d.year() + '-' + d.month() + '-' + d.day();
    }

    /**
    Method name: formatDateOfBirth
    Parameters : date
    Description: This method is used to convert the date formt of 'yyyy/mm/dd' to 'yyyy-mm-dd'
                 and generally date.month() return 06 instead of 6, date.day() will return 03 instead of 3.
                 So, this method will tolorate above issue, the will be eg. 2020-03-01 not 2020-3-1 
     */
    private static String formatDateOfBirth(Date d){
        return d.year() + '-' + string.valueof(d.month()+100).right(2)  + '-' + string.valueof(d.day()+100).right(2) ;
    }


    // Dnt delete this method in future we will use for file upload
    /*public static void createFile(Form_Results__c newFormResult, String fileData)
    {
        CPDonorReferralFormController.FileUploadDataEntity objFileData = (CPDonorReferralFormController.FileUploadDataEntity) JSON.deserialize(fileData, CPDonorReferralFormController.FileUploadDataEntity.class);
        objFileData.base64Data = EncodingUtil.urlDecode(objFileData.base64Data, 'UTF-8');
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(objFileData.base64Data);
        cv.Title = objFileData.fileName;
        cv.PathOnClient = objFileData.fileName;
        cv.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        cv.Description = objFileData.fileName;
        // cv.FirstPublishLocationId = newFormResult.Id;
        cv.Origin = 'C';
        //cv.OwnerId = '0050Q000003eYo6QAE';
        insert cv;
        System.debug('***cv'+cv);
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = newFormResult.Id;
        cdl.ShareType = 'V'; 
        cdl.Visibility = 'AllUsers';
        insert cdl;
    }*/

    /* Method name: updateIntegrationPatientReferral
       Parameters : String emailAddress, String phoneNumber, String dateOfBirth, String siteSelectedId
       Description: This method is used to update the site study for existing */
    @AuraEnabled
    public static void updateStudySite( String emailAddress, String phoneNumber, String delegateEmailAddress, String delegatePhoneNumber, String dateOfBirth, String siteSelectedId, String protocolId ){
       
        set<String> participantEnrollmentId = getParticipantEnrollment(emailAddress, phoneNumber, delegateEmailAddress, delegatePhoneNumber , dateOfBirth);
        String studySiteId = getStudySite(siteSelectedId, protocolId);
        studySiteId = studySiteId != '' ? getStudySite(siteSelectedId, protocolId) : System.Label.CPD_Default_study_site;

        Participant_Enrollment__c participantsObj = new Participant_Enrollment__c();
        SET<String> findDuplicateSet =new SET<String>();
        SET<String> integrationRecordIdSet =new SET<String>();
        Map<Id, Participant_Enrollment__c> participantsMap = new Map<Id, Participant_Enrollment__c>();
        Map<Id, Integration_Patient_Referral__c> integrationPatientMap = new Map<Id, Integration_Patient_Referral__c>();
        List<Participant_Enrollment__c> participantsEnrollmentList  = new  List<Participant_Enrollment__c>();
        try{
            
            for( Participant_Enrollment__c participants : [SELECT Id, Study_Site__c FROM Participant_Enrollment__c WHERE Id IN : participantEnrollmentId ]){
                if(findDuplicateSet.add(participants.Id)){
                    participants.Study_Site__c = studySiteId;
                    participantsMap.put(participants.Id, participants);
                 }
            }

            for( Integration_Patient_Referral__c integrationPatient : [SELECT Id, siteSelected__c, referralID__c FROM Integration_Patient_Referral__c WHERE Id IN : integrationPatientReferralIds ]){
                if(integrationRecordIdSet.add(integrationPatient.Id)){
                    integrationPatient.siteSelected__c = siteSelectedId;
                    integrationPatient.referralID__c = integrationPatient.referralID__c.replace(System.Label.CPD_Default_study_site,siteSelectedId);
                    integrationPatientMap.put(integrationPatient.Id, integrationPatient);
                 }
            }
            

            if(!participantsMap.isEmpty()){
                update participantsMap.values();
            }

            if(!integrationPatientMap.isEmpty()){
                update integrationPatientMap.values();
            }

        }catch(DmlException ex){
             throw new AuraHandledException('Something went wrong due to: ' + ex.getMessage()); 
        }
    }

    private static Set<String> getParticipantEnrollment(String emailAddress, String phoneNumber, String delegateEmailAddress, String delegatePhoneNumber, String dateOfBirth){
       set<String> participantEnrollmentId = new Set<String>();
        for(Integration_Patient_Referral__c integrationPR:[SELECT Id, Participant_Enrollment__c FROM Integration_Patient_Referral__c WHERE BirthDate__c =: dateOfBirth AND ( (Email__c =: emailAddress OR Delegate_Email_Address__c =: delegateEmailAddress) OR (phone__c =: phoneNumber OR Delegate_Daytime_Phone_Number__c =: delegatePhoneNumber) )]){
            participantEnrollmentId.add(integrationPR.Participant_Enrollment__c);
            integrationPatientReferralIds.add(integrationPR.Id);
        }       
        return participantEnrollmentId;
    }

    private static string getStudySite(String studySiteNumber, String protocolId){
        String studySiteId;
        if(!String.isEmpty(studySiteNumber) && !String.isEmpty(protocolId) ){
            studySiteId = [SELECT Id FROM Study_Site__c WHERE Study_Site_Number__c =: studySiteNumber AND Study_Site_Number__c !=null AND Protocol_ID__c =: protocolId LIMIT 1].Id;
        }
        return studySiteId;
    }

   
}