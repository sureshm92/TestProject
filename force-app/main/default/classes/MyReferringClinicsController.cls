/**
 * Created by D.Yasinskyi on 30.03.2018
 */
public without sharing class MyReferringClinicsController {
    @AuraEnabled
    public static String getInitData(String trialId, String ssId, String communityTemplateName) {
        InitData initData;
        try {
            initData = new InitData(trialId, ssId);
            getInitDataEnrollments(initData);
            if (CommunityService.getUserContact().UserCommunityIsDelegate__c) {
                initData.isButtonDisabled = Action_InviteRPRemote.getPIForInvetation(
                        communityTemplateName
                    )
                    .isEmpty();
            } else {
                initData.isButtonDisabled = false;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
        return JSON.serialize(initData);
    }
    @AuraEnabled
    public static String searchReferringClinics(
        String filterValuesJSON,
        String sortDataJSON,
        String paginationDataJSON,
        Boolean trialChanged
    ) {
        InitData initData;
        try {
            ReferringClinicsFilter.FilterValues filterValues = (ReferringClinicsFilter.FilterValues) JSON.deserialize(
                filterValuesJSON,
                ReferringClinicsFilter.FilterValues.class
            );
            ReferringClinicsFilter.SortData sortData = (ReferringClinicsFilter.SortData) JSON.deserialize(
                sortDataJSON,
                ReferringClinicsFilter.SortData.class
            );
            PaginationData paginationData = (PaginationData) JSON.deserialize(
                paginationDataJSON,
                PaginationData.class
            );
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
        List<HCP_Enrollment__c> enrollments = SearchService.search(
            initData.referringClinicsFilter,
            initData.paginationData
        );
        initData.filteredReferringClinics = getEnrollmentWrappers(enrollments);
    }
    private static List<MyReferringClinicsController.ClinicWrapper> getEnrollmentWrappers(
        List<HCP_Enrollment__c> enrollments
    ) {
        List<MyReferringClinicsController.ClinicWrapper> result = new List<MyReferringClinicsController.ClinicWrapper>();
        Map<Id, List<HCP_Enrollment__c>> clinicEnrolmentMap = new Map<Id, List<HCP_Enrollment__c>>();
        Set<Id> piHcpContactIds = new Set<Id>();
        for (HCP_Enrollment__c enroll : enrollments) {
            pihcpContactIds.add(enroll.Study_Site__r.Principal_Investigator__c);
            if (!clinicEnrolmentMap.containsKey(enroll.HCP_Contact__c)) {
                clinicEnrolmentMap.put(enroll.HCP_Contact__c, new List<HCP_Enrollment__c>());
            }
            piHcpContactIds.add(enroll.HCP_Contact__c);
            clinicEnrolmentMap.get(enroll.HCP_Contact__c).add(enroll);
        }
        Map<Id,Participant__c> piHcpContactNames = ParticipantWorkflowService.getPIContactNameDetails(piHcpContactIds);
        for (Id hcpId : clinicEnrolmentMap.keySet()) {
            result.add(new ClinicWrapper(clinicEnrolmentMap.get(hcpId),piHcpContactNames,piHcpContactNames.get(hcpId)));
        }
        return result;
    }

    public class ClinicWrapper {
        public Account clinic;
        public Contact hcpContact;
        public Participant__c hcpContactPartName;
        public List<MyReferringClinicsController.HCPEnrollmentWrapper> enrollments = new List<MyReferringClinicsController.HCPEnrollmentWrapper>();

        public ClinicWrapper(List<HCP_Enrollment__c> enrollments) {
            if (enrollments != null && !enrollments.isEmpty()) {
                this.hcpContact = enrollments[0].HCP_Contact__r;
                for (HCP_Enrollment__c enrollment : enrollments) {
                    this.enrollments.add(new HCPEnrollmentWrapper(enrollment, null));
                }
            }
        }
        public ClinicWrapper(List<HCP_Enrollment__c> enrollments, Map<Id,Participant__c> piHcpContactNames, Participant__c hcpContactPartName) {
            this.hcpContactPartName= hcpContactPartName;
            if (enrollments != null && !enrollments.isEmpty()) {
                this.hcpContact = enrollments[0].HCP_Contact__r;
                for (HCP_Enrollment__c enrollment : enrollments) {
                    this.enrollments.add(new HCPEnrollmentWrapper(enrollment,piHcpContactNames.get(enrollment.Study_Site__r.Principal_Investigator__c)));
                }
            }
        }        
    }

    public class HCPEnrollmentWrapper {
        HCP_Enrollment__c enrollment;
        String status;
        String statusLabel;
        Participant__c piContactName;
        List<StudyActions.Action> buttonList = new List<StudyActions.Action>();
        //Boolean isHCPRegistred;
        public HCPEnrollmentWrapper(HCP_Enrollment__c hcpEnrollment, Participant__c piContactName) {
            this.piContactName = piContactName;
            Map<String, StudyActions.Action> actionsMap = new StudyActionsPI(hcpEnrollment).actions;
            status = CommunityService.getConvertedStatus(hcpEnrollment.Status__c);
            statusLabel = TranslateHelper.getPickListLabel(
                HCP_Enrollment__c.Status__c,
                hcpEnrollment.Status__c
            );
            enrollment = hcpEnrollment;
            //isHCPRegistred = !hcpEnrollment.HCP_Contact__r.Is_First_Logon__c;
            Map<String, String> actionToStatusesMap = HCPEnrollmentService.HCP_CHANGE_STATUS_MAP.get(
                hcpEnrollment.Status__c
            );
            if (actionToStatusesMap != null) {
                for (String actionId : actionToStatusesMap.keySet()) {
                    buttonList.add(actionsMap.get(actionId));
                }
            }
        }
    }
    public class InitData {
        public ReferringClinicsFilter referringClinicsFilter;
        public PaginationData paginationData;
        public List<MyReferringClinicsController.ClinicWrapper> filteredReferringClinics;
        public String trialId;
        public String ssId;
        public Boolean isButtonDisabled;
        public InitData(String trialId, String ssId) {
            this.trialId = trialId;
            this.ssId = ssId;
            filteredReferringClinics = new List<MyReferringClinicsController.ClinicWrapper>();
            referringClinicsFilter = new ReferringClinicsFilter(trialId, ssId);
            paginationData = new PaginationData();
        }
        public InitData(
            ReferringClinicsFilter.FilterValues filterValues,
            ReferringClinicsFilter.SortData sortData,
            PaginationData paginationData
        ) {
            filteredReferringClinics = new List<MyReferringClinicsController.ClinicWrapper>();
            this.trialId = filterValues.trialId;
            this.ssId = filterValues.ssId;
            this.referringClinicsFilter = new ReferringClinicsFilter(filterValues, sortData);
            this.paginationData = paginationData;
        }
    }
}