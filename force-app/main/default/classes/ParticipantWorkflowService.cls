/**
 * Created by Andrii Kryvolap.
 */

public without sharing class ParticipantWorkflowService {

    public static ParticipantWorkflowWrapper prepareParticipantWorkflow(Clinical_Trial_Profile__c ctp, Participant_Enrollment__c pe){
        ParticipantWorkflowWrapper wrapper = new ParticipantWorkflowWrapper();
        wrapper.steps = new List<ParticipantWorkflowService.ParticipantWorkflowStepWrapper>();
        List<Participant_Workflow_Step__mdt> steps = [
                SELECT DeveloperName, Condition__c, Name_Label__c, Order__c, History_Label__c,
                        Card_Name_Label__c, No_Outcome_Label__c, Failed_State_Editing_Enabled__c,
                        Outcome_Placeholder_Label__c, History_Item_Title_Template_Label__c,
                        History_Item_Details_Template_Label__c, Form_Fields__c,In_Progress_Condition__c,
                        Success_Condition__c, Success_Date_Field__c, In_Progress_Date_Field__c
                FROM Participant_Workflow_Step__mdt ORDER By Order__c ASC];
        Set<String> stepNames = new Set<String>();
        for(Participant_Workflow_Step__mdt step : steps){
            stepNames.add(step.DeveloperName);
        }
        Map<String, Participant_Workflow_Outcome__mdt> outcomesMap = getOutcomesMap(stepNames);
        Map<String, List<Participant_Enrollment_Status_History__c>> peshMapByStep = getPESHByStep(pe, outcomesMap);
        Map<String, Participant_Workflow_Form_Field__mdt> fieldsMap = getFieldsMap(ctp);
        Boolean previousStepSuccess = false;
        for(Participant_Workflow_Step__mdt step : steps){
            if(String.isBlank(step.Condition__c) || ConditionCheckerService.checkConditionForObject(step.Condition__c, ctp)){
                ParticipantWorkflowStepWrapper stepWrapper = createStepWrapper(step, outcomesMap, peshMapByStep, previousStepSuccess, fieldsMap, pe);
                previousStepSuccess = stepWrapper.state == PEStatusState.STATUS_STATE_SUCCESS;

                if(stepWrapper.state == PEStatusState.STATUS_STATE_SUCCESS
                        || stepWrapper.state == PEStatusState.STATUS_STATE_IN_PROGRESS
                        || stepWrapper.state == PEStatusState.STATUS_STATE_FAILURE){
                    wrapper.currentStep = stepWrapper;
                    if(!wrapper.steps.isEmpty()){
                        wrapper.steps[wrapper.steps.size()-1].editable = false;
                    }
                }
                wrapper.steps.add(stepWrapper);
            }
        }
        if(wrapper.currentStep == null){
            wrapper.currentStep = wrapper.steps[wrapper.steps.size()-1];
        }
        return wrapper;
    }

    private static Map<String, Participant_Workflow_Outcome__mdt> getOutcomesMap(Set<String> stepNames){
        Map<String, Participant_Workflow_Outcome__mdt> result = new Map<String, Participant_Workflow_Outcome__mdt>();
        for(Participant_Workflow_Outcome__mdt outcome : [
                SELECT Status_Name__c, Step__c, Reasons_List__c, State__c,Order__c
                FROM Participant_Workflow_Outcome__mdt WHERE Step__c IN :stepNames ORDER BY Order__c ASC]){
            result.put(outcome.Status_Name__c, outcome);
        }
        return result;
    }

    private static Map<String, List<Participant_Enrollment_Status_History__c>> getPESHByStep(Participant_Enrollment__c pe,
            Map<String, Participant_Workflow_Outcome__mdt> outcomesMap){
        Map<String, List<Participant_Enrollment_Status_History__c>> result = new Map<String, List<Participant_Enrollment_Status_History__c>>();
        for(Participant_Enrollment_Status_History__c pesh: [
                SELECT Id, Date__c, Status__c, Reason__c, Notes__c, CreatedBy.Name,
                        ParticipantEnrollment__r.Referral_Source__c, ParticipantEnrollment__r.Referral_Completedby_Name__c,
                        ParticipantEnrollment__r.Source_Type__c, ParticipantEnrollment__r.PI_Contact__r.Name
                FROM Participant_Enrollment_Status_History__c
                WHERE ParticipantEnrollment__c = :pe.Id
                ORDER BY Date__c DESC]){
            if(outcomesMap.containsKey(pesh.Status__c)){
                String stepName = outcomesMap.get(pesh.Status__c).Step__c;
                if(!result.containsKey(stepName)){
                    result.put(stepName, new List<Participant_Enrollment_Status_History__c>());
                }
                result.get(stepName).add(pesh);
            }
        }
        return result;
    }

    private static ParticipantWorkflowStepWrapper createStepWrapper(Participant_Workflow_Step__mdt step,
            Map<String, Participant_Workflow_Outcome__mdt> outcomesMap,
            Map<String, List<Participant_Enrollment_Status_History__c>> peshMap, Boolean previousStepSuccess,
            Map<String, Participant_Workflow_Form_Field__mdt> fieldsMap,
            Participant_Enrollment__c pe){
        ParticipantWorkflowStepWrapper stepWrapper = new ParticipantWorkflowStepWrapper();
        stepWrapper.title = TranslateHelper.getLabelValue(step.Name_Label__c);
        stepWrapper.cardTitle = TranslateHelper.getLabelValue(step.Card_Name_Label__c);
        stepWrapper.historyTitle = TranslateHelper.getLabelValue(step.History_Label__c);
        stepWrapper.outcomePlaceholder = String.isBlank(step.Outcome_Placeholder_Label__c)?
                TranslateHelper.getLabelValue('PG_RP_L_Not_selected'):
                TranslateHelper.getLabelValue(step.Outcome_Placeholder_Label__c);
        stepWrapper.stepHistory = new List<ParticipantWorkflowService.ParticipantWorkflowHistoryWrapper>();
        if(!peshMap.containsKey(step.DeveloperName)){
            Boolean stepSuccessful =String.isNotBlank(step.Success_Condition__c) && ConditionCheckerService.checkConditionForObject(step.Success_Condition__c, pe);

            Boolean stepInProgress = String.isBlank(step.In_Progress_Condition__c) || ConditionCheckerService.checkConditionForObject(step.In_Progress_Condition__c, pe);
            stepWrapper.state = previousStepSuccess?
                    (stepSuccessful?
                            PEStatusState.STATUS_STATE_SUCCESS
                            :(stepInProgress?
                                    PEStatusState.STATUS_STATE_IN_PROGRESS
                                    :PEStatusState.STATUS_STATE_NEUTRAL))
                    :PEStatusState.STATUS_STATE_NEUTRAL;
            if(stepSuccessful && step.Success_Date_Field__c != null){
                stepWrapper.status = ((Date)pe.get(step.Success_Date_Field__c)).format();
            }
            else{
                stepWrapper.status = TranslateHelper.getLabelValue(step.No_Outcome_Label__c);
            }
        }
        else{
            List<Participant_Enrollment_Status_History__c> peshList = peshMap.get(step.DeveloperName);
            stepWrapper.state = outcomesMap.get(peshList[0].Status__c).State__c;
            stepWrapper.status = TranslateHelper.getPickListLabel(Participant_Enrollment__c.Participant_Status__c,peshList[0].Status__c)
                    + ' ' + peshList[0].Date__c.date().format();
            stepWrapper.outcome = peshList[0].Status__c;
            for(Participant_Enrollment_Status_History__c pesh: peshList){
                ParticipantWorkflowHistoryWrapper historyWrapper = createHistoryWrapper(pesh, step);
                stepWrapper.stepHistory.add(historyWrapper);
            }
        }
        stepWrapper.editable = stepWrapper.state == PEStatusState.STATUS_STATE_IN_PROGRESS
                || (stepWrapper.state != PEStatusState.STATUS_STATE_NEUTRAL && step.Failed_State_Editing_Enabled__c);
        stepWrapper.outcomeList = new List<LabelValueItem>();
        stepWrapper.successOutcomes = new List<String>();
        stepWrapper.reasonMap = new Map<String, List<LabelValueItem>>();
        stepWrapper.notesRequiredMap = new Map<String, Boolean>();
        for(Participant_Workflow_Outcome__mdt outcome : outcomesMap.values()){
            if(outcome.Step__c == step.DeveloperName){
                if(outcome.State__c ==PEStatusState.STATUS_STATE_SUCCESS){
                    stepWrapper.successOutcomes.add(outcome.Status_Name__c);
                    if(stepWrapper.outcome == outcome.State__c){
                        stepWrapper.currentOutcomeSuccess = true;
                    }
                }
                stepWrapper.outcomeList.add(new LabelValueItem(TranslateHelper.getPickListLabel(Participant_Enrollment__c.Participant_Status__c,outcome.Status_Name__c),outcome.Status_Name__c));
                List<LabelValueItem> reasonsList = new List<LabelValueItem>();
                if(outcome.Reasons_List__c == null){
                    //reasonsList.add(new LabelValueItem('', ''));
                    stepWrapper.notesRequiredMap.put(outcome.Status_Name__c + ';', false);
                }
                else{
                    for(String reason : outcome.Reasons_List__c.split(';')){
                        String reasonNoDecoration = reason.remove('*');
                        reasonsList.add(new LabelValueItem(TranslateHelper.getPickListLabel(Participant_Enrollment__c.Non_Enrollment_Reason__c,reasonNoDecoration), reasonNoDecoration));
                        stepWrapper.notesRequiredMap.put(outcome.Status_Name__c + ';' + reasonNoDecoration, reason.contains('*'));
                    }
                }
                stepWrapper.reasonMap.put(outcome.Status_Name__c, reasonsList);
            }
        }
        System.debug('notesRequiredMap:' + stepWrapper.notesRequiredMap);
        stepWrapper.fieldDependencyMap = new Map<String, List<String>>();
        stepWrapper.formFieldGroups = createFieldGroupWrapperes(step, fieldsMap, pe, stepWrapper.fieldDependencyMap);
        stepWrapper.notes = '';
        return stepWrapper;
    }

    private static ParticipantWorkflowHistoryWrapper createHistoryWrapper(Participant_Enrollment_Status_History__c pesh, Participant_Workflow_Step__mdt step){
        ParticipantWorkflowHistoryWrapper historyWrapper = new ParticipantWorkflowHistoryWrapper();
        String statusString = TranslateHelper.getPickListLabel(Participant_Enrollment__c.Participant_Status__c,pesh.Status__c);
        String reasonString = (String.isNotBlank(pesh.Reason__c)?' - ' + TranslateHelper.getPickListLabel(Participant_Enrollment__c.Non_Enrollment_Reason__c,pesh.Reason__c.trim()):'');
        String notesString = (String.isNotBlank(pesh.Notes__c)?', ' + pesh.Notes__c.trim():'');
        if(String.isEmpty(step.History_Item_Title_Template_Label__c)){
            historyWrapper.title = statusString
                    + reasonString
                    + notesString;
        }
        else{
            historyWrapper.title = TranslateHelper.getLabelValue(step.History_Item_Title_Template_Label__c).
                    replace('##Status',statusString).
                    replace('##Reason',reasonString).
                    replace('##Notes',notesString);
        }
        if(String.isBlank(step.History_Item_Details_Template_Label__c)){
            historyWrapper.detail = ' '+ TranslateHelper.getLabelValue('PE_Status_History_On_Date') +' ' + pesh.Date__c.date().format()
                    + ' ' + TranslateHelper.getLabelValue('PG_IMI_L_by_user') + ' '+ pesh.CreatedBy.Name;
        }
        else{
            String sourceString = String.isBlank(pesh.ParticipantEnrollment__r.Referral_Completedby_Name__c)?
                    (pesh.ParticipantEnrollment__r.Source_Type__c == ParticipantEnrollmentService.PE_SOURCE_TYPE_EPR?
                            pesh.ParticipantEnrollment__r.Source_Type__c
                            :pesh.ParticipantEnrollment__r.PI_Contact__r.Name):
                    pesh.ParticipantEnrollment__r.Referral_Completedby_Name__c;
            historyWrapper.detail = ' ' + TranslateHelper.getLabelValue(step.History_Item_Details_Template_Label__c).
                    replace('##Date',pesh.Date__c.date().format()).
                    replace('##ByUser',pesh.CreatedBy.Name).
                    replace('##Source', sourceString);
        }
        return historyWrapper;
    }

    private static List<ParticipantWorkflowFieldGroupWrapper> createFieldGroupWrapperes(Participant_Workflow_Step__mdt step,
            Map<String, Participant_Workflow_Form_Field__mdt> fieldsMap, Participant_Enrollment__c pe, Map<String, List<String>> fieldDependencyMap){
        List<ParticipantWorkflowFieldGroupWrapper> result = new List<ParticipantWorkflowService.ParticipantWorkflowFieldGroupWrapper>();
        if(String.isNotBlank(step.Form_Fields__c)){
            for(string fieldGroupString : step.Form_Fields__c.split('\\|')){
                ParticipantWorkflowFieldGroupWrapper groupWrapper = new ParticipantWorkflowFieldGroupWrapper();
                List<String> fieldGroupStringParts = fieldGroupString.split('#');
                String fieldsString;
                if(fieldGroupStringParts.size() == 1){
                    fieldsString = fieldGroupStringParts[0];
                }
                else{
                    groupWrapper.title = TranslateHelper.getLabelValue(fieldGroupStringParts[0]);
                    fieldsString = fieldGroupStringParts[1];
                }
                groupWrapper.fields = createFieldWrappers(step, fieldsString, fieldsMap, pe, fieldDependencyMap);
                result.add(groupWrapper);
            }
        }
        return result;
    }

    private static List<ParticipantWorkflowFieldWrapper> createFieldWrappers(Participant_Workflow_Step__mdt step,
            String fieldsString, Map<String, Participant_Workflow_Form_Field__mdt> fieldsMap,
            Participant_Enrollment__c pe, Map<String, List<String>> fieldDependencyMap){
        List<ParticipantWorkflowFieldWrapper> fieldWrappers = new List<ParticipantWorkflowFieldWrapper>();
        for(String lineString: fieldsString.split(';')){
            List<String> atomicFieldStrings = lineString.split(',');
            ParticipantWorkflowFieldWrapper currentFieldWrapper;
            for(String atomicFieldString : atomicFieldStrings){
                if(atomicFieldString == 'blank'){
                    currentFieldWrapper = new ParticipantWorkflowFieldWrapper();
                    currentFieldWrapper.type = 'blank';
                    currentFieldWrapper.style = 'slds-size--1-of-'+String.valueOf(atomicFieldStrings.size());
                    currentFieldWrapper.numOccurences = 1;
                }
                Participant_Workflow_Form_Field__mdt fieldSetting = fieldsMap.get(atomicFieldString);
                if(fieldSetting == null){
                    currentFieldWrapper = null;
                    continue;
                }
                if(currentFieldWrapper != null && (currentFieldWrapper.field == fieldSetting.Field_Name__c
                        && currentFieldWrapper.type == fieldSetting.Type__c )){
                    currentFieldWrapper.numOccurences++;
                    currentFieldWrapper.style = 'slds-size--'+String.valueOf(currentFieldWrapper.numOccurences)+'-of-'
                            + String.valueOf(atomicFieldStrings.size());
                }
                else{
                    currentFieldWrapper = new ParticipantWorkflowFieldWrapper();
                    currentFieldWrapper.title = TranslateHelper.getLabelValue(fieldSetting.Title_Label__c);
                    currentFieldWrapper.style = 'slds-size--1-of-'+String.valueOf(atomicFieldStrings.size());
                    currentFieldWrapper.field = fieldSetting.Field_Name__c;
                    currentFieldWrapper.readonly = fieldSetting.Readonly_for_Steps__c != null && fieldSetting.Readonly_for_Steps__c.contains(step.DeveloperName);
                    currentFieldWrapper.required = fieldSetting.Required_for_Steps__c != null && fieldSetting.Required_for_Steps__c.contains(step.DeveloperName);
                    currentFieldWrapper.onlyFutureDate = fieldSetting.Only_Future_Dates__c;
                    currentFieldWrapper.onlyPastDate = fieldSetting.Only_Past_Dates__c;
                    currentFieldWrapper.numOccurences = 1;
                    currentFieldWrapper.fieldType = fieldSetting.Type__c;
                    if(String.isNotBlank(fieldSetting.Depends_On_Field__c)){
                        currentFieldWrapper.dependent = true;
                        currentFieldWrapper.readonly = true;
                        if(!fieldDependencyMap.containsKey(fieldSetting.Depends_On_Field__c)){
                            fieldDependencyMap.put(fieldSetting.Depends_On_Field__c, new List<String>{fieldSetting.Field_Name__c});
                        }
                        else{
                            fieldDependencyMap.get(fieldSetting.Depends_On_Field__c).add(fieldSetting.Field_Name__c);
                        }
                    }
                    switch on fieldSetting.Type__c {
                        when 'visitplan'{
                            currentFieldWrapper.type = 'picklist';
                            currentFieldWrapper.value = pe.Visit_Plan__c;
                            currentFieldWrapper.values = StudySiteService.getVisitPlansLVList(pe.Study_Site__c);
                        }
                        when 'time' {
                            currentFieldWrapper.type = 'time';
                            if(pe.get(fieldSetting.Field_Name__c) instanceof Time) {
                                currentFieldWrapper.value = String.valueOf((Time)pe.get(fieldSetting.Field_Name__c));
                            }
                            else {
                                currentFieldWrapper.value = pe.get(fieldSetting.Field_Name__c)==null?'':((DateTime)pe.get(fieldSetting.Field_Name__c)).format('TT:MM');
                            }
                        }
                        when 'date' {
                            currentFieldWrapper.type = 'date';
                            if(pe.get(fieldSetting.Field_Name__c) instanceof Date) {
                                System.debug('fieldSetting.Field_Name__c');
                                System.debug(pe.get(fieldSetting.Field_Name__c));
                                currentFieldWrapper.value = pe.get(fieldSetting.Field_Name__c)==null?'':String.valueOf(pe.get(fieldSetting.Field_Name__c));
                            }
                            else {
                                currentFieldWrapper.value = pe.get(fieldSetting.Field_Name__c)==null?'': ((DateTime)pe.get(fieldSetting.Field_Name__c)).format('yyyy-MM-dd');
                            }
                        }
                        when 'text' {
                            currentFieldWrapper.type = 'text';
                            currentFieldWrapper.value =  (String)pe.get(fieldSetting.Field_Name__c);
                        }
                        when 'boolean' {
                            if(String.isBlank(fieldSetting.True_Value_Label__c)) {
                                currentFieldWrapper.type = 'checkbox';
                                currentFieldWrapper.value = String.valueOf((Boolean)pe.get(fieldSetting.Field_Name__c));
                            }
                            else {
                                currentFieldWrapper.type = 'picklist';
                                currentFieldWrapper.value = String.valueOf((Boolean)pe.get(fieldSetting.Field_Name__c));
                                currentFieldWrapper.values = new List<LabelValueItem>{
                                        new LabelValueItem(TranslateHelper.getLabelValue(fieldSetting.True_Value_Label__c),'true'),
                                        new LabelValueItem(TranslateHelper.getLabelValue(fieldSetting.False_Value_Label__c),'false')
                                };
                            }
                        }
                        when else {
                            currentFieldWrapper.type = 'blank';
                        }
                    }
                }
                fieldWrappers.add(currentFieldWrapper);
            }
        }
        return fieldWrappers;
    }

    public static Participant_Enrollment_Status_History__c createPESHFromStepWrapper(ParticipantWorkflowStepWrapper stepWrapper, String peId){
        Participant_Enrollment_Status_History__c pesh;
        if(String.isNotBlank(stepWrapper.outcome)){
            pesh = new Participant_Enrollment_Status_History__c(
                    Status__c = stepWrapper.outcome,
                    Reason__c = stepWrapper.reason,
                    Notes__c = stepWrapper.notes,
                    Date__c = Datetime.now(),
                    ParticipantEnrollment__c = peId
            ) ;
        }
        return pesh;
    }

    public static void populatePEFromStepWrapper(ParticipantWorkflowStepWrapper stepWrapper, Participant_Enrollment__c pe){
        if(!stepWrapper.formFieldGroups.isEmpty()){
            for(ParticipantWorkflowService.ParticipantWorkflowFieldGroupWrapper fieldGroup: stepWrapper.formFieldGroups) {
                for (ParticipantWorkflowService.ParticipantWorkflowFieldWrapper field: fieldGroup.fields){
                    if( field.readonly || String.isBlank(field.value)){
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
        }
    }

    public static Map<String, Participant_Workflow_Form_Field__mdt> getFieldsMap(Clinical_Trial_Profile__c ctp){
        Map<String, Participant_Workflow_Form_Field__mdt> result = new Map<String, Participant_Workflow_Form_Field__mdt>();
        for(Participant_Workflow_Form_Field__mdt field: [
                SELECT Field_Name__c, Type__c, Condition__c, True_Value_Label__c, Title_Label__c, False_Value_Label__c,
                        DeveloperName, Required_for_Steps__c, Readonly_for_Steps__c, Depends_On_Field__c, Only_Future_Dates__c, Only_Past_Dates__c
                FROM Participant_Workflow_Form_Field__mdt]){
            if(String.isBlank(field.Condition__c) || ConditionCheckerService.checkConditionForObject(field.Condition__c, ctp)){
                result.put(field.DeveloperName, field);
            }
        }
        return result;
    }

    public static void populatePatientItemsWithPathWrappers(List<ParticipantItem> participantItems){
        Set<Id> ctpIds = new Set<Id>();
        Set<Id> peIds = new Set<Id>();
        for(ParticipantItem pi : participantItems){
            ctpIds.add(pi.pe.Clinical_Trial_Profile__c);
            peIds.add(pi.pe.Id);
        }
        List<Participant_Workflow_Step__mdt> steps = [
                SELECT DeveloperName, Condition__c, Name_Label__c, Order__c, History_Label__c,
                        Card_Name_Label__c, No_Outcome_Label__c, Failed_State_Editing_Enabled__c,
                        Outcome_Placeholder_Label__c, History_Item_Title_Template_Label__c,
                        History_Item_Details_Template_Label__c, Form_Fields__c,In_Progress_Condition__c,
                        Success_Condition__c, Success_Date_Field__c, In_Progress_Date_Field__c
                FROM Participant_Workflow_Step__mdt ORDER By Order__c ASC];
        Set<String> stepNames = new Set<String>();
        for(Participant_Workflow_Step__mdt step : steps){
            stepNames.add(step.DeveloperName);
        }
        Map<String, Participant_Workflow_Outcome__mdt> outcomesMap = getOutcomesMap(stepNames);
        Map<Id, List<Participant_Workflow_Step__mdt>> studyStepsList = new Map<Id, List<Participant_Workflow_Step__mdt>>();
        for(Clinical_Trial_Profile__c ctp : StudyTrialService.getFullTrials(ctpIds)){
            List<Participant_Workflow_Step__mdt> stepList = new List<Participant_Workflow_Step__mdt>();
            for(Participant_Workflow_Step__mdt step : steps){
                if(String.isBlank(step.Condition__c) || ConditionCheckerService.checkConditionForObject(step.Condition__c, ctp)){
                    stepList.add(step);
                }
            }
            studyStepsList.put(ctp.Id, stepList);
        }
        Map<Id, Map<String, Participant_Enrollment_Status_History__c>> lastHistoryByStepMap = new Map<Id, Map<String, Participant_Enrollment_Status_History__c>>();
        for(Participant_Enrollment_Status_History__c pesh: [
                SELECT Id, Date__c, Status__c, Reason__c, Notes__c, CreatedBy.Name,
                        ParticipantEnrollment__r.Referral_Source__c, ParticipantEnrollment__r.Referral_Completedby_Name__c,
                        ParticipantEnrollment__r.Source_Type__c, ParticipantEnrollment__r.PI_Contact__r.Name
                FROM Participant_Enrollment_Status_History__c
                WHERE ParticipantEnrollment__c IN :peIds
                ORDER BY Date__c DESC]){
            if(!lastHistoryByStepMap.containsKey(pesh.ParticipantEnrollment__c)){
                lastHistoryByStepMap.put(pesh.ParticipantEnrollment__c, new Map<String, Participant_Enrollment_Status_History__c>());
            }
            Map<String, Participant_Enrollment_Status_History__c> peLastHistoryMap = lastHistoryByStepMap.get(pesh.ParticipantEnrollment__c);
            if(outcomesMap.containsKey(pesh.Status__c)){
                String stepName = outcomesMap.get(pesh.Status__c).Step__c;
                if(!peLastHistoryMap.containsKey(stepName)){
                    peLastHistoryMap.put(stepName, pesh);
                }
            }
        }
        for(ParticipantItem pi : participantItems){
            pi.pathItems = new List<ParticipantWorkflowService.PathStepWrapper>();
            if(lastHistoryByStepMap.containsKey(pi.pe.Id)){
                PathStepWrapper previousStep = null;
                for(Participant_Workflow_Step__mdt step : studyStepsList.get(pi.pe.Clinical_Trial_Profile__c)){
                    PathStepWrapper currentStep = createPathStepWrapper(pi.pe, lastHistoryByStepMap.get(pi.pe.Id).get(step.DeveloperName), step, outcomesMap, previousStep);
                    pi.pathItems.add(currentStep);
                    previousStep = currentStep;
                }
            }
        }

    }

    private static PathStepWrapper createPathStepWrapper(Participant_Enrollment__c pe, Participant_Enrollment_Status_History__c pesh,
            Participant_Workflow_Step__mdt step, Map<String, Participant_Workflow_Outcome__mdt> outcomesMap, PathStepWrapper previousStep){
        PathStepWrapper result = new PathStepWrapper();
        if(pesh!=null){
            result.title = TranslateHelper.getPickListLabel(Participant_Enrollment__c.Participant_Status__c,pesh.Status__c);
            result.reason = TranslateHelper.getPickListLabel(Participant_Enrollment__c.Non_Enrollment_Reason__c,pesh.Reason__c);
            if(pesh.Date__c != null){
                result.dateOccured = pesh.Date__c.date().format();
            }
            result.state = outcomesMap.get(pesh.Status__c).State__c;
            result.left = PEStatusState.STATUS_STATE_SUCCESS;
            if(previousStep != null) previousStep.right = PEStatusState.STATUS_STATE_SUCCESS;
            result.isCurrent = pe.Participant_Status__c == pesh.Status__c;
            result.right = PEStatusState.STATUS_STATE_NEUTRAL;
        }
        else{
            result.title = TranslateHelper.getLabelValue(step.Card_Name_Label__c);
            if(step.Success_Condition__c != null && ConditionCheckerService.checkConditionForObject(step.Success_Condition__c, pe)){
                result.state = PEStatusState.STATUS_STATE_SUCCESS;
                result.left = PEStatusState.STATUS_STATE_SUCCESS;
                if(step.Success_Date_Field__c != null && pe.get(step.Success_Date_Field__c)!= null){
                    result.dateOccured = ((Date)pe.get(step.Success_Date_Field__c)).format();
                }
                if(previousStep != null) previousStep.right = PEStatusState.STATUS_STATE_SUCCESS;

            }
            else if(step.In_Progress_Condition__c != null && ConditionCheckerService.checkConditionForObject(step.In_Progress_Condition__c, pe)){
                result.state = PEStatusState.STATUS_STATE_IN_PROGRESS;
                result.left = PEStatusState.STATUS_STATE_SUCCESS;
                if(step.In_Progress_Date_Field__c != null && pe.get(step.In_Progress_Date_Field__c) != null){
                    result.dateOccured = ((Date)pe.get(step.In_Progress_Date_Field__c)).format();
                }
                if(previousStep != null) previousStep.right = PEStatusState.STATUS_STATE_SUCCESS;
            }
            else{
                result.state = PEStatusState.STATUS_STATE_NEUTRAL;
                result.left = PEStatusState.STATUS_STATE_NEUTRAL;
            }
            result.right = PEStatusState.STATUS_STATE_NEUTRAL;
        }

        return result;
    }

    public class ParticipantWorkflowWrapper{
        @AuraEnabled public List<ParticipantWorkflowStepWrapper> steps;
        @AuraEnabled public ParticipantWorkflowStepWrapper currentStep;
    }

    public class ParticipantWorkflowStepWrapper{
        @AuraEnabled public String title;
        @AuraEnabled public String status;
        @AuraEnabled public Boolean editable;
        @AuraEnabled public String state;
        @AuraEnabled public String cardTitle;
        @AuraEnabled public String historyTitle;
        @AuraEnabled public String outcomePlaceholder;
        @AuraEnabled public List<LabelValueItem> outcomeList;
        @AuraEnabled public Map<String, List<LabelValueItem>> reasonMap;
        @AuraEnabled public Map<String, Boolean> notesRequiredMap;
        @AuraEnabled public String outcome;
        @AuraEnabled public String reason;
        @AuraEnabled public String notes;
        @AuraEnabled public List<ParticipantWorkflowHistoryWrapper> stepHistory;
        @AuraEnabled public List<ParticipantWorkflowFieldGroupWrapper> formFieldGroups;
        @AuraEnabled public Map<String, List<String>> fieldDependencyMap;
        @AuraEnabled public List<String> successOutcomes;
        @AuraEnabled public Boolean currentOutcomeSuccess;
    }

    public class ParticipantWorkflowHistoryWrapper{
        @AuraEnabled public String title;
        @AuraEnabled public String detail;
    }

    public class ParticipantWorkflowFieldGroupWrapper{
        @AuraEnabled public String title;
        @AuraEnabled public List<ParticipantWorkflowFieldWrapper> fields;
    }

    public class ParticipantWorkflowFieldWrapper{
        @AuraEnabled public String title;
        @AuraEnabled public String  type;
        @AuraEnabled public String  value;
        @AuraEnabled public String  style;
        @AuraEnabled public Boolean  required;
        @AuraEnabled public Boolean  readonly;
        @AuraEnabled public List<LabelValueItem>values;
        @AuraEnabled public String  field;
        @AuraEnabled public String  fieldType;
        @AuraEnabled public Integer numOccurences;
        @AuraEnabled public Boolean dependent;
        @AuraEnabled public Boolean onlyFutureDate;
        @AuraEnabled public Boolean onlyPastDate;
    }

    public class PathStepWrapper{
        @AuraEnabled public String state;
        @AuraEnabled public String  title;
        @AuraEnabled public String  reason;
        @AuraEnabled public String  dateOccured;
        @AuraEnabled public String  left;
        @AuraEnabled public String  right;
        @AuraEnabled public Boolean  isCurrent;
    }


}