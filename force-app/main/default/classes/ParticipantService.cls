/**
 * Created by Leonid Bartenev
 */

public class ParticipantService {
    public class ParticipantServiceException extends Exception {
    }

    public enum ParticipantStates {
        ALUMNI, PROSPECT, REFERRAL, PARTICIPANT
    }

    public class ParticipantState {
        @AuraEnabled public ParticipantStates value;
        @AuraEnabled public Participant_Enrollment__c pe;
        @AuraEnabled public Participant_Study_Enrollment__c pse;
        @AuraEnabled public Boolean isDelegate;
        @AuraEnabled public Clinical_Trial_Profile__c ctp;
        @AuraEnabled public Participant__c participant;
        @AuraEnabled public String participantName;
        @AuraEnabled public Boolean showTerms;
        @AuraEnabled public Boolean showVisits;
        @AuraEnabled public Boolean isPremium;

        public ParticipantState() {
            value = ParticipantStates.PROSPECT;
            isDelegate = false;
            isPremium = false;
            showTerms = false;
            showVisits = false;
        }
    }

    private ParticipantState participantState;
    private static ParticipantService instance;

    public static ParticipantService getInstance() {
        if (instance == null) instance = new ParticipantService();
        return instance;
    }

    public static void setMock(StubProvider stubProvider) {
        instance = (ParticipantService) Test.createStub(ParticipantService.class, stubProvider);
    }

    public ParticipantService() {
        participantState = new ParticipantState();
        List<Participant_Enrollment__c> peList = ParticipantEnrollmentService.getParticipantEnrollmentsForParticipant();
        if (peList.size() > 0) {
            participantState.pe = peList[0];
            participantState.participant = participantState.pe.Participant__r;
            participantState.isDelegate = participantState.pe.Participant__r.Contact__c != CommunityService.getInstance().getCurrentContactId();
            participantState.participantName = getParticipantName();

            if (participantState.pe.Study_Site__r.Clinical_Trial_Profile__c != null) {
                participantState.ctp = participantState.pe.Study_Site__r.Clinical_Trial_Profile__r;
                participantState.showTerms = showTerms();
                participantState.isPremium = participantState.ctp.Participating_in_Patient_Portal__c == 'Yes';
            }
            if (PEStatusState.PE_STATUS_GROUP_FAILED.contains(participantState.pe.Participant_Status__c) &&
                    participantState.isPremium) {
                participantState.value = ParticipantStates.ALUMNI;
            } else if (PEStatusState.PE_STATUS_GROUP_IN_PROGRESS.contains(participantState.pe.Participant_Status__c)) {
                participantState.value = ParticipantStates.REFERRAL;
            } else if (participantState.pe.Participant_Status__c == PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS) {
                if (participantState.isPremium) {
                    List<Participant_Study_Enrollment__c> pseList = PSEService.getPSEListForParticipant();
                    if (pseList.size() > 0) {
                        participantState.value = ParticipantStates.PARTICIPANT;
                        participantState.pse = pseList[0];
                        if (participantState.isPremium) participantState.showVisits = showVisits();
                        participantState.isDelegate =
                                participantState.pse.Participant__r.Contact__c != CommunityService.getInstance().getCurrentContactId();
                        if (PSEService.PSE_STATUS_GROUP_COMPLETE.contains(participantState.pse.Status__c)) {
                            participantState.value = ParticipantStates.ALUMNI;
                            participantState.showVisits = showVisits();
                        }
                    } else {
                        participantState.value = ParticipantStates.REFERRAL;
                    }
                } else {
                    participantState.value = ParticipantStates.REFERRAL;
                }
            }
        }
    }

    @TestVisible
    private Boolean showTerms() {
        return participantState.ctp.Terms_And_Conditions_ID__c != null
                && !TermsAndConditions.isTCAccepted(participantState.ctp.Terms_And_Conditions_ID__c);
    }

    @TestVisible
    private Boolean showVisits() {
        if (participantState.value == ParticipantStates.ALUMNI) return false;

        if (participantState.ctp.Visit_Plan__c != null) {
            List<Visit__c> visitsList = (List<Visit__c>) DatabaseService.query(
                    new List<String>{
                            'Id'
                    },
                    Visit__c.getSObjectType(),
                    DatabaseService.fieldEqual('Visit_Plan__c', participantState.ctp.Visit_Plan__c)
            );
            return !visitsList.isEmpty();
        }

        return false;
    }

    @TestVisible
    private String getParticipantName() {
        String fullName;
        if (participantState.isDelegate) {
            fullName = (String) CommunityService.getUserContact().get('Name');
        } else {
            fullName = participantState.pe.Participant__r.Full_Name__c;
        }

        return Label.PG_Home_Welcome_Message.replace('##UserName', fullName);
    }

    public ParticipantState getState() {
        return participantState;
    }

    public void createParticipantAndUpdatePEImpl(Participant__c participant, Participant_Enrollment__c pe) {
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
                } else {
                    System.debug(error.getMessage());
                    throw new ParticipantServiceException(error.getMessage());
                }
            }
        }

        if (participant.Id != null) {
            pe.Participant__c = participant.Id;
            try {
                DatabaseService.getInstance().upsertToDB(pe);
            } catch (Exception e) {
                String errorMsg = e.getMessage();
                if (errorMsg.contains('DUPLICATE')) {
                    errorMsg = Label.Error_Message_Participant_Duplicate;
                }
                System.debug('ERROR: ' + errorMsg);
                throw new ParticipantServiceException(errorMsg);
            }
        } else {
            throw new ParticipantServiceException(Label.Error_Message_Can_Not_Create_Participant);
        }
    }

    // Static facade: --------------------------------------------------------------------------------------------------

    public static ParticipantState getParticipantState() {
        return getInstance().getState();
    }

    public static void createParticipantAndUpdatePE(Participant__c participant, Participant_Enrollment__c pe) {
        getInstance().createParticipantAndUpdatePEImpl(participant, pe);
    }

    public static List<LabelValueItem> getGenderLVList() {
        List<LabelValueItem> genders = new List<LabelValueItem>();
        genders.add(new LabelValueItem(Label.Gender_Male, 'Male'));
        genders.add(new LabelValueItem(Label.Gender_Female, 'Female'));
        return genders;
    }


}