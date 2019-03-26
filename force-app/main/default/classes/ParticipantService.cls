/**
 * Created by Leonid Bartenev
 */

public class ParticipantService {
    
    public enum ParticipantStates {ALUMNI, PROSPECT, REFERRAL, PARTICIPANT}
    
    public class ParticipantState{
        @AuraEnabled public ParticipantStates value;
        @AuraEnabled public Participant_Enrollment__c pe;
        @AuraEnabled public Participant_Study_Enrollment__c pse;
        @AuraEnabled public Boolean isDelegate;
        @AuraEnabled public Clinical_Trial_Profile__c ctp;

        public ParticipantState(){
            value = ParticipantStates.PROSPECT;
            isDelegate = false;
        }
    }
    
    public static ParticipantState getParticipantState(){
        ParticipantState state = new ParticipantState();
        List<Participant_Enrollment__c> peList = ParticipantEnrollmentService.getParticipantEnrollmentsForParticipant();
        if(peList.size() >  0) {
            state.pe = peList[0];
            state.isDelegate = state.pe.Participant__r.Contact__c != CommunityService.getUserContact().Id;
            if(PEStatusState.PE_STATUS_GROUP_FAILED.contains(state.pe.Participant_Status__c)){
                state.value = ParticipantStates.ALUMNI;
            }else if(PEStatusState.PE_STATUS_GROUP_IN_PROGRESS.contains(state.pe.Participant_Status__c)){
                state.value = ParticipantStates.REFERRAL;
                state.ctp = state.pe.Study_Site__r.Clinical_Trial_Profile__r;

            }else if(state.pe.Participant_Status__c == PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS){
                state.value = ParticipantStates.PARTICIPANT;
                List<Participant_Study_Enrollment__c> pseList = PSEService.getPSEListForParticipant();
                if(pseList.size() > 0) {
                    state.pse = pseList[0];
                    state.isDelegate = state.pse.Participant__r.Contact__c != CommunityService.getUserContact().Id;
                    state.ctp = state.pse.Study_Site__r.Clinical_Trial_Profile__r;
                    if(PSEService.PSE_STATUS_GROUP_COMPLETE.contains(state.pse.Status__c)){
                        state.value = ParticipantStates.ALUMNI;
                    }
                }
            }
        }
        return state;
    }

}