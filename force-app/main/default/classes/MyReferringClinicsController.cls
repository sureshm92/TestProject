/**
 * Created by D.Yasinskyi on 30.03.2018
 */
public without sharing class MyReferringClinicsController {
    private static List<String> ENROLLMENT_SEARCH_FIELDS = new List<String>{
            'HCP_Contact__r.Account.Name',
            'HCP_Name__c',
            'Study_Site__r.Name',
            'Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c'
    };
    @AuraEnabled
    public static String getInitData(String trialId, String ssId) {
        InitData initData;
        try {
            initData = new InitData(trialId, ssId);
            getInitDataEnrollments(initData);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
        return JSON.serialize(initData);
    }
    @AuraEnabled
    public static String searchReferringClinics(String filterValuesJSON, String sortDataJSON, String paginationDataJSON, Boolean trialChanged) {
        InitData initData;
        try {
            FilterValues filterValues = (FilterValues) JSON.deserialize(filterValuesJSON, FilterValues.class);
            SortData sortData = (SortData) JSON.deserialize(sortDataJSON, SortData.class);
            PaginationData paginationData = (PaginationData) JSON.deserialize(paginationDataJSON, PaginationData.class);
            if (trialChanged) {
                filterValues.ssId = '';
            }
            initData = new InitData(filterValues, sortData, paginationData);
            getInitDataEnrollments(initData);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
        return JSON.serialize(initData);
    }

    private static void getInitDataEnrollments(InitData initData) {
        List<HCP_Enrollment__c> enrollments = new List<HCP_Enrollment__c>();
        if (initData.filterValues.ssId != null && initData.filterValues.ssId != '') {
            if(initData.filterValues.statusFilter == ''){
                enrollments = HCPEnrollmentService.getEnrollmentsForPIByStudySiteId(
                        initData.filterValues.ssId,
                        null,
                        false,
                        initData.sortData.sortType
                );
            }
            else{
                enrollments = HCPEnrollmentService.getEnrollmentsForPIByStudySiteId(
                        initData.filterValues.ssId,
                        new List<String>{
                                initData.filterValues.statusFilter
                        },
                        false,
                        initData.sortData.sortType
                );
            }
        } else {
            Set<Id> trialIds = new Set<Id>();
            if (initData.filterValues.trialId != null && initData.filterValues.trialId != '') {
                trialIds.add(initData.filterValues.trialId);
            } else {
                for (LabelValueItem trialOptions : initData.filterData.studyPickList) {
                    if (trialOptions.value != '') {
                        trialIds.add(trialOptions.value);
                    }
                }
            }
            if(initData.filterValues.statusFilter == ''){
                enrollments = HCPEnrollmentService.getEnrollmentsForPIByTrialIds(
                        trialIds, new List<String>{
                                HCPEnrollmentService.HCP_S_INVITATION_SENT
                        },
                        true,
                        initData.sortData.sortType
                );
            }
            else {
                enrollments = HCPEnrollmentService.getEnrollmentsForPIByTrialIds(
                        trialIds, new List<String>{
                                initData.filterValues.statusFilter
                        },
                        false,
                        initData.sortData.sortType
                );
            }
        }
        if (initData.filterValues.searchText != '') {
            List<HCP_Enrollment__c> searchList = new List<HCP_Enrollment__c>();
            for (HCP_Enrollment__c enrollment : enrollments) {
                for (String field : ENROLLMENT_SEARCH_FIELDS) {
                    String fieldValue = getFieldValue( enrollment,field);
                    if (fieldValue != null && fieldValue.indexOfIgnoreCase(initData.filterValues.searchText) != -1) {
                        searchList.add(enrollment);
                        break;
                    }
                }
            }
            enrollments = searchList;
        }
        if (initData.paginationData != null) {
            initData.paginationData.setRecordsCount(enrollments.size());
            List<HCP_Enrollment__c> pageList = new List<HCP_Enrollment__c>();
            for (Integer i = initData.paginationData.offset; i < initData.paginationData.endOffset; i++) {
                pageList.add(enrollments[i]);
            }
            enrollments = pageList;
        }
        initData.filteredReferringClinics = getEnrollmentWrappers(enrollments);
    }
    private static List<MyReferringClinicsController.ClinicWrapper> getEnrollmentWrappers(List<HCP_Enrollment__c> enrollments) {
        List<MyReferringClinicsController.ClinicWrapper> result = new List<MyReferringClinicsController.ClinicWrapper>();
        Map<Id, List<HCP_Enrollment__c>> clinicEnrolmentMap = new Map<Id, List<HCP_Enrollment__c>>();
        for (HCP_Enrollment__c enroll : enrollments) {
            if (!clinicEnrolmentMap.containsKey(enroll.HCP_Contact__r.AccountId)) {
                clinicEnrolmentMap.put(enroll.HCP_Contact__r.AccountId, new List<HCP_Enrollment__c>());
            }
            clinicEnrolmentMap.get(enroll.HCP_Contact__r.AccountId).add(enroll);
        }
        for (Id accId : clinicEnrolmentMap.keySet()) {
            result.add(new ClinicWrapper(clinicEnrolmentMap.get(accId)));
        }
        return result;
    }
    public static List<LabelValueItem> getInitStatusOptions() {
        List<LabelValueItem> enrollmentStatusOptions = new List<LabelValueItem>();
        for (Schema.PicklistEntry ple : HCP_Enrollment__c.Status__c.getDescribe().getPicklistValues()) {
            if (HCPEnrollmentService.HCP_E_S_INVISIBLE_ON_STUDY_SITE_P.contains(ple.getValue())) continue;
            enrollmentStatusOptions.add(new LabelValueItem(ple.getLabel(), ple.getValue()));
        }
        return enrollmentStatusOptions;
    }
    private static String getFieldValue(SObject obj, String fieldName) {
        SObject tempSObject = obj;
        List<String> fieldPath = fieldName.split('\\.');
        for (Integer i = 0; i < fieldPath.size() - 1; i++) {
            tempSObject = tempSObject.getSObject(fieldPath[i]);
        }
        return (String) tempSObject.get(fieldPath[fieldPath.size() - 1]);
    }

    public class ClinicWrapper {
        public Account clinic;
        public List<MyReferringClinicsController.HCPEnrollmentWrapper> enrollments = new List<MyReferringClinicsController.HCPEnrollmentWrapper>();

        public ClinicWrapper(List<HCP_Enrollment__c> enrollments) {
            if (enrollments != null && !enrollments.isEmpty()) {
                this.clinic = enrollments[0].HCP_Contact__r.Account;
                for (HCP_Enrollment__c enrollment : enrollments) {
                    this.enrollments.add(new HCPEnrollmentWrapper(enrollment));
                }
            }
        }
    }

    public class HCPEnrollmentWrapper {
        HCP_Enrollment__c enrollment;
        String status;
        String statusLabel;
        List<StudyActions.Action> buttonList = new List<StudyActions.Action>();
        public HCPEnrollmentWrapper(HCP_Enrollment__c hcpEnrollment) {
            Map<String, StudyActions.Action> actionsMap = new StudyActionsPI(hcpEnrollment).actions;
            status = CommunityService.getConvertedStatus(hcpEnrollment.Status__c);
            statusLabel = TranslateHelper.getPickListLabel(HCP_Enrollment__c.Status__c, hcpEnrollment.Status__c);
            enrollment = hcpEnrollment;

            Map<String, String> actionToStatusesMap = HCPEnrollmentService.HCP_CHANGE_STATUS_MAP.get(hcpEnrollment.Status__c);
            if (actionToStatusesMap != null) {
                for (String actionId : actionToStatusesMap.keySet()) {
                    buttonList.add(actionsMap.get(actionId));
                }
            }
        }
    }
    public class InitData {
        FilterData filterData;
        FilterValues filterValues;
        SortData sortData;
        PaginationData paginationData;
        public List<MyReferringClinicsController.ClinicWrapper> filteredReferringClinics;
        public String trialId;
        public String ssId;
        public InitData(String trialId, String ssId) {
            this.trialId = trialId;
            this.ssId = ssId;
            filteredReferringClinics = new List<MyReferringClinicsController.ClinicWrapper>();
            filterValues = new FilterValues(trialId, ssId, '');
            filterData = new FilterData(filterValues);
            sortData = new SortData();
            paginationData = new PaginationData();
        }
        public InitData(FilterValues filterValues, SortData sortData, PaginationData paginationData) {
            filteredReferringClinics = new List<MyReferringClinicsController.ClinicWrapper>();
            this.trialId = filterValues.trialId;
            this.ssId = filterValues.ssId;
            this.filterValues = filterValues;
            this.filterData = new FilterData(filterValues);
            this.sortData = sortData;
            this.paginationData = paginationData;
        }
    }
    public class FilterValues {
        public String searchText = '';
        public String statusFilter = '';
        public String statusFilterPlaceholder = Label.PG_MRZ_L_Provider_Status;
        public String trialId;
        public String ssId;
        public FilterValues(String trialId, String ssId, String statusFilter) {
            this.trialId = trialId;
            this.ssId = ssId;
            this.statusFilter = statusFilter;
        }

    }
    public class FilterData {
        public String searchTextPlaceholder = Label.PG_MRZ_L_Search_for_a_referring_clinic;
        public List<LabelValueItem> statusOptions = new List<LabelValueItem>();
        public List<LabelValueItem> studyPickList;
        public List<LabelValueItem> studySitePickList;
        public FilterData(FilterValues filterValues) {
            statusOptions = getInitStatusOptions();
            studyPickList = new List<LabelValueItem>{
                    new LabelValueItem(Label.PG_MRRL_L_All_studies, null)
            };
            studySitePickList = new List<LabelValueItem>{
                    new LabelValueItem(Label.PG_Report_L_All_study_sites, null)
            };
            List<Study_Site__c> studySites = StudySiteService.getStudySitesForPI();
            Set<Id> studyIds = new Set<Id>();
            for (Study_Site__c site : studySites) {
                if (!studyIds.contains(site.Clinical_Trial_Profile__c)) {
                    studyPickList.add(new LabelValueItem(site.Clinical_Trial_Profile__r.Study_Code_Name__c, site.Clinical_Trial_Profile__c));
                    studyIds.add(site.Clinical_Trial_Profile__c);
                }
                if (filterValues.trialId == null || filterValues.trialId == '' || site.Clinical_Trial_Profile__c == filterValues.trialId) {
                    studySitePickList.add(new LabelValueItem(site.Name, site.Id));
                }
            }
        }

    }
    public class SortData {
        public String sortType;
        public List<LabelValueItem> sortVariants;
        public SortData() {
            sortVariants = new List<LabelValueItem>{
                    new LabelValueItem(Label.PG_MRZ_L_Last_Added, 'CreatedDate DESC'),
                    new LabelValueItem(Label.PG_MRZ_L_Last_Modified, 'LastModifiedDate DESC'),
                    new LabelValueItem(Label.PG_MRZ_L_Alphabetical_A_Z, 'Study_Site__r.Name ASC'),
                    new LabelValueItem(Label.PG_MRZ_L_Alphabetical_Z_A, 'Study_Site__r.Name DESC')
            };
            sortType = 'CreatedDate DESC';
        }
    }

}