/**
 * Created by Leonid Bartenev
 */

public class ParticipantItem {
    
    @AuraEnabled public Participant_Enrollment__c pe;
    @AuraEnabled public Map<String, PEStatusState> peStatusStateMap = PEStatusState.STATUSES_MAP;
    @AuraEnabled public List<String> peStatusesPathList = PEStatusState.STATUS_STEPS_LIST;
    @AuraEnabled public List<LabelValueItem> participationFlowSteps;
    @AuraEnabled public Boolean showParticipationSteps;
    @AuraEnabled public Boolean showVisits;
    @AuraEnabled public List<ParticipantWorkflowService.PathStepWrapper> pathItems;

    public ParticipantItem(Participant_Enrollment__c pe){
        pe.Referral_Source__c = TranslateHelper.getPickListLabel(Participant_Enrollment__c.Referral_Source__c, pe.Referral_Source__c);
        this.pe = pe;
        this.participationFlowSteps = PEStatusState.getParticipationFlowStepsLV(pe);
        this.showParticipationSteps = PEStatusState.getParticipationFlowSteps(pe).contains(pe.Participant_Status__c);
    }

    public ParticipantItem(ParticipantService.ParticipantState participantState) {
        this.pe = participantState.pe;
        this.showVisits = pe.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c && participantState.showVisits
                && pe.Clinical_Trial_Profile__r.Visit_Schedule_Is_Available__c;
        this.participationFlowSteps = PEStatusState.getParticipationFlowStepsLV(participantState.pe);
        this.showParticipationSteps = PEStatusState.getParticipationFlowSteps(participantState.pe).contains(participantState.pe.Participant_Status__c);
    }
}