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
        public ParticipantItem pItem;
        public Map<String, StudyActions.Action> actions;

        public PEWrapper(Participant_Enrollment__c pe, Map<String, StudyActions.Action> actions){
            this.pItem = new ParticipantItem(pe);
            this.actions = actions;
        }
    }

    @AuraEnabled
    public static String getInitData(Id trialId,Id siteId, String mode, String btnFilter, String userMode, String delegateId){
        try{
            InitData initData = new InitData();
            //pagination:
            initData.paginationData = new PaginationData();
            //filters data:
            initData.peFilterData = ParticipantEnrollmentService.getPEFilterData(trialId, mode, true, delegateId);
            initData.peFilterData.dateField = 'Referred_Date__c';
            initData.peFilterData.sortVariants.addAll(new List<LabelValueItem>{
                    new LabelValueItem(SortOrder.ORDER_A_Z, 'Alphabetical_ASC,Participant__r.First_Name__c,Participant__r.Last_Name__c'),
                    new LabelValueItem(SortOrder.ORDER_Z_A, 'Alphabetical_DESC,Participant__r.First_Name__c,Participant__r.Last_Name__c')
            });
            //filters: 
            initData.peFilter = new ParticipantEnrollmentService.PEFilter(initData.peFilterData);
            initData.peFilter.studySite = siteId;
            initData.peFilter.study = trialId;
            initData.peFilter.activePE = 'Active';
            //set up search fields
            initData.peFilter.searchFields = new List<String>{
                    'Participant__r.First_Name__c',
                    'Participant__r.Last_Name__c',
                    'Screening_ID__c',
                    'Name'
                    /*'Referral_ID__c',
                    'Patient_ID__c',
                    'Participant_Name__c',
                    'Participant_Surname__c',
                    'Medical_Record_Review_Status__c',
                    'Participant_Status__c',
                    'Pre_screening_Status__c',
                    'Non_Referral_Reason__c',
                    'CreatedDate'*/
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
            else if(mode == CommunityService.USER_MODE_HCP){
                filterCopy.additionalFilter += ' AND Non_Referral_Reason__c !=\''+ParticipantEnrollmentService.NON_REF_REASON_STATUS_HAD_DISC_NOT_INTERESTED + '\''
                        + ' AND Non_Referral_Reason__c !=\''+ParticipantEnrollmentService.NON_REF_REASON_STATUS_FAILED_PE_SCREENING + '\''
                        + ' AND Non_Referral_Reason__c !=\''+ParticipantEnrollmentService.NON_REF_REASON_STATUS_NOT_INTERESTED + '\'';
            }

            //records for current filter and pagination
            List<Participant_Enrollment__c> peList = ParticipantEnrollmentService.getParticipantEnrollments(filterCopy, initData.paginationData, delegateId);
            List<LabelValueItem> peSource = new List<LabelValueItem>{new LabelValueItem(Label.PG_MRR_L_All_Sources, null)};
            Map<String,String> sourceMap = new Map<String,String>();
            List<LabelValueItem> trialFilterData = new  List<LabelValueItem>{new LabelValueItem(Label.PG_MRRL_L_All_studies, null)};
            List<LabelValueItem> ssFilterData = new  List<LabelValueItem>{new LabelValueItem(Label.PG_Report_L_All_study_sites, null)};
            List<LabelValueItem> statusFilterData = new  List<LabelValueItem>{new LabelValueItem(Label.PG_MRR_L_All_Statuses, null)};
            Set<Id> trialIds = new Set<Id>();
            Set<Id> ssIds = new Set<Id>();
            Set<String> statuses = new Set<String>();
            for (Integer i = 0, j=peList.size(); i < j; i++) {
                if(!trialIds.contains(peList[i].Study_Site__r.Clinical_Trial_Profile__c)){
                    trialFilterData.add(new LabelValueItem(peList[i].Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c, peList[i].Study_Site__r.Clinical_Trial_Profile__r.Id));
                    trialIds.add(peList[i].Study_Site__r.Clinical_Trial_Profile__c);
                }
                if(!ssIds.contains(peList[i].Study_Site__c)){
                    ssFilterData.add(new LabelValueItem(peList[i].Study_Site__r.Name, peList[i].Study_Site__r.Id));
                    ssIds.add(peList[i].Study_Site__c);
                }
                if(!statuses.contains(peList[i].Participant_Status__c)){
                    statusFilterData.add(new LabelValueItem(peList[i].Participant_Status__c, peList[i].Participant_Status__c));
                    statuses.add(peList[i].Participant_Status__c);
                }
                if(peList[i].Referral_Source__c == ParticipantEnrollmentService.PE_REFERRAL_SOURCE_HCP){
                    sourceMap.put(peList[i].HCP_Contact_HCPEnroll__c,peList[i].HCP_Contact_HCPEnroll__r.Name);
                } else if(peList[i].Referral_Source__c == ParticipantEnrollmentService.PE_REFERRAL_SOURCE_PI){
                    sourceMap.put(peList[i].PI_Contact__c,peList[i].PI_Contact__r.Name);
                } else{
                    sourceMap.put(ParticipantEnrollmentService.PE_REFERRAL_SOURCE_DIGITAL_RECRUITMENT,ParticipantEnrollmentService.PE_REFERRAL_SOURCE_DIGITAL_RECRUITMENT);
                }
            }
            for(String key : sourceMap.keySet()){
                peSource.add(new LabelValueItem(sourceMap.get(key), key));
            }
            initData.peFilterData.studies = trialFilterData;
            initData.peFilterData.studySites = ssFilterData;
            initData.peFilterData.statuses = statusFilterData;
            initData.peFilterData.source = peSource;
            initData.currentPageList = convertToPEWrapperList(
                    peList,
                    userMode,
                    delegateId
            );
            return JSON.serialize(initData);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    class SearchResult{
        List<PEWrapper> peList;
        PaginationData paginationData;
        ParticipantEnrollmentService.PEFilter peFilter;
        ParticipantEnrollmentService.PEFilterData peFilterData;
    }

    @AuraEnabled
    public static String getRecords(String filterJSON, String paginationJSON, String piBtnFilter, String userMode, Boolean studyChanged, String delegateId){
        ParticipantEnrollmentService.PEFilter filter = (ParticipantEnrollmentService.PEFilter)JSON.deserialize(filterJSON, ParticipantEnrollmentService.PEFilter.class);
        SearchResult result = new SearchResult();
        result.peFilterData = ParticipantEnrollmentService.getPEFilterData(filter.study, userMode, true, delegateId);
        result.peFilterData.sortVariants.addAll(new List<LabelValueItem>{
                new LabelValueItem(SortOrder.ORDER_A_Z, 'Alphabetical_ASC,Participant__r.First_Name__c,Participant__r.Last_Name__c'),
                new LabelValueItem(SortOrder.ORDER_Z_A, 'Alphabetical_DESC,Participant__r.First_Name__c,Participant__r.Last_Name__c')
        });
        ParticipantEnrollmentService.PEFilter activefilter = new ParticipantEnrollmentService.PEFilter(result.peFilterData);
        activefilter.activePE = filter.activePE;
        /*if(!String.isEmpty(filter.searchText)){
            Map<String,Object> filterMap = (Map<String,Object>) JSON.deserializeUntyped(filterJSON);
            for(String key : filterMap.keySet()){
                if(key != 'searchText' && key != 'searchFields' && key != 'sortType' && key != 'trialIds' && key != 'mode') {
                    filterMap.put(key,null);
                }
            }
            filter = (ParticipantEnrollmentService.PEFilter)JSON.deserialize(JSON.serialize(filterMap), ParticipantEnrollmentService.PEFilter.class);
        }*/
        PaginationData pagination = (PaginationData)JSON.deserialize(paginationJSON, PaginationData.class);
        try {
            if(studyChanged){
                filter.studySite = null;
            }
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
                    activefilter.additionalFilter += ' AND Participant_Status__c IN ' +
                            '(\'' + String.join(PEStatusState.STATUS_STEPS_TABLE[0].states.values(), '\',\'') + '\')'
                            + ' AND Non_Referral_Reason__c !=\''+ParticipantEnrollmentService.NON_REF_REASON_STATUS_HAD_DISC_NOT_INTERESTED + '\''
                            + ' AND Non_Referral_Reason__c !=\''+ParticipantEnrollmentService.NON_REF_REASON_STATUS_NOT_INTERESTED + '\''
                            + ' AND Non_Referral_Reason__c !=\''+ParticipantEnrollmentService.NON_REF_REASON_STATUS_FAILED_PE_SCREENING + '\'';
                }else{
                    activefilter.additionalFilter += ' AND Participant_Status__c IN ' +
                            '(\'' + String.join(PEStatusState.STATUSES_IN_PROGRESS, '\',\'') + '\')'
                            + ' AND Non_Referral_Reason__c !=\''+ParticipantEnrollmentService.NON_REF_REASON_STATUS_HAD_DISC_NOT_INTERESTED + '\''
                            + ' AND Non_Referral_Reason__c !=\''+ParticipantEnrollmentService.NON_REF_REASON_STATUS_NOT_INTERESTED + '\''
                            + ' AND Non_Referral_Reason__c !=\''+ParticipantEnrollmentService.NON_REF_REASON_STATUS_FAILED_PE_SCREENING + '\'';
                }
            }
            else if(userMode == CommunityService.USER_MODE_HCP){
                activefilter.additionalFilter += + ' AND Non_Referral_Reason__c !=\''+ParticipantEnrollmentService.NON_REF_REASON_STATUS_HAD_DISC_NOT_INTERESTED + '\''
                        + ' AND Non_Referral_Reason__c !=\''+ParticipantEnrollmentService.NON_REF_REASON_STATUS_NOT_INTERESTED + '\''
                        + ' AND Non_Referral_Reason__c !=\''+ParticipantEnrollmentService.NON_REF_REASON_STATUS_FAILED_PE_SCREENING + '\'';
            }
            System.debug('additionalFilter' + activefilter.additionalFilter);


            result.paginationData = pagination;


            List<Participant_Enrollment__c> peList = ParticipantEnrollmentService.getParticipantEnrollments(activefilter, pagination, delegateId);
            List<LabelValueItem> peSource = new List<LabelValueItem>{new LabelValueItem(Label.PG_MRR_L_All_Sources, null)};
            Map<String,String> sourceMap = new Map<String,String>();
            List<LabelValueItem> trialFilterData = new  List<LabelValueItem>{new LabelValueItem(Label.PG_MRRL_L_All_studies, null)};
            List<LabelValueItem> ssFilterData = new  List<LabelValueItem>{new LabelValueItem(Label.PG_Report_L_All_study_sites, null)};
            List<LabelValueItem> statusFilterData = new  List<LabelValueItem>{new LabelValueItem(Label.PG_MRR_L_All_Statuses, null)};
            Set<Id> trialIds = new Set<Id>();
            Set<Id> ssIds = new Set<Id>();
            Set<String> statuses = new Set<String>();
            for (Integer i = 0, j = peList.size(); i < j; i++) {
                if(!trialIds.contains(peList[i].Study_Site__r.Clinical_Trial_Profile__c)){
                    trialFilterData.add(new LabelValueItem(peList[i].Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c, peList[i].Study_Site__r.Clinical_Trial_Profile__r.Id));
                    trialIds.add(peList[i].Study_Site__r.Clinical_Trial_Profile__c);
                }

                if (!String.isEmpty(filter.study)) {
                    if (peList[i].Study_Site__r.Clinical_Trial_Profile__r.Id == filter.study) {
                        if(!ssIds.contains(peList[i].Study_Site__c)){
                            ssFilterData.add(new LabelValueItem(peList[i].Study_Site__r.Name, peList[i].Study_Site__r.Id));
                            ssIds.add(peList[i].Study_Site__c);
                        }
                        if (!String.isEmpty(filter.studySite)) {
                            if (peList[i].Study_Site__r.Id == filter.studySite) {
                                if (peList[i].Referral_Source__c == ParticipantEnrollmentService.PE_REFERRAL_SOURCE_HCP) {
                                    sourceMap.put(peList[i].HCP_Contact_HCPEnroll__c, peList[i].HCP_Contact_HCPEnroll__r.Name);
                                } else if (peList[i].Referral_Source__c == ParticipantEnrollmentService.PE_REFERRAL_SOURCE_PI) {
                                    sourceMap.put(peList[i].PI_Contact__c, peList[i].PI_Contact__r.Name);
                                } else {
                                    sourceMap.put(ParticipantEnrollmentService.PE_REFERRAL_SOURCE_DIGITAL_RECRUITMENT, ParticipantEnrollmentService.PE_REFERRAL_SOURCE_DIGITAL_RECRUITMENT);
                                }
                            }
                        } else {
                            if (peList[i].Referral_Source__c == ParticipantEnrollmentService.PE_REFERRAL_SOURCE_HCP) {
                                sourceMap.put(peList[i].HCP_Contact_HCPEnroll__c, peList[i].HCP_Contact_HCPEnroll__r.Name);
                            } else if (peList[i].Referral_Source__c == ParticipantEnrollmentService.PE_REFERRAL_SOURCE_PI) {
                                sourceMap.put(peList[i].PI_Contact__c, peList[i].PI_Contact__r.Name);
                            } else {
                                sourceMap.put(ParticipantEnrollmentService.PE_REFERRAL_SOURCE_DIGITAL_RECRUITMENT, ParticipantEnrollmentService.PE_REFERRAL_SOURCE_DIGITAL_RECRUITMENT);
                            }
                        }
                        if(!statuses.contains(peList[i].Participant_Status__c)){
                            statusFilterData.add(new LabelValueItem(peList[i].Participant_Status__c, peList[i].Participant_Status__c));
                            statuses.add(peList[i].Participant_Status__c);
                        }

                    }
                } else {
                    if(!ssIds.contains(peList[i].Study_Site__c)){
                        ssFilterData.add(new LabelValueItem(peList[i].Study_Site__r.Name, peList[i].Study_Site__r.Id));
                        ssIds.add(peList[i].Study_Site__c);
                    }
                    statusFilterData.add(new LabelValueItem(peList[i].Participant_Status__c, peList[i].Participant_Status__c));
                    if (peList[i].Referral_Source__c == ParticipantEnrollmentService.PE_REFERRAL_SOURCE_HCP) {
                        sourceMap.put(peList[i].HCP_Contact_HCPEnroll__c, peList[i].HCP_Contact_HCPEnroll__r.Name);
                    } else if (peList[i].Referral_Source__c == ParticipantEnrollmentService.PE_REFERRAL_SOURCE_PI) {
                        sourceMap.put(peList[i].PI_Contact__c, peList[i].PI_Contact__r.Name);
                    } else {
                        sourceMap.put(ParticipantEnrollmentService.PE_REFERRAL_SOURCE_DIGITAL_RECRUITMENT, ParticipantEnrollmentService.PE_REFERRAL_SOURCE_DIGITAL_RECRUITMENT);
                    }
                }
            }
            for(String key : sourceMap.keySet()){
                peSource.add(new LabelValueItem(sourceMap.get(key), key));
            }
            result.peFilterData.studies = trialFilterData;
            result.peFilterData.studySites = ssFilterData;
            result.peFilterData.statuses = statusFilterData;
            result.peFilterData.source = peSource;
            result.peList = convertToPEWrapperList(
                    peList,
                    userMode,
                    delegateId
            );
            result.peList = convertToPEWrapperList(
                    ParticipantEnrollmentService.getParticipantEnrollments(filter, pagination, delegateId),
                    userMode,
                    delegateId
            );

            result.peFilter = filter;
//            Boolean siteExists = false;
//            for(LabelValueItem site: result.peFilterData.studySites){
//                if (site.value == filter.studySite) {
//                    siteExists = true;
//                    break;
//                }
//            }
//            if(!siteExists){
//                filter.studySite = null;
//            }
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
    public static String getInitDataForPatientProfile(Id participantId, String mode, String delegateId){
        try{
            InitDataForPatientProfile initData = new InitDataForPatientProfile();
            //filters data:
            ParticipantEnrollmentService.PEFilterData peFilterData = ParticipantEnrollmentService.getPEFilterData(null, mode, false, delegateId);
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
            initData.peList = ParticipantEnrollmentService.getParticipantEnrollments(peFilter, null, delegateId);
            if(initData.peList == null) return null;
            initData.participant = [
                    SELECT Id, First_Name__c, Last_Name__c, Email__c, Phone__c
                    FROM Participant__c
                    WHERE Id =: participantId
            ];
            String filter = ' AND Participant_Status__c =\'' +  PEStatusState.STATUS_STEPS_TABLE[5].states.get(PEStatusState.STATUS_STATE_SUCCESS) + '\' ';
            filter += ' AND Participant__c=\'' + participantId + '\'' ;
            initData.alreadyEnrolled = ParticipantEnrollmentService.getPEnrolmentsCountCommon(mode, filter, delegateId) > 0;
            return JSON.serialize(initData);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String getStatistics(String mode, String delegateId){
        try{
            return JSON.serialize(MyPatientsStatistics.getStatistics(TrialService.getAvailableTrialIds(mode, delegateId), mode));
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    private static List<PEWrapper> convertToPEWrapperList(List<Participant_Enrollment__c> participantEnrollments, String userMode){
        return convertToPEWrapperList(participantEnrollments, userMode, null);
    }
    private static List<PEWrapper> convertToPEWrapperList(List<Participant_Enrollment__c> participantEnrollments, String userMode, String delegateId){
        List<PEWrapper> resultList = new List<PEWrapper>();
        for(Participant_Enrollment__c pe : participantEnrollments){
            if(userMode == CommunityService.USER_MODE_HCP){
                resultList.add(new PEWrapper(pe, new StudyActionsHCP(pe, delegateId).actions));
            }else{
                resultList.add(new PEWrapper(pe, new StudyActionsPI(pe).actions));
            }
        }
        return resultList;
    }


}