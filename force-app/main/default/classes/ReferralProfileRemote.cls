/**
 * Created by Leonid Bartenev
 * Modified by Pijush Kar on 4/22/2020
 * to accomodate the changes related to REF-1200
 */

public without sharing class ReferralProfileRemote {
    class InitData {
        ParticipantWorkflowService.ParticipantWorkflowWrapper steps;
        Participant_Enrollment__c enrollment;
        Participant__c participantDelegate;
        List<LabelValueItem> visitPlanLVList;
        public List<LabelValueItem> yearOfBirth;
        Map<String, PEStatusState> peStatusStateMap = PEStatusState.STATUSES_MAP;
        List<String> peStatusesPathList = PEStatusState.STATUS_STEPS_LIST;
        Boolean isEnrolled;
        Boolean isBulkImport;
        Boolean containsFile; //REF-2654
        Boolean isSiteEnabledforHAPI = false;
        User userInfo;
        Contact contactInfo; 
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
            initData.isBulkImport = false;
            //Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(peId, userMode, delegateId);
            Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(
                peId,
                userMode,
                delegateId,
                ViewPatientsRemote.PE_MY_PARTICIPANTS_FIELDS
            );
            Clinical_Trial_Profile__c ctp = StudyTrialService.getFullTrial(
                pe.Clinical_Trial_Profile__c
            );

             //START REF-2654
             String participantId = pe.Participant__c;
             Integer count= database.countQuery('Select count() from ContentDocumentLink where LinkedEntityId = :participantId');
             Boolean containsFile;
             if(count > 0)
             {
                 containsFile = true;
             }else
             {
                 containsFile = false;
             }
             initData.containsFile = containsFile;
             //END REF-2654
             List<Medical_Record_Vendor__c> medicalRecordVendors = MedicalRecordVendorPanelRemote.getVendors(pe.Study_Site__c);
             System.debug('$$$$$$$ medicalRecordVendors: ' + medicalRecordVendors);
             for (Medical_Record_Vendor__c item: medicalRecordVendors){
                 if(item.Medical_Vendor__c == 'HumanApi'){
                    initData.isSiteEnabledforHAPI = true;
                    break;
                 }
             }
            List<User> participantUsers = [
                SELECT Id, LanguageLocaleKey
                FROM User
                WHERE ContactId = :pe.Participant_Contact__c
            ];
            initData.userInfo = participantUsers.isEmpty() ? null : participantUsers[0];
            
             List<Contact> participantContacts = [
                SELECT Id, Language__c
                FROM contact
                WHERE id = :pe.Participant_Contact__c
             	];
        	initData.contactInfo = participantContacts.isEmpty() ? null : participantContacts[0];
            
            if (pe == null)
                throw new CommunityServiceException('Participant enrollment not found');
            initData.enrollment = pe;
            
            List<Patient_Delegate__c> lstPE = [SELECT Contact__c,Attestation__c FROM Patient_Delegate__c
                      							WHERE Participant__c =: pe.Participant__c 
                                               AND Primary_Delegate__c = TRUE];
            List<Participant__c> delegates = new List<Participant__c> ();
            if(!lstPE.isEmpty()){
          delegates = [
                SELECT Id, First_Name__c, Last_Name__c, Phone__c,Email__c,Contact__c,Birth_Year__c
              	,Attestation__c
                FROM Participant__c
                WHERE  Contact__c =: lstPE[0].Contact__c ];
          }
            system.debug('pe.Participant__c>>'+pe.Participant__c);
            if (!delegates.isEmpty()){
                initData.participantDelegate = delegates[0];
                if(delegates[0].Attestation__c == True && String.isBlank(delegates[0].Birth_Year__c))
                {
                    initData.isBulkImport = True;
                }
           }
            else {
                initData.participantDelegate  = new Participant__c(First_Name__c='',
                                                                  Last_Name__c='',
                                                                  Phone__c='',
                                                                  Email__c='');
            }  
            initData.visitPlanLVList = StudySiteService.getVisitPlansLVList(pe.Study_Site__c);
            if (initData.visitPlanLVList.size() == 1) {
                initData.enrollment.Visit_Plan__c = initData.visitPlanLVList[0].value;
            }
            // initData.steps = ParticipantWorkflowService.prepareParticipantWorkflow(ctp, pe);
            initData.yearOfBirth = ParticipantService.getYearofBirthList();
            initData.isEnrolled =
                !PEStatusState.STATUSES_MAP.containsKey(pe.Participant_Status__c) ||
                pe.Participant_Status__c.startsWith('Enrollment');
            return JSON.serialize(initData);
        } catch (Exception e) {
            System.debug('ERROR: ' + e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void updateParticipantData(String participantJSON, String perJSON) {
        update (Participant__c) JSON.deserialize(participantJSON, Participant__c.class);
        update (Participant_Enrollment__c) JSON.deserialize(
            perJSON,
            Participant_Enrollment__c.class
        );
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
        if (String.isEmpty(sourceStr))
            return sourceStr;
        Set<String> excludeWords = new Set<String>{ 'PI', 'HCP', 'Participant' };
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
    public static Participant_Enrollment__c setMRRStatus(
        String peJSON,
        String status,
        String surveyGizmoData
    ) {
        Participant_Enrollment__c participantEnrollment = (Participant_Enrollment__c) JSON.deserialize(
            peJSON,
            Participant_Enrollment__c.class
        );
        participantEnrollment.Medical_Record_Review_Completed_Date__c = Datetime.now();
        participantEnrollment.Medical_Record_Review_Status__c = status;
        participantEnrollment.MRR_Survey_Results_URL__c = surveyGizmoData;
        participantEnrollment.Medical_Record_Review_Completed_by__c = CommunityService.getUserContact()
            .Id;
        if (status == 'Pass') {
            participantEnrollment.Pre_screening_Status__c = 'Pass';
        } else {
            participantEnrollment.Pre_screening_Status__c = 'Fail';
        }
        IncentiveProgramService.completeIncentiveTaskCurrentContact(
            IncentiveTaskCatalog.INCENTIVE_TASK_PRE_SCREENING,
            participantEnrollment.Study_Site__c,
            participantEnrollment.Name
        );

        System.debug('PE: ' + JSON.serialize(participantEnrollment));
        if (participantEnrollment.Participant_Status__c == 'Received') {
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CreateUsersOrSendNotificationsHandler.class
            );
        }
        update participantEnrollment;
        return participantEnrollment;
    }

    @AuraEnabled
    public static void createUser(String peId, String pcId) {
        try {
            List<Participant_Enrollment__c> pe = [
                SELECT Id, Participant_Contact__c,Participant_Contact__r.Is_Patient_User_Created__c,
                Clinical_Trial_Profile__r.CommunityTemplate__c,Invited_To_PP_Date__c
                FROM Participant_Enrollment__c
                WHERE Id = :peId AND Participant_Contact__c = :pcId
            ];
            if (!pe.isEmpty() && pe[0].Invited_To_PP_Date__c == null) {
                pe[0].Invited_To_PP_Date__c = DateTime.now();
                update pe[0];
            }
            


            if (!pe.isEmpty()) {
                if(!pe[0].Participant_Contact__r.Is_Patient_User_Created__c){
                    ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                    .createPortalUsers(new Set<Id>{ pcId });
                }
                Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
                String permissionSetName = CommunityTemplateService.getTemplate(
                        pe[0].Clinical_Trial_Profile__r.CommunityTemplate__c
                    )
                    .permissionSet;
                actionAssignContactPermissions.addPermission(
                    pe[0].Participant_Contact__c,
                    permissionSetName
                );
                if (!actionAssignContactPermissions.isEmpty()) {
                    ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    /*
     * This method returns the delegate contact for the participant
     * along with ContactId of the User.
     * Written in accordance with REF-1200
     * @param peId Participant_Enrollment__c.Id in String
     * @param userMode in String
     * @param delegateId in String
     * @return Map<String, Object> with 'userContactId'
     *                             and 'participantDelegate' as key
     * @exception AuraHandledException to community UI
     * @see AuraHandledException
     */
    @AuraEnabled
    public static Map<String, Object> getDelegateAndContactId(
        String peId,
        String userMode,
        String delegateId
        
    ) {
        Map<String, Object> returnValue = new Map<String, Object>();
        try {
            returnValue.put('userContactId', getContactId());
            Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(
                peId,
                userMode,
                delegateId
            );
            List<Participant__c> delegates = [
                SELECT Id, First_Name__c, Last_Name__c, Phone__c
                FROM Participant__c
                WHERE
                    Contact__c IN (
                        SELECT Contact__c
                        FROM Patient_Delegate__c
                        WHERE
                        Participant__c = :pe.Participant__c
                        // AND Status__c = :PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS
                         AND Primary_Delegate__c = TRUE // as per REF-2298
                    )
            ];
            if (!delegates.isEmpty()) {
                returnValue.put('participantDelegate', delegates[0]);
            }
            return returnValue;
        } catch (Exception e) {
            return (Map<String, Object>) AuraHelper.throwException(e);
        }
    }
    @AuraEnabled
    public static String getAuthForm(Id peId){
        
        List<ContentDocument> entries = new List<ContentDocument>();
        
        List<ContentDocumentLink> cdls = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: peId];
        
        Set<Id> documentIds = new Set<Id>();
        if(cdls.size() > 0){
            for (ContentDocumentLink cdl : cdls) {
                documentIds.add(cdl.ContentDocumentId);
            }
            List<ContentDocument> documents = [SELECT Id, Title,ContentSize, CreatedDate, FileExtension, ContentModifiedDate FROM ContentDocument WHERE Id IN :documentIds 
                                               ORDER BY CreatedDate DESC LIMIT 1];
            String basefileUrl = URL.getSalesforceBaseUrl().toExternalForm();
            return JSON.serialize(new AuthFormWrapper(peId, documents, basefileUrl));
        }
        else{
            return null;
        }
    }

    public class AuthFormWrapper{
        @AuraEnabled public Id peId;
        @AuraEnabled public List<ContentDocument> attachments;
        @AuraEnabled public String baseURL;
        
        public AuthFormWrapper(Id peId, List<ContentDocument> attachments, String baseURL){
            this.peId = peId;
            this.attachments = attachments;
            this.baseURL = baseURL;
        }
    } 

}