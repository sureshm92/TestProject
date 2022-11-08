/**
 * Created by Leonid Bartenev
 */

public without sharing class TrialService {
    public static final String STATUS_ACTIVELY_ENROLLING = 'Actively Enrolling';
    public static final String STATUS_NO_LONGER_ENROLLING = 'No_Longer_Enrolling';

    public static final List<String> CTP_FIELDS = new List<String>{
        'Id',
        'Orientation_Required__c',
        'Name',
        'Terms_And_Conditions_ID__c',
        'Study_Sponsor__c',
        'Study_Type__c',
        'Detailed_Description__c',
        'toLabel(Override_Recruitment_Status__c)',
        'Brief_Summary__c',
        'Override_Description__c',
        'Override_Inclusion_Criteria__c',
        'Override_Exclusion_Criteria__c',
        'Condition_s_Therapeutic_Area__c',
        'Sponsor_Pays_for_Referral_Activity__c',
        'Study_Phase__c, NCT_Number__c',
        'Protocol_ID__c',
        'Enrollment_Start_Date__c',
        'Enrolled_End_Date__c',
        'Link_to_Medical_Record_Review__c',
        'Link_to_Pre_screening__c',
        'Study_Title__c',
        'Study_Code_Name__c',
        'Official_Title__c',
        'Interventions__c',
        'Profile_Picture__c',
        'Share_URL__c',
        'Patient_Portal_Enabled__c',
        'Visit_Data_Shareback__c',
        'Therapeutic_Area__r.Name',
        'Study_Documents_Are_Available__c',
        'Video_And_Articles_Are_Available__c',
        'Tasks_Are_Available__c',
        'Travel_Vendor_Is_Available__c',
        'Received_Until_Consent_Is_Available__c',
        'Enrolled_Or_Randomized_Consent_Available__c',
        'Visit_Schedule_Is_Available__c',
        'Participant_Workflow_Final_Step__c',
        'Initial_Visit_Required__c',
        'Final_Consent_Required__c',
        'Patient_Auth_Upload_Required__c',
        'Televisit_Vendor_is_Available__c',
        'IQVIA_Outreach__c',
        'Tokenization_Support__c'
    };

    private static TrialService instance;

    public static TrialService getInstance() {
        if (instance == null)
            instance = new TrialService();
        return instance;
    }

    public static void setMock(StubProvider stubProvider) {
        instance = (TrialService) Test.createStub(TrialService.class, stubProvider);
    }
    public List<Clinical_Trial_Profile__c> getAvailableTrialsImpl(String mode) {
        return getAvailableTrialsImpl(mode, null);
    }
    public List<Clinical_Trial_Profile__c> getAvailableTrialsImpl(String mode, String delegateId) {
        Set<Clinical_Trial_Profile__c> trials = new Set<Clinical_Trial_Profile__c>();
        if (mode == CommunityService.USER_MODE_PI) {
            List<Study_Site__c> studySites = StudySiteService.getStudySitesCommon(
                CommunityService.USER_MODE_PI,
                null,
                false
            );
            for (Study_Site__c ss : studySites)
                trials.add(ss.Clinical_Trial_Profile__r);
        } else if (mode == CommunityService.USER_MODE_HCP) {
            List<HCP_Enrollment__c> hcpEnrollments = HCPEnrollmentService.getHCPEnrollmentsCommon(
                mode,
                delegateId,
                null,
                false
            );
            System.debug('hcpCommon' + hcpEnrollments);
            for (HCP_Enrollment__c hcpEnrollment : hcpEnrollments) {
                if (hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__r != null)
                    trials.add(hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__r);
            }
        } else if (mode == CommunityService.USER_MODE_PARTICIPANT) {
            List<Participant_Enrollment__c> participantEnrollments = ParticipantEnrollmentService.getParticipantEnrollmentsForParticipant();
            trials.add(participantEnrollments.get(0).Study_Site__r.Clinical_Trial_Profile__r);
        }
        return new List<Clinical_Trial_Profile__c>(trials);
    }
    public List<Clinical_Trial_Profile__c> getAvailableTrialsWithPEImpl(
        String activePE,
        String mode,
        String delegateId,
        String additionalFilter
    ) {
        List<Clinical_Trial_Profile__c> trials = getAvailableTrials(mode, delegateId);
        Set<Id> trialIds = new Set<Id>();
        //for (Participant_Enrollment__c pe : ParticipantEnrollmentService.getParticipantEnrollmentsActiveFilter(activePE, mode, delegateId, additionalFilter)){
        for (
            Participant_Enrollment__c pe : ParticipantEnrollmentService.getParticipantEnrollmentsActiveFilterOptimized(
                activePE,
                mode,
                delegateId,
                additionalFilter,
                ParticipantEnrollmentService.ACTIVE_PE_FIELDS_FOR_CTP_SS
            )
        ) {
            trialIds.add(pe.Clinical_Trial_Profile__c);
        }
        return (List<Clinical_Trial_Profile__c>) SObjectHelper.filterSObjectsByIds(
            trials,
            trialIds
        );
    }

    public List<Clinical_Trial_Profile__c> getOwnTrialsImpl(String userMode) {
        List<Clinical_Trial_Profile__c> ownTrials = new List<Clinical_Trial_Profile__c>();
        for (Clinical_Trial_Profile__c trial : getAvailableTrials(userMode)) {
            if (
                DelegateService.getStudyAccessLevel(trial.Id, userMode) ==
                DelegateService.OWNER_LEVEL
            ) {
                ownTrials.add(trial);
            }
        }
        return ownTrials;
    }

    public List<Clinical_Trial_Profile__c> getTrialsImpl(List<Id> trialIds) {
        List<Clinical_Trial_Profile__c> trials = DatabaseService.query(
            CTP_FIELDS,
            Clinical_Trial_Profile__c.getSObjectType(),
            DatabaseService.fieldInValues('Id', trialIds)
        );
        return trials;
    }

    public List<Clinical_Trial_Profile__c> getTrialsImpl(
        List<Id> trialIds,
        List<String> CTP_INPUT_FIELDS
    ) {
        List<Clinical_Trial_Profile__c> trials = DatabaseService.query(
            CTP_INPUT_FIELDS,
            Clinical_Trial_Profile__c.getSObjectType(),
            DatabaseService.fieldInValues('Id', trialIds)
        );
        return trials;
    }

    public Clinical_Trial_Profile__c getTrialImpl(Id trialId) {
        List<Clinical_Trial_Profile__c> trials = getTrialsImpl(new List<Id>{ trialId });
        if (trials.size() > 0) {
            String language = UserInfo.getLanguage();
            if (
                CommunityService.getUserContact()
                    .userCommunityMode__c.equals(CommunityService.USER_MODE_PARTICIPANT)
            ) {
                language = IRBParticipantService.getSuitableLanguageForIRBTranslation(
                    ParticipantService.getParticipantState().pe.Id
                );
            }
            TranslateHelper.translate(trials[0], language);
            return trials[0];
        }
        return null;
    }

    public Clinical_Trial_Profile__c getTrialImpl(Id trialId, List<String> CTP_INPUT_FIELDS) {
        List<Clinical_Trial_Profile__c> trials = getTrialsImpl(
            new List<Id>{ trialId },
            CTP_INPUT_FIELDS
        );
        if (trials.size() > 0) {
            String language = UserInfo.getLanguage();
            if (
                CommunityService.getUserContact()
                    .userCommunityMode__c.equals(CommunityService.USER_MODE_PARTICIPANT)
            ) {
                language = IRBParticipantService.getSuitableLanguageForIRBTranslation(
                    ParticipantService.getParticipantState().pe.Id
                );
            }
            TranslateHelper.translate(trials[0], language);
            return trials[0];
        }
        return null;
    }

    public List<Id> getAvailableTrialIdsImpl(String userMode) {
        return getAvailableTrialIdsImpl(userMode, null);
    }
    public List<Id> getAvailableTrialIdsImpl(String userMode, String delegateId) {
        return SObjectHelper.toIdsList(getAvailableTrials(userMode, delegateId));
    }

    // Static facade: --------------------------------------------------------------------------------------------------

    public static List<Clinical_Trial_Profile__c> getAvailableTrials(String userMode) {
        return getInstance().getAvailableTrialsImpl(userMode);
    }

    public static List<Clinical_Trial_Profile__c> getAvailableTrials(
        String userMode,
        String delegateId
    ) {
        return getInstance().getAvailableTrialsImpl(userMode, delegateId);
    }

    public static List<Clinical_Trial_Profile__c> getAvailableTrialsWithPE(
        String activePE,
        String userMode,
        String delegateId,
        String additionalFilter
    ) {
        return getInstance()
            .getAvailableTrialsWithPEImpl(activePE, userMode, delegateId, additionalFilter);
    }

    public static List<Clinical_Trial_Profile__c> getOwnTrials(String userMode) {
        return getInstance().getOwnTrialsImpl(userMode);
    }

    public static List<Id> getAvailableTrialIds(String userMode) {
        return getInstance().getAvailableTrialIdsImpl(userMode);
    }
    public static List<Id> getAvailableTrialIds(String userMode, String delegateId) {
        return getInstance().getAvailableTrialIdsImpl(userMode, delegateId);
    }

    public static Clinical_Trial_Profile__c getTrial(Id trialId) {
        return getInstance().getTrialImpl(trialId);
    }

    public static Clinical_Trial_Profile__c getTrial(Id trialId, List<String> CTP_INPUT_FIELDS) {
        return getInstance().getTrialImpl(trialId, CTP_INPUT_FIELDS);
    }

    public static List<Clinical_Trial_Profile__c> getTrials(List<Id> trialIds) {
        return getInstance().getTrialsImpl(trialIds);
    }

    public static Boolean isTrialAvailable(Id trialId, String userMode) {
        return getAvailableTrialIds(userMode).contains(trialId);
    }

    public static Boolean isTrialAvailable(Id trialId, String userMode, String delegateId) {
        return getAvailableTrialIds(userMode, delegateId).contains(trialId);
    }

    public static List<Clinical_Trial_Profile__c> filterStudyForCurrentCommunity(
        List<Clinical_Trial_Profile__c> studies
    ) {
        List<Clinical_Trial_Profile__c> filteredStudies = new List<Clinical_Trial_Profile__c>();
        CommunityTemplate currentCommunityTemplate = UserContext.getCurrentCommunityTemplate();
        for (Clinical_Trial_Profile__c study : studies) {
            if (
                currentCommunityTemplate.templateName == CommunityTemplateService.TEMPLATE_JANSSEN
            ) {
                if (study.CommunityTemplate__c == CommunityTemplateService.TEMPLATE_JANSSEN)
                    filteredStudies.add(study);
            } else {
                if (study.CommunityTemplate__c != CommunityTemplateService.TEMPLATE_JANSSEN)
                    filteredStudies.add(study);
            }
        }
        return filteredStudies;
    }
}
