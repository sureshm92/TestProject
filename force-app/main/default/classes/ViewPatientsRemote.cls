/**
 * Created by Leonid Bartenev
 */

public without sharing class ViewPatientsRemote {

    public static final List<String> EXCLUDED_STATUSES_COMMON = new List<String>{
            ParticipantEnrollmentService.PART_STATUS_FAILED_REVIEW,
            ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL,
            ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING
    };
    public static final List<String> EXCLUDED_STATUSES_PI = new List<String>{
            ParticipantEnrollmentService.PART_STATUS_FAILED_REVIEW,
            ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL,
            ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING,
            ParticipantEnrollmentService.PART_STATUS_FAILED_REFERRAL
    };
    public static final List<String> EXCLUDED_REASONS = new List<String>{
            ParticipantEnrollmentService.NON_REF_REASON_STATUS_HAD_DISC_NOT_INTERESTED,
            ParticipantEnrollmentService.NON_REF_REASON_STATUS_FAILED_PE_SCREENING,
            ParticipantEnrollmentService.NON_REF_REASON_STATUS_NOT_INTERESTED
    };

    @AuraEnabled
    public static String getInitData(Id trialId, Id siteId, String userMode, String delegateId) {
        try{
            InitData initData = new InitData();
            String additionalFilter = getAdditionalFilter(userMode, false, null);
            initData.paginationData = new PaginationData();
            initData.peFilterData = createPEFilterData(userMode == 'PI' ? 'Active' : null, trialId, siteId, userMode, true, delegateId, additionalFilter);
            initData.peFilter = new ParticipantEnrollmentService.PEFilter(initData.peFilterData);
            initData.peFilter.studySite = siteId;
            initData.peFilter.study = trialId;
            initData.peFilter.activePE = userMode == 'PI' ? 'Active' : null;
            initData.peFilter.searchFields = new List<String>{
                    'Participant__r.First_Name__c',
                    'Participant__r.Last_Name__c',
                    'Screening_ID__c',
                    'Name'
            };
            initData.peFilter.additionalFilter = additionalFilter;
            List<Participant_Enrollment__c> peList = ParticipantEnrollmentService.getParticipantEnrollments(initData.peFilter, delegateId);
            initData.hasEmancipatedParticipants = checkHasEmancipatedParticipants(peList);
            peList = ParticipantEnrollmentService.getParticipantEnrollmentsPaginated(peList, initData.paginationData);
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

    @AuraEnabled
    public static String getRecords(String filterJSON, String paginationJSON, String userMode, String changedItem, String delegateId, Boolean emancipatedPE) {
        try {
        SearchResult result = new SearchResult();
            result.peFilter = (ParticipantEnrollmentService.PEFilter) JSON.deserialize(filterJSON, ParticipantEnrollmentService.PEFilter.class);
            result.paginationData = (PaginationData) JSON.deserialize(paginationJSON, PaginationData.class);
            result.peFilter.additionalFilter = getAdditionalFilter(userMode, emancipatedPE, null);
            updateSearchResultAccordingItemChanged(result, changedItem);
            if(changedItem != 'pagination'){
                result.peFilterData = createPEFilterData(result.peFilter.activePE, result.peFilter.study,result.peFilter.studySite, userMode, true, delegateId, result.peFilter.additionalFilter);
            }
            List<Participant_Enrollment__c> peList = ParticipantEnrollmentService.getParticipantEnrollments(result.peFilter, delegateId);
            peList = ParticipantEnrollmentService.getParticipantEnrollmentsPaginated(peList, result.paginationData);
            result.peList = convertToPEWrapperList(peList, userMode, delegateId);
            return JSON.serialize(result);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String getInitDataForPatientProfile(Id participantId, String mode, String delegateId){
        try{
            InitDataForPatientProfile initData = new InitDataForPatientProfile();
            //filters data:
            ParticipantEnrollmentService.PEFilterData peFilterData = ParticipantEnrollmentService.getPEFilterData(null, mode, false, delegateId);
            //init filters:
            ParticipantEnrollmentService.PEFilter peFilter = new ParticipantEnrollmentService.PEFilter(peFilterData);
            peFilter.additionalFilter = getAdditionalFilter(mode, false, participantId);
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

    private static Boolean checkHasEmancipatedParticipants(List<Participant_Enrollment__c> peList) {
        for (Participant_Enrollment__c pe : peList) {
            if (pe.Participant__r != null && pe.Participant__r.Emancipation_in_progress__c) {
                return true;
            }
        }
        return false;
    }

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

    private static String getAdditionalFilter(String mode, Boolean emancipatedPE, Id participantId) {

        String filter = ' Participant_Status__c NOT IN ' + DatabaseService.listToString((mode != CommunityService.USER_MODE_PI || participantId != null) ? EXCLUDED_STATUSES_COMMON : EXCLUDED_STATUSES_PI);
        if (mode == CommunityService.USER_MODE_HCP && participantId == null) {
            filter += ' AND Non_Referral_Reason__c NOT IN ' + DatabaseService.listToString(EXCLUDED_REASONS);
        }
        if (emancipatedPE) {
            filter += ' AND Participant__r.Emancipation_in_progress__c = true ';
        }
        if (participantId != null) {
            filter += ' AND Participant__c=\'' + participantId + '\'' ;
        }

        return filter;
    }

    private static ParticipantEnrollmentService.PEFilterData createPEFilterData(String activePE, Id trialId, Id siteId, String mode, Boolean restrictTrial, String delegateId, String additionalFilter) {
        ParticipantEnrollmentService.PEFilterData filterData = ParticipantEnrollmentService.getPEFilterDataWithExistingPERecords(activePE, trialId, mode, restrictTrial, delegateId);
        ParticipantEnrollmentService.PEFilter filter = new ParticipantEnrollmentService.PEFilter(filterData);
        filter.activePE = activePE;
        filter.study = trialId;
        filter.studySite = siteId;
        filter.additionalFilter = additionalFilter;
        filterData.dateField = 'Referred_Date__c';
        filterData.sortVariants.addAll(new List<LabelValueItem>{
                new LabelValueItem(SortOrder.ORDER_A_Z, 'Alphabetical_ASC,Participant__r.First_Name__c,Participant__r.Last_Name__c'),
                new LabelValueItem(SortOrder.ORDER_Z_A, 'Alphabetical_DESC,Participant__r.First_Name__c,Participant__r.Last_Name__c')
        });
        List<LabelValueItem> peSource = new List<LabelValueItem>{
                new LabelValueItem(Label.PG_MRR_L_All_Sources, null)
        };
        Map<String, String> sourceMap = new Map<String, String>();
//        List<LabelValueItem> trialFilterData = new List<LabelValueItem>{
//                new LabelValueItem(Label.PG_MRRL_L_All_studies, null)
//        };
//        List<LabelValueItem> ssFilterData = new List<LabelValueItem>{
//                new LabelValueItem(Label.PG_Report_L_All_study_sites, null)
//        };
        List<LabelValueItem> statusFilterData = new List<LabelValueItem>{
                new LabelValueItem(Label.PG_MRR_L_All_Statuses, null)
        };
        Map<String, Map<String, String>> fieldMap = ParticipantEnrollmentService.FILTER_FIELD_MAP;
        List<Participant_Enrollment__c> peList = ParticipantEnrollmentService.getParticipantEnrollments(filter, delegateId);
        if (!peList.isEmpty()) {
            Map<String, List<LabelValueItem>> filterDataMap = getInterdependentFilterData(peList, fieldMap);
//            trialFilterData.addAll(filterDataMap.get(ParticipantEnrollmentService.STUDIES_FILTER_DATA_FIELD));
//            ssFilterData.addAll(filterDataMap.get(ParticipantEnrollmentService.STUDY_SITES_FILTER_DATA_FIELD));
            statusFilterData.addAll(filterDataMap.get(ParticipantEnrollmentService.STATUSES_FILTER_DATA_FIELD));
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
//        filterData.studies = trialFilterData;
//        filterData.studySites = ssFilterData;
        filterData.statuses = new List<LabelValueItem>();
        for (LabelValueItem statusItem : statusFilterData) {
            if (statusItem.value == null) {
                filterData.statuses.add(new LabelValueItem(TranslateHelper.getLabelValue(Label.PG_MRR_L_All_Statuses), statusItem.value));
            } else {
                filterData.statuses.add(new LabelValueItem(TranslateHelper.getPickListLabel(Participant_Enrollment__c.Participant_Status__c, statusItem.value), statusItem.value));
            }
        }
        filterData.source = peSource;
        return filterData;
    }

    private static Boolean labelValueItemsHaveItem(List<LabelValueItem> labelValueItems, String item){
        for (LabelValueItem lvi : labelValueItems){
            if(lvi.value == item){
                return true;
            }
        }
        return false;
    }

    private static void updateSearchResultAccordingItemChanged(SearchResult result, String changedItem){
        if (changedItem == 'active') {
            result.peFilter.study = null;
        }
        if (changedItem == 'active' || changedItem == 'study') {
            result.peFilter.studySite = null;
        }
        if (changedItem == 'active' || changedItem == 'study' || changedItem == 'site') {
            result.peFilter.source = null;
            result.peFilter.dateRange = null;
            result.peFilter.participantStatus = null;
            result.peFilter.referringStatus = null;
        }
        if (changedItem != 'pagination') {
            result.paginationData.currentPage = 1;
        }
    }

    public class InitData {
        public ParticipantEnrollmentService.PEFilter peFilter;
        public ParticipantEnrollmentService.PEFilterData peFilterData;
        public List<PEWrapper> currentPageList;
        public PaginationData paginationData;
        public List<Id> trialIds;
        public Map<String, PEStatusState> peStatusStateMap = PEStatusState.STATUSES_MAP;
        public List<String> peStatusesPathList = PEStatusState.STATUS_STEPS_LIST;
        public Boolean isInvited;
        public Boolean hasEmancipatedParticipants;
    }

    public class SearchResult {
        List<PEWrapper> peList;
        PaginationData paginationData;
        ParticipantEnrollmentService.PEFilter peFilter;
        ParticipantEnrollmentService.PEFilterData peFilterData;
    }

    public class PEWrapper {
        public boolean isInvited;
        public Boolean hasEmancipatedParticipants;
        public ParticipantItem pItem;
        public Map<String, StudyActions.Action> actions;
        public List<StudyActions.Action> participantCardActions;
        public List<StudyActions.Action> healthcareProviderActions;

        public PEWrapper(Participant_Enrollment__c pe, Map<String, StudyActions.Action> actions) {
            this.pItem = new ParticipantItem(pe);
            this.actions = actions;
        }
        public PEWrapper(Participant_Enrollment__c pe, Map<String, StudyActions.Action> actions, Boolean isInvited) {
            this.pItem = new ParticipantItem(pe);
            this.actions = actions;
            this.isInvited = isInvited;
            this.hasEmancipatedParticipants = pe.Participant__r != null ? pe.Participant__r.Emancipation_in_progress__c : false;
        }
    }

    class InitDataForPatientProfile {
        Participant__c participant;
        List<Participant_Enrollment__c> peList;
        Map<String, PEStatusState> peStatusStateMap = PEStatusState.STATUSES_MAP;
        List<String> peStatusesPathList = PEStatusState.STATUS_STEPS_LIST;
        Boolean alreadyEnrolled = false;
    }

}
