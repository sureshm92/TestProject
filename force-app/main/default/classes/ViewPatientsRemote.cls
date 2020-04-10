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
        public Boolean isInvited;
        public Boolean hasEmancipatedParticipants;
     //   public MyPatientsStatistics statistics;
     //   public List<ReferralProfileRemote.ChangeStatusButton> btnList = ReferralProfileRemote.createButtonsList(null);
    }

    public class PEWrapper{
        public boolean isInvited;
        public Boolean hasEmancipatedParticipants;
        public ParticipantItem pItem;
        public Map<String, StudyActions.Action> actions;
        public List<StudyActions.Action> participantCardActions;
        public List<StudyActions.Action> healthcareProviderActions;

        public PEWrapper(Participant_Enrollment__c pe, Map<String, StudyActions.Action> actions){
            this.pItem = new ParticipantItem(pe);
            this.actions = actions;
        }
        public PEWrapper(Participant_Enrollment__c pe, Map<String, StudyActions.Action> actions, Boolean isInvited){
            this.pItem = new ParticipantItem(pe);
            this.actions = actions;
            this.isInvited = isInvited;
            this.hasEmancipatedParticipants = pe.Participant__r != null ? pe.Participant__r.Emancipation_in_progress__c : false;
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
            initData.peFilter.activePE = userMode == 'PI' ? 'Active' : null;
            //set up search fields
            initData.peFilter.searchFields = new List<String>{
                    'Participant__r.First_Name__c',
                    'Participant__r.Last_Name__c',
                    'Screening_ID__c',
                    'Name'
            };
            //add additional filtration:
            List<String> excludedStatuses = new List<String>{
                    ParticipantEnrollmentService.PART_STATUS_FAILED_REVIEW,
                    ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL,
                    ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING
            };
            if(mode == CommunityService.USER_MODE_PI) excludedStatuses.add(ParticipantEnrollmentService.PART_STATUS_FAILED_REFERRAL);
            initData.peFilter.additionalFilter = ' Participant_Status__c NOT IN (\'' + String.join(excludedStatuses, '\', \'') + '\') ';
            //if(trialId == null) initData.statistics = MyPatientsStatistics.getStatistics(initData.peFilterData.trialIds, mode);
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
            //List<Participant_Enrollment__c> peList = ParticipantEnrollmentService.getParticipantEnrollments(filterCopy, initData.paginationData, delegateId);
            List<Participant_Enrollment__c> peList = ParticipantEnrollmentService.getParticipantEnrollments(filterCopy, delegateId);
            initData.hasEmancipatedParticipants = checkHasEmancipatedParticipants(peList);
            peList = ParticipantEnrollmentService.getParticipantEnrollmentsPaginated(peList, initData.paginationData);
            List<LabelValueItem> peSource = new List<LabelValueItem>{new LabelValueItem(Label.PG_MRR_L_All_Sources, null)};
            Map<String,String> sourceMap = new Map<String,String>();
            List<LabelValueItem> trialFilterData = new  List<LabelValueItem>{new LabelValueItem(Label.PG_MRRL_L_All_studies, null)};
            List<LabelValueItem> ssFilterData = new  List<LabelValueItem>{new LabelValueItem(Label.PG_Report_L_All_study_sites, null)};
            List<LabelValueItem> statusFilterData = new  List<LabelValueItem>{new LabelValueItem(Label.PG_MRR_L_All_Statuses, null)};
            Map<String,Map<String,String>> fieldMap = ParticipantEnrollmentService.FILTER_FIELD_MAP;
            if(!peList.isEmpty()) {
                Map<String, List<LabelValueItem>> filterData = getInterdependentFilterData(peList, fieldMap);
                trialFilterData.addAll(filterData.get(ParticipantEnrollmentService.STUDIES_FILTER_DATA_FIELD));
                ssFilterData.addAll(filterData.get(ParticipantEnrollmentService.STUDY_SITES_FILTER_DATA_FIELD));
                statusFilterData.addAll(filterData.get(ParticipantEnrollmentService.STATUSES_FILTER_DATA_FIELD));
                for (Integer i = 0, j = peList.size(); i < j; i++) {
                    if (peList[i].Referral_Source__c == ParticipantEnrollmentService.PE_REFERRAL_SOURCE_HCP) {
                        sourceMap.put(peList[i].HCP_Contact_HCPEnroll__c, peList[i].HCP_Contact_HCPEnroll__r.Name);
                    } else if (peList[i].Referral_Source__c == ParticipantEnrollmentService.PE_REFERRAL_SOURCE_PI) {
                        sourceMap.put(peList[i].PI_Contact__c, peList[i].PI_Contact__r.Name);
                    } else {
                        sourceMap.put(ParticipantEnrollmentService.PE_REFERRAL_SOURCE_DIGITAL_RECRUITMENT, ParticipantEnrollmentService.PE_REFERRAL_SOURCE_DIGITAL_RECRUITMENT);
                    }
                }
                for (String key : sourceMap.keySet()) {
                    peSource.add(new LabelValueItem(sourceMap.get(key), key));
                }
            }
            initData.peFilterData.studies = trialFilterData;
            initData.peFilterData.studySites = ssFilterData;
            initData.peFilterData.statuses = new List<LabelValueItem>();
            for ( LabelValueItem statusItem : statusFilterData){
                if(statusItem.value == null){
                    initData.peFilterData.statuses.add(new LabelValueItem(TranslateHelper.getLabelValue(Label.PG_MRR_L_All_Statuses), statusItem.value));
                } else {
                    initData.peFilterData.statuses.add(new LabelValueItem(TranslateHelper.getPickListLabel(Participant_Enrollment__c.Participant_Status__c, statusItem.value), statusItem.value));
                }
            }

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

    private static Boolean checkHasEmancipatedParticipants(List<Participant_Enrollment__c> peList) {
        for (Participant_Enrollment__c pe : peList) {
            if (pe.Participant__r != null && pe.Participant__r.Emancipation_in_progress__c) {
                return true;
            }
        }

        return false;
    }

    class SearchResult{
        List<PEWrapper> peList;
        PaginationData paginationData;
        ParticipantEnrollmentService.PEFilter peFilter;
        ParticipantEnrollmentService.PEFilterData peFilterData;
    }

    @AuraEnabled
    public static String getRecords(String filterJSON, String paginationJSON, String piBtnFilter, String userMode, Boolean studyChanged, String delegateId, Boolean emancipatedPE){
        ParticipantEnrollmentService.PEFilter filter = (ParticipantEnrollmentService.PEFilter)JSON.deserialize(filterJSON, ParticipantEnrollmentService.PEFilter.class);
        SearchResult result = new SearchResult();
        result.peFilterData = ParticipantEnrollmentService.getPEFilterData(filter.study, userMode, true, delegateId);
        result.peFilterData.sortVariants.addAll(new List<LabelValueItem>{
                new LabelValueItem(SortOrder.ORDER_A_Z, 'Alphabetical_ASC,Participant__r.First_Name__c,Participant__r.Last_Name__c'),
                new LabelValueItem(SortOrder.ORDER_Z_A, 'Alphabetical_DESC,Participant__r.First_Name__c,Participant__r.Last_Name__c')
        });
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
                    filter.additionalFilter += ' AND Participant_Status__c IN ' +
                            '(\'' + String.join(PEStatusState.STATUS_STEPS_TABLE[0].states.values(), '\',\'') + '\')'
                            + ' AND Non_Referral_Reason__c !=\''+ParticipantEnrollmentService.NON_REF_REASON_STATUS_HAD_DISC_NOT_INTERESTED + '\''
                            + ' AND Non_Referral_Reason__c !=\''+ParticipantEnrollmentService.NON_REF_REASON_STATUS_NOT_INTERESTED + '\''
                            + ' AND Non_Referral_Reason__c !=\''+ParticipantEnrollmentService.NON_REF_REASON_STATUS_FAILED_PE_SCREENING + '\'';
                }else{
                    filter.additionalFilter += ' AND Participant_Status__c IN ' +
                            '(\'' + String.join(PEStatusState.STATUSES_IN_PROGRESS, '\',\'') + '\')'
                            + ' AND Non_Referral_Reason__c !=\''+ParticipantEnrollmentService.NON_REF_REASON_STATUS_HAD_DISC_NOT_INTERESTED + '\''
                            + ' AND Non_Referral_Reason__c !=\''+ParticipantEnrollmentService.NON_REF_REASON_STATUS_NOT_INTERESTED + '\''
                            + ' AND Non_Referral_Reason__c !=\''+ParticipantEnrollmentService.NON_REF_REASON_STATUS_FAILED_PE_SCREENING + '\'';
                }
            }
            else if(userMode == CommunityService.USER_MODE_HCP){
                filter.additionalFilter += + ' AND Non_Referral_Reason__c !=\''+ParticipantEnrollmentService.NON_REF_REASON_STATUS_HAD_DISC_NOT_INTERESTED + '\''
                        + ' AND Non_Referral_Reason__c !=\''+ParticipantEnrollmentService.NON_REF_REASON_STATUS_NOT_INTERESTED + '\''
                        + ' AND Non_Referral_Reason__c !=\''+ParticipantEnrollmentService.NON_REF_REASON_STATUS_FAILED_PE_SCREENING + '\'';
            }
            if(emancipatedPE){
                filter.additionalFilter += ' AND Participant__r.Emancipation_in_progress__c = true ';
            }
            System.debug('additionalFilter' + filter.additionalFilter);
            result.paginationData = pagination;


            List<Participant_Enrollment__c> peList = ParticipantEnrollmentService.getParticipantEnrollments(filter, pagination, delegateId);
            List<LabelValueItem> peSource = new List<LabelValueItem>{new LabelValueItem(Label.PG_MRR_L_All_Sources, null)};
            List<LabelValueItem> trialFilterData = new  List<LabelValueItem>{new LabelValueItem(Label.PG_MRRL_L_All_studies, null)};
            List<LabelValueItem> ssFilterData = new  List<LabelValueItem>{new LabelValueItem(Label.PG_Report_L_All_study_sites, null)};
            List<LabelValueItem> statusFilterData = new  List<LabelValueItem>{new LabelValueItem(Label.PG_MRR_L_All_Statuses, null)};
            if(!peList.isEmpty()) {
                Map<String,Map<String,String>> fieldMap = ParticipantEnrollmentService.FILTER_FIELD_MAP;
                Map<String, List<LabelValueItem>> filterData = getInterdependentFilterData(peList, fieldMap);
                trialFilterData.addAll(filterData.get(ParticipantEnrollmentService.STUDIES_FILTER_DATA_FIELD));
                ssFilterData.addAll(filterData.get(ParticipantEnrollmentService.STUDY_SITES_FILTER_DATA_FIELD));
                statusFilterData.addAll(filterData.get(ParticipantEnrollmentService.STATUSES_FILTER_DATA_FIELD));
                Map<String,String> sourceMap = new Map<String,String>();
                for (Integer i = 0, j = peList.size(); i < j; i++) {
                    if (peList[i].Referral_Source__c == ParticipantEnrollmentService.PE_REFERRAL_SOURCE_HCP) {
                        sourceMap.put(peList[i].HCP_Contact_HCPEnroll__c, peList[i].HCP_Contact_HCPEnroll__r.Name);
                    } else if (peList[i].Referral_Source__c == ParticipantEnrollmentService.PE_REFERRAL_SOURCE_PI) {
                        sourceMap.put(peList[i].PI_Contact__c, peList[i].PI_Contact__r.Name);
                    } else {
                        sourceMap.put(ParticipantEnrollmentService.PE_REFERRAL_SOURCE_DIGITAL_RECRUITMENT, ParticipantEnrollmentService.PE_REFERRAL_SOURCE_DIGITAL_RECRUITMENT);
                    }
                }
                for (String key : sourceMap.keySet()) {
                    peSource.add(new LabelValueItem(sourceMap.get(key), key));
                }
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
            String filter = ' AND Participant_Status__c IN (\'' + String.join(PEStatusState.STATUS_STEPS_TABLE[4].states.get(PEStatusState.STATUS_STATE_SUCCESS), '\',\'')  + '\') ';
            filter += ' AND Participant__c=\'' + participantId + '\'' ;
            initData.alreadyEnrolled = ParticipantEnrollmentService.getPEnrolmentsCountCommon(mode, filter, delegateId) > 0;
            return JSON.serialize(initData);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
//deprecated
//    @AuraEnabled
//    public static String getStatistics(String mode, String delegateId){
//        try{
//            return JSON.serialize(MyPatientsStatistics.getStatistics(TrialService.getAvailableTrialIds(mode, delegateId), mode));
//        }catch (Exception e){
//            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
//        }
//    }

    private static List<PEWrapper> convertToPEWrapperList(List<Participant_Enrollment__c> participantEnrollments, String userMode){
        return convertToPEWrapperList(participantEnrollments, userMode, null);
    }
    private static List<PEWrapper> convertToPEWrapperList(List<Participant_Enrollment__c> participantEnrollments, String userMode, String delegateId){
        List<PEWrapper> resultList = new List<PEWrapper>();
        List<ParticipantItem> participantItems = new List<ParticipantItem>();
        Set<Id> idParticipants = new Set<Id>();
        Set<Id> idParticipantsOnUser = new Set<Id>();
        for (Participant_Enrollment__c pe : participantEnrollments) {
            idParticipants.add(pe.Participant_Contact__c);
        }
        Map<Id, User> usersMapId = new Map<Id, User>([
                                                        SELECT
                                                                Id,
                                                                ContactId
                                                        FROM User
                                                        WHERE  ContactId
                                                        IN : idParticipants
        ]);
        for (User us : usersMapId.values()) {
            idParticipantsOnUser.add(us.ContactId);
        }
        for (Participant_Enrollment__c pe : participantEnrollments) {
            PEWrapper newPeWrapper;
            if (userMode == CommunityService.USER_MODE_HCP) {
                newPeWrapper = new PEWrapper(pe, new StudyActionsHCP(pe, delegateId).actions);
                resultList.add(newPeWrapper);
                participantItems.add(newPeWrapper.pItem);
            } else {
                if (userMode == CommunityService.USER_MODE_PI) {
                    if (pe.Participant_Contact__c != null && idParticipantsOnUser.contains(pe.Participant_Contact__c)) {
                        newPeWrapper = new PEWrapper(pe, new StudyActionsPI(pe).actions, true);
                        resultList.add(newPeWrapper);
                        participantItems.add(newPeWrapper.pItem);
                    } else {
                        newPeWrapper = new PEWrapper(pe, new StudyActionsPI(pe).actions, false);
                        resultList.add(newPeWrapper);
                        participantItems.add(newPeWrapper.pItem);
                    }
                } else {
                    newPeWrapper = new PEWrapper(pe, new StudyActionsPI(pe).actions);
                    resultList.add(newPeWrapper);
                    participantItems.add(newPeWrapper.pItem);
                }
            }
        }
        ParticipantWorkflowService.populatePatientItemsWithPathWrappers(participantItems);
        return resultList;
    }

    public static Map<String, List<LabelValueItem>> getInterdependentFilterData(List<SObject> recordsList, Map<String, Map<String, String>> fieldMapping) {
        try {
            Map<String, Map<String, String>> filterData = new Map<String, Map<String, String>>();
            for (SObject obj : recordsList) {
                for (String key : fieldMapping.keySet()) {
                    String fieldLabelValue;
                    String fieldValue;
                    Map<String, String> fields = fieldMapping.get(key);
                        String valueKey = new List<String>(fields.keySet()).get(0);
                        String labelKey = fields.get(valueKey);
                        List<String> fieldsForValues = valueKey.split('\\.');
                        List<String> fieldsForLabels = labelKey.split('\\.');
                        SObject valuesObject = obj;
                        SObject labelObject = obj;
                        for (Integer i = 0, j = fieldsForValues.size(); i < j; i++) {
                            if (i + 1 != j) {
                                valuesObject = valuesObject.getSObject(fieldsForValues[i]);
                            } else {
                                fieldValue = String.valueOf(valuesObject.get(fieldsForValues[i]));
                            }
                        }
                        for (Integer x = 0, y = fieldsForLabels.size(); x < y; x++) {
                            if (x + 1 != y) {
                                labelObject = labelObject.getSObject(fieldsForLabels[x]);
                            } else {
                                fieldLabelValue = String.valueOf(labelObject.get(fieldsForLabels[x]));
                            }
                        }
                    if (filterData.containsKey(key)) {
                        filterData.get(key).put(fieldValue, fieldLabelValue);
                    } else {
                        filterData.put(key, new Map<String, String>{
                                fieldValue => fieldLabelValue
                        });
                    }
                }
            }
            Map<String, List<LabelValueItem>> finalfilterData = new Map<String, List<LabelValueItem>>();
            for (String key : filterData.keySet()) {
                Map<String, String> data = filterData.get(key);
                List<LabelValueItem> dataItems = new List<LabelValueItem>();
                for (String dataKey : data.keySet()) {
                    dataItems.add(new LabelValueItem(data.get(dataKey), dataKey));
                }
                finalfilterData.put(key, dataItems);
            }
            return finalfilterData;
        } catch (Exception e) {
            return (Map<String, List<LabelValueItem>>) AuraHelper.throwException(e);
        }
    }
}
