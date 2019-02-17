/**
 * Created by Leonid Bartenev
 */

public class DashboardRemote {
    
    class PIData{
        Integer waitingAcceptence;
        List<ListItem> waitingAcceptenceList;
        List<DonutItem> referralsReceived = new List<DonutItem>();
        
        Integer waitingToBeContacted;
        List<ListItem> waitingToBeContactedList;
        List<DonutItem> referralsApproved = new List<DonutItem>();
        
        Integer physiciansWaitingForApproval;
        List<ListItem> physiciansWaitingForApprovalList;
        List<DonutItem> siteRequests = new List<DonutItem>();
    }
    
    class HCPData{
        Integer waitingToBeReferred;
        List<ListItem> waitingToBeReferredList;
        List<DonutItem> referringStatus = new List<DonutItem>();
        List<DonutItem> acceptenceStatus = new List<DonutItem>();
        List<DonutItem> enrollmentStatus = new List<DonutItem>();
    }
    
    class ListItem{
        Object data;
        Map<String, StudyActions.Action> actions;
        StudyActions.Action action;

        ListItem(Object data, Map<String, StudyActions.Action> actions){
            this.data = data;
            this.actions = actions;
        }

        ListItem(Object data, StudyActions.Action action){
            this.data = data;
            this.action = action;
        }
    }
    
