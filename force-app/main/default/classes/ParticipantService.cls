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
        @AuraEnabled public Participant__c participant;
        @AuraEnabled public String participantName;
        @AuraEnabled public Boolean showTerms;

        public ParticipantState(){
            value = ParticipantStates.PROSPECT;
            isDelegate = false;
        }
    }
    
    private ParticipantState participantState;
    private static ParticipantService instance;
    
    public static ParticipantService getInstance(){
        if(instance == null) instance = new ParticipantService();
        return instance;
    }
    
    public static void setMock(StubProvider stubProvider){
        instance = (ParticipantService) Test.createStub(ParticipantService.class, stubProvider);
    }
    
    public ParticipantService(){
        participantState = new ParticipantState();
        List<Participant_Enrollment__c> peList = ParticipantEnrollmentService.getParticipantEnrollmentsForParticipant();
        if(peList.size() >  0) {
            participantState.pe = peList[0];
            participantState.participant = participantState.pe.Participant__r;
            participantState.isDelegate = participantState.pe.Participant__r.Contact__c != CommunityService.getInstance().getCurrentContactId();
            participantState.participantName = getParticipantName();

            if(participantState.pe.Study_Site__r.Clinical_Trial_Profile__c != null) {
                participantState.ctp = participantState.pe.Study_Site__r.Clinical_Trial_Profile__r;
            }
            if(PEStatusState.PE_STATUS_GROUP_FAILED.contains(participantState.pe.Participant_Status__c)){
                participantState.value = ParticipantStates.ALUMNI;
            }else if(PEStatusState.PE_STATUS_GROUP_IN_PROGRESS.contains(participantState.pe.Participant_Status__c)){
                participantState.value = ParticipantStates.REFERRAL;
            }else if(participantState.pe.Participant_Status__c == PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS){
                participantState.value = ParticipantStates.PARTICIPANT;
                participantState.showTerms = showTerms();
                List<Participant_Study_Enrollment__c> pseList = PSEService.getPSEListForParticipant();
                if(pseList.size() > 0) {
                    participantState.pse = pseList[0];
                    participantState.isDelegate = participantState.pse.Participant__r.Contact__c != CommunityService.getInstance().getCurrentContactId();
                    if(PSEService.PSE_STATUS_GROUP_COMPLETE.contains(participantState.pse.Status__c)){
                        participantState.value = ParticipantStates.ALUMNI;
                    }
                }
            }
        }
    }

    private Boolean showTerms() {
        return participantState.ctp.Terms_And_Conditions_ID__c != null
                && !TermsAndConditions.isTCAccepted(participantState.ctp.Terms_And_Conditions_ID__c);
    }

    private String getParticipantName() {
        String fullName;
        if(participantState.isDelegate) {
            fullName = (String) CommunityService.getUserContact().get('Name');
        }
        else {
            fullName = participantState.pe.Participant__r.Full_Name__c;
        }

        return Label.PG_Home_Welcome_Message.replace('##UserName', fullName);
    }

    public ParticipantState getState(){
        return participantState;
    }
    
    // Static facade: --------------------------------------------------------------------------------------------------
    
    public static ParticipantState getParticipantState(){
        return getInstance().getState();
    }

}