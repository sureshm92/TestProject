/**
 * Created by Leonid Bartenev
 */

public class ParticipantItem {
    
    @AuraEnabled public Participant_Enrollment__c pe;
    @AuraEnabled public Map<String, PEStatusState> peStatusStateMap = PEStatusState.STATUSES_MAP;
    @AuraEnabled public List<String> peStatusesPathList = PEStatusState.STATUS_STEPS_LIST;
    @AuraEnabled public List<LabelValueItem> psePathSteps = PSEService.getInstance().getPSEPathSteps();
    @AuraEnabled public Boolean showPSESteps;
    
    public ParticipantItem(Participant_Enrollment__c pe){
        Boolean isParticipant = CommunityService.getUserContact().userCommunityMode__c == CommunityService.USER_MODE_PARTICIPANT;
        pe.Referral_Source__c = TranslateHelper.getPickListLabel(Participant_Enrollment__c.Referral_Source__c, pe.Referral_Source__c);
        this.pe = pe;
        this.showPSESteps = pe.Study_Site__r.Clinical_Trial_Profile__r.Participating_in_Patient_Portal__c == 'Yes' || !isParticipant ;
    }

    public ParticipantItem(ParticipantService.ParticipantState participantState) {
        Boolean isParticipant = CommunityService.getUserContact().userCommunityMode__c == CommunityService.USER_MODE_PARTICIPANT;
        this.pe = participantState.pe;
        this.showPSESteps = participantState.isPremium || !isParticipant;
    }
}