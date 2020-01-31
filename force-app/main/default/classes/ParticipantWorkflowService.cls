/**
 * Created by Andrii Kryvolap.
 */

public without sharing class ParticipantWorkflowService {

    public static ParticipantWorkflowWrapper prepareParticipantWorkflow(Clinical_Trial_Profile__c ctp, Participant_Enrollment__c pe){
        ParticipantWorkflowWrapper wrapper = new ParticipantWorkflowWrapper();
        wrapper.steps = new List<ParticipantWorkflowService.ParticipantWorkflowStepWrapper>();
        List<Participant_Workflow_Step__mdt> steps = [SELECT Condition__c, Name_Label__c FROM Participant_Workflow_Step_mdt ORDER By Order__c ASC];
        for(Participant_Workflow_Step__mdt step : steps){
            if(step.Condition__c == null || step.Condition__c =='' || ConditionCheckerService.checkConditionForObject(step.Condition__c, ctp)){
                ParticipantWorkflowStepWrapper stepWrapper = new ParticipantWorkflowStepWrapper();
                stepWrapper.title = step.Name_Label__c;
                stepWrapper.status = step.Name_Label__c + ' status';
                wrapper.steps.add(stepWrapper);
            }
        }
        if(!wrapper.steps.isEmpty()){
            wrapper.currentStep = wrapper.steps[0];
        }
        return wrapper;
    }



    public class ParticipantWorkflowWrapper{
        @AuraEnabled public List<ParticipantWorkflowStepWrapper> steps;
        @AuraEnabled public ParticipantWorkflowStepWrapper currentStep;
    }

    public class ParticipantWorkflowStepWrapper{
        @AuraEnabled public String title;
        @AuraEnabled public String status;
    }

}