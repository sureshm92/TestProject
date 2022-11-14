public without sharing class RPRecordReviewLogController {
    
    
    public class peInitData {
        @AuraEnabled public Participant_Enrollment__c peRec;
        @AuraEnabled public Boolean isChecked;
        @AuraEnabled public String doBFormat;
        
        public peInitData(Participant_Enrollment__c peRec,Boolean isChecked,String doBFormat) {
            this.peRec = peRec;
            this.isChecked = isChecked;
            this.doBFormat = doBFormat;
        }
    }
    
    public static String dateFormatChange(Date doB) {
        Date d = doB;
        String dt ='';
        if(d != null) {
            dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('MM/YYYY');
        }
        return dt;
    }
    
    public static String dateFormatChangeForCreatedDate(DateTime createDate) {
        DateTime d = createDate;
        String dt ='';
        if(createDate != null) {
            dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('MM/dd/YY');
        }
        return dt;
    }
    
    @AuraEnabled
    public static List<peInitData> getPEDetails(String userMode,String delegateId) {
        try {
            Id currentContactId = CommunityService.getInstance().getCurrentContactId();
            List<peInitData> peInitWrapperDataList = new List<peInitData>();
            
            if (delegateId != null && delegateId != '') {
                currentContactId = delegateId;
            }
            
            List<Participant_Enrollment__c> peList = [Select Id,Participant_Name__c,Participant_Surname__c,YOB__c,Birth_Month__c,Participant_Status__c,
                                                      Patient_ID__c,Date_of_Birth__c,Study_Site__r.Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.Enable_RP_Outreach_Email__c,Clinical_Trial_Profile__r.Link_to_ePR_Campaign__c,Clinical_Trial_Profile__r.Condition_s_Therapeutic_Area__c,Outreach_Email_Status__c from Participant_Enrollment__c where
                                                      (Participant_Status__c = 'Failed Referral' OR Participant_Status__c = 'Failed Review' OR Participant_Status__c = 'Pending Referral' OR Participant_Status__c = 'Excluded from Referring') AND
                                                      Study_Site__r.Override_PI_Referral_Status__c !=NULL AND HCP__c!=NULL AND HCP__r.Status__c !=NULL AND HCP__r.Override_PI_Status__c !=NULL AND HCP__r.HCP_Contact__c =:currentContactId  order by lastmodifiedDate DESC];
            for (Participant_Enrollment__c pe : peList) {
                //String dobString = dateFormatChange(pe.Date_of_Birth__c);
                String dobString = '';
                
                if(pe.Birth_Month__c != null && pe.YOB__c == null) {
                    dobString = pe.Birth_Month__c ;
                }
                if(pe.YOB__c != null && pe.Birth_Month__c == null) {
                    dobString = pe.YOB__c ;
                }
                if(pe.YOB__c != null && pe.Birth_Month__c != null) {
                    dobString = pe.Birth_Month__c+'/'+pe.YOB__c;
                }
                peInitWrapperDataList.add(new peInitData(pe, false, dobString));
            }
            return peInitWrapperDataList;
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    public class peProfileSection {
        @AuraEnabled 
        public Participant_Enrollment__c peRecord;
        @AuraEnabled
        public Participant_PrescreenerResponse__c mrrScreenerResponse;
        @AuraEnabled
        public Participant_PrescreenerResponse__c prescreenerResponse;
        @AuraEnabled
        public PreScreener_Survey__c mrrScreener;
        @AuraEnabled 
        public String createdDateFormat;
        @AuraEnabled 
        public List<LabelValueItem> sexList = SObjectHelper.getPicklistLabelValueList(Participant_Enrollment__c.Patient_Sex__c);
        @AuraEnabled 
        public List<LabelValueItem> countryList = CountryStateUtil.getCountries();
        @AuraEnabled
        public Map<String, List<LabelValueItem>> statesByCountryMap = CountryStateUtil.getStatesByCountryMap();
        @AuraEnabled 
        public List<LabelValueItem> phoneTypeList = SObjectHelper.getPicklistLabelValueList(Participant_Enrollment__c.Patient_Phone_Type__c);
        @AuraEnabled 
        public List<LabelValueItem> altPhoneTypeList = SObjectHelper.getPicklistLabelValueList(Participant_Enrollment__c.Participant_Alt_Phone_Type__c);
        @AuraEnabled 
        public List<LabelValueItem> siteList;
        @AuraEnabled 
        public List<LabelValueItem> patientAuthStatusList = SObjectHelper.getPicklistLabelValueList(Participant_Enrollment__c.Patient_Auth__c);
        @AuraEnabled 
        public List<LabelValueItem> legalStatusList = SObjectHelper.getPicklistLabelValueList(Participant_Enrollment__c.Legal_Status__c);
        @AuraEnabled 
        public List<LabelValueItem> delegatePhoneTypeList = SObjectHelper.getPicklistLabelValueList(Participant_Enrollment__c.Primary_Delegate_Phone_Type__c);
        @AuraEnabled 
        public List<LabelValueItem> monthDateOption = RPRecordReviewLogHelper.getMonthWithZero();
        @AuraEnabled 
        public List<LabelValueItem> yearDateOption = RPRecordReviewLogHelper.getYear();
        @AuraEnabled 
        public List<LabelValueItem> delegateYearOption = RPRecordReviewLogHelper.getYear();
        @AuraEnabled 
        public String accessLevel;
        @AuraEnabled 
        public boolean isRequired;
        @AuraEnabled 
        public boolean isMinor;
        @AuraEnabled 
        public List<LabelValueItem> altDelPhoneTypeList = SObjectHelper.getPicklistLabelValueList(Participant_Enrollment__c.Primary_Delegate_s_Alt_Phone_Type__c);
        @AuraEnabled 
        public String backendSelectedSite;
        
        public peProfileSection(Participant_Enrollment__c peRecord,String createdDateFormat) {
            this.peRecord = peRecord;
            this.createdDateFormat = createdDateFormat;
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static list<peProfileSection> getSelectedPeDetails (String peId,String delegateId, String userMode) {
        try {
            List<peProfileSection> peProfileSectionWrapperList = new List<peProfileSection>();
            Id currentContactId = CommunityService.getInstance().getCurrentContactId();
            
            List<Participant_Enrollment__c> peList = [Select Id,Patient_ID__c,Study_Site__c,Study_Site__r.Name,Participant_Name__c,Participant_Surname__c,Patient_Middle_Name_Initial__c,
                                                      Patient_Sex__c,Email__c,YOB__c,Birth_Month__c,Date_of_Birth__c,Postal_Code__c,Legal_Status__c,Patient_Auth__c,Country__c,Mailing_Country_Code__c,State__c,Mailing_State_Code__c,Phone__c,Patient_Phone_Type__c,Participant_Alternative_Phone__c,
                                                      Participant_Alt_Phone_Type__c,Primary_Delegate_First_Name__c,Primary_Delegate_Last_Name__c,Primary_Delegate_Email__c,Clinical_Trial_Profile__c,
                                                      Primary_Delegate_Phone_Number__c,Primary_Delegate_Phone_Type__c,Primary_Delegate_YOB__c,Legal_Status_of_Primary_Delegate__c,CreatedDate,Participant_Status__c,Primary_Delegate_s_Alt_Phone__c,Primary_Delegate_s_Alt_Phone_Type__c,
                                                      RP_Site_Selected__c,Study_Site__r.Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.Study_Code_Name__c,Is_Contact__c,Is_Email__c,Is_Phone__c,Is_SMS__c,Is_Delegate_Certify__c,HCP__c,Delegate_Consent__c,Delegate_SMS_Consent__c,
                                                      Permit_SMS_Text_for_this_study__c,Permit_Voice_Text_contact_for_this_study__c,Permit_Mail_Email_contact_for_this_study__c, Clinical_Trial_Profile__r.Enable_RP_Outreach_Email__c,Clinical_Trial_Profile__r.Link_to_ePR_Campaign__c,
                                                      Clinical_Trial_Profile__r.Condition_s_Therapeutic_Area__c,Outreach_Email_Status__c,
                                                      Participant__c,Participant__r.Mailing_Country_Code__c,Clinical_Trial_Profile__r.IQVIA_Outreach__c,Participant_Contact__c,Participant_Contact__r.Participant_Opt_In_Status_Emails__c,Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
                                                      Participant_Contact__r.Participant_Opt_In_Status_SMS__c ,Participant_Opt_In_Status_Emails__c,Participant_Opt_In_Status_SMS__c,Participant_Phone_Opt_In_Permit_Phone__c,
                                                      IQVIA_Direct_Mail_Consent__c,IQVIA_Contact_info_storage_consent__c
                                                      from Participant_Enrollment__c where Id =: peId];
            
            String isAdult = '';
            
            for (Participant_Enrollment__c pe : peList) {
                
                    String createdDateString = dateFormatChangeForCreatedDate(pe.CreatedDate);
                    peProfileSectionWrapperList.add(new peProfileSection(pe, createdDateString));

                    //By defult value if country and state null
                    if(pe.Mailing_Country_Code__c == null) {
                        pe.Mailing_Country_Code__c = 'US';
                    }
                    if(pe.Mailing_State_Code__c == null) {
                        pe.Mailing_State_Code__c = 'NY';
                    }
                    //if no YOB and Month and Adult than field will email,phone number and phone type required 
                    if(pe.YOB__c != null) {
                        isAdult = RPRecordReviewLogHelper.checkNeedsGuardian(pe.Mailing_Country_Code__c, pe.Mailing_State_Code__c, pe.Birth_Month__c,pe.YOB__c);
                        if(isAdult =='true') {
                            //Minor
                            peProfileSectionWrapperList[0].isRequired = false;
                            //pe.Legal_Status__c = 'No';
                            peProfileSectionWrapperList[0].isMinor = true;
                        }
                        else{
                            peProfileSectionWrapperList[0].isRequired = true;
                            //pe.Legal_Status__c = 'Yes';
                            peProfileSectionWrapperList[0].isMinor = false;
                        }
                    }
                    else{
                        peProfileSectionWrapperList[0].isRequired = true;
                    peProfileSectionWrapperList[0].isMinor = false;
                }
                if(pe.RP_Site_Selected__c == null) {
                    peProfileSectionWrapperList[0].backendSelectedSite = '';
                }
                else{
                    peProfileSectionWrapperList[0].backendSelectedSite = pe.Study_Site__c;
                }
            }
            
            if (delegateId != null && delegateId != '') {
                currentContactId = delegateId;
            }
            
            peProfileSectionWrapperList[0].siteList = RPRecordReviewLogHelper.getSelectedStudySite(currentContactId,
                                                                                                   peList[0].Clinical_Trial_Profile__c);
            peProfileSectionWrapperList[0].accessLevel = CommunityService.getInstance().getUserAccessLevel(delegateId);
            peProfileSectionWrapperList[0].mrrScreener = getMRRSurvey(peList[0].Clinical_Trial_Profile__c);
            peProfileSectionWrapperList[0] = getScreenerResponse(peId, peProfileSectionWrapperList[0]);
            return peProfileSectionWrapperList;
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
   
    public static peProfileSection getScreenerResponse(String peId, peProfileSection profileSection){
        try {
            List<Participant_PrescreenerResponse__c> responseList = [
                SELECT Participant_enrollment__c, PreScreener_Survey__c, Status__c,
                    MRR__c, Prescreener__c
                FROM  Participant_PrescreenerResponse__c 
                WHERE Participant_enrollment__c =: peId
            ];
            
            for(Participant_PrescreenerResponse__c response : responseList){
                if(response.MRR__c == true){
                    profileSection.mrrScreenerResponse = response;
                } else if(response.Prescreener__c == true){
                    profileSection.prescreenerResponse = response;
                }
            }
            return profileSection;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public static PreScreener_Survey__c getMRRSurvey(Id trialId){
        try {
			List<PreScreener_Survey__c> preSurveyList = [
                SELECT Id, Link_to_Pre_screening__c, Survey_Name__c 
                FROM PreScreener_Survey__c  
                WHERE Study__c = :trialId AND MRR__c = true
            ];
            if(!preSurveyList.isEmpty()){
                preSurveyList[0].Link_to_Pre_screening__c = CommunityFacadeRemote.getLocalizedURL(preSurveyList[0].Link_to_Pre_screening__c);
                return preSurveyList[0];
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String updatePeRecords(Participant_Enrollment__c peRecord){
        try {
            Participant_Enrollment__c peEnrollment = new Participant_Enrollment__c();
            peEnrollment.id = peRecord.id;
            peEnrollment.Patient_ID__c=peRecord.Patient_ID__c;
            peEnrollment.Email__c = peRecord.Email__c;
            peEnrollment.Participant_Name__c=peRecord.Participant_Name__c;
            peEnrollment.Patient_Middle_Name_Initial__c=peRecord.Patient_Middle_Name_Initial__c;
            
            if(peRecord.Birth_Month__c != null && peRecord.Birth_Month__c != '' && peRecord.Birth_Month__c != 'undefined'){
                peEnrollment.Birth_Month__c = peRecord.Birth_Month__c;
            }
            peEnrollment.Birth_Month__c=peRecord.Birth_Month__c;
            peEnrollment.YOB__c=peRecord.YOB__c;
            peEnrollment.Participant_Surname__c=peRecord.Participant_Surname__c;
            peEnrollment.Patient_Sex__c=peRecord.Patient_Sex__c;
            peEnrollment.Mailing_Country_Code__c=peRecord.Mailing_Country_Code__c;
            peEnrollment.Phone__c=peRecord.Phone__c;
            peEnrollment.Patient_Phone_Type__c=peRecord.Patient_Phone_Type__c;
            peEnrollment.Mailing_State_Code__c=peRecord.Mailing_State_Code__c;
            peEnrollment.Participant_Alternative_Phone__c=peRecord.Participant_Alternative_Phone__c;
            if(peRecord.Participant_Alt_Phone_Type__c != null && peRecord.Participant_Alt_Phone_Type__c != ''  
               && peRecord.Participant_Alt_Phone_Type__c != 'undefined'){
                   peEnrollment.Participant_Alt_Phone_Type__c = peRecord.Participant_Alt_Phone_Type__c;
               }
            //Added by Raviteja Starts
            if(peRecord.Permit_Mail_Email_contact_for_this_study__c){
            peEnrollment.Permit_IQVIA_to_contact_about_study__c = peRecord.Permit_Mail_Email_contact_for_this_study__c;
            }
            peEnrollment.Permit_SMS_Text_for_this_study__c = peRecord.Permit_SMS_Text_for_this_study__c;
            peEnrollment.Permit_Voice_Text_contact_for_this_study__c = peRecord.Permit_Voice_Text_contact_for_this_study__c;
            peEnrollment.Study_Artificial_Voice_Consent__c = peRecord.Permit_Voice_Text_contact_for_this_study__c;
            peEnrollment.Study_Assisted_Dialing_Consent__c = peRecord.Permit_Voice_Text_contact_for_this_study__c;
            peEnrollment.Study_Pre_recorded_Voice_Consent__c = peRecord.Permit_Voice_Text_contact_for_this_study__c;
            peEnrollment.Permit_Mail_Email_contact_for_this_study__c = peRecord.Permit_Mail_Email_contact_for_this_study__c;
            peEnrollment.Study_Direct_Mail_Consent__c = peRecord.Permit_Mail_Email_contact_for_this_study__c;
            peEnrollment.IQVIA_Contact_info_storage_consent__c = (peRecord.Participant_Opt_In_Status_Emails__c || peRecord.Participant_Opt_In_Status_SMS__c 
            || peRecord.Participant_Phone_Opt_In_Permit_Phone__c || peRecord.IQVIA_Direct_Mail_Consent__c);
            peEnrollment.Participant_Opt_In_Status_Emails__c = peRecord.Participant_Opt_In_Status_Emails__c;
            peEnrollment.Participant_Opt_In_Status_SMS__c = peRecord.Participant_Opt_In_Status_SMS__c;
            peEnrollment.Participant_Phone_Opt_In_Permit_Phone__c = peRecord.Participant_Phone_Opt_In_Permit_Phone__c;
            peEnrollment.IQVIA_Direct_Mail_Consent__c = peRecord.IQVIA_Direct_Mail_Consent__c;
            peEnrollment.IQVIA_Artificial_Voice_Consent__c = peRecord.Participant_Phone_Opt_In_Permit_Phone__c;
            peEnrollment.IQVIA_Assisted_Dialing_Consent__c = peRecord.Participant_Phone_Opt_In_Permit_Phone__c;
            peEnrollment.IQVIA_Pre_recorded_Voice_Consent__c = peRecord.Participant_Phone_Opt_In_Permit_Phone__c;
            
            //Ends
               peEnrollment.Postal_Code__c=peRecord.Postal_Code__c;
               peEnrollment.Patient_Auth__c=peRecord.Patient_Auth__c;
               peEnrollment.Legal_Status__c=peRecord.Legal_Status__c;
               peEnrollment.Is_Email__c=peRecord.Is_Email__c;
               peEnrollment.Is_Phone__c=peRecord.Is_Phone__c;
               peEnrollment.Is_SMS__c=peRecord.Is_SMS__c;
               peEnrollment.Study_Site__c=peRecord.Study_Site__c;
               peEnrollment.RP_Site_Selected__c=peRecord.RP_Site_Selected__c;

               
               update peEnrollment;
                //update peRecord;
                return 'Success';
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static Participant_Enrollment__c delegateUpdatePeRecords(Participant_Enrollment__c peRecord){
        try {
            
            Participant_Enrollment__c peEnrollment = new Participant_Enrollment__c();
            peEnrollment.id = peRecord.id;
            peEnrollment.Primary_Delegate_First_Name__c=peRecord.Primary_Delegate_First_Name__c;
            peEnrollment.Primary_Delegate_Phone_Number__c = peRecord.Primary_Delegate_Phone_Number__c;
            peEnrollment.Primary_Delegate_Phone_Type__c = peRecord.Primary_Delegate_Phone_Type__c;
            peEnrollment.Primary_Delegate_Last_Name__c = peRecord.Primary_Delegate_Last_Name__c;
            peEnrollment.Primary_Delegate_YOB__c = peRecord.Primary_Delegate_YOB__c;
            peEnrollment.Primary_Delegate_Email__c = peRecord.Primary_Delegate_Email__c;
            peEnrollment.Primary_Delegate_s_Alt_Phone__c = peRecord.Primary_Delegate_s_Alt_Phone__c;
            if(peRecord.Primary_Delegate_s_Alt_Phone_Type__c != null && peRecord.Primary_Delegate_s_Alt_Phone_Type__c != ''  
               && peRecord.Primary_Delegate_s_Alt_Phone_Type__c != 'undefined'){
                   peEnrollment.Primary_Delegate_s_Alt_Phone_Type__c = peRecord.Primary_Delegate_s_Alt_Phone_Type__c;
               }
            peEnrollment.Is_Delegate_Certify__c = peRecord.Is_Delegate_Certify__c;
            peEnrollment.Delegate_Consent__c = peRecord.Delegate_Consent__c;
            peEnrollment.Delegate_SMS_Consent__c = peRecord.Delegate_SMS_Consent__c;
            //2 new fields 
            update peEnrollment;
            return peEnrollment;
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static String checkPatientAge(String countryCode, String stateCode, String month ,String year) {
        try {
            String isAdult = RPRecordReviewLogHelper.checkNeedsGuardian(countryCode, stateCode, month, year);
            return isAdult;
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static String checkDelegateAge(String countryCode, String stateCode, String year) {
        try {
            String isAdult = RPRecordReviewLogHelper.checkDelegateAge(countryCode, stateCode, year);
            return isAdult;
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static String patientValidation(String newPatientId,String oldPatientId,
                                           String countryCode, String stateCode, String month ,String year,String legalStatus){
                                               try {
                                                   List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
                                                   peList = [Select id,Patient_ID__c,YOB__c,Primary_Delegate_First_Name__c,Primary_Delegate_Last_Name__c,Primary_Delegate_Email__c,
                                                             Primary_Delegate_Phone_Number__c,Primary_Delegate_Phone_Type__c,Primary_Delegate_YOB__c,Legal_Status_of_Primary_Delegate__c
                                                             from Participant_Enrollment__c where Patient_ID__c = :newPatientId];
                                                   
                                                   String isAdult = RPRecordReviewLogHelper.checkDelegateAge(countryCode, stateCode, year);
                                                   
                                                   if( newPatientId != oldPatientId && peList.size() >0) {
                                                       return 'DuplicatePatientId';
                                                   }
                                                   else if(isAdult == 'false') {
                                                       if(peList.size() >0 && peList[0].Primary_Delegate_First_Name__c == null && peList[0].Primary_Delegate_Last_Name__c == null && peList[0].Primary_Delegate_Email__c == null
                                                          && peList[0].Primary_Delegate_Phone_Number__c == null && peList[0].Primary_Delegate_Phone_Type__c == null && peList[0].Primary_Delegate_YOB__c == null
                                                          && peList[0].Legal_Status_of_Primary_Delegate__c == null) {
                                                              return 'Minor';
                                                          }
                                                       else if(legalStatus == 'Yes') {
                                                           return 'LegalStatus';
                                                       }
                                                   } else if(isAdult == 'true') {
                                                       if(legalStatus == 'No') {
                                                           return 'LegalStatus';
                                                       }
                                                   }
                                                   return 'Validation Passed';
                                                   
                                               } 
                                               catch (Exception e) {
                                                   throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
                                               }
                                           }
    
    
    
    @AuraEnabled(cacheable=true)
    public static peDataRpWrapper getRecordsDetails() {
        try {
            peDataRpWrapper peData = new peDataRpWrapper();
            peData.participantStatus = new List<LabelValueItem>();
            peData.participantStatus.add(new LabelValueItem(ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING,
                                                            ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING));
            return peData;
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    public class peDataRpWrapper {
        @AuraEnabled public List<LabelValueItem> participantStatus { get; set; }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactList() {
        return [
            SELECT Id, Name, Title, Phone, Email
            FROM Contact
            LIMIT 10
        ];
    }
    
    @AuraEnabled(cacheable=false)
    public static wrapPEcount  getPECountDetails(String userMode,String delegateId) {
        try {
            
            Integer total=0;
            Integer Included=0;
            Integer Excluded=0;
            Integer PatientAth=0;
            Integer MedicalReview=0;
            Integer OutreachMailSent=0;
            Integer yesterdaycount=0;
            Integer lastweekcount=0;
            Integer lastmonthcount=0;
            
            
            Id currentContactId = CommunityService.getInstance().getCurrentContactId();
            if (delegateId != null && delegateId != '') {
                currentContactId = delegateId;
            }
            
            AggregateResult[] groupedResults = [
                SELECT Included_for_Referring__c,
                Excluded_for_Referring__c,
                Patient_Auth__c,Outreach_Mail_Sent__c, Count(Id) total 
                FROM Participant_Enrollment__c where HCP__r.HCP_Contact__c =:currentContactId  AND
                (Participant_Status__c = 'Failed Referral' OR Participant_Status__c = 'Failed Review' OR Participant_Status__c = 'Excluded from Referring' OR Participant_Status__c = 'Pending Referral') AND
                Study_Site__r.Override_PI_Referral_Status__c !=NULL AND HCP__c!=NULL AND HCP__r.Status__c !=NULL AND HCP__r.Override_PI_Status__c !=NULL
                GROUP BY 
                Included_for_Referring__c,
                Excluded_for_Referring__c,
                Patient_Auth__c,
                Outreach_Mail_Sent__c
            ];
            
            
            for (AggregateResult ar : groupedResults)  {
                System.debug('Included_for_Referring__c: ' + ar.get('Included_for_Referring__c') +'  ||   '+ 'Excluded_for_Referring__c: ' + ar.get('Excluded_for_Referring__c') +'||'+ + ar.get('total'));
                total=total + Integer.Valueof(ar.get('total'));
                if(ar.get('Included_for_Referring__c') == 'Yes'){
                    //Included=Included+Integer.Valueof(ar.get('total'));
                    Included = 0;
                    
                }
                if(ar.get('Excluded_for_Referring__c') == 'Yes'){
                    //Excluded=Excluded+Integer.Valueof(ar.get('total'));
                    Excluded = 0;
                    
                }
                if(ar.get('Patient_Auth__c') == 'Yes'){
                    PatientAth=PatientAth+Integer.Valueof(ar.get('total'));
                }
                if(ar.get('Outreach_Mail_Sent__c') == 'Yes'){
                    OutreachMailSent=OutreachMailSent+Integer.Valueof(ar.get('total'));
                    //OutreachMailSent = 0;
                }
            }
            yesterdaycount =[SELECT count() FROM Participant_Enrollment__c 
                             WHERE
                             HCP__r.HCP_Contact__c =:currentContactId  AND
                             (Participant_Status__c = 'Failed Referral' OR Participant_Status__c = 'Failed Review' OR Participant_Status__c = 'Excluded from Referring' OR Participant_Status__c = 'Pending Referral') AND
                             Study_Site__r.Override_PI_Referral_Status__c !=NULL AND HCP__c!=NULL AND HCP__r.Status__c !=NULL AND HCP__r.Override_PI_Status__c !=NULL AND
                             CreatedDate = YESTERDAY];
            lastweekcount=[SELECT count() FROM Participant_Enrollment__c 
                           WHERE 
                           HCP__r.HCP_Contact__c =:currentContactId  AND
                           (Participant_Status__c = 'Failed Referral' OR Participant_Status__c = 'Failed Review' OR Participant_Status__c = 'Excluded from Referring' OR Participant_Status__c = 'Pending Referral') AND
                           Study_Site__r.Override_PI_Referral_Status__c !=NULL AND HCP__c!=NULL AND HCP__r.Status__c !=NULL AND HCP__r.Override_PI_Status__c !=NULL AND
                           CreatedDate = Last_week ];
            lastmonthcount=[SELECT count() FROM Participant_Enrollment__c 
                            WHERE 
                            HCP__r.HCP_Contact__c =:currentContactId  AND
                            (Participant_Status__c = 'Failed Referral' OR Participant_Status__c = 'Failed Review' OR Participant_Status__c = 'Excluded from Referring' OR Participant_Status__c = 'Pending Referral') AND
                            Study_Site__r.Override_PI_Referral_Status__c !=NULL AND HCP__c!=NULL AND HCP__r.Status__c !=NULL AND HCP__r.Override_PI_Status__c !=NULL AND
                            CreatedDate = Last_month ];
            Excluded  =[SELECT count() FROM Participant_Enrollment__c 
                        WHERE 
                        HCP__r.HCP_Contact__c =:currentContactId  AND
                        Participant_Status__c = 'Excluded from Referring' AND
                        Study_Site__r.Override_PI_Referral_Status__c !=NULL AND HCP__c!=NULL AND HCP__r.Status__c !=NULL AND HCP__r.Override_PI_Status__c !=NULL
                       ]; 
                       
            medicalreview = [
                SELECT count() 
                FROM  Participant_PrescreenerResponse__c
                WHERE MRR__c = true
                    AND Participant_enrollment__r.HCP__r.HCP_Contact__c =:currentContactId  
                    AND (Participant_enrollment__r.Participant_Status__c = 'Failed Referral' 
                        OR Participant_enrollment__r.Participant_Status__c = 'Failed Review' 
                        OR Participant_enrollment__r.Participant_Status__c = 'Excluded from Referring' 
                        OR Participant_enrollment__r.Participant_Status__c = 'Pending Referral') 
                    AND Participant_enrollment__r.Study_Site__r.Override_PI_Referral_Status__c != null 
                    AND Participant_enrollment__r.HCP__c != null 
                    AND Participant_enrollment__r.HCP__r.Status__c != null 
                    AND Participant_enrollment__r.HCP__r.Override_PI_Status__c != null
            ];
            
            Included = total - Excluded;
            wrapPEcount count = new wrapPEcount();
            count.totalpatients =total;
            count.includedreferring =Included;
            count.excludedreferring =Excluded;
            count.patientauthreq =PatientAth;
            count.medicalreview =MedicalReview;
            count.outreachmail =OutreachMailSent;
            count.lastdayper=yesterdaycount;
            count.lastweekper =lastweekcount;
            count.lastmonthper =lastmonthcount;  
            
            
            return count;
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }  
    }
    
    @AuraEnabled
    public static void setMRRStatus(
        String peId,
        String status,
        String surveyGizmoData,
        Id screenerId
    ) {
        
        try{ 
            Participant_Enrollment__c pe = [
                SELECT Id, Study_Site__c, Name, Participant_Status__c 
                FROM Participant_Enrollment__c 
                WHERE Id = :peId
            ];
            if (status == 'Fail') {
                pe.Participant_Status__c = 'Failed Review';
            }
            IncentiveProgramService.completeIncentiveTaskCurrentContact(
                IncentiveTaskCatalog.INCENTIVE_TASK_PRE_SCREENING,
                pe.Study_Site__c,
                pe.Name
            );
            
            
            if (pe.Participant_Status__c == 'Received') {
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentTriggerHandler.CreateUsersOrSendNotificationsHandler.class
                );
            }
            update pe;

            Participant_PrescreenerResponse__c prscreenerresponse = new Participant_PrescreenerResponse__c(
                Participant_enrollment__c = pe.Id,
                Status__c = status,
                PreScreener_Survey__c = screenerId,
                Completed_Date__c = Datetime.now(),
                MRR__c = true
            );
            if(!Test.isRunningTest()){
                prscreenerresponse.Screener_Response__c = surveyGizmoData;
                prscreenerresponse.Completed_by__c = CommunityService.getUserContact().Id;
            }
            insert prscreenerresponse;
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }   
    }
    
    public class wrapPEcount {
        @AuraEnabled
        public Integer totalpatients;
        @AuraEnabled
        public Integer includedreferring;
        @AuraEnabled
        public Integer excludedreferring;
        @AuraEnabled
        public Integer patientauthreq;
        @AuraEnabled
        public Integer medicalreview;
        @AuraEnabled
        public Integer outreachmail;
        @AuraEnabled
        public Integer lastmonthper;
        @AuraEnabled
        public Integer lastweekper; 
        @AuraEnabled
        public Integer lastdayper; 
        
        
    } 
    
    
    @AuraEnabled
    public static String changeStatusToExcludeFromReferring(String participantEnrollmentId) {
        try {
            Participant_Enrollment__c participantEnrollment = new Participant_Enrollment__c(
                Id = participantEnrollmentId,
                Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING
            );
            update participantEnrollment;
            return ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + '\n' + ex.getStackTraceString());
        }
    }
    @AuraEnabled
    public static String undoChangeStatusToExcludeFromReferring(String participantEnrollmentId) {
        try {
            Participant_Enrollment__c participantEnrollment = new Participant_Enrollment__c(
                Id = participantEnrollmentId,
                Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL
            );
            update participantEnrollment;
            return ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + '\n' + ex.getStackTraceString());
        }
    }
    @AuraEnabled
    public static String bulkChangeStatusToExcludeFromReferring(List<String> participantEnrollmentIds) {
        try {
            List<Participant_Enrollment__c> updatePeRecords = new List<Participant_Enrollment__c>();
            for(String participantEnrollmentId :participantEnrollmentIds) {
                Participant_Enrollment__c participantEnrollment = new Participant_Enrollment__c(
                    Id = participantEnrollmentId,
                    Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING
                );
                updatePeRecords.add(participantEnrollment);
            }
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
            );
            TriggerHandlerExecutor.bypassHandler(
                PENotificationTriggerHandler.SendEmailIfSSWasChanged.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
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
                ParticipantEnrollmentTriggerHandler.CreateWelcomeToStudyAlertHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
            );
            TriggerHandlerExecutor.bypassHandler(
                PENotificationTriggerHandler.CreateNotificationHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
            );
            /* TriggerHandlerExecutor.bypassHandler(
ParticipantEnrollmentTriggerHandler.SendFOVtoAPI.class
);*/
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.UnenrollorCancelPer.class
            );
            
            update updatePeRecords;
            return ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + '\n' + ex.getStackTraceString());
        }
    }
    
    public class peExportData {
        @AuraEnabled public String Name;
        @AuraEnabled public String MRNID;
        @AuraEnabled public String PatientID;
        @AuraEnabled public String Referreddate;
        @AuraEnabled public String StudyCodeName;
        @AuraEnabled public String StudySiteName;
        @AuraEnabled public String InvestigatorName;
        @AuraEnabled public String ParticipantStatus;
        @AuraEnabled public String StatusChangeReason;
        @AuraEnabled public String  ParticipantStatusLastChangedDt;
        @AuraEnabled public String LastStatusChangedNotes;
        @AuraEnabled public String PreScreeningStatus;
        @AuraEnabled public String PreScreeningCompletedby;
        @AuraEnabled public String PreScreeningdate;
        @AuraEnabled public String ReferralCompletedby;
        @AuraEnabled public String ReferralSource;
        @AuraEnabled public String LastAddedNotes;
        @AuraEnabled public String OutreachMail;
        
        public peExportData(String Name,String MRNID,String PatientID, String Referreddate, String StudyCodeName,String StudySiteName,String InvestigatorName,String ParticipantStatus,
                            String StatusChangeReason,String ParticipantStatusLastChangedDt,String LastStatusChangedNotes,String PreScreeningStatus,String PreScreeningCompletedby,
                            String PreScreeningdate,String ReferralCompletedby,String ReferralSource, String LastAddedNotes ,String OutreachMail               
                           ) {
                               this.Name= Name;
                               this.MRNID=MRNID;
                               this.PatientID= PatientID;
                               this.Referreddate = Referreddate;
                               this.StudyCodeName=StudyCodeName;
                               this.StudySiteName =StudySiteName;
                               this.InvestigatorName=InvestigatorName;
                               this.ParticipantStatus=ParticipantStatus;
                               this.StatusChangeReason=StatusChangeReason;
                               this.ParticipantStatusLastChangedDt=ParticipantStatusLastChangedDt;
                               this.LastStatusChangedNotes=LastStatusChangedNotes;
                               this.PreScreeningStatus=PreScreeningStatus;
                               this.PreScreeningCompletedby=PreScreeningCompletedby;
                               this.PreScreeningdate =PreScreeningdate;
                               this.ReferralCompletedby =ReferralCompletedby;
                               this.ReferralSource = ReferralSource;
                               this.LastAddedNotes = LastAddedNotes;
                               this.OutreachMail = OutreachMail;
                           }
    }
    
    @AuraEnabled
    public static List<peExportData> getExportRecords(List<String> participantEnrollmentIds) {
        try {
            List<Participant_Enrollment__c> PeRecords = new List<Participant_Enrollment__c>();
            List<peExportData> peInitWrapperDataList = new List<peExportData>();
            PeRecords = [
                SELECT Id, Name, Patient_ID__c, MRN_Id__c, Clinical_Trial_Profile__c, Clinical_Trial_Profile__r.Study_Code_Name__c, Site__c,
                    PI_Contact__c,PI_Contact__r.Name,Referred_Date__c, Referral_Completedby_Name__c, Participant_Status__c,
                    Non_Referral_Reason__c,Participant_Status_Last_Changed_Date__c, Last_Status_Changed_Notes__c, Study_Site__c,
                    Study_Site__r.Name, Screening_Date__c,Referral_Source__c, RP_Site_Selected__c,
                    (SELECT Id, Completed_by__c, Completed_by__r.Name, Completed_Date__c, Status__c 
                    FROM Participant_PrescreenerResponses__r 
                    WHERE MRR__c = true 
                    ORDER BY Completed_Date__c DESC 
                    LIMIT 1)
                FROM Participant_Enrollment__c 
                WHERE Id IN :participantEnrollmentIds
            ];
            
            Map<Id, Id> mapContentDocId = new Map<Id, Id>();
            Map<Id, string> mapLastNotes = new Map<Id, string>();
            Set<Id> lstEntityId = new Set<Id>();
            for(ContentDocumentLink conDoc : [SELECT ContentDocumentId,LinkedEntityId,SystemModstamp  FROM ContentDocumentLink WHERE LinkedEntityId IN:participantEnrollmentIds order by SystemModstamp DESC]){
                if(lstEntityId.add(conDoc.LinkedEntityId)){
                    mapContentDocId.put(conDoc.ContentDocumentId,conDoc.LinkedEntityId);}
                
            }
            List<ContentDocument> ContentDoc = [SELECT Id, Title from ContentDocument where Id In: mapContentDocId.keySet() order by CreatedDate DESC];
            for(ContentDocument cd:ContentDoc)
            {
                mapLastNotes.put(mapContentDocId.get(cd.id),cd.Title);  
            }
            
            for(Participant_Enrollment__c per:PeRecords){
                String dateTimeofStatuschng='';
                String lastNotes='';
                String sitename='';
                String OutreachMail='';
                String ReferredDt='';
                String preScreeningDt='', mrrStatus = '', mrrCompletedBy = '';
                if(per.Participant_Status_Last_Changed_Date__c !=null)
                {
                    //dateTimeofStatuschng = per.Participant_Status_Last_Changed_Date__c.format('MM/dd/yyyy, hh:mm a');
                    
                    dateTimeofStatuschng = per.Participant_Status_Last_Changed_Date__c.formatGMT('EEE MMM d HH:mm:ss zz yyyy');
                }
                if(per.Referred_Date__c!=null)
                {
                    Date refdt = per.Referred_Date__c;
                    Datetime dt = datetime.newInstance(refdt.year(), refdt.month(),refdt.day());
                    ReferredDt = dt.formatGMT('EEE MMM d 00:00:00 zz yyyy');
                }
                
                if(per.Participant_PrescreenerResponses__r.isEmpty() == false) {

                    preScreeningDt = per.Participant_PrescreenerResponses__r[0].Completed_Date__c != null 
                        ? per.Participant_PrescreenerResponses__r[0].Completed_Date__c.formatGMT('EEE MMM d HH:mm:ss zz yyyy')
                        : '';
                    mrrStatus = per.Participant_PrescreenerResponses__r[0].Status__c;
                    mrrCompletedBy = per.Participant_PrescreenerResponses__r[0].Completed_by__c != null 
                        ? per.Participant_PrescreenerResponses__r[0].Completed_by__r.Name : '';
                }
                
                if(mapLastNotes.containsKey(per.id)){
                    lastNotes = mapLastNotes.get(per.id);}
                if(per.RP_Site_Selected__c != null){
                    sitename = per.Study_Site__r.Name;
                }
                
                peInitWrapperDataList.add(new peExportData(per.Name,per.MRN_Id__c,per.Patient_ID__c,ReferredDt,per.Clinical_Trial_Profile__r.Study_Code_Name__c,
                                                           sitename,per.PI_Contact__r.Name,per.Participant_Status__c,per.Non_Referral_Reason__c,dateTimeofStatuschng,
                                                           per.Last_Status_Changed_Notes__c,mrrStatus,mrrCompletedBy,
                                                           preScreeningDt,per.Referral_Completedby_Name__c,per.Referral_Source__c,lastNotes,OutreachMail
                                                           
                                                          ));
            }
            return peInitWrapperDataList;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + '\n' + ex.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static String bulkUndoChangeStatusToExcludeFromReferring(list<String> participantEnrollmentIds) {
        try {
            List<Participant_Enrollment__c> updatePeRecords = new List<Participant_Enrollment__c>();
            for(String participantEnrollmentId :participantEnrollmentIds) {
                Participant_Enrollment__c participantEnrollment = new Participant_Enrollment__c(
                    Id = participantEnrollmentId,
                    Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL
                );
                updatePeRecords.add(participantEnrollment);
            }
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
            );
            TriggerHandlerExecutor.bypassHandler(
                PENotificationTriggerHandler.SendEmailIfSSWasChanged.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
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
                ParticipantEnrollmentTriggerHandler.CreateWelcomeToStudyAlertHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
            );
            TriggerHandlerExecutor.bypassHandler(
                PENotificationTriggerHandler.CreateNotificationHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
            );
            /* TriggerHandlerExecutor.bypassHandler(
ParticipantEnrollmentTriggerHandler.SendFOVtoAPI.class
);*/
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.UnenrollorCancelPer.class
            );
            update updatePeRecords;
            return ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + '\n' + ex.getStackTraceString());
        }
    }    
    
    //GN: logic to validate if the Email Outreach button to be visible based on Delegate Role access.
    @AuraEnabled
    public static boolean checkDelegateRole(){
        boolean isDelegateRoleEligible = false;
        User loggedinUser = [select id,ContactId from user where Id =: UserInfo.getUserId()];
        
        if(!String.isBlank(loggedinUser?.ContactId)){
            for(RP_Delegate_Relationship__c delegateRelRec : [SELECT Delegate_Access_Level__c,Referring_Provider__c,Delegate__c 
                                                              FROM RP_Delegate_Relationship__c WHERE Delegate__c =:loggedinUser.ContactId])
            {
                if(delegateRelRec.Delegate_Access_Level__c == 'Level 1'){// enabled only if access level is Level 1.
                    isDelegateRoleEligible = true;
                }
            }
        }        
        return isDelegateRoleEligible;        
    }
    
    //Create note records
    @AuraEnabled
    public static void createNotes(String notes, String peId,String delegateId) {
        try {
            if(delegateId == null || delegateId == '' || delegateId == 'undefined') {
                delegateId = UserInfo.getUserId();
            }
            else{
                User loggedinUser = [select id,ContactId from user where ContactId =: delegateId];
                delegateId = loggedinUser.id;
            }
            ContentNote noteRecord = new ContentNote();
            noteRecord.Title = notes;
            String body = notes;
            noteRecord.Content = Blob.valueOf(body.escapeHTML4());
            insert noteRecord;
            
            ContentDocumentLink link = new ContentDocumentLink();
            link.ContentDocumentId = noteRecord.id;
            link.LinkedEntityId = peId;
            link.ShareType = 'V';
            link.Visibility = 'AllUsers';
            insert link;
            
            Participant_Enrollment__c participantEnrollment = new Participant_Enrollment__c(
                Id = peId
            );
            Update participantEnrollment;
        } 
        catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + '\n' + ex.getStackTraceString());
        }
    }    
    
    public class peNoteData {
        @AuraEnabled public String title;
        @AuraEnabled public DateTime createdDate;
        @AuraEnabled public String createdBy;
        
        public peNoteData(String title,DateTime createdDate,String createdBy) {
            this.title= title;
            this.createdDate=createdDate;
            this.createdBy= createdBy;
        }
    }
    
    //get note records based on participant enrolment ID
    @AuraEnabled(cacheable=true)    
    public static List<peNoteData> getNotesDetails(String peId){
        try {
            Set<Id> contentDocumentIds = new Set<Id>();
            List<peNoteData> lstofNotes = new List<peNoteData>();
            
            List<ID> cdid = new List<Id>();
            List<ContentDocumentLink> CDLink = new List<ContentDocumentLink>();
            CDLink = [
                SELECT ContentDocumentId, LinkedEntityId, Visibility
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :peId
            ];
            for (ContentDocumentLink cd : CDLink) {
                cdid.add(cd.ContentDocumentId);
            }
            List<ContentNote> lstCD = new List<ContentNote>();
            lstCD =[SELECT Id,LastModifiedById,LastModifiedDate,Title,LastModifiedBy.Name,CreatedDate,CreatedBy.Name FROM ContentNote where Id IN:cdid 
                    ORDER BY LastModifieddate DESC];
            
            
            
            Set<Id> lstusr = new Set<Id>();
            List<User> lstusrRecord = new List<User>();
            Map<Id,String> mapUsrmsk = new Map<Id,String>();
            for(ContentNote cn:lstCD){
                lstusr.add(cn.LastModifiedById);
            }
            lstusrRecord = [select id,Name,IsPortalEnabled,ContactId,Contact.userCommunityMode__c from User where id IN:lstusr];
            
            for(User u:lstusrRecord ){
                if(u.IsPortalEnabled){
                    if(u.ContactId != null && u.Contact.userCommunityMode__c == 'CC'){
                        mapUsrmsk.put(u.id,System.Label.RH_Masked_IQVIA_User);
                    }else{
                        mapUsrmsk.put(u.id,u.Name);
                    }
                }else{
                    mapUsrmsk.put(u.id,System.Label.RH_Masked_IQVIA_User);
                }
            } 
            
            for(ContentNote cns:lstCD ){
                lstofNotes.add(new peNoteData(cns.Title,cns.LastModifiedDate,mapUsrmsk.get(cns.LastModifiedById)));
            }
            
            return lstofNotes;
            
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
}
