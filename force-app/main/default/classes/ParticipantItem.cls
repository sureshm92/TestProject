/**
 * Created by Leonid Bartenev
 */

public class ParticipantItem {
    
    @AuraEnabled public Participant_Enrollment__c pe;
    @AuraEnabled public Map<String, PEStatusState> peStatusStateMap = PEStatusState.STATUSES_MAP;
    @AuraEnabled public List<String> peStatusesPathList = PEStatusState.STATUS_STEPS_LIST;
    @AuraEnabled public List<LabelValueItem> participationFlowSteps = PEStatusState.getParticipationFlowSteps();
    @AuraEnabled public Boolean showParticipationSteps;
    
    public ParticipantItem(Participant_Enrollment__c pe){
        pe.Referral_Source__c = TranslateHelper.getPickListLabel(Participant_Enrollment__c.Referral_Source__c, pe.Referral_Source__c);
        this.pe = pe;
        this.showParticipationSteps = PEStatusState.PE_STATUS_GROUP_PARTICIPATION_FLOW.contains(pe.Participant_Status__c);
    }

    public ParticipantItem(ParticipantService.ParticipantState participantState) {
        this.pe = participantState.pe;
        Boolean isPEInParticipationFlow = PEStatusState.PE_STATUS_GROUP_PARTICIPATION_FLOW.contains(participantState.pe.Participant_Status__c);
        this.showParticipationSteps = isPEInParticipationFlow;
    }
}