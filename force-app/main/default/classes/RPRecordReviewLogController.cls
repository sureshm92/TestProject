public without sharing class RPRecordReviewLogController {


    public class peInitData {
        @AuraEnabled public Participant_Enrollment__c peRec{get;set;}
        @AuraEnabled public Boolean isChecked{get;set;}
        @AuraEnabled public String doBFormat{get;set;}

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
            List<Participant_Enrollment__c> peList = [Select Id,Participant_Name__c,Participant_Surname__c,YOB__c,Birth_Month__c,
            Patient_ID__c,Date_of_Birth__c,Study_Site__r.Clinical_Trial_Profile__c from Participant_Enrollment__c where HCP_Contact_HCPEnroll__c=:currentContactId AND
            (Participant_Status__c = 'Failed Referral' OR Participant_Status__c = 'Failed Review' OR Participant_Status__c = 'Excluded from Referring' OR Participant_Status__c = 'Pending Referral') AND
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
        public String accessLevel;
        
        public peProfileSection(Participant_Enrollment__c peRecord,String createdDateFormat) {
            this.peRecord = peRecord;
            this.createdDateFormat = createdDateFormat;
        }
    }

    @AuraEnabled(cacheable=true)
    public static list<peProfileSection> getSelectedPeDetails (String peId,String delegateId, String userMode) {
        try {
                List<peProfileSection> peProfileSectionWrapperList = new List<peProfileSection>();
                Id currentContactId = CommunityService.getInstance().getCurrentContactId();
                List<Participant_Enrollment__c> peList = [Select Id,Patient_ID__c,Study_Site__c,Study_Site__r.Name,Participant_Name__c,Participant_Surname__c,Patient_Middle_Name_Initial__c,Pre_screening_Status__c,
                Patient_Sex__c,Email__c,YOB__c,Birth_Month__c,Date_of_Birth__c,Postal_Code__c,Legal_Status__c,Patient_Auth__c,Country__c,State__c,Phone__c,Patient_Phone_Type__c,Participant_Alternative_Phone__c,
                Participant_Alt_Phone_Type__c,Primary_Delegate_First_Name__c,Primary_Delegate_Last_Name__c,Primary_Delegate_Email__c,Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c,
                Primary_Delegate_Phone_Number__c,Primary_Delegate_Phone_Type__c,Primary_Delegate_YOB__c,Legal_Status_of_Primary_Delegate__c,CreatedDate,
                Medical_Record_Review_Status__c,Study_Site__r.Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.Study_Code_Name__c,Is_Contact__c,Is_Email__c,Is_Phone__c,Is_SMS__c,Is_Delegate_Certify__c
                from Participant_Enrollment__c where Id =: peId];
                
                for (Participant_Enrollment__c pe : peList) {
                    //By defult value if country and state null
                    if(pe.Country__c == null) {
                        pe.Country__c = 'US';
                    }
                    if(pe.State__c == null) {
                        pe.State__c = 'NY';
                    }

                    String createdDateString = dateFormatChangeForCreatedDate(pe.CreatedDate);
                    peProfileSectionWrapperList.add(new peProfileSection(pe, createdDateString));
                }
                
                RPRecordReviewLogHelper.HCPInit hcp =RPRecordReviewLogHelper.getHCPInitData(delegateId, userMode);
                peProfileSectionWrapperList[0].siteList = hcp.studySiteList;
                
                List<RP_Delegate_Relationship__c> RPD = new List<RP_Delegate_Relationship__c>();
                RPD = [
                        SELECT Delegate_Access_Level__c
                        FROM RP_Delegate_Relationship__c
                        WHERE Delegate__c = :currentContactId 
                        LIMIT 1
                     ];
                if(RPD.size() != 0){
                 peProfileSectionWrapperList[0].accessLevel =  RPD[0].Delegate_Access_Level__c;
                }else{
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
                update peRecord;
                return 'Success';
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    @AuraEnabled
    public static String checkPatientAge(String countryCode, String stateCode, String month ,String year) {
        try {
            String isAdult = RPRecordReviewLogHelper.checkNeedsGuardian(countryCode, stateCode, month,year);
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
                if(peList[0].Primary_Delegate_First_Name__c == null && peList[0].Primary_Delegate_Last_Name__c == null && peList[0].Primary_Delegate_Email__c == null
                && peList[0].Primary_Delegate_Phone_Number__c == null && peList[0].Primary_Delegate_Phone_Type__c == null && peList[0].Primary_Delegate_YOB__c == null
                && peList[0].Legal_Status_of_Primary_Delegate__c == null) {
                    return 'Minor';
                }
                else if(legalStatus == 'No')
                {
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
    
    @AuraEnabled(cacheable=true)
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
            
            AggregateResult[] groupedResults = [
                 SELECT Included_for_Referring__c,
                     Excluded_for_Referring__c,
                     Patient_Auth__c,Medical_Record_Review_Status__c,Outreach_Mail_Sent__c, Count(Id) total 
                 FROM Participant_Enrollment__c where HCP_Contact_HCPEnroll__c=:currentContactId AND
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
                if(ar.get('Medical_Record_Review_Status__c') == 'Pass'){
                   MedicalReview=MedicalReview+Integer.Valueof(ar.get('total'));
                }
                if(ar.get('Outreach_Mail_Sent__c') == 'Yes'){
                   //OutreachMailSent=OutreachMailSent+Integer.Valueof(ar.get('total'));
                   OutreachMailSent = 0;
                }
            }
            yesterdaycount =[SELECT count() FROM Participant_Enrollment__c 
                             WHERE
                                  HCP_Contact_HCPEnroll__c=:currentContactId AND
                                  (Medical_Record_Review_Status__c = 'Pass' OR Medical_Record_Review_Status__c = 'Fail') AND 
                                  (Participant_Status__c = 'Failed Referral' OR Participant_Status__c = 'Failed Review' OR Participant_Status__c = 'Excluded from Referring' OR Participant_Status__c = 'Pending Referral') AND
                                  Study_Site__r.Override_PI_Referral_Status__c !=NULL AND HCP__c!=NULL AND HCP__r.Status__c !=NULL AND HCP__r.Override_PI_Status__c !=NULL AND
                                  CreatedDate = YESTERDAY];
            lastweekcount=[SELECT count() FROM Participant_Enrollment__c 
                           WHERE 
                                HCP_Contact_HCPEnroll__c=:currentContactId AND
                                (Medical_Record_Review_Status__c = 'Pass' OR Medical_Record_Review_Status__c = 'Fail') AND 
                                (Participant_Status__c = 'Failed Referral' OR Participant_Status__c = 'Failed Review' OR Participant_Status__c = 'Excluded from Referring' OR Participant_Status__c = 'Pending Referral') AND
                                Study_Site__r.Override_PI_Referral_Status__c !=NULL AND HCP__c!=NULL AND HCP__r.Status__c !=NULL AND HCP__r.Override_PI_Status__c !=NULL AND
                                CreatedDate = Last_week ];
            lastmonthcount=[SELECT count() FROM Participant_Enrollment__c 
                            WHERE 
                               HCP_Contact_HCPEnroll__c=:currentContactId AND
                               (Medical_Record_Review_Status__c = 'Pass' OR Medical_Record_Review_Status__c = 'Fail') AND 
                               (Participant_Status__c = 'Failed Referral' OR Participant_Status__c = 'Failed Review' OR Participant_Status__c = 'Excluded from Referring' OR Participant_Status__c = 'Pending Referral') AND
                               Study_Site__r.Override_PI_Referral_Status__c !=NULL AND HCP__c!=NULL AND HCP__r.Status__c !=NULL AND HCP__r.Override_PI_Status__c !=NULL AND
                               CreatedDate = Last_month ];
            
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
            if (status == 'Pass') {
                pe.Pre_screening_Status__c = 'Pass';
            } else {
                pe.Pre_screening_Status__c = 'Fail';
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

}