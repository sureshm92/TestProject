/**
 * Created by D.Yasinskyi on 30.03.2018
 */
public without sharing class MyReferringClinicsController {

    private static List<Account> getAccounts(Set<Id> accountIds) {
        return [
                SELECT Id, Name, BillingStreet, BillingState, BillingPostalCode, BillingCity, Phone
                FROM Account
                WHERE Id IN :accountIds
        ];
    }

    private static MyReferringClinicsController.HCPEnrollmentWrapper createEnrollmentWrapper(HCP_Enrollment__c hcpEnrollment){
        Map<String, StudyActions.Action> actionsMap = new StudyActionsPI(hcpEnrollment).actions;
        MyReferringClinicsController.HCPEnrollmentWrapper wrapper = new MyReferringClinicsController.HCPEnrollmentWrapper();
        wrapper.status = CommunityService.getConvertedStatus(hcpEnrollment.Status__c);
        wrapper.statusLabel = TranslateHelper.getPickListLabel(HCP_Enrollment__c.Status__c,hcpEnrollment.Status__c);
        wrapper.enrollment = hcpEnrollment;

        Map<String, String> actionToStatusesMap = HCPEnrollmentService.HCP_CHANGE_STATUS_MAP.get(hcpEnrollment.Status__c);
        if(actionToStatusesMap != null){
            for(String actionId : actionToStatusesMap.keySet()) {
                wrapper.buttonList.add(actionsMap.get(actionId));
            }
        }
        return wrapper;
    }
    @AuraEnabled
    public static String getInitData(String trialId, String ssId){
        InitData initData = new InitData();
        initData.ssId = null;
        initData.trialId = null;
        initData.filterData.statusOptions = getInitStatusOptions();
        try {
            Set<Id> trialIds = new Set<Id>();
            List<Study_Site__c> studySites;
            studySites = StudySiteService.getStudySitesForPI();
            Map<Id, List<Study_Site__c>> studyMap = new Map<Id, List<Study_Site__c>>();
            Map<String, String> studySiteMap = new Map<String, String>();
            initData.filterData.studyPickList = new List<LabelValueItem>{
                    new LabelValueItem(Label.PG_MRRL_L_All_studies, null)
            };
            for (Integer i = 0, j = studySites.size(); i < j; i++) {
                if (studyMap.containsKey(studySites[i].Clinical_Trial_Profile__c)) {
                    studyMap.get(studySites[i].Clinical_Trial_Profile__c).add(studySites[i]);
                } else {
                    studyMap.put(studySites[i].Clinical_Trial_Profile__c, new List<Study_Site__c>{
                            studySites[i]
                    });
                    initData.filterData.studyPickList.add(new LabelValueItem(studySites[i].Clinical_Trial_Profile__r.Study_Code_Name__c, studySites[i].Clinical_Trial_Profile__c));
                }
                studySiteMap.put(studySites[i].Id, studySites[i].Clinical_Trial_Profile__c);
            }
            if (trialId != null) {
                studySites = studyMap.get(trialId);
            }
            initData.filterData.studySitePickList = new List<LabelValueItem>{
                    new LabelValueItem(Label.PG_Report_L_All_study_sites, null)
            };
            if (ssId == null) {
                for (Study_Site__c studySite : studySites) {
                    trialIds.add(studySite.Clinical_Trial_Profile__c);
                    initData.filterData.studySitePickList.add(new LabelValueItem(studySite.Name, studySite.Id));
                }
                initData.filteredReferringClinics = getInitDataEnrollments(HCPEnrollmentService.getEnrollmentsForPIByTrialIds(
                        trialIds, new List<String>{
                                HCPEnrollmentService.HCP_S_INVITATION_SENT
                        }
                ));
            } else {
                initData.filteredReferringClinics = getInitDataEnrollments(HCPEnrollmentService.getEnrollmentsForPIByStudySiteId(ssId));
                List<Study_Site__c> ssForStudy = studyMap.get(studySiteMap.get(ssId));
                initData.ssId = ssId;
                initData.filterData.ssId = ssId;
                trialId = ssForStudy[0].Clinical_Trial_Profile__c;
                for (Integer i = 0; i < ssForStudy.size(); i++) {
                    initData.filterData.studySitePickList.add(new LabelValueItem(ssForStudy[i].Name, ssForStudy[i].Id));
                }
            }
            if (trialId != null) {
                initData.trialId = trialId;
                initData.filterData.trialId = trialId;
            }


        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
        return JSON.serialize(initData);
    }

    private static List<MyReferringClinicsController.ClinicWrapper> getInitDataEnrollments(List<HCP_Enrollment__c> enrollments) {
        List<MyReferringClinicsController.ClinicWrapper> result = new List<MyReferringClinicsController.ClinicWrapper>();
        Map<Id, List<HCP_Enrollment__c>> clinicEnrolmentMap = new Map<Id, List<HCP_Enrollment__c>>();
        for (HCP_Enrollment__c enroll :enrollments) {
            if (!clinicEnrolmentMap.containsKey(enroll.HCP_Contact__r.AccountId)) {
                clinicEnrolmentMap.put(enroll.HCP_Contact__r.AccountId, new List<HCP_Enrollment__c>());
            }
            clinicEnrolmentMap.get(enroll.HCP_Contact__r.AccountId).add(enroll);
        }

        for (Account acc : getAccounts(clinicEnrolmentMap.keySet())) {
            result.add(new ClinicWrapper(acc, clinicEnrolmentMap.get(acc.Id)));
        }

        return result;
    }
    public static List<LabelValueItem> getInitStatusOptions(){
        List<LabelValueItem> enrollmentStatusOptions = new List<LabelValueItem>();
        for (Schema.PicklistEntry ple : HCP_Enrollment__c.Status__c.getDescribe().getPicklistValues()) {
            if(HCPEnrollmentService.HCP_E_S_INVISIBLE_ON_STUDY_SITE_P.contains(ple.getValue())) continue;
            enrollmentStatusOptions.add(new LabelValueItem(ple.getLabel(),ple.getValue()));
        }
        return enrollmentStatusOptions;
    }

    public class ClinicWrapper {
        public Account clinic;
        public List<MyReferringClinicsController.HCPEnrollmentWrapper> enrollments = new List<MyReferringClinicsController.HCPEnrollmentWrapper>();

        public ClinicWrapper(Account clinic, List<HCP_Enrollment__c> enrollments) {
            this.clinic = clinic;
            if(enrollments != null){
                for(HCP_Enrollment__c enrollment : enrollments){
                    this.enrollments.add(createEnrollmentWrapper(enrollment));
                }
            }
        }
    }

    public class  HCPEnrollmentWrapper {
        HCP_Enrollment__c enrollment;
        String status;
        String statusLabel;
        List<StudyActions.Action> buttonList = new List<StudyActions.Action>();
    }
    public class InitData{
        FilterData filterData;
        SortData sortData;
        PaginationData paginationData;
        public List<MyReferringClinicsController.ClinicWrapper> filteredReferringClinics;
        public String trialId;
        public String ssId;
        public InitData(){
            filteredReferringClinics = new List<MyReferringClinicsController.ClinicWrapper>();
            filterData = new FilterData();
            sortData = new SortData();
            PaginationData = new PaginationData();
        }
    }
    public class FilterData {
        public String searchText = '';
        public String searchTextPlaceholder = Label.PG_MRZ_L_Search_for_a_referring_clinic;
        public String statusFilter = '';
        public List<LabelValueItem> statusOptions = new List<LabelValueItem>();
        public String statusFilterPlaceholder = Label.PG_MRZ_L_Provider_Status;
        public String trialId;
        public List<LabelValueItem> studyPickList = new List<LabelValueItem>();
        public String ssId;
        public List<LabelValueItem> studySitePickList = new List<LabelValueItem>();

    }
    public class SortData{
        public String sortType;
        public List<LabelValueItem> sortVariants;
        public SortData(){
            sortVariants = new List<LabelValueItem>{
                    new LabelValueItem(Label.PG_MRZ_L_Last_Added, 'CreatedDate DESC'),
                    new LabelValueItem(Label.PG_MRZ_L_Last_Modified, 'LastModifiedDate DESC'),
                    new LabelValueItem(Label.PG_MRZ_L_Alphabetical_A_Z, 'Name ASC'),
                    new LabelValueItem(Label.PG_MRZ_L_Alphabetical_Z_A, 'Name DESC')
            };
            sortType = 'CreatedDate DESC';
        }
    }

}