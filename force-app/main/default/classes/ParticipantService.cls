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
        @AuraEnabled public Id currentUserId;
        @AuraEnabled public Id currentContactId;
        @AuraEnabled public String welcomeMessage;
        @AuraEnabled public Boolean showTerms;
        @AuraEnabled public Boolean showVisits;
        @AuraEnabled public Boolean showResults;
        @AuraEnabled public Boolean isPremium;
        @AuraEnabled public String communityName;
        @AuraEnabled public String payCardLink;

        public ParticipantState() {
            value = ParticipantStates.ALUMNI;
            isDelegate = false;
            isPremium = false;
            showTerms = false;
            showVisits = false;
            showResults = false;
            communityName = '';
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
        participantState.currentContactId = userContact.userCommunityDelegateId__c;
        if (participantState.currentContactId == null) participantState.currentContactId = userContact.Id;
        participantState.isDelegate = userContact.userCommunityDelegateId__c != null;
        List<User> participantUser = [SELECT Id FROM User WHERE ContactId = :participantState.currentContactId LIMIT 1];
        if (!participantUser.isEmpty()) participantState.currentUserId = participantUser.get(0).Id;
        else participantState.currentUserId = CommunityService.getUserId();
        if (userContact.Current_Participant_Enrollment__c != null) {
            Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(userContact.Current_Participant_Enrollment__c, CommunityService.USER_MODE_PARTICIPANT);
            if (pe != null) {
                participantState.participant = getParticipant(pe.Participant__c);
                participantState.pe = pe;
                participantState.ctp = participantState.pe.Clinical_Trial_Profile__r;
                TranslateHelper.translate(participantState.pe, IRBParticipantService.getSuitableLanguageForIRBTranslation(pe.Id));
                participantState.showTerms = showTerms();
                participantState.isPremium = participantState.ctp.Patient_Portal_Enabled__c;
                participantState.payCardLink = PaymentService.getPaymentVendorLink(participantState.pe.Study_Site__c);
                if (PEStatusState.PE_STATUS_GROUP_PARTICIPATION_IN_PROGRESS.contains(participantState.pe.Participant_Status__c)) {
                    participantState.value = ParticipantStates.PARTICIPANT;
                    participantState.showVisits = showVisits();
                    participantState.showResults = showResults();
                } else {
                    participantState.value = ParticipantStates.REFERRAL;
                }
            }
        } else {
            participantState.participant = getParticipant(participantState.currentContactId);
            //Get participant for delegate
            if (participantState.participant == null) {
                Participant__c participant = PatientDelegateService.getParticipantByDelegateContactId(CommunityService.getUserContact().Id);
                if (participant != null) participantState.participant = getParticipant(participant.Id);
            }
        }
        participantState.welcomeMessage = getWelcomeMessage();
        participantState.communityName = UserContext.getCurrentCommunityName();
    }

    public static Participant__c getParticipant(Id sourceId) {
        List<Participant__c> participants = [
                SELECT Id,
                        First_Name__c,
                        Last_Name__c,
                        Middle_Name__c,
                        Full_Name__c,
                        Date_of_Birth__c,
                        Birth_Year__c,
                        Gender__c,
                        Email__c,
                        Phone__c,
                        Phone_Type__c,
                        Status__c,
                        Balance__c,
                        Pending_Payments__c,
                        Mailing_State__c,
                        Mailing_City__c,
                        Mailing_State_Code__c,
                        Mailing_Country__c,
                        Mailing_Country_Code__c,
                        Mailing_Zip_Postal_Code__c,
                        Contact__c,
                        Conditions__c,
                        Contact__r.Current_Participant_Enrollment__c,
                        Contact__r.Visit_Results_OptIn__c,
                        Contact__r.Participant_Opt_In_Status_Emails__c,
                        Marketing_Flag__c
                FROM Participant__c
                WHERE Contact__c = :sourceId OR Id = :sourceId
        ];
        if (participants.size() > 0) return participants[0];
        return null;
    }

    @TestVisible
    private Boolean showTerms() {
        return participantState.ctp.Terms_And_Conditions_ID__c != null
                && !TermsAndConditions.isTCAccepted(participantState.ctp.Terms_And_Conditions_ID__c);
    }

    @TestVisible
    private Boolean showVisits() {
        if (participantState.pe != null) {
            List<Patient_Visit__c> patientVisit = [
                    SELECT Id
                    FROM Patient_Visit__c
                    WHERE Participant_Enrollment__c = :participantState.pe.Id
            ];
            return !patientVisit.isEmpty();
        }
        return false;
    }

    @TestVisible
    private Boolean showResults() {
        Clinical_Trial_Profile__c ctp = VisitResultSharingService.getCTP(participantState.ctp.Id);
        String countryCode = participantState.participant.Mailing_Country_Code__c;
        return ctp.Shareback_Settings_On_Country_Level__c
                && (String.isBlank(ctp.Shareback_Settings_Countries__c)
                        || ctp.Shareback_Settings_Countries__c.containsIgnoreCase(countryCode));
    }

    @TestVisible
    private String getWelcomeMessage() {
        String userName;
        List<Participant__c> participants = [
                SELECT Full_Name__c
                FROM Participant__c
                WHERE Contact__c = :CommunityService.getInstance().getCurrentContactId()
        ];
        if (participants.size() == 0) {
            userName = (String) CommunityService.getUserContact().get('Name');
        } else {
            userName = participants[0].Full_Name__c;
        }

        String message;
        if (participantState.value == ParticipantStates.ALUMNI) {
            message = Label.PG_Home_Welcome_Message_Alumni;
        } else {
            message = Label.PG_Home_Welcome_Message;
            String communityName = TranslateHelper.getLabelValue(UserContext.getTemplateProperty('CommunityWelcome'));
            message = message.replace('##CommunityWelcome', communityName);
        }

        return message.replace('##UserName', userName);
    }

    public ParticipantState getState() {
        return participantState;
    }

    public void createParticipantAndUpdatePEImpl(Participant__c participant, Participant__c participantDelegate, Participant_Enrollment__c pe, String userLanguage) {
        participant.Preferred_Language__c = userLanguage;
        ParticipantDuplicateService.ParticipantWithDelegate participantWithDelegate = new ParticipantDuplicateService.ParticipantWithDelegate();
        participantWithDelegate.participant = participant;
        participantWithDelegate.delegate = participantDelegate;

        ParticipantDuplicateService duplicateService = new ParticipantDuplicateService(participantWithDelegate);
        Participant__c participantFromDatabase = duplicateService.findDuplicate(participant);
        if (participantFromDatabase != null) {
            participant = participantFromDatabase;
        } else {
            //check contact duplicate:
            if (duplicateService.findDuplicateContact(participant) != null) {
                participant.Contact__c = duplicateService.findDuplicateContact(participant).Id;
                 if ('Home' == participant.Phone_Type__c) {
                        participant.Contact__r.HomePhone = participant.Phone__c;
                    } if ('Mobile' == participant.Phone_Type__c) {
                        participant.Contact__r.MobilePhone = participant.Phone__c;
                    } else {
                        participant.Contact__r.Phone = participant.Phone__c;
                    }
            }
            insert participant;
        }
        if (pe != null) {
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
    }

    // Static facade: --------------------------------------------------------------------------------------------------

    public static ParticipantState getParticipantState() {
        return getInstance().getState();
    }

    public static void createParticipantAndUpdatePE(Participant__c participant, Participant__c participantDelegate, Participant_Enrollment__c pe, String userLanguage) {
        getInstance().createParticipantAndUpdatePEImpl(participant, participantDelegate, pe, userLanguage);
    }

    public static List<LabelValueItem> getGenderLVList() {
        List<LabelValueItem> genders = new List<LabelValueItem>();
        genders.add(new LabelValueItem(Label.Gender_Male, 'Male'));
        genders.add(new LabelValueItem(Label.Gender_Female, 'Female'));
        return genders;
    }

    public static List<LabelValueItem> getPhoneTypeLVList() {
        List<LabelValueItem> phoneTypes = new List<LabelValueItem>();
        phoneTypes.add(new LabelValueItem(Label.Phone_Type_Home, 'Home'));
        phoneTypes.add(new LabelValueItem(Label.Phone_Type_Work, 'Work'));
        phoneTypes.add(new LabelValueItem(Label.Phone_Type_Mobile, 'Mobile'));
        return phoneTypes;
    }
	
	public static List<LabelValueItem> getPrefixList() {
        List<LabelValueItem> prefix = new List<LabelValueItem>();
        prefix.add(new LabelValueItem('Mr.', 'Mr.'));
        prefix.add(new LabelValueItem('Ms.', 'Ms.'));
        prefix.add(new LabelValueItem('Mrs.', 'Mrs.'));
        prefix.add(new LabelValueItem('Dr.', 'Dr.'));
        prefix.add(new LabelValueItem('Prof.', 'Prof.'));
        return prefix;
    }

    public static Map<Id, Integer> getNearestLogOutNotification(List<Id> participantContIds) {
        List<Participant_Enrollment__c> enrollments = [
                SELECT
                        Id,
                        Participant_Contact__c,
                        Participant__r.Contact__c,
                        Clinical_Trial_Profile__r.Logged_Out_Days_Notification__c
                FROM Participant_Enrollment__c
                WHERE Participant_Contact__c IN:participantContIds
                AND Participant_Status__c IN:PEStatusState.PE_STATUS_GROUP_IN_PROGRESS_ALL
                AND Clinical_Trial_Profile__r.Logged_Out_Days_Notification__c != NULL
        ];

        Map<Id, Integer> nearestNotificationByContactIds = new Map<Id, Integer>();
        for (Participant_Enrollment__c pe : enrollments) {
            Id contactId = pe.Participant_Contact__c != null ? pe.Participant_Contact__c : pe.Participant__r.Contact__c;
            Integer daysNotification = (Integer) pe.Clinical_Trial_Profile__r.Logged_Out_Days_Notification__c;

            if (!nearestNotificationByContactIds.containsKey(contactId)) {
                nearestNotificationByContactIds.put(
                        contactId,
                        daysNotification
                );
            }

            Integer currentNotification = nearestNotificationByContactIds.get(contactId);
            if (currentNotification > daysNotification) {
                nearestNotificationByContactIds.put(contactId, daysNotification);
            }
        }

        return nearestNotificationByContactIds;
    }

    public static String getParticipantFullName(Id contactId) {
        List<Participant__c> participant = [SELECT Full_Name__c FROM Participant__c WHERE Contact__c = :contactId];
        if (participant.isEmpty()) throw new ParticipantServiceException('This contact hasn\'t participant!');

        return participant.get(0).Full_Name__c;
    }

    public static List<Participant__c> checkParticipantsAgeOfMajority(List<Participant__c> participants) {
        List<Age_of_Majority__mdt> ageOfMajorities = [
                SELECT
                        Country_Code__c,
                        State_Code__c,
                        Age__c
                FROM Age_of_Majority__mdt
                ORDER BY
                        Country_Code__c NULLS LAST,
                        State_Code__c NULLS LAST
        ];

        for (Participant__c prt : participants) {
            if (prt.Adult__c || String.isBlank(prt.Date_of_Birth__c)) continue;
            try {
                Date birthDate = Date.newInstance(
                        Integer.valueOf(prt.Date_of_Birth__c.substring(0, 4)),
                        Integer.valueOf(prt.Date_of_Birth__c.substring(5, 7)),
                        Integer.valueOf(prt.Date_of_Birth__c.substring(8, 10)));

                Integer participantAge =
                        Date.newInstance(2000, birthDate.month(), birthDate.day()) <
                                Date.newInstance(2000, Date.today().month(), Date.today().day()) ?
                                Date.today().year() - birthDate.year() : Date.today().year() - birthDate.year() - 1;

                for (Age_of_Majority__mdt ageOfMajority : ageOfMajorities) {
                    if (prt.Mailing_Country_Code__c == ageOfMajority.Country_Code__c || String.isBlank(ageOfMajority.Country_Code__c))
                        if (prt.Mailing_State_Code__c == ageOfMajority.State_Code__c || String.isBlank(ageOfMajority.State_Code__c)) {
                            prt.Adult__c = participantAge >= ageOfMajority.Age__c;
                            break;
                        }
                }
            } catch (Exception e) {
            }
        }
        return participants;
    }
}