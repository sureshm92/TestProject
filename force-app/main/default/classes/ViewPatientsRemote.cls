/**
 * Created by Leonid Bartenev
 */

public without sharing class ViewPatientsRemote {

    public class InitData{
        public ParticipantEnrollmentService.PEFilter peFilter;
        public ParticipantEnrollmentService.PEFilterData peFilterData;
        public List<PEWrapper> currentPageList;
        public PaginationData paginationData;
        public List<Id> trialIds;
        public Map<String, PEStatusState> peStatusStateMap = PEStatusState.STATUSES_MAP;
        public List<String> peStatusesPathList = PEStatusState.STATUS_STEPS_LIST;
        public MyPatientsStatistics statistics;
        public List<ReferralProfileRemote.ChangeStatusButton> btnList = ReferralProfileRemote.createButtonsList(null);
    }

    public class PEWrapper{
        public Participant_Enrollment__c pe;
        public Map<String, StudyActions.Action> actions;

        public PEWrapper(Participant_Enrollment__c pe, Map<String, StudyActions.Action> actions){
            this.pe = pe;
            this.actions = actions;
        }
    }

    @AuraEnabled
    public static String getInitData(Id trialId, String mode, String btnFilter, String userMode){
        try{
            InitData initData = new InitData();
            //pagination:
            initData.paginationData = new PaginationData();
            //filters data:
            initData.peFilterData = ParticipantEnrollmentService.getPEFilterData(trialId, mode);
            initData.peFilterData.sortVariants.addAll(new List<LabelValueItem>{
                    new LabelValueItem(SortOrder.ORDER_A_Z, 'Alphabetical_ASC,Participant__r.First_Name__c,Participant__r.Last_Name__c'),
                    new LabelValueItem(SortOrder.ORDER_Z_A, 'Alphabetical_DESC,Participant__r.First_Name__c,Participant__r.Last_Name__c')
            });
            //filters: 
            initData.peFilter = new ParticipantEnrollmentService.PEFilter(initData.peFilterData);
            //set up search fields
            initData.peFilter.searchFields = new List<String>{
                    'Participant__r.First_Name__c',
                    'Participant__r.Last_Name__c',
                    'Referral_ID__c',
                    'Patient_ID__c',
                    'Participant_Name__c',
                    'Participant_Surname__c'
            };
            //add additional filtration:
            List<String> excludedStatuses = new List<String>{
                    ParticipantEnrollmentService.PART_STATUS_FAILED_REVIEW,
                    ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL,
                    ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING
            };
            if(mode == CommunityService.USER_MODE_PI) excludedStatuses.add(ParticipantEnrollmentService.PART_STATUS_FAILED_REFERRAL);
            initData.peFilter.additionalFilter = ' Participant_Status__c NOT IN (\'' + String.join(excludedStatuses, '\', \'') + '\') ';
            if(trialId == null) initData.statistics = MyPatientsStatistics.getStatistics(initData.peFilterData.trialIds, mode);
            ParticipantEnrollmentService.PEFilter filterCopy = (ParticipantEnrollmentService.PEFilter) JSON.deserialize(JSON.serialize(initData.peFilter), ParticipantEnrollmentService.PEFilter.class);
            if(btnFilter != null && mode == CommunityService.USER_MODE_PI){
                if(btnFilter.equalsIgnoreCase('Pending')){
                    filterCopy.additionalFilter += ' AND Participant_Status__c IN ' +
                            '(\'' + String.join(PEStatusState.STATUS_STEPS_TABLE[0].states.values(), '\',\'') + '\')';
                }else{
                    filterCopy.additionalFilter += ' AND Participant_Status__c IN ' +
                            '(\'' + String.join(PEStatusState.STATUSES_IN_PROGRESS, '\',\'') + '\')';
                }
            }
            //records for current filter and pagination
            initData.currentPageList = convertToPEWrapperList(
                    ParticipantEnrollmentService.getParticipantEnrollments(filterCopy, initData.paginationData),
                    userMode
            );
            return JSON.serialize(initData);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    class SearchResult{
        List<PEWrapper> peList;
        PaginationData paginationData;
    }

    @AuraEnabled
    public static String getRecords(String filterJSON, String paginationJSON, String piBtnFilter, String userMode){
        ParticipantEnrollmentService.PEFilter filter = (ParticipantEnrollmentService.PEFilter)JSON.deserialize(filterJSON, ParticipantEnrollmentService.PEFilter.class);
        PaginationData pagination = (PaginationData)JSON.deserialize(paginationJSON, PaginationData.class);
        try {
            if(piBtnFilter != null){
                /*filter.study = null;
                filter.studySite = null;
                filter.referringStatus = null;
                filter.enrollmentStatus = null;
                filter.referredType = null;
                filter.dateRange = null;
                filter.acceptenceStatus = null;
                filter.referringClinic = null;*/
                if(piBtnFilter.equalsIgnoreCase('Pending')){
                    filter.additionalFilter += ' AND Participant_Status__c IN ' +
                            '(\'' + String.join(PEStatusState.STATUS_STEPS_TABLE[0].states.values(), '\',\'') + '\')';
                }else{
                    filter.additionalFilter += ' AND Participant_Status__c IN ' +
                            '(\'' + String.join(PEStatusState.STATUSES_IN_PROGRESS, '\',\'') + '\')';
                }
            }
            SearchResult result = new SearchResult();
            result.peList = convertToPEWrapperList(
                    ParticipantEnrollmentService.getParticipantEnrollments(filter, pagination),
                    userMode
            );
            result.paginationData = pagination;
            return JSON.serialize(result);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    class InitDataForPatientProfile{
        Participant__c participant;
        List<Participant_Enrollment__c> peList;
        Map<String, PEStatusState> peStatusStateMap = PEStatusState.STATUSES_MAP;
        List<String> peStatusesPathList = PEStatusState.STATUS_STEPS_LIST;
        Boolean alreadyEnrolled = false;
    }

    @AuraEnabled
    public static String getInitDataForPatientProfile(Id participantId, String mode){
        try{
            InitDataForPatientProfile initData = new InitDataForPatientProfile();
            //filters data:
            ParticipantEnrollmentService.PEFilterData peFilterData = ParticipantEnrollmentService.getPEFilterData(null, mode);
            //init filters:
            ParticipantEnrollmentService.PEFilter peFilter = new ParticipantEnrollmentService.PEFilter(peFilterData);
            List<String> excludedStatuses = new List<String>{
                    ParticipantEnrollmentService.PART_STATUS_FAILED_REVIEW,
                    ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL,
                    ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING
            };
            peFilter.additionalFilter = ' Participant_Status__c NOT IN (\'' + String.join(excludedStatuses, '\', \'') + '\') ';
            peFilter.additionalFilter += ' AND Participant__c=\'' + participantId + '\'' ;
            //retrieve records:
            initData.peList = ParticipantEnrollmentService.getParticipantEnrollments(peFilter, null);
            if(initData.peList == null) return null;
            initData.participant = [
                    SELECT Id, First_Name__c, Last_Name__c, Email__c, Phone__c
                    FROM Participant__c
                    WHERE Id =: participantId
            ];
            String filter = ' AND Participant_Status__c =\'' +  PEStatusState.STATUS_STEPS_TABLE[5].states.get(PEStatusState.STATUS_STATE_SUCCESS) + '\' ';
            filter += ' AND Participant__c=\'' + participantId + '\'' ;
            initData.alreadyEnrolled = ParticipantEnrollmentService.getPEnrolmentsCountCommon(mode, filter) > 0;
            return JSON.serialize(initData);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String getStatistics(String mode){
        try{
            return JSON.serialize(MyPatientsStatistics.getStatistics(TrialService.getAvailableTrialIds(mode), mode));
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    private static List<PEWrapper> convertToPEWrapperList(List<Participant_Enrollment__c> participantEnrollments, String userMode){
        List<PEWrapper> resultList = new List<PEWrapper>();
        for(Participant_Enrollment__c pe : participantEnrollments){
            if(userMode == CommunityService.USER_MODE_HCP){
                resultList.add(new PEWrapper(pe, new StudyActionsHCP(pe).actions));
            }else{
                resultList.add(new PEWrapper(pe, new StudyActionsPI(pe).actions));
            }
        }
        return resultList;
    }


}