/**
 * Created by Leonid Bartenev
 *
 */

public abstract class StudyActions {
    public class Action {
        public String id;
        public String label;
        public String iconName;
        public Boolean disabled;
        public String disableReason;
        public String cssClass;

        public Action(String id, String label, String iconName, Boolean disabled) {
            this.id = id;
            this.label = label;
            this.iconName = iconName;
            this.disabled = disabled;
        }

        public Action(String id, String label, String iconName) {
            this(id, label, iconName, false);
        }

        public Action(
            String id,
            String label,
            String iconName,
            List<DisableReason> disableReasons
        ) {
            this(id, label, iconName, disableReasons, null);
        }

        public Action(
            String id,
            String label,
            String iconName,
            List<DisableReason> disableReasons,
            String cssClass
        ) {
            this(id, label, iconName);
            this.cssClass = cssClass;
            for (DisableReason disableReason : disableReasons) {
                if (disableReason.disabled) {
                    this.disabled = true;
                    this.disableReason = disableReason.reason;
                    break;
                }
            }
        }
    }

    public class DisableReason {
        public Boolean disabled;
        public String reason;

        public DisableReason(Boolean disabled, String reason) {
            this.disabled = disabled;
            this.reason = reason;
        }
    }

    //action ID's
    public static final String ACT_ACCEPT_TC = 'acceptTermsAndConditions';
    public static final String ACT_VIEW_TC = 'viewTermsAndConditions';
    public static final String ACT_NO_THANKS = 'noThanks';
    public static final String ACT_DELEGATE = 'delegate';
    public static final String ACT_ADD_PATIENT = 'addPatient';
    public static final String ACT_UPLOAD_PATIENT = 'uploadPatient';
    public static final String ACT_DOWNLOAD_CONSENT = 'downloadConsent';
    public static final String ACT_HOME = 'backHome';

    public static final String ACT_MEDICAL_RECORD_REVIEW = 'medicalRecordReview';
    public static final String ACT_EXCLUDE_FROM_REFERRING = 'excludeFromReferring';
    public static final String ACT_UNDO_EXCLUDE_FROM_REFERRING = 'undoExcludeFromReferring';
    public static final String ACT_REFER_TO_THIS_STUDY = 'referToThisStudy';
    public static final String ACT_REFER = 'refer';
    public static final String ACT_REQUEST_TO_REFER = 'requestToRefer';
    public static final String ACT_SHARE = 'share';
    public static final String ACT_SHARE_EMAIL = 'shareEmail';
    public static final String ACT_SHARE_FACEBOOK = 'shareFacebook';
    public static final String ACT_SHARE_LINKEDIN = 'shareLinkedin';
    public static final String ACT_SHARE_TWITTER = 'shareTwitter';
    public static final String ACT_FIND_STUDY_SITES = 'findStudySites';
    public static final String ACT_SEND_SITE_REQUEST = 'sendSiteRequest';
    public static final String ACT_MY_PATIENTS = 'myPatients';

    public static final String ACT_MANAGE_REFERRALS = 'manageReferrals';
    public static final String ACT_MANAGE_REFERRALS_BY_SS = 'manageReferralsBySS';
    public static final String ACT_MANAGE_REFERRING_CLINICS = 'manageReferringClinics';
    public static final String ACT_MANAGE_REFERRING_CLINICS_BY_SS = 'manageReferringClinicsBySS';
    public static final String ACT_OPEN_TO_RECEIVE_REFERRALS = 'openToReceiveReferrals';
    public static final String ACT_CHANGE_PE_STATUS_BY_PI = 'changePEStatusByPI';
    public static final String ACT_HCP_ON_HOLD = 'hcpOnHold';
    public static final String ACT_HCP_DECLINE = 'hcpDecline';
    public static final String ACT_HCP_APPROVE = 'hcpApprove';
    public static final String ACT_HCP_ACTIVATE = 'hcpActivate';
    public static final String ACT_HCP_ACTIVATE_FOR_ALL = 'hcpActivateForAll';
    public static final String ACT_HCP_ORIENTATION_ATTENDED_AND_ACTIVATE = 'hcpOrientationAttendedAndActivate';
    public static final String ACT_HCP_DEACTIVATE = 'hcpDeactivate';
    public static final String ACT_HCP_LINK_STUDY_SITES = 'linkToStudySites';
    public static final String ACT_SCREENER_RESPONSES = 'screenerResponses';
    public static final String ACT_CONNECT_PROVIDER = 'connectProvider';
    public static final String ACT_MEDICAL_HISTORY = 'medicalHistory'; //REF-2774

