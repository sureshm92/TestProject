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

        List<BarItem> waitingTimeToContact = new List<BarItem>();

        Integer participantsWaitingContact;
        List<WaitingContactItem> awaitingToContact = new List<WaitingContactItem>();
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

    private static String LEESS_5_DAYS = '<5 Days';
    private static String FROM_6_TO_10_DAYS = '6-10 Days';
    private static String FROM_11_TO_15_DAYS = '11-15 Days';
    private static String FROM_16_TO_20_DAYS = '16-20 Days';
    private static String GREATER_20_DAYS = '>20 Days';

    class BarItem {
        String color;
        String width;
        String title;
        String count;

        BarItem(String color, String width, String title, String count) {
            this.color = color;
            this.width = width;
            this.title = title;
            this.count = count;
        }
    }

    class WaitingContactItem {
        String Id;
        String name;
        String source;
        String studyName;
        String studyId;
        Integer daysAdded;

        WaitingContactItem(String Id, String name, String source, String studyName, String studyId, Integer daysAdded) {
            this.Id = Id;
            this.name = name;
            this.source = source;
            this.studyName = studyName;
            this.studyId = studyId;
            this.daysAdded = daysAdded;
        }
    }
    //TODO Review
    @AuraEnabled
    public static String getInitData(String userMode, String delegateId){
        try{
            if(userMode == CommunityService.USER_MODE_PI){
                PIData piData = new PIData();
                // acceptance data
                piData.waitingAcceptenceList = preparePEList(
                        ParticipantEnrollmentService.getPEnrolmentsByStatus(userMode, new List<String>{
                                ParticipantEnrollmentService.PART_STATUS_REFERRAL_SENT_TO_PI
                        }, 3), userMode,
                        delegateId
                );
//                Integer piPending = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[0].states.get(PEStatusState.STATUS_STATE_SUCCESS));
                Integer piAccepted = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[0].states.get(PEStatusState.STATUS_STATE_SUCCESS));
//                Integer piOnHold = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_IN_PROGRESS));
//                Integer piDeclined = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_FAILURE));
                piData.waitingAcceptence =0;// piPending;
                piData.referralsReceived.addAll(new List<DonutItem>{
                        new DonutItem(Label.DI_L_Accepted, piAccepted , DonutItem.Type.SUCCSESS)/*,
                        new DonutItem(Label.DI_L_On_hold, piOnHold , DonutItem.Type.ON_HOLD),
                        new DonutItem(Label.DI_L_Declined, piDeclined , DonutItem.Type.DECLINED),
                        new DonutItem(Label.DI_L_Acceptance_pending, piPending , DonutItem.Type.PENDING)*/
                });
        
                //contact attemts data
                piData.waitingToBeContactedList = preparePEList(
                        ParticipantEnrollmentService.getPEnrolmentsByStatus(userMode, PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_IN_PROGRESS), 3), userMode,
                        delegateId
                );
                Integer piPendingContacted = piAccepted;
                Integer piSuccessContacted = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_SUCCESS));
                Integer piOnHoldContacted = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_IN_PROGRESS));
                Integer piDeclineContacted = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_FAILURE));
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

                // waiting contact in days
                piData.waitingTimeToContact = prepareWaitingList(userMode, delegateId);

                // awaiting contact
                piData.awaitingToContact = prepareAwaitingContactList(userMode, delegateId);
                piData.participantsWaitingContact = piData.awaitingToContact.size();

                return JSON.serialize(piData);
    
            }else if(userMode == CommunityService.USER_MODE_HCP){
                HCPData hcpData = new HCPData();
                hcpData.waitingToBeReferred = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL, delegateId);
                hcpData.waitingToBeReferredList = preparePEList(
                        ParticipantEnrollmentService.getPEnrolmentsByStatus(userMode, new List<String>{
                                ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL
                        }, 3, delegateId), userMode,
                        delegateId
                );
                //Referring status:
                Integer passedReviewAndReffered = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, new List<String>(PEStatusState.ALL_USED_STATUSES), delegateId);
                Integer passedReviewNotYetReferred = hcpData.waitingToBeReferred;
                Integer failedReview = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, ParticipantEnrollmentService.PART_STATUS_FAILED_REVIEW, delegateId);
                hcpData.referringStatus.addAll(new List<DonutItem>{
                        new DonutItem(Label.DI_L_Passed_review_and_referred, passedReviewAndReffered , DonutItem.Type.SUCCSESS),
                        new DonutItem(Label.DI_L_Passed_review_and_not_yet_referred, passedReviewNotYetReferred , DonutItem.Type.ON_HOLD),
                        new DonutItem(Label.DI_L_Failed_review, failedReview , DonutItem.Type.DECLINED)
                });
        
                //Acceptance statuses
