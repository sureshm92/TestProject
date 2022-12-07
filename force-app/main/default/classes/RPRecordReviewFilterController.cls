public without sharing class  RPRecordReviewFilterController{
   
    public class PEFilterData {
        @AuraEnabled
        public List<Id> trialIds;
        @AuraEnabled
        public List<LabelValueItem> studies;
        @AuraEnabled
        public List<LabelValueItem> dateRanges;
        @AuraEnabled
        public List<LabelValueItem> reviewResults;
        @AuraEnabled
        public List<LabelValueItem> patientStatus;
        @AuraEnabled
        public List<LabelValueItem> exclusionReasons;
    }
    public class filterWrapper {
        @AuraEnabled public List<Id>   SelectedStudies{get;set;}
        @AuraEnabled public String  SelectedExclusionReason{get;set;}
        @AuraEnabled public String  selectedPatientStatus{get;set;}
        @AuraEnabled public String  SelectedDateRangeValue {get;set;}
        @AuraEnabled public String  SelectedReviewResult {get;set;}
        @AuraEnabled public List<Id>  trialIds {get;set;}
        
        public filterWrapper(List<Id>   SelectedStudies,String  SelectedExclusionReason,String  SelectedDateRangeValue,String  SelectedReviewResult,String selectedPatientStatus,List<Id>  trialIds) {
            this.SelectedStudies = SelectedStudies;
            this.SelectedExclusionReason = SelectedExclusionReason;
            this.SelectedDateRangeValue = SelectedDateRangeValue;
            this.SelectedReviewResult = SelectedReviewResult;
            this.selectedPatientStatus = selectedPatientStatus;
            this.trialIds = trialIds;
        }
    }    
    @AuraEnabled
    public static PEFilterData setFilterData(String userMode,String delegateId){
    
        PEFilterData peFilterData =new RPRecordReviewFilterController.PEFilterData();
        peFilterData.studies = new List<LabelValueItem>();
        peFilterData.studies.add(new LabelValueItem(Label.PG_MRRL_L_All_studies, null));
        peFilterData.trialIds = new List<Id>();
        Map<Id, String> trialsByName = new Map<Id, String>();
        
        Id currentContactId = CommunityService.getInstance().getCurrentContactId();
        
       if (delegateId != null && delegateId != '') {
         currentContactId = delegateId;
        }
      
       
       for(Clinical_Trial_Profile__c trial : TrialService.getAvailableTrials(userMode, currentContactId)) {
            trialsByName.put(trial.Id, trial.Study_Code_Name__c);
        }
       for(Id studyId : trialsByName.keySet()) {
            peFilterData.trialIds.add(studyId);
            peFilterData.studies.add(new LabelValueItem(trialsByName.get(studyId), studyId));
        } 
        
        peFilterData.reviewResults = new List<LabelValueItem>();
        peFilterData.reviewResults.add(new LabelValueItem(Label.PG_SDRC_L_All, ''));
        peFilterData.reviewResults.add(new LabelValueItem(Label.PG_MRRL_L_Passed_review,ParticipantEnrollmentService.MRR_STATUS_PASS));
        peFilterData.reviewResults.add(new LabelValueItem(Label.PG_MRRL_L_Failed_review,ParticipantEnrollmentService.MRR_STATUS_FAIL));
        
        peFilterData.dateRanges = new List<LabelValueItem>{
            new LabelValueItem(Label.DRF_L_All_date_ranges, ''),
            new LabelValueItem(Label.DRF_L_Yesterday, '= YESTERDAY'),
            new LabelValueItem(Label.DRF_L_Today, '= TODAY'),
            new LabelValueItem(Label.DRF_L_Last_week, '= LAST_WEEK'),
            new LabelValueItem(Label.DRF_L_This_week, '= THIS_WEEK'),
            new LabelValueItem(Label.DRF_L_Last_month, '= LAST_MONTH'),
            new LabelValueItem(Label.DRF_L_This_month, '= THIS_MONTH'),
            new LabelValueItem(Label.DRF_L_Last_quarter, '= LAST_QUARTER'),
            new LabelValueItem(Label.DRF_L_This_quarter, '= THIS_QUARTER'),
            new LabelValueItem(Label.DRF_L_Last_year, '= LAST_YEAR'),
            new LabelValueItem(Label.DRF_L_This_year, '= THIS_YEAR')
        };
        
        
        peFilterData.patientStatus=new List<LabelValueItem>();
        peFilterData.patientStatus.add(new LabelValueItem(Label.Patient_Status_Exclude_For_Referring,ParticipantEnrollmentService.PART_STATUS_EXCLUDE_FROM_REFERRING_RP));
        peFilterData.patientStatus.add(new LabelValueItem(Label.Patient_Status_Include_For_Referring,ParticipantEnrollmentService.PART_STATUS_INCLUDE_FROM_REFERRING_RP));
        
        peFilterData.exclusionReasons=new List<LabelValueItem>();
        peFilterData.exclusionReasons.add(new LabelValueItem(Label.PG_MPS_L_Failed_pre_eligibility_screening,ParticipantEnrollmentService.NON_REF_REASON_STATUS_FAILED_PE_SCREENING));
        peFilterData.exclusionReasons.add(new LabelValueItem(Label.PG_MPS_L_Had_discussion_not_interested,ParticipantEnrollmentService.NON_REF_REASON_STATUS_HAD_DISC_NOT_INTERESTED));
        peFilterData.exclusionReasons.add(new LabelValueItem(Label.PG_MPS_L_No_longer_interested,ParticipantEnrollmentService.NON_REF_REASON_STATUS_NOT_INTERESTED));
        
        System.debug('peFilterData--'+peFilterData);
        return peFilterData;

        
    }
    @AuraEnabled 
    public static List<RPRecordReviewLogController.peInitData> getFilterPEDetails(String filterJSON,String delegateId) {
       // try {
            Id currentContactId = CommunityService.getInstance().getCurrentContactId();
            List<RPRecordReviewLogController.peInitData> peInitWrapperDataList = new List<RPRecordReviewLogController.peInitData>();
           
            if (delegateId != null && delegateId != '') {
                 currentContactId = delegateId ;
            }
 
            filterWrapper filter = (filterWrapper) JSON.deserialize( filterJSON,filterWrapper.class);
            String strQuery = 'Select Id,Participant_Name__c,Participant_Surname__c,YOB__c,Birth_Month__c,Patient_ID__c,Date_of_Birth__c,Study_Site__r.Clinical_Trial_Profile__c,Participant_Status__c ';

            if(String.isNotBlank(filter.SelectedReviewResult)){
                strQuery += ',(SELECT Id FROM Participant_PrescreenerResponses__r WHERE MRR__c = true AND Status__c = \'' + filter.SelectedReviewResult +  '\' LIMIT 1) ';
            }

            strQuery += ' from Participant_Enrollment__c where HCP__r.HCP_Contact__c = \'' + currentContactId +  '\'';
            strQuery += ' AND Study_Site__r.Override_PI_Referral_Status__c !=NULL AND HCP__c !=NULL AND HCP__r.Status__c !=NULL AND HCP__r.Override_PI_Status__c !=NULL ';
            
            
            if(!filter.SelectedStudies.isEmpty())
                strQuery +=   ' AND Study_Site__r.Clinical_Trial_Profile__c IN (\'' + String.join(filter.SelectedStudies, '\',\'') +  '\') ';
            else 
              strQuery += ' AND Study_Site__r.Clinical_Trial_Profile__c IN (\'' + String.join(filter.trialIds, '\',\'') +  '\') ';
        
             if(String.isNotBlank(filter.selectedPatientStatus))
            {
                String status='';
                if(filter.selectedPatientStatus == ParticipantEnrollmentService.PART_STATUS_EXCLUDE_FROM_REFERRING_RP){
                    status ='Excluded from Referring';
                    strQuery +=' AND Participant_Status__c = \'' + status  +  '\'';
                }else{
                   strQuery += ' AND (Participant_Status__c = \'Failed Referral\' OR Participant_Status__c = \'Failed Review\' OR Participant_Status__c = \'Pending Referral\'  )';
                }
            }else{
               strQuery += ' AND (Participant_Status__c = \'Failed Referral\' OR Participant_Status__c = \'Failed Review\' OR Participant_Status__c = \'Pending Referral\'  )';
            }
                        
            if(String.isNotBlank(filter.SelectedExclusionReason))
            {
                strQuery +=' AND Non_Referral_Reason__c = \'' + filter.SelectedExclusionReason +  '\'';
            }
            
            if(String.isNotBlank(filter.SelectedDateRangeValue))
            {
                strQuery += ' AND CreatedDate ' + '  '  +filter.SelectedDateRangeValue + ' ';
            }
            
            strQuery += ' order by lastmodifiedDate DESC ';
            
            List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c> ();
            system.debug('dynamicquery--->'+strQuery);
            peList = Database.query(strQuery);
            
            for (Participant_Enrollment__c pe : peList) {

                if(String.isBlank(filter.SelectedReviewResult) || pe.Participant_PrescreenerResponses__r.size() > 0){

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
                    peInitWrapperDataList.add(new RPRecordReviewLogController.peInitData(pe, false, dobString));
                }
            }
            return peInitWrapperDataList;
       // } 
      /*  catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        } */
    }
}