    //action labels:
    public static final String LABEL_ACCEPT_TC = Label.BTN_Accept_terms_and_conditions;
    public static final String LABEL_VIEW_TC = Label.BTN_View_terms_and_conditions;
    public static final String LABEL_VIEW_TC_Participant = Label.BTN_View_terms_and_conditions_participant;
    public static final String LABEL_NO_THANKS = Label.BTN_No_thanks;
    public static final String LABEL_DELEGATE = Label.BTN_Delegate;
    public static final String LABEL_ADD_PATIENT = Label.PG_Add_Patients_Header;
    public static final String LABEL_UPLOAD_PATIENT = Label.PIR_Import_Participants;
    public static final String LABEL_DOWNLOAD_CONSENT = Label.BTN_View_Download_Consent;
    public static final String LABEL_HOME = Label.Link_Back_To_Home;

    public static final String LABEL_MEDICAL_RECORD_REVIEW = Label.BTN_PES;
    public static final String LABEL_PRE_ELIGIBILITY_SCREENING = Label.BTN_PES2;

    public static final String LABEL_EXCLUDE_FROM_REFERRING = Label.BTN_Exclude_from_referring;
    public static final String LABEL_UNDO_EXCLUDE_FROM_REFERRING = Label.BTN_Undo_exclude;
    public static final String LABEL_REFER_TO_THIS_STUDY = Label.BTN_Refer_to_this_study;
    public static final String LABEL_REFER = Label.BTN_Refer;
    public static final String LABEL_SHARE = Label.BTN_Share;
    public static final String LABEL_FIND_STUDY_SITES = Label.BTN_Find_study_sites;
    public static final String LABEL_SEND_SITE_REQUEST = Label.BTN_Send_site_request;
    public static final String LABEL_REQUEST_TO_REFER = Label.BTN_Request_to_refer;
    public static final String LABEL_MY_PATIENTS = Label.BTN_My_Patients;

    public static final String LABEL_MANAGE_REFERRALS = Label.SS_Btn_Manage_Referrals;
    public static final String LABEL_MANAGE_REFERRING_CLINICS = Label.SS_Btn_Manage_Referring_Providers;
    public static final String LABEL_MANAGE_REFERRALS_BY_SS = Label.SS_Btn_Manage_Referrals;
    public static final String LABEL_MANAGE_REFERRING_CLINICS_BY_SS = Label.SS_Btn_Manage_Referring_Providers;
    public static final String LABEL_OPEN_TO_RECEIVE_REFERRALS = Label.BTN_I_Activate_my_site;
    public static final String LABEL_HCP_ON_HOLD = Label.BTN_On_hold;
    public static final String LABEL_HCP_DECLINE = Label.BTN_Decline;
    public static final String LABEL_HCP_DEACTIVATE = Label.BTN_Deactivate;
    public static final String LABEL_HCP_APPROVE = Label.BTN_Approve;
    public static final String LABEL_HCP_ACTIVATE = Label.BTN_Activate;
    public static final String LABEL_HCP_ACTIVATE_FOR_ALL = Label.BTN_Activate_All;
    public static final String LABEL_HCP_ORIENTATION_ATTENDED_AND_ACTIVATE = Label.BTN_Orientation_attended_activate;
    public static final String LABEL_HCP_LINK_STUDY_SITES = Label.Studies_FindSitesForStudy;

