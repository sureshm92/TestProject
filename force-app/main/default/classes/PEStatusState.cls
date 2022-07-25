/**
 * Created by Leonid Bartenev
 */

public without sharing class PEStatusState {
    public class StatusStep {
        public String name;
        public Map<String, List<String>> states;

        public StatusStep(String name, Map<String, List<String>> states) {
            this.name = name;
            this.states = states;
        }

        public List<String> getStatus(String state) {
            return states.get(state);
        }
    }

    public static final String STATUS_STATE_IN_PROGRESS = 'in_progress';
    public static final String STATUS_STATE_SUCCESS = 'success';
    public static final String STATUS_STATE_FAILURE = 'failure';
    public static final String STATUS_STATE_NEUTRAL = 'neutral';
    public static final List<String> STATUS_STATE_LIST = new List<String>{
        STATUS_STATE_SUCCESS,
        STATUS_STATE_IN_PROGRESS,
        STATUS_STATE_FAILURE
    };

    //participant states:
    public static final String PE_ST_REFERRED = Label.PE_ST_Referred;
    public static final String PE_ST_REFERRAL_ACCEPTANCE = Label.PE_ST_Referral_Acceptance;
    public static final String PE_ST_CONTACT_ATTEMPTS = Label.PE_ST_Contact_Attempts;
    public static final String PE_ST_INITIAL_VISIT_ELIGIBILITY = Label.PE_ST_Initial_Visit_And_Screening;
    public static final String PE_ST_SCREENING = Label.PE_ST_Eligibility;
    public static final String PE_ST_ENROLLED_RANDOMIZED = Label.PE_ST_Enrolled_Randomized;

    //participant statuses:

    //deprecated statuses
    //TODO:check
    public static final String PE_STATUS_REFERRAL_SENT_TO_PI = 'Referral Sent to PI';
    public static final String PE_STATUS_REFERRAL_ACCEPTED = 'Referral Accepted';
    public static final String PE_STATUS_REFERRAL_ON_HOLD = 'Referral On Hold';
    public static final String PE_STATUS_REFERRAL_DECLINED = 'Referral Declined';
    //    public static final String PE_STATUS_CONTACT_SUCCESSFUL = 'Contact Successful';
    //    public static final String PE_STATUS_CONTACT_ATTEMPT_IN_PROGRESS = 'Contact Attempt in Progress';
    //    public static final String PE_STATUS_CONTACT_FAILED = 'Contact Failed';
    //    public static final String PE_STATUS_SCREENING_COMPLETE = 'Screening Complete';

    //Received Step
    public static final String PE_STATUS_RECEIVED = 'Received'; //TODO:check
    //Contact Step
    public static final String PE_STATUS_PRE_REVIEW_PASSED = 'Pre-review Passed'; //REF-1827 Added by Sumit S
    public static final String PE_STATUS_PRE_REVIEW_FAILED = 'Pre-review Failed'; //REF-1827 Added by Sumit S
    public static final String PE_STATUS_SUCCESSFULLY_CONTACTED = 'Successfully Contacted'; //TODO:check
    public static final String PE_STATUS_CONTACT_ATTEMPTED = 'Contact Attempted'; //TODO:check
    public static final String PE_STATUS_CONTACTED_NOT_SUITABLE = 'Contacted - Not Suitable'; //TODO:check
    public static final String PE_STATUS_UNABLE_TO_REACH = 'Unable to Reach'; //TODO:check
    public static final String PE_STATUS_SUCCESSFULLY_REENGAGED = 'Successfully re-engaged';
    public static final String PE_STATUS_NO_SHOW = 'Participant No Show';

    //Eligibility Step
    public static final String PE_STATUS_ELIGIBILITY_PASSED = 'Eligibility Passed';
    public static final String PE_STATUS_ELIGIBILITY_FAILED = 'Eligibility Failed';
    //Screening Step
    public static final String PE_STATUS_SCREENING_IN_PROGRESS = 'Screening In Progress';
    public static final String PE_STATUS_SCREENING_IN_PROGRESS_WASH_OUT_PERIOD = 'Screening In Progress - Wash Out Period'; //TODO:check
    public static final String PE_STATUS_SCREENING_PASSED = 'Screening Passed';
    public static final String PE_STATUS_SCREENING_PASSED_WASH_OUT_PERIOD = 'Screening Passed - Wash Out Period'; //TODO:check
    public static final String PE_STATUS_SCREENING_FAILED = 'Screening Failed';
    public static final String PE_STATUS_UNABLE_TO_SCREEN = 'Unable to Screen';
    public static final String PE_STATUS_READY_TO_SCREEN = 'Ready to Screen';
    public static final String PE_STATUS_DECLINED_CONSENT = 'Declined Consent';
    public static final String PE_STATUS_WITHDREW_CONSENT = 'Withdrew Consent';
    //Enrollment Step
    public static final String PE_STATUS_ENROLLMENT_OLD = 'Enrolled';
    public static final String PE_STATUS_ENROLLMENT_SUCCESS = 'Enrollment Success';
    public static final String PE_STATUS_ENROLLMENT_FAILED = 'Enrollment Failed';
    //Randomization Step
    public static final String PE_STATUS_RANDOMIZATION_SUCCESS = 'Randomization Success'; //TODO:check
    public static final String PE_STATUS_RANDOMIZATION_FAILED = 'Randomization Failed'; //TODO:check

    public static final String PE_STATUS_WITHDREW_CONSENT_AFTER_SCREENING = 'Withdrew Consent After Screening';
    public static final String PE_STATUS_DECLINED_FINAL_CONSENT = 'Declined Final Consent';

    public static final String PE_STATUS_PENDING_REFERRAL = 'Pending Referral';
    public static final String PE_STATUS_EXCLUDED_FROM_REFERRING = 'Excluded from Referring';
    public static final String PE_STATUS_FAILED_REVIEW = 'Failed Review';
    public static final String PE_STATUS_FAILED_REFERRAL = 'Failed Referral';

    public static final String PE_STATUS_TREATMENT_PERIOD_STARTED = 'Treatment Period Started';
    public static final String PE_STATUS_FOLLOW_UP_PERIOD_STARTED = 'Follow-Up Period Started';
    public static final String PE_STATUS_PARTICIPATION_COMPLETE = 'Participation Complete';
    public static final String PE_STATUS_TRIAL_COMPLETE = 'Trial Complete';
    public static final String PE_STATUS_DROP_OUT = 'Drop Out';
    public static final String PE_STATUS_DECEASED = 'Deceased';

    public static final String PE_STATUSES_ACTIVE = 'Active';
    public static final String PE_STATUSES_INACTIVE = 'Inactive';

    public static final String PW_FINAL_STEP_RANDOMIZATION = 'Randomization';
    public static final String PW_FINAL_STEP_ENROLLMENT = 'Enrollment';

    //status groups:
    public static final List<String> PE_STATUS_GROUP_FAILED = new List<String>{
        PE_STATUS_REFERRAL_DECLINED,
        PE_STATUS_PRE_REVIEW_FAILED,
        PE_STATUS_CONTACTED_NOT_SUITABLE,
        PE_STATUS_UNABLE_TO_REACH,
        PE_STATUS_ELIGIBILITY_FAILED,
        PE_STATUS_SCREENING_FAILED,
        PE_STATUS_UNABLE_TO_SCREEN,
        PE_STATUS_DECLINED_CONSENT,
        PE_STATUS_WITHDREW_CONSENT,
        PE_STATUS_ENROLLMENT_FAILED,
        PE_STATUS_RANDOMIZATION_FAILED,
        PE_STATUS_FAILED_REVIEW,
        PE_STATUS_FAILED_REFERRAL,
        PE_STATUS_EXCLUDED_FROM_REFERRING,
        PE_STATUS_WITHDREW_CONSENT_AFTER_SCREENING,
        PE_STATUS_DECLINED_FINAL_CONSENT
    };

    public static final List<String> PE_STATUS_GROUP_ALUMNI = new List<String>{
        PE_STATUS_FAILED_REVIEW,
        PE_STATUS_FAILED_REFERRAL,
        PE_STATUS_PRE_REVIEW_FAILED,
        PE_STATUS_CONTACTED_NOT_SUITABLE,
        PE_STATUS_EXCLUDED_FROM_REFERRING,
        PE_STATUS_REFERRAL_DECLINED,
        PE_STATUS_UNABLE_TO_REACH,
        PE_STATUS_ELIGIBILITY_FAILED,
        PE_STATUS_DECLINED_CONSENT,
        PE_STATUS_WITHDREW_CONSENT,
        PE_STATUS_SCREENING_FAILED,
        PE_STATUS_UNABLE_TO_SCREEN,
        PE_STATUS_ENROLLMENT_FAILED,
        PE_STATUS_RANDOMIZATION_FAILED,
        PE_STATUS_WITHDREW_CONSENT_AFTER_SCREENING,
        PE_STATUS_DROP_OUT,
        PE_STATUS_PARTICIPATION_COMPLETE,
        PE_STATUS_TRIAL_COMPLETE
    };

    public static final List<String> PE_STATUS_GROUP_IN_PROGRESS = new List<String>{
        PE_STATUS_REFERRAL_SENT_TO_PI,
        PE_STATUS_REFERRAL_ACCEPTED,
        PE_STATUS_REFERRAL_ON_HOLD,
        PE_STATUS_RECEIVED,
        PE_STATUS_SUCCESSFULLY_CONTACTED,
        PE_STATUS_PRE_REVIEW_PASSED,
        PE_STATUS_CONTACT_ATTEMPTED,
        PE_STATUS_ELIGIBILITY_PASSED,
        PE_STATUS_SCREENING_PASSED,
        PE_STATUS_SCREENING_IN_PROGRESS,
        PE_STATUS_SCREENING_IN_PROGRESS_WASH_OUT_PERIOD,
        PE_STATUS_READY_TO_SCREEN
    };

    public static final List<String> PE_STATUS_GROUP_IN_PROGRESS_NOT_ON_HOLD = new List<String>{
        PE_STATUS_REFERRAL_SENT_TO_PI,
        PE_STATUS_REFERRAL_ACCEPTED,
        PE_STATUS_RECEIVED,
        PE_STATUS_SUCCESSFULLY_CONTACTED,
        PE_STATUS_PRE_REVIEW_PASSED,
        PE_STATUS_CONTACT_ATTEMPTED,
        PE_STATUS_ELIGIBILITY_PASSED,
        PE_STATUS_SCREENING_PASSED,
        PE_STATUS_SCREENING_IN_PROGRESS,
        PE_STATUS_SCREENING_IN_PROGRESS_WASH_OUT_PERIOD,
        PE_STATUS_READY_TO_SCREEN
    };
    //TODO:check
    public static final List<String> PE_STATUS_GROUP_PARTICIPATION_FLOW_WITHOUT_INITIAL = new List<String>{
        PE_STATUS_TREATMENT_PERIOD_STARTED,
        PE_STATUS_FOLLOW_UP_PERIOD_STARTED,
        PE_STATUS_PARTICIPATION_COMPLETE,
        PE_STATUS_TRIAL_COMPLETE
    };

    //TODO:check
    public static final List<String> PE_STATUS_GROUP_PARTICIPATION_IN_PROGRESS = new List<String>{
        PE_STATUS_ENROLLMENT_SUCCESS,
        PE_STATUS_RANDOMIZATION_SUCCESS,
        PE_STATUS_TREATMENT_PERIOD_STARTED,
        PE_STATUS_FOLLOW_UP_PERIOD_STARTED
    };

    //Add any new Status comes equivalent to below added statuses
    public static final List<String> PE_STATUS_GROUP_PARTICIPATION_IN_ENROLLMENT_SUCCESS = new List<String>{
        PE_STATUS_ENROLLMENT_SUCCESS,
        PE_STATUS_RANDOMIZATION_SUCCESS
    };

    public static final List<String> PE_STATUS_GROUP_PARTICIPANT;

    public static final List<String> PE_STATUS_GROUP_COMPLETE = new List<String>{
        PE_STATUS_PARTICIPATION_COMPLETE,
        PE_STATUS_TRIAL_COMPLETE,
        PE_STATUS_DROP_OUT,
        PE_STATUS_DECEASED
    };

    public static final List<String> PE_STATUS_GROUP_POST_ENROLLMENT_VISIT_RELATED = new List<String>{
        PE_STATUS_ENROLLMENT_SUCCESS,
        PE_STATUS_RANDOMIZATION_SUCCESS,
        PE_STATUS_TREATMENT_PERIOD_STARTED,
        PE_STATUS_FOLLOW_UP_PERIOD_STARTED,
        PE_STATUS_PARTICIPATION_COMPLETE,
        PE_STATUS_TRIAL_COMPLETE,
        PE_STATUS_DROP_OUT
    };

    public static final List<String> PE_STATUS_GROUP_ACTIVE = new List<String>{
        PE_STATUS_REFERRAL_SENT_TO_PI,
        PE_STATUS_REFERRAL_ACCEPTED,
        PE_STATUS_REFERRAL_ON_HOLD,
        PE_STATUS_RECEIVED,
        PE_STATUS_SUCCESSFULLY_CONTACTED,
        PE_STATUS_PRE_REVIEW_PASSED,
        PE_STATUS_CONTACT_ATTEMPTED,
        PE_STATUS_ELIGIBILITY_PASSED,
        PE_STATUS_SCREENING_PASSED,
        PE_STATUS_SCREENING_IN_PROGRESS,
        PE_STATUS_SCREENING_IN_PROGRESS_WASH_OUT_PERIOD,
        PE_STATUS_READY_TO_SCREEN,
        PE_STATUS_ENROLLMENT_SUCCESS,
        PE_STATUS_RANDOMIZATION_SUCCESS,
        PE_STATUS_TREATMENT_PERIOD_STARTED,
        PE_STATUS_FOLLOW_UP_PERIOD_STARTED,
        PE_STATUS_PARTICIPATION_COMPLETE
    };

    public static final List<String> PE_STATUS_GROUP_POSITIVE_PARTICIPANTS_CONTACTED = new List<String>{
        PE_STATUS_Eligibility_Passed,
        PE_STATUS_Screening_In_Progress,
        PE_STATUS_Enrollment_Success,
        PE_STATUS_Treatment_Period_Started,
        PE_STATUS_Follow_Up_Period_Started,
        PE_STATUS_Participation_Complete,
        PE_STATUS_Trial_Complete,
        PE_STATUS_Received,
        PE_STATUS_Successfully_Contacted,
        PE_STATUS_Contact_Attempted,
        PE_STATUS_Screening_Passed,
        PE_STATUS_Randomization_Success,
        PE_STATUS_Screening_In_Progress_Wash_Out_Period,
        PE_STATUS_Ready_to_Screen,
        PE_STATUS_Pre_review_Passed,
        PE_STATUS_Unable_to_Reach
    };
    
    public static final List<String> PE_STATUS_GROUP_INACTIVE = new List<String>{
        PE_STATUS_REFERRAL_DECLINED,
        PE_STATUS_CONTACTED_NOT_SUITABLE,
        PE_STATUS_PRE_REVIEW_FAILED,
        PE_STATUS_UNABLE_TO_REACH,
        PE_STATUS_ELIGIBILITY_FAILED,
        PE_STATUS_SCREENING_FAILED,
        PE_STATUS_UNABLE_TO_SCREEN,
        PE_STATUS_DECLINED_CONSENT,
        PE_STATUS_WITHDREW_CONSENT,
        PE_STATUS_ENROLLMENT_FAILED,
        PE_STATUS_RANDOMIZATION_FAILED,
        PE_STATUS_WITHDREW_CONSENT_AFTER_SCREENING,
        PE_STATUS_DECLINED_FINAL_CONSENT,
        PE_STATUS_TRIAL_COMPLETE,
        PE_STATUS_DROP_OUT,
        PE_STATUS_DECEASED
    };

    public static final List<String> PE_STATUS_GROUP_VISIT_PLAN_CHECK = new List<String>{
        PE_STATUS_FAILED_REFERRAL,
        PE_STATUS_FAILED_REVIEW,
        PE_STATUS_PENDING_REFERRAL,
        PE_STATUS_REFERRAL_SENT_TO_PI,
        PE_STATUS_REFERRAL_ACCEPTED,
        PE_STATUS_REFERRAL_ON_HOLD,
        PE_STATUS_REFERRAL_DECLINED,
        PE_STATUS_RECEIVED,
        PE_STATUS_EXCLUDED_FROM_REFERRING,
        PE_STATUS_PRE_REVIEW_PASSED,
        PE_STATUS_PRE_REVIEW_FAILED,
        PE_STATUS_SUCCESSFULLY_CONTACTED,
        PE_STATUS_CONTACT_ATTEMPTED,
        PE_STATUS_CONTACTED_NOT_SUITABLE,
        PE_STATUS_UNABLE_TO_REACH,
        PE_STATUS_ELIGIBILITY_PASSED,
        PE_STATUS_ELIGIBILITY_FAILED,
        PE_STATUS_SCREENING_PASSED,
        PE_STATUS_SCREENING_IN_PROGRESS,
        PE_STATUS_SCREENING_IN_PROGRESS_WASH_OUT_PERIOD,
        PE_STATUS_READY_TO_SCREEN,
        PE_STATUS_SCREENING_FAILED,
        PE_STATUS_UNABLE_TO_SCREEN,
        PE_STATUS_DECLINED_CONSENT,
        PE_STATUS_WITHDREW_CONSENT
    };

    public static final List<String> PE_STATUS_GROUP_PARTICIPANT_IMPORT = new List<String>{
        PE_STATUS_RECEIVED,
        PE_STATUS_SUCCESSFULLY_CONTACTED,
        PE_STATUS_READY_TO_SCREEN,
        PE_STATUS_SCREENING_PASSED,
        PE_STATUS_RANDOMIZATION_SUCCESS,
        PE_STATUS_ENROLLMENT_SUCCESS
    };

    public static final List<String> PE_STATUS_GROUP_PI_VISIBLE;

    public static List<String> PE_STATUS_GROUP_IN_PROGRESS_ALL;
    public static List<String> PE_STATUS_GROUP_NOT_IN_PROGRESS_ALL;

    // Table with data: Status Step -> available states and real statuses names
    //TODO:check
    public static List<StatusStep> STATUS_STEPS_TABLE = new List<StatusStep>{
        new StatusStep(
            PE_ST_REFERRAL_ACCEPTANCE,
            new Map<String, List<String>>{
                STATUS_STATE_SUCCESS => new List<String>{ PE_STATUS_RECEIVED }
            }
        ),
        new StatusStep(
            PE_ST_CONTACT_ATTEMPTS,
            new Map<String, List<String>>{
                STATUS_STATE_SUCCESS => new List<String>{ PE_STATUS_SUCCESSFULLY_CONTACTED },
                STATUS_STATE_IN_PROGRESS => new List<String>{
                    PE_STATUS_CONTACT_ATTEMPTED,
                    PE_STATUS_PRE_REVIEW_PASSED
                },
                STATUS_STATE_FAILURE => new List<String>{
                    PE_STATUS_PRE_REVIEW_FAILED,
                    PE_STATUS_UNABLE_TO_REACH,
                    PE_STATUS_CONTACTED_NOT_SUITABLE
                }
            }
        ),
        new StatusStep(
            PE_ST_INITIAL_VISIT_ELIGIBILITY,
            new Map<String, List<String>>{
                STATUS_STATE_SUCCESS => new List<String>{ PE_STATUS_ELIGIBILITY_PASSED },
                STATUS_STATE_FAILURE => new List<String>{ PE_STATUS_ELIGIBILITY_FAILED }
            }
        ),
        new StatusStep(
            PE_ST_SCREENING,
            new Map<String, List<String>>{
                STATUS_STATE_SUCCESS => new List<String>{ PE_STATUS_SCREENING_PASSED },
                STATUS_STATE_IN_PROGRESS => new List<String>{
                    PE_STATUS_SCREENING_IN_PROGRESS,
                    PE_STATUS_SCREENING_IN_PROGRESS_WASH_OUT_PERIOD,
                    PE_STATUS_READY_TO_SCREEN
                },
                STATUS_STATE_FAILURE => new List<String>{
                    PE_STATUS_SCREENING_FAILED,
                    PE_STATUS_UNABLE_TO_SCREEN,
                    PE_STATUS_DECLINED_CONSENT,
                    PE_STATUS_WITHDREW_CONSENT
                }
            }
        ),
        new StatusStep(
            PE_ST_ENROLLED_RANDOMIZED,
            new Map<String, List<String>>{
                STATUS_STATE_SUCCESS => new List<String>{
                    PE_STATUS_ENROLLMENT_SUCCESS,
                    PE_STATUS_RANDOMIZATION_SUCCESS
                },
                STATUS_STATE_FAILURE => new List<String>{
                    PE_STATUS_ENROLLMENT_FAILED,
                    PE_STATUS_RANDOMIZATION_FAILED,
                    PE_STATUS_WITHDREW_CONSENT_AFTER_SCREENING,
                    PE_STATUS_DECLINED_FINAL_CONSENT
                }
            }
        )
    };

    public static Map<String, StatusStep> STATUS_STEPS_MAP;
    public static List<String> STATUS_STEPS_LIST;
    public static Map<String, Integer> STATUS_STEPS_ORDER_MAP;
    public static Set<String> ALL_USED_STATUSES;
    public static Set<String> ALL_USED_STATUSES_WITH_REFERRING;

    // Map with data: Real Status name -> Status State (step name, state and step number)
    public static Map<String, PEStatusState> STATUSES_MAP;

    //Status groups
    public static List<String> STATUSES_FAILED;
    public static List<String> STATUSES_ON_HOLD;
    public static List<String> STATUSES_IN_PROGRESS;
    public static List<String> STATUSES_ENROLLED;
    //Update with new statuses
    public static Map<String, Integer> PE_ORDERED_STATUSES = new Map<String, Integer>{
        PE_STATUS_REFERRAL_SENT_TO_PI => 1,
        PE_STATUS_REFERRAL_ACCEPTED => 1,
        PE_STATUS_REFERRAL_ON_HOLD => 1,
        PE_STATUS_REFERRAL_DECLINED => 1,
        PE_STATUS_RECEIVED => 1,
        PE_STATUS_PRE_REVIEW_PASSED => 2,
        PE_STATUS_PRE_REVIEW_FAILED => 2,
        PE_STATUS_CONTACT_ATTEMPTED => 2,
        PE_STATUS_SUCCESSFULLY_CONTACTED => 2,
        PE_STATUS_CONTACTED_NOT_SUITABLE => 2,
        PE_STATUS_UNABLE_TO_REACH => 2,
        PE_STATUS_ELIGIBILITY_PASSED => 3,
        PE_STATUS_ELIGIBILITY_FAILED => 3,
        PE_STATUS_SCREENING_PASSED => 4,
        PE_STATUS_SCREENING_IN_PROGRESS => 4,
        PE_STATUS_SCREENING_IN_PROGRESS_WASH_OUT_PERIOD => 4,
        PE_STATUS_READY_TO_SCREEN => 4,
        PE_STATUS_SCREENING_FAILED => 4,
        PE_STATUS_UNABLE_TO_SCREEN => 4,
        PE_STATUS_DECLINED_CONSENT => 4,
        PE_STATUS_WITHDREW_CONSENT => 4,
        PE_STATUS_ENROLLMENT_OLD => 5,
        PE_STATUS_ENROLLMENT_SUCCESS => 5,
        PE_STATUS_ENROLLMENT_FAILED => 5,
        PE_STATUS_RANDOMIZATION_SUCCESS => 5,
        PE_STATUS_RANDOMIZATION_FAILED => 5,
        PE_STATUS_WITHDREW_CONSENT_AFTER_SCREENING => 5,
        PE_STATUS_DECLINED_FINAL_CONSENT => 5,
        PE_STATUS_TREATMENT_PERIOD_STARTED => 6,
        PE_STATUS_FOLLOW_UP_PERIOD_STARTED => 7,
        PE_STATUS_PARTICIPATION_COMPLETE => 8,
        PE_STATUS_TRIAL_COMPLETE => 9,
        PE_STATUS_DROP_OUT => 10,
        PE_STATUS_DECEASED => 11
    };
    //Pre Enrollment status group:
    public static final List<String> PE_STATUS_GROUP_PRE_ENROLLMENT = new List<String>{
        PE_STATUS_RECEIVED,
        PE_STATUS_CONTACT_ATTEMPTED,
        PE_STATUS_SUCCESSFULLY_CONTACTED,
        PE_STATUS_PRE_REVIEW_PASSED,
        PE_STATUS_SCREENING_PASSED,
        PE_STATUS_SCREENING_IN_PROGRESS,
        PE_STATUS_SCREENING_IN_PROGRESS_WASH_OUT_PERIOD,
        PE_STATUS_READY_TO_SCREEN,
        PE_STATUS_ELIGIBILITY_PASSED,
        PE_STATUS_SUCCESSFULLY_REENGAGED,
        PE_STATUS_NO_SHOW
    };
    //Pre Enrollment status group for Pre-consent Toggle at CTP:
    public static final List<String> PE_STATUS_GROUP_FOR_PRE_CONSENT_TOGGLE = new List<String>{
        PE_STATUS_RECEIVED,
        PE_STATUS_SUCCESSFULLY_CONTACTED,
        PE_STATUS_PRE_REVIEW_PASSED,
        PE_STATUS_CONTACT_ATTEMPTED,
        PE_STATUS_ELIGIBILITY_PASSED,
        PE_STATUS_SUCCESSFULLY_REENGAGED,
        PE_STATUS_NO_SHOW
    };
    //Pre Enrollment status group for Consent through Enrolled/Randomized toggle at CTP:
    public static final List<String> PE_STATUS_GROUP_FOR_CONSENT_ENROLL_RANDMZ_TOGGLE = new List<String>{
        PE_STATUS_SCREENING_IN_PROGRESS,
        PE_STATUS_SCREENING_IN_PROGRESS_WASH_OUT_PERIOD,
        PE_STATUS_READY_TO_SCREEN,
        PE_STATUS_SCREENING_PASSED
    };

    //Pre Enrollment status group for Completing the Pre Enrollment Visit Status.
    public static final List<String> PE_STATUS_GROUP_FOR_COMPLETING_PRE_ENROLL_VISITS = new List<String>{
        PE_STATUS_READY_TO_SCREEN,
        PE_STATUS_ENROLLMENT_SUCCESS,
        PE_STATUS_RANDOMIZATION_SUCCESS
    };

    static {
        PE_STATUS_GROUP_IN_PROGRESS_ALL = new List<String>();
        PE_STATUS_GROUP_IN_PROGRESS_ALL.addAll(PE_STATUS_GROUP_IN_PROGRESS);
        PE_STATUS_GROUP_IN_PROGRESS_ALL.addAll(PE_STATUS_GROUP_PARTICIPATION_IN_PROGRESS);

        PE_STATUS_GROUP_NOT_IN_PROGRESS_ALL = new List<String>();
        PE_STATUS_GROUP_NOT_IN_PROGRESS_ALL.addAll(PE_STATUS_GROUP_FAILED);
        PE_STATUS_GROUP_NOT_IN_PROGRESS_ALL.addAll(PE_STATUS_GROUP_COMPLETE);

        PE_STATUS_GROUP_PARTICIPANT = new List<String>{
            PE_STATUS_PARTICIPATION_COMPLETE,
            PE_STATUS_TRIAL_COMPLETE
        };
        PE_STATUS_GROUP_PARTICIPANT.addAll(PE_STATUS_GROUP_PARTICIPATION_IN_PROGRESS);

        PE_STATUS_GROUP_PI_VISIBLE = new List<String>();
        PE_STATUS_GROUP_PI_VISIBLE.addAll(PE_STATUS_GROUP_ACTIVE);
        PE_STATUS_GROUP_PI_VISIBLE.addAll(PE_STATUS_GROUP_INACTIVE);
        prepare();
    }

    public String name;
    public String state;
    public Integer order;

    public PEStatusState(String name, String state, Integer order) {
        this.name = name;
        this.state = state;
        this.order = order;
    }

    // Prepare all data
    public static void prepare() {
        STATUS_STEPS_MAP = new Map<String, PEStatusState.StatusStep>();
        STATUS_STEPS_LIST = new List<String>();
        STATUS_STEPS_ORDER_MAP = new Map<String, Integer>();
        ALL_USED_STATUSES = new Set<String>();
        STATUSES_MAP = new Map<String, PEStatusState>();
        Integer i = 1;

        STATUSES_ON_HOLD = new List<String>();
        STATUSES_IN_PROGRESS = new List<String>();
        STATUSES_ENROLLED = new List<String>();
        STATUSES_FAILED = new List<String>();

        for (StatusStep step : STATUS_STEPS_TABLE) {
            STATUS_STEPS_LIST.add(step.name);
            STATUS_STEPS_MAP.put(step.name, step);
            STATUS_STEPS_ORDER_MAP.put(step.name, i);
            for (String stateName : step.states.keySet()) {
                if (i > 2) {
                    if (stateName == STATUS_STATE_SUCCESS) {
                        if (i == STATUS_STEPS_TABLE.size()) {
                            STATUSES_ENROLLED.addAll(step.getStatus(stateName));
                        } else {
                            STATUSES_IN_PROGRESS.addAll(step.getStatus(stateName));
                        }
                    } else if (stateName == STATUS_STATE_FAILURE) {
                        STATUSES_FAILED.addAll(step.getStatus(stateName));
                    } else if (stateName == STATUS_STATE_IN_PROGRESS) {
                        STATUSES_ON_HOLD.addAll(step.getStatus(stateName));
                    }
                }
                ALL_USED_STATUSES.addAll(step.states.get(stateName));
                for (String status : step.states.get(stateName)) {
                    STATUSES_MAP.put(status, new PEStatusState(step.name, stateName, i));
                }
            }
            i++;
        }
        ALL_USED_STATUSES_WITH_REFERRING = new Set<String>(ALL_USED_STATUSES);
        ALL_USED_STATUSES_WITH_REFERRING.addAll(
            new Set<String>{
                ParticipantEnrollmentService.PART_STATUS_FAILED_REFERRAL,
                ParticipantEnrollmentService.PART_STATUS_FAILED_REVIEW,
                ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL
            }
        );
    }

    public static List<LabelValueItem> getEnrollmentStatusesLVList() {
        List<LabelValueItem> resList = new List<LabelValueItem>{
            new LabelValueItem(Label.PES_L_All_enrollment_statuses, null),
            new LabelValueItem(
                Label.PG_MPS_L_Enrolled,
                '(\'' +
                String.join(STATUSES_ENROLLED, '\',\'') +
                '\')'
            ),
            new LabelValueItem(
                Label.PG_MSS_L_On_hold,
                '(\'' +
                String.join(STATUSES_ON_HOLD, '\',\'') +
                '\')'
            ),
            new LabelValueItem(
                Label.DI_L_In_progress,
                '(\'' +
                String.join(STATUSES_IN_PROGRESS, '\',\'') +
                '\')'
            ),
            new LabelValueItem(
                Label.PG_MRR_R_Failed,
                '(\'' +
                String.join(STATUSES_FAILED, '\',\'') +
                '\')'
            )
        };
        return resList;
    }
    //deprecated
    //    public static List<LabelValueItem> getStepsLVList(){
    //        List<LabelValueItem> resList = new List<LabelValueItem>{
    //                new LabelValueItem(Label.PES_L_All_Steps, null)
    //        };
    //        for(StatusStep step : STATUS_STEPS_TABLE){
    //            resList.add(new LabelValueItem(step.name, '(\'' + String.join(step.states.values(), '\',\'') + '\')'));
    //        }
    //        return resList;
    //    }

    public static List<LabelValueItem> getAcceptenceStatusesLVList() {
        List<LabelValueItem> resList = new List<LabelValueItem>{
            new LabelValueItem(Label.PES_L_All_acceptance_statuses, null) //,
            //                new LabelValueItem(Label.PG_MRR_L_Pending, '(\'' + ParticipantEnrollmentService.PART_STATUS_REFERRAL_SENT_TO_PI + '\')'),
            //                new LabelValueItem(Label.DI_L_Accepted, '(\'' + STATUS_STEPS_TABLE[1].states.get(STATUS_STATE_SUCCESS) + '\')'),
            //                new LabelValueItem(Label.PG_MSS_L_On_hold, '(\'' + STATUS_STEPS_TABLE[1].states.get(STATUS_STATE_IN_PROGRESS) + '\')'),
            //                new LabelValueItem(Label.DI_L_Declined, '(\'' + STATUS_STEPS_TABLE[1].states.get(STATUS_STATE_FAILURE) + '\')')
        };
        return resList;
    }

    public static List<LabelValueItem> getReferringStatusesLVList() {
        List<LabelValueItem> resList = new List<LabelValueItem>{
            new LabelValueItem(Label.PES_L_All_enrollment_statuses, null),
            new LabelValueItem(
                Label.DI_L_In_progress,
                '(\'' +
                String.join(PE_STATUS_GROUP_IN_PROGRESS_NOT_ON_HOLD, '\',\'') +
                '\')'
            ),
            new LabelValueItem(Label.PG_MSS_L_On_hold, '(\'' + PE_STATUS_REFERRAL_ON_HOLD + '\')'),
            new LabelValueItem(
                Label.PG_MPS_L_Enrolled,
                '(\'' +
                PE_STATUS_ENROLLMENT_SUCCESS +
                '\')'
            ),
            new LabelValueItem(
                Label.PG_MRR_R_Failed,
                '(\'' +
                String.join(PE_STATUS_GROUP_FAILED, '\',\'') +
                '\')'
            )
        };
        return resList;
    }

    private static String getCTPParticipantWorkflowFinalStep(Clinical_Trial_Profile__c ctp) {
        if (ctp.Participant_Workflow_Final_Step__c == PW_FINAL_STEP_RANDOMIZATION) {
            return PE_STATUS_RANDOMIZATION_SUCCESS;
        } else {
            return PE_STATUS_ENROLLMENT_SUCCESS;
        }
    }

    public static String getParticipationFlowInitialStep(Participant_Enrollment__c pe) {
        return getCTPParticipantWorkflowFinalStep(pe.Clinical_Trial_Profile__r);
    }

    public static List<String> getParticipantImportStatuses(Clinical_Trial_Profile__c ctp) {
        List<String> statuses = ParticipantWorkflowService.filterStatusesForCTPSettings(
            PE_STATUS_GROUP_PARTICIPANT_IMPORT,
            ctp
        );
        return statuses;
    }

    public static List<LabelValueItem> getParticipantImportStatusesLV(
        Clinical_Trial_Profile__c ctp
    ) {
        return getStatusesLV(
            getParticipantImportStatuses(ctp),
            new Map<String, String>{
                PE_STATUS_RECEIVED => TranslateHelper.getLabelValue(
                    'PWS_Contact_Outcome_Placeholder'
                )
            }
        );
    }

    public static List<String> getParticipationFlowSteps(Participant_Enrollment__c pe) {
        List<String> flowSteps = new List<String>();
        flowSteps.add(getParticipationFlowInitialStep(pe));
        flowSteps.addAll(PE_STATUS_GROUP_PARTICIPATION_FLOW_WITHOUT_INITIAL);
        return flowSteps;
    }

    public static List<LabelValueItem> getParticipationFlowStepsLV(Participant_Enrollment__c pe) {
        return getStatusesLV(getParticipationFlowSteps(pe), null);
    }

    private static List<LabelValueItem> getStatusesLV(
        List<String> statuses,
        Map<String, String> overrideLabels
    ) {
        List<LabelValueItem> statusesLV = new List<LabelValueItem>();
        for (String status : statuses) {
            if (overrideLabels != null && overrideLabels.containsKey(status)) {
                statusesLV.add(new LabelValueItem(overrideLabels.get(status), status));
            } else {
                statusesLV.add(
                    new LabelValueItem(
                        TranslateHelper.getPickListLabel(
                            Participant_Enrollment__c.Participant_Status__c,
                            status
                        ),
                        status
                    )
                );
            }
        }
        return statusesLV;
    }
}
