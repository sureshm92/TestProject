/**
 * Created by Leonid Bartenev
 */

public without sharing class ReferralProfileRemote {

    class InitData {
        ParticipantWorkflowService.ParticipantWorkflowWrapper steps;
        Participant_Enrollment__c enrollment;
        List<LabelValueItem> visitPlanLVList;
        Map<String, PEStatusState> peStatusStateMap = PEStatusState.STATUSES_MAP;
        List<String> peStatusesPathList = PEStatusState.STATUS_STEPS_LIST;
        Boolean isEnrolled;
    }

    class StatusStep {
        String name;
        String state;
        Boolean isDisabled;
        String disableReason;
        Boolean isCurrent;
        Boolean isPassed;
        String nextState;
        String selectedStatus;
        String notes;
        List<LabelValueItem> statusReasonsList;
        List<ChangeStatusButton> buttonsList;
        List<HistoryItem> history;
    }

    class HistoryItem {
        String styleClass;
        Datetime changeDate;
        String message;
        String modifiedBy;
        HistoryItem(String styleClass, Datetime changeDate, String message, String modifiedBy) {
            this.styleClass = styleClass;
            this.changeDate = changeDate;
            this.message = message;
            this.modifiedBy = modifiedBy;
        }
    }

    public static Map<String, String> BTN_STYLE_MAP = new Map<String, String>{
            PEStatusState.STATUS_STATE_SUCCESS => 'green',
            PEStatusState.STATUS_STATE_IN_PROGRESS => 'orange',
            PEStatusState.STATUS_STATE_FAILURE => 'red'
    };

    public static final Map<String, String> BTN_LABELS_MAP = new Map<String, String>{
            PEStatusState.STATUS_STATE_SUCCESS => Label.BTN_Accept,
            PEStatusState.STATUS_STATE_IN_PROGRESS => Label.BTN_On_hold,
            PEStatusState.STATUS_STATE_FAILURE => Label.BTN_Decline
    };

    public class ChangeStatusButton {
        String name;
        String status;
        String style;
        Boolean isDisabled;

        public ChangeStatusButton(String state, String status) {
            this.status = status;
            this.isDisabled = false;
            this.style = BTN_STYLE_MAP.get(state);
            this.name = BTN_LABELS_MAP.get(state);
        }
        public ChangeStatusButton(String state, String status, Boolean isDisabled) {
            this.status = status;
            this.isDisabled = isDisabled;
            this.style = BTN_STYLE_MAP.get(state);
            this.name = BTN_LABELS_MAP.get(state);
        }
    }

    @AuraEnabled
    public static String getReferralProfileDetail(String peId, String userMode) {
        return getReferralProfileDetail(peId, userMode, null);
    }

    @AuraEnabled
    public static String getContactId() {
         return CommunityService.getInstance().getCurrentContactId();
    }

    @AuraEnabled
    public static String getReferralProfileDetail(String peId, String userMode, String delegateId) {
        try {
            InitData initData = new InitData();
            Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(peId, userMode, delegateId);
            Clinical_Trial_Profile__c ctp = StudyTrialService.getFullTrial(pe.Clinical_Trial_Profile__c);
            if (pe == null) throw new CommunityServiceException('Participant enrollment not found');
            initData.enrollment = pe;
            initData.visitPlanLVList = StudySiteService.getVisitPlansLVList(pe.Study_Site__c);
            initData.steps = ParticipantWorkflowService.prepareParticipantWorkflow(ctp, pe);
            initData.isEnrolled = !PEStatusState.STATUSES_MAP.containsKey(pe.Participant_Status__c) || pe.Participant_Status__c.startsWith('Enrollment');
            return JSON.serialize(initData);
        } catch (Exception e) {
            System.debug('ERROR: ' + e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void updateParticipantData(String participantJSON, String perJSON) {
        update (Participant__c) JSON.deserialize(participantJSON, Participant__c.class);
        update (Participant_Enrollment__c) JSON.deserialize(perJSON, Participant_Enrollment__c.class);
    }
    //deprecated
//    @AuraEnabled
//    public static String changePEStatus(Id peId, String newStatus, String notes, String userMode) {
//        try {
//            List<String> statusAndReason = newStatus.split(';');
//            String status = statusAndReason[0];
//            String reason;
//            if (statusAndReason.size() > 1) reason = statusAndReason[1];
//            Participant_Enrollment__c pe = new Participant_Enrollment__c(
//                    Id = peId,
//                    Participant_Status_Last_Changed_Date__c = Datetime.now(),
//                    Last_Status_Changed_Notes__c = notes,
//                    Participant_Status__c = status,
//                    Non_Enrollment_Reason__c = reason
//            );
//            upsert pe;
//            pe = ParticipantEnrollmentService.getParticipantEnrollment(peId, userMode);
//            return JSON.serialize(loadSteps(pe, userMode, null));
//        } catch (Exception e) {
//            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
//        }
//    }

    @AuraEnabled
    public static String changePEStatusByBtn(Id peId, String newStatus) {
        try {
            Participant_Enrollment__c pe = new Participant_Enrollment__c(
                    Id = peId,
                    Participant_Status_Last_Changed_Date__c = Datetime.now(),
                    Last_Status_Changed_Notes__c = null,
                    Participant_Status__c = newStatus,
                    Non_Enrollment_Reason__c = null
            );
            upsert pe;
            return JSON.serialize(pe);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String savePEScreeningId(Id peId, String newScreeningId) {
        try {
            Participant_Enrollment__c pe = new Participant_Enrollment__c(
                    Id = peId,
                    Screening_ID__c = newScreeningId
            );
            upsert pe;
            return JSON.serialize(pe);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    //deprecated
//    @AuraEnabled
//    public static String getPEStatusHistory(Id peId, String userMode, String delegateId) {
//        try {
//            Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(peId, userMode, delegateId);
//            List<StatusStep> steps = loadSteps(pe, userMode, delegateId);
//            Map<String, List<HistoryItem>> historyMap = new Map<String, List<HistoryItem>>();
//            for (StatusStep step : steps) {
//                historyMap.put(step.name, step.history);
//            }
//            return JSON.serialize(historyMap);
//        } catch (Exception e) {
//            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
//        }
//    }

    public static final Map<String, List<String>> REASONS_MAP = FieldDescribeUtil.getDependentOptionsImpl(
            Participant_Enrollment__c.Non_Enrollment_Reason__c,
            Participant_Enrollment__c.Participant_Status__c
    );
    //deprecated
//    private static List<StatusStep> loadSteps(Participant_Enrollment__c pe, String userMode, String delegateId) {
//        if (pe == null) return null;
//        StudyActions sActions;
//        if (userMode == CommunityService.USER_MODE_PI) {
//            sActions = new StudyActionsPI(pe);
//        } else if (userMode == CommunityService.USER_MODE_HCP) {
//            sActions = new StudyActionsHCP(pe, delegateId);
//        }
//        Integer i = 1;
//        PEStatusState currentState = PEStatusState.STATUSES_MAP.get(pe.Participant_Status__c);
//        if (!PEStatusState.STATUSES_MAP.containsKey(pe.Participant_Status__c)) {
//            currentState = PEStatusState.STATUSES_MAP.get(PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS);
//        }
//        List<StatusStep> steps = new List<StatusStep>();
//        for (String stepName : PEStatusState.STATUS_STEPS_LIST) {
//            PEStatusState.StatusStep step = PEStatusState.STATUS_STEPS_MAP.get(stepName);
//            StatusStep ss = new StatusStep();
//            ss.name = stepName;
//            ss.history = new List<HistoryItem>();
//            if (i < currentState.order) {
//                ss.state = PEStatusState.STATUS_STATE_SUCCESS;
//            } else if (i == currentState.order) {
//                ss.state = currentState.state;
//            } else {
//                ss.state = 'neutral';
//            }
//            ss.isPassed = i == 1 || i < currentState.order || (i == PEStatusState.STATUS_STEPS_LIST.size() && i == currentState.order);
//            if (currentState.state != PEStatusState.STATUS_STATE_SUCCESS) {
//                ss.isDisabled = i > currentState.order;
//                ss.isCurrent = i == currentState.order;
//            } else {
//                ss.isDisabled = i > currentState.order + 1;
//                ss.isCurrent = i == currentState.order + 1;
//            }
//            if (userMode == CommunityService.USER_MODE_HCP || userMode == CommunityService.USER_MODE_PI) {
//                StudyActions.Action changePEStatusByPIAction = sActions.actions.get(StudyActions.ACT_CHANGE_PE_STATUS_BY_PI);
//
//                if (changePEStatusByPIAction != null) {
//                    ss.isDisabled = ss.isDisabled || changePEStatusByPIAction.disabled;
//                    ss.disableReason = changePEStatusByPIAction.disableReason;
//                }
//                if (i == 2 && sActions.studyAccessLevel == DelegateService.DELEGATE_LEVEL_3) {
//                    ss.isDisabled = true;
//                    ss.disableReason = StudyActions.REASON_LABEL_ACTION_NOT_ALLOWED_ON_ACCESS_LEVEL;
//                }
//            }

            //disable step for delegate level - support
            //init buttons (only for step 2):
//            String step2State;
//            if (i == 2) {
//                if(currentState.order == 2) step2State = currentState.state;
//                ss.buttonsList = createButtonsList(step2State, disableActions);
//            }
            //init select lists
//            ss.statusReasonsList = new List<LabelValueItem>();
//            ss.statusReasonsList.add(new LabelValueItem(Label.PG_RP_L_Not_selected, null));
//            for (String state : step.states.keySet()) {
//                String status = step.states.get(state);
//                List<String> dependedReasons = REASONS_MAP.get(status);
//                if (dependedReasons == null || dependedReasons.size() == 0) {
//                    ss.statusReasonsList.add(new LabelValueItem(TranslateHelper.getPickListLabel(Participant_Enrollment__c.Participant_Status__c, status), status));
//                } else {
//                    for (String reason : dependedReasons) {
//                        ss.statusReasonsList.add(new LabelValueItem(TranslateHelper.getPickListLabel(Participant_Enrollment__c.Participant_Status__c, status)
//                                + ' - ' + TranslateHelper.getPickListLabel(Participant_Enrollment__c.Non_Enrollment_Reason__c, reason),
//                                status + ';' + reason));
//                    }
//                }
//            }
//            steps.add(ss);
//            if (i > 1) steps[i - 2].nextState = steps[i - 1].state;
//            i++;
//        }
//        List<Participant_Enrollment_Status_History__c> historyList = [
//                SELECT Id, Notes__c, Status__c, Reason__c, Date__c, LastModifiedBy.Profile.Name, LastModifiedBy.Name
//                FROM Participant_Enrollment_Status_History__c
//                WHERE ParticipantEnrollment__c = :pe.Id
//                ORDER BY CreatedDate DESC
//        ];
//        for (Participant_Enrollment_Status_History__c hi : historyList) {
//            PEStatusState state = PEStatusState.STATUSES_MAP.get(hi.Status__c);
//            if (state != null && steps != null && state.order > 0) {
//                steps[state.order - 1].history.add(new HistoryItem(
//                        BTN_STYLE_MAP.get(state.state),
//                        hi.Date__c,
//                        TranslateHelper.getPickListLabel(Participant_Enrollment__c.Participant_Status__c, hi.Status__c) +
//                                (hi.Reason__c != null ? ' - ' + TranslateHelper.getPickListLabel(Participant_Enrollment__c.Non_Enrollment_Reason__c, hi.Reason__c) : '') +
//                                (hi.Notes__c != null && userMode == CommunityService.USER_MODE_PI ? ':  ' + hi.Notes__c : ''),
//                        (hi.LastModifiedBy.Profile.Name == 'System Administrator' || hi.LastModifiedBy.Profile.Name == 'IQVIA SPNL') ? System.Label.Admin_Label : hi.LastModifiedBy.Name
//                ));
//            }
//        }
//        return steps;
//    }
//deprecated
//    public static List<ChangeStatusButton> createButtonsList(String currentState, Boolean isDisabled) {
//        //buttons used only for step 2
//        List<ChangeStatusButton> buttonsList = new List<ChangeStatusButton>();
//        for (String state : PEStatusState.STATUS_STATE_LIST) {
//            String status = PEStatusState.STATUS_STEPS_TABLE[1].states.get(state);
//            if (state != currentState) buttonsList.add(
//                    new ChangeStatusButton(state, status, isDisabled)
//            );
//        }
//        return buttonsList;
//    }
//
//    public static List<ChangeStatusButton> createButtonsList(String currentState) {
//        return createButtonsList(currentState, false);
//    }

    public static String toSentenceFont(String sourceStr) {
        if (String.isEmpty(sourceStr)) return sourceStr;
        Set<String> excludeWords = new Set<String>{
                'PI', 'HCP', 'Participant'
        };
        List<String> words = sourceStr.split(' ');
        List<String> processedWords = new List<String>();
        for (String word : words) {
            if (!excludeWords.contains(word)) {
                word = word.toLowerCase();
            }
            processedWords.add(word);
        }
        processedWords[0] = processedWords[0].capitalize();
        return String.join(processedWords, ' ');
    }
    @AuraEnabled
    public static Participant_Enrollment__c setMRRStatus(String peJSON, String status, String surveyGizmoData) {
        Participant_Enrollment__c participantEnrollment = (Participant_Enrollment__c) JSON.deserialize(peJSON, Participant_Enrollment__c.class);
        participantEnrollment.Medical_Record_Review_Status__c = status;
        participantEnrollment.MRR_Survey_Results_URL__c = surveyGizmoData;
        participantEnrollment.Medical_Record_Review_Completed_by__c = CommunityService.getUserContact().Id;
        if (status == 'Pass') {
            participantEnrollment.Pre_screening_Status__c = 'Pass';
        } else {
            participantEnrollment.Pre_screening_Status__c = 'Fail';
        }

        System.debug('PE: ' + JSON.serialize(participantEnrollment));
        update participantEnrollment;
        return participantEnrollment;
    }
    @AuraEnabled
    public static void createUser(String peId) {
        try {
            ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createPortalUsers(new Set<Id>{
                    peId
            });
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String updateParticipantStatus(String stepWrapperJSON, String peId) {
        try {
            ParticipantWorkflowService.ParticipantWorkflowStepWrapper stepWrapper =
                    (ParticipantWorkflowService.ParticipantWorkflowStepWrapper)JSON.deserialize(stepWrapperJSON, ParticipantWorkflowService.ParticipantWorkflowStepWrapper.class);

            if(stepWrapper.outcome!= null && stepWrapper.outcome!=''){
                Participant_Enrollment_Status_History__c pesh = new Participant_Enrollment_Status_History__c(
                        Status__c = stepWrapper.outcome,
                        Reason__c = stepWrapper.reason,
                        Notes__c = stepWrapper.notes,
                        Date__c = Datetime.now(),
                        ParticipantEnrollment__c = peId
                ) ;
                insert pesh;
            }
            Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(peId, CommunityService.USER_MODE_PI);
            if(!stepWrapper.formFieldGroups.isEmpty()){
                for(ParticipantWorkflowService.ParticipantWorkflowFieldGroupWrapper fieldGroup: stepWrapper.formFieldGroups) {
                    for (ParticipantWorkflowService.ParticipantWorkflowFieldWrapper field: fieldGroup.fields){
                        if( field.readonly || field.value == null || field.value == ''){
                            continue;
                        }
                        switch on field.fieldType{
                            when 'visitplan','text'{
                                pe.put(field.field, field.value);
                            }
                            when 'time' {
                                List<String> strTimeSplit = field.value.split(':');
                                pe.put(field.field, Time.newInstance( Integer.valueOf(strTimeSplit[0]) ,Integer.valueOf(strTimeSplit[1]),0,0));
                            }
                            when 'date' {
                                System.debug(field.value);
                                pe.put(field.field, Date.valueOf(field.value));
                            }
                            when 'boolean' {
                                pe.put(field.field, Boolean.valueOf(field.value));
                            }
                        }
                    }
                }
                update pe;
            }
            pe = ParticipantEnrollmentService.getParticipantEnrollment(peId, CommunityService.USER_MODE_PI);
            Clinical_Trial_Profile__c ctp = StudyTrialService.getFullTrial(pe.Clinical_Trial_Profile__c);
            if (pe == null) throw new CommunityServiceException('Participant enrollment not found');
            return JSON.serialize(ParticipantWorkflowService.prepareParticipantWorkflow(ctp, pe));
        } catch (Exception e) {
            System.debug('ERROR: ' + e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
}