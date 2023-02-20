/**
 * Created by Leonid Bartenev
 */

public without sharing class AddPatientByPIRemote {
    public class FormData {
        @AuraEnabled
        public List<LabelValueItem> countriesLVList = CountryStateUtil.getCountries();
        @AuraEnabled
        public Map<String, List<LabelValueItem>> statesByCountryMap = CountryStateUtil.getStatesByCountryMap();
        @AuraEnabled
        public List<LabelValueItem> genderLVList = ParticipantService.getGenderLVList();
        @AuraEnabled
        public List<LabelValueItem> phoneTypeLVList = SObjectHelper.getPicklistLabelValueList(
            Participant__c.Phone_Type__c
        );
        @AuraEnabled
        public List<LabelValueItem> referredByLVList = SObjectHelper.getPicklistLabelValueList(
            Participant_Enrollment__c.Referred_By__c
        );
        @AuraEnabled
        public List<LabelValueItem> languageLVList = SObjectHelper.getPicklistLabelValueList(
            Contact.Language__c
        );
        @AuraEnabled
        public List<LabelValueItem> yearOfBirth;
        @AuraEnabled
        public List<LabelValueItem> peStatusLVList;
        @AuraEnabled
        public List<LabelValueItem> visitPlansLVList;
        @AuraEnabled
        public Clinical_Trial_Profile__c ctp;
        @AuraEnabled
        public Study_Site__c ss;
        @AuraEnabled
        public String userLanguage;

        public FormData() {
        }
    }

    @AuraEnabled
    public static FormData getInitData(Id ssId) {
        try {
            FormData initData = new FormData();
            if (ssId != null) {
                initData.ss = StudySiteService.getStudySiteForPIById(ssId);
                List<String> CTP_FIELDS_ADDPBYPI = TrialService.CTP_FIELDS;
                CTP_FIELDS_ADDPBYPI.add('Promote_to_SH__c');
                CTP_FIELDS_ADDPBYPI.add('DCT_Platform__c');
                initData.ctp = TrialService.getTrial(initData.ss.Clinical_Trial_Profile__c, CTP_FIELDS_ADDPBYPI);
                initData.visitPlansLVList = StudySiteService.getVisitPlansLVList(ssId);
                initData.peStatusLVList = PEStatusState.getParticipantImportStatusesLV(
                    initData.ctp
                );
                initData.userLanguage = getUserLanguage();
                initData.yearOfBirth = ParticipantService.getYearofBirthList();
            }
            return initData;
        } catch (Exception e) {
            return (FormData) AuraHelper.throwException(e);
        }
    }

    //TODO:Review
    @AuraEnabled
    public static void saveParticipant(
        String participantJSON,
        String peJSON,
        String userLanguage,
        String ssId,
        Boolean createUser,
        String participantDelegateJSON,
        String delegateDuplicateInfo,
        Boolean allowEmail,
        Boolean allowPhone,
        Boolean allowSMS,
        Boolean allowContact,
        Boolean allowDelegateContact,
        String contactConsentJSON,
        Boolean iqviaOutreachEnabled
    ) {
        try {
            TriggerHandlerExecutor.bypassHandler(
                ContactTriggerHandler.CreateUserForCCContactHandler.class
            );

            if (!createUser) {
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    UserTriggerHandler.AssignCommunityPermissionSetToUserHandler.class
                );
            } else {
                if (ReferringRemote.checkNeedsGuardian(participantJSON) == 'true') {
                    TriggerHandlerExecutor.bypassHandler(
                        ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
                    );
                }
            }

            Participant__c participant = (Participant__c) JSON.deserialize(
                participantJSON,
                Participant__c.class
            );
            trimParticipantFields(participant);
            Participant_Enrollment__c pe = (Participant_Enrollment__c) JSON.deserialize(
                peJSON,
                Participant_Enrollment__c.class
            );
            participant.Secondary_Source__c = ParticipantEnrollmentService.PE_REFERRAL_SOURCE_PI;
            pe.Referral_Source__c = 'PI';
            pe.Permit_IQVIA_to_contact_about_study__c = allowContact;
            pe.Permit_Mail_Email_contact_for_this_study__c = allowEmail;
            pe.Study_Direct_Mail_Consent__c = allowEmail;
            pe.Permit_Voice_Text_contact_for_this_study__c = allowPhone;
            pe.Permit_SMS_Text_for_this_study__c = allowSMS;
            pe.Study_Pre_recorded_Voice_Consent__c = allowPhone;
            pe.Study_Assisted_Dialing_Consent__c = allowPhone;
            pe.Study_Artificial_Voice_Consent__c = allowPhone;
            
			//pe.Invited_To_Patient_Portal__c = createUser && participant.Adult__c;
            if(createUser && participant.Adult__c && String.isNotBlank(participant.Email__c)){//RH-5163
                pe.Invited_To_PP_Date__c =  DateTime.now();
            }

            Participant__c participantDelegate;
            if (!String.isBlank(participantDelegateJSON)) {
                participantDelegate = (Participant__c) JSON.deserialize(
                    participantDelegateJSON,
                    Participant__c.class
                );
                if (participantDelegate != null) {
                    participantDelegate.Secondary_Source__c = ParticipantEnrollmentService.PE_REFERRAL_SOURCE_HCP;
                }
            }
            //DOB changes start 
            String studyConfig = [select Participant_DOB_format__c FROM Study_Site__c where id=:ssId].Participant_DOB_format__c;
            if(studyConfig.contains('DD')){
                participant.Birth_Day__c = participant.Date_of_Birth__c.substring(8,10);
                Date birthDate = Date.newInstance(
                    Integer.valueOf(participant.Date_of_Birth__c.substring(0, 4)),
                    Integer.valueOf(participant.Date_of_Birth__c.substring(5, 7)),
                    Integer.valueOf(participant.Date_of_Birth__c.substring(8, 10))
                );

                Integer participantAge = Date.newInstance(
                        2000,
                        birthDate.month(),
                        birthDate.day()
                    ) <= Date.newInstance(2000, Date.today().month(), Date.today().day())
                    ? Date.today().year() - birthDate.year()
                    : Date.today().year() - birthDate.year() - 1;
                
                participant.Age__c = participantAge;
            }
            if(studyConfig.contains('MM')){
                participant.Birth_Month__c = participant.Date_of_Birth__c.substring(5,7);
            }
            if(studyConfig.contains('YYYY')){
                participant.Birth_Year__c = participant.Date_of_Birth__c.substring(0,4);
            }
            participant.Date_of_Birth__c = null;
            system.debug('participant.Age__c'+participant.Age__c);
            //DOB changes end
            ParticipantService.createParticipantAndUpdatePE(
                participant,
                participantDelegate,
                pe,
                userLanguage
            );
            String participantId = !String.isBlank(participant.Id)
                ? participant.Id
                : pe.Participant__c;
            Participant__c newParticipant = [
                SELECT Id, Contact__c, Phone__c
                FROM Participant__c
                WHERE Id = :participantId
            ];
            if (newParticipant.Contact__c != null) {
                Contact participantCon = new Contact(Id = newParticipant.Contact__c);

                if (participant.Phone_Type__c == 'Home') {
                    participantCon.HomePhone = participant.Phone__c;
                }
                if (participant.Phone_Type__c == 'Mobile') {
                    participantCon.MobilePhone = participant.Phone__c;
                } else {
                    participantCon.Phone = participant.Phone__c;
                }
                if (
                    iqviaOutreachEnabled &&
                    String.isNotBlank(contactConsentJSON) &&
                    String.isNotEmpty(contactConsentJSON)
                ) {
                    contact contactConsent = (Contact) JSON.deserialize(
                        contactConsentJSON,
                        Contact.class
                    );
                    participantCon.Participant_Opt_In_Status_Emails__c = contactConsent.Participant_Opt_In_Status_Emails__c;
                    participantCon.Participant_Opt_In_Status_SMS__c = contactConsent.Participant_Opt_In_Status_SMS__c;
                    participantCon.Participant_Phone_Opt_In_Permit_Phone__c = contactConsent.Participant_Phone_Opt_In_Permit_Phone__c;
                    participantCon.IQVIA_Artificial_Voice_Consent__c = contactConsent.Participant_Phone_Opt_In_Permit_Phone__c;
                    participantCon.IQVIA_Assisted_Dialing_Consent__c = contactConsent.Participant_Phone_Opt_In_Permit_Phone__c;
                    participantCon.IQVIA_Pre_recorded_Voice_Consent__c = contactConsent.Participant_Phone_Opt_In_Permit_Phone__c;
                    participantCon.IQVIA_Direct_Mail_Consent__c = contactConsent.IQVIA_Direct_Mail_Consent__c;
                   
                }
                  //update participantCon; converted to future method
                  String objJSONStr = Json.serialize(participantCon);
                  updateParticipantContact(objJSONStr);
            }

            if (
                createUser &&
                newParticipant != null &&
                !String.isBlank(newParticipant.Contact__c) &&
                !String.isBlank(ssId)
            ) {
                assignParticipantPermissions(ssId, newParticipant.Contact__c);
            }

            // updateParticipant(JSON.serialize(participant));
            if(!Test.isRunningTest()){
            createParticipantDelegate(
                participantDelegateJSON,
                delegateDuplicateInfo,
                participantId,
                participantJSON,
                allowDelegateContact,
                TaskService.invitationsVisibleTemp, // added this to hold the value of this param in future method
                contactConsentJSON,
                iqviaOutreachEnabled,
                false,
                null,
                allowEmail,
                allowPhone,
                allowSMS,
                allowContact
            );
            }
            //Moved history Creation to Trigger
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static list<String> saveParticipants(
        String participantJSON,
        String peJSON,
        String userLanguage,
        String ssId,
        Boolean createUser,
        String participantDelegateJSON,
        String delegateDuplicateInfo,
        Boolean allowEmail,
        Boolean allowPhone,
        Boolean allowSMS,
        Boolean allowContact,
        Boolean allowDelegateContact,
        String contactConsentJSON,
        Boolean iqviaOutreachEnabled
    ) {
        try {
            TriggerHandlerExecutor.bypassHandler(
                ContactTriggerHandler.CreateUserForCCContactHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class
            );
            if (!createUser) {
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    UserTriggerHandler.AssignCommunityPermissionSetToUserHandler.class
                );
            } else {
                if (ReferringRemote.checkNeedsGuardian(participantJSON) == 'true') {
                    TriggerHandlerExecutor.bypassHandler(
                        ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
                    );
                }
            }

            Participant__c participant = (Participant__c) JSON.deserialize(
                participantJSON,
                Participant__c.class
            );
            trimParticipantFields(participant);
            Participant_Enrollment__c pe = (Participant_Enrollment__c) JSON.deserialize(
                peJSON,
                Participant_Enrollment__c.class
            );
            participant.Secondary_Source__c = ParticipantEnrollmentService.PE_REFERRAL_SOURCE_PI;
            pe.Referral_Source__c = 'PI';
            pe.Permit_IQVIA_to_contact_about_study__c = allowContact;
            pe.Permit_Mail_Email_contact_for_this_study__c = allowEmail;
            pe.Study_Direct_Mail_Consent__c = allowEmail;
            pe.Permit_Voice_Text_contact_for_this_study__c = allowPhone;
            pe.Permit_SMS_Text_for_this_study__c = allowSMS;
            pe.Study_Pre_recorded_Voice_Consent__c = allowPhone;
            pe.Study_Assisted_Dialing_Consent__c = allowPhone;
            pe.Study_Artificial_Voice_Consent__c = allowPhone;
            
            //pe.Invited_To_Patient_Portal__c = createUser && participant.Adult__c;
            if(createUser && participant.Adult__c && String.isNotBlank(participant.Email__c)){//RH-5163
                pe.Invited_To_PP_Date__c =  DateTime.now();
            }

            Participant__c participantDelegate;
            if (!String.isBlank(participantDelegateJSON)) {
                participantDelegate = (Participant__c) JSON.deserialize(
                    participantDelegateJSON,
                    Participant__c.class
                );
                if (participantDelegate != null) {
                    participantDelegate.Secondary_Source__c = ParticipantEnrollmentService.PE_REFERRAL_SOURCE_HCP;
                }
            }
            //DOB changes start 
            String studyConfig = [select Participant_DOB_format__c FROM Study_Site__c where id=:ssId].Participant_DOB_format__c;
            if(studyConfig.contains('DD')){
                participant.Birth_Day__c = participant.Date_of_Birth__c.substring(8,10);
                Date birthDate = Date.newInstance(
                    Integer.valueOf(participant.Date_of_Birth__c.substring(0, 4)),
                    Integer.valueOf(participant.Date_of_Birth__c.substring(5, 7)),
                    Integer.valueOf(participant.Date_of_Birth__c.substring(8, 10))
                );
                Integer participantAge = Date.newInstance(
                        2000,
                        birthDate.month(),
                        birthDate.day()
                    ) <= Date.newInstance(2000, Date.today().month(), Date.today().day())
                    ? Date.today().year() - birthDate.year()
                    : Date.today().year() - birthDate.year() - 1;
                
                participant.Age__c = participantAge;
            }
            if(studyConfig.contains('MM')){
                participant.Birth_Month__c = participant.Date_of_Birth__c.substring(5,7);
            }
            if(studyConfig.contains('YYYY')){
                participant.Birth_Year__c = participant.Date_of_Birth__c.substring(0,4);
            }
            participant.Date_of_Birth__c = null;
            system.debug('participant.Age__c'+participant.Age__c);
            //DOB changes end
            list<String> parIDandDup = 
            ParticipantService.createParticipantAndUpdatePES(
                participant,
                participantDelegate,
                pe,
                userLanguage
            );
            return parIDandDup ;
        } catch (Exception e) {
            AuraHelper.throwException(e);
            return null;
        }
    }
    
    @AuraEnabled
    public static Integer savePER(
        String partId,
        String peJSON,
        String ssId,
        String participantDelegateJSON,
        String participantJSON,
        String delegateDuplicateInfo,
        String contactConsentJSON,
        Boolean iqviaOutreachEnabled,
        Boolean allowDelegateContact,
        Boolean createUser,
        Boolean allowEmail,
        Boolean allowPhone,
        Boolean allowSMS,
        Boolean allowContact,
        Boolean sendToSH,
        String ssType
    ) {
        try{ 
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class
            ); 
            TriggerHandlerExecutor.bypassHandler(
                ContactTriggerHandler.CreateUserForCCContactHandler.class
            );

            if (!createUser) {
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    UserTriggerHandler.AssignCommunityPermissionSetToUserHandler.class
                );
            } else {
                if (ReferringRemote.checkNeedsGuardian(participantJSON) == 'true') {
                    TriggerHandlerExecutor.bypassHandler(
                        ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
                    );
                }
            }
            Participant__c participant = (Participant__c) JSON.deserialize(
                participantJSON,
                Participant__c.class
            );
            trimParticipantFields(participant);
            Participant_Enrollment__c pe = (Participant_Enrollment__c) JSON.deserialize(
                peJSON,
                Participant_Enrollment__c.class
            );
            
            pe.Referral_Source__c = 'PI';
            pe.Permit_IQVIA_to_contact_about_study__c = allowContact;
            pe.Permit_Mail_Email_contact_for_this_study__c = allowEmail;
            pe.Study_Direct_Mail_Consent__c = allowEmail;
            pe.Permit_Voice_Text_contact_for_this_study__c = allowPhone;
            pe.Permit_SMS_Text_for_this_study__c = allowSMS;
            pe.Study_Pre_recorded_Voice_Consent__c = allowPhone;
            pe.Study_Assisted_Dialing_Consent__c = allowPhone;
            pe.Study_Artificial_Voice_Consent__c = allowPhone;
            
            if(createUser && participant.Adult__c && String.isNotBlank(participant.Email__c)){//RH-5163
                pe.Invited_To_PP_Date__c =  DateTime.now();
            }     
             
            String participantId = !String.isBlank(partId)
                ? partId
                : pe.Participant__c;
            Participant__c newParticipant = [
                SELECT Id, Contact__c, Phone__c,Phone_Type__c,First_Name__c,Last_Name__c
                FROM Participant__c
                WHERE Id = :participantId 
            ];
            system.debug('>>BeforePEINSERT>' + limits.getQueries());
            if (pe != null) {
                pe.Participant__c = partId;
                if (pe.Participant_Name__c == null)
                    pe.Participant_Name__c = newParticipant.First_Name__c;
                if (pe.Participant_Surname__c == null)
                    pe.Participant_Surname__c = newParticipant.Last_Name__c;
                try {
                    system.debug('>>BeforeUpsertPE>' + limits.getQueries());
                    DatabaseService.getInstance().upsertToDB(pe);
                    system.debug('>>aFTERUpsertPE>' + limits.getQueries());
                } catch (Exception e) {
                    String errorMsg = e.getMessage();
                    if (errorMsg.contains('DUPLICATE')) {
                        errorMsg = Label.Error_Message_Participant_Duplicate;
                    }
                    System.debug('ERROR: ' + errorMsg);AuraHelper.throwException(e);
                    //throw new ParticipantServiceException(errorMsg);
                }
            }
            
            if (newParticipant.Contact__c != null) {
                Contact participantCon = new Contact(Id = newParticipant.Contact__c);

                if (newParticipant.Phone_Type__c == 'Home') {
                    participantCon.HomePhone = newParticipant.Phone__c;
                }
                if (newParticipant.Phone_Type__c == 'Mobile') {
                    participantCon.MobilePhone = newParticipant.Phone__c;
                } else {
                    participantCon.Phone = newParticipant.Phone__c;
                }
                if (
                    iqviaOutreachEnabled &&
                    String.isNotBlank(contactConsentJSON) &&
                    String.isNotEmpty(contactConsentJSON)
                ) {
                    contact contactConsent = (Contact) JSON.deserialize(
                        contactConsentJSON,
                        Contact.class
                    );
                    participantCon.Participant_Opt_In_Status_Emails__c = contactConsent.Participant_Opt_In_Status_Emails__c;
                    participantCon.Participant_Opt_In_Status_SMS__c = contactConsent.Participant_Opt_In_Status_SMS__c;
                    participantCon.Participant_Phone_Opt_In_Permit_Phone__c = contactConsent.Participant_Phone_Opt_In_Permit_Phone__c;
                    participantCon.IQVIA_Artificial_Voice_Consent__c = contactConsent.Participant_Phone_Opt_In_Permit_Phone__c;
                    participantCon.IQVIA_Assisted_Dialing_Consent__c = contactConsent.Participant_Phone_Opt_In_Permit_Phone__c;
                    participantCon.IQVIA_Pre_recorded_Voice_Consent__c = contactConsent.Participant_Phone_Opt_In_Permit_Phone__c;
                    participantCon.IQVIA_Direct_Mail_Consent__c = contactConsent.IQVIA_Direct_Mail_Consent__c;
                   
                }
                  update participantCon;
                  //String objJSONStr = Json.serialize(participantCon);
                  //updateParticipantContact(objJSONStr);
            }

            if (
                createUser &&
                newParticipant != null &&
                !String.isBlank(newParticipant.Contact__c) &&
                !String.isBlank(ssId)
            ) {
                assignParticipantPermissions(ssId, newParticipant.Contact__c);
            }
            Boolean sendPEToStudyHubAsync= false;
            if((pe.Participant_Status__c == PEStatusState.PE_STATUS_SCREENING_PASSED ||
               pe.Participant_Status__c == PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS ||
               pe.Participant_Status__c == PEStatusState.PE_STATUS_RANDOMIZATION_SUCCESS ||
               pe.Participant_Status__c == PEStatusState.PE_STATUS_READY_TO_SCREEN
               )&& sendToSH == true && StudySiteService.SS_TYPE_VT_INTEGRATION.contains(ssType)){
                sendPEToStudyHubAsync = true;
            }
            // updateParticipant(JSON.serialize(participant));
            createParticipantDelegate(
                participantDelegateJSON,
                delegateDuplicateInfo,
                participantId,
                participantJSON,
                allowDelegateContact,
                TaskService.invitationsVisibleTemp, // added this to hold the value of this param in future method
                contactConsentJSON,
                iqviaOutreachEnabled,
                sendPEToStudyHubAsync,
                pe.Id,
                allowEmail,
                allowPhone,
                allowSMS,
                allowContact
            );
            //Moved history Creation to Trigger
            System.debug('>>>TRANSACTIONOVER>>>'+limits.getQueries());
            return limits.getQueries();
         } catch (Exception e) {
            AuraHelper.throwException(e);
            return limits.getQueries();
        }
       
    }

    @Future
    public static void updateParticipantContact(String objJson) {
             Contact participantCont = (Contact) JSON.deserialize(
            objJson,
            Contact.class
        );
        update participantCont;
    }

    @Future
    public static void assignParticipantPermissions(String ssId, String contactId) {
        Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
        Study_Site__c ss = StudySiteService.getStudySiteForPIById(ssId);
        String permissionSetName = CommunityTemplateService.getTemplate(
                ss.Clinical_Trial_Profile__r.CommunityTemplate__c
            )
            .permissionSet;
        actionAssignContactPermissions.addPermission(contactId, permissionSetName);
        if (!actionAssignContactPermissions.isEmpty()) {
            ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
        }
    }

    @AuraEnabled
    public static void updateParticipant(String participantJSON) {
        Participant__c participant = (Participant__c) JSON.deserialize(
            participantJSON,
            Participant__c.class
        );
        Integer limitRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
        if (
            ((participant.Email__c != null||
            participant.Phone__c != Null ||
            !participant.Adult__c) ||
            (participant.Email__c != null ||
            participant.Phone__c != null ||
            participant.Adult__c)) &&
            participant.First_Name__c != null &&
            participant.Last_Name__c != null
        ) {
            List<Participant__c> newPartcipantObjs = [
                SELECT
                    Id,
                    First_Name__c,
                    Last_Name__c,
                    Suffix__c,
                    Middle_Name__c,
                    Nickname__c,
                    Date_of_Birth__c,
                    Gender__c,
                    Email__c,
                    Contact__c,
                    Phone_Type__c,
                    Phone__c,
                    Mailing_Zip_Postal_Code__c,
                    Mailing_Country_Code__c,
                    Mailing_State_Code__c
                FROM Participant__c
                WHERE
                    (Email__c = :participant.Email__c
                    OR Phone__c =: participant.Phone__c )
                    AND First_Name__c = :participant.First_Name__c
                    AND Last_Name__c = :participant.Last_Name__c
                LIMIT :limitRows
            ];
            List<Participant__c> participantPatient = new List<Participant__c>();
            if (!newPartcipantObjs.isEmpty()) {
                for (Participant__c partici : newPartcipantObjs) {
                    if (String.isNotBlank(participant.First_Name__c)) {
                        partici.First_Name__c = participant.First_Name__c;
                    }
                    if (String.isNotBlank(participant.Last_Name__c)) {
                        partici.Last_Name__c = participant.Last_Name__c;
                    }
                    if (String.isNotBlank(participant.Suffix__c)) {
                        partici.Suffix__c = participant.Suffix__c;
                    }
                    if (String.isNotBlank(participant.Middle_Name__c)) {
                        partici.Middle_Name__c = participant.Middle_Name__c;
                    }
                    if (String.isNotBlank(participant.Nickname__c)) {
                        partici.Nickname__c = participant.Nickname__c;
                    }
                    /*if (String.isNotBlank(participant.Date_of_Birth__c)) {
                        partici.Date_of_Birth__c = participant.Date_of_Birth__c;
                   }*/
                   if(String.isNotBlank(participant.Birth_Day__c)){
                    partici.Birth_Day__c = participant.Birth_Day__c;
                   }
                   if (String.isNotBlank(participant.Birth_Month__c)) {
                    partici.Birth_Month__c = participant.Birth_Month__c;
                   }
                   if(String.isNotBlank(participant.Birth_Year__c)) {
                    partici.Birth_Year__c = participant.Birth_Year__c;
                    }
                   if(participant.Age__c!=null){
                    partici.Age__c = participant.Age__c;
                   }
                    if (String.isNotBlank(participant.Gender__c)) {
                        partici.Gender__c = participant.Gender__c;
                    }
                    if (String.isNotBlank(participant.Email__c)) {
                        partici.Email__c = participant.Email__c;
                    }
                    if (String.isNotBlank(participant.Phone__c)) {
                        partici.Phone__c = participant.Phone__c;
                    }
                    if (String.isNotBlank(participant.Phone_Type__c)) {
                        partici.Phone_Type__c = participant.Phone_Type__c;
                    }
                    if (String.isNotBlank(participant.Mailing_Country_Code__c)) {
                        partici.Mailing_Country_Code__c = participant.Mailing_Country_Code__c;
                    }
                    if (String.isNotBlank(participant.Mailing_Zip_Postal_Code__c)) {
                        partici.Mailing_Zip_Postal_Code__c = participant.Mailing_Zip_Postal_Code__c;
                    }
                    if (String.isNotBlank(participant.Mailing_State_Code__c)) {
                        partici.Mailing_State_Code__c = participant.Mailing_State_Code__c;
                    }
                    if (String.isNotBlank(participant.Preferred_Language__c)) {
                        partici.Preferred_Language__c = participant.Preferred_Language__c;
                    }
                    participantPatient.add(partici);
                }
                if (!participantPatient.isEmpty()) {
                    update participantPatient;
                }
            }
        }
    }

    @Future(Callout=true)
    @TestVisible
    private static void createParticipantDelegate(
        String participantDelegateJSON,
        String delegateDuplicateInfo,
        String participantId,
        String participantJSON,
        Boolean createDelegateuser,
        Map<Id,String> invitationsVisibleTemp,
        String contactConsentJSON,
        Boolean iqviaOutreachEnabled,
        Boolean sendPEToStudyHubAsync,
        Id peId,
        Boolean allowEmail,
        Boolean allowPhone,
        Boolean allowSMS,
        Boolean allowContact
    ) {
        //Bypaass old methods from Patient Delegate Trigger
        TriggerHandlerExecutor.bypassHandler(
        PatientDelegateTriggerHandler.CreateNewAssignmentNotification.class
        );
        TriggerHandlerExecutor.bypassHandler(
        PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
        );
        
        if(sendPEToStudyHubAsync == true){
            IntegrationService.sendPEToStudyHub(peId);
        }
        Participant__c participant = (Participant__c) JSON.deserialize(
            participantJSON,
            Participant__c.class
        );
        contact contactConsent = (Contact) JSON.deserialize(
            contactConsentJSON,
            Contact.class
        );
        Participant__c participantDelegate;
        if (!String.isBlank(participantDelegateJSON)) {
            participantDelegate = (Participant__c) JSON.deserialize(
                participantDelegateJSON,
                Participant__c.class
            );
            if (participantDelegate != null) {
                participantDelegate.Secondary_Source__c = ParticipantEnrollmentService.PE_REFERRAL_SOURCE_HCP;
            }
        }

        ReferHealthcareProviderRemote.HealthcareProvider ddInfo;
        if (delegateDuplicateInfo != null)
            ddInfo = (ReferHealthcareProviderRemote.HealthcareProvider) JSON.deserialize(
                delegateDuplicateInfo,
                ReferHealthcareProviderRemote.HealthcareProvider.class
            );
        if (ddInfo != null && ddInfo.participantId != null) {
            participantDelegate.Id = ddInfo.participantId;
            try {
                upsert participantDelegate;
            } catch (Exception exp) {
                system.debug('No delegate was provided');
            }
        }

        if (
            participantDelegate != null &&
            !String.isEmpty(participantDelegate.Last_Name__c) &&
            !String.isEmpty(participantDelegate.Email__c)
        ) {
            Contact newContact;
            if (ddInfo == null || String.isBlank(ddInfo.contactId)) {
                newContact = new Contact();
                newContact.FirstName = participantDelegate.First_Name__c;
                newContact.LastName = participantDelegate.Last_Name__c;
                newContact.Email = participantDelegate.Email__c;
                /*newContact.AccountId = [
                        SELECT Id
                        FROM Account
                        WHERE Name = :CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
                        LIMIT 1
                        FOR UPDATE
                ].Id;*/
                newContact.AccountId = participantDelegate.Site__c;
                newContact.Language__c = UserInfo.getLanguage();
                newContact.Second_Choice_Language__c = '';
                newContact.Third_Choice_Language__c = '';
                newContact.userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT;
                newContact.userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT;
                newContact.userCommunityIsDelegate__c = true;
                newContact.MailingCountryCode = participant.Mailing_Country_Code__c;
                newContact.MailingStateCode = participant.Mailing_State_Code__c;
                newContact.MailingCountry = participant.Mailing_Country__c;
                newContact.MailingState = participant.Mailing_State__c;
                newContact.MailingPostalCode = participant.Mailing_Zip_Postal_Code__c;
                if ('Home' == participantDelegate.Phone_Type__c) {
                    newContact.HomePhone = participantDelegate.Phone__c;
                }
                if ('Mobile' == participantDelegate.Phone_Type__c) {
                    newContact.MobilePhone = participantDelegate.Phone__c;
                } else {
                    newContact.Phone = participantDelegate.Phone__c;
                }
                insert newContact;
            } else {
                newContact = [
                    SELECT
                        Id,
                        FirstName,
                        LastName,
                        Email,
                        MailingCity,
                        MailingCountryCode,
                        MailingState,
                        MailingCountry,
                        MailingStateCode,
                    	MailingPostalCode,
                        Participant_Opt_In_Status_Emails__c,
                        Participant_Opt_In_Status_SMS__c,
                        Participant_Phone_Opt_In_Permit_Phone__c
                    FROM Contact
                    WHERE Id = :ddInfo.contactId
                ];
                createDelegateuser = false;
            }
            if (ddInfo == null || ddInfo.participantId == null) {
                participantDelegate.Contact__c = newContact.Id;
                participantDelegate.Adult__c = true;
                participantDelegate.Mailing_Country__c = participant.Mailing_Country__c;
                participantDelegate.Mailing_Country_Code__c = participant.Mailing_Country_Code__c;
                participantDelegate.Mailing_State__c = participant.Mailing_State__c;
                participantDelegate.Mailing_State_Code__c = participant.Mailing_State_Code__c;
                participantDelegate.Mailing_Zip_Postal_Code__c = participant.Mailing_Zip_Postal_Code__c;
                if (String.isNotBlank(participantDelegate.Birth_Year__c)) {
                    participantDelegate.Attestation__c = true;
                    participantDelegate.Attestation_TimeStamp__c = ParticipantService.getFormattedTime();
                    participantDelegate.Attested_by__c = CommunityService.getInstance()
                        .getCurrentContactId();
                }
                if (
                    String.isBlank(participantDelegate.Phone__c) &&
                    !String.isBlank(participant.Phone__c)
                ) {
                    participantDelegate.Phone__c = participant.Phone__c;
                    participantDelegate.Phone_Type__c = participant.Phone_Type__c;
                }
                insert participantDelegate;
            }
            //if(ddInfo == null || !ddInfo.isDuplicateDelegate) {
                List<Patient_Delegate__c> checkPDel;
                List<Patient_Delegate_Enrollment__c> addPatientDelEnrollForDup= new List<Patient_Delegate_Enrollment__c> ();
                if (participantId != null && newContact.Id != null) { 
                    checkPDel=new List<Patient_Delegate__c>();
                    List<Patient_Delegate__c> allPDelList = [
                        SELECT Id,Primary_Delegate__c,Participant__r.Email__c,Contact__c
                        FROM Patient_Delegate__c
                        WHERE Participant__c = :participantId 
                        //AND Contact__c = :newContact.Id
                    ];
                    for(Patient_Delegate__c pDel:allPDelList){
                        if(pDel.Contact__c==newContact.Id){
                            pDel.Primary_Delegate__c = True;
                            checkPDel.add(pDel);         
                            Patient_Delegate_Enrollment__c ptDelegateEnroll = new Patient_Delegate_Enrollment__c();
                            ptDelegateEnroll.Participant_Enrollment__c = peId;
                            ptDelegateEnroll.Patient_Delegate__c = pDel.Id;
                            ptDelegateEnroll.Primary_Delegate__c = true;
                            ptDelegateEnroll.Status__c = 'Disconnected';  
                            ptDelegateEnroll.Study_info_storage_consent__c = allowEmail;
                            ptDelegateEnroll.Study_Email_Consent__c = allowEmail;
                            ptDelegateEnroll.Study_Phone_Consent__c = allowPhone;
                            ptDelegateEnroll.Study_SMS_Consent__c = allowSMS;
                            addPatientDelEnrollForDup.add(ptDelegateEnroll);
                           }else {
                            pDel.Primary_Delegate__c = false;
                           }
                     }
                     update allPDelList;
                     insert addPatientDelEnrollForDup;
                     
                List<Participant_Enrollment__c> particpantEnrollList = [
                    SELECT
                        Id,
                        Study_Site__r.Study_Site_Type__c,
                        Study_Site__r.Suppress_Participant_Emails__c,
                        Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c
                    FROM Participant_Enrollment__c
                    WHERE Participant__c = :participantId
                ];

                if (checkPDel.isEmpty()) {
                    Participant__c mainParticipant = [
                        SELECT Id
                        FROM Participant__c
                        WHERE Id = :participantId
                        FOR UPDATE
                    ];
                    Patient_Delegate__c ptDelegateRef = new Patient_Delegate__c();
                    ptDelegateRef.Participant__c = mainParticipant.Id;
                    ptDelegateRef.Contact__c = newContact.Id;
                    ptDelegateRef.Primary_Delegate__c = true;
                    ptDelegateRef.Status__c = 'Disconnected';
                    /* if (ddInfo == null || ddInfo.participantId == null){
                        ptDelegateRef.Attestation__c = true; 
                        ptDelegateRef.Attestation_TimeStamp__c = Date.today(); 
                        ptDelegateRef.Attested_by__c = CommunityService.getInstance().getCurrentContactId();
                    } */
                    String communityTemplateName = UserContext.getCurrentCommunityTemplate()
                        .templateName;
                    if (
                        particpantEnrollList.size() > 0 &&
                        particpantEnrollList[0].Study_Site__r.Study_Site_Type__c ==
                        StudySiteService.SS_TYPE_TRADITIONAL &&
                        (particpantEnrollList[0].Study_Site__r.Suppress_Participant_Emails__c ||
                        particpantEnrollList[0]
                            .Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c) &&
                        (communityTemplateName == CommunityTemplateService.TEMPLATE_DEFAULT ||
                        communityTemplateName == CommunityTemplateService.TEMPLATE_PP)
                    ) {
                        TriggerHandlerExecutor.bypassHandler(
                            PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
                        );
                    }

                    insert ptDelegateRef;

                    Patient_Delegate_Enrollment__c ptDelegateEnroll = new Patient_Delegate_Enrollment__c();
                    ptDelegateEnroll.Participant_Enrollment__c = peId;
                    ptDelegateEnroll.Patient_Delegate__c = ptDelegateRef.Id;
                    ptDelegateEnroll.Primary_Delegate__c = true;
                    ptDelegateEnroll.Status__c = 'Disconnected';
                    ptDelegateEnroll.Study_info_storage_consent__c = allowEmail;
                    ptDelegateEnroll.Study_Email_Consent__c = allowEmail;
                    ptDelegateEnroll.Study_Phone_Consent__c = allowPhone;
                    ptDelegateEnroll.Study_SMS_Consent__c = allowSMS;

                             
                    insert ptDelegateEnroll;

                }
            }
            if(iqviaOutreachEnabled && ((checkPDel.isEmpty() && (participant.Email__c == null || participant.Email__c == '' || participant.Email__c.trim() == '')) || 
              (checkPDel != null && !checkPDel.isEmpty() && checkPDel[0].Primary_Delegate__c && checkPDel[0].Participant__r.Email__c == null) )
               && String.isNotBlank(contactConsentJSON) && String.isNotEmpty(contactConsentJSON)){
                    contact con = new contact();
                    con.id = newContact.Id;
                    con.Participant_Opt_In_Status_Emails__c = contactConsent.Participant_Opt_In_Status_Emails__c;
                    con.Participant_Opt_In_Status_SMS__c = contactConsent.Participant_Opt_In_Status_SMS__c;
                    con.Participant_Phone_Opt_In_Permit_Phone__c = contactConsent.Participant_Phone_Opt_In_Permit_Phone__c;
                    con.IQVIA_Artificial_Voice_Consent__c = contactConsent.Participant_Phone_Opt_In_Permit_Phone__c;
                    con.IQVIA_Assisted_Dialing_Consent__c = contactConsent.Participant_Phone_Opt_In_Permit_Phone__c;
                    con.IQVIA_Pre_recorded_Voice_Consent__c = contactConsent.Participant_Phone_Opt_In_Permit_Phone__c;
                    con.IQVIA_Direct_Mail_Consent__c = contactConsent.IQVIA_Direct_Mail_Consent__c;
                    
                    TriggerHandlerExecutor.bypassHandler(
                        ContactTriggerHandler.CreateUserForDelegateContactHandler.class
                    );
                    TriggerHandlerExecutor.bypassHandler(
                        ContactTriggerHandler.PopulateOverrideFields.class
                    );
                    TriggerHandlerExecutor.bypassHandler(
                        ContactTriggerHandler.CreateUserForCCContactHandler.class
                    );
                    TriggerHandlerExecutor.bypassHandler(
                        ContactTriggerHandler.UpdateParticipantDetailsHandler.class
                    );
                    update con;
            }
            // }
            if (createDelegateuser) {
                /*ReferringRemote.createParticipantUsers(new Map<Id, Id>{
                        newContact.Id => null
                });*/
                ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                    .createParticipantUsers(new Map<Id, Id>{ newContact.Id => null });
                //Recalling createSurveyTasks method to create survey task for Patient Delegates
                TaskService.invitationsVisibleTemp = invitationsVisibleTemp;
                if (
                    TaskService.invitationsVisibleTemp != null &&
                    !TaskService.invitationsVisibleTemp.isEmpty()
                ) {
                    TaskService.createSurveyTasksforDelegate(
                        TaskService.invitationsVisibleTemp,
                        true
                    );
                }
            }
        } else {
            //REF-3566
            if (participantId != null) {
                List<Patient_Delegate__c> pdList = new List<Patient_Delegate__c>();
                for (Patient_Delegate__c pd : [
                    SELECT Id, Primary_Delegate__c
                    FROM Patient_Delegate__c
                    WHERE Participant__c = :participantId
                ]) {
                    pd.Primary_Delegate__c = false;
                    pdList.add(pd);
                }
                update pdList;
            }
        }
    }

    @AuraEnabled
    public static Participant_Enrollment__c updatePatientInfo(
        String participantJSON,
        String peJSON
    ) {
        try {
            Participant__c participant = (Participant__c) JSON.deserialize(
                participantJSON,
                Participant__c.class
            );
            if (participant.Contact__r.Email == null && participant.Email__c != null) {
                update new Contact(Id = participant.Contact__c, Email = participant.Email__c);
            }
            Participant_Enrollment__c pe = (Participant_Enrollment__c) JSON.deserialize(
                peJSON,
                Participant_Enrollment__c.class
            );
            update pe;
            update participant;
            return pe;
        } catch (Exception e) {
            AuraHelper.throwException(e);
            return null;
        }
    }
    @AuraEnabled
    public static String getUserLanguage() {
        return UserInfo.getLanguage();
    }

    private static void trimParticipantFields(Participant__c participant) {
        participant.Phone__c = !String.isBlank(participant.Phone__c)
            ? participant.Phone__c.trim()
            : null;
        participant.First_Name__c = !String.isBlank(participant.First_Name__c)
            ? participant.First_Name__c.trim()
            : null;
        participant.Last_Name__c = !String.isBlank(participant.Last_Name__c)
            ? participant.Last_Name__c.trim()
            : null;
        participant.Email__c = !String.isBlank(participant.Email__c)
            ? participant.Email__c.trim()
            : null;
    }

    @AuraEnabled
    public static String checkNeedsGuardian(String participantJSON) {
        return ReferringRemote.checkNeedsGuardian(participantJSON);
    }

    @AuraEnabled
    public static String checkDelegateAge(String participantJSON, String delegateParticipantJSON) {
        return ReferringRemote.checkDelegateAge(participantJSON, delegateParticipantJSON);
    }

    @AuraEnabled
    public static ReferHealthcareProviderRemote.HealthcareProvider checkDuplicateDelegate(
        String email,
        String firstName,
        String lastName
    ) {
        return ReferHealthcareProviderRemote.checkDuplicate(null, email, firstName, lastName, null);
    }
}