    //reason labels:
    public static final String REASON_LABEL_STUDY_NO_LONGER_ENROLLING = Label.RSN_Study_no_longer_enrolling;
    public static final String REASON_LABEL_SS_ON_HOLD = Label.RSN_Study_Site_on_hold;
    public static final String REASON_LABEL_HCP_ON_HOLD = Label.RSN_Referring_provider_on_hold;
    public static final String REASON_LABEL_ACTION_NOT_ALLOWED_ON_ACCESS_LEVEL = Label.RSN_Your_permissions_do_not_permit_this_action;
    public static final String REASON_LABEL_TC_REQUIRED = Label.RSN_Acceptance_of_Terms_and_Conditions_required;
    public static final String REASON_LABEL_NOT_ALLOWED_FOR_CURRENT_HCP_STATUS = Label.RSN_Current_status_of_referring_provider_does_not_permit_this_action;
    public static final String REASON_LABEL_NOT_ALLOWED_FOR_CURRENT_SS_STATUS = Label.RSN_Study_Site_permissions_do_not_permit_this_action;
    public static final String REASON_LABEL_LOCKED_BY_ADMIN = Label.RSN_The_status_of_this_record_is_locked_by_site_administration_For_more_informa;

    public List<Action> studyListViewItemActions = new List<Action>();
    public List<Action> studySitePiActions = new List<Action>();
    public List<Action> studyDetailActions = new List<Action>();
    public List<Action> studyDetailBottomBarActions = new List<Action>();
    public Map<String, Action> actions = new Map<String, Action>();

    public transient String userMode;
    public transient Clinical_Trial_Profile__c study;
    public transient Study_Site__c studySite;
    public transient HCP_Enrollment__c hcpEnrollment;

    public transient Boolean isStudyTCAccepted;
    public transient String studyAccessLevel;
    public transient Boolean isTCAcceptanceRequired;

    protected transient DisableReason studyNoLongerEnrollingReason;
    protected transient DisableReason studySiteNotAcceptedReason;
    protected transient DisableReason studySiteOnHoldReason;
    protected transient DisableReason hcpNotActiveReason;
    protected transient DisableReason hcpOnHoldReason;
    protected transient DisableReason hcpLockedByAdmin;
    protected transient DisableReason supportLevelReason;
    protected transient DisableReason level2AndLowReason;
    protected transient DisableReason level1AndLowReason;
    protected transient DisableReason tcAcceptanceRequiredReason;

    private static Map<Id, Boolean> tcAcceptanceMap;

    public StudyActions() {
    }

    public StudyActions(
        Clinical_Trial_Profile__c study,
        Study_Site__c studySite,
        HCP_Enrollment__c hcpEnrollment,
        String userMode
    ) {
        this(study, studySite, hcpEnrollment, userMode, null);
    }

