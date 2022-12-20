public without sharing class DashboardRemoteNew {
    public static final String INITIAL_VISIT_SCHEDULED = 'Initial Visit Scheduled';
    public static final String ELIGIBILITY_PASSED = 'Eligibility Passed';
    public static final String PE_STATUS_ELIGIBILITY_FAILED = 'Eligibility Failed';
    public static final String UNABLE_TO_REACH = 'Unable to Reach';
    public static final String PRE_REVIEW_PASSED = 'Pre-review Passed';
    public static final String PRE_REVIEW_FAILED = 'Pre-review Failed';
    public static final String PE_STATUS_SUCCESSFULLY_CONTACTED = 'Successfully Contacted';
    public static final String STATUS_SCREENING_PASSED = 'Screening Passed';
    public static final String PE_STATUS_SCREENING_PASSED_WASH_OUT_PERIOD = 'Screening Passed - Wash Out Period';
    public static final String STATUS_IN_WASH_OUT_PERIOD = 'In Wash Out Period';
    public static final String STATUS_SCREENING_IN_PROGRESS_WASH_OUT = 'Screening In Progress - Wash Out Period';
    public static final String PE_STATUS_SCREENING_FAILED = 'Screening Failed';
    public static final String STATUS_ENROLLMENT_SUCCESS = 'Enrollment Success';
    public static final String STATUS_RANDOMIZATION_SUCCESS = 'Randomization Success';
    public static final String PE_STATUS_ENROLLED = 'Enrolled';
    public static final String PE_STATUS_RANDOMIZED = 'Randomized';
    public static final String PARTICIPANT_WORKFLOW_FINAL_STEP_ENROLLMENT = 'Enrollment';
    public static final String PARTICIPANT_WORKFLOW_FINAL_STEP_RANDOMIZATION = 'Randomization';
    public static final String STATUS_CONTACTED_NOT_SUITABLE = 'Contacted - Not Suitable';
    public static final String STATUS_RECEIVED = 'Received';
    public static final String STATUS_REFERRAL_ACCEPTED = 'Referral Accepted';
    public static final String STATUS_REFERRAL_ON_HOLD = 'Referral On Hold';
    public static final String STATUS_REFERRAL_DECLINED = 'Referral Declined';
    public static final String STATUS_CONTACT_ATTEMPTED = 'Contact Attempted';
    public static final String STATUS_SCREENING_IN_PROGRESS = 'Screening In Progress';
    public static final String STATUS_UNABLE_TO_SCREEN = 'Unable to Screen';
    public static final String STATUS_ENROLLMENT_FAILED = 'Enrollment Failed';
    public static final String STATUS_RANDOMIZATION_FAILED = 'Randomization Failed';
    public static final String STATUS_TREATMENT_PERIOD_STARTED = 'Treatment Period Started';
    public static final String STATUS_FOLLOW_UP_PERIOD_STARTED = 'Follow-Up Period Started';
    public static final String STATUS_PARTICIPATION_COMPLETE = 'Participation Complete';
    public static final String STATUS_TRIAL_COMPLETE = 'Trial Complete';
    public static final String STATUS_DROP_OUT = 'Drop Out';
    public static final String STATUS_DECEASED = 'Deceased';
    public static final String STATUS_READY_TO_SCREEN = 'Ready to Screen';
    public static final String STATUS_DECLINED_FINAL_CONSENT = 'Declined Final Consent';
    public static final String STATUS_DECLINED_CONSENT = 'Declined Consent';
    public static final String STATUS_WITHDREW_CONSENT = 'Withdrew Consent';
    public static final String STATUS_WITHDREW_CONSENT_AFTER_SCREENING = 'Withdrew Consent After Screening';
    public static final String STATUS_PARTICIPANT_NO_SHOW = 'Participant No Show';
    public static final String STATUS_RE_ENGAGED = 'Successfully re-engaged';

    class PIData {
        List<LabelValueItem> delegatePIsPicklist = new List<LabelValueItem>();
        List<LabelValueItem> piCTPPicklist = new List<LabelValueItem>();
        List<CTPPPEnable> piCTPPPEnablelist = new List<CTPPPEnable>();//RH-5163
        Id selectedCTP;
        Id selectedPi;
        Integer currentStudySitesCount = 10;
        Integer totalPrepareAwaitingContactCount = 0;
        Integer totalTimeWaitingContactCount = 0;
        Integer participantScheduledCount = 0;
    }

    class CTPPPEnable {//RH-5163
        String label;
        String value;
        Boolean ppEnabled;
    }

    class HCPData {
        Integer waitingToBeReferred;
        List<ListItem> waitingToBeReferredList;
        List<DonutItem> referringStatus = new List<DonutItem>();
        List<DonutItem> acceptenceStatus = new List<DonutItem>();
        List<DonutItem> enrollmentStatus = new List<DonutItem>();
    }

    class ListItem {
        Object data;
        Map<String, StudyActions.Action> actions;
        StudyActions.Action action;
        String hcpName;

        ListItem(Object data, Map<String, StudyActions.Action> actions) {
            this.data = data;
            this.actions = actions;
        }
        ListItem(Object data, Map<String, StudyActions.Action> actions, String hcpName) {
            this.data = data;
            this.actions = actions;
            this.hcpName = hcpName;
        }
        ListItem(Object data, StudyActions.Action action) {
            this.data = data;
            this.action = action;
        }
        ListItem(Object data, StudyActions.Action action, String hcpName) {
            this.data = data;
            this.action = action;
            this.hcpName = hcpName;
        }
    }

    public class WaitingContactItem implements Comparable {
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String strPerName;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String source;
        @AuraEnabled
        public String studyName;
        @AuraEnabled
        public String studyId;
        @AuraEnabled
        public Integer daysAdded;
        @AuraEnabled
        public Boolean isAbleToEdit;
        @AuraEnabled
        public String StudySiteName;
        @AuraEnabled
        public Boolean isReEngagePar;
            
        public WaitingContactItem(
            String Id,
            String strPerName,
            String name,
            String source,
            String studyName,
            String studyId,
            Integer daysAdded,
            Boolean isAbleToEdit,
            String StudySiteName,
            Boolean isReEngagePar
        ) {
            this.Id = Id;
            this.strPerName = strPerName;
            this.name = name;
            this.source = source;
            this.studyName = studyName;
            this.studyId = studyId;
            this.daysAdded = daysAdded;
            this.isAbleToEdit = isAbleToEdit;
            this.StudySiteName = StudySiteName;
            this.isReEngagePar = isReEngagePar;
        }

        public Integer compareTo(Object compareTo) {
            WaitingContactItem wci = (WaitingContactItem) compareTo;
            if (daysAdded == wci.daysAdded)
                return 0;
            else if (daysAdded > wci.daysAdded)
                return -1;
            return 1;
        }
    }

    public class FunnelData {
        @AuraEnabled
        public String statusLabel;
        @AuraEnabled
        public Integer peInStatus;
        @AuraEnabled
        public String funnelColor;

        public FunnelData(String statusLabel, Integer peInStatus, String funnelColor) {
            this.statusLabel = statusLabel;
            this.peInStatus = peInStatus;
            this.funnelColor = funnelColor;
        }
    }
    
    private static String LEESS_5_DAYS = Label.DBPI_Days_Less_5;
    private static String FROM_6_TO_10_DAYS = Label.DBPI_Days_6_To_10;
    private static String FROM_11_TO_15_DAYS = Label.DBPI_Days_11_To_15;
    private static String FROM_16_TO_20_DAYS  = Label.DBPI_Days_16_To_20;
    private static String GREATER_20_DAYS = Label.DBPI_Days_Greater_20;

    private static Map<String, String> BarTitleLabelsMap = new Map<String, String>{
        LEESS_5_DAYS => 'PG_DBPI_Days_Less_5',
        FROM_6_TO_10_DAYS => 'PG_DBPI_Days_6_To_10',
        FROM_11_TO_15_DAYS => 'PG_DBPI_Days_11_To_15',
        FROM_16_TO_20_DAYS => 'PG_DBPI_Days_16_To_20',
        GREATER_20_DAYS => 'PG_DBPI_Days_Greater_20'
    };

    public class BarItem {
        @AuraEnabled
        public String color;
        @AuraEnabled
        public String width;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String count;

        public BarItem(String color, String width, String title, String count) {
            this.color = color;
            this.width = width;
            this.title = title;
            this.count = count;
        }
    }

    public class SSRankWrapper implements Comparable {
        @AuraEnabled
        public Integer rank;
        @AuraEnabled
        public String site_Number;
        @AuraEnabled
        public String site_Name;
        @AuraEnabled
        public String location;
        @AuraEnabled
        public Integer initial_Visits_Completed;
        @AuraEnabled
        public Integer contacted;
        @AuraEnabled
        public Integer scheduled;
        @AuraEnabled
        public Integer screened;
        @AuraEnabled
        public Integer enrolled_randomized;
        @AuraEnabled
        public String is_enrolled_randomized;
        @AuraEnabled
        public String piName;
        @AuraEnabled
        public String pi_Id;
        @AuraEnabled
        public String studyName;

        //SSRankWrapper Constructor
        public SSRankWrapper(
            String site_Number,
            String site_Name,
            String location,
            Integer initial_Visits_Completed,
            Integer contacted,
            Integer scheduled,
            Integer screened,
            Integer enrolled_randomized,
            String is_enrolled_randomized,
            String piName,
            Id pi_Id,
            String studyName
        ) {
            this.site_Number = site_Number;
            this.site_Name = site_Name;
            this.location = location;
            this.initial_Visits_Completed = initial_Visits_Completed;
            this.contacted = contacted;
            this.scheduled = scheduled;
            this.screened = screened;
            this.enrolled_randomized = enrolled_randomized;
            this.is_enrolled_randomized = is_enrolled_randomized;
            this.piName = piName;
            this.pi_Id = pi_Id;
            this.studyName = studyName;
        }

        public Integer compareTo(Object obj) {
            SSRankWrapper ssSiteRank = (SSRankWrapper) obj;
            if (this.initial_Visits_Completed < ssSiteRank.initial_Visits_Completed)
                return 1;
            else if (this.initial_Visits_Completed == ssSiteRank.initial_Visits_Completed)
                return 0;
            return -1;
        }
    }
 
    @AuraEnabled
    public static String getInitData(
        String userMode,
        String communityName,
        String delegateId,
        Id piId,
        Id ctpId,
        String action
    ) {
        try {
            System.debug(
                'userMode---> :' +
                userMode +
                ' delegateId---> : ' +
                delegateId +
                ' piId----> : ' +
                piId +
                ' ctpId---> : ' +
                ctpId
            );
            if (userMode == CommunityService.USER_MODE_PI) {
                List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
                Set<Id> delegateSSIds = new Set<Id>();
                Contact currentContact = CommunityService.getUserContact();
                Id currentContactId = currentContact.Id;
                String currentContactName =
                    currentContact.FirstName +
                    ' ' +
                    currentContact.LastName;
                Map<Id, String> delegatePIsMap = new Map<Id, String>();
                PIData piData = new PIData();
                List<String> communityNames = new List<String>(); 
                if(communityName  == CommunityTemplateService.TEMPLATE_DEFAULT){
                    communityNames.add(CommunityTemplateService.TEMPLATE_GSK);
                }
                communityNames.add(communityName);
                if (
                    ![
                            SELECT Id
                            FROM Study_Site__c
                            WHERE Principal_Investigator__c = :currentContactId  AND Clinical_Trial_Profile__r.CommunityTemplate__c IN :communityNames
                        ]
                        .isEmpty()
                ) {
                    delegatePIsMap.put(currentContactId,'Self' );
                    if (piId == null) {
                        piData.selectedPi = currentContactId;
                        piId = currentContactId;
                    }
                }
                Set<Id> sStaffPIIds = new Set<Id>();
                for (Site_Staff__c sStaff : [
                    SELECT
                        Id,
                        Study_Site__r.Principal_Investigator__c,
                        Study_Site__r.Principal_Investigator__r.Name,
                        Study_Site__c,
                        is_Invited__c
                    FROM Site_Staff__c
                    WHERE Site_Contact__c = :currentContactId AND is_Invited__c = TRUE AND Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c IN :communityNames
                ]) {
                    delegatePIsMap.put(
                        sStaff.Study_Site__r.Principal_Investigator__c,
                        sStaff.Study_Site__r.Principal_Investigator__r.Name
                    );
                    sStaffPIIds.add(sStaff.Study_Site__r.Principal_Investigator__c);
                    delegateSSIds.add(sStaff.Study_Site__c);
                }
                delegatePIsMap.putAll(ParticipantWorkflowService.getPIContactNames(sStaffPIIds));
                Id pi_Id;
                if (action == 'Init') {
                    if (!delegatePIsMap.isEmpty()) {
                        pi_Id = new List<Id>(delegatePIsMap.keySet())[0];
                    } else {
                        pi_Id = piId;
                    }
                } else if (action == 'PIChange') {
                    pi_Id = piId;
                }

                //Map<String, String> piCTPMap = new Map<String, String>();
                Map<String, Clinical_Trial_Profile__c> piCTPMap = new Map<String, Clinical_Trial_Profile__c>();//RH-5163

                String ssQuery =
                    'SELECT Id, Name, Clinical_Trial_Profile__r.Id, Clinical_Trial_Profile__r.Study_Code_Name__c,Clinical_Trial_Profile__r.Name, Clinical_Trial_Profile__r.Study_Sponsor__c,' +
                    +'Clinical_Trial_Profile__r.CommunityTemplate__c,Clinical_Trial_Profile__r.Patient_Portal_Enabled__c, Principal_Investigator__c FROM Study_Site__c WHERE Principal_Investigator__c =\'' +
                    pi_Id +
                    '\'';
                if (CommunityTemplateService.TEMPLATE_JANSSEN == communityName) {
                    ssQuery +=
                        ' AND Clinical_Trial_Profile__r.CommunityTemplate__c = \'' +
                        CommunityTemplateService.TEMPLATE_JANSSEN +
                        '\'';
                } else {
                    ssQuery +=
                        ' AND Clinical_Trial_Profile__r.CommunityTemplate__c != \'' +
                        CommunityTemplateService.TEMPLATE_JANSSEN +
                        '\'';
                }
                if (!delegateSSIds.isEmpty() && currentContactId != pi_Id)
                    ssQuery +=
                        ' AND Id  IN (\'' +
                        String.join(new List<Id>(delegateSSIds), '\',\'') +
                        '\')';

                List<Study_Site__c> related_site_sites = Database.query(ssQuery);
                for (Study_Site__c ss : related_site_sites) {
                    /*piCTPMap.put(
                        ss.Clinical_Trial_Profile__r.Id,
                        ss.Clinical_Trial_Profile__r.Study_Code_Name__c
                    );*/
                    //RH-5163
                    piCTPMap.put(
                        ss.Clinical_Trial_Profile__r.Id,
                        ss.Clinical_Trial_Profile__r
                    );
                }

                for (Id ctp_Id : piCTPMap.keySet()) {
                    piData.piCTPPicklist.add(new LabelValueItem(piCTPMap.get(ctp_Id).Study_Code_Name__c, ctp_Id));
                    //RH-5163
                    CTPPPEnable ctpp = new CTPPPEnable();
                    ctpp.label = piCTPMap.get(ctp_Id).Study_Code_Name__c;
                    ctpp.value = ctp_id;
                    ctpp.ppEnabled = piCTPMap.get(ctp_Id).Patient_Portal_Enabled__c;
                    piData.piCTPPPEnablelist.add(ctpp);
                }

                for (Id pId : delegatePIsMap.keySet()) {
                    piData.delegatePIsPicklist.add(
                        new LabelValueItem(delegatePIsMap.get(pId), pId)
                    );
                }

                if (!delegatePIsMap.isEmpty()) {
                    piData.selectedPi = new List<Id>(delegatePIsMap.keySet())[0];
                } else {
                    piData.selectedPi = currentContactId;
                }

                if (!piCTPMap.isEmpty()) {
                    piData.selectedCTP = new List<String>(piCTPMap.keySet())[0];
                } else {
                    piData.selectedCTP = ctpId;
                }

                piData.currentStudySitesCount = [
                    SELECT COUNT()
                    FROM Study_Site__c
                    WHERE Clinical_Trial_Profile__r.Id = :ctpId
                ];
                return JSON.serialize(piData);
            } else if (userMode == CommunityService.USER_MODE_HCP) {
                HCPData hcpData = new HCPData();
                hcpData.waitingToBeReferred = ParticipantEnrollmentService.getPEnrolmentsCount(
                    userMode,
                    ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL,
                    delegateId
                );
                hcpData.waitingToBeReferredList = preparePEList(
                    ParticipantEnrollmentService.getPEnrolmentsByStatus(
                        userMode,
                        new List<String>{
                            ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL
                        },
                        3,
                        delegateId
                    ),
                    userMode,
                    delegateId
                );
                //Referring status:
                Integer passedReviewAndReffered = ParticipantEnrollmentService.getPEnrolmentsCount(
                    userMode,
                    new List<String>(PEStatusState.ALL_USED_STATUSES),
                    delegateId
                );
                Integer passedReviewNotYetReferred = hcpData.waitingToBeReferred;
                Integer failedReview = ParticipantEnrollmentService.getPEnrolmentsCount(
                    userMode,
                    ParticipantEnrollmentService.PART_STATUS_FAILED_REVIEW,
                    delegateId
                );
                hcpData.referringStatus.addAll(
                    new List<DonutItem>{
                        new DonutItem(
                            Label.DI_L_Passed_review_and_referred,
                            passedReviewAndReffered,
                            DonutItem.Type.SUCCSESS
                        ),
                        new DonutItem(
                            Label.DI_L_Passed_review_and_not_yet_referred,
                            passedReviewNotYetReferred,
                            DonutItem.Type.ON_HOLD
                        ),
                        new DonutItem(
                            Label.DI_L_Failed_review,
                            failedReview,
                            DonutItem.Type.DECLINED
                        )
                    }
                );

                Integer piAccepted = ParticipantEnrollmentService.getPEnrolmentsCount(
                    userMode,
                    PEStatusState.STATUS_STEPS_TABLE[0]
                        .states.get(PEStatusState.STATUS_STATE_SUCCESS),
                    delegateId
                );
                hcpData.acceptenceStatus.addAll(
                    new List<DonutItem>{
                        new DonutItem(
                            Label.DI_L_Accepted,
                            piAccepted,
                            DonutItem.Type.SUCCSESS
                        ) /*,
                                                                                                  new DonutItem(Label.DI_L_On_hold, piOnHold , DonutItem.Type.ON_HOLD),
                                                                                                  new DonutItem(Label.DI_L_Declined, piDeclined , DonutItem.Type.DECLINED),
                                                                                                  new DonutItem(Label.DI_L_Approval_pending, piPending , DonutItem.Type.PENDING)*/
                    }
                );

                //Enrollment status
                Integer enrolledRandomized = ParticipantEnrollmentService.getPEnrolmentsCount(
                    userMode,
                    PEStatusState.STATUSES_ENROLLED,
                    delegateId
                );
                Integer inProgress = ParticipantEnrollmentService.getPEnrolmentsCount(
                    userMode,
                    PEStatusState.STATUSES_IN_PROGRESS,
                    delegateId
                );
                Integer declined = ParticipantEnrollmentService.getPEnrolmentsCount(
                    userMode,
                    PEStatusState.STATUSES_FAILED,
                    delegateId
                );
                hcpData.enrollmentStatus.addAll(
                    new List<DonutItem>{
                        new DonutItem(
                            Label.DI_L_Enrolled_randomized,
                            enrolledRandomized,
                            DonutItem.Type.SUCCSESS
                        ),
                        new DonutItem(Label.DI_L_In_progress, inProgress, DonutItem.Type.ON_HOLD),
                        new DonutItem(
                            Label.DI_L_Failed_enrollment,
                            declined,
                            DonutItem.Type.DECLINED
                        )
                    }
                );

                return JSON.serialize(hcpData);
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @TestVisible
    private static List<ListItem> preparePEList(
        List<Participant_Enrollment__c> peList,
        String userMode,
        String delegateId
    ) {
        List<ListItem> resList = new List<ListItem>();
        for (Participant_Enrollment__c pe : peList) {
            StudyActions studyActions;
            if (userMode == CommunityService.USER_MODE_HCP) {
                studyActions = new StudyActionsHCP(pe, delegateId);
            } else {
                studyActions = new StudyActionsPI(pe);
            }
            resList.add(new ListItem(pe, studyActions.actions));
        }
        return resList;
    }

    /* @AuraEnabled
    public static Integer totalPrepareAwaitingContacts(String userMode, String delegateId, Id piId, String ctpId){
       AggregateResult awaitingContactRecords = [SELECT COUNT(Id)totalContacts FROM Participant_Enrollment__c
                                                    WHERE (Participant_Status__c =: PEStatusState.PE_STATUS_CONTACT_ATTEMPTED OR Participant_Status__c =: PEStatusState.PE_STATUS_RECEIVED) 
                                                    AND Study_Site__c != NULL AND study_Site__r.Clinical_Trial_Profile__c =: ctpId
                                                    AND Study_Site__r.Principal_Investigator__c =: piId];
         Integer totalAwaitingContacts = (Integer)awaitingContactRecords.get('totalContacts');
        return totalAwaitingContacts;
    } */

    @AuraEnabled
    public static List<WaitingContactItem> prepareAwaitingContactList(
        Id piId,
        String ctpId,
        String communityName
    ) {
        List<WaitingContactItem> resList = new List<WaitingContactItem>();
        Set<Id> avaliableSS = new Set<Id>();
        Set<Id> ssId = new Set<Id>();
        try {
            Id currentContactId = CommunityService.getInstance().getCurrentContactId();
            List<Participant_Enrollment__c> contactAtemptedList = [
                SELECT
                    Id,
                    Name,
                    CreatedDate,
                    Participant__c,
                    Participant__r.First_Name__c,
                    Source_Type__c,
                    Participant__r.Last_Name__c,
                	Study_Site__r.Name,
                    Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                    Study_Site__r.Clinical_Trial_Profile__c,
                    Participant_Status__c,
                    Succesfully_Re_Engaged__c
                FROM Participant_Enrollment__c
                WHERE
                    (Participant_Status__c = :PEStatusState.PE_STATUS_CONTACT_ATTEMPTED
                    OR Participant_Status__c = :PEStatusState.PE_STATUS_RECEIVED
                    OR Participant_Status__c = :STATUS_PARTICIPANT_NO_SHOW
                    OR Participant_Status__c = :STATUS_RE_ENGAGED)
                    AND Study_Site__c != NULL
                    AND study_Site__r.Clinical_Trial_Profile__c = :ctpId
                    AND Study_Site__r.Principal_Investigator__c = :piId
                ORDER BY Createddate DESC
                LIMIT 50
            ];

            for (Participant_Enrollment__c pe : contactAtemptedList) {
                ssId.add(pe.Study_Site__c);
            }

            for (Site_Staff__c sstaff : [
                SELECT Id, Study_Site__c, Study_Site__r.Clinical_Trial_Profile__c, is_Invited__c
                FROM Site_Staff__c
                WHERE
                    Study_Site__c IN :ssId
                    AND Site_Contact__c = :currentContactId
                    AND is_Invited__c = TRUE
            ]) {
                avaliableSS.add(sstaff.Study_Site__c);
            }

            for (Participant_Enrollment__c pe : contactAtemptedList) {
                Boolean isReEngagePar = false;      
                isReEngagePar = pe.Succesfully_Re_Engaged__c;
                if (avaliableSS.isEmpty()) {
                    Integer daysAdded = pe.CreatedDate.date().daysBetween(System.today());
                    resList.add(
                        new WaitingContactItem(
                            pe.Participant__c,
                            pe.Name,
                            pe.Participant__r.First_Name__c +
                            ' ' +
                            pe.Participant__r.Last_Name__c,
                            TranslateHelper.getPickListLabel(
                                Participant_Enrollment__c.Source_Type__c,
                                pe.Source_Type__c
                            ),
                            pe.Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                            pe.Study_Site__r.Clinical_Trial_Profile__c,
                            daysAdded,
                            true,
                            pe.Study_Site__r.Name,
                            isReEngagePar
                        )
                    );
                } else {
                    if (avaliableSS.contains(pe.Study_Site__c)) {
                        Integer daysAdded = pe.CreatedDate.date().daysBetween(System.today());
                        resList.add(
                            new WaitingContactItem(
                                pe.Participant__c,
                                pe.Name,
                                pe.Participant__r.First_Name__c +
                                ' ' +
                                pe.Participant__r.Last_Name__c,
                                TranslateHelper.getPickListLabel(
                                    Participant_Enrollment__c.Source_Type__c,
                                    pe.Source_Type__c
                                ),
                                pe.Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                                pe.Study_Site__r.Clinical_Trial_Profile__c,
                                daysAdded,
                                true,
                                pe.Study_Site__r.Name,
                                isReEngagePar
                            )
                        );
                    } else {
                        Integer daysAdded = pe.CreatedDate.date().daysBetween(System.today());
                        resList.add(
                            new WaitingContactItem(
                                pe.Participant__c,
                                pe.Name,
                                pe.Participant__r.First_Name__c +
                                ' ' +
                                pe.Participant__r.Last_Name__c,
                                TranslateHelper.getPickListLabel(
                                    Participant_Enrollment__c.Source_Type__c,
                                    pe.Source_Type__c
                                ),
                                pe.Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                                pe.Study_Site__r.Clinical_Trial_Profile__c,
                                daysAdded,
                                false,
                                pe.Study_Site__r.Name,
                                isReEngagePar
                            )
                        );
                    }
                }
            }
            resList.sort();
            return resList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static List<BarItem> prepareWaitingList(
        String userMode,
        String delegateId,
        String piId,
        String ctpId
    ) {
        try {
            List<BarItem> resList = new List<BarItem>();
            List<Participant_Enrollment_Status_History__c> peSHs = [
                SELECT Id, Date__c, ParticipantEnrollment__c, Status__c
                FROM Participant_Enrollment_Status_History__c
                WHERE
                    Date__c != NULL
                    AND ParticipantEnrollment__r.Study_Site__r.Principal_Investigator__c = :piId
                    AND ParticipantEnrollment__r.Clinical_Trial_Profile__c = :ctpId
                    AND Status__c IN :(new List<String>{
                        PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED,
                        PEStatusState.PE_STATUS_RECEIVED
                    })
                ORDER BY CreatedDate DESC
                LIMIT 40000
            ];
            Map<Id, Participant_Enrollment_Status_History__c> receivedPESHsByPIId = new Map<Id, Participant_Enrollment_Status_History__c>();
            Map<Id, Participant_Enrollment_Status_History__c> contactedPESHsByPIId = new Map<Id, Participant_Enrollment_Status_History__c>();
            Set<Id> peIdsProcessed = new Set<Id>();
            Integer peSHsSize = peSHs.size();

            for (Integer i = 0; i < peSHsSize; i++) {
                if (!peIdsProcessed.Contains(peSHs[i].ParticipantEnrollment__c)) {
                    if (peSHs[i].Status__c == PEStatusState.PE_STATUS_RECEIVED) {
                        receivedPESHsByPIId.put(peSHs[i].ParticipantEnrollment__c, peSHs[i]);
                    } else {
                        contactedPESHsByPIId.put(peSHs[i].ParticipantEnrollment__c, peSHs[i]);
                    }
                }
            }

            Integer maxParticipantsInDays = 0;
            String daysMaxParticipantsInDays = null;

            String days;
            Integer total_LEESS_5_DAYS = 0;
            Integer total_FROM_6_TO_10_DAYS = 0;
            Integer total_FROM_11_TO_15_DAYS = 0;
            Integer total_FROM_16_TO_20_DAYS = 0;
            Integer total_GREATER_20_DAYS = 0;
            Integer peSHDaySize = 0;
            Integer daysBetween = 0;
            List<Participant_Enrollment_Status_History__c> receivedPeshList = receivedPESHsByPIId.values();
            Integer receivedPeshSize = receivedPeshList.size();

            for (Integer i = 0; i < receivedPeshSize; i++) {
                Participant_Enrollment_Status_History__c contactedPESH = contactedPESHsByPIId.get(
                    receivedPeshList[i].ParticipantEnrollment__c
                );
                if (contactedPESH != null) {
                    daysBetween = receivedPeshList[i]
                        .Date__c.date()
                        .daysBetween(contactedPESH.Date__c.date());
                    days = null;
                    if (daysBetween <= 5) {
                        days = LEESS_5_DAYS;
                        ++total_LEESS_5_DAYS;
                        ++peSHDaySize;
                    } else if (daysBetween >= 6 && daysBetween <= 10) {
                        days = FROM_6_TO_10_DAYS;
                        ++total_FROM_6_TO_10_DAYS;
                        ++peSHDaySize;
                    } else if (daysBetween >= 11 && daysBetween <= 15) {
                        days = FROM_11_TO_15_DAYS;
                        ++total_FROM_11_TO_15_DAYS;
                        ++peSHDaySize;
                    } else if (daysBetween >= 16 && daysBetween <= 20) {
                        days = FROM_16_TO_20_DAYS;
                        ++total_FROM_16_TO_20_DAYS;
                        ++peSHDaySize;
                    } else if (daysBetween > 20) {
                        days = GREATER_20_DAYS;
                        ++total_GREATER_20_DAYS;
                        ++peSHDaySize;
                    }
                    if (maxParticipantsInDays < peSHDaySize) {
                        ++maxParticipantsInDays;
                        daysMaxParticipantsInDays = days;
                    }
                }
            }
            // 70% width is maxParticipantsInDays
            resList.add(
                prepareBarItem(
                    '#D8EBF7',
                    LEESS_5_DAYS,
                    total_LEESS_5_DAYS,
                    maxParticipantsInDays,
                    daysMaxParticipantsInDays
                )
            );
            resList.add(
                prepareBarItem(
                    '#B8DDF6',
                    FROM_6_TO_10_DAYS,
                    total_FROM_6_TO_10_DAYS,
                    maxParticipantsInDays,
                    daysMaxParticipantsInDays
                )
            );
            resList.add(
                prepareBarItem(
                    '#83C7F4',
                    FROM_11_TO_15_DAYS,
                    total_FROM_11_TO_15_DAYS,
                    maxParticipantsInDays,
                    daysMaxParticipantsInDays
                )
            );
            resList.add(
                prepareBarItem(
                    '#3D9BD9',
                    FROM_16_TO_20_DAYS,
                    total_FROM_16_TO_20_DAYS,
                    maxParticipantsInDays,
                    daysMaxParticipantsInDays
                )
            );
            resList.add(
                prepareBarItem(
                    '#136BA6',
                    GREATER_20_DAYS,
                    total_GREATER_20_DAYS,
                    maxParticipantsInDays,
                    daysMaxParticipantsInDays
                )
            );
            return resList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String getParticipantData(
        String userMode,
        String delegateId,
        String participantId,
        String piId,
        String ctpId
    ) {
        ViewPatientsRemote.InitData initData = new ViewPatientsRemote.InitData();
        initData.peStatusStateMap = PEStatusState.STATUSES_MAP;
        initData.peStatusesPathList = PEStatusState.STATUS_STEPS_LIST;
        Id participantContactId = [SELECT Contact__c FROM Participant__c WHERE Id = :participantId]
        .Contact__c;
        // initData.isInvited = ![SELECT Id FROM User WHERE ContactId = : participantContactId].isEmpty();

        List<user> lstUser = new List<user>();
        lstUser = [SELECT Id FROM User WHERE ContactId = :participantContactId];

		//List<String> PE_FIELDS = ParticipantEnrollmentService.PE_COMMON_FIELDS;
        //PE_FIELDS.add('Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c');
        //PE_FIELDS.add('Invited_To_Patient_Portal__c');
        if (lstUser.size() == 0){// && !pes[i].Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c && !pes[i].Invited_To_Patient_Portal__c) {
            initData.isInvited = false;
        } else {
            initData.isInvited = true;
        }  
        List<Participant_Enrollment__c> pes = (List<Participant_Enrollment__c>) DatabaseService.query(
            ParticipantEnrollmentService.PE_COMMON_FIELDS,
            Participant_Enrollment__c.getSObjectType(),
            ' Participant__c = \'' +
            participantId +
            '\''
        );
        
        
        Integer participantEnrollmentSize = pes.size();
        for (Integer i = 0; i < participantEnrollmentSize; ++i) {
            if (pes[i].Participant__c == participantId 
                && pes[i].Study_Site__c != null
                && pes[i].Study_Site__r.Clinical_Trial_Profile__c == ctpId 
                && pes[i].Study_Site__r.Principal_Investigator__c == piId) {
                initData.currentPageList = new List<ViewPatientsRemote.PEWrapper>{
                    new ViewPatientsRemote.PEWrapper(pes[i], new StudyActionsPI(pes[i]).actions)
                };
            }
        }
        return JSON.serialize(initData);
    }

    private static BarItem prepareBarItem(
        String color,
        String title,
        Integer count,
        Integer maxPInD,
        String maxD
    ) {
        String width = title == maxD
            ? '70%'
            : count != 0 ? '' + Math.Round(70 / Math.Round(maxPInD / count)) + '%' : '1%';
        return new BarItem(color, width, title, '' + count);
    }

    @AuraEnabled
    public static string prepareHCPEList(Id piId, Id ctpId) {
        List<HCP_Enrollment__c> physiciansWaitingForApprovalPEList = new List<HCP_Enrollment__c>();
        List<ListItem> physiciansWaitingForApprovalList = new List<ListItem>();
        try {
            if (piId != null && ctpId != null) {
                List<HCP_Enrollment__c> hcpEnrollments = HCPEnrollmentService.getHCPEnrollmentsByPIVSStudy(
                    piId,
                    ctpId
                );
                for (HCP_Enrollment__c hcpe : hcpEnrollments) {
                    if (
                        HCPEnrollmentService.STATUS_GROUP_PENDING.contains(hcpe.Status__c) &&
                        physiciansWaitingForApprovalPEList.size() < 3
                    ) {
                        physiciansWaitingForApprovalPEList.add(hcpe);
                    }
                }
                if (!physiciansWaitingForApprovalPEList.isEmpty()) {
                    physiciansWaitingForApprovalList = prepareHCPEList(
                        physiciansWaitingForApprovalPEList,
                        piId
                    );
                }
            }
            return JSON.serialize(physiciansWaitingForApprovalList);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public static List<ListItem> prepareHCPEList(List<HCP_Enrollment__c> hcpeList, Id piId) {
        List<ListItem> resList = new List<ListItem>();
        Id currentUserId = CommunityService.getInstance().getCurrentContactId();
        Set<Id> avaliableIds = new Set<Id>();
        Set<Id> hcpContactIds = new Set<Id>();
        if (piId != currentUserId) {
            Set<Id> ssId = new Set<Id>();
            for (HCP_Enrollment__c hcpe : hcpeList) {
                ssId.add(hcpe.Study_Site__c);
                hcpContactIds.add(hcpe.HCP_Contact__c);
            }
            for (Site_Staff__c ssStaff : [
                SELECT Id, Study_Site__c
                FROM Site_Staff__c
                WHERE
                    Study_Site__c IN :ssId
                    AND Site_Contact__c = :currentUserId
                    AND Delegate_Level__c = 'Level 1'
            ]) {
                avaliableIds.add(ssStaff.Study_Site__c);
            }
        }else{
            for (HCP_Enrollment__c hcpe : hcpeList) {
                hcpContactIds.add(hcpe.HCP_Contact__c);
            }
        }
        Map<Id,String> hcpNames = new Map<Id,String>();
        if(!hcpContactIds.isEmpty()){        
            List<Participant__c> RHParticipants= [SELECT Id,Contact__c,Salutation__c,First_Name__c,Middle_Name__c,Last_Name__c,Suffix__c FROM Participant__c WHERE Contact__c IN:hcpContactIds];
            for(Participant__c RHParticipant : RHParticipants){
                String Name;
		if(RHParticipant.Salutation__c!=null){
                    Name = Name==null?RHParticipant.Salutation__c : Name + ' ' + RHParticipant.Salutation__c;
            	}
                if(RHParticipant.First_Name__c!=null){
                    Name = Name==null?RHParticipant.First_Name__c : Name + ' ' + RHParticipant.First_Name__c;
                }
                if(RHParticipant.Middle_Name__c!=null){
                    Name = Name==null?RHParticipant.Middle_Name__c : Name + ' ' + RHParticipant.Middle_Name__c;
                }
                if(RHParticipant.Last_Name__c!=null){
                    Name = Name==null?RHParticipant.Last_Name__c : Name + ' ' + RHParticipant.Last_Name__c;
                }
                if(RHParticipant.Suffix__c!=null){
                    Name = Name==null?RHParticipant.Suffix__c : Name + ' ' + RHParticipant.Suffix__c;
                }
                hcpNames.put(RHParticipant.Contact__c, Name);
            }
        }
        for (HCP_Enrollment__c hcpe : hcpeList) {
            if (avaliableIds.isEmpty() && piId == currentUserId) {
                Map<String, StudyActions.Action> actions = new StudyActionsPI(hcpe).actions;
                Set<String> actionIds = HCPEnrollmentService.HCP_CHANGE_STATUS_MAP.get(
                        hcpe.Status__c
                    )
                    .keySet();
                for (String actionId : actionIds) {
                    StudyActions.Action action = actions.get(actionId);
                    if (action.cssClass == 'green') {
                        resList.add(new ListItem(hcpe, action, hcpNames.get(hcpe.HCP_Contact__c)));
                        break;
                    }
                }
            } else {
                if (avaliableIds.contains(hcpe.Study_Site__c) && piId != currentUserId) {
                    Map<String, StudyActions.Action> actions = new StudyActionsPI(hcpe).actions;
                    Set<String> actionIds = HCPEnrollmentService.HCP_CHANGE_STATUS_MAP.get(
                            hcpe.Status__c
                        )
                        .keySet();
                    for (String actionId : actionIds) {
                        StudyActions.Action action = actions.get(actionId);
                        if (action.cssClass == 'green') {
                            resList.add(new ListItem(hcpe, action, hcpNames.get(hcpe.HCP_Contact__c)));
                            break;
                        }
                    }
                }
            }
        }
        return resList;
    }

    public class ContactedParticipantwrapper {
        @AuraEnabled
        public String FROM_1_TO_3_DAYS_Label = Label.PG_DBPI_L_1_to_3_Days;
        @AuraEnabled
        public String FROM_4_TO_7_DAYS_Label = Label.PG_DBPI_L_4_to_7_Days;
        @AuraEnabled
        public String FROM_8_TO_10_DAYS_Label = Label.PG_DBPI_L_8_to_10_Days;
        @AuraEnabled
        public String FROM_11_TO_21_DAYS_Label = Label.PG_DBPI_L_11_to_21_Days;
        @AuraEnabled
        public String GREATER_21_DAYS_Label = Label.PG_DBPI_L_Greater_Than_21_Days;
        @AuraEnabled
        public Integer FROM_1_TO_3_DAYS = 0;
        @AuraEnabled
        public Integer FROM_4_TO_7_DAYS = 0;
        @AuraEnabled
        public Integer FROM_8_TO_10_DAYS = 0;
        @AuraEnabled
        public Integer FROM_11_TO_21_DAYS = 0;
        @AuraEnabled
        public Integer GREATER_21_DAYS = 0;
        @AuraEnabled
        public Integer total = 0;
        @AuraEnabled
        public Map<String, Map<Id, String>> daysPatientsStudies = new Map<String, Map<Id, String>>();
        @AuraEnabled 
        public Map<Id,String> mapPartcipantIdToPerName = new Map<Id,String> (); 	
    }

    @AuraEnabled
    public static ContactedParticipantwrapper getContactedParticipantsData(
        String principalInvestigatorId,
        String studyId
    ) {
        try {
            List<Clinical_Trial_Profile__c> ctp = [
                SELECT Id, Initial_Visit_Required__c
                FROM Clinical_Trial_Profile__c
                WHERE
                    Id = :studyId
                    AND Initial_Visit_Required__c != NULL
                    AND Initial_Visit_Required__c = FALSE
            ];
            if (!ctp.isEmpty()) {
                return null;
            } else {
                ContactedParticipantwrapper contactedWrapper = new ContactedParticipantwrapper();
                contactedWrapper.daysPatientsStudies.put('1-3 Days', new Map<Id, String>());
                contactedWrapper.daysPatientsStudies.put('4-7 Days', new Map<Id, String>());
                contactedWrapper.daysPatientsStudies.put('8-10 Days', new Map<Id, String>());
                contactedWrapper.daysPatientsStudies.put('11-21 Days', new Map<Id, String>());
                contactedWrapper.daysPatientsStudies.put('>21 Days', new Map<Id, String>());
                Integer daysBetween = 0;

                List<Participant_Enrollment_Status_History__c> peshList = [
                    SELECT
                        Id,
                        ParticipantEnrollment__r.Name,
                        CreatedDate,
                        Date__c,
                        Status__c,
                        ParticipantEnrollment__r.Initial_visit_scheduled_date__c,
                        ParticipantEnrollment__r.Participant_Status__c,
                        ParticipantEnrollment__r.PI_Contact__c,
                        ParticipantEnrollment__r.Clinical_Trial_Profile__r.Study_Title__c,
                        ParticipantEnrollment__c,
                        ParticipantEnrollment__r.Participant__c,
                        ParticipantEnrollment__r.Participant__r.Full_Name__c
                    FROM Participant_Enrollment_Status_History__c
                    WHERE
                        ParticipantEnrollment__r.Study_Site__r.Principal_Investigator__c = :principalInvestigatorId
                        AND ParticipantEnrollment__r.Clinical_Trial_Profile__c = :studyId
                        AND ParticipantEnrollment__r.Initial_visit_scheduled_date__c = NULL
                        AND ParticipantEnrollment__r.Participant__c != NULL
                        AND Date__c != NULL
                        AND Status__c IN :(new List<String>{ PE_STATUS_SUCCESSFULLY_CONTACTED })
                        AND ParticipantEnrollment__r.Participant_Status__c  IN :PEStatusState.PE_STATUS_GROUP_POSITIVE_PARTICIPANTS_CONTACTED
                    ORDER BY Createddate DESC
                    LIMIT 40000
                ];
                for (Participant_Enrollment_Status_History__c pesh : peshList) {
                    daysBetween = Date.valueOf(pesh.Date__c).daysBetween(system.Today());
                    String days = null;
                    contactedWrapper.mapPartcipantIdToPerName.put(pesh.ParticipantEnrollment__r.Participant__c,pesh.ParticipantEnrollment__r.Name);
                    if (daysBetween <= 3) {
                        ++contactedWrapper.FROM_1_TO_3_DAYS;
                        if (contactedWrapper.FROM_1_TO_3_DAYS <= 800) {
                            days = '1-3 Days';
                        }
                    } else if (daysBetween >= 4 && daysBetween <= 7) {
                        ++contactedWrapper.FROM_4_TO_7_DAYS;
                        if (contactedWrapper.FROM_4_TO_7_DAYS <= 800) {
                            days = '4-7 Days';
                        }
                    } else if (daysBetween >= 8 && daysBetween <= 10) {
                        ++contactedWrapper.FROM_8_TO_10_DAYS;
                        if (contactedWrapper.FROM_8_TO_10_DAYS <= 800) {
                            days = '8-10 Days';
                        }
                    } else if (daysBetween >= 11 && daysBetween <= 21) {
                        ++contactedWrapper.FROM_11_TO_21_DAYS;
                        if (contactedWrapper.FROM_11_TO_21_DAYS <= 800) {
                            days = '11-21 Days';
                        }
                    } else if (daysBetween > 21) {
                        ++contactedWrapper.GREATER_21_DAYS;
                        if (contactedWrapper.GREATER_21_DAYS <= 800) {
                            days = '>21 Days';
                        }
                    }
                    if (days != null) {
                        contactedWrapper.daysPatientsStudies.get(days)
                            .put(
                                pesh.ParticipantEnrollment__r.Participant__c,
                                pesh.ParticipantEnrollment__r.Participant__r.Full_Name__c
                            );
                    }
                }
                return contactedWrapper;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static string getPEEnrollmentsByPI(String eId) {
        List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
        try {
            String filter = ' Participant__c = \'' + eId + '\'';
            peList = DatabaseService.query(
                ParticipantEnrollmentService.PE_COMMON_FIELDS,
                Participant_Enrollment__c.getSObjectType(),
                filter
            );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
        return JSON.serialize(peList[0]);
    }

    @AuraEnabled
    public static string getInvitedDetails(string participantId) {
        try {
            Boolean Userexist;
            Id participantContactId = [
                SELECT Contact__c
                FROM Participant__c
                WHERE Id = :participantId
            ]
            .Contact__c;
            List<user> lstUser = [
                SELECT id, ContactId
                FROM user
                WHERE ContactId = :participantContactId
            ];

            if (!lstUser.isEmpty()) {
                Userexist = true;
            } else {
                Userexist = false;
            }
            return JSON.serialize(Userexist);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    //This method is used to set rank for the study sites
    public static List<SSRankWrapper> setRank(List<SSRankWrapper> ssRankWrapperlist) {
        Integer rank = 1;
        List<SSRankWrapper> setRankList = new List<SSRankWrapper>();
        if (ssRankWrapperlist != null && !ssRankWrapperlist.isEmpty()) {
            for (SSRankWrapper ssrw : ssRankWrapperlist) {
                ssrw.rank = rank++;
                setRankList.add(ssrw);
            }
            for (Integer index = 0; index < setRankList.size(); index++) {
                if (
                    index < setRankList.size() - 1 &&
                    (setRankList.get(index).initial_Visits_Completed ==
                    setRankList.get(index + 1).initial_Visits_Completed)
                ) {
                    setRankList.get(index + 1).rank = setRankList.get(index).rank;
                }
            }
        }
        return setRankList;
    }

    //This mesthod is used to get Name of the selected PI
    public static String getPIName(Id pIid) {
        String piName;
        List<Participant__c> partList = [SELECT Id,First_Name__c,Middle_Name__c,Last_Name__c,Suffix__c FROM Participant__c WHERE Contact__c =:pIid LIMIT 1];
        if(partList.isEmpty()){
            List<Contact> cList = [SELECT Id, Name FROM Contact WHERE Id = :pIid LIMIT 1];
            piName = !cList.isEmpty() && cList[0].Name != null ? cList[0].Name : null;
        }else{
            if(partList[0].First_Name__c!=null){
                piName = piName==null?partList[0].First_Name__c : piName + ' ' + partList[0].First_Name__c;
            }
            if(partList[0].Middle_Name__c!=null){
                piName = piName==null?partList[0].Middle_Name__c : piName + ' ' + partList[0].Middle_Name__c;
            }
            if(partList[0].Last_Name__c!=null){
                piName = piName==null?partList[0].Last_Name__c : piName + ' ' + partList[0].Last_Name__c;
            }
            if(partList[0].Suffix__c!=null){
                piName = piName==null?partList[0].Suffix__c : piName + ' ' + partList[0].Suffix__c;
            }
        }
        return piName;
    }

    //This method used to get name of the selected Study
    public static String getStudyName(Id studyid) {
        List<Clinical_Trial_Profile__c> ctp = [
            SELECT Id, Study_Code_Name__c
            FROM Clinical_Trial_Profile__c
            WHERE Id = :studyid
            LIMIT 1
        ];
        return !ctp.isEmpty() && ctp[0].Study_Code_Name__c != null
            ? ctp[0].Study_Code_Name__c
            : null;
    }

    @AuraEnabled
    public static Integer getCurrentStudySitesCount(Id ctpId) {
        try {
            Integer currentStudySitesCount = [
                SELECT COUNT()
                FROM Study_Site__c
                WHERE Clinical_Trial_Profile__r.Id = :ctpId
            ];
            return currentStudySitesCount;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public static Map<String, List<String>> funnelChartAndLeaderBoardStatusMap = new Map<String, List<String>>{
        'receivedStatus' => new List<String>{
            PE_STATUS_SUCCESSFULLY_CONTACTED,
            STATUS_SCREENING_PASSED,
            PE_STATUS_SCREENING_PASSED_WASH_OUT_PERIOD,
            STATUS_IN_WASH_OUT_PERIOD,
            STATUS_SCREENING_IN_PROGRESS_WASH_OUT,
            PE_STATUS_SCREENING_FAILED,
            PE_STATUS_ELIGIBILITY_FAILED, 
            STATUS_ENROLLMENT_SUCCESS,
            STATUS_RANDOMIZATION_SUCCESS,
            PE_STATUS_ENROLLED,
            PE_STATUS_RANDOMIZED,
            PARTICIPANT_WORKFLOW_FINAL_STEP_ENROLLMENT,
            PARTICIPANT_WORKFLOW_FINAL_STEP_RANDOMIZATION,
            STATUS_CONTACTED_NOT_SUITABLE,
            STATUS_RECEIVED,
            STATUS_REFERRAL_ACCEPTED,
            STATUS_REFERRAL_ON_HOLD,
            STATUS_REFERRAL_DECLINED,
            STATUS_CONTACT_ATTEMPTED,
            STATUS_SCREENING_IN_PROGRESS,
            STATUS_UNABLE_TO_SCREEN,
            STATUS_ENROLLMENT_FAILED,
            STATUS_RANDOMIZATION_FAILED,
            STATUS_TREATMENT_PERIOD_STARTED,
            STATUS_FOLLOW_UP_PERIOD_STARTED,
            STATUS_PARTICIPATION_COMPLETE,
            STATUS_TRIAL_COMPLETE,
            STATUS_DROP_OUT,
            STATUS_DECEASED,
            STATUS_READY_TO_SCREEN,
            STATUS_DECLINED_FINAL_CONSENT,
            STATUS_DECLINED_CONSENT,
            STATUS_WITHDREW_CONSENT,
            STATUS_WITHDREW_CONSENT_AFTER_SCREENING,
            ELIGIBILITY_PASSED,
            UNABLE_TO_REACH,
            PRE_REVIEW_PASSED,
            PRE_REVIEW_FAILED
        },
        'conditionStatus1' => new List<String>{
            PE_STATUS_SUCCESSFULLY_CONTACTED,
            STATUS_CONTACTED_NOT_SUITABLE
        },
        'conditionStatus2' => new List<String>{
            PE_STATUS_SUCCESSFULLY_CONTACTED,
            PE_STATUS_ELIGIBILITY_FAILED
        },
        'conditionStatus3' => new List<String>{
            PE_STATUS_SUCCESSFULLY_CONTACTED,
            ELIGIBILITY_PASSED
        },
        'conditionStatus4' => new List<String>{
            PE_STATUS_SUCCESSFULLY_CONTACTED,
            STATUS_CONTACT_ATTEMPTED,
            PE_STATUS_SCREENING_FAILED,
            STATUS_SCREENING_IN_PROGRESS,
            STATUS_UNABLE_TO_SCREEN
        },
        'conditionStatus5' => new List<String>{
            PE_STATUS_SUCCESSFULLY_CONTACTED,
            STATUS_CONTACT_ATTEMPTED
        },
        'conditionStatus6' => new List<String>{
            PE_STATUS_SCREENING_FAILED,
            STATUS_SCREENING_IN_PROGRESS,
            STATUS_UNABLE_TO_SCREEN,
            STATUS_READY_TO_SCREEN,
            PE_STATUS_SCREENING_PASSED_WASH_OUT_PERIOD,
            STATUS_IN_WASH_OUT_PERIOD,
            STATUS_SCREENING_IN_PROGRESS_WASH_OUT,
            STATUS_DECLINED_CONSENT,
            STATUS_WITHDREW_CONSENT
        },
        'conditionStatus7' => new List<String>{
            STATUS_SCREENING_PASSED,
            STATUS_DECLINED_FINAL_CONSENT,
            STATUS_WITHDREW_CONSENT_AFTER_SCREENING
        },
        'conditionStatus8' => new List<String>{
            STATUS_ENROLLMENT_SUCCESS,
            STATUS_RANDOMIZATION_SUCCESS,
            STATUS_TREATMENT_PERIOD_STARTED,
            STATUS_FOLLOW_UP_PERIOD_STARTED,
            STATUS_PARTICIPATION_COMPLETE,
            STATUS_TRIAL_COMPLETE,
            STATUS_DROP_OUT,
            STATUS_DECEASED
        },
        'conditionStatus9' => new List<String>{
            STATUS_ENROLLMENT_FAILED,
            STATUS_RANDOMIZATION_FAILED
        }
    };

    //Display funnel chart method
    @AuraEnabled
    public static List<FunnelData> prepareDataForFunnelChart(Id piId, Id ctpId) {
        List<FunnelData> returnData = new List<FunnelData>();
        Integer received = 0;
        Integer contacted = 0;
        Integer scheduled = 0;
        Integer eligibility = 0;
        Integer screened = 0;
        Integer enrolled_randomized = 0;
        Date initialVisitScheduleddate;
        String participantEnrolmentStatus;
        Boolean initialVisitOccuredFlag;
        Boolean initialVisitRequired;
        Integer total;
        try {
            AggregateResult[] groupResult = [
                SELECT
                    Participant_Status__c,
                    Initial_visit_scheduled_date__c,
                    Initial_visit_occurred_flag__c,
                    Clinical_Trial_Profile__r.Initial_Visit_Required__c T,
                    Count(Id) total
                FROM Participant_Enrollment__c
                WHERE
                    Study_Site__c != NULL
                    AND Study_Site__r.Principal_Investigator__c = :piId
                    AND Clinical_Trial_Profile__c = :ctpId
                GROUP BY
                    Participant_Status__c,
                    Initial_visit_scheduled_date__c,
                    Initial_visit_occurred_flag__c,
                    Clinical_Trial_Profile__r.Initial_Visit_Required__c

            ];
            for (AggregateResult ar : groupResult) {
                initialVisitScheduleddate = Date.ValueOf(ar.get('Initial_visit_scheduled_date__c'));
                participantEnrolmentStatus = String.ValueOf(ar.get('Participant_Status__c'));
                initialVisitOccuredFlag = Boolean.ValueOf(ar.get('Initial_visit_occurred_flag__c'));
                initialVisitRequired = Boolean.ValueOf(ar.get('T'));
                total = Integer.valueOf(ar.get('total'));

                if (
                    initialVisitScheduleddate == null && 
                    funnelChartAndLeaderBoardStatusMap.get('conditionStatus1')
                        .contains(participantEnrolmentStatus)
                ) {
                    contacted = contacted + total;
                } else if (
                    initialVisitScheduleddate == null 
                     && initialVisitRequired == false &&
                    funnelChartAndLeaderBoardStatusMap.get('conditionStatus2')
                        .contains(participantEnrolmentStatus)
                ) {
                    contacted = contacted + total;
                }else if (
                    initialVisitScheduleddate == null 
                     && initialVisitRequired == false &&
                    funnelChartAndLeaderBoardStatusMap.get('conditionStatus3')
                        .contains(participantEnrolmentStatus)
                ) {
                    contacted = contacted + total;
                    eligibility = eligibility + total;
                } else if (
                    initialVisitScheduleddate != null &&
                    initialVisitOccuredFlag == false &&
                    funnelChartAndLeaderBoardStatusMap.get('conditionStatus4')
                        .contains(participantEnrolmentStatus)
                ) {
                    contacted = contacted + total;
                    scheduled = scheduled + total;
                }
                if (initialVisitOccuredFlag == true) {
                    if (
                        funnelChartAndLeaderBoardStatusMap.get('conditionStatus5')
                            .contains(participantEnrolmentStatus)
                    ) {
                        contacted = contacted + total;
                        scheduled = scheduled + total;
                    } else if (
                        funnelChartAndLeaderBoardStatusMap.get('conditionStatus6')
                            .contains(participantEnrolmentStatus)
                    ) {
                        contacted = contacted + total;
                        scheduled = scheduled + total;
                    } else if (
                        funnelChartAndLeaderBoardStatusMap.get('conditionStatus7')
                            .contains(participantEnrolmentStatus)
                    ) {
                        contacted = contacted + total;
                        scheduled = scheduled + total;
                        screened = screened + total;
                    }
                }
                if (initialVisitOccuredFlag == false) {
                    if (
                           funnelChartAndLeaderBoardStatusMap.get('conditionStatus6')
                               .contains(participantEnrolmentStatus)
                       ) {
                           contacted = contacted + total;
                           eligibility = eligibility + total;
                       } else if (
                           funnelChartAndLeaderBoardStatusMap.get('conditionStatus7')
                               .contains(participantEnrolmentStatus)
                       ) {
                           contacted = contacted + total;
                           eligibility = eligibility + total;
                           screened = screened + total;
                       } 
                   }  
                if (initialVisitOccuredFlag == false &&
                    funnelChartAndLeaderBoardStatusMap.get('conditionStatus8')
                        .contains(participantEnrolmentStatus)
                ) {
                    contacted = contacted + total;
                    eligibility = eligibility + total;
                    screened = screened + total;
                    enrolled_randomized = enrolled_randomized + total;
                } else if ( initialVisitScheduleddate != null 
                    && initialVisitRequired == true && initialVisitOccuredFlag == true &&
                    funnelChartAndLeaderBoardStatusMap.get('conditionStatus8')
                        .contains(participantEnrolmentStatus)
                ) {
                    contacted = contacted + total;
                    scheduled = scheduled + total;
                    screened = screened + total;
                    enrolled_randomized = enrolled_randomized + total;
                } 
                else if ( initialVisitOccuredFlag == false &&
                    funnelChartAndLeaderBoardStatusMap.get('conditionStatus9')
                        .contains(participantEnrolmentStatus)
                ) {
                    contacted = contacted + total;
                    eligibility = eligibility + total;
                    screened = screened + total;
                }
                else if ( initialVisitScheduleddate != null 
                && initialVisitRequired == true && initialVisitOccuredFlag == true &&
                    funnelChartAndLeaderBoardStatusMap.get('conditionStatus9')
                        .contains(participantEnrolmentStatus)
                ) {
                    contacted = contacted + total;
                    scheduled = scheduled + total;
                    screened = screened + total;
                }
                if (
                    funnelChartAndLeaderBoardStatusMap.get('receivedStatus')
                        .contains(participantEnrolmentStatus)
                ) {
                    received = received + total;
                }
            }
            returnData.add(new FunnelData(Label.Received, received, '#3DC2FA'));
            returnData.add(new FunnelData(Label.Successfully_Contacted, contacted, '#9914E6'));
            if(initialVisitRequired == true){
                returnData.add(new FunnelData(Label.Initial_Visit_Scheduled, scheduled, '#D892FF'));
                }else {
                    returnData.add(new FunnelData(Label.Eligibility_Passed,eligibility , '#D892FF'));
                }
            returnData.add(new FunnelData(Label.Screening_Passed, screened, '#139458'));
            returnData.add(
                new FunnelData(Label.Enrolled_Or_Randomized, enrolled_randomized, '#7AFFD3')
            );
            return returnData;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static List<SSRankWrapper> getStudySiteDetails(Id pIid, Id studyid) {
        try {
            List<SSRankWrapper> ssRankWrapperlist = new List<SSRankWrapper>();
            Map<String, List<AggregateResult>> mapStudySiteWisePEAggregateResult = new Map<String, List<AggregateResult>>();
            Integer contacted = 0;
            Integer scheduled = 0;
            Integer screened = 0;
            Integer enrolled_randomized = 0;
            Integer initial_Visits_Completed = 0;
            Integer rank = 1;
            String site_Number;
            String site_Name;
            String location;
            String is_enrolled_randomized;
            String pi_Id;
            String piName = getPIName(pIid);
            String studyName = getStudyName(studyid);
            Date initialVisitScheduledDate;
            String participantEnrolmentStatus;
            Boolean initialVisitOccuredFlag;
            Integer total;
            String studySiteId;

            List<Study_Site__c> studySites = [
                SELECT
                    Id,
                    Study_Site_Number__c,
                    Name,
                    Site__r.BillingCountry,
                    Principal_Investigator__c,
                    Clinical_Trial_Profile__r.Id,
                    Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c
                FROM Study_Site__c
                WHERE Clinical_Trial_Profile__r.Id = :studyid
                ORDER BY Study_Site_Number__c ASC NULLS LAST
            ];

            AggregateResult[] groupResult = [
                SELECT
                    Study_Site__c,
                    Participant_Status__c,
                    Initial_visit_scheduled_date__c,
                    Initial_visit_occurred_flag__c,
                    Count(Id) total
                FROM Participant_Enrollment__c
                WHERE Study_Site__c != NULL AND Study_Site__c = :studySites
                GROUP BY
                    Study_Site__c,
                    Participant_Status__c,
                    Initial_visit_scheduled_date__c,
                    Initial_visit_occurred_flag__c

            ];
            for (AggregateResult ar : groupResult) {
                studySiteId = String.ValueOf(ar.get('Study_Site__c'));
                if (mapStudySiteWisePEAggregateResult.containsKey(studySiteId)) {
                    List<AggregateResult> lstPE = mapStudySiteWisePEAggregateResult.get(
                        studySiteId
                    );
                    lstPE.add(ar);
                } else {
                    List<AggregateResult> lstPE = new List<AggregateResult>();
                    lstPE.add(ar);
                    mapStudySiteWisePEAggregateResult.put(studySiteId, lstPE);
                }
            }

            for (Study_Site__c ss : studySites) {
                contacted = 0;
                scheduled = 0;
                screened = 0;
                enrolled_randomized = 0;
                rank = 1;
                initial_Visits_Completed = 0;
                site_Number = ss.Study_Site_Number__c;
                site_Name = ss.Name;
                pi_Id = ss.Principal_Investigator__c;
                location = ss.Site__r.BillingCountry;

                if (
                    ss.Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c ==
                    PARTICIPANT_WORKFLOW_FINAL_STEP_ENROLLMENT
                ) {
                    is_enrolled_randomized = PE_STATUS_ENROLLED;
                }
                if (
                    ss.Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c ==
                    PARTICIPANT_WORKFLOW_FINAL_STEP_RANDOMIZATION
                ) {
                    is_enrolled_randomized = PE_STATUS_RANDOMIZED;
                }
                if (
                    !mapStudySiteWisePEAggregateResult.isEmpty() &&
                    mapStudySiteWisePEAggregateResult.get(ss.id) != null
                ) {
                    for (AggregateResult ar : mapStudySiteWisePEAggregateResult.get(ss.id)) {
                        initialVisitScheduledDate = Date.ValueOf(
                            ar.get('Initial_visit_scheduled_date__c')
                        );
                        participantEnrolmentStatus = String.ValueOf(
                            ar.get('Participant_Status__c')
                        );
                        initialVisitOccuredFlag = Boolean.ValueOf(
                            ar.get('Initial_visit_occurred_flag__c')
                        );
                        total = Integer.valueOf(ar.get('total'));

                        if (
                            initialVisitScheduledDate == null &&
                            funnelChartAndLeaderBoardStatusMap.get('conditionStatus1')
                                .contains(participantEnrolmentStatus)
                        ) {
                            contacted = contacted + total;
                        } else if (
                            initialVisitScheduledDate != null &&
                            initialVisitOccuredFlag == false &&
                            funnelChartAndLeaderBoardStatusMap.get('conditionStatus2')
                                .contains(participantEnrolmentStatus)
                        ) {
                            contacted = contacted + total;
                            scheduled = scheduled + total;
                        }
                        if (initialVisitOccuredFlag == true) {
                            if (
                                funnelChartAndLeaderBoardStatusMap.get('conditionStatus3')
                                    .contains(participantEnrolmentStatus)
                            ) {
                                contacted = contacted + total;
                                scheduled = scheduled + total;
                                initial_Visits_Completed = initial_Visits_Completed + total;
                            } else if (
                                funnelChartAndLeaderBoardStatusMap.get('conditionStatus4')
                                    .contains(participantEnrolmentStatus)
                            ) {
                                contacted = contacted + total;
                                scheduled = scheduled + total;
                                initial_Visits_Completed = initial_Visits_Completed + total;
                            } else if (
                                funnelChartAndLeaderBoardStatusMap.get('conditionStatus5')
                                    .contains(participantEnrolmentStatus)
                            ) {
                                contacted = contacted + total;
                                scheduled = scheduled + total;
                                screened = screened + total;
                                initial_Visits_Completed = initial_Visits_Completed + total;
                            }
                        }
                        if (
                            funnelChartAndLeaderBoardStatusMap.get('conditionStatus6')
                                .contains(participantEnrolmentStatus)
                        ) {
                            contacted = contacted + total;
                            scheduled = scheduled + total;
                            screened = screened + total;
                            enrolled_randomized = enrolled_randomized + total;
                            initial_Visits_Completed = initial_Visits_Completed + total;
                        } else if (
                            funnelChartAndLeaderBoardStatusMap.get('conditionStatus7')
                                .contains(participantEnrolmentStatus)
                        ) {
                            contacted = contacted + total;
                            scheduled = scheduled + total;
                            screened = screened + total;
                            initial_Visits_Completed = initial_Visits_Completed + total;
                        }
                    }
                }
                ssRankWrapperlist.add(
                    new SSRankWrapper(
                        site_Number,
                        site_Name,
                        location,
                        initial_Visits_Completed,
                        contacted,
                        scheduled,
                        screened,
                        enrolled_randomized,
                        is_enrolled_randomized,
                        piName,
                        pi_Id,
                        studyName
                    )
                );
            }
            ssRankWrapperlist.sort();
            return setRank(ssRankWrapperlist);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
}
