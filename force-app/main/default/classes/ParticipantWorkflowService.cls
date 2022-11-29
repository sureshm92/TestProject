/**
 * Created by Andrii Kryvolap.
 */

public without sharing class ParticipantWorkflowService {
    public static final String PARTICIPANT_ENROLLMENT_SOBJECT_ALIAS = 'pe';
    public static final String PARTICIPANT_ENROLLMENT_STATUS_HISTORY_SOBJECT_ALIAS = 'pesh';
    public static final String CLINICAL_TRIAL_PROFILE_SOBJECT_ALIAS = 'ctp';
    public static final List<Participant_Workflow_Step__mdt> Participant_Workflow_Step = [SELECT
                                                                                            Id,
                                                                                            DeveloperName,
                                                                                            Condition__c,
                                                                                            Name_Label__c,
                                                                                            Order__c,
                                                                                            History_Label__c,
                                                                                            Card_Name_Label__c,
                                                                                            No_Outcome_Label__c,
                                                                                            Failed_State_Editing_Enabled__c,
                                                                                            Outcome_Placeholder_Label__c,
                                                                                            History_Item_Title_Template_Label__c,
                                                                                            History_Item_Details_Template_Label__c,
                                                                                            Form_Fields__c,
                                                                                            In_Progress_Condition__c,
                                                                                            Additional_Notes_For_Statuses__c,
                                                                                            Success_Condition__c,
                                                                                            Success_Date_Field__c,
                                                                                            In_Progress_Date_Field__c,
                                                                                            Success_Checkbox_Field__c
                                                                                            FROM Participant_Workflow_Step__mdt
                                                                                            ORDER BY Order__c ASC];

    @AuraEnabled
    public static ParticipantWorkflowWrapper prepareParticipantWorkflowHelper(
        String peId,
        String userMode,
        String delegateId
    ) {
        try {
            Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(
                peId,
                userMode,
                delegateId,
                ViewPatientsRemote.PE_MY_PARTICIPANTS_FIELDS
            );
            Clinical_Trial_Profile__c ctp = StudyTrialService.getFullTrial(
                pe.Clinical_Trial_Profile__c
            );
            ParticipantWorkflowWrapper partWFwrap = new ParticipantWorkflowWrapper();
            partWFwrap = ParticipantWorkflowService.prepareParticipantWorkflow(ctp, pe);
            
         /**   if(peId !=null && peId!=''){
                List<Participant_Enrollment__History> peh = new List<Participant_Enrollment__History>();
                List<Participant_Enrollment__History> pehstinitial = new List<Participant_Enrollment__History>();
                List<String> lstFOVhistory = new List<String>();
                lstFOVhistory.add('Initial_visit_scheduled_date__c');
                lstFOVhistory.add('Initial_visit_scheduled_time__c');
                List<Participant_Enrollment__c> partenroll = new List<Participant_Enrollment__c>();
                peh =[SELECT CreatedById,CreatedDate,CreatedBy.Name,Field,NewValue,OldValue,ParentId FROM Participant_Enrollment__History WHERE ParentId =:peId AND Field IN:lstFOVhistory];
                List<String> cby = new List<String>();
                List<Datetime> cd = new List<Datetime>();
                 
                List<User> ValidUserList = new  List<User>();
                List<Id> ApiUsrList = new List<Id>();
                ValidUserList = [SELECT Id FROM User where Profile.Name = 'API Only'];
                if(ValidUserList.size() != 0 && !ValidUserList.isEmpty() && ValidUserList != null) 
                {
                   for(User us:ValidUserList){
                      ApiUsrList.add(us.id);
                   }
                  
                }
                
                if(peh.size() != 0 && !peh.isEmpty() && peh != null) 
                {
                 
                  List<Datetime> lstDuphistory = new List<Datetime>();
                  Set<Id> lstusr = new Set<Id>();
                  List<User> lstusrRecord = new List<User>();
                  Map<Id,String> mapUsrmsk = new Map<Id,String>();
                  for(Participant_Enrollment__History phusrid:peh){
                      lstusr.add(phusrid.CreatedById);
                  }
                  lstusrRecord = [select id,Name,IsPortalEnabled,ContactId,Contact.userCommunityMode__c from User where id IN:lstusr];
                  for(User u:lstusrRecord ){
                     if(ApiUsrList.size() != 0 && !ApiUsrList.isEmpty() && ApiUsrList != null){
                         if(ApiUsrList.contains(u.id)){
                             mapUsrmsk.put(u.id,System.Label.chatbot);
                         }else if(u.IsPortalEnabled){
                              if(u.ContactId != null && u.Contact.userCommunityMode__c == 'CC'){
                                mapUsrmsk.put(u.id,System.Label.RH_Masked_IQVIA_User);
                              }else{
                                mapUsrmsk.put(u.id,u.Name);
                             }
                         }else{
                             mapUsrmsk.put(u.id,System.Label.RH_Masked_IQVIA_User);
                         }
                     }else{
                        if(u.IsPortalEnabled){
                              if(u.ContactId != null && u.Contact.userCommunityMode__c == 'CC'){
                                mapUsrmsk.put(u.id,System.Label.RH_Masked_IQVIA_User);
                              }else{
                                mapUsrmsk.put(u.id,u.Name);
                             }
                       }else{
                             mapUsrmsk.put(u.id,System.Label.RH_Masked_IQVIA_User);
                         }
                     
                    }
                     
                  }
                  for(Participant_Enrollment__History ph:peh){
                      if(!lstDuphistory.contains(ph.CreatedDate)){
                          cby.add(mapUsrmsk.get(ph.CreatedById));
                          cd.add(ph.CreatedDate);
                          lstDuphistory.add(ph.CreatedDate);
                      }
                  }
                  Boolean onRecordcreation =false;
                  pehstinitial =[SELECT CreatedById,CreatedDate,CreatedBy.Name,Field,NewValue,OldValue,ParentId FROM Participant_Enrollment__History WHERE ParentId =:peId AND Field IN:lstFOVhistory ORDER BY CreatedDate ASC LIMIT 1];
                   for(Participant_Enrollment__History phOld:pehstinitial){
                          if(phOld.OldValue != NULL){
                             onRecordcreation =true;
                          } 
                  }
                  if(onRecordcreation){
                      Participant_Enrollment__c penrollmnt = [select id,Initial_visit_scheduled_date__c,Initial_visit_scheduled_time__c,CreatedDate,CreatedById,CreatedBy.IsPortalEnabled,CreatedBy.contact.userCommunityMode__c,CreatedBy.Name,CreatedBy.ContactId from Participant_Enrollment__c where id =:peId ];
                       
                       if(ApiUsrList.size() != 0 && !ApiUsrList.isEmpty() && ApiUsrList != null){
                         if(ApiUsrList.contains(penrollmnt.CreatedById)){
                                cby.add(System.Label.chatbot);
                                cd.add(penrollmnt.CreatedDate);
                         }else if(penrollmnt.CreatedBy.IsPortalEnabled){
                              if(penrollmnt.CreatedBy.contact != null && penrollmnt.CreatedBy.Contact.userCommunityMode__c == 'CC'){ 
                                cby.add(System.Label.RH_Masked_IQVIA_User);
                                cd.add(penrollmnt.CreatedDate);
                              }else{ 
                                cby.add(penrollmnt.CreatedBy.Name);
                                cd.add(penrollmnt.CreatedDate);
                             }
                         }else{
                              cby.add(System.Label.RH_Masked_IQVIA_User);
                              cd.add(penrollmnt.CreatedDate);
                         } 
                       }else{
                          if(penrollmnt.CreatedBy.IsPortalEnabled){
                              if(penrollmnt.CreatedBy.contact != null && penrollmnt.CreatedBy.Contact.userCommunityMode__c == 'CC'){ 
                                cby.add(System.Label.RH_Masked_IQVIA_User);
                                cd.add(penrollmnt.CreatedDate);
                              }else{ 
                                cby.add(penrollmnt.CreatedBy.Name);
                                cd.add(penrollmnt.CreatedDate);
                             }
                         }else{
                              cby.add(System.Label.RH_Masked_IQVIA_User);
                              cd.add(penrollmnt.CreatedDate);
                         } 
                       
                       }
                  }
                  
                  partWFwrap.fovCreatedby=cby;
                  partWFwrap.fovCreateddate=cd;
                  partWFwrap.fovhistory='notnull';
                }else{
                   partenroll = [select id,Initial_visit_scheduled_date__c,Initial_visit_scheduled_time__c,CreatedDate,CreatedById,CreatedBy.IsPortalEnabled,CreatedBy.contact.userCommunityMode__c,CreatedBy.Name,CreatedBy.ContactId from Participant_Enrollment__c where id =:peId AND (Initial_visit_scheduled_date__c!=NULL OR Initial_visit_scheduled_time__c !=NULL)];
                   if(partenroll.size() != 0 && !partenroll.isEmpty() && partenroll != null){
                        
                       for(Participant_Enrollment__c per:partenroll){
                         
                         if(ApiUsrList.size() != 0 && !ApiUsrList.isEmpty() && ApiUsrList != null){
                             if(ApiUsrList.contains(per.CreatedById)){
                                    cby.add(System.Label.chatbot);
                                    cd.add(per.CreatedDate);
                             }else if(per.CreatedBy.IsPortalEnabled){
                                  if(per.CreatedBy.contact != null && per.CreatedBy.Contact.userCommunityMode__c == 'CC'){ 
                                    cby.add(System.Label.RH_Masked_IQVIA_User);
                                    cd.add(per.CreatedDate);
                                  }else{ 
                                    cby.add(per.CreatedBy.Name);
                                    cd.add(per.CreatedDate);
                                 }
                             }else{
                                  cby.add(System.Label.RH_Masked_IQVIA_User);
                                  cd.add(per.CreatedDate);
                             }
                         }else{
                             if(per.CreatedBy.IsPortalEnabled){
                                  if(per.CreatedBy.contact != null && per.CreatedBy.Contact.userCommunityMode__c == 'CC'){ 
                                    cby.add(System.Label.RH_Masked_IQVIA_User);
                                    cd.add(per.CreatedDate);
                                  }else{ 
                                    cby.add(per.CreatedBy.Name);
                                    cd.add(per.CreatedDate);
                                 }
                             }else{
                                  cby.add(System.Label.RH_Masked_IQVIA_User);
                                  cd.add(per.CreatedDate);
                             }
                         
                         }
                      }
                      partWFwrap.fovCreatedby=cby;
                      partWFwrap.fovCreateddate=cd;
                      partWFwrap.fovhistory='notnull';
                       
                   }else{
                      partWFwrap.fovhistory='null';
                   }
                   
                }
            }else{
                  partWFwrap.fovhistory='null';
                } **/
            
            return partWFwrap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static ParticipantWorkflowWrapper prepareParticipantWorkflow(
        Clinical_Trial_Profile__c ctp,
        Participant_Enrollment__c pe
    ) {
        ParticipantWorkflowWrapper wrapper = new ParticipantWorkflowWrapper();
        wrapper.steps = new List<ParticipantWorkflowService.ParticipantWorkflowStepWrapper>();
        Map<String, String> stepsAndStates = new Map<String, String>();
        //List<Participant_Workflow_Step__mdt> steps = getWorkflowStepsAndStates(ctp, stepsAndStates);
        List<Participant_Workflow_Step__mdt> steps = getWorkflowSteps(ctp);
        Map<String, List<Participant_Enrollment_Status_History__c>> stepsAndStatuses = new Map<String, List<Participant_Enrollment_Status_History__c>>();
        List<Participant_Enrollment_Status_History__c> peshistories = [
            SELECT
                Id,
                Date__c,
                Status__c,
                Non_Enrollment_Reason__c,
                Notes__c,
                CreatedBy.Name,
                Additional_Notes__c,
                ParticipantEnrollment__r.Referral_Source__c,
                ParticipantEnrollment__r.Referral_Completedby_Name__c,
                ParticipantEnrollment__r.Source_Type__c,
                ParticipantEnrollment__r.PI_Contact__r.Name,
                CreatedBy.IsPortalEnabled,
                CreatedBy.contact.userCommunityMode__c,Backward_Bulk_Update__c
            FROM Participant_Enrollment_Status_History__c
            WHERE ParticipantEnrollment__c = :pe.Id and Backward_Bulk_Update__c=false and Disabled_PESH__c=false    
            ORDER BY Date__c DESC
        ];
        Map<String, List<Participant_Enrollment_Status_History__c>> stepsAndPesh = new Map<String, List<Participant_Enrollment_Status_History__c>>();
        for (Participant_Workflow_Step__mdt step : steps) {
            stepsAndStates.put(step.DeveloperName, step.Additional_Notes_For_Statuses__c);
        }
        Boolean eligibilityStatusPresent = false;
        for (String step : stepsAndStates.keySet()) {
            for (Participant_Enrollment_Status_History__c pesh : peshistories) {
                if(pesh.Status__c == 'Eligibility Passed'){
                    wrapper.sendToSHDate = (pesh.Date__c!=null)?Date.valueOf(pesh.Date__c):null;
                    wrapper.sendToSHReason = pesh.Non_Enrollment_Reason__c;
                    eligibilityStatusPresent = true;
                }
                if (
                    stepsAndStates.get(step) != null &&
                    stepsAndStates.get(step) != '' &&
                    stepsAndStates.get(step).contains(';' + pesh.Status__c + ';')
                ) {
                    if (stepsAndPesh.containsKey(step)) {
                        List<Participant_Enrollment_Status_History__c> peshs = stepsAndPesh.get(
                            step
                        );
                        if (peshs == null || peshs.isEmpty()) {
                            peshs = new List<Participant_Enrollment_Status_History__c>{ pesh };
                        } else {
                            peshs.add(pesh);
                        }
                    } else {
                        List<Participant_Enrollment_Status_History__c> peshs = new List<Participant_Enrollment_Status_History__c>{
                            pesh
                        };
                        stepsAndPesh.put(step, peshs);
                    }
                }
            }
        }
        wrapper.sendToSH = sendToSH(wrapper, pe, eligibilityStatusPresent);
        Map<String, Map<String, Participant_Workflow_Outcome__mdt>> outcomesMap = getOutcomesMap(
            steps,
            ctp
        );
        Map<String, List<Participant_Enrollment_Status_History__c>> peshMapByStep = getPESHByStep(
            pe,
            outcomesMap,
            peshistories
        );
        Map<String, Participant_Workflow_Form_Field__mdt> fieldsMap = getFieldsMap(ctp, pe);
        Map<String, ParticipantWorkflowFieldWrapper> fieldWrappersMap = new Map<String, ParticipantWorkflowService.ParticipantWorkflowFieldWrapper>();
        Boolean previousStepSuccess = false;
        Integer currentStepInd = 0;
        Boolean nonNeutralStepFound = false;
        for (Integer i = 0; i < steps.size(); i++) {
            Participant_Workflow_Step__mdt step = steps[i];
            Participant_Workflow_Step__mdt previousStep;
            Participant_Workflow_Step__mdt nextStep;
            if (i > 0) {
                previousStep = steps[i - 1];
            }
            if (i < steps.size() - 1) {
                nextStep = steps[i + 1];
            }
            ParticipantWorkflowStepWrapper stepWrapper = createStepWrapper(
                step,
                outcomesMap,
                peshMapByStep,
                previousStepSuccess,
                fieldsMap,
                pe,
                ctp,
                fieldWrappersMap,
                previousStep,
                nextStep,
                stepsAndPesh,
                wrapper.sendToSHDate
            );
            
            previousStepSuccess = stepWrapper.state == PEStatusState.STATUS_STATE_SUCCESS;
           
            if (
                stepWrapper.state == PEStatusState.STATUS_STATE_SUCCESS ||
                stepWrapper.state == PEStatusState.STATUS_STATE_IN_PROGRESS ||
                stepWrapper.state == PEStatusState.STATUS_STATE_FAILURE
            ) {
                nonNeutralStepFound = true;
                wrapper.currentStepInd = currentStepInd;
                if (!wrapper.steps.isEmpty()) {
                    wrapper.steps[wrapper.steps.size() - 1].editable = false;
                }
                }
               
            wrapper.steps.add(stepWrapper);
            currentStepInd++;
        }
        if (!nonNeutralStepFound) {
            wrapper.currentStepInd = wrapper.steps.size() - 1;
        }
        
        wrapper.steps[wrapper.currentStepInd].isCurrentStep = true;
        populateDependencyActiveFields(wrapper, fieldWrappersMap);
        return wrapper;
    }

    private static Boolean sendToSH(ParticipantWorkflowWrapper wrapper, Participant_Enrollment__c pe, Boolean eligibilityStatusPresent){
        List<String> pshStatus = new List<String>();
        for (Promote_to_SH__mdt psl : [SELECT DeveloperName, status__c FROM Promote_to_SH__mdt]) {
            pshStatus.add(psl.status__c);
        }
        return ListViewParticipantController.ifAllowedForSH(pe, pshStatus, eligibilityStatusPresent);
                    
    }

    private static List<Participant_Workflow_Step__mdt> getWorkflowSteps(
        Clinical_Trial_Profile__c ctp
    ) {
        List<Participant_Workflow_Step__mdt> eligibleSteps = new List<Participant_Workflow_Step__mdt>();
        for (Participant_Workflow_Step__mdt step : Participant_Workflow_Step) {
            if (
                String.isBlank(step.Condition__c) ||
                ConditionCheckerService.checkConditionForObject(step.Condition__c, ctp)
            ) {
                eligibleSteps.add(step);
            }
        }
        return eligibleSteps;
    }

    private static List<Participant_Workflow_Step__mdt> getWorkflowStepsAndStates(
        Clinical_Trial_Profile__c ctp,
        Map<String, String> stepsAndStates
    ) {
        List<Participant_Workflow_Step__mdt> eligibleSteps = new List<Participant_Workflow_Step__mdt>();
        for (Participant_Workflow_Step__mdt step : Participant_Workflow_Step) {
            if (
                String.isBlank(step.Condition__c) ||
                ConditionCheckerService.checkConditionForObject(step.Condition__c, ctp)
            ) {
                eligibleSteps.add(step);
                stepsAndStates.put(step.DeveloperName, step.Additional_Notes_For_Statuses__c);
            }
        }
        return eligibleSteps;
    }

    private static Map<String, Map<String, Participant_Workflow_Outcome__mdt>> getOutcomesMap(
        List<Participant_Workflow_Step__mdt> workflowSteps,
        Clinical_Trial_Profile__c ctp
    ) {
        String UserMode = UserContext.getCurrentUserMode().userMode;
        Set<String> stepNames = new Set<String>();
        for (Participant_Workflow_Step__mdt step : workflowSteps) {
            stepNames.add(step.DeveloperName);
        }
        Map<String, Map<String, Participant_Workflow_Outcome__mdt>> result = new Map<String, Map<String, Participant_Workflow_Outcome__mdt>>();
        

        List<Participant_Workflow_Outcome__mdt> participantOutcomeList = new List<Participant_Workflow_Outcome__mdt>();
        if(UserMode == 'HCP'){
        participantOutcomeList = [
            SELECT
                Id,
                Status_Name__c,
                Step__c,
                Reasons_List__c,
                State__c,
                Order__c,
                Show_Only_If_Selected__c,
                Readonly_if_Current__c,
                Disclaimer_if_Current__c,
                Condition_for_Auto_Update__c,
                Suppress_Multiple__c,
                Condition__c
            FROM Participant_Workflow_Outcome__mdt
            WHERE Step__c IN :stepNames
            ORDER BY Order__c ASC
        ]; 
        }
        else{
           participantOutcomeList = [
            SELECT
                Id,
                Status_Name__c,
                Step__c,
                Reasons_List__c,
                State__c,
                Order__c,
                Show_Only_If_Selected__c,
                Readonly_if_Current__c,
                Disclaimer_if_Current__c,
                Condition_for_Auto_Update__c,
                Suppress_Multiple__c,
                Condition__c
            FROM Participant_Workflow_Outcome__mdt
            WHERE Step__c IN :stepNames 
            AND Status_Name__c != 'Participant No Show'
            ORDER BY Order__c ASC
        ];
        }
        
        for(Participant_Workflow_Outcome__mdt outcome : participantOutcomeList){
            if (!result.containsKey(outcome.Status_Name__c)) {
                result.put(
                    outcome.Status_Name__c,
                    new Map<String, Participant_Workflow_Outcome__mdt>()
                );
            }
            if (
                String.isBlank(outcome.Condition__c) ||
                ctp == null ||
                ConditionCheckerService.checkConditionForObject(outcome.Condition__c, ctp)
            ) {
                result.get(outcome.Status_Name__c).put(outcome.Step__c, outcome);
            }
        }
        return result;
    }

    private static Map<String, List<Participant_Enrollment_Status_History__c>> getPESHByStep(
        Participant_Enrollment__c pe,
        Map<String, Map<String, Participant_Workflow_Outcome__mdt>> outcomesMap,
        List<Participant_Enrollment_Status_History__c> peshs
    ) {
        Map<String, List<Participant_Enrollment_Status_History__c>> result = new Map<String, List<Participant_Enrollment_Status_History__c>>();
        for (Participant_Enrollment_Status_History__c pesh : peshs) {
            if (outcomesMap.containsKey(pesh.Status__c)) {
                for (String stepName : outcomesMap.get(pesh.Status__c).keySet()) {
                    if (!result.containsKey(stepName)) {
                        result.put(stepName, new List<Participant_Enrollment_Status_History__c>());
                    }
                    result.get(stepName).add(pesh);
                }
            }
        }
        return result;
    }

    private static ParticipantWorkflowStepWrapper createStepWrapper(
        Participant_Workflow_Step__mdt step,
        Map<String, Map<String, Participant_Workflow_Outcome__mdt>> outcomesMap,
        Map<String, List<Participant_Enrollment_Status_History__c>> peshMap,
        Boolean previousStepSuccess,
        Map<String, Participant_Workflow_Form_Field__mdt> fieldsMap,
        Participant_Enrollment__c pe,
        Clinical_Trial_Profile__c ctp,
        Map<String, ParticipantWorkflowFieldWrapper> fieldWrappersMap,
        Participant_Workflow_Step__mdt previousStep,
        Participant_Workflow_Step__mdt nextStep,
        Map<String, List<Participant_Enrollment_Status_History__c>> stepsAndPesh,
        Date sendToSHDate
    ) {
        ParticipantWorkflowStepWrapper stepWrapper = new ParticipantWorkflowStepWrapper();
        stepWrapper.title = TranslateHelper.getLabelValue(step.Name_Label__c);
        
        //REF-4546
        stepWrapper.stepName = step.DeveloperName;
        if(stepWrapper.stepName == 'Contact'){
            List<Participant_Enrollment_Status_History__c> pehistory = [SELECT
                Id,
                Date__c,
                Status__c,
                Non_Enrollment_Reason__c,
                Notes__c,
                CreatedBy.Name,
                Additional_Notes__c,
                ParticipantEnrollment__r.Referral_Source__c,
                ParticipantEnrollment__r.Referral_Completedby_Name__c,
                ParticipantEnrollment__r.Source_Type__c,
                ParticipantEnrollment__r.PI_Contact__r.Name,
                CreatedBy.IsPortalEnabled,
                CreatedBy.contact.userCommunityMode__c,Backward_Bulk_Update__c
            FROM Participant_Enrollment_Status_History__c
            WHERE ParticipantEnrollment__c = :pe.Id and Backward_Bulk_Update__c=true
            ORDER BY Date__c DESC];
            
            if(!pehistory.isEmpty()){
            for(Participant_Enrollment_Status_History__c per: pehistory){
                ParticipantWorkflowHistoryWrapper historyWrapper = createHistoryWrapper(per, step, pe);
                if(per.Additional_Notes__c != null && per.Additional_Notes__c != ''){
                    if (
                        per.Additional_Notes__c.contains('####')
                    ) {
                        String addNotes = per.Additional_Notes__c.substringBefore('####');
                        stepWrapper.historyList.addAll(createOnlyNotesHistoryWrapper(addNotes));
                    } else {
                        stepWrapper.historyList.addAll(
                            createOnlyNotesHistoryWrapper(per.Additional_Notes__c)
                        );
                    }
                }
                
                    stepWrapper.historyList.add(historyWrapper);
                
            }
            }
        }
        //
        stepWrapper.cardTitle = TranslateHelper.getLabelValue(step.Card_Name_Label__c);
        stepWrapper.historyTitle = TranslateHelper.getLabelValue(step.History_Label__c);
        stepWrapper.outcomePlaceholder = String.isBlank(step.Outcome_Placeholder_Label__c)
            ? TranslateHelper.getLabelValue('PG_RP_L_Not_selected')
            : TranslateHelper.getLabelValue(step.Outcome_Placeholder_Label__c);
        stepWrapper.reason = TranslateHelper.getPickListLabel(
            Participant_Enrollment__c.Non_Enrollment_Reason__c,
            pe.Non_Enrollment_Reason__c
        );
        stepWrapper.stepHistory = new List<ParticipantWorkflowService.ParticipantWorkflowHistoryWrapper>();
        
        if (peshMap.containsKey(step.DeveloperName)) {
            List<Participant_Enrollment_Status_History__c> peshList = peshMap.get(
                step.DeveloperName
            );
            stepWrapper.state = outcomesMap.get(peshList[0].Status__c)
                .get(step.DeveloperName)
                .State__c;
            stepWrapper.status = TranslateHelper.getPickListLabel(
                Participant_Enrollment__c.Participant_Status__c,
                peshList[0].Status__c
            );
            stepWrapper.dateStatus = Date.valueOf(peshList[0].Date__c);
            stepWrapper.outcome = peshList[0].Status__c;
            List<Id> stepList = new List<Id>();
            if (peshList != null)
                for (Participant_Enrollment_Status_History__c pesh : peshList) {
                    stepList.add(pesh.Id);
                }
            List<Participant_Enrollment_Status_History__c> peshists = stepsAndPesh.get(
                step.DeveloperName
            );

            for (Participant_Enrollment_Status_History__c pesh : peshList) {
                Boolean nextStepSuccessful = false;
                Boolean nextStepInProgress = false;
                nextStepSuccessful =
                    nextStep != null &&
                    String.isNotBlank(nextStep.Success_Condition__c) &&
                    ConditionCheckerService.checkConditionForObject(
                        nextStep.Success_Condition__c,
                        pe
                    );
                nextStepInProgress =
                    nextStep != null &&
                    (String.isBlank(nextStep.In_Progress_Condition__c) ||
                    ConditionCheckerService.checkConditionForObject(
                        nextStep.In_Progress_Condition__c,
                        pe
                    ));
                Boolean statusValidForCurrentStep = (step.Additional_Notes_For_Statuses__c !=
                null &&
                step.Additional_Notes_For_Statuses__c.contains(';' + pesh.Status__c + ';') &&
                !(nextStep != null &&
                nextStep.Additional_Notes_For_Statuses__c != null &&
                nextStep.Additional_Notes_For_Statuses__c.contains(';' + pesh.Status__c + ';')));
                Boolean isStatusCommonForSteps = (stepsAndPesh.containsKey(step.DeveloperName) &&
                stepsAndPesh.get(step.DeveloperName) != null &&
                stepsAndPesh.get(step.DeveloperName).contains(pesh) &&
                nextStep != null &&
                stepsAndPesh.containsKey(nextStep.DeveloperName) &&
                stepsAndPesh.get(nextStep.DeveloperName) != null &&
                stepsAndPesh.get(nextStep.DeveloperName).contains(pesh));
                if (
                    stepsAndPesh.containsKey(step.DeveloperName) &&
                    stepsAndPesh.get(step.DeveloperName) != null &&
                    stepsAndPesh.get(step.DeveloperName).contains(pesh)
                ) {
                    if (
                        pesh.Additional_Notes__c != null &&
                        pesh.Additional_Notes__c.contains('####')
                    ) {
                        stepWrapper.stepHistory.addAll(
                            createOnlyNotesHistoryWrapper(
                                pesh.Additional_Notes__c.substringAfter('####')
                            )
                        );
                    } else if (
                        (isStatusCommonForSteps &&
                        !(nextStepSuccessful || nextStepInProgress) &&
                        (pesh.Additional_Notes__c == null ||
                        !pesh.Additional_Notes__c.contains('####'))) || !isStatusCommonForSteps
                    ) {
                        stepWrapper.stepHistory.addAll(
                            createOnlyNotesHistoryWrapper(pesh.Additional_Notes__c)
                        );
                    }
                }
                ParticipantWorkflowHistoryWrapper historyWrapper = createHistoryWrapper(pesh, step, pe);
                stepWrapper.stepHistory.add(historyWrapper);
            }

            if (peshists != null) {
                for (Participant_Enrollment_Status_History__c peshist : peshists) {
                    if (!stepList.contains(peshist.Id)) {
                        if (
                            peshist.Additional_Notes__c != null &&
                            peshist.Additional_Notes__c.contains('####')
                        ) {
                            String addNotes = peshist.Additional_Notes__c.substringBefore('####');
                            stepWrapper.stepHistory.addAll(createOnlyNotesHistoryWrapper(addNotes));
                        } else {
                            stepWrapper.stepHistory.addAll(
                                createOnlyNotesHistoryWrapper(peshist.Additional_Notes__c)
                            );
                        }
                    }
                }
            }
        } else {
            Boolean stepSuccessful =
                String.isNotBlank(step.Success_Condition__c) &&
                ConditionCheckerService.checkConditionForObject(step.Success_Condition__c, pe);

            Boolean stepInProgress =
                String.isBlank(step.In_Progress_Condition__c) ||
                ConditionCheckerService.checkConditionForObject(step.In_Progress_Condition__c, pe);
            stepWrapper.state = previousStepSuccess
                ? (stepSuccessful
                      ? PEStatusState.STATUS_STATE_SUCCESS
                      : (stepInProgress
                            ? PEStatusState.STATUS_STATE_IN_PROGRESS
                            : PEStatusState.STATUS_STATE_NEUTRAL))
                : PEStatusState.STATUS_STATE_NEUTRAL;
            if (stepSuccessful && step.Success_Date_Field__c != null) {
                if (pe.get(step.Success_Date_Field__c) != null)
                    stepWrapper.status = ((Date) pe.get(step.Success_Date_Field__c)).format();
                stepWrapper.dateStatus = (Date) pe.get(step.Success_Date_Field__c);
            } else {
                stepWrapper.status = TranslateHelper.getLabelValue(step.No_Outcome_Label__c);
            }
            List<Participant_Enrollment_Status_History__c> peshList = peshMap.get(
                step.DeveloperName
            );
            List<Id> stepList = new List<Id>();
            if (peshList != null)
                for (Participant_Enrollment_Status_History__c pesh : peshList) {
                    stepList.add(pesh.Id);
                }
            List<Participant_Enrollment_Status_History__c> peshists = stepsAndPesh.get(
                step.DeveloperName
            );
            if (peshists != null) {
                for (Participant_Enrollment_Status_History__c peshist : peshists) {
                    if (
                        peshist.Additional_Notes__c != null &&
                        peshist.Additional_Notes__c.contains('####')
                    ) {
                        String addNotes = peshist.Additional_Notes__c.substringBefore('####');
                        stepWrapper.stepHistory.addAll(createOnlyNotesHistoryWrapper(addNotes));
                    } else {
                        stepWrapper.stepHistory.addAll(
                            createOnlyNotesHistoryWrapper(peshist.Additional_Notes__c)
                        );
                    }
                }
            }
        }
        stepWrapper.editable =
            stepWrapper.state == PEStatusState.STATUS_STATE_IN_PROGRESS ||
            (stepWrapper.state != PEStatusState.STATUS_STATE_NEUTRAL &&
            step.Failed_State_Editing_Enabled__c);
        stepWrapper.outcomeList = new List<LabelValueItem>();
        stepWrapper.successOutcomes = new List<String>();
        stepWrapper.reasonMap = new Map<String, List<LabelValueItem>>();
        stepWrapper.notesRequiredMap = new Map<String, Boolean>();
        for (
            Map<String, Participant_Workflow_Outcome__mdt> statusOutcomesMap : outcomesMap.values()
        ) {
            for (Participant_Workflow_Outcome__mdt outcome : statusOutcomesMap.values()) {
                if (outcome.Step__c == step.DeveloperName) {
                    if (outcome.State__c == PEStatusState.STATUS_STATE_SUCCESS) {
                        stepWrapper.successOutcomes.add(outcome.Status_Name__c);
                        if (stepWrapper.outcome == outcome.State__c) {
                            stepWrapper.currentOutcomeSuccess = true;
                        }
                    }
                    if (!outcome.Show_Only_If_Selected__c) {
                        stepWrapper.outcomeList.add(
                            new LabelValueItem(
                                TranslateHelper.getPickListLabel(
                                    Participant_Enrollment__c.Participant_Status__c,
                                    outcome.Status_Name__c
                                ),
                                outcome.Status_Name__c
                            )
                        );
                    } else if (outcome.Status_Name__c == pe.Participant_Status__c) {
                        stepWrapper.outcomePlaceholder = TranslateHelper.getPickListLabel(
                            Participant_Enrollment__c.Participant_Status__c,
                            outcome.Status_Name__c
                        );
                    }
                    if (
                        (outcome.Status_Name__c == pe.Participant_Status__c &&
                         outcome.Readonly_if_Current__c)||(step.DeveloperName == 'Contact' && sendToSHDate !=null)
                    ) {
                        stepWrapper.outcomeEditable = false;
                    }
                    if (
                        outcome.Status_Name__c == pe.Participant_Status__c &&
                        !String.isEmpty(outcome.Disclaimer_if_Current__c)
                    ) {
                        stepWrapper.outcomeDisclaimer = TranslateHelper.getLabelValue(
                            outcome.Disclaimer_if_Current__c
                        );
                    }

                    List<LabelValueItem> reasonsList = new List<LabelValueItem>();
                    if (outcome.Reasons_List__c == null) {
                        //reasonsList.add(new LabelValueItem('', ''));
                        stepWrapper.notesRequiredMap.put(outcome.Status_Name__c + ';', false);
                    } else {
                        for (String reason : outcome.Reasons_List__c.split(';')) {
                            String reasonNoDecoration = reason.remove('*');
                            reasonsList.add(
                                new LabelValueItem(
                                    TranslateHelper.getPickListLabel(
                                        Participant_Enrollment__c.Non_Enrollment_Reason__c,
                                        reasonNoDecoration
                                    ),
                                    reasonNoDecoration
                                )
                            );
                            stepWrapper.notesRequiredMap.put(
                                outcome.Status_Name__c +
                                ';' +
                                reasonNoDecoration,
                                reason.contains('*')
                            );
                        }
                    }
                    stepWrapper.reasonMap.put(outcome.Status_Name__c, reasonsList);
                }
            }
        }
        stepWrapper.fieldDependencyMap = new Map<String, List<DependentFieldWrapper>>();

        stepWrapper.formFieldGroups = createFieldGroupWrappers(
            step,
            fieldsMap,
            pe,
            stepWrapper.fieldDependencyMap,
            ctp,
            fieldWrappersMap
        );
        stepWrapper.notes = '';
        return stepWrapper;
    }

    private static List<ParticipantWorkflowHistoryWrapper> createOnlyNotesHistoryWrapper(
        String additionalNotes
    ) {
        List<ParticipantWorkflowHistoryWrapper> historyWrappers = new List<ParticipantWorkflowHistoryWrapper>();
        List<String> notes = new List<String>();
        if (additionalNotes != null && additionalNotes != '')
            notes = additionalNotes.split('#');
        for (String note : notes) {
            if (note != '') {
                ParticipantWorkflowHistoryWrapper historyWrapper = new ParticipantWorkflowHistoryWrapper();
                Integer startOfIQVIA = note.lastIndexOfIgnoreCase('('+Label.RH_Masked_IQVIA_User+')');
                if(startOfIQVIA>0){
                    note = note.substring(0,startOfIQVIA) + ' ' + Label.RH_Masked_Display_IQVIA_User;
                }
                Integer startOfOnLabel = note.lastIndexOfIgnoreCase(' ' + Label.PE_Status_History_On_Date + ' ');
                if(startOfOnLabel>0){
                    historyWrapper.title = note.substring(0,startOfOnLabel);
                    historyWrapper.detail =note.substring(startOfOnLabel,note.length());
                    historyWrapper.detail.replace(
                        Label.PE_Status_History_On_Date,
                        TranslateHelper.getLabelValue('PE_Status_History_On_Date')
                    );
                    historyWrapper.detail.replace(
                        Label.PG_IMI_L_by_user,
                        TranslateHelper.getLabelValue('PG_IMI_L_by_user')
                    );
                }else{
                    historyWrapper.detail = note;
                }
                historyWrapper.isAdditionalNote = true;
                historyWrappers.add(historyWrapper);
            }
        }
        return historyWrappers;
    }

    private static ParticipantWorkflowHistoryWrapper createHistoryWrapper(
        Participant_Enrollment_Status_History__c pesh,
        Participant_Workflow_Step__mdt step,
        Participant_Enrollment__c pe
) {
     return createHistoryWrapper(pesh,step,pe,null); 
}
    private static ParticipantWorkflowHistoryWrapper createHistoryWrapper(
        Participant_Enrollment_Status_History__c pesh,
        Participant_Workflow_Step__mdt step,
        Participant_Enrollment__c pe,
        Map<Id,String> piContactNames
    ) {
        ParticipantWorkflowHistoryWrapper historyWrapper = new ParticipantWorkflowHistoryWrapper();
        String statusString = TranslateHelper.getPickListLabel(
            Participant_Enrollment__c.Participant_Status__c,
            pesh.Status__c
        );
        if(pesh.Status__c == 'Eligibility Passed' && pe.Clinical_Trial_Profile__r.Promote_To_SH__c ==true){
            statusString = TranslateHelper.getLabelValue(Label.Sent_to_Study_Hub);
        }
        String reasonString = (String.isNotBlank(pesh.Non_Enrollment_Reason__c)
            ? ' - ' +
              TranslateHelper.getPickListLabel(
                  Participant_Enrollment__c.Non_Enrollment_Reason__c,
                  pesh.Non_Enrollment_Reason__c.trim()
              )
            : '');
        String notesString = (String.isNotBlank(pesh.Notes__c) ? ', ' + pesh.Notes__c.trim() : '');
        String createdbyName = '';
        //Mask Created by Name for non Portal users and Portal user whose User Community Mode is 'CC'
        if (pesh.CreatedBy.IsPortalEnabled == true) {
            if (pesh.CreatedBy.contact.userCommunityMode__c == 'CC') {
                createdbyName = System.Label.RH_Masked_IQVIA_User;
            } else {
                createdbyName = pesh.CreatedBy.Name;
            }
        } else {
            createdbyName = System.Label.RH_Masked_IQVIA_User;
        }

        if (String.isEmpty(step.History_Item_Title_Template_Label__c)) {
            historyWrapper.title = statusString + reasonString + notesString;
        } else {
            historyWrapper.title = TranslateHelper.getLabelValue(
                    step.History_Item_Title_Template_Label__c
                )
                .replace('##Status', statusString)
                .replace('##Reason', reasonString)
                .replace('##Notes', notesString);
        }
        if (String.isBlank(step.History_Item_Details_Template_Label__c)) {
            if (pesh.Date__c != null) {
                historyWrapper.detail =
                    ' ' +
                    TranslateHelper.getLabelValue('PE_Status_History_On_Date') +
                    ' ' +
                    pesh.Date__c.format() +
                    ' ' +
                    TranslateHelper.getLabelValue('PG_IMI_L_by_user') +
                    ' ' +
                    createdbyName;
                historyWrapper.detailDate = pesh.Date__c;
                historyWrapper.createdBy = createdbyName;
            } else {
                historyWrapper.detail =
                    ' ' +
                    TranslateHelper.getLabelValue('PE_Status_History_On_Date') +
                    ' ' +
                    TranslateHelper.getLabelValue('PG_IMI_L_by_user') +
                    ' ' +
                    createdbyName;
                historyWrapper.detailDate = pesh.Date__c;
                historyWrapper.createdBy = createdbyName;
            }
        } else {
            String sourceString = String.isBlank(
                    pesh.ParticipantEnrollment__r.Referral_Completedby_Name__c
                )
                ? (pesh.ParticipantEnrollment__r.Source_Type__c ==
                      ParticipantEnrollmentService.PE_SOURCE_TYPE_EPR
                      ? pesh.ParticipantEnrollment__r.Source_Type__c
                      : piContactNames!=null && piContactNames.containsKey(pesh.ParticipantEnrollment__r.PI_Contact__c)
                        ? piContactNames.get(pesh.ParticipantEnrollment__r.PI_Contact__c)
                        : pesh.ParticipantEnrollment__r.PI_Contact__r.Name)
                : pesh.ParticipantEnrollment__r.Referral_Completedby_Name__c;
            historyWrapper.detail =
                ' ' +
                TranslateHelper.getLabelValue(step.History_Item_Details_Template_Label__c)
                    .replace('##Date', pesh.Date__c.format())
                    .replace('##ByUser', createdbyName)
                    .replace('##Source', sourceString);
            historyWrapper.detailDate = pesh.Date__c;
            historyWrapper.createdBy = createdbyName;
            historyWrapper.source = sourceString;
        }
        return historyWrapper;
    }

    private static List<ParticipantWorkflowFieldGroupWrapper> createFieldGroupWrappers(
        Participant_Workflow_Step__mdt step,
        Map<String, Participant_Workflow_Form_Field__mdt> fieldsMap,
        Participant_Enrollment__c pe,
        Map<String, List<DependentFieldWrapper>> fieldDependencyMap,
        Clinical_Trial_Profile__c ctp,
        Map<String, ParticipantWorkflowFieldWrapper> fieldWrappersMap
    ) {
        List<ParticipantWorkflowFieldGroupWrapper> result = new List<ParticipantWorkflowService.ParticipantWorkflowFieldGroupWrapper>();
        if (String.isNotBlank(step.Form_Fields__c)) {
            for (string fieldGroupString : step.Form_Fields__c.split('\\|')) {
                ParticipantWorkflowFieldGroupWrapper groupWrapper = new ParticipantWorkflowFieldGroupWrapper();
                List<String> fieldGroupStringParts = fieldGroupString.split('#');
                String fieldsString;
                if (fieldGroupStringParts.size() == 1) {
                    fieldsString = fieldGroupStringParts[0];
                } else {
                    groupWrapper.title = TranslateHelper.getLabelValue(fieldGroupStringParts[0]);
                    fieldsString = fieldGroupStringParts[1];
                }
                groupWrapper.fields = createFieldWrappers(
                    step,
                    fieldsString,
                    fieldsMap,
                    pe,
                    fieldDependencyMap,
                    ctp,
                    fieldWrappersMap
                );
                result.add(groupWrapper);
            }
        }
        return result;
    }

    private static List<ParticipantWorkflowFieldWrapper> createFieldWrappers(
        Participant_Workflow_Step__mdt step,
        String fieldsString,
        Map<String, Participant_Workflow_Form_Field__mdt> fieldsMap,
        Participant_Enrollment__c pe,
        Map<String, List<DependentFieldWrapper>> fieldDependencyMap,
        Clinical_Trial_Profile__c ctp,
        Map<String, ParticipantWorkflowFieldWrapper> fieldWrappersMap
    ) {
        List<ParticipantWorkflowFieldWrapper> fieldWrappers = new List<ParticipantWorkflowFieldWrapper>();
        List<LabelValueItem> visitPlansLVList = StudySiteService.getVisitPlansLVList(
            pe.Study_Site__c
        );
        for (String lineString : fieldsString.split(';')) {
            Integer numValidFieldInLine = 0;
            List<String> atomicFieldStrings = lineString.split(',');
            ParticipantWorkflowFieldWrapper currentFieldWrapper;
            for (String atomicFieldString : atomicFieldStrings) {
                if (atomicFieldString == 'blank' || fieldsMap.containsKey(atomicFieldString)) {
                    numValidFieldInLine++;
                }
            }
            for (String atomicFieldString : atomicFieldStrings) {
                Participant_Workflow_Form_Field__mdt fieldSetting = fieldsMap.get(
                    atomicFieldString
                );
                if (
                    atomicFieldString != 'blank' &&
                    (fieldSetting == null ||
                    (fieldSetting.Type__c == 'visitplan' && visitPlansLVList.isEmpty()))
                ) {
                    currentFieldWrapper = null;
                    continue;
                }
                if (
                    currentFieldWrapper != null &&
                    fieldSetting != null &&
                    (currentFieldWrapper.field == fieldSetting.Field_Name__c &&
                    currentFieldWrapper.type == fieldSetting.Type__c)
                ) {
                    currentFieldWrapper.numOccurences++;
                    currentFieldWrapper.style =
                        'slds-size--' +
                        String.valueOf(currentFieldWrapper.numOccurences) +
                        '-of-' +
                        String.valueOf(numValidFieldInLine);
                } else {
                    currentFieldWrapper = createFieldWrapper(
                        fieldSetting,
                        numValidFieldInLine,
                        step,
                        pe,
                        fieldDependencyMap,
                        ctp,
                        visitPlansLVList
                    );
                    fieldWrappers.add(currentFieldWrapper);
                    fieldWrappersMap.put(currentFieldWrapper.field, currentFieldWrapper);
                }
            }
        }
        return fieldWrappers;
    }

    private static ParticipantWorkflowFieldWrapper createFieldWrapper(
        Participant_Workflow_Form_Field__mdt fieldSetting,
        Integer numberOfFieldsInRow,
        Participant_Workflow_Step__mdt step,
        Participant_Enrollment__c pe,
        Map<String, List<DependentFieldWrapper>> fieldDependencyMap,
        Clinical_Trial_Profile__c ctp,
        List<LabelValueItem> visitPlansLVList
    ) {
        ParticipantWorkflowFieldWrapper newFieldWrapper = new ParticipantWorkflowFieldWrapper();
        newFieldWrapper.numOccurences = 1;
        newFieldWrapper.style = 'slds-size--1-of-' + String.valueOf(numberOfFieldsInRow);
        if (fieldSetting == null) {
            newFieldWrapper.type = 'blank';
        } else {
            populateWrapperWithTypeSettings(newFieldWrapper, fieldSetting, pe, visitPlansLVList);
            newFieldWrapper.title = TranslateHelper.getLabelValue(fieldSetting.Title_Label__c);
            newFieldWrapper.requiredTitle = TranslateHelper.getLabelValue(
                fieldSetting.Required_Title_Label__c
            );
            newFieldWrapper.field = fieldSetting.Field_Name__c;
            newFieldWrapper.readonly =
                (newFieldWrapper.readonly != null && newFieldWrapper.readonly) ||
                (fieldSetting.Editable_for_Statuses__c != null &&
                !fieldSetting.Editable_for_Statuses__c.contains(pe.Participant_Status__c)) ||
                fieldSetting.Readonly_for_Steps__c != null &&
                fieldSetting.Readonly_for_Steps__c.contains(step.DeveloperName);
            newFieldWrapper.required =
                fieldSetting.Required_for_Steps__c != null &&
                fieldSetting.Required_for_Steps__c.contains(step.DeveloperName) &&
                (fieldSetting.Required_Condition__c == null ||
                ConditionCheckerService.checkConditionForObject(
                    fieldSetting.Required_Condition__c,
                    ctp
                ));
            newFieldWrapper.onlyFutureDate = fieldSetting.Only_Future_Dates__c;
            newFieldWrapper.onlyPastDate = fieldSetting.Only_Past_Dates__c;
            newFieldWrapper.fieldType = fieldSetting.Type__c;
            if (String.isNotBlank(fieldSetting.False_Value_Validation_Error_Label__c)) {
                newFieldWrapper.validationMessageIfFalse = TranslateHelper.getLabelValue(
                    fieldSetting.False_Value_Validation_Error_Label__c
                );
                newFieldWrapper.validValue = fieldSetting.Valid_Value_for_Validation_Message__c;
            }
            if (String.isNotBlank(fieldSetting.Depends_On_Field__c)) {
                newFieldWrapper.dependent = true;
                newFieldWrapper.dependentActive = false;
                newFieldWrapper.strictDependency = fieldSetting.Strict_Dependency__c;

                DependentFieldWrapper dependentField = new DependentFieldWrapper();
                dependentField.fieldName = fieldSetting.Field_Name__c;
                dependentField.controllingValue = fieldSetting.Depends_On_Values__c;

                if (!fieldDependencyMap.containsKey(fieldSetting.Depends_On_Field__c)) {
                    fieldDependencyMap.put(
                        fieldSetting.Depends_On_Field__c,
                        new List<DependentFieldWrapper>{ dependentField }
                    );
                } else {
                    fieldDependencyMap.get(fieldSetting.Depends_On_Field__c).add(dependentField);
                }
                if (String.isNotBlank(fieldSetting.Populate_from_Field__c)) {
                    newFieldWrapper.populateFromDependent = fieldSetting.Populate_from_Field__c;
                }
            } else {
                newFieldWrapper.dependent = false;
                newFieldWrapper.dependentActive = false;
                newFieldWrapper.strictDependency = false;
            }
            if (String.isNotBlank(fieldSetting.Populate_Fields_Map__c)) {
                newFieldWrapper.populateFields = new Map<String, String>();
                for (String fieldValueString : fieldSetting.Populate_Fields_Map__c.split(';')) {
                    List<String> fieldValuePair = fieldValueString.split('=>');
                    if (fieldValuePair.size() == 2) {
                        newFieldWrapper.populateFields.put(
                            fieldValuePair[0].trim(),
                            fieldValuePair[1].trim()
                        );
                    }
                }
            }
            //            Object fieldvalue;
            ////            if (String.isNotBlank(fieldSetting.Field_Name__c) && pe.get(fieldSetting.Field_Name__c) != null) {
            ////                fieldvalue = pe.get(fieldSetting.Field_Name__c);
            ////            } else if (String.isNotBlank(fieldSetting.Populate_from_Field__c)) {
            ////                fieldvalue = pe.get(fieldSetting.Populate_from_Field__c);
            ////            }
        }
        return newFieldWrapper;
    }

    private static void populateWrapperWithTypeSettings(
        ParticipantWorkflowFieldWrapper fieldWrapper,
        Participant_Workflow_Form_Field__mdt fieldSetting,
        Participant_Enrollment__c pe,
        List<LabelValueItem> visitPlansLVList
    ) {
        switch on fieldSetting.Type__c {
            when 'visitplan' {
                fieldWrapper.type = 'picklist';
                fieldWrapper.value = pe.Visit_Plan__c;
                fieldWrapper.smartPicklist = true;
                fieldWrapper.values = visitPlansLVList;
                if (fieldWrapper.values.size() == 1 && fieldWrapper.value == null) {
                    fieldWrapper.value = fieldWrapper.values[0].value;
                }
            }
            when 'time' {
                fieldWrapper.type = 'time';
                if (!fieldSetting.Status_History_Record_Field__c) {
                    if (pe.get(fieldSetting.Field_Name__c) instanceof Time) {
                        fieldWrapper.value = String.valueOf(
                            (Time) pe.get(fieldSetting.Field_Name__c)
                        );
                    } else {
                        fieldWrapper.value = pe.get(fieldSetting.Field_Name__c) == null
                            ? ''
                            : ((DateTime) pe.get(fieldSetting.Field_Name__c)).format('TT:MM');
                    }
                }
            }
            when 'date' {
                fieldWrapper.type = 'date';
                if (!fieldSetting.Status_History_Record_Field__c) {
                    if (pe.get(fieldSetting.Field_Name__c) instanceof Date) {
                        fieldWrapper.value = pe.get(fieldSetting.Field_Name__c) == null
                            ? ''
                            : String.valueOf(pe.get(fieldSetting.Field_Name__c));
                    } else {
                        fieldWrapper.value = pe.get(fieldSetting.Field_Name__c) == null
                            ? ''
                            : ((DateTime) pe.get(fieldSetting.Field_Name__c)).format('yyyy-MM-dd');
                    }
                }
            }
            when 'text' {
                fieldWrapper.type = 'text';
                if (!fieldSetting.Status_History_Record_Field__c) {
                    fieldWrapper.value = (String) pe.get(fieldSetting.Field_Name__c);
                }
            }
            when 'boolean' {
                if (String.isBlank(fieldSetting.True_Value_Label__c)) {
                    fieldWrapper.type = 'checkbox';
                    if (!fieldSetting.Status_History_Record_Field__c) {
                        fieldWrapper.value = String.valueOf(
                            (Boolean) pe.get(fieldSetting.Field_Name__c)
                        );
                    }
                    fieldWrapper.style += ' checkbox-field';
                } else {
                    fieldWrapper.type = 'picklist';
                    if (!fieldSetting.Status_History_Record_Field__c) {
                        fieldWrapper.value = String.valueOf(
                            (Boolean) pe.get(fieldSetting.Field_Name__c)
                        );
                    }
                    fieldWrapper.values = new List<LabelValueItem>{
                        new LabelValueItem(
                            TranslateHelper.getLabelValue(fieldSetting.True_Value_Label__c),
                            'true'
                        ),
                        new LabelValueItem(
                            TranslateHelper.getLabelValue(fieldSetting.False_Value_Label__c),
                            'false'
                        )
                    };
                }
            }
            when 'picklist' {
                fieldWrapper.type = 'picklist';
                populateFieldWrapperWithPicklistValues(fieldWrapper, fieldSetting, pe);
            }
            when else {
                fieldWrapper.type = 'blank';
            }
        }
    }
    private static void populateFieldWrapperWithPicklistValues(
        ParticipantWorkflowFieldWrapper fieldWrapper,
        Participant_Workflow_Form_Field__mdt fieldSetting,
        Participant_Enrollment__c pe
    ) {
        fieldWrapper.values = new List<LabelValueItem>();
        List<Participant_Workflow_Picklist_Value__mdt> picklistValues = [
            SELECT
                Id,
                DeveloperName,
                Label__c,
                Value__c,
                Selected_Condition__c,
                Available_Condition__c,
                Show_Only_If_Selected__c,
                Readonly_if_Current__c,
                Order__c
            FROM Participant_Workflow_Picklist_Value__mdt
            WHERE Participant_Workflow_Form_Field__c = :fieldSetting.Id
            ORDER BY Order__c ASC
        ];
        fieldWrapper.value = '';
        for (Participant_Workflow_Picklist_Value__mdt picklistValue : picklistValues) {
            Boolean selected =
                String.isNotBlank(picklistValue.Selected_Condition__c) &&
                ConditionCheckerService.checkConditionForObject(
                    picklistValue.Selected_Condition__c,
                    pe
                );
            Boolean available =
                String.isBlank(picklistValue.Available_Condition__c) ||
                ConditionCheckerService.checkConditionForObject(
                    picklistValue.Available_Condition__c,
                    pe
                );
            if ((available && !picklistValue.Show_Only_If_Selected__c) || selected) {
                fieldWrapper.values.add(
                    new LabelValueItem(
                        TranslateHelper.getLabelValue(picklistValue.Label__c),
                        picklistValue.Value__c
                    )
                );
            }
            if (selected && picklistValue.Readonly_if_Current__c) {
                fieldWrapper.readonly = true;
            }
            if (selected) {
                fieldWrapper.value = picklistValue.Value__c;
            }
        }
    }

    private static void populateDependencyActiveFields(
        ParticipantWorkflowWrapper wrapper,
        Map<String, ParticipantWorkflowFieldWrapper> fieldWrappersMap
    ) {
        Set<String> fieldsToActivate = new Set<String>();
        for (ParticipantWorkflowStepWrapper step : wrapper.steps) {
            for (String controllingField : step.fieldDependencyMap.keySet()) {
                if (fieldWrappersMap.containsKey(controllingField)) {
                    for (
                        DependentFieldWrapper dependentWrapper : step.fieldDependencyMap.get(
                            controllingField
                        )
                    ) {
                        if (
                            !String.isBlank(fieldWrappersMap.get(controllingField).value) &&
                            dependentWrapper.controllingValue.indexOf(
                                fieldWrappersMap.get(controllingField).value
                            ) != -1
                        ) {
                            fieldsToActivate.add(dependentWrapper.fieldName);
                        }
                    }
                }
            }
        }
        for (ParticipantWorkflowStepWrapper step : wrapper.steps) {
            for (ParticipantWorkflowFieldGroupWrapper fieldGroup : step.formFieldGroups) {
                for (ParticipantWorkflowFieldWrapper fieldWrapper : fieldGroup.fields) {
                    if (fieldsToActivate.contains(fieldWrapper.field)) {
                        fieldWrapper.dependentActive = true;
                    }
                }
            }
        }
    }
    public static Participant_Enrollment_Status_History__c createPESHFromPathWrapper(
        ParticipantWorkflowWrapper pathWrapper,
        Participant_Enrollment__c pe,
        Clinical_Trial_Profile__c ctp,
        Participant_Enrollment__c oldParticipantEnrollment,
        Boolean PartcipantNoShow
    ) {
        Participant_Enrollment_Status_History__c pesh = new Participant_Enrollment_Status_History__c();
        pesh.ParticipantEnrollment__c = pe.Id;
        pesh.Date__c = Datetime.now();
        List<Participant_Workflow_Step__mdt> steps = getWorkflowSteps(ctp);
        Map<String, Map<String, Participant_Workflow_Outcome__mdt>> outcomesMap = getOutcomesMap(
            steps,
            ctp
        );
        List<Participant_Workflow_Outcome__mdt> outcomes = new List<Participant_Workflow_Outcome__mdt>();
        for (
            Map<String, Participant_Workflow_Outcome__mdt> stepOutcomesMap : outcomesMap.values()
        ) {
            for (Participant_Workflow_Outcome__mdt outcome : stepOutcomesMap.values()) {
                outcomes.add(outcome);
            }
        }
        populatePESHFromWorkflowWrapper(pathWrapper, pe, pesh, ctp, oldParticipantEnrollment);
        System.debug('pesh ' + pesh);
        if (String.isEmpty(pesh.Status__c)) {
            String autoUpdateStatus = autoUpdateStatusForPE(pe, ctp, outcomes);
            if (String.isNotBlank(autoUpdateStatus)) {
                pesh.Status__c = autoUpdateStatus;
            } else {
                populatePESHFromLastStep(pathWrapper, pe, pesh);
            }
        }
        //RH-539
        if(PartcipantNoShow){
          pesh.Status__c = 'Unable to Reach';
        pesh.Non_Enrollment_Reason__c = 'Didn\'t Show For Initial Visit'; 
        }
        if (
            pesh == null ||
            String.isBlank(pesh.Status__c) ||
            (outcomesMap.get(pesh.Status__c).values()[0].Suppress_Multiple__c &&
            pesh.Status__c == pe.Participant_Status__c)
        )
          return null;
        {
        }
       
        return pesh;
    }

    public static void populatePESHFromLastStep(
        ParticipantWorkflowWrapper pathWrapper,
        Participant_Enrollment__c pe,
        Participant_Enrollment_Status_History__c pesh
    ) {
        ParticipantWorkflowStepWrapper lastStepWrapper = null;
        if (pathWrapper != null) {
            for (ParticipantWorkflowStepWrapper step : pathWrapper.steps) {
                if (step.state != PEStatusState.STATUS_STATE_NEUTRAL) {
                    lastStepWrapper = step;
                }
            }
        }
        if (lastStepWrapper != null) {
            if (String.isNotBlank(lastStepWrapper.outcome)) {
                pesh.Status__c = lastStepWrapper.outcome;
                pesh.Non_Enrollment_Reason__c = lastStepWrapper.reason;
                pesh.Notes__c = lastStepWrapper.notes;
            }
        }
    }

    public static String autoUpdateStatusForPE(
        Participant_Enrollment__c pe,
        Clinical_Trial_Profile__c ctp,
        List<Participant_Workflow_Outcome__mdt> outcomes
    ) {
        String status = '';
        for (Participant_Workflow_Outcome__mdt outcome : outcomes) {
            if (
                String.isNotBlank(outcome.Condition_for_Auto_Update__c) &&
                ConditionCheckerService.checkConditionForObject(
                    outcome.Condition_for_Auto_Update__c,
                    pe
                )
            ) {
                status = outcome.Status_Name__c;
            }
        }
        return status;
    }

    public static void populateOBJFromStepWrapper(
        ParticipantWorkflowStepWrapper stepWrapper,
        SObject obj,
        String objectNameAlias,
        Map<String, Participant_Workflow_Form_Field__mdt> fieldsMap
    ) {
        if (!stepWrapper.formFieldGroups.isEmpty()) {
            for (
                ParticipantWorkflowService.ParticipantWorkflowFieldGroupWrapper fieldGroup : stepWrapper.formFieldGroups
            ) {
                for (
                    ParticipantWorkflowService.ParticipantWorkflowFieldWrapper field : fieldGroup.fields
                ) {
                    if (
                        field.type == 'blank' ||
                        field.readonly ||
                        (field.dependent &&
                        field.strictDependency &&
                        !field.dependentActive) ||
                        (field.fieldType != 'picklist' &&
                        fieldsMap.get(field.field).Status_History_Record_Field__c &&
                        objectNameAlias != PARTICIPANT_ENROLLMENT_STATUS_HISTORY_SOBJECT_ALIAS) ||
                        (field.fieldType != 'picklist' &&
                        !fieldsMap.get(field.field).Status_History_Record_Field__c &&
                        objectNameAlias == PARTICIPANT_ENROLLMENT_STATUS_HISTORY_SOBJECT_ALIAS)
                    ) {
                        continue;
                    }
                    if (String.isBlank(field.value) && field.fieldType != 'boolean') {
                        obj.put(field.field, null);
                    } else if (String.isBlank(field.value) && field.fieldType == 'boolean') {
                        obj.put(field.field, false);
                    } else {
                        switch on field.fieldType {
                            when 'visitplan', 'text' {
                                obj.put(field.field, field.value);
                            }
                            when 'time' {
                                List<String> strTimeSplit = field.value.split(':');
                                obj.put(
                                    field.field,
                                    Time.newInstance(
                                        Integer.valueOf(strTimeSplit[0]),
                                        Integer.valueOf(strTimeSplit[1]),
                                        0,
                                        0
                                    )
                                );
                            }
                            when 'date' {
                                obj.put(field.field, Date.valueOf(field.value));
                            }
                            when 'boolean' {
                                obj.put(field.field, Boolean.valueOf(field.value));
                            }
                            when 'picklist' {
                                populateSObjectFromPicklistField(
                                    obj,
                                    objectNameAlias,
                                    field,
                                    fieldsMap.get(field.field)
                                );
                            }
                        }
                    }
                }
            }
        }
    }

    public static void populateSObjectFromPicklistField(
        SObject obj,
        String objectNameAlias,
        ParticipantWorkflowFieldWrapper field,
        Participant_Workflow_Form_Field__mdt fieldSetting
    ) {
        List<Participant_Workflow_Picklist_Value__mdt> picklistValues = [
            SELECT Value__c, Update_Fields_Mapping__c
            FROM Participant_Workflow_Picklist_Value__mdt
            WHERE Participant_Workflow_Form_Field__c = :fieldSetting.Id AND Value__c = :field.value
        ];
        System.debug('picklistValues ' + picklistValues);
        if (!picklistValues.isEmpty()) {
            if (
                String.isBlank(picklistValues[0].Update_Fields_Mapping__c) &&
                (objectNameAlias == PARTICIPANT_ENROLLMENT_STATUS_HISTORY_SOBJECT_ALIAS ||
                !fieldSetting.Status_History_Record_Field__c)
            ) {
                obj.put(field.field, picklistValues[0].Value__c);
            }
            if (String.isNotBlank(picklistValues[0].Update_Fields_Mapping__c)) {
                for (String valueMapping : picklistValues[0].Update_Fields_Mapping__c.split(';')) {
                    List<String> fieldValuePair = valueMapping.split('=>');
                    if (fieldValuePair.size() == 2) {
                        List<String> fieldNamePair = fieldValuePair[0].trim().split('\\.');
                        if (fieldNamePair.size() == 2 && fieldNamePair[0] == objectNameAlias) {
                            SObjectField objectField = obj.getSObjectType()
                                .getDescribe()
                                .fields.getMap()
                                .get(fieldNamePair[1].trim());
                            if (objectField.getDescribe().getType() == Schema.DisplayType.BOOLEAN) {
                                obj.put(
                                    fieldNamePair[1].trim(),
                                    Boolean.valueOf(fieldValuePair[1].trim())
                                );
                            } else {
                                obj.put(fieldNamePair[1].trim(), fieldValuePair[1].trim());
                            }
                        }
                    }
                }
            }
        }
    }

    public static void populatePEFromWorkflowWrapper(
        ParticipantWorkflowWrapper pathWrapper,
        Participant_Enrollment__c pe,
        Clinical_Trial_Profile__c ctp,
        Participant_Enrollment__c oldParticipantEnrollment
    ) {
        Map<String, Participant_Workflow_Form_Field__mdt> fieldsMap = getFieldsByObjectFieldNameMap(
            ctp,
            oldParticipantEnrollment
        );
        populateOBJFromWorkflowWrapper(
            pathWrapper,
            pe,
            PARTICIPANT_ENROLLMENT_SOBJECT_ALIAS,
            fieldsMap
        );
    }
    public static void populatePESHFromWorkflowWrapper(
        ParticipantWorkflowWrapper pathWrapper,
        Participant_Enrollment__c pe,
        Participant_Enrollment_Status_History__c pesh,
        Clinical_Trial_Profile__c ctp,
        Participant_Enrollment__c oldParticipantEnrollment
    ) {
        Map<String, Participant_Workflow_Form_Field__mdt> fieldsMap = getFieldsByObjectFieldNameMap(
            ctp,
            oldParticipantEnrollment
        );
        populateOBJFromWorkflowWrapper(
            pathWrapper,
            pesh,
            PARTICIPANT_ENROLLMENT_STATUS_HISTORY_SOBJECT_ALIAS,
            fieldsMap
        );
    }

    public static void populateOBJFromWorkflowWrapper(
        ParticipantWorkflowWrapper pathWrapper,
        SObject obj,
        String objectNameAlias,
        Map<String, Participant_Workflow_Form_Field__mdt> fieldsMap
    ) {
        if (pathWrapper != null) {
            for (ParticipantWorkflowStepWrapper step : pathWrapper.steps) {
                if (step.state != PEStatusState.STATUS_STATE_NEUTRAL) {
                    populateOBJFromStepWrapper(step, obj, objectNameAlias, fieldsMap);
                }
            }
        }
    }

    public static Map<String, Participant_Workflow_Form_Field__mdt> getFieldsMap(
        Clinical_Trial_Profile__c ctp,
        Participant_Enrollment__c pe
    ) {
        Map<String, Participant_Workflow_Form_Field__mdt> result = new Map<String, Participant_Workflow_Form_Field__mdt>();
        for (Participant_Workflow_Form_Field__mdt field : [
            SELECT
                Id,
                Field_Name__c,
                Type__c,
                Condition__c,
                Title_Label__c,
                Required_Title_Label__c,
                True_Value_Label__c,
                False_Value_Label__c,
                DeveloperName,
                Required_for_Steps__c,
                Editable_for_Statuses__c,
                Readonly_for_Steps__c,
                Depends_On_Field__c,
                Depends_On_Values__c,
                Strict_Dependency__c,
                Only_Future_Dates__c,
                Only_Past_Dates__c,
                Required_Condition__c,
                Populate_from_Field__c,
                Populate_Fields_Map__c,
                False_Value_Validation_Error_Label__c,
                Valid_Value_for_Validation_Message__c,
                Status_History_Record_Field__c
            FROM Participant_Workflow_Form_Field__mdt
        ]) {
            if (
                String.isBlank(field.Condition__c) ||
                ConditionCheckerService.checkConditionForMultipleObjects(
                    field.Condition__c,
                    new Map<String, SObject>{
                        CLINICAL_TRIAL_PROFILE_SOBJECT_ALIAS => ctp,
                        PARTICIPANT_ENROLLMENT_SOBJECT_ALIAS => pe
                    },
                    CLINICAL_TRIAL_PROFILE_SOBJECT_ALIAS
                )
            ) {
                result.put(field.DeveloperName, field);
            }
        }
        return result;
    }
    public static Map<String, Participant_Workflow_Form_Field__mdt> getFieldsByObjectFieldNameMap(
        Clinical_Trial_Profile__c ctp,
        Participant_Enrollment__c pe
    ) {
        Map<String, Participant_Workflow_Form_Field__mdt> result = new Map<String, Participant_Workflow_Form_Field__mdt>();
        for (Participant_Workflow_Form_Field__mdt field : [
            SELECT
                Id,
                Field_Name__c,
                Type__c,
                Condition__c,
                Title_Label__c,
                Required_Title_Label__c,
                True_Value_Label__c,
                False_Value_Label__c,
                DeveloperName,
                Required_for_Steps__c,
                Editable_for_Statuses__c,
                Readonly_for_Steps__c,
                Depends_On_Field__c,
                Depends_On_Values__c,
                Strict_Dependency__c,
                Only_Future_Dates__c,
                Only_Past_Dates__c,
                Required_Condition__c,
                Populate_from_Field__c,
                Populate_Fields_Map__c,
                False_Value_Validation_Error_Label__c,
                Valid_Value_for_Validation_Message__c,
                Status_History_Record_Field__c
            FROM Participant_Workflow_Form_Field__mdt
        ]) {
            if (
                String.isBlank(field.Condition__c) ||
                ConditionCheckerService.checkConditionForMultipleObjects(
                    field.Condition__c,
                    new Map<String, SObject>{
                        CLINICAL_TRIAL_PROFILE_SOBJECT_ALIAS => ctp,
                        PARTICIPANT_ENROLLMENT_SOBJECT_ALIAS => pe
                    },
                    CLINICAL_TRIAL_PROFILE_SOBJECT_ALIAS
                )
            ) {
                result.put(field.Field_Name__c, field);
            }
        }
        return result;
    }

    public static void populatePatientItemsWithPathWrappers(
        List<ParticipantItem> participantItems
    ) {
        Set<Id> ctpIds = new Set<Id>();
        Set<Id> peIds = new Set<Id>();
        for (ParticipantItem pi : participantItems) {
            ctpIds.add(pi.pe.Clinical_Trial_Profile__c);
            peIds.add(pi.pe.Id);
        }
        List<Participant_Workflow_Step__mdt> steps = Participant_Workflow_Step;
        Map<String, Map<String, Participant_Workflow_Outcome__mdt>> outcomesMap = getOutcomesMap(
            steps,
            null
        );
        Map<Id, List<Participant_Workflow_Step__mdt>> studyStepsList = new Map<Id, List<Participant_Workflow_Step__mdt>>();
        for (Clinical_Trial_Profile__c ctp : StudyTrialService.getFullTrials(ctpIds)) {
            List<Participant_Workflow_Step__mdt> stepList = new List<Participant_Workflow_Step__mdt>();
            for (Participant_Workflow_Step__mdt step : steps) {
                if (
                    String.isBlank(step.Condition__c) ||
                    ConditionCheckerService.checkConditionForObject(step.Condition__c, ctp)
                ) {
                    stepList.add(step);
                }
            }
            studyStepsList.put(ctp.Id, stepList);
        }
        List<Id> piContacts = new List<Id>();
        Map<Id,String> piContactNames = new Map<Id,String>();
        Map<Id, Map<String, Participant_Enrollment_Status_History__c>> lastHistoryByStepMap = new Map<Id, Map<String, Participant_Enrollment_Status_History__c>>();
        for (Participant_Enrollment_Status_History__c pesh : [
            SELECT
                Id,
                Date__c,
                Status__c,
                Non_Enrollment_Reason__c,
                Notes__c,
                CreatedBy.Name,
                ParticipantEnrollment__r.Referral_Source__c,
                ParticipantEnrollment__r.Referral_Completedby_Name__c,
                ParticipantEnrollment__r.Source_Type__c,
                ParticipantEnrollment__r.PI_Contact__c,
                ParticipantEnrollment__r.PI_Contact__r.Name,
                CreatedBy.IsPortalEnabled,
                CreatedBy.contact.userCommunityMode__c,Backward_Bulk_Update__c
            FROM Participant_Enrollment_Status_History__c
            WHERE ParticipantEnrollment__c IN :peIds and Backward_Bulk_Update__c=false and Disabled_PESH__c=false   
            ORDER BY Date__c DESC
        ]) {
            piContacts.add(pesh.ParticipantEnrollment__r.PI_Contact__c);
            if (!lastHistoryByStepMap.containsKey(pesh.ParticipantEnrollment__c)) {
                lastHistoryByStepMap.put(
                    pesh.ParticipantEnrollment__c,
                    new Map<String, Participant_Enrollment_Status_History__c>()
                );
            }
            Map<String, Participant_Enrollment_Status_History__c> peLastHistoryMap = lastHistoryByStepMap.get(
                pesh.ParticipantEnrollment__c
            );
            if (outcomesMap.containsKey(pesh.Status__c)) {
                for (String stepName : outcomesMap.get(pesh.Status__c).keySet()) {
                    if (!peLastHistoryMap.containsKey(stepName)) {
                        peLastHistoryMap.put(stepName, pesh);
                    }
                }
            }
        }
        piContactNames = getPIContactNames(piContacts);
        for (ParticipantItem pi : participantItems) {
            pi.pathItems = new List<ParticipantWorkflowService.PathStepWrapper>();
            if (lastHistoryByStepMap.containsKey(pi.pe.Id)) {
                PathStepWrapper previousStep = null;
                for (
                    Participant_Workflow_Step__mdt step : studyStepsList.get(
                        pi.pe.Clinical_Trial_Profile__c
                    )
                ) {
                    PathStepWrapper currentStep = createPathStepWrapper(
                        pi.pe,
                        lastHistoryByStepMap.get(pi.pe.Id).get(step.DeveloperName),
                        step,
                        outcomesMap,
                        previousStep,
                        piContactNames
                    );
                    pi.pathItems.add(currentStep);
                    previousStep = currentStep;
                }
            }
        }
    }

    public static Map<Id,Participant__c> getPIContactNameDetails(Set<Id> piContactIds){
        Map<Id,Participant__c> piContactDetails = new Map<Id,Participant__c>();
        for(Participant__c partPIContact : [SELECT Id,Contact__c,Salutation__c,First_Name__c,Middle_Name__c,Last_Name__c,Suffix__c FROM Participant__c WHERE Contact__c IN : piContactIds]){
           piContactDetails.put(partPIContact.Contact__c,partPIContact);
        }
        return piContactDetails;
    }

    public static Map<Id,String> getContactFullNamesFromParticipants(Set<Id> piContactIds){
        Map<Id,String> piContactNames = new Map<Id,String>();
        for(Participant__c partPIContact : [SELECT Id,Contact__c,Full_Name__c FROM Participant__c WHERE Contact__c IN : piContactIds]){
            piContactNames.put(partPIContact.Contact__c,partPIContact.Full_Name__c);
        }
        return piContactNames;
    }
    
    public static Map<Id,String> getPIContactNames(Set<Id> piContactIds){
        Map<Id,String> piContactNames = new Map<Id,String>();
        for(Participant__c partPIContact : [SELECT Id,Contact__c,First_Name__c,Middle_Name__c,Last_Name__c,Suffix__c FROM Participant__c WHERE Contact__c IN : piContactIds]){
            String partName;
            if(partPIContact.First_Name__c!=null){
                partName = partName==null?partPIContact.First_Name__c : partName + ' ' + partPIContact.First_Name__c;
            }
            if(partPIContact.Middle_Name__c!=null){
                partName = partName==null?partPIContact.Middle_Name__c : partName + ' ' + partPIContact.Middle_Name__c;
            }
            if(partPIContact.Last_Name__c!=null){
                partName = partName==null?partPIContact.Last_Name__c : partName + ' ' + partPIContact.Last_Name__c;
            }
            if(partPIContact.Suffix__c!=null){
                partName = partName==null?partPIContact.Suffix__c : partName + ' ' + partPIContact.Suffix__c;
            }
            piContactNames.put(partPIContact.Contact__c,partName);
        }
        return piContactNames;
    }

    public static Map<Id,String> getPIContactNames(List<Id> in_piContactIds){
        Set<Id> piContactIds = new Set<Id>();
        piContactIds.addAll(in_piContactIds);
        return getPIContactNames(piContactIds);
    }
    
    public static Map<Id,String> getPIContactSalutationAndNames(Set<Id> piContactIds){
        Map<Id,String> piContactNames = new Map<Id,String>();
        for(Participant__c partPIContact : [SELECT Id,Contact__c,Salutation__c,First_Name__c,Middle_Name__c,Last_Name__c,Suffix__c FROM Participant__c WHERE Contact__c IN : piContactIds]){
            String partName;
            if(partPIContact.Salutation__c!=null){
                partName = partPIContact.Salutation__c;
            }
            if(partPIContact.First_Name__c!=null){
                partName = partName==null?partPIContact.First_Name__c : partName + ' ' + partPIContact.First_Name__c;
            }
            if(partPIContact.Middle_Name__c!=null){
                partName = partName==null?partPIContact.Middle_Name__c : partName + ' ' + partPIContact.Middle_Name__c;
            }
            if(partPIContact.Last_Name__c!=null){
                partName = partName==null?partPIContact.Last_Name__c : partName + ' ' + partPIContact.Last_Name__c;
            }
            if(partPIContact.Suffix__c!=null){
                partName = partName==null?partPIContact.Suffix__c : partName + ' ' + partPIContact.Suffix__c;
            }
            piContactNames.put(partPIContact.Contact__c,partName);
        }
        return piContactNames;
    }
    
    private static PathStepWrapper createPathStepWrapper(
        Participant_Enrollment__c pe,
        Participant_Enrollment_Status_History__c pesh,
        Participant_Workflow_Step__mdt step,
        Map<String, Map<String, Participant_Workflow_Outcome__mdt>> outcomesMap,
        PathStepWrapper previousStep,
        Map<Id,String> piContactNames
    ) {
        PathStepWrapper result = new PathStepWrapper();
        if (pesh != null) {
            result.title = TranslateHelper.getPickListLabel(
                Participant_Enrollment__c.Participant_Status__c,
                pesh.Status__c
            );
            if(String.valueOf(pesh.Status__c)=='Successfully re-engaged'){
                 result.title =TranslateHelper.getLabelValue(Label.Successfully_Re_Engaged);
            }
           
            if(pesh.Status__c == 'Eligibility Passed' && pe.Clinical_Trial_Profile__r.Promote_To_SH__c ==true){
                result.title = TranslateHelper.getLabelValue(Label.Sent_to_Study_Hub);
            }
            result.reason = TranslateHelper.getPickListLabel(
                Participant_Enrollment__c.Non_Enrollment_Reason__c,
                pesh.Non_Enrollment_Reason__c
            );
            if (pesh.Date__c != null) {
                result.dateOccured = pesh.Date__c.date().format();
                result.occuredDate = pesh.Date__c.date();
            }
            result.state = outcomesMap.get(pesh.Status__c).get(step.DeveloperName).State__c;
            result.left = PEStatusState.STATUS_STATE_SUCCESS;
            if (previousStep != null)
                previousStep.right = PEStatusState.STATUS_STATE_SUCCESS;
            result.isCurrent = pe.Participant_Status__c == pesh.Status__c;
            result.right = PEStatusState.STATUS_STATE_NEUTRAL;
            result.stepHistory = new List<ParticipantWorkflowService.ParticipantWorkflowHistoryWrapper>();
            ParticipantWorkflowHistoryWrapper historyWrapper = createHistoryWrapper(pesh, step, pe, piContactNames);
            result.stepHistory.add(historyWrapper);
        } else {
            result.title = TranslateHelper.getLabelValue(step.Card_Name_Label__c);
            if (
                step.Success_Condition__c != null &&
                ConditionCheckerService.checkConditionForObject(step.Success_Condition__c, pe) &&
                (previousStep == null ||
                previousStep.state == PEStatusState.STATUS_STATE_SUCCESS)
            ) {
                result.state = PEStatusState.STATUS_STATE_SUCCESS;
                result.left = PEStatusState.STATUS_STATE_SUCCESS;
                if (
                    step.Success_Date_Field__c != null &&
                    pe.get(step.Success_Date_Field__c) != null
                ) {
                    result.dateOccured = ((Date) pe.get(step.Success_Date_Field__c)).format();
                    result.occuredDate = ((Date) pe.get(step.Success_Date_Field__c));
                }
                result.isCurrent = true;
            } else if (
                step.In_Progress_Condition__c != null &&
                ConditionCheckerService.checkConditionForObject(
                    step.In_Progress_Condition__c,
                    pe
                ) &&
                (previousStep == null ||
                previousStep.state == PEStatusState.STATUS_STATE_SUCCESS)
            ) {
                result.state = PEStatusState.STATUS_STATE_IN_PROGRESS;
                result.left = PEStatusState.STATUS_STATE_SUCCESS;
                if (
                    step.In_Progress_Date_Field__c != null &&
                    pe.get(step.In_Progress_Date_Field__c) != null
                ) {
                    result.dateOccured = ((Date) pe.get(step.In_Progress_Date_Field__c)).format();
                    result.occuredDate = ((Date) pe.get(step.Success_Date_Field__c));
                }
                result.isCurrent = true;
            } else {
                result.state = PEStatusState.STATUS_STATE_NEUTRAL;
                result.left = PEStatusState.STATUS_STATE_NEUTRAL;
            }
            result.right = PEStatusState.STATUS_STATE_NEUTRAL;
            if(pe.Participant_Status__c == PEStatusState.PE_STATUS_NO_SHOW && UserContext.getCurrentUserMode().userMode == CommunityService.USER_MODE_PARTICIPANT){//step.DeveloperName == 'Initial_Visit'
                result.state = PEStatusState.STATUS_STATE_NEUTRAL;
                result.left = PEStatusState.STATUS_STATE_NEUTRAL;
            }
        }
        if (result.state != PEStatusState.STATUS_STATE_NEUTRAL && previousStep != null) {
            previousStep.right = PEStatusState.STATUS_STATE_SUCCESS;
            previousStep.isCurrent = false;
        }

        return result;
    }

    public static List<Participant_Enrollment_Status_History__c> createHistoryRecordsForPE(
        Participant_Enrollment__c participantEnrollment,
        Clinical_Trial_Profile__c ctp
    ) {
        List<Participant_Workflow_Step__mdt> steps = getWorkflowSteps(ctp);
        Map<String, Map<String, Participant_Workflow_Outcome__mdt>> outcomesMap = getOutcomesMap(
            steps,
            ctp
        );
        Map<String, String> successfulStatusesForSteps = new Map<String, String>();
        for (Map<String, Participant_Workflow_Outcome__mdt> statusOutcomeMap : outcomesMap.values())
            for (Participant_Workflow_Outcome__mdt outcome : statusOutcomeMap.values()) {
                if (
                    outcome.State__c == PEStatusState.STATUS_STATE_SUCCESS &&
                    !successfulStatusesForSteps.containsKey(outcome.Step__c)
                ) {
                    successfulStatusesForSteps.put(outcome.Step__c, outcome.Status_Name__c);
                }
            }
        List<Participant_Enrollment_Status_History__c> statusHistories = new List<Participant_Enrollment_Status_History__c>();
        if (outcomesMap.get(participantEnrollment.Participant_Status__c) != null) {
            Participant_Workflow_Outcome__mdt currentOutcome = outcomesMap.get(
                    participantEnrollment.Participant_Status__c
                )
                .values()[0];
            for (Participant_Workflow_Step__mdt step : steps) {
                if (step.DeveloperName == currentOutcome.Step__c) {
                    statusHistories.add(
                        new Participant_Enrollment_Status_History__c(
                            Notes__c = participantEnrollment.Last_Status_Changed_Notes__c,
                            Date__c = Datetime.now(),
                            ParticipantEnrollment__c = participantEnrollment.Id,
                            Status__c = participantEnrollment.Participant_Status__c
                        )
                    );
                    break;
                }
                if (successfulStatusesForSteps.containsKey(step.DeveloperName))
                    statusHistories.add(
                        new Participant_Enrollment_Status_History__c(
                            Notes__c = '',
                            Date__c = Datetime.now(),
                            ParticipantEnrollment__c = participantEnrollment.Id,
                            Status__c = successfulStatusesForSteps.get(step.DeveloperName)
                        )
                    );
            }
        }
        return statusHistories;
    }

    public static void updatePEWithPreviousStatusesSuccess(
        Participant_Enrollment__c participantEnrollment,
        Clinical_Trial_Profile__c ctp
    ) {
        List<Participant_Workflow_Step__mdt> steps = getWorkflowSteps(ctp);
        Map<String, Map<String, Participant_Workflow_Outcome__mdt>> outcomesMap = getOutcomesMap(
            steps,
            ctp
        );
        if (outcomesMap.get(participantEnrollment.Participant_Status__c) != null) {
            Participant_Workflow_Outcome__mdt currentOutcome = outcomesMap.get(
                    participantEnrollment.Participant_Status__c
                )
                .values()[0];
            for (Participant_Workflow_Step__mdt step : steps) {
                if (step.DeveloperName == currentOutcome.Step__c) {
                    break;
                }
                if (String.isNotBlank(step.Success_Checkbox_Field__c))
                    for (String field : step.Success_Checkbox_Field__c.split(';')) {
                        participantEnrollment.put(field, true);
                    }
            }
        }
    }

    public static List<String> filterStatusesForCTPSettings(
        List<String> statuses,
        Clinical_Trial_Profile__c ctp
    ) {
        List<Participant_Workflow_Step__mdt> steps = getWorkflowSteps(ctp);
        Map<String, Map<String, Participant_Workflow_Outcome__mdt>> outcomesMap = getOutcomesMap(
            steps,
            ctp
        );
        List<String> filteredStatuses = new List<String>();
        for (String status : statuses) {
            if (outcomesMap.containsKey(status)) {
                filteredStatuses.add(status);
            }
        }
        return filteredStatuses;
    }

    public class ParticipantWorkflowWrapper {
        @AuraEnabled
        public List<ParticipantWorkflowStepWrapper> steps;
        @AuraEnabled
        public Integer currentStepInd;
        
        @AuraEnabled
        public Date sendToSHDate;
        @AuraEnabled
        public Boolean sendToSH;
        @AuraEnabled
        public String sendToSHReason;   
        @AuraEnabled
        public String fovhistory;
        @AuraEnabled
        public List<DateTime> fovCreateddate;
        @AuraEnabled
        public List<String> fovCreatedby;       
    }
    
    public class ParticipantWorkflowStepWrapper {
        //
        @AuraEnabled
        public list<ParticipantWorkflowHistoryWrapper> historyList = new list<ParticipantWorkflowHistoryWrapper>();
        @AuraEnabled
        public String stepName;
        //
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Date dateStatus;
        @AuraEnabled
        public Boolean editable;
        @AuraEnabled
        public String state;
        @AuraEnabled
        public String cardTitle;
        @AuraEnabled
        public String historyTitle;
        @AuraEnabled
        public String outcomePlaceholder;
        @AuraEnabled
        public List<LabelValueItem> outcomeList;
        @AuraEnabled
        public Map<String, List<LabelValueItem>> reasonMap;
        @AuraEnabled
        public Map<String, Boolean> notesRequiredMap;
        @AuraEnabled
        public String outcome;
        @AuraEnabled
        public String reason;
        @AuraEnabled
        public String notes;
        @AuraEnabled
        public List<ParticipantWorkflowHistoryWrapper> stepHistory;
        @AuraEnabled
        public List<ParticipantWorkflowFieldGroupWrapper> formFieldGroups;
        @AuraEnabled
        public Map<String, List<DependentFieldWrapper>> fieldDependencyMap;
        @AuraEnabled
        public List<String> successOutcomes;
        @AuraEnabled
        public Boolean currentOutcomeSuccess;
        @AuraEnabled
        public Boolean isCurrentStepValid = true;
        @AuraEnabled
        public Boolean isCurrentStep = false;
        @AuraEnabled
        public String outcomeDisclaimer;
        @AuraEnabled
        public Boolean outcomeEditable = true;
    }

    public class ParticipantWorkflowHistoryWrapper {
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String detail;
        @AuraEnabled
        public DateTime detailDate;
        @AuraEnabled
        public String createdBy;
        @AuraEnabled
        public String source;
        @AuraEnabled
        public Boolean isAdditionalNote;
    }

    public class ParticipantWorkflowFieldGroupWrapper {
        @AuraEnabled
        public String title;
        @AuraEnabled
        public List<ParticipantWorkflowFieldWrapper> fields;
    }

    public class ParticipantWorkflowFieldWrapper {
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String requiredTitle;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String style;
        @AuraEnabled
        public Boolean required;
        @AuraEnabled
        public Boolean readonly;
        @AuraEnabled
        public List<LabelValueItem> values;
        @AuraEnabled
        public String field;
        @AuraEnabled
        public String fieldType;
        @AuraEnabled
        public Integer numOccurences;
        @AuraEnabled
        public Boolean dependent;
        @AuraEnabled
        public Boolean dependentActive;
        @AuraEnabled
        public Boolean strictDependency;
        @AuraEnabled
        public Boolean onlyFutureDate;
        @AuraEnabled
        public Boolean onlyPastDate;
        @AuraEnabled
        public Map<String, String> populateFields;
        @AuraEnabled
        public String populateFromDependent;
        @AuraEnabled
        public String validationMessageIfFalse;
        @AuraEnabled
        public String validValue;
        @AuraEnabled
        public Boolean smartPicklist = false;
    }

    public class PathStepWrapper {
        @AuraEnabled
        public String state;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String reason;
        @AuraEnabled
        public String dateOccured;
        @AuraEnabled
        public Date occuredDate;
        @AuraEnabled
        public String left;
        @AuraEnabled
        public String right;
        @AuraEnabled
        public Boolean isCurrent = false;
        @AuraEnabled
        public List<ParticipantWorkflowHistoryWrapper> stepHistory;
    }

    public class DependentFieldWrapper {
        @AuraEnabled
        public String fieldName;
        @AuraEnabled
        public String controllingValue;
    }
}