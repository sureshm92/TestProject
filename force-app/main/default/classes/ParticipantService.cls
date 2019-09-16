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
            value = ParticipantStates.ALUMNI;
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
        Contact userContact = CommunityService.getUserContact();
        //ContactService.updateCurrentPEOnContacts(new List<Id>{userContact.Id});
        if(userContact.Current_Participant_Enrollment__c != null){
            Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(userContact.Current_Participant_Enrollment__c, CommunityService.USER_MODE_PARTICIPANT);
            if(pe != null){
                participantState.pe = pe;
                List<Participant__c> participants = [
                        SELECT First_Name__c,
                                Last_Name__c,
                                Middle_Name__c,
                                Full_Name__c,
                                Date_of_Birth__c,
                                Birth_Year__c,
                                Gender__c,
                                Email__c,
                                Phone__c,
                                Phone_Type__c,
                                Mailing_State__c,
                                Mailing_City__c,
                                Mailing_State_Code__c,
                                Mailing_Country__c,
                                Mailing_Country_Code__c,
                                Mailing_Zip_Postal_Code__c,
                                Contact__c,
                                Conditions__c,
                                Contact__r.Visit_Results_Opt_In__c
                        FROM Participant__c
                        WHERE Id =: pe.Participant__c
                ];
                if(!participants.isEmpty()) participantState.participant = participants.get(0);

                participantState.isDelegate = pe.Participant__r.Contact__c != userContact.Id;
                participantState.ctp = participantState.pe.Study_Site__r.Clinical_Trial_Profile__r;
                participantState.showTerms = showTerms();
                participantState.isPremium = participantState.ctp.Patient_Portal_Enabled__c;
                if (PEStatusState.PE_STATUS_GROUP_IN_PROGRESS.contains(participantState.pe.Participant_Status__c)) {
                    participantState.value = ParticipantStates.REFERRAL;
                } else if (PEStatusState.PE_STATUS_GROUP_PARTICIPATION_IN_PROGRESS.contains(participantState.pe.Participant_Status__c)) {
                    participantState.value = ParticipantStates.PARTICIPANT;
                    participantState.showVisits = showVisits();
                }else{
                    participantState.value = ParticipantStates.REFERRAL;
                }
            }
        }
        participantState.welcomeMessage = getWelcomeMessage();
    }

    @TestVisible
    private Boolean showTerms() {
        return participantState.ctp.Terms_And_Conditions_ID__c != null
                && !TermsAndConditions.isTCAccepted(participantState.ctp.Terms_And_Conditions_ID__c);
    }

    @TestVisible
    private Boolean showVisits() {
        if (participantState.ctp != null && participantState.ctp.Visit_Plan__c != null) {
            List<Visit__c> visitsList = (List<Visit__c>) DatabaseService.query(
                    'SELECT Id FROM Visit__c WHERE Visit_Plan__c = \''
                            + participantState.ctp.Visit_Plan__c + '\'');
            return visitsList.size() > 0;
        }
        return false;
    }

    @TestVisible
    private String getWelcomeMessage() {
        String userName;
        List<Participant__c> participants = [
                SELECT Full_Name__c
                FROM Participant__c
                WHERE Contact__c =: CommunityService.getInstance().getCurrentContactId()
        ];
        if (participants.size() == 0) {
            userName = (String) CommunityService.getUserContact().get('Name');
        } else {
            userName = participants[0].Full_Name__c;
        }

        String message = participantState.value == ParticipantStates.ALUMNI
                ? Label.PG_Home_Welcome_Message_Alumni : Label.PG_Home_Welcome_Message;

        return message.replace('##UserName', userName);
    }

    public ParticipantState getState() {
        return participantState;
    }

    public void createParticipantAndUpdatePEImpl(Participant__c participant, Participant_Enrollment__c pe) {
        participant.Language_Preference_Code__c = UserInfo.getLanguage();
        ParticipantDuplicateService duplicateService = new ParticipantDuplicateService(participant);
        Participant__c participantFromDatabase = duplicateService.findDuplicate(participant);
        if(participantFromDatabase != null){
            participant = participantFromDatabase;
        }else {
            //check contact duplicate:
            if(duplicateService.findDuplicateContact(participant) != null){
                participant.Contact__c = duplicateService.findDuplicateContact(participant).Id;
            }
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