/**
 * Created by Leonid Bartenev
 */

public class ParticipantService {
    public class ParticipantServiceException extends Exception{}
    
    public enum ParticipantStates {ALUMNI, PROSPECT, REFERRAL, PARTICIPANT}
    
    public class ParticipantState{
        @AuraEnabled public ParticipantStates value;
        @AuraEnabled public Participant_Enrollment__c pe;
        @AuraEnabled public Participant_Study_Enrollment__c pse;
        @AuraEnabled public Boolean isDelegate;
        @AuraEnabled public Clinical_Trial_Profile__c ctp;
        @AuraEnabled public Participant__c participant;

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
            if(participantState.pe.Study_Site__r.Clinical_Trial_Profile__c != null) {
                participantState.ctp = participantState.pe.Study_Site__r.Clinical_Trial_Profile__r;
            }
            if(PEStatusState.PE_STATUS_GROUP_FAILED.contains(participantState.pe.Participant_Status__c)){
                participantState.value = ParticipantStates.ALUMNI;
            }else if(PEStatusState.PE_STATUS_GROUP_IN_PROGRESS.contains(participantState.pe.Participant_Status__c)){
                participantState.value = ParticipantStates.REFERRAL;
            }else if(participantState.pe.Participant_Status__c == PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS){
                participantState.value = ParticipantStates.PARTICIPANT;
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
    
    public ParticipantState getState(){
        return participantState;
    }
    
    public List<ParticipantItem> createParticipantItems(List<Participant_Enrollment__c> peList){
        List<ParticipantItem> items = new List<ParticipantItem>();
        for(Participant_Enrollment__c pe : peList) items.add(new ParticipantItem(pe));
        return items;
    }
    
    public void createParticipantAndUpdatePEImpl(Participant__c participant, Participant_Enrollment__c pe){
        Database.SaveResult saveResult = DatabaseService.insertSObj(participant, false);
        if (!saveResult.isSuccess()) {
            System.debug('PARTICIPANT INSERT ERROR');
            for (Database.Error error : saveResult.getErrors()) {
                if (error instanceof Database.DuplicateError) {
                    Database.DuplicateError duplicateError = (Database.DuplicateError) error;
                    Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
                    List<SObject> duplicateRecords = new List<SObject>();
                    Datacloud.MatchResult[] matchResults = duplicateResult.getMatchResults();
                    Datacloud.MatchResult matchResult = matchResults[0];
                    Datacloud.MatchRecord[] matchRecords = matchResult.getMatchRecords();
                    for (Datacloud.MatchRecord matchRecord : matchRecords) {
                        participant = (Participant__c) matchRecord.getRecord();
                        System.debug('FOUND PART DUPLICATE: ' + participant);
                        break;
                    }
                }else{
                    System.debug(error.getMessage());
                    throw new ParticipantServiceException(error.getMessage());
                }
            }
        }
        
        if(participant.Id != null){
            pe.Participant__c = participant.Id;
            try{
                upsert pe;
            }catch (Exception e){
                String errorMsg = e.getMessage();
                if(errorMsg.contains('DUPLICATE')) {
                    errorMsg = Label.Error_Message_Participant_Duplicate;
                }
                System.debug('ERROR: ' + errorMsg);
                throw new ParticipantServiceException(errorMsg);
            }
        }else{
            throw new ParticipantServiceException(Label.Error_Message_Can_Not_Create_Participant);
        }
    }
    
    // Static facade: --------------------------------------------------------------------------------------------------
    
    public static ParticipantState getParticipantState(){
        return getInstance().getState();
    }
    
    public static void createParticipantAndUpdatePE(Participant__c participant, Participant_Enrollment__c pe){
        getInstance().createParticipantAndUpdatePEImpl(participant, pe);
    }
    
    public static List<LabelValueItem> getGenderLVList(){
        List<LabelValueItem> genders = new List<LabelValueItem>();
        genders.add(new LabelValueItem(Label.Gender_Male, 'Male'));
        genders.add(new LabelValueItem(Label.Gender_Female, 'Female'));
        return genders;
    }


}