    public StudyActions(
        Clinical_Trial_Profile__c study,
        Study_Site__c studySite,
        HCP_Enrollment__c hcpEnrollment,
        String userMode,
        String delegateId
    ) {
        this.userMode = userMode;
        this.study = study;
        this.studySite = studySite;
        this.hcpEnrollment = hcpEnrollment;

        isStudyTCAccepted = isTCAccepted(study.Id);
        studyAccessLevel = DelegateService.getStudyAccessLevel(
            studySite != null ? studySite.Id : null,
            userMode,
            delegateId
        );

        isTCAcceptanceRequired =
            study.Terms_And_Conditions_ID__c != null &&
            isStudyTCAccepted != null &&
            !isStudyTCAccepted;

        //init common reasons:
        studyNoLongerEnrollingReason = new DisableReason(
            study.Override_Recruitment_Status__c != TrialService.STATUS_ACTIVELY_ENROLLING,
            REASON_LABEL_STUDY_NO_LONGER_ENROLLING
        );

        studySiteNotAcceptedReason = new DisableReason(
            studySite != null &&
            !StudySiteService.STATUS_GROUP_ACCEPTED.contains(
                //studySite.Override_PI_Referral_Status__c
                studySite.Site_Activation_Status__c
            ),
            REASON_LABEL_NOT_ALLOWED_FOR_CURRENT_SS_STATUS
        );

        studySiteOnHoldReason = new DisableReason(
            studySite != null &&
            StudySiteService.STATUS_GROUP_ON_HOLD.contains(
                //studySite.Override_PI_Referral_Status__c
                studySite.Site_Activation_Status__c
            ),
            REASON_LABEL_SS_ON_HOLD
        );

        hcpNotActiveReason = new DisableReason(
            hcpEnrollment != null &&
            !HCPEnrollmentService.STATUS_GROUP_ACTIVATED.contains(hcpEnrollment.Status__c),
            REASON_LABEL_NOT_ALLOWED_FOR_CURRENT_HCP_STATUS
        );

        hcpOnHoldReason = new DisableReason(
            hcpEnrollment != null &&
            HCPEnrollmentService.STATUS_GROUP_ON_HOLD.contains(hcpEnrollment.Status__c),
            REASON_LABEL_HCP_ON_HOLD
        );

        hcpLockedByAdmin = new DisableReason(
            hcpEnrollment != null && hcpEnrollment.Status__c.containsIgnoreCase('admin'),
            REASON_LABEL_LOCKED_BY_ADMIN
        );

        supportLevelReason = new DisableReason(
            studyAccessLevel == DelegateService.DELEGATE_LEVEL_3,
            REASON_LABEL_ACTION_NOT_ALLOWED_ON_ACCESS_LEVEL
        );

        level2AndLowReason = new DisableReason(
            DelegateService.DELEGATE_LEVEL_2_AND_LOW.contains(studyAccessLevel),
            REASON_LABEL_ACTION_NOT_ALLOWED_ON_ACCESS_LEVEL
        );

        level1AndLowReason = new DisableReason(
            DelegateService.DELEGATE_LEVEL_2_AND_LOW.contains(studyAccessLevel),
            REASON_LABEL_ACTION_NOT_ALLOWED_ON_ACCESS_LEVEL
        );

        tcAcceptanceRequiredReason = new DisableReason(
            isTCAcceptanceRequired,
            REASON_LABEL_TC_REQUIRED
        );

        //common actions:
        actions.put(
            ACT_ACCEPT_TC,
            new Action(
                ACT_ACCEPT_TC,
                LABEL_ACCEPT_TC,
                'paper-many',
                new List<DisableReason>{
                    new DisableReason(study.Terms_And_Conditions_ID__c == null, '')
                },
                'primary'
            )
        );
        actions.put(
            ACT_VIEW_TC,
            new Action(
                ACT_VIEW_TC,
                LABEL_VIEW_TC,
                'paper-many',
                new List<DisableReason>{
                    new DisableReason(study.Terms_And_Conditions_ID__c == null, '')
                },
                'primary'
            )
        );
        actions.put(
            ACT_DELEGATE,
            new Action(
                ACT_DELEGATE,
                LABEL_DELEGATE,
                null,
                new List<DisableReason>{
                    new DisableReason(
                        studyAccessLevel != DelegateService.OWNER_LEVEL,
                        REASON_LABEL_ACTION_NOT_ALLOWED_ON_ACCESS_LEVEL
                    )
                },
                'secondary'
            )
        );
    }

    public void checkAction(String actionId) {
        Action action = actions.get(actionId);
        if (action == null || action.disabled) {
            String message = 'Action not allowed';
            if (action != null && !String.isEmpty(action.disableReason))
                message += '. Reason: ' + action.disableReason;
            System.debug('Action exception:' + message);
            throw new CommunityServiceException(message);
        }
    }

    public Boolean isTCAccepted(Id studyId) {
        if (tcAcceptanceMap == null) {
            List<Clinical_Trial_Profile__c> trials = TrialService.getAvailableTrials(userMode);
            tcAcceptanceMap = TermsAndConditions.getTrialsAcceptanceMap(trials);
        }
        return tcAcceptanceMap.get(studyId);
    }
}