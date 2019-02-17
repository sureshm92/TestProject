/**
 * Created by D.Yasinskyi on 17.04.2018
 */
public without sharing class MedicalRecordReviewLogController {

    public class ParticipantDetail {
        public ParticipantEnrollmentService.PEFilter peFilter;
        public ParticipantEnrollmentService.PEFilterData peFilterData;
        public PaginationData paginationData;
        public List<PEWrapper> currentPageList;
        public List<SummaryContainer> summrayContainers;
        public FilterPillInfo filterInfo;
    }

    public class PEWrapper{
        public Participant_Enrollment__c pe;
        public Map<String, StudyActions.Action> actions;

        public PEWrapper(Participant_Enrollment__c pe, Map<String, StudyActions.Action> actions){
            this.pe = pe;
            this.actions = actions;
        }
    }

    public static final String ADDITIONAL_FILTER = '(Medical_Record_Review_Status__c = \'' + ParticipantEnrollmentService.MRR_STATUS_PASS + '\'' +
            ' OR Medical_Record_Review_Status__c = \'' + ParticipantEnrollmentService.MRR_STATUS_FAIL + '\')';

    @AuraEnabled
    public static String getParticipantDetail(String trialId, String userMode, Boolean applyPendingFilter) {

        MedicalRecordReviewLogController.ParticipantDetail pDetail = new MedicalRecordReviewLogController.ParticipantDetail();

        try {
            //pagination:
            pDetail.paginationData = new PaginationData();
            //filters data:
            pDetail.peFilterData = setFilterData(trialId, userMode);
            //filters:
            pDetail.peFilter = new ParticipantEnrollmentService.PEFilter(pDetail.peFilterData);
            //set up search fields
            pDetail.peFilter.searchFields = new List<String>{
                    'Participant_Name__c',
                    'Participant_Surname__c',
                    'Name',
                    'Patient_ID__c'
            };
            //set up additional Filters
            if(applyPendingFilter){
                pDetail.peFilter.additionalFilter = ADDITIONAL_FILTER +
                        ' AND Participant_Status__c =\'' + ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL + '\'';
            } else {
                pDetail.peFilter.additionalFilter = ADDITIONAL_FILTER;
            }
            //set SummrayContainers and FilterInfo
            if(String.isEmpty(trialId)){
                setSummrayInfoAndFilterInfo(pDetail);
            }
            //records for current filter and pagination
            pDetail.currentPageList = convertToPEWrapperList(
                    ParticipantEnrollmentService.getParticipantEnrollments(pDetail.peFilter, pDetail.paginationData)
            );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
        }
        return JSON.serialize(pDetail);
    }

    @AuraEnabled
    public static String getRecords(String filterJSON, String paginationJSON, Boolean applyPendingFilter){
        ParticipantEnrollmentService.PEFilter filter = (ParticipantEnrollmentService.PEFilter)JSON.deserialize(filterJSON, ParticipantEnrollmentService.PEFilter.class);
        PaginationData pagination = (PaginationData)JSON.deserialize(paginationJSON, PaginationData.class);
        try {
            ParticipantDetail resultDetail = new ParticipantDetail();
            if(applyPendingFilter){
                filter.additionalFilter = ADDITIONAL_FILTER +
                        ' AND Participant_Status__c =\'' + ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL + '\'';
            } else {
                filter.additionalFilter = ADDITIONAL_FILTER;
            }

            if(String.isNotEmpty(filter.reviewResult)){
                filter.additionalFilter += ' AND Medical_Record_Review_Status__c = \'' + filter.reviewResult + '\'';
            }

            if(String.isNotEmpty(filter.referredType)){
                if(filter.referredType == ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING){
                    filter.additionalFilter += ' AND Participant_Status__c = \'' + ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING + '\'';
                } else if(filter.referredType == 'no'){
                    filter.additionalFilter += ' AND (Participant_Status__c = \'' + ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING + '\'' +
                            ' OR Participant_Status__c = \'' + ParticipantEnrollmentService.PART_STATUS_FAILED_REFERRAL + '\')';
                } else if(filter.referredType == 'yes'){
                    filter.additionalFilter += ' AND (Participant_Status__c != \'' + ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING + '\'' +
                            ' AND Participant_Status__c != \'' + ParticipantEnrollmentService.PART_STATUS_FAILED_REFERRAL + '\'' +
                            ' AND Participant_Status__c != \'' + ParticipantEnrollmentService.PART_STATUS_FAILED_REVIEW + '\'' +
                            ' AND Participant_Status__c != \'' + ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL + '\')';
                }
            }
            resultDetail.currentPageList = convertToPEWrapperList(
                    ParticipantEnrollmentService.getParticipantEnrollments(filter, pagination)
            );
            resultDetail.paginationData = pagination;
            return JSON.serialize(resultDetail);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    private static void setSummrayInfoAndFilterInfo(MedicalRecordReviewLogController.ParticipantDetail pDetail){
        List<SummaryContainer> summrayContainers = new List<SummaryContainer>();
        Integer waitingToBeReferred = 0, totalRecordReviews = 0, totalReferrals = 0,
                reviewsPassed = 0, reviewsFailed = 0, referralsPassed = 0, referralsFailed = 0;

        List<Participant_Enrollment__c> passOrFailEnrollments = ParticipantEnrollmentService.getPEnrolmentsCommon(
                CommunityService.USER_MODE_HCP, 'AND Medical_Record_Review_Status__c IN (\'' + String.join(new List<String>{
                        ParticipantEnrollmentService.MRR_STATUS_PASS,
                        ParticipantEnrollmentService.MRR_STATUS_FAIL
                }, '\',\'') + '\') AND HCP__c != NULL');

        for(Participant_Enrollment__c enroll : passOrFailEnrollments){

            if(enroll.Medical_Record_Review_Status__c == ParticipantEnrollmentService.MRR_STATUS_PASS) reviewsPassed++;

            if(enroll.Participant_Status__c == ParticipantEnrollmentService.PART_STATUS_FAILED_REFERRAL ||
                    enroll.Participant_Status__c == ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING) {
                referralsFailed++;
            } else if(enroll.Participant_Status__c == ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL) {
                waitingToBeReferred++;
            } else if(enroll.Participant_Status__c != ParticipantEnrollmentService.PART_STATUS_FAILED_REVIEW) {
                referralsPassed++;
            }
        }

        reviewsFailed = passOrFailEnrollments.size() - reviewsPassed;
        totalRecordReviews = passOrFailEnrollments.size();
        totalReferrals = referralsPassed + referralsFailed;

        SummaryContainer MRROverall = new SummaryContainer(Label.PG_MRRL_L_Medical_record_reviews_overall, String.valueOf(totalRecordReviews));
        MRROverall.items.add(new LabelValueItem(Label.PG_MRRL_L_Passed_review, String.valueOf(reviewsPassed)));
        MRROverall.items.add(new LabelValueItem(Label.PG_MRRL_L_Failed_review, String.valueOf(reviewsFailed)));
        summrayContainers.add(MRROverall);
        SummaryContainer MRRLRefferals = new SummaryContainer(Label.PG_MRRL_L_Referrals_started_from_medical_record_review_log, String.valueOf(totalReferrals));
        MRRLRefferals.items.add(new LabelValueItem(Label.PG_MRRL_L_Passed_referral, String.valueOf(referralsPassed)));
        MRRLRefferals.items.add(new LabelValueItem(Label.PG_MRRL_L_Failed_referral, String.valueOf(referralsFailed)));
        summrayContainers.add(MRRLRefferals);

        pDetail.summrayContainers = summrayContainers;
        pDetail.filterInfo = new FilterPillInfo(waitingToBeReferred, Label.PG_MRRL_L_Patients_waiting_to_be_referred);
    }

    private static ParticipantEnrollmentService.PEFilterData setFilterData(String trialId, String userMode){
        ParticipantEnrollmentService.PEFilterData peFilterData = new ParticipantEnrollmentService.PEFilterData();

        //set clinical trial profiels
        peFilterData.studies = new List<LabelValueItem>();
        peFilterData.studies.add(new LabelValueItem(Label.PG_MRRL_L_All_studies, null));
        peFilterData.trialIds = new List<Id>();

        //set trails id and trils(studies)
        Map<Id, String> trialsByName = new Map<Id, String>();
        for (Clinical_Trial_Profile__c trial : TrialService.getAvailableTrials(userMode)) {
            trialsByName.put(trial.Id, trial.Study_Code_Name__c);
        }
        if(String.isNotEmpty(trialId)){
            peFilterData.trialIds.add(Id.valueOf(trialId));
            peFilterData.studies.add(new LabelValueItem(trialsByName.get(Id.valueOf(trialId)), trialId));
        } else {
            for(Id studyId : trialsByName.keySet()){
                peFilterData.trialIds.add(studyId);
                peFilterData.studies.add(new LabelValueItem(trialsByName.get(studyId), studyId));
            }
        }

        peFilterData.mode = userMode;

        //set sort
        peFilterData.sortVariants.add(new LabelValueItem(SortOrder.ORDER_A_Z, 'Alphabetical_ASC,Name'));
        peFilterData.sortVariants.add(new LabelValueItem(SortOrder.ORDER_Z_A, 'Alphabetical_DESC,Name'));

        //set Review Results
        peFilterData.reviewResults = new List<LabelValueItem>();
        peFilterData.reviewResults.add(new LabelValueItem(Label.PG_SDRC_L_All, null));
        peFilterData.reviewResults.add(new LabelValueItem(Label.PG_MRRL_L_Passed_review, ParticipantEnrollmentService.MRR_STATUS_PASS));
        peFilterData.reviewResults.add(new LabelValueItem(Label.PG_MRRL_L_Failed_review, ParticipantEnrollmentService.MRR_STATUS_FAIL));

        //set referred
        peFilterData.referredTypes = new List<LabelValueItem>();
        peFilterData.referredTypes.add(new LabelValueItem(Label.PG_SDRC_L_All, null));
        peFilterData.referredTypes.add(new LabelValueItem(Label.BTN_Yes, 'yes'));
        peFilterData.referredTypes.add(new LabelValueItem(Label.BTN_No, 'no'));
        peFilterData.referredTypes.add(new LabelValueItem(Label.PG_MRRLI_MSG_Excluded_from_referring, ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING));

        //set Date Range
        peFilterData.dateRanges = DateRangeFilterData.getRanges();

        return peFilterData;
    }

    private static List<PEWrapper> convertToPEWrapperList(List<Participant_Enrollment__c> participantEnrollments){
        List<PEWrapper> resultList = new List<PEWrapper>();
        for(Participant_Enrollment__c pe : participantEnrollments){
            StudyActions studyActions = new StudyActionsHCP(pe);
            resultList.add(new PEWrapper(pe, studyActions.actions));
        }
        return resultList;
    }

}