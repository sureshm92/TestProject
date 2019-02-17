/**
 * Created by Leonid Bartenev
 */

public without sharing class PEStatusState {

    public class StatusStep{
        public String name;
        public Map<String, String> states;

        public StatusStep(String name, Map<String, String> states){
            this.name = name;
            this.states = states;
        }
        
        public String getStatus(String state){
            return states.get(state);
        }
    }

    public static final String STATUS_STATE_IN_PROGRESS = 'in_progress';
    public static final String STATUS_STATE_SUCCESS = 'success';
    public static final String STATUS_STATE_FAILURE = 'failure';
    public static final List<String> STATUS_STATE_LIST = new List<String> {
            STATUS_STATE_SUCCESS,
            STATUS_STATE_IN_PROGRESS,
            STATUS_STATE_FAILURE
    };
    
    //participant states:
    public static final String PE_ST_REFERRED = Label.PE_ST_Referred;
    public static final String PE_ST_REFERRAL_ACCEPTANCE = Label.PE_ST_Referral_Acceptance;
    public static final String PE_ST_CONTACT_ATTEMPTS = Label.PE_ST_Contact_Attempts;
    public static final String PE_ST_ELIGIBILITY = Label.PE_ST_Eligibility;
    public static final String PE_ST_INITIAL_VISIT_SCREENING = Label.PE_ST_Initial_Visit_And_Screening;
    public static final String PE_ST_ENROLLED_RANDOMIZED = Label.PE_ST_Enrolled_Randomized;
    
    //participant statuses:
    public static final String PE_STATUS_REFERRAL_SENT_TO_PI = 'Referral Sent to PI';
    public static final String PE_STATUS_REFERRAL_ACCEPTED = 'Referral Accepted';
    public static final String PE_STATUS_REFERRAL_ON_HOLD = 'Referral On Hold';
    public static final String PE_STATUS_REFERRAL_DECLINED = 'Referral Declined';
    public static final String PE_STATUS_CONTACT_SUCCESSFUL = 'Contact Successful';
    public static final String PE_STATUS_CONTACT_ATTEMPT_IN_PROGRESS = 'Contact Attempt In Progress';
    public static final String PE_STATUS_CONTACT_FAILED = 'Contact Failed';
    public static final String PE_STATUS_ELIGIBILITY_PASSED = 'Eligibility Passed';
    public static final String PE_STATUS_ELIGIBILITY_FAILED = 'Eligibility Failed';
    public static final String PE_STATUS_SCREENING_COMPLETE = 'Screening Complete';
    public static final String PE_STATUS_SCREENING_IN_PROGRESS= 'Screening In Progress';
    public static final String PE_STATUS_SCREENING_FAILED = 'Screening Failed';
    public static final String PE_STATUS_ENROLLMENT_SUCCESS= 'Enrollment Success';
    public static final String PE_STATUS_ENROLLMENT_FAILED = 'Enrollment Failed';
    
    // Table with data: Status Step -> available states and real statuses names
    public static List<StatusStep> STATUS_STEPS_TABLE = new List<StatusStep>{
            new StatusStep(PE_ST_REFERRED,
                    new Map<String, String>{
                            STATUS_STATE_SUCCESS => PE_STATUS_REFERRAL_SENT_TO_PI
                    }),
            new StatusStep(PE_ST_REFERRAL_ACCEPTANCE,
                    new Map<String, String>{
                            STATUS_STATE_SUCCESS => PE_STATUS_REFERRAL_ACCEPTED,
                            STATUS_STATE_IN_PROGRESS => PE_STATUS_REFERRAL_ON_HOLD,
                            STATUS_STATE_FAILURE => PE_STATUS_REFERRAL_DECLINED
                    }),
            new StatusStep(PE_ST_CONTACT_ATTEMPTS,
                    new Map<String, String>{
                            STATUS_STATE_SUCCESS => PE_STATUS_CONTACT_SUCCESSFUL,
                            STATUS_STATE_IN_PROGRESS => PE_STATUS_CONTACT_ATTEMPT_IN_PROGRESS,
                            STATUS_STATE_FAILURE => PE_STATUS_CONTACT_FAILED
                    }),
            new StatusStep(PE_ST_ELIGIBILITY,
                    new Map<String, String>{
                            STATUS_STATE_SUCCESS => PE_STATUS_ELIGIBILITY_PASSED,
                            STATUS_STATE_FAILURE => PE_STATUS_ELIGIBILITY_FAILED
                    }),
            new StatusStep(PE_ST_INITIAL_VISIT_SCREENING,
                    new Map<String, String>{
                            STATUS_STATE_SUCCESS => PE_STATUS_SCREENING_COMPLETE,
                            STATUS_STATE_IN_PROGRESS => PE_STATUS_SCREENING_IN_PROGRESS,
                            STATUS_STATE_FAILURE => PE_STATUS_SCREENING_FAILED
                    }),
            new StatusStep(PE_ST_ENROLLED_RANDOMIZED,
                    new Map<String, String>{
                            STATUS_STATE_SUCCESS => PE_STATUS_ENROLLMENT_SUCCESS,
                            STATUS_STATE_FAILURE => PE_STATUS_ENROLLMENT_FAILED
                    })

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

    static {
        prepare();
    }


    public String name;
    public String state;
    public Integer order;

    public PEStatusState(String name, String state, Integer order){
        this.name = name;
        this.state = state;
        this.order = order;
    }

    // Prepare all data
    public static void prepare(){
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
    
        for(StatusStep step : STATUS_STEPS_TABLE) {
            STATUS_STEPS_LIST.add(step.name);
            STATUS_STEPS_MAP.put(step.name, step);
            STATUS_STEPS_ORDER_MAP.put(step.name, i);
            for(String stateName : step.states.keySet()){
                if(i > 2){
                    if(stateName == STATUS_STATE_SUCCESS){
                        if(i == STATUS_STEPS_TABLE.size()){
                            STATUSES_ENROLLED.add(step.getStatus(stateName));
                        }else{
                            STATUSES_IN_PROGRESS.add(step.getStatus(stateName));
                        }
                    }else if(stateName == STATUS_STATE_FAILURE){
                        STATUSES_FAILED.add(step.getStatus(stateName));
                    }else if(stateName == STATUS_STATE_IN_PROGRESS){
                        STATUSES_ON_HOLD.add(step.getStatus(stateName));
                    }
                }
                ALL_USED_STATUSES.add(step.states.get(stateName));
                STATUSES_MAP.put(step.states.get(stateName), new PEStatusState(step.name, stateName, i));
            }
            i++;
        }
        ALL_USED_STATUSES_WITH_REFERRING = new Set<String>(ALL_USED_STATUSES);
        ALL_USED_STATUSES_WITH_REFERRING.addAll(new Set<String>{
                ParticipantEnrollmentService.PART_STATUS_FAILED_REFERRAL,
                ParticipantEnrollmentService.PART_STATUS_FAILED_REVIEW,
                ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL
        });
    }
    
    public static List<LabelValueItem> getEnrollmentStatusesLVList(){
        List<LabelValueItem> resList = new List<LabelValueItem>{
                new LabelValueItem(Label.PES_L_All_enrollment_statuses , null),
                new LabelValueItem(Label.PG_MPS_L_Enrolled, '(\'' + String.join(STATUSES_ENROLLED, '\',\'') + '\')'),
                new LabelValueItem(Label.PG_MSS_L_On_hold, '(\'' + String.join(STATUSES_ON_HOLD, '\',\'') + '\')'),
                new LabelValueItem(Label.DI_L_In_progress, '(\'' + String.join(STATUSES_IN_PROGRESS, '\',\'') + '\')'),
                new LabelValueItem(Label.PG_MRR_R_Failed, '(\'' + String.join(STATUSES_FAILED, '\',\'') + '\')')
        };
        return resList;
    }
    
    public static List<LabelValueItem> getStepsLVList(){
        List<LabelValueItem> resList = new List<LabelValueItem>{
                new LabelValueItem(Label.PES_L_All_Steps, null)
        };
        for(StatusStep step : STATUS_STEPS_TABLE){
            resList.add(new LabelValueItem(step.name, '(\'' + String.join(step.states.values(), '\',\'') + '\')'));
        }
        return resList;
    }
    
    public static List<LabelValueItem> getAcceptenceStatusesLVList(){
        List<LabelValueItem> resList = new List<LabelValueItem>{
                new LabelValueItem(Label.PES_L_All_acceptance_statuses, null),
                new LabelValueItem(Label.PG_MRR_L_Pending, '(\'' + ParticipantEnrollmentService.PART_STATUS_REFERRAL_SENT_TO_PI + '\')'),
                new LabelValueItem(Label.DI_L_Accepted, '(\'' + STATUS_STEPS_TABLE[1].states.get(STATUS_STATE_SUCCESS) + '\')'),
                new LabelValueItem(Label.PG_MSS_L_On_hold, '(\'' + STATUS_STEPS_TABLE[1].states.get(STATUS_STATE_IN_PROGRESS) + '\')'),
                new LabelValueItem(Label.DI_L_Declined, '(\'' + STATUS_STEPS_TABLE[1].states.get(STATUS_STATE_FAILURE) + '\')')
        };
        return resList;
    }
    
    public static List<LabelValueItem> getReferringStatusesLVList(){
        List<LabelValueItem> resList = new List<LabelValueItem>{
                new LabelValueItem(Label.PES_L_All_referring_statuses, null),
                new LabelValueItem(Label.PG_MPS_L_Failed_pre_eligibility_screening,
                        'AND Participant_Status__c=\'' + ParticipantEnrollmentService.PART_STATUS_FAILED_REFERRAL + '\' ' +
                                'AND Non_Referral_Reason__c=\'' + ParticipantEnrollmentService.NON_REF_REASON_STATUS_FAILED_PE_SCREENING + '\''),
                new LabelValueItem(Label.PG_MPS_L_Had_discussion_not_interested,
                        'AND Participant_Status__c=\'' + ParticipantEnrollmentService.PART_STATUS_FAILED_REFERRAL + '\' ' +
                                'AND Non_Referral_Reason__c=\'' + ParticipantEnrollmentService.NON_REF_REASON_STATUS_HAD_DISC_NOT_INTERESTED + '\''),
                new LabelValueItem(Label.PG_MPS_L_No_longer_interested,
                        'AND Participant_Status__c=\'' + ParticipantEnrollmentService.PART_STATUS_FAILED_REFERRAL + '\' ' +
                                'AND Non_Referral_Reason__c=\'' + ParticipantEnrollmentService.NON_REF_REASON_STATUS_NOT_INTERESTED + '\'')
        };
        return resList;
    }

}