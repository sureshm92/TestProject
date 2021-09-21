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
    public static List<peInitData> getPEDetails() {
        try {
            //(Medical_Record_Review_Status__c = 'Pass' OR  Medical_Record_Review_Status__c = 'Fail') AND 
            Id currentContactId = CommunityService.getInstance().getCurrentContactId();
            List<peInitData> peInitWrapperDataList = new List<peInitData>();
            
            List<Id> lstcontactId = new List<Id>();
            List<RP_Delegate_Relationship__c> RPD = new List<RP_Delegate_Relationship__c>();
            RPD = [SELECT Delegate_Access_Level__c,Referring_Provider__c FROM RP_Delegate_Relationship__c WHERE Delegate__c = :currentContactId];
            if(RPD.size() != 0){
                for(RP_Delegate_Relationship__c del: RPD){
                    lstcontactId.add(del.Referring_Provider__c);
                }
                lstcontactId.add(currentContactId);
            }else{
                 lstcontactId.add(currentContactId);
            }
            
            List<Participant_Enrollment__c> peList = [Select Id,Participant_Name__c,Participant_Surname__c,YOB__c,Birth_Month__c,Participant_Status__c,
            Patient_ID__c,Date_of_Birth__c,Study_Site__r.Clinical_Trial_Profile__c from Participant_Enrollment__c where HCP_Contact_HCPEnroll__c IN:lstcontactId AND
            (Participant_Status__c = 'Failed Referral' OR Participant_Status__c = 'Failed Review' OR Participant_Status__c = 'Pending Referral' OR Participant_Status__c = 'Excluded from Referring') AND
            Study_Site__r.Override_PI_Referral_Status__c !=NULL AND HCP__c!=NULL AND HCP__r.Status__c !=NULL AND HCP__r.Override_PI_Status__c !=NULL order by lastmodifiedDate DESC];
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
                List<Participant_Enrollment__c> peList = [Select Id,Patient_ID__c,Study_Site__c,Study_Site__r.Name,Participant_Name__c,Participant_Surname__c,Patient_Middle_Name_Initial__c,Pre_screening_Status__c,
                Patient_Sex__c,Email__c,YOB__c,Birth_Month__c,Date_of_Birth__c,Postal_Code__c,Legal_Status__c,Patient_Auth__c,Country__c,State__c,Phone__c,Patient_Phone_Type__c,Participant_Alternative_Phone__c,
                Participant_Alt_Phone_Type__c,Primary_Delegate_First_Name__c,Primary_Delegate_Last_Name__c,Primary_Delegate_Email__c,Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c,
                Primary_Delegate_Phone_Number__c,Primary_Delegate_Phone_Type__c,Primary_Delegate_YOB__c,Legal_Status_of_Primary_Delegate__c,CreatedDate,Participant_Status__c,Primary_Delegate_s_Alt_Phone__c,Primary_Delegate_s_Alt_Phone_Type__c,
                RP_Site_Selected__c,Medical_Record_Review_Status__c,Study_Site__r.Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.Study_Code_Name__c,Is_Contact__c,Is_Email__c,Is_Phone__c,Is_SMS__c,Is_Delegate_Certify__c,HCP__c
                from Participant_Enrollment__c where Id =: peId];

                String isAdult = '';

                for (Participant_Enrollment__c pe : peList) {

                    String createdDateString = dateFormatChangeForCreatedDate(pe.CreatedDate);
                    peProfileSectionWrapperList.add(new peProfileSection(pe, createdDateString));

                    //By defult value if country and state null
                    if(pe.Country__c == null) {
                        pe.Country__c = 'US';
                    }
                    if(pe.State__c == null) {
                        pe.State__c = 'NY';
                    }
                    //if no YOB and Month and Adult than field will email,phone number and phone type required 
                    if(pe.YOB__c != null) {
                        isAdult = RPRecordReviewLogHelper.checkNeedsGuardian(pe.Country__c, pe.State__c, pe.Birth_Month__c,pe.YOB__c);
                        if(isAdult =='true') {
                            //Minor
                            peProfileSectionWrapperList[0].isRequired = false;
                            pe.Legal_Status__c = 'No';
                            peProfileSectionWrapperList[0].isMinor = true;
                        }
                        else{
                            peProfileSectionWrapperList[0].isRequired = true;
                            pe.Legal_Status__c = 'Yes';
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
                
                peProfileSectionWrapperList[0].siteList = RPRecordReviewLogHelper.getSelectedStudySite(currentContactId,
                peList[0].Clinical_Trial_Profile__c);

                
                List<RP_Delegate_Relationship__c> RPD = new List<RP_Delegate_Relationship__c>();
                RPD = [SELECT Delegate_Access_Level__c FROM RP_Delegate_Relationship__c WHERE Delegate__c = :currentContactId LIMIT 1];
                if(RPD.size() != 0){
                    peProfileSectionWrapperList[0].accessLevel =  RPD[0].Delegate_Access_Level__c;
                }
                else{
                    peProfileSectionWrapperList[0].accessLevel ='All';
                }     
                return peProfileSectionWrapperList;
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
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
               peEnrollment.Birth_Month__c=peRecord.Birth_Month__c;
               peEnrollment.YOB__c=peRecord.YOB__c;
               peEnrollment.Participant_Surname__c=peRecord.Participant_Surname__c;
               peEnrollment.Patient_Sex__c=peRecord.Patient_Sex__c;
               peEnrollment.Country__c=peRecord.Country__c;
               peEnrollment.Phone__c=peRecord.Phone__c;
               peEnrollment.Patient_Phone_Type__c=peRecord.Patient_Phone_Type__c;
               peEnrollment.State__c=peRecord.State__c;
               peEnrollment.Participant_Alternative_Phone__c=peRecord.Participant_Alternative_Phone__c;
               peEnrollment.Participant_Alt_Phone_Type__c=peRecord.Participant_Alt_Phone_Type__c;
               peEnrollment.Postal_Code__c=peRecord.Postal_Code__c;
               peEnrollment.Patient_Auth__c=peRecord.Patient_Auth__c;
               peEnrollment.Legal_Status__c=peRecord.Legal_Status__c;
               peEnrollment.Is_Email__c=peRecord.Is_Email__c;
               peEnrollment.Is_Phone__c=peRecord.Is_Phone__c;
               peEnrollment.Is_SMS__c=peRecord.Is_SMS__c;
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
                update peRecord;
                return peRecord;
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
    public static wrapPEcount  getPECountDetails() {
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
            String UserMode='HCP';
            
            Id currentContactId = CommunityService.getInstance().getCurrentContactId();
            
            List<Id> lstcontactId = new List<Id>();
            List<RP_Delegate_Relationship__c> RPD = new List<RP_Delegate_Relationship__c>();
            RPD = [SELECT Delegate_Access_Level__c,Referring_Provider__c FROM RP_Delegate_Relationship__c WHERE Delegate__c = :currentContactId];
            if(RPD.size() != 0){
                for(RP_Delegate_Relationship__c del: RPD){
                    lstcontactId.add(del.Referring_Provider__c);
                }
                lstcontactId.add(currentContactId);
            }else{
                 lstcontactId.add(currentContactId);
            }
            
            AggregateResult[] groupedResults = [
                 SELECT Included_for_Referring__c,
                     Excluded_for_Referring__c,
                     Patient_Auth__c,Medical_Record_Review_Status__c,Outreach_Mail_Sent__c, Count(Id) total 
                 FROM Participant_Enrollment__c where HCP_Contact_HCPEnroll__c IN:lstcontactId AND
                      (Participant_Status__c = 'Failed Referral' OR Participant_Status__c = 'Failed Review' OR Participant_Status__c = 'Excluded from Referring' OR Participant_Status__c = 'Pending Referral') AND
                      Study_Site__r.Override_PI_Referral_Status__c !=NULL AND HCP__c!=NULL AND HCP__r.Status__c !=NULL AND HCP__r.Override_PI_Status__c !=NULL
                 GROUP BY 
                     Included_for_Referring__c,
                     Excluded_for_Referring__c,
                     Patient_Auth__c,
                     Medical_Record_Review_Status__c,
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
                if(ar.get('Medical_Record_Review_Status__c') == 'Pass' || ar.get('Medical_Record_Review_Status__c') == 'Fail' ){
                   MedicalReview=MedicalReview+Integer.Valueof(ar.get('total'));
                }
                if(ar.get('Outreach_Mail_Sent__c') == 'Yes'){
                   //OutreachMailSent=OutreachMailSent+Integer.Valueof(ar.get('total'));
                   OutreachMailSent = 0;
                }
            }
            yesterdaycount =[SELECT count() FROM Participant_Enrollment__c 
                             WHERE
                                  HCP_Contact_HCPEnroll__c IN:lstcontactId AND
                                  (Participant_Status__c = 'Failed Referral' OR Participant_Status__c = 'Failed Review' OR Participant_Status__c = 'Excluded from Referring' OR Participant_Status__c = 'Pending Referral') AND
                                  Study_Site__r.Override_PI_Referral_Status__c !=NULL AND HCP__c!=NULL AND HCP__r.Status__c !=NULL AND HCP__r.Override_PI_Status__c !=NULL AND
                                  CreatedDate = YESTERDAY];
            lastweekcount=[SELECT count() FROM Participant_Enrollment__c 
                           WHERE 
                                HCP_Contact_HCPEnroll__c IN:lstcontactId AND
                                (Participant_Status__c = 'Failed Referral' OR Participant_Status__c = 'Failed Review' OR Participant_Status__c = 'Excluded from Referring' OR Participant_Status__c = 'Pending Referral') AND
                                Study_Site__r.Override_PI_Referral_Status__c !=NULL AND HCP__c!=NULL AND HCP__r.Status__c !=NULL AND HCP__r.Override_PI_Status__c !=NULL AND
                                CreatedDate = Last_week ];
            lastmonthcount=[SELECT count() FROM Participant_Enrollment__c 
                            WHERE 
                               HCP_Contact_HCPEnroll__c IN:lstcontactId AND
                               (Participant_Status__c = 'Failed Referral' OR Participant_Status__c = 'Failed Review' OR Participant_Status__c = 'Excluded from Referring' OR Participant_Status__c = 'Pending Referral') AND
                               Study_Site__r.Override_PI_Referral_Status__c !=NULL AND HCP__c!=NULL AND HCP__r.Status__c !=NULL AND HCP__r.Override_PI_Status__c !=NULL AND
                               CreatedDate = Last_month ];
           Excluded  =[SELECT count() FROM Participant_Enrollment__c 
                            WHERE 
                               HCP_Contact_HCPEnroll__c IN:lstcontactId AND
                               Participant_Status__c = 'Excluded from Referring' AND
                               Study_Site__r.Override_PI_Referral_Status__c !=NULL AND HCP__c!=NULL AND HCP__r.Status__c !=NULL AND HCP__r.Override_PI_Status__c !=NULL
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
        String surveyGizmoData
    ) {
        
       try{ 
            Participant_Enrollment__c pe = [select id,Medical_Record_Review_Completed_Date__c,
                                        Medical_Record_Review_Status__c,
                                        MRR_Survey_Results_URL__c,
                                        Medical_Record_Review_Completed_by__c,
                                        Pre_screening_Status__c,
                                        Study_Site__c,
                                        Name,
                                        Participant_Status__c From Participant_Enrollment__c where id=:peId
                                        ];
           
            pe.Medical_Record_Review_Completed_Date__c = Datetime.now();
            pe.Medical_Record_Review_Status__c = status;
            pe.MRR_Survey_Results_URL__c = surveyGizmoData;
            pe.Medical_Record_Review_Completed_by__c = CommunityService.getUserContact().Id;
            /**if (status == 'Pass') {
                pe.Pre_screening_Status__c = 'Pass';
            } else {
                pe.Pre_screening_Status__c = 'Fail';
            }**/
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

}