public without sharing class RestrictedSourceConfigService {
    
    private static RestrictedSourceConfigService instance;
    //For EPR variables
    public static final String EPR = 'EPR';
    public static final String EPR_Campaign = 'EPR_Campaign';
    public static Map<Id,Boolean> displayConsents = new Map<Id,Boolean>();
    
    public static RestrictedSourceConfigService getInstance() {
        if (instance == null)
            instance = new RestrictedSourceConfigService();
        return instance;
    }
    public static void setMock(StubProvider mock) {
        instance = (RestrictedSourceConfigService) Test.createStub(RestrictedSourceConfigService.class, mock);
    }
    @AuraEnabled(cacheable = false)
    public static Map<Id,Boolean> getConsentPreferences(List<Id> contactIdslst) {
        Set<Id> contactIds = new Set<Id>(contactIdslst);
        Map<Id,String> studieslst = new Map<Id,String>();
        Map<Id,List<Participant_Enrollment__c>> studywithPerlst = new Map<Id,List<Participant_Enrollment__c>>();
        Map<Id,List<Patient_Delegate_Enrollment__c>> studywithPdelst = new Map<Id,List<Patient_Delegate_Enrollment__c>>();
        
        String filter =
            ' Clinical_Trial_Profile__r.IQVIA_Outreach__c = TRUE AND Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = TRUE AND Participant_Contact__c IN (\'' + String.join(contactIds, '\',\'') + '\') ';
        List<Participant_Enrollment__c> perlistTemp = getParticipantEnrollmentsForContact(filter); 
        List<Participant_Enrollment__c> perlist = new List<Participant_Enrollment__c>();
        if(perlistTemp.size()>0){
            for(Participant_Enrollment__c per : perlistTemp){
                if(per.Invited_To_PP_Date__c != NULL){ 
                   perlist.add(per); 
                }
                else if(!per.Participant__r.Adult__c){ // Minor participant 
                    perlist.add(per); 
                }
            }
        }
        if(perlist.size()>0)
            displayConsents = getCTPwithReferalSources(perlist,null);
        if(displayConsents != null && !displayConsents.isEmpty()){
            for(Id key : displayConsents.keyset()){
                if(contactIds.contains(key) && displayConsents.get(key)){
                    contactIds.remove(key);
                }  
            }
        }
        system.debug('contactIds::'+contactIds);
        //For Delegates
        List<Patient_Delegate_Enrollment__c> pdelst = PatientDelegateEnrollmentService.getPDEnrollmentforDelContactwithFilter(contactIds);
        system.debug('pdelst::'+pdelst);
        system.debug('pdelst::'+pdelst.size());
        if(pdelst.size()>0)
            displayConsents = getCTPwithReferalSources(null,pdelst); 
        
        return displayConsents;
    }
    public static final List<String> PE_COMMON_FIELDS = new List<String>{
        'Id',
            'Invited_To_PP_Date__c',
            'Clinical_Trial_Profile__c',
            'Clinical_Trial_Profile__r.Profile_Picture__c',
            'Clinical_Trial_Profile__r.Is_Program__c',
            'Clinical_Trial_Profile__r.Override_Inclusion_Criteria__c',
            'Clinical_Trial_Profile__r.Override_Exclusion_Criteria__c',
            'Clinical_Trial_Profile__r.Patient_Portal_Enabled__c',
            'Clinical_Trial_Profile__r.Detailed_Description__c',
            'Clinical_Trial_Profile__r.Brief_Summary__c',
            'Clinical_Trial_Profile__r.Study_Sponsor__c',
            'Clinical_Trial_Profile__r.Study_Title__c',
            'Clinical_Trial_Profile__r.Study_Code_Name__c',
            'Clinical_Trial_Profile__r.Official_Title__c',
            'Clinical_Trial_Profile__r.Orientation_Required__c',
            'Clinical_Trial_Profile__r.Override_Recruitment_Status__c',
            'Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c',
            'Clinical_Trial_Profile__r.Privacy_Policy_ID__c',
            'Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c',
            'Clinical_Trial_Profile__r.Link_to_Pre_screening__c',
            'Clinical_Trial_Profile__r.Visit_Plan__c',
            'Clinical_Trial_Profile__r.Visit_Data_Shareback__c',
            'Clinical_Trial_Profile__r.Video_And_Articles_Are_Available__c',
            'Clinical_Trial_Profile__r.Protocol_ID__c',
            'Clinical_Trial_Profile__r.Study_Documents_Are_Available__c',
            'Clinical_Trial_Profile__r.Tasks_Are_Available__c',
            'Clinical_Trial_Profile__r.Payment_Is_Available__c',
            'Clinical_Trial_Profile__r.Travel_Vendor_Is_Available__c',
            'Clinical_Trial_Profile__r.Received_Until_Consent_Is_Available__c',
            'Clinical_Trial_Profile__r.Enrolled_Or_Randomized_Consent_Available__c',
            'Clinical_Trial_Profile__r.Visit_Schedule_Is_Available__c',
            'Clinical_Trial_Profile__r.Relevant_Links_Are_Available__c',
            'Clinical_Trial_Profile__r.CommunityTemplate__c',
            'Clinical_Trial_Profile__r.PPTemplate__c',
            'Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c',
            'Clinical_Trial_Profile__r.Trial_Match_Is_Available__c',
            'Clinical_Trial_Profile__r.ECOA_Is_Avaialble__c',
            'Clinical_Trial_Profile__r.Patient_Auth_Upload_Required__c',
            'Clinical_Trial_Profile__r.Shareback_Availability_Timing__c',
            'Clinical_Trial_Profile__r.Promote_to_SH__c',
            'Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c',
            'Clinical_Trial_Profile__r.Study_GUID__c',
            'Clinical_Trial_Profile__r.Visits_are_Available__c ',
            'Clinical_Trial_Profile__r.Televisit_Vendor_is_Available__c ',
            'Clinical_Trial_Profile__r.IQVIA_Outreach__c',
            'Subject_GUID__c',
            'isAuthorized__c',
            'Human_Id__c',
            'Unique_HumanId__c',
            'CreatedDate',
            'Enrolled_Date__c',
            'Enrolled_DateTime__c',
            'HCP__c',
            'HCP__r.Status__c',
            'HCP__r.Study_Site__c',
            'HCP__r.HCP_Contact__c',
            'HCP__r.HCP_Contact__r.Name',
            'HCP__r.HCP_Contact__r.FirstName',
            'HCP__r.HCP_Contact__r.LastName',
            'HCP__r.HCP_Contact__r.Email',
            'HCP__r.HCP_Contact__r.Salutation',
            'HCP__r.HCP_Contact__r.Language__c',
            'HCP__r.HCP_Contact__r.AccountId',
            'HCP__r.HCP_Contact__r.Account.Name',
            'HCP__r.HCP_Contact__r.Account.BillingCountryCode',
            'HCP__r.HCP_Contact__r.Account.BillingStateCode',
            'HCP__r.Orientation_Date__c',
            'Days_After_Enrolled__c',
            'Informed_Consent__c',
            'Is_Virtual_Study_Site__c',
            'IsSubjectIDverifiedInSDH__c',
            'Medical_Record_Review_Status__c',
            'Medical_Record_Review_Completedby_Name__c',
            'Medical_Record_Review_Completed_by__r.Id',
            'Motivational_Message_Id__c',
            'MRN_Id__c',
            'MRR_Survey_Results_URL__c',
            'Name',
            'Non_Referral_Reason__c',
            'Patient_ID__c',
            'Participant_Status__c',
            'Participant_Status_Last_Changed_Date__c',
            'Participant_Name__c',
            'Participant_Surname__c',
            'Participant__c',
            'Participant__r.Adult__c',
            'Participant__r.Marketing_Flag__c',
            'Participant__r.Emancipation_in_progress__c',
            'Participant__r.First_Name__c',
            'Participant__r.Last_Name__c',
            'Participant__r.Middle_Name__c',
            'Participant__r.Full_Name__c',
            'Participant__r.Nickname__c',
            'Participant__r.Suffix__c',
            'Participant__r.Preferred_Language__c',
            'Participant__r.Date_of_Birth__c',
            'Participant__r.Birth_Year__c',
            'Participant__r.Gender__c',
            'Participant__r.Email__c',
            'Participant__r.IsCountry_NOT_Eligible_for_Emails__c',
            'Participant__r.Phone__c',
            'Participant__r.Phone_Type__c',
            'Participant__r.Alternative_Phone_Number__c',
            'Participant__r.Alternative_Phone_Type__c',
            'Participant__r.Mailing_State__c',
            'Participant__r.Mailing_City__c',
            'Participant__r.Mailing_State_Code__c',
            'Participant__r.Mailing_Country__c',
            'Participant__r.Mailing_Country_Code__c',
            'Participant__r.Mailing_Zip_Postal_Code__c',
            'Participant__r.Contact__c',
            'Participant__r.Conditions__c',
            'Participant__r.Contact__r.Language__c',
            'Participant__r.Contact__r.Second_Choice_Language__c',
            'Participant__r.Contact__r.Third_Choice_Language__c',
            'Participant__r.Contact__r.Visit_Results_OptIn__c',
            'Participant_Contact__c',
            'Participant_Contact__r.Visit_Results_OptIn__c',
            'Participant_Opt_In_Status_Emails__c',
            'Participant_Opt_In_Status_SMS__c',
            'Participant_Phone_Opt_In_Permit_Phone__c',
            'IQVIA_Direct_Mail_Consent__c',
            'PI_Contact__c',
            'PI_Contact__r.Id',
            'PI_Contact__r.Name',
            'PI_Contact__r.Phone',
            'Pre_screening_Status__c',
            'Pre_Eligibility_Date__c',
            'Referred_Date__c',
            'Referred_By__c',
            'HCP_Contact_HCPEnroll__c',
            'HCP_Contact_HCPEnroll__r.Name',
            'Referral_ID__c',
            'Referral_Source__c',
            'Referral_Completed_by__r.Id',
            'Referral_Completedby_Name__c',
            'Source_Type__c',
            'Visit_Plan__c',
            'Visit_Plan__r.Name',
            'IVRS_IWRS__c',
            'Show_Referring_Provider__c',
            'Study_Name__c',
            'Study_Site__c',
            'Study_Site__r.Name',
            'Study_Site__r.Is_Virtual_Study_Site__c',
            'Study_Site__r.Study_Site_Type__c',
            'Study_Site__r.Approved_Lng__c',
            'Study_Site__r.Override_PI_Referral_Status__c',
            'Study_Site__r.Clinical_Trial_Profile__c',
            'Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c',
            'Study_Site__r.Clinical_Trial_Profile__r.PPTemplate__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Profile_Picture__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Is_Program__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Override_Inclusion_Criteria__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Override_Exclusion_Criteria__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Detailed_Description__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Brief_Summary__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Study_Sponsor__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Study_Title__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Official_Title__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Orientation_Required__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Override_Recruitment_Status__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Link_to_Pre_screening__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Visit_Plan__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Visit_Data_Shareback__c',
            'Study_Site__r.Site__r.Name',
            'Study_Site__r.Site__r.Phone',
            'Study_Site__r.Site__r.BillingStreet',
            'Study_Site__r.Site__r.BillingCity',
            'Study_Site__r.Site__r.BillingState',
            'Study_Site__r.Site__r.BillingPostalCode',
            'Study_Site__r.Site__r.BillingCountryCode',
            'Study_Site__r.Principal_Investigator__c',
            'Study_Site__r.Principal_Investigator__r.Name',
            'Study_Site__r.Principal_Investigator__r.Salutation',
            'Study_Site__r.Principal_Investigator__r.Language__c',
            'Study_Site__r.Study_Site_Phone__c',
            'Study_Site__r.Visit_Results_Sharing__c',
            'Study_Site__r.Messages_Are_Available__c',
            'Study_Site__r.SMS_Are_Available__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c',
            'Study_Site__r.Suppress_Participant_Emails__c',
            'Study_Site__r.Participant_DOB_format__c',
            'Screening_ID__c',
            'Washout_Run_In_Applies__c',
            'Final_Consent_Date__c',
            'Informed_Consent_Date__c',
            'Initial_visit_occurred_flag__c',
            'Initial_visit_occurred_date__c',
            'Initial_visit_scheduled_date__c',
            'Initial_visit_scheduled_time__c',
            'Initial_visit_scheduled_flag__c',
            'Revisit_Date__c',
            'Final_consent__c',
            'Non_Enrollment_Reason__c',
            'Last_Status_Changed_Notes__c',
            'Permit_SMS_Text_for_this_study__c',
            'Permit_Voice_Text_contact_for_this_study__c',
            'Permit_Mail_Email_contact_for_this_study__c',
            'Delegate_Consent__c',
            'Delegate_SMS_Consent__c',
            'Study_Direct_Mail_Consent__c',
            'Permit_IQVIA_to_contact_about_study__c',
            'Email__c',
            'Patient_Middle_Name_Initial__c',
            'Patient_Sex__c',
            'Phone__c',
            'Country__c',
            'Patient_Phone_Type__c',
            'State__c',
            'Postal_Code__c',
            'Primary_Delegate_First_Name__c',
            'Primary_Delegate_Last_Name__c',
            'Primary_Delegate_Email__c',
            'Primary_Delegate_Phone_Number__c',
            'Primary_Delegate_Phone_Type__c',
            'Primary_Delegate_YOB__c',
            'Is_Delegate_Certify__c',
            'Birth_Month__c',
            'YOB__c',
            'Is_Contact__c',
            'Is_Email__c',
            'Is_SMS__c',
            'Is_Phone__c',
            'Mailing_State_Code__c',
            'Mailing_Country_Code__c',
            'Participant_Alternative_Phone__c',
            'Participant_Alt_Phone_Type__c',
            'Contacted__c',
            'Contacted_Date__c',
            'Consulted__c',
            'Consulted_Date__c',
            'DataControllerOrg__c',
            'Have_you_Documented_the_Discussion__c',
            'Discussion_Documented_Date__c'
            };
                
    public static List<Participant_Enrollment__c> getParticipantEnrollmentsForContact(
        String filter
    ) {
        return getParticipantEnrollmentsCustomFields(
            PE_COMMON_FIELDS,
            filter
        );
    }
    public static Map<Id,Boolean> getCTPwithReferalSources(
        List<Participant_Enrollment__c> perLst,
        List<Patient_Delegate_Enrollment__c> pdeLst
    ) {
        Map<Id,Boolean> displayConsentPref = new Map<Id,Boolean>();
        displayConsentPref = displayConsents;
        Set<Id> studieslst = new Set<Id>();
        Map<Id,String> ctpRestrictedSources = new Map<Id,String>();
        if(perLst != null && !perLst.isEmpty()){
            for(Participant_Enrollment__c per : perLst){
                studieslst.add(per.Clinical_Trial_Profile__c);
            }
        }
        system.debug('perLst::'+perLst);

        if(pdeLst != null && !pdeLst.isEmpty()){
            for(Patient_Delegate_Enrollment__c pde : pdeLst){
                studieslst.add(pde.Participant_Enrollment__r.Clinical_Trial_Profile__c);
            }
        }
        system.debug('pdeLst::'+pdeLst);
        Map<ID, Restricted_Source_Config__c> restrictedsourcelst = new Map<ID, Restricted_Source_Config__c>([SELECT Id, Study__c, Sponsor__c, Referral_Resource__c FROM Restricted_Source_Config__c where Study__c	IN : studieslst]); //AND Sponsor__c IN : sponserlst.values()
        for(Restricted_Source_Config__c resConfig : restrictedsourcelst.values()){
            system.debug(resConfig.Referral_Resource__c);
            if (!ctpRestrictedSources.containsKey(resConfig.Study__c))
                ctpRestrictedSources.put(resConfig.Study__c, resConfig.Referral_Resource__c);
        }
        system.debug('ctpRestrictedSources::'+ctpRestrictedSources);
        if(perLst != null && !perLst.isEmpty()){
            for(Participant_Enrollment__c per : perLst){
                if(ctpRestrictedSources.containsKey(per.Clinical_Trial_Profile__c)){ // study with all PERS for that CTP
                    if(!displayConsentPref.containskey(per.Participant_Contact__c) || !displayConsentPref.get(per.Participant_Contact__c)){
                        displayConsentPref.put(per.Participant_Contact__c,false);
                    }
                    else{
                        continue;
                    }
                    system.debug('displayConsentPref::'+displayConsentPref);
                    String[] restrictedlst = ctpRestrictedSources.get(per.Clinical_Trial_Profile__c) != null ? ctpRestrictedSources.get(per.Clinical_Trial_Profile__c).toUppercase().split(';') :  null;
                    system.debug('restrictedlst::'+restrictedlst);
                    String referralSource = ((per.Referral_Source__c.toUppercase() == EPR || per.Referral_Source__c.toUppercase() == EPR_Campaign) && per.DataControllerOrg__c != null)  ? per.Referral_Source__c.toUppercase() +'-'+per.DataControllerOrg__c.toUppercase() : per.Referral_Source__c.toUppercase(); 
                    system.debug('referralSource::'+referralSource);
                    if(restrictedlst != null && !restrictedlst.isEmpty() && !restrictedlst.contains(referralSource)){
                        system.debug('if block::');
                        displayConsentPref.put(per.Participant_Contact__c,true);
                    }
                }
                else {
                    system.debug('else block::');
                    displayConsentPref.put(per.Participant_Contact__c,true);
                }
            }
        }
        if(pdeLst != null && !pdeLst.isEmpty()){
            for(Patient_Delegate_Enrollment__c pde : pdeLst){ // each CTP
                system.debug('pde::'+pde);
                if(ctpRestrictedSources.containsKey(pde.Participant_Enrollment__r.Clinical_Trial_Profile__c)){ // study with all PERS for that CTP
                    if(!displayConsentPref.containskey(pde.Patient_Delegate__r.Contact__c)  || !displayConsentPref.get(pde.Patient_Delegate__r.Contact__c)){
                        system.debug('if block::');
                        displayConsentPref.put(pde.Patient_Delegate__r.Contact__c,false);
                    }
                    else{
                        continue;
                    }
                    String[] restrictedlst = ctpRestrictedSources.get(pde.Participant_Enrollment__r.Clinical_Trial_Profile__c) != null ? ctpRestrictedSources.get(pde.Participant_Enrollment__r.Clinical_Trial_Profile__c).toUppercase().split(';') :  null;
                    system.debug('if restrictedlst::'+restrictedlst);
                    String referralSource = (pde.Participant_Enrollment__r.Referral_Source__c.toUppercase() == EPR  || pde.Participant_Enrollment__r.Referral_Source__c.toUppercase() == EPR_Campaign && pde.Participant_Enrollment__r.DataControllerOrg__c != null)?pde.Participant_Enrollment__r.Referral_Source__c.toUppercase() +'-'+pde.Participant_Enrollment__r.DataControllerOrg__c.toUppercase() :pde.Participant_Enrollment__r.Referral_Source__c.toUppercase(); 
                    system.debug('referralSource::'+referralSource);
                    if(restrictedlst != null && !restrictedlst.isEmpty() && !restrictedlst.contains(referralSource)){
                        system.debug('if block::');
                        displayConsentPref.put(pde.Patient_Delegate__r.Contact__c,true);
                    }
                }
                else {
                    displayConsentPref.put(pde.Patient_Delegate__r.Contact__c,true);
                }
                system.debug('if displayConsentPref::'+displayConsentPref);
            }
        } 
        return displayConsentPref;
    }
    
    public static List<Participant_Enrollment__c> getParticipantEnrollmentsCustomFields(
        List<String> fieldsList,
        String filter
    ) {
        List<Participant_Enrollment__c> peList = DatabaseService.query(
            fieldsList,
            Participant_Enrollment__c.getSObjectType(),
            filter
        );
        return peList;
    }
}