//                Integer piPending = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[0].states.get(PEStatusState.STATUS_STATE_SUCCESS), delegateId);
                Integer piAccepted = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[0].states.get(PEStatusState.STATUS_STATE_SUCCESS), delegateId);
//                Integer piOnHold = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_IN_PROGRESS), delegateId);
//                Integer piDeclined = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_FAILURE), delegateId);
                hcpData.acceptenceStatus.addAll(new List<DonutItem>{
                        new DonutItem(Label.DI_L_Accepted, piAccepted , DonutItem.Type.SUCCSESS)/*,
                        new DonutItem(Label.DI_L_On_hold, piOnHold , DonutItem.Type.ON_HOLD),
                        new DonutItem(Label.DI_L_Declined, piDeclined , DonutItem.Type.DECLINED),
                        new DonutItem(Label.DI_L_Approval_pending, piPending , DonutItem.Type.PENDING)*/
                });
        
                //Enrollment status
                Integer enrolledRandomized = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUSES_ENROLLED, delegateId);
                Integer inProgress = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUSES_IN_PROGRESS, delegateId);
                Integer declined = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUSES_FAILED, delegateId);
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
                Participant_Status__c = PEStatusState.STATUS_STEPS_TABLE[0].states.get(PEStatusState.STATUS_STATE_SUCCESS)[0]
        );
        upsert pe;
        return getInitData(CommunityService.USER_MODE_PI, null);
    }

    @AuraEnabled
    public static String getParticipantData(String userMode, String delegateId, String participantId){
        System.debug('participantId => ' + participantId);
        ViewPatientsRemote.InitData initData = new ViewPatientsRemote.InitData();
        initData.peStatusStateMap = PEStatusState.STATUSES_MAP;
        initData.peStatusesPathList = PEStatusState.STATUS_STEPS_LIST;

        List<Participant_Enrollment__c> pes =
                ParticipantEnrollmentService.getPEnrolmentsByStatus(
                        userMode,
                        new List<String>{ PEStatusState.PE_STATUS_CONTACT_ATTEMPTED },
                        null,
                        delegateId);
        for (Participant_Enrollment__c pe : pes) {
            if (pe.Participant__c == participantId) {
                initData.currentPageList = new List<ViewPatientsRemote.PEWrapper> { new ViewPatientsRemote.PEWrapper(pe, new StudyActionsPI(pe).actions) };
            }
        }

        return JSON.serialize(initData);
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
        return preparePEList(peList, userMode, null);
    }

    private static List<ListItem> preparePEList(List<Participant_Enrollment__c> peList, String userMode, String delegateId){
        List<ListItem> resList = new List<ListItem>();
        for(Participant_Enrollment__c pe : peList){
            StudyActions studyActions;
            if(userMode == CommunityService.USER_MODE_HCP) {
                studyActions = new StudyActionsHCP(pe, delegateId);
            }else{
                studyActions = new StudyActionsPI(pe);
            }
            resList.add(new ListItem(pe, studyActions.actions));
        }
        return resList;
    }

    private static List<BarItem> prepareWaitingList(String userMode, String delegateId) {
        List<BarItem> resList = new List<BarItem>();

        /*List<Participant_Enrollment__c> pes =
                ParticipantEnrollmentService.getPEnrolmentsByStatus(
                        userMode,
                        new List<String>{ PEStatusState.PE_STATUS_RECEIVED },
                        null,
                        delegateId);
        Map<Id, Participant_Enrollment__c> peById = new Map<Id, Participant_Enrollment__c>(pes);*/

        List<Participant_Enrollment_Status_History__c> peSHs =
            [SELECT Id,
                    CreatedDate,
                    Date__c,
                    ParticipantEnrollment__c,
                    Status__c
             FROM Participant_Enrollment_Status_History__c
             WHERE ParticipantEnrollment__c IN (SELECT Id
                                                FROM Participant_Enrollment__c
                                                WHERE Study_Site__r.Principal_Investigator__c = :delegateId) AND
                   Status__c IN :(new List<String>{ PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED,
                                                    PEStatusState.PE_STATUS_RECEIVED })
             ORDER BY CreatedDate DESC];
        Map<Id, Participant_Enrollment_Status_History__c> receivedPESHsByPIId = new Map<Id, Participant_Enrollment_Status_History__c>();
        Map<Id, Participant_Enrollment_Status_History__c> contactedPESHsByPIId = new Map<Id, Participant_Enrollment_Status_History__c>();
        for (Participant_Enrollment_Status_History__c peSH : peSHs) {
            if (peSH.Status__c == PEStatusState.PE_STATUS_RECEIVED) {
                receivedPESHsByPIId.put(peSH.ParticipantEnrollment__c, peSH);
            } else {
                contactedPESHsByPIId.put(peSH.ParticipantEnrollment__c, peSH);
            }
        }

        Integer maxParticipantsInDays = 0;
        String daysMaxParticipantsInDays = null;
        Set<Id> peIdsProcessed = new Set<Id>();
        Map<String, List<Participant_Enrollment_Status_History__c>> peSHByDays = new Map<String, List<Participant_Enrollment_Status_History__c>> {
                LEESS_5_DAYS => new List<Participant_Enrollment_Status_History__c>(),
                FROM_6_TO_10_DAYS => new List<Participant_Enrollment_Status_History__c>(),
                FROM_11_TO_15_DAYS => new List<Participant_Enrollment_Status_History__c>(),
                FROM_16_TO_20_DAYS => new List<Participant_Enrollment_Status_History__c>(),
                GREATER_20_DAYS => new List<Participant_Enrollment_Status_History__c>()
        };
        for (Participant_Enrollment_Status_History__c peSH : receivedPESHsByPIId.values()) {
            if (!peIdsProcessed.contains(peSH.ParticipantEnrollment__c)) {
                Participant_Enrollment_Status_History__c contactedPESH = contactedPESHsByPIId.get(peSH.ParticipantEnrollment__c);

                if (contactedPESH != null) {
                    Integer daysBetween;
                    if (peSH.Date__c != null && contactedPESH.Date__c != null) {
                        daysBetween = contactedPESH.Date__c.date().daysBetween(peSH.Date__c.date());
                    } else {
                        daysBetween = contactedPESH.CreatedDate.date().daysBetween(peSH.CreatedDate.date());
                    }
                    String days = null;
                    if (5 >= daysBetween) {
                        days = LEESS_5_DAYS;
                    } else if (daysBetween >= 6 && daysBetween <= 10) {
                        days = FROM_6_TO_10_DAYS;
                    } else if (daysBetween >= 11 && daysBetween <= 15) {
                        days = FROM_11_TO_15_DAYS;
                    } else if (daysBetween >= 16 && daysBetween <= 20) {
                        days = FROM_16_TO_20_DAYS;
                    } else if (daysBetween > 20) {
                        days = GREATER_20_DAYS;
                    }

                    List<Participant_Enrollment_Status_History__c> peSHDay = peSHByDays.get(days);
                    if (peSHDay != null) {
                        peSHDay.add(peSH);
                        if (maxParticipantsInDays < peSHDay.size()) {
                            maxParticipantsInDays = peSHDay.size();
                            daysMaxParticipantsInDays = days;
                        }
                    }
                }
            }
        }

        // 70% width is maxParticipantsInDays
        resList.add(prepareBarItem('#D8EBF7', LEESS_5_DAYS, peSHByDays.get(LEESS_5_DAYS).size(), maxParticipantsInDays, daysMaxParticipantsInDays));
        resList.add(prepareBarItem('#B8DDF6', FROM_6_TO_10_DAYS, peSHByDays.get(FROM_6_TO_10_DAYS).size(), maxParticipantsInDays, daysMaxParticipantsInDays));
        resList.add(prepareBarItem('#83C7F4', FROM_11_TO_15_DAYS, peSHByDays.get(FROM_11_TO_15_DAYS).size(), maxParticipantsInDays, daysMaxParticipantsInDays));
        resList.add(prepareBarItem('#3D9BD9', FROM_16_TO_20_DAYS, peSHByDays.get(FROM_16_TO_20_DAYS).size(), maxParticipantsInDays, daysMaxParticipantsInDays));
        resList.add(prepareBarItem('#136BA6', GREATER_20_DAYS, peSHByDays.get(GREATER_20_DAYS).size(), maxParticipantsInDays, daysMaxParticipantsInDays));

        return resList;
    }

    private static BarItem prepareBarItem(String color, String title, Integer count, Integer maxPInD, String maxD) {
        String width = title == maxD ? '70%' : count != 0 ? '' + Math.Round(70 / Math.Round(maxPInD / count)) + '%' : '1%';
        return new BarItem(color, width, title, '' + count);
    }

    private static List<WaitingContactItem> prepareAwaitingContactList(String userMode, String delegateId) {
        List<WaitingContactItem> resList = new List<WaitingContactItem>();

        List<Participant_Enrollment__c> pes =
                ParticipantEnrollmentService.getPEnrolmentsByStatus(
                        userMode,
                        new List<String>{ PEStatusState.PE_STATUS_CONTACT_ATTEMPTED },
                        null,
                        delegateId);
        for (Participant_Enrollment__c pe : pes) {
            Integer daysAdded = pe.CreatedDate.date().daysBetween(System.today());
            resList.add(new WaitingContactItem(pe.Participant__c, pe.Participant__r.First_Name__c + ' ' + pe.Participant__r.Last_Name__c, pe.Source_Type__c, pe.Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c, pe.Study_Site__r.Clinical_Trial_Profile__c, daysAdded));
        }

        return resList;
    }
}