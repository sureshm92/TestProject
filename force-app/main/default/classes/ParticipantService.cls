/**
 * Created by Leonid Bartenev
 */

public without sharing class ParticipantService {
    public class ParticipantServiceException extends Exception {
    }

    public enum ParticipantStates {
        ALUMNI, PROSPECT, REFERRAL, PARTICIPANT
    }

    public class ParticipantState {
        @AuraEnabled public ParticipantStates value;
        @AuraEnabled public Participant_Enrollment__c pe;
        @AuraEnabled public Boolean isDelegate;
        @AuraEnabled public Clinical_Trial_Profile__c ctp;
        @AuraEnabled public Participant__c participant;
        @AuraEnabled public String welcomeMessage;
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
            if (peList[0].Study_Site__c == null) {
                throw new ParticipantServiceException('Study Site cannot be null on peId = ' + peList[0].Id);
            }

            participantState.pe = peList[0];
            participantState.participant = participantState.pe.Participant__r;
            participantState.isDelegate = peList[0].Participant__r.Contact__c != CommunityService.getInstance().getCurrentContactId();
            participantState.ctp = participantState.pe.Study_Site__r.Clinical_Trial_Profile__r;
            participantState.showTerms = showTerms();
            participantState.isPremium = participantState.ctp.Participating_in_Patient_Portal__c == 'Yes';

            if ((PEStatusState.PE_STATUS_GROUP_FAILED.contains(participantState.pe.Participant_Status__c) ||
                    PEStatusState.PE_STATUS_GROUP_COMPLETE.contains(participantState.pe.Participant_Status__c)
            ) && participantState.isPremium) {
                participantState.value = ParticipantStates.ALUMNI;
            } else if (PEStatusState.PE_STATUS_GROUP_IN_PROGRESS.contains(participantState.pe.Participant_Status__c)) {
                participantState.value = ParticipantStates.REFERRAL;
            } else if (PEStatusState.PE_STATUS_GROUP_PARTICIPATION_IN_PROGRESS.contains(participantState.pe.Participant_Status__c)) {
                if (participantState.isPremium) {
                    participantState.value = ParticipantStates.PARTICIPANT;
                    participantState.showVisits = showVisits();
                    participantState.isDelegate =
                            participantState.pe.Participant__r.Contact__c != CommunityService.getInstance().getCurrentContactId();
                } else {
                    participantState.value = ParticipantStates.REFERRAL;
                }
            }
            participantState.welcomeMessage = getWelcomeMessage();
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
                    'SELECT Id FROM Visit__c WHERE Visit_Plan__c = \''
                            + participantState.ctp.Visit_Plan__c + '\'');
            return !visitsList.isEmpty();
        }

        return false;
    }

    @TestVisible
    private String getWelcomeMessage() {
        String fullName;
        if (participantState.isDelegate) {
            fullName = (String) CommunityService.getUserContact().get('Name');
        } else {
            fullName = participantState.pe.Participant__r.Full_Name__c;
        }

        String message = participantState.value == ParticipantStates.ALUMNI
                ? Label.PG_Home_Welcome_Message_Alumni : Label.PG_Home_Welcome_Message;

        return message.replace('##UserName', fullName);
    }

    public ParticipantState getState() {
        return participantState;
    }

    public void createParticipantAndUpdatePEImpl(Participant__c participant, Participant_Enrollment__c pe) {
        participant.Language_Preference_Code__c = UserInfo.getLanguage();
        Participant__c participantFromDatabase = new ParticipantDuplicateService(participant).findDuplicate(participant);
        if(participantFromDatabase != null){
            participant = participantFromDatabase;
        }else{
            insert participant;
        }
        pe.Participant__c = participant.Id;
        if (pe.Participant_Name__c == null) pe.Participant_Name__c = participant.First_Name__c;
        if (pe.Participant_Surname__c == null) pe.Participant_Surname__c = participant.Last_Name__c;
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