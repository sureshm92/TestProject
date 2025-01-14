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
                initData.ctp = TrialService.getTrial(initData.ss.Clinical_Trial_Profile__c);
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
        Boolean allowDelegateContact
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
            pe.Permit_Voice_Text_contact_for_this_study__c = allowPhone;
            pe.Permit_SMS_Text_for_this_study__c = allowSMS;
			//pe.Invited_To_Patient_Portal__c = createUser && participant.Adult__c;
            if(createUser && participant.Adult__c){
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
                update participantCon;
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
            createParticipantDelegate(
                participantDelegateJSON,
                delegateDuplicateInfo,
                participantId,
                participantJSON,
                allowDelegateContact,
                TaskService.invitationsVisibleTemp // added this to hold the value of this param in future method
            );
            //Moved history Creation to Trigger
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }
 
    @Future
    private static void assignParticipantPermissions(String ssId, String contactId) {
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

     @Future
    @TestVisible
    public static void updateParticipant(String participantJSON) {
        Participant__c participant = (Participant__c) JSON.deserialize(
            participantJSON,
            Participant__c.class
        );
        Integer limitRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
        if (
            (participant.Email__c != null 
            ||participant.Phone__c != Null) &&
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
                   if(String.isNotBlank(participant.First_Name__c)){
                        partici.First_Name__c = participant.First_Name__c;
                    }
                    if(String.isNotBlank(participant.Last_Name__c)){
                        partici.Last_Name__c = participant.Last_Name__c;
                    }
                    if(String.isNotBlank(participant.Suffix__c)){
                        partici.Suffix__c = participant.Suffix__c;
                    }
                    if(String.isNotBlank(participant.Middle_Name__c)){
                        partici.Middle_Name__c = participant.Middle_Name__c;
                    }
                    if(String.isNotBlank(participant.Nickname__c)){
                        partici.Nickname__c = participant.Nickname__c;
                    }
                   // partici.Date_of_Birth__c = participant.Date_of_Birth__c;
                   if(String.isNotBlank(participant.Gender__c)){
                    partici.Gender__c = participant.Gender__c;
                   }
                   if(String.isNotBlank(participant.Email__c)){
                    partici.Email__c = participant.Email__c;
                   }
                   if(String.isNotBlank(participant.Phone__c)){
                    partici.Phone__c = participant.Phone__c;
                   }
                   if(String.isNotBlank(participant.Phone_Type__c)){
                    partici.Phone_Type__c = participant.Phone_Type__c;
                   }
                   if(String.isNotBlank(participant.Mailing_Country_Code__c)){
                    partici.Mailing_Country_Code__c = participant.Mailing_Country_Code__c;
                   }
                   if(String.isNotBlank(participant.Mailing_Zip_Postal_Code__c)){
                    partici.Mailing_Zip_Postal_Code__c = participant.Mailing_Zip_Postal_Code__c;
                   }
                   if(String.isNotBlank(participant.Mailing_State_Code__c)){
                    partici.Mailing_State_Code__c = participant.Mailing_State_Code__c;
                   }
                   if(String.isNotBlank(participant.Preferred_Language__c)){
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

    @Future
    @TestVisible
    private static void createParticipantDelegate(
        String participantDelegateJSON,
        String delegateDuplicateInfo,
        String participantId,
        String participantJSON,
        Boolean createDelegateuser,
        Map<Id,String> invitationsVisibleTemp 
    ) {
        Participant__c participant = (Participant__c) JSON.deserialize(
            participantJSON,
            Participant__c.class
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
                    	MailingPostalCode
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
            if (participantId != null && newContact.Id != null) {
                List<Patient_Delegate__c> checkPDel = [
                    SELECT Id
                    FROM Patient_Delegate__c
                    WHERE Participant__c = :participantId AND Contact__c = :newContact.Id
                ];
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
                        communityTemplateName == CommunityTemplateService.TEMPLATE_DEFAULT
                    ) {
                        TriggerHandlerExecutor.bypassHandler(
                            PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
                        );
                    }

                    insert ptDelegateRef;
                }
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
                if (TaskService.invitationsVisibleTemp != null && !TaskService.invitationsVisibleTemp.isEmpty()){
                    TaskService.createSurveyTasksforDelegate(TaskService.invitationsVisibleTemp,true);
                }
            }
        }

        //REF-3566
         else{
             if (participantId != null ) {
                 List<Patient_Delegate__c> pdList = new List<Patient_Delegate__c>();
                 For(Patient_Delegate__c pd : [SELECT Id,
                                               Primary_Delegate__c
                                               FROM Patient_Delegate__c
                                               WHERE Participant__c =: participantId 
                                              ]) {
                                                  pd.Primary_Delegate__c = False;
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
