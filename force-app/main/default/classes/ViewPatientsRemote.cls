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

    public static final List<String> PE_MY_PARTICIPANTS_FIELDS = new List<String>{
            'Id',
            'Clinical_Trial_Profile__c',
            'Clinical_Trial_Profile__r.Id',
            'Clinical_Trial_Profile__r.Study_Sponsor__c',
            'Clinical_Trial_Profile__r.Study_Title__c',
            'Clinical_Trial_Profile__r.Study_Code_Name__c',
            'Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c',
            'Clinical_Trial_Profile__r.Link_to_Pre_screening__c',
            'Clinical_Trial_Profile__r.Protocol_ID__c',
            'Clinical_Trial_Profile__r.CommunityTemplate__c',
            'Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c',
            'CreatedDate',
            'Enrolled_Date__c',
            'Enrolled_DateTime__c',
            'HCP__r.HCP_Contact__r.Name',
            'Days_After_Enrolled__c',
            'Informed_Consent__c',
            'Is_Virtual_Study_Site__c',
            'IsSubjectIDverifiedInSDH__c',
            'Medical_Record_Review_Status__c',
            'Medical_Record_Review_Completedby_Name__c',
            'Motivational_Message_Id__c',
            'MRN_Id__c',
            'MRR_Survey_Results_URL__c',
            'Name',
            'Non_Referral_Reason__c',
            'Patient_ID__c',
            'Participant_Status__c',
            'Participant_Status_Last_Changed_Date__c',
            'Participant__c',
            'Participant__r.Adult__c',
            'Participant__r.Marketing_Flag__c',
            'Participant__r.Emancipation_in_progress__c',
            'Participant__r.First_Name__c',
            'Participant__r.Last_Name__c',
            'Participant__r.Middle_Name__c',
            'Participant__r.Full_Name__c',
            'Participant__r.Nickname__c',
            'Participant__r.Suffix__c',
            'Participant__r.Preferred_Language__c',
            'Participant__r.Date_of_Birth__c',
            'Participant__r.Birth_Year__c',
            'Participant__r.Gender__c',
            'Participant__r.Email__c',
            'Participant__r.IsCountry_NOT_Eligible_for_Emails__c',
            'Participant__r.Phone__c',
            'Participant__r.Phone_Type__c',
            'Participant__r.Alternative_Phone_Number__c',
            'Participant__r.Alternative_Phone_Type__c',
            'Participant__r.Mailing_State__c',
            'Participant__r.Mailing_City__c',
            'Participant__r.Mailing_State_Code__c',
            'Participant__r.Mailing_Country__c',
            'Participant__r.Mailing_Country_Code__c',
            'Participant__r.Mailing_Zip_Postal_Code__c',
            'Participant__r.Conditions__c',
            'Participant__r.Contact__c',
            'Participant_Contact__c',
            'PI_Contact__r.Name',
            'PI_Contact__r.Phone',
            'Pre_screening_Status__c',
            'Pre_Eligibility_Date__c',
            'Referred_Date__c',
            'Referred_By__c',
            'Referral_ID__c',
            'Referral_Source__c',
            'Referral_Completedby_Name__c',
            'Source_Type__c',
            'IVRS_IWRS__c',
            'Show_Referring_Provider__c',
            'Study_Name__c',
            'Study_Site__c',
            'Study_Site__r.Id',
            'Study_Site__r.Name',
            'Study_Site__r.Is_Virtual_Study_Site__c',
            'Study_Site__r.Study_Site_Type__c',
            'Study_Site__r.Approved_Lng__c',
            'Study_Site__r.Override_PI_Referral_Status__c',
            'Study_Site__r.Clinical_Trial_Profile__c',
            'Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Brief_Summary__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Study_Sponsor__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Study_Title__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Link_to_Pre_screening__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Override_Recruitment_Status__c',
            'Study_Site__r.Study_Site_Phone__c',
            'Study_Site__r.Visit_Results_Sharing__c',
            'Study_Site__r.Messages_Are_Available__c',
            'Study_Site__r.SMS_Are_Available__c',
            'Screening_ID__c',
            'Washout_Run_In_Applies__c',
            'Final_Consent_Date__c',
            'Informed_Consent_Date__c',
            'Initial_visit_occurred_flag__c',
            'Initial_visit_occurred_date__c',
            'Initial_visit_scheduled_date__c',
            'Initial_visit_scheduled_time__c',
            'PI_Contact__c',
            'Initial_visit_scheduled_flag__c',
            'Revisit_Date__c',
            'Final_consent__c',
            'Non_Enrollment_Reason__c',
            'Last_Status_Changed_Notes__c',
            'HCP_Contact_HCPEnroll__c',
            'HCP_Contact_HCPEnroll__r.Name',
            'HCP__r.Status__c'
    };

    @AuraEnabled
    public static String getInitData(Id trialId, Id siteId, String userMode, String delegateId,String sponsorName) {
        try{
            InitData initData = new InitData();
            String additionalFilter = getAdditionalFilter(userMode, false, null,sponsorName);
            initData.paginationData = new PaginationData();
            initData.peFilterData = createPEFilterData(userMode == 'PI' ? 'Active' : null, trialId, siteId, userMode, true, delegateId, additionalFilter,initData.paginationData, sponsorName);
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
            List<Participant_Enrollment__c> peList;
            if(userMode != CommunityService.USER_MODE_PI) {
                //Needs review
                peList = ParticipantEnrollmentService.getParticipantEnrollments(initData.peFilter, delegateId,sponsorName);              
            }
            else {
                peList = ParticipantEnrollmentService.getParticipantEnrollmentsCustomFields(PE_MY_PARTICIPANTS_FIELDS, initData.peFilter, delegateId, false,initData.paginationData, sponsorName);           
            }
            initData.hasEmancipatedParticipants = false;
            //peList = ParticipantEnrollmentService.getParticipantEnrollmentsPaginated(peList, initData.paginationData);
            if (userMode == CommunityService.USER_MODE_PI) {
                TranslateHelper.translate(peList);
            }
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
    public static String getRecords(String filterJSON, String paginationJSON, String userMode, String changedItem, String delegateId, Boolean emancipatedPE,String sponsorName) {
        try {
            SearchResult result = new SearchResult();
            result.peFilter = (ParticipantEnrollmentService.PEFilter) JSON.deserialize(filterJSON, ParticipantEnrollmentService.PEFilter.class);
            result.paginationData = (PaginationData) JSON.deserialize(paginationJSON, PaginationData.class);
            result.peFilter.additionalFilter = getAdditionalFilter(userMode, emancipatedPE, null,sponsorName);
            updateSearchResultAccordingItemChanged(result, changedItem);
            result.peFilterData = createPEFilterData(result.peFilter.activePE, result.peFilter.study,result.peFilter.studySite, userMode, true, delegateId, result.peFilter.additionalFilter,result.paginationData, sponsorName);
            List<Participant_Enrollment__c> peList;
            if(userMode != CommunityService.USER_MODE_PI){
                peList = ParticipantEnrollmentService.getParticipantEnrollments(result.peFilter, delegateId,sponsorName);
            }
            else{
                peList = ParticipantEnrollmentService.getParticipantEnrollmentsCustomFields(PE_MY_PARTICIPANTS_FIELDS, result.peFilter, delegateId, false,result.paginationData,sponsorName);
            }
            //peList = ParticipantEnrollmentService.getParticipantEnrollmentsPaginated(peList, result.paginationData);
            if (userMode == CommunityService.USER_MODE_PI) {
                TranslateHelper.translate(peList);
            }
            result.peList = convertToPEWrapperList(peList, userMode, delegateId);
            return JSON.serialize(result);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String getInitDataForPatientProfile(Id participantId, String mode, String delegateId,String sponsorName){
        try{
            InitDataForPatientProfile initData = new InitDataForPatientProfile();
            //filters data:
            ParticipantEnrollmentService.PEFilterData peFilterData = ParticipantEnrollmentService.getPEFilterData(null, mode, false, delegateId);
            //init filters:
            ParticipantEnrollmentService.PEFilter peFilter = new ParticipantEnrollmentService.PEFilter(peFilterData);
            peFilter.additionalFilter = getAdditionalFilter(mode, false, participantId,sponsorName);
            //retrieve records:
            initData.peList = ParticipantEnrollmentService.getParticipantEnrollments(peFilter, null, delegateId,sponsorName);
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

    private static String getAdditionalFilter(String mode, Boolean emancipatedPE, Id participantId,String sponsorName) {

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
        //Added filter janssen
        if (sponsorName == CommunityTemplateService.TEMPLATE_JANSSEN) {
            filter += ' AND Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c = \'' + CommunityTemplateService.TEMPLATE_JANSSEN + '\' ';
        } else {
            filter += ' AND Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c != \'' + CommunityTemplateService.TEMPLATE_JANSSEN + '\' ';
        }

        return filter;
    }

    // Modified for performance tuning
    // Sabir & Velu 09/04/2020
    private static ParticipantEnrollmentService.PEFilterData createPEFilterData(String activePE, Id trialId, Id siteId, String mode, Boolean restrictTrial, String delegateId, String additionalFilter, PaginationData paginationData,String sponsorName) {
        //ParticipantEnrollmentService.PEFilterData filterData = ParticipantEnrollmentService.getPEFilterDataWithExistingPERecords(activePE, trialId, mode, restrictTrial, delegateId, additionalFilter,sponsorName);
        ParticipantEnrollmentService.PEFilterData filterData = ParticipantEnrollmentService.getPEFilterDataWithSponsor(mode, trialId, restrictTrial, delegateId , sponsorName);
        ParticipantEnrollmentService.PEFilter filter = new ParticipantEnrollmentService.PEFilter(filterData);
        filter.activePE = activePE;
        filter.study = trialId;
        filter.studySite = siteId;
        filter.additionalFilter = additionalFilter;
        filterData.dateField = 'Referred_Date__c';
        filterData.sortVariants.addAll(new List<LabelValueItem> {
                new LabelValueItem(SortOrder.ORDER_A_Z, 'Alphabetical_ASC,Participant__r.First_Name__c,Participant__r.Last_Name__c'),
                new LabelValueItem(SortOrder.ORDER_Z_A, 'Alphabetical_DESC,Participant__r.First_Name__c,Participant__r.Last_Name__c')
        });
        List<LabelValueItem> peSource = new List<LabelValueItem> {
                new LabelValueItem(Label.PG_MRR_L_All_Sources, null),
                new LabelValueItem(Label.Referring_Provider,'Referring Provider'),
                new LabelValueItem(Label.Principal_Investigator,'Principal Investigator'),
                new LabelValueItem(Label.Digital_Recruitment,'Digital Recruitment')
        };

        List<LabelValueItem> statusFilterData ;
        if(activePE == 'Active') {
            statusFilterData = new List<LabelValueItem>{
                    new LabelValueItem(Label.PG_MRR_L_All_Statuses, null),
                    new LabelValueItem(Label.Received, 'Received'),
                    new LabelValueItem(Label.Contact_Attempted, 'Contact Attempted'),
                    new LabelValueItem(Label.Successfully_Contacted, 'Successfully Contacted'),
                    new LabelValueItem(Label.Screening_In_Progress, 'Screening In Progress'),
                    new LabelValueItem(Label.In_Wash_Out_Period, 'Screening In Progress - Wash Out Period'),
                    new LabelValueItem(Label.Screening_Passed, 'Screening Passed'),
                    new LabelValueItem(Label.Enrollment_Success, 'Enrollment Success'),
                    new LabelValueItem(Label.Eligibility_Passed, 'Eligibility Passed'),
                    new LabelValueItem(Label.Ready_to_Screen, 'Ready to Screen'),
                    new LabelValueItem(Label.Randomization_Success, 'Randomization Success')
            };
        } else {
            statusFilterData = new List<LabelValueItem>{
                new LabelValueItem(Label.PG_MRR_L_All_Statuses, null),
                new LabelValueItem(Label.Unable_to_Reach, 'Unable to Reach'),
                new LabelValueItem(Label.Contacted_Not_Suitable, 'Contacted - Not Suitable'),
                new LabelValueItem(Label.Eligibility_Failed, 'Eligibility Failed'),
                new LabelValueItem(Label.Declined_Consent, 'Declined Consent'),
                new LabelValueItem(Label.Unable_to_Screen, 'Unable to Screen'),
                new LabelValueItem(Label.Withdrew_Consent, 'Withdrew Consent'),
                new LabelValueItem(Label.Screening_Failed, 'Screening Failed'),
                new LabelValueItem(Label.Withdrew_Consent_After_Screening, 'Withdrew Consent After Screening'),
                new LabelValueItem(Label.Enrollment_Failed, 'Enrollment Failed'),
                new LabelValueItem(Label.Randomization_Failed, 'Randomization Failed')
            };
        } 
        filterData.statuses = statusFilterData;
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
        if (changedItem == 'active' || changedItem == 'emancipation') {
            result.peFilter.study = null;
        }
        if (changedItem == 'active' || changedItem == 'emancipation' || changedItem == 'study') {
            result.peFilter.studySite = null;
        }
        if (changedItem == 'active' || changedItem == 'emancipation' || changedItem == 'study' || changedItem == 'site') {
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