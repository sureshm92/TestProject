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

    @AuraEnabled(cacheable=true)
    public static List<peInitData> getPEDetails() {
        Id currentContactId = CommunityService.getInstance().getCurrentContactId();

        List<peInitData> peInitWrapperDataList = new List<peInitData>();
        List<Participant_Enrollment__c> peList = [Select Id,Participant_Name__c,Participant_Surname__c,
        Patient_ID__c,Date_of_Birth__c from Participant_Enrollment__c where HCP_Contact_HCPEnroll__c=:currentContactId AND
        (Medical_Record_Review_Status__c = 'Pass' OR Medical_Record_Review_Status__c = 'Fail') AND 
        (Participant_Status__c = 'Failed Referral' OR Participant_Status__c = 'Failed Review' OR Participant_Status__c = 'Excluded from Referring' OR Participant_Status__c = 'Pending Referral') AND
        Study_Site__r.Override_PI_Referral_Status__c !=NULL AND HCP__c!=NULL AND HCP__r.Status__c !=NULL AND HCP__r.Override_PI_Status__c !=NULL order by CreatedDate DESC];
        for (Participant_Enrollment__c pe : peList) {
            String dobString = dateFormatChange(pe.Date_of_Birth__c);
            peInitWrapperDataList.add(new peInitData(pe, false, dobString));
        }
        return peInitWrapperDataList;
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
                      (Medical_Record_Review_Status__c = 'Pass' OR Medical_Record_Review_Status__c = 'Fail') AND 
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
                   Included=Included+Integer.Valueof(ar.get('total'));
                }
                if(ar.get('Excluded_for_Referring__c') == 'Yes'){
                   Excluded=Excluded+Integer.Valueof(ar.get('total'));
                }
                if(ar.get('Patient_Auth__c') == 'Yes'){
                   PatientAth=PatientAth+Integer.Valueof(ar.get('total'));
                }
                if(ar.get('Medical_Record_Review_Status__c') == 'Pass'){
                   MedicalReview=MedicalReview+Integer.Valueof(ar.get('total'));
                }
                if(ar.get('Outreach_Mail_Sent__c') == 'Yes'){
                   OutreachMailSent=OutreachMailSent+Integer.Valueof(ar.get('total'));
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