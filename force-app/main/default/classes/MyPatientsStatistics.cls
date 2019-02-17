/**
 * Created by Leonid Bartenev
 */

public without sharing class MyPatientsStatistics {

    public Integer pendingReferral;
    
    public Integer onHold;
    public Integer inProgress;
    public Integer failed;
    public Integer enrolled;
    
    public Integer passedReferral;
    public Integer patientsOverall;
    
    public Integer failedReferral;
    public Integer failedPEScreening;
    public Integer noLongerInterested;
    public Integer hadDiscNotInterested;
    
    public Integer piPending;
    public Integer piAccepted;
    public Integer piOnHold;
    public Integer piDeclined;
    
    public List<SummaryContainer> subTotals = new List<SummaryContainer>();


    public static MyPatientsStatistics getStatistics(List<Id> trialIds, String mode){
        MyPatientsStatistics statistics = new MyPatientsStatistics();
        statistics.onHold = ParticipantEnrollmentService.getPEnrolmentsCount(trialIds, mode, PEStatusState.STATUSES_ON_HOLD);
        statistics.inProgress = ParticipantEnrollmentService.getPEnrolmentsCount(trialIds, mode, PEStatusState.STATUSES_IN_PROGRESS);
        statistics.enrolled = ParticipantEnrollmentService.getPEnrolmentsCount(trialIds, mode, PEStatusState.STATUSES_ENROLLED);
        statistics.failed = ParticipantEnrollmentService.getPEnrolmentsCount(trialIds, mode, PEStatusState.STATUSES_FAILED);
        statistics.passedReferral = statistics.onHold + statistics.inProgress + statistics.enrolled + statistics.failed;
    
        statistics.failedPEScreening = ParticipantEnrollmentService.getPEnrolmentsCount(trialIds, mode,
                ParticipantEnrollmentService.PART_STATUS_FAILED_REFERRAL,
                ParticipantEnrollmentService.NON_REF_REASON_STATUS_FAILED_PE_SCREENING
        );
    
        statistics.noLongerInterested = ParticipantEnrollmentService.getPEnrolmentsCount(trialIds, mode,
                ParticipantEnrollmentService.PART_STATUS_FAILED_REFERRAL,
                ParticipantEnrollmentService.NON_REF_REASON_STATUS_NOT_INTERESTED
        );
    
        statistics.hadDiscNotInterested = ParticipantEnrollmentService.getPEnrolmentsCount(trialIds, mode,
                ParticipantEnrollmentService.PART_STATUS_FAILED_REFERRAL,
                ParticipantEnrollmentService.NON_REF_REASON_STATUS_HAD_DISC_NOT_INTERESTED
        );
        statistics.failedReferral = statistics.noLongerInterested + statistics.hadDiscNotInterested + statistics.failedPEScreening;
        statistics.patientsOverall = statistics.passedReferral + statistics.failedReferral;
    
        statistics.pendingReferral = ParticipantEnrollmentService.getPEnrolmentsCount(trialIds, mode, new List<String>{
                ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL
        });
        
        if(mode == CommunityService.USER_MODE_HCP){
            statistics.pendingReferral = ParticipantEnrollmentService.getPEnrolmentsCount(trialIds, mode, new List<String>{
                    ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL
            });
    
            SummaryContainer total = new SummaryContainer(Label.PG_MPS_L_Patients_overall, statistics.patientsOverall + '');
            total.labelMaxWidth = '60px';
            SummaryContainer passedReferalsTotal = new SummaryContainer(Label.PG_MPS_L_Passed_referrals, statistics.passedReferral + '');
            passedReferalsTotal.items = new List<LabelValueItem>{
                    new LabelValueItem(Label.PG_MPS_L_Enrolled, statistics.enrolled + ''),
                    new LabelValueItem(Label.DI_L_In_progress, statistics.inProgress + ''),
                    new LabelValueItem(Label.DI_L_On_hold, statistics.onHold + ''),
                    new LabelValueItem(Label.DI_L_Failed_enrollment, statistics.failed + '')
            };

            SummaryContainer failedReferralsTotal = new SummaryContainer(Label.PG_MPS_L_Failed_referrals, statistics.failedReferral + '');
            failedReferralsTotal.items = new List<LabelValueItem>{
                    new LabelValueItem(Label.PG_MPS_L_Failed_pre_eligibility_screening, statistics.failedPEScreening + ''),
                    new LabelValueItem(Label.PG_MPS_L_Had_discussion_not_interested, statistics.hadDiscNotInterested + ''),
                    new LabelValueItem(Label.PG_MPS_L_No_longer_interested, statistics.noLongerInterested + '')
            };
            statistics.subTotals = new List<SummaryContainer>{
                    total,
                    passedReferalsTotal,
                    failedReferralsTotal 
            };
        }else if(mode == CommunityService.USER_MODE_PI){
            statistics.piPending = ParticipantEnrollmentService.getPEnrolmentsCount(trialIds, mode, new List<String>{
                    PEStatusState.STATUS_STEPS_TABLE[0].states.get(PEStatusState.STATUS_STATE_SUCCESS)
            });
    
            statistics.piAccepted = ParticipantEnrollmentService.getPEnrolmentsCount(trialIds, mode, new List<String>{
                    PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_SUCCESS)
            });
    
            statistics.piOnHold = ParticipantEnrollmentService.getPEnrolmentsCount(trialIds, mode, new List<String>{
                    PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_IN_PROGRESS)
            });
    
            statistics.piDeclined = ParticipantEnrollmentService.getPEnrolmentsCount(trialIds, mode, new List<String>{
                    PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_FAILURE)
            });
    
            SummaryContainer referralsOverall = new SummaryContainer(Label.PG_MPS_L_Referrals_overall,
                    statistics.piAccepted + statistics.piDeclined + statistics.piOnHold + statistics.piPending + ''
            );
            referralsOverall.items = new List<LabelValueItem>{
                    new LabelValueItem(Label.DI_L_Accepted, statistics.piAccepted + ''),
                    new LabelValueItem(Label.PG_MRR_L_Pending, statistics.piPending + ''),
                    new LabelValueItem(Label.DI_L_On_hold, statistics.piOnHold + ''),
                    new LabelValueItem(Label.DI_L_Declined, statistics.piDeclined + '')
            };
            SummaryContainer referralsAccepted = new SummaryContainer(Label.PG_MPS_L_Referrals_accepted, statistics.passedReferral + '');
            referralsAccepted.items = new List<LabelValueItem>{
                    new LabelValueItem(Label.PG_MPS_L_Enrolled, statistics.enrolled + ''),
                    new LabelValueItem(Label.DI_L_In_progress, statistics.inProgress + ''),
                    new LabelValueItem(Label.DI_L_On_hold, statistics.onHold + ''),
                    new LabelValueItem(Label.DI_L_Failed_enrollment, statistics.failed + '')
            };
            
            statistics.subTotals = new List<SummaryContainer>{
                    referralsOverall,
                    referralsAccepted
            };
        }
        return statistics;
    }
    

}