    @AuraEnabled
    public static String getInitData(String userMode){
        try{
            if(userMode == CommunityService.USER_MODE_PI){
                PIData piData = new PIData();
                // acceptance data
                piData.waitingAcceptenceList = preparePEList(
                        ParticipantEnrollmentService.getPEnrolmentsByStatus(userMode, new List<String>{
                                ParticipantEnrollmentService.PART_STATUS_REFERRAL_SENT_TO_PI
                        }, 3), userMode
                );
                Integer piPending = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[0].states.get(PEStatusState.STATUS_STATE_SUCCESS));
                Integer piAccepted = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_SUCCESS));
                Integer piOnHold = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_IN_PROGRESS));
                Integer piDeclined = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_FAILURE));
                piData.waitingAcceptence = piPending;
                piData.referralsReceived.addAll(new List<DonutItem>{
                        new DonutItem(Label.DI_L_Accepted, piAccepted , DonutItem.Type.SUCCSESS),
                        new DonutItem(Label.DI_L_On_hold, piOnHold , DonutItem.Type.ON_HOLD),
                        new DonutItem(Label.DI_L_Declined, piDeclined , DonutItem.Type.DECLINED),
                        new DonutItem(Label.DI_L_Acceptance_pending, piPending , DonutItem.Type.PENDING)
                });
        
                //contact attemts data
                piData.waitingToBeContactedList = preparePEList(
                        ParticipantEnrollmentService.getPEnrolmentsByStatus(userMode, new List<String>{
                                PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_SUCCESS)
                        }, 3), userMode
                );
                Integer piPendingContacted = piAccepted;
                Integer piSuccessContacted = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[2].states.get(PEStatusState.STATUS_STATE_SUCCESS));
                Integer piOnHoldContacted = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[2].states.get(PEStatusState.STATUS_STATE_IN_PROGRESS));
                Integer piDeclineContacted = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[2].states.get(PEStatusState.STATUS_STATE_FAILURE));
                piData.waitingToBeContacted = piPendingContacted;
                piData.referralsApproved.addAll(new List<DonutItem>{
                        new DonutItem(Label.DI_L_Accepted, piSuccessContacted , DonutItem.Type.SUCCSESS),
                        new DonutItem(Label.DI_L_On_hold, piOnHoldContacted , DonutItem.Type.ON_HOLD),
                        new DonutItem(Label.DI_L_Declined, piDeclineContacted , DonutItem.Type.DECLINED),
                        new DonutItem(Label.DI_L_Not_yet_contacted, piPendingContacted , DonutItem.Type.PENDING)
                });
        
                //referring clinics data
                piData.physiciansWaitingForApprovalList = prepareHCPEList(
                        HCPEnrollmentService.getHCPEnrollmentsForPI(HCPEnrollmentService.STATUS_GROUP_PENDING, 3), userMode
                );
                Integer phPending = HCPEnrollmentService.getHCPEnrollmentsCountForPI(HCPEnrollmentService.STATUS_GROUP_PENDING);
                Integer phDeclined = HCPEnrollmentService.getHCPEnrollmentsCountForPI(HCPEnrollmentService.STATUS_GROUP_DECLINED);
                Integer phActivated = HCPEnrollmentService.getHCPEnrollmentsCountForPI(HCPEnrollmentService.STATUS_GROUP_ACTIVATED);
                Integer phOnHold = HCPEnrollmentService.getHCPEnrollmentsCountForPI(HCPEnrollmentService.STATUS_GROUP_ON_HOLD);
                piData.physiciansWaitingForApproval = phPending;
                piData.siteRequests.addAll(new List<DonutItem>{
                        new DonutItem(Label.DI_L_Activated, phActivated , DonutItem.Type.SUCCSESS),
                        new DonutItem(Label.DI_L_On_hold, phOnHold , DonutItem.Type.ON_HOLD),
                        new DonutItem(Label.DI_L_Declined, phDeclined , DonutItem.Type.DECLINED),
                        new DonutItem(Label.DI_L_Pending_approval_activation, phPending , DonutItem.Type.PENDING)
                });
        
                return JSON.serialize(piData);
    
            }else if(userMode == CommunityService.USER_MODE_HCP){
                HCPData hcpData = new HCPData();
                hcpData.waitingToBeReferred = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL);
                hcpData.waitingToBeReferredList = preparePEList(
                        ParticipantEnrollmentService.getPEnrolmentsByStatus(userMode, new List<String>{
                                ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL
                        }, 3), userMode
                );
                //Referring status:
                Integer passedReviewAndReffered = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, new List<String>(PEStatusState.ALL_USED_STATUSES));
                Integer passedReviewNotYetReferred = hcpData.waitingToBeReferred;
                Integer failedReview = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, ParticipantEnrollmentService.PART_STATUS_FAILED_REVIEW);
                hcpData.referringStatus.addAll(new List<DonutItem>{
                        new DonutItem(Label.DI_L_Passed_review_and_referred, passedReviewAndReffered , DonutItem.Type.SUCCSESS),
                        new DonutItem(Label.DI_L_Passed_review_and_not_yet_referred, passedReviewNotYetReferred , DonutItem.Type.ON_HOLD),
                        new DonutItem(Label.DI_L_Failed_review, failedReview , DonutItem.Type.DECLINED)
                });
        
                //Acceptance statuses
                Integer piPending = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[0].states.get(PEStatusState.STATUS_STATE_SUCCESS));
                Integer piAccepted = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_SUCCESS));
                Integer piOnHold = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_IN_PROGRESS));
                Integer piDeclined = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_FAILURE));
                hcpData.acceptenceStatus.addAll(new List<DonutItem>{
                        new DonutItem(Label.DI_L_Accepted, piAccepted , DonutItem.Type.SUCCSESS),
                        new DonutItem(Label.DI_L_On_hold, piOnHold , DonutItem.Type.ON_HOLD),
                        new DonutItem(Label.DI_L_Declined, piDeclined , DonutItem.Type.DECLINED),
                        new DonutItem(Label.DI_L_Approval_pending, piPending , DonutItem.Type.PENDING)
                });
        
                //Enrollment status
                Integer enrolledRandomized = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUSES_ENROLLED);
                Integer inProgress = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUSES_IN_PROGRESS);
                Integer declined = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUSES_FAILED);
                hcpData.enrollmentStatus.addAll(new List<DonutItem>{
                        new DonutItem(Label.DI_L_Enrolled_randomized, enrolledRandomized , DonutItem.Type.SUCCSESS),
                        new DonutItem(Label.DI_L_In_progress, inProgress , DonutItem.Type.ON_HOLD),
                        new DonutItem(Label.DI_L_Failed_enrollment, declined , DonutItem.Type.DECLINED)
                });
        
                return JSON.serialize(hcpData);
            }
            return null;
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static String acceptPE(Id peId){
        Participant_Enrollment__c pe  = new Participant_Enrollment__c(
                Id = peId,
                Participant_Status_Last_Changed_Date__c = Datetime.now(),
                Participant_Status__c = PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_SUCCESS)
        );
        upsert pe;
        return getInitData(CommunityService.USER_MODE_PI);
    }
    
    private static List<ListItem> prepareHCPEList(List<HCP_Enrollment__c> hcpeList, String userMode){
        List<ListItem> resList = new List<ListItem>();
        for(HCP_Enrollment__c hcpe : hcpeList){
            Map<String, StudyActions.Action> actions = new StudyActionsPI(hcpe).actions;
            Set<String> actionIds = HCPEnrollmentService.HCP_CHANGE_STATUS_MAP.get(hcpe.Status__c).keySet();
            for(String actionId : actionIds){
                StudyActions.Action action = actions.get(actionId);
                if(action.cssClass == 'green'){
                    resList.add(new ListItem(hcpe, action));
                    break;
                }
            }
        }
        return resList;
    }
    
    private static List<ListItem> preparePEList(List<Participant_Enrollment__c> peList, String userMode){
        List<ListItem> resList = new List<ListItem>();
        for(Participant_Enrollment__c pe : peList){
            StudyActions studyActions;
            if(userMode == CommunityService.USER_MODE_HCP) {
                studyActions = new StudyActionsHCP(pe);
            }else{
                studyActions = new StudyActionsPI(pe);
            }
            resList.add(new ListItem(pe, studyActions.actions));
        }
        return resList;
    }

}