public without sharing class ListViewParticipantService {
    //Filter Data Wrapper Fields
    public static final String STUDIES_FILTER_DATA_FIELD = 'studies';
    public static final String STUDY_SITES_FILTER_DATA_FIELD = 'studySites';
    public static final String STATUSES_FILTER_DATA_FIELD = 'statuses';

    public static PEFilterData getPEFilterDataWithSponsor(
        String mode,
        Id trialId,
        Boolean restrictTrial,
        String delegateId,
        String communityTemplate
    ) {
        Map<Id, Clinical_Trial_Profile__c> trialsMap = new Map<Id, Clinical_Trial_Profile__c>();
        List<Clinical_Trial_Profile__c> trials = new List<Clinical_Trial_Profile__c>();
        List<Study_Site__c> studySites = new List<Study_Site__c>();
        String hcpFilter =
            'AND Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c = \'' +
            communityTemplate +
            '\'';
        List<String> SS_COMMON_CUSTOM_FIELDS = new List<String>();
        SS_COMMON_CUSTOM_FIELDS.addAll(StudySiteService.SS_COMMON_FIELDS);
        SS_COMMON_CUSTOM_FIELDS.add('Clinical_Trial_Profile__r.Promote_to_SH__c');
        if (mode == CommunityService.USER_MODE_HCP) {
            List<HCP_Enrollment__c> hcpEnrollments = HCPEnrollmentService.getHCPEnrollmentsCommon(
                mode,
                delegateId,
                hcpFilter,
                false
            );

            for (HCP_Enrollment__c hcpEnrollment : hcpEnrollments) {
                if (hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__r != null)
                    trials.add(hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__r);
            }
            trialsMap.putAll(trials);
            if (restrictTrial && trialId != null && trialsMap.containsKey(trialId)) {
                studySites = StudySiteService.getStudySitesForHCPByTrialId(trialId);
            } else {
                studySites = StudySiteService.getStudySitesForHCP(
                    new List<Id>(trialsMap.keySet()),
                    delegateId
                );
            }
        }
        if (mode == CommunityService.USER_MODE_PI) {
            String communityFilter = communityTemplate.equalsIgnoreCase(
                    CommunityTemplateService.TEMPLATE_JANSSEN
                )
                ? 'AND Clinical_Trial_Profile__r.CommunityTemplate__c = \'' +
                  CommunityTemplateService.TEMPLATE_JANSSEN +
                  '\''
                : 'AND Clinical_Trial_Profile__r.CommunityTemplate__c != \'' +
                  CommunityTemplateService.TEMPLATE_JANSSEN +
                  '\'';

            List<Study_Site__c> studySitesTmp = StudySiteService.getStudySitesCommon(
                CommunityService.USER_MODE_PI,
                communityFilter,
                false,
                SS_COMMON_CUSTOM_FIELDS
            );
            for (Study_Site__c ss : studySitesTmp)
                trials.add(ss.Clinical_Trial_Profile__r);
            trialsMap.putAll(trials);
            if (restrictTrial && trialId != null && trialsMap.containsKey(trialId)) {
                studySites = StudySiteService.getStudySiteForPIByTrialId(trialId, SS_COMMON_CUSTOM_FIELDS);
            } else {
                studySites.addAll(studySitesTmp);
            }
        }
        return createPEFilterDataForTrials(trialsMap, studySites, mode);
    }
    @TestVisible
    private static PEFilterData createPEFilterDataForTrials(
        Map<Id, Clinical_Trial_Profile__c> trialsMap,
        List<Study_Site__c> studySites,
        String mode
    ) {
        PEFilterData peFilterData = new PEFilterData();
        peFilterData.mode = mode;
        //init trials
        peFilterData.studies = new List<LabelValueItem>();
        //peFilterData.studies.add(new LabelValueItem(Label.PG_MRRL_L_All_studies, null));
        peFilterData.trialIds = new List<Id>();
        Clinical_Trial_Profile__c trial;
        for (String id : trialsMap.keySet()) {
            peFilterData.trialIds.add(id);
            trial = trialsMap.get(id);
            peFilterData.studies.add(new LabelValueItem(trial.Study_Code_Name__c, trial.Id));
        }

        //init study sites:
        peFilterData.studySites = new List<LabelValueItem>();
        peFilterData.studySites.add(new LabelValueItem(Label.PG_Report_L_All_study_sites, null));
        for (Study_Site__c ss : studySites)
            peFilterData.studySites.add(new LabelValueItem(ss.Name, ss.Id));

        peFilterData.referringClinics = new List<LabelValueItem>();
        peFilterData.referringClinics.add(
            new LabelValueItem(Label.PG_Report_L_All_referring_clinics, null)
        );
        for (Account clinic : HCPEnrollmentService.getReferringClinics(peFilterData.trialIds)) {
            peFilterData.referringClinics.add(new LabelValueItem(clinic.Name, clinic.Id));
        }
        peFilterData.activePE = new List<LabelValueItem>{
            new LabelValueItem(
                TranslateHelper.getLabelValue('PG_VP_L_Active'),
                PEStatusState.PE_STATUSES_ACTIVE
            ),
            new LabelValueItem(
                TranslateHelper.getLabelValue('PG_VP_L_Inactive'),
                PEStatusState.PE_STATUSES_INACTIVE
            )
        };
        peFilterData.activeParticipantStatus = new List<LabelValueItem>();
        for (Integer i = 0, j = PEStatusState.PE_STATUS_GROUP_ACTIVE.size(); i < j; i++) {
            peFilterData.activeParticipantStatus.add(
                new LabelValueItem(
                    TranslateHelper.getPickListLabel(
                        Participant_Enrollment__c.Participant_Status__c,
                        PEStatusState.PE_STATUS_GROUP_ACTIVE[i]
                    ),
                    PEStatusState.PE_STATUS_GROUP_ACTIVE[i]
                )
            );
        }
        peFilterData.inactiveParticipantStatus = new List<LabelValueItem>();
        for (Integer i = 0, j = PEStatusState.PE_STATUS_GROUP_INACTIVE.size(); i < j; i++) {
            peFilterData.inactiveParticipantStatus.add(
                new LabelValueItem(
                    TranslateHelper.getPickListLabel(
                        Participant_Enrollment__c.Participant_Status__c,
                        PEStatusState.PE_STATUS_GROUP_INACTIVE[i]
                    ),
                    PEStatusState.PE_STATUS_GROUP_INACTIVE[i]
                )
            );
        }
        return peFilterData;
    }

    //Added by Akanksha
    //contains selected filter values
    public class PEFilter {
        public String mode;
        public List<Id> trialIds;
        public String Study;
        public Id studySite;
        public String referringStatus;
        public String enrollmentStatus;
        public String reviewResult;
        public String showExcludedFromReferring;
        public String dateRange;
        public String Source;
        public String activePE;
        public String ParticipantStatus;
        public Date startDate;
        public Date endDate;
        public String searchText;
        public List<String> searchFields;
        public String sortType = SortOrder.SORT_TYPES[0].value;
        public String additionalFilter;
        public String acceptenceStatus;
        public String referringClinic;
        public String dateField;
        public List<filterWrapper> fwrapMain;

        public PEFilter(PEFilterData filterData) {
        }
    }

    public class filterWrapper {
        public String Status;
        public String Study;
        public String StudySites;
        public String Source;
        public String ParticipantStatus;
        public String isHighRiskOccupation;
        public String isComorbidities;
        public String isInitialVisitScheduled;
        public String AgeFrom;
        public String AgeTo;
        public String Ethnicity;
        public String Sex;
    }

    //contains pick list values for PEFilter
    public class PEFilterData {
        public String mode;
        public List<Id> trialIds;
        public List<Study_Site__c> ssValue;
        public List<LabelValueItem> ethnicity;
        public List<LabelValueItem> studies;
        public List<LabelValueItem> studySites;
        public List<LabelValueItem> referringStatuses = PEStatusState.getReferringStatusesLVList();
        public List<LabelValueItem> reviewResults;
        public List<LabelValueItem> source;
        public List<LabelValueItem> activePE;
        public List<LabelValueItem> statuses;
        public List<LabelValueItem> activeParticipantStatus;
        public List<LabelValueItem> inactiveParticipantStatus;
        public List<LabelValueItem> excludedFromReferring;
        public List<LabelValueItem> referringClinics;
        public List<LabelValueItem> dateRanges = DateRangeFilterData.getRanges();
        public List<LabelValueItem> sortVariants;
        public List<LabelValueItem> acceptenceStatuses = PEStatusState.getAcceptenceStatusesLVList();
        public List<LabelValueItem> enrollmentStatuses = PEStatusState.getEnrollmentStatusesLVList();
        public PEFilterData() {
            sortVariants = new List<LabelValueItem>();
            sortVariants.addAll(SortOrder.SORT_TYPES);
        }
        public String dateField = 'CreatedDate';
    }
}
