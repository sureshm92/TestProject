public without sharing class ParticipantService {
    public static final List<Age_of_Majority__mdt> Age_Of_Majorities = [
        SELECT Country_Code__c, State_Code__c, Age__c
        FROM Age_of_Majority__mdt
        ORDER BY Country_Code__c NULLS LAST, State_Code__c NULLS LAST
    ];
    public class ParticipantServiceException extends Exception {
    }

    public enum ParticipantStates {
        ALUMNI,
        PROSPECT,
        REFERRAL,
        PARTICIPANT
    }

    public class ParticipantState {
        @AuraEnabled
        public ParticipantStates value;
        @AuraEnabled
        public Participant_Enrollment__c pe;
        @AuraEnabled
        public Boolean isDelegate;
        @AuraEnabled
        public Boolean hasPatientDelegates;
        @AuraEnabled
        public Clinical_Trial_Profile__c ctp;
        @AuraEnabled
        public Participant__c participant;
        @AuraEnabled
        public List<Medical_Record_Vendor__c> medicalVendors;
        @AuraEnabled
        public Id currentUserId;
        @AuraEnabled
        public Id currentContactId;
        @AuraEnabled
        public String welcomeMessage;
        @AuraEnabled
        public Boolean showTerms;
        @AuraEnabled
        public Boolean showVisits;
        @AuraEnabled
        public Boolean showTeleVisits;
        @AuraEnabled
        public Boolean showResults;
        @AuraEnabled
        public Boolean isPremium;
        @AuraEnabled
        public String communityName;
        @AuraEnabled
        public String payCardLink;
        @AuraEnabled
        public Boolean isVisitPathEnabled;
        @AuraEnabled
        public Boolean isTravelSupportEnabled;
        public Boolean showVisitsInPreTrial;
        @AuraEnabled
        public Boolean showTravelCardInPreEnrollment;
        @AuraEnabled
        public Boolean showNonInitialVisits;
        @AuraEnabled
        public List<Televisit_Record_Vendor__c> teleVendors;
        @AuraEnabled
        public Boolean isTeleVendorEnabled;
        @AuraEnabled
        public String loggedInUserName;

        public ParticipantState() {
            value = ParticipantStates.ALUMNI;
            isDelegate = false;
            isPremium = false;
            showTerms = false;
            showVisits = false;
            showTeleVisits = false;
            showVisitsInPreTrial = false;
            showResults = false;
            communityName = '';
            isVisitPathEnabled = false;
            isTravelSupportEnabled = false;
            showTravelCardInPreEnrollment = false;
            showNonInitialVisits = false;
            loggedInUserName = '';
        }
    }

    private ParticipantState participantState;
    private static ParticipantService instance;

    public static ParticipantService getInstance() {
        if (instance == null)
            instance = new ParticipantService();
        return instance;
    }

    public static void setMock(StubProvider stubProvider) {
        instance = (ParticipantService) Test.createStub(ParticipantService.class, stubProvider);
    }

    public ParticipantService() {
        participantState = new ParticipantState();
        Contact userContact = CommunityService.getUserContact();
        participantState.currentContactId = userContact.userCommunityDelegateId__c;
        if (participantState.currentContactId == null)
            participantState.currentContactId = userContact.Id;
        participantState.isDelegate = userContact.userCommunityDelegateId__c != null;
        participantState.hasPatientDelegates = PatientDelegateService.getInstance().hasDelegates;

        List<User> participantUser = [
            SELECT Id
            FROM User
            WHERE ContactId = :participantState.currentContactId
            LIMIT 1
        ];
        if (!participantUser.isEmpty())
            participantState.currentUserId = participantUser.get(0).Id;
        else
            participantState.currentUserId = CommunityService.getUserId();
        if (userContact.Current_Participant_Enrollment__c != null) {
            Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(
                userContact.Current_Participant_Enrollment__c,
                CommunityService.USER_MODE_PARTICIPANT
            );
            if (pe != null) {
                participantState.participant = getParticipant(pe.Participant__c);
                participantState.pe = pe;
                participantState.ctp = participantState.pe.Clinical_Trial_Profile__r;
                TranslateHelper.translate(
                    participantState.pe,
                    IRBParticipantService.getSuitableLanguageForIRBTranslation(pe.Id)
                );
                if (Site.getMasterLabel() != 'IQVIA Patient Portal') {
                    participantState.showTerms = showTerms();
                }
                participantState.medicalVendors = MedicalRecordVendorPanelRemote.getVendors(
                    participantState.pe.Study_Site__c
                );
                participantState.teleVendors = televisitConfigurationController.getVendors(
                    participantState.pe.Study_Site__c
                );
                participantState.isTeleVendorEnabled =
                    (participantState.teleVendors.size() > 0) &
                    PEStatusState.PE_STATUS_GROUP_IN_PROGRESS_ALL.contains(
                        participantState.pe.Participant_Status__c
                    );
                participantState.isPremium = participantState.ctp.Patient_Portal_Enabled__c;
                participantState.isVisitPathEnabled = participantState.ctp.Visit_Schedule_Is_Available__c;
                participantState.isTravelSupportEnabled = participantState.ctp.Travel_Vendor_Is_Available__c;
                participantState.payCardLink = PaymentService.getPaymentVendorLink(
                    participantState.pe.Study_Site__c
                );
                if (
                    PEStatusState.PE_STATUS_GROUP_PARTICIPATION_IN_PROGRESS.contains(
                        participantState.pe.Participant_Status__c
                    )
                ) {
                    participantState.value = ParticipantStates.PARTICIPANT;
                    participantState.showVisits = showVisits();
                    participantState.showTeleVisits = showTeleVisits();
                    /**PEH-525 START*/
                    participantState.showVisitsInPreTrial = participantState.showVisits;
                    /**PEH-525 END*/
                    participantState.showResults = showResults();
                    participantState.showNonInitialVisits = showNonInitialVisitsNew();
                } else {
                    participantState.value = ParticipantStates.REFERRAL;
                    /**PEH-525 START*/
                    participantState.showVisits = showVisits();
                    participantState.showTeleVisits = showTeleVisits();
                    participantState.showVisitsInPreTrial = showVisits();
                    participantState.showNonInitialVisits = showNonInitialVisitsNew();
                    /**PEH-525 END*/
                    Boolean boolPreConsent = participantState.ctp.Received_Until_Consent_Is_Available__c;
                    Boolean boolEnrolledConsent = participantState.ctp.Enrolled_Or_Randomized_Consent_Available__c;
                    //if Pre Consent is on and  Consent through enrollment/randomization is Off
                    if (boolPreConsent && !boolEnrolledConsent) {
                        if (
                            PEStatusState.PE_STATUS_GROUP_FOR_PRE_CONSENT_TOGGLE.contains(
                                participantState.pe.Participant_Status__c
                            )
                        ) {
                            participantState.showTravelCardInPreEnrollment = true;
                        }
                    } else if (!boolPreConsent && boolEnrolledConsent) {
                        if (
                            PEStatusState.PE_STATUS_GROUP_FOR_CONSENT_ENROLL_RANDMZ_TOGGLE.contains(
                                participantState.pe.Participant_Status__c
                            )
                        ) {
                            participantState.showTravelCardInPreEnrollment = true;
                        }
                    } else if (boolPreConsent && boolEnrolledConsent) {
                        if (
                            PEStatusState.PE_STATUS_GROUP_PRE_ENROLLMENT.contains(
                                participantState.pe.Participant_Status__c
                            )
                        ) {
                            participantState.showTravelCardInPreEnrollment = true;
                        }
                    }
                }
            }
        } else {
            participantState.participant = getParticipant(participantState.currentContactId);
            //Get participant for delegate
            if (participantState.participant == null) {
                Participant__c participant = PatientDelegateService.getParticipantByDelegateContactId(
                    CommunityService.getUserContact().Id
                );
                if (participant != null)
                    participantState.participant = getParticipant(participant.Id);
            }
        }
        participantState.welcomeMessage = getWelcomeMessage();
        participantState.communityName = UserContext.getCurrentCommunityName();
        participantState.loggedInUserName = getLoggedInUserName();
    }

    public static Participant__c getParticipant(Id sourceId) {
        if (sourceId != null) {
            List<Participant__c> participants = [
                SELECT
                    Id,
                    First_Name__c,
                    Last_Name__c,
                    Middle_Name__c,
                    Full_Name__c,
                    Date_of_Birth__c,
                    Birth_Year__c,
                    Birth_Month__c,
                    Birth_Day__c,
                    Age__c,
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
                    Marketing_Flag__c,
                    Adult__c
                FROM Participant__c
                WHERE Contact__c = :sourceId OR Id = :sourceId
            ];
            if (participants.size() > 0)
                return participants[0];
        }
        return null;
    }

    @TestVisible
    private Boolean showTerms() {
        return participantState.ctp.Terms_And_Conditions_ID__c != null &&
            !TermsAndConditions.isTCAccepted(participantState.ctp.Terms_And_Conditions_ID__c);
    }

    @TestVisible
    private Boolean showVisits() {
        if (participantState.pe != null) {
            List<Patient_Visit__c> patientVisit = [
                SELECT Id
                FROM Patient_Visit__c
                WHERE Participant_Enrollment__c = :participantState.pe.Id
            ];
            Boolean VisitEnabled = participantState.pe.Clinical_Trial_Profile__r.Visits_are_Available__c;
            return (!patientVisit.isEmpty());
        }
        return false;
    }

    @TestVisible
    private Boolean showTeleVisits() {
        ///**ParticipantState ps = getParticipantState();
        if (participantState.pe != null) {
            List<Televisit__c> tvList = [
                SELECT
                    Id,
                    Name,
                    Title__c,
                    Duration__c,
                    Start_Time__c,
                    Visit_Date__c,
                    Visit_Date_Time__c,
                    Status__c,
                    (
                        SELECT Id, Firstname__c, Lastname__c, Attendee_Type__c
                        FROM Televisit_Attendee__r
                    )
                FROM Televisit__c
                WHERE
                    Id IN (
                        SELECT Televisit__c
                        FROM Televisit_Attendee__c
                        WHERE Contact__c = :participantState.pe.Participant__r.Contact__c
                    )
                    AND Participant_Enrollment__c = :participantState.pe.Id
            ];
            return (!tvList.isEmpty());
        }
        return false;
    }
    @TestVisible
    private Boolean showNonInitialVisitsNew() {
        if (participantState.pe != null) {
            List<Patient_Visit__c> patientVisit = [
                SELECT Id
                FROM Patient_Visit__c
                WHERE
                    Participant_Enrollment__c = :participantState.pe.Id
                    AND Is_Pre_Enrollment_Patient_Visit__c = FALSE
            ];

            return (!patientVisit.isEmpty());
        }
        return false;
    }
    @TestVisible
    private Boolean showResults() {
        Clinical_Trial_Profile__c ctp = VisitResultSharingService.getCTP(participantState.ctp.Id);
        String countryCode = participantState.participant.Mailing_Country_Code__c;
        return ctp.Shareback_Settings_On_Country_Level__c &&
            (String.isBlank(ctp.Shareback_Settings_Countries__c) ||
            ctp.Shareback_Settings_Countries__c.containsIgnoreCase(countryCode));
    }

    @TestVisible
    private String getLoggedInUserName() {
        String userName;
        List<Participant__c> participants = new List<Participant__c>();
        if (String.isNotBlank(CommunityService.getInstance().getCurrentContactId())) {
            participants = [
                SELECT First_Name__c
                FROM Participant__c
                WHERE Contact__c = :CommunityService.getInstance().getCurrentContactId()
            ];
        }
        if (participants.size() == 0) {
            userName = (String) CommunityService.getUserContact().get('Name');
        } else {
            userName = participants[0].First_Name__c;
        }
        return userName;
    }

    @TestVisible
    private String getWelcomeMessage() {
        String userName;
        List<Participant__c> participants = new List<Participant__c>();
        if (String.isNotBlank(CommunityService.getInstance().getCurrentContactId())) {
            participants = [
                SELECT Full_Name__c
                FROM Participant__c
                WHERE Contact__c = :CommunityService.getInstance().getCurrentContactId()
            ];
        }
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
            String communityName = TranslateHelper.getLabelValue(
                UserContext.getTemplateProperty('CommunityWelcome')
            );
            if (communityName != null) {
                message = message.replace('##CommunityWelcome', communityName);
            }
        }

        return message.replace('##UserName', userName);
    }

    public ParticipantState getState() {
        return participantState;
    }

    public void createParticipantAndUpdatePEImpl(
        Participant__c participant,
        Participant__c participantDelegate,
        Participant_Enrollment__c pe,
        String userLanguage
    ) {
        participant.Preferred_Language__c = userLanguage;
        ParticipantDuplicateService.ParticipantWithDelegate participantWithDelegate = new ParticipantDuplicateService.ParticipantWithDelegate();
        participantWithDelegate.participant = participant;
        participantWithDelegate.delegate = participantDelegate;
        ParticipantDuplicateService duplicateService = new ParticipantDuplicateService(
            participantWithDelegate
        );

        Participant__c participantFromDatabase = duplicateService.findDuplicate(participant);
        if (participantFromDatabase != null) {
            AddPatientByPIRemote.updateParticipant(JSON.serialize(participant));
            participant = participantFromDatabase;
        } else {
            //check contact duplicate:
            if (duplicateService.findDuplicateContact(participant) != null) {
                Contact existingContact = duplicateService.findDuplicateContact(participant);
                participant.Contact__c = existingContact.Id;
                if ('Home' == participant.Phone_Type__c) {
                    existingContact.HomePhone = participant.Phone__c;
                }
                if ('Mobile' == participant.Phone_Type__c) {
                    existingContact.MobilePhone = participant.Phone__c;
                } else {
                    existingContact.Phone = participant.Phone__c;
                }
                update existingContact;
            }
            system.debug('>>beforeInsertPart>' + limits.getQueries());
            insert participant;
        }
        system.debug('>>AfterInsertPart>' + limits.getQueries());
        if (pe != null) {
            pe.Participant__c = participant.Id;
            if (pe.Participant_Name__c == null)
                pe.Participant_Name__c = participant.First_Name__c;
            if (pe.Participant_Surname__c == null)
                pe.Participant_Surname__c = participant.Last_Name__c;
            try {
                system.debug('>>BeforeUpsertPE>' + limits.getQueries());
                DatabaseService.getInstance().upsertToDB(pe);
                system.debug('>>aFTERUpsertPE>' + limits.getQueries());
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

    public static list<String> createParticipantAndUpdatePEImpls(
        Participant__c participant,
        Participant__c participantDelegate,
        Participant_Enrollment__c pe,
        String userLanguage
    ) {
        try {
            String dupPart = 'no duplicate';
            participant.Preferred_Language__c = userLanguage;
            ParticipantDuplicateService.ParticipantWithDelegate participantWithDelegate = new ParticipantDuplicateService.ParticipantWithDelegate();
            participantWithDelegate.participant = participant;
            participantWithDelegate.delegate = participantDelegate;
            ParticipantDuplicateService duplicateService = new ParticipantDuplicateService(
                participantWithDelegate
            );
            String ParticipantID = '';
            Participant__c participantFromDatabase = duplicateService.findDuplicate(participant);
            if (participantFromDatabase != null) {
                //AddPatientByPIRemote.updateParticipant(JSON.serialize(participant));
                dupPart = JSON.serialize(participant);
                participant = participantFromDatabase;
                ParticipantID = participant.Id;
            } else {
                //check contact duplicate:
                if (duplicateService.findDuplicateContact(participant) != null) {
                    Contact existingContact = duplicateService.findDuplicateContact(participant);
                    participant.Contact__c = existingContact.Id;
                    if ('Home' == participant.Phone_Type__c) {
                        existingContact.HomePhone = participant.Phone__c;
                    }
                    if ('Mobile' == participant.Phone_Type__c) {
                        existingContact.MobilePhone = participant.Phone__c;
                    } else {
                        existingContact.Phone = participant.Phone__c;
                    }
                    update existingContact;
                }
                system.debug('>>beforeInsertPart>' + limits.getQueries());
                insert participant;
                system.debug('>>AfterInsertPart>' + limits.getQueries());
                ParticipantID = participant.Id;
            }
            return new List<String>{ ParticipantID, dupPart };
        } catch (Exception e) {
            System.debug('ERROR: ' + e);
            AuraHelper.throwException(e);
        }
        return null;
    }

    // Static facade: --------------------------------------------------------------------------------------------------

    public static ParticipantState getParticipantState() {
        return getInstance().getState();
    }

    public static void createParticipantAndUpdatePE(
        Participant__c participant,
        Participant__c participantDelegate,
        Participant_Enrollment__c pe,
        String userLanguage
    ) {
        getInstance()
            .createParticipantAndUpdatePEImpl(participant, participantDelegate, pe, userLanguage);
    }
    public static list<String> createParticipantAndUpdatePES(
        Participant__c participant,
        Participant__c participantDelegate,
        Participant_Enrollment__c pe,
        String userLanguage
    ) {
        list<String> partAndDup = createParticipantAndUpdatePEImpls(
            participant,
            participantDelegate,
            pe,
            userLanguage
        );
        return partAndDup;
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

    public static List<LabelValueItem> getYearofBirthList() {
        List<LabelValueItem> yearOfBirth = new List<LabelValueItem>();
        Integer currentYear = System.Today().year();
        Integer firstYear = currentYear - 150;
        if (!UserContext.isParticipant()) {
            yearOfBirth.add(new LabelValueItem('', ''));
        }
        for (Integer i = currentYear; i >= firstYear; i--) {
            yearOfBirth.add(new LabelValueItem(String.valueOf(i), String.valueOf(i)));
        }
        return yearOfBirth;
    }

    public static List<LabelValueItem> getPrefixList() {
        List<LabelValueItem> prefix = new List<LabelValueItem>();
        prefix.add(new LabelValueItem(Label.PP_Prefix_Mr, 'Mr.'));
        prefix.add(new LabelValueItem(Label.PP_Prefix_Ms, 'Ms.'));
        prefix.add(new LabelValueItem(Label.PP_Prefix_Mrs, 'Mrs.'));
        prefix.add(new LabelValueItem(Label.PP_Prefix_Dr, 'Dr.'));
        prefix.add(new LabelValueItem(Label.PP_Prefix_Prof, 'Prof.'));
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
            WHERE
                Participant_Contact__c IN :participantContIds
                AND Participant_Status__c IN :PEStatusState.PE_STATUS_GROUP_IN_PROGRESS_ALL
                AND Clinical_Trial_Profile__r.Logged_Out_Days_Notification__c != NULL
        ];

        Map<Id, Integer> nearestNotificationByContactIds = new Map<Id, Integer>();
        for (Participant_Enrollment__c pe : enrollments) {
            Id contactId = pe.Participant_Contact__c != null
                ? pe.Participant_Contact__c
                : pe.Participant__r.Contact__c;
            Integer daysNotification = (Integer) pe.Clinical_Trial_Profile__r.Logged_Out_Days_Notification__c;

            if (!nearestNotificationByContactIds.containsKey(contactId)) {
                nearestNotificationByContactIds.put(contactId, daysNotification);
            }

            Integer currentNotification = nearestNotificationByContactIds.get(contactId);
            if (currentNotification > daysNotification) {
                nearestNotificationByContactIds.put(contactId, daysNotification);
            }
        }

        return nearestNotificationByContactIds;
    }

    public static String getParticipantFullName(Id contactId) {
        List<Participant__c> participant = [
            SELECT Full_Name__c
            FROM Participant__c
            WHERE Contact__c = :contactId
        ];
        if (participant.isEmpty())
            throw new ParticipantServiceException('This contact hasn\'t participant!');

        return participant.get(0).Full_Name__c;
    }

    public static List<Participant__c> checkParticipantsAgeOfMajority(
        List<Participant__c> participants
    ) {
        List<Age_of_Majority__mdt> ageOfMajorities = Age_Of_Majorities;

        for (Participant__c prt : participants) {
            if (prt.Adult__c || String.isBlank(prt.Date_of_Birth__c))
                continue;
            try {
                Date birthDate = Date.newInstance(
                    Integer.valueOf(prt.Date_of_Birth__c.substring(0, 4)),
                    Integer.valueOf(prt.Date_of_Birth__c.substring(5, 7)),
                    Integer.valueOf(prt.Date_of_Birth__c.substring(8, 10))
                );

                Integer participantAge = Date.newInstance(
                        2000,
                        birthDate.month(),
                        birthDate.day()
                    ) < Date.newInstance(2000, Date.today().month(), Date.today().day())
                    ? Date.today().year() - birthDate.year()
                    : Date.today().year() - birthDate.year() - 1;

                for (Age_of_Majority__mdt ageOfMajority : ageOfMajorities) {
                    if (
                        prt.Mailing_Country_Code__c == ageOfMajority.Country_Code__c ||
                        String.isBlank(ageOfMajority.Country_Code__c)
                    )
                        if (
                            prt.Mailing_State_Code__c == ageOfMajority.State_Code__c ||
                            String.isBlank(ageOfMajority.State_Code__c)
                        ) {
                            prt.Adult__c = participantAge >= ageOfMajority.Age__c;
                            break;
                        }
                }
            } catch (Exception e) {
            }
        }
        return participants;
    }
    public static String getFormattedTime() {
        User userVal = [SELECT Id, timezonesidkey FROM User WHERE Id = :UserInfo.getUserId()];
        return getFormattedTimeImpl(userVal);
    }
    public static String getFormattedTimeImpl(User userVal) {
        String userTimeZoneValue = '';
        String strDateTimeValue = '';
        try {
            String timeZoneValue = TimeZone.getTimeZone(String.valueof(userval.timezonesidkey))
                .getDisplayName();
            if (!String.isBlank(timeZoneValue)) {
                userTimeZoneValue = userval.timezonesidkey + ' ' + timeZoneValue;
            }
            if (!String.isBlank(userTimeZoneValue)) {
                strDateTimeValue =
                    System.now()
                        .format('dd/MMM/yyyy HH:mm:ss', String.valueof(userval.timezonesidkey)) +
                    ' ' +
                    userTimeZoneValue;
            }
        } catch (Exception e) {
            System.debug('Exception e --' + e.getMessage());
        }
        return strDateTimeValue;
    }
}
