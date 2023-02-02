/**
 * Created by D.Yasinskyi  on 07.05.2018
 */
public without sharing class AccountSettingsController {
    public static String loggedInUserMode;
    public static ParticipantService.ParticipantState participantState;
    public static final String USER_MODE_HCP = 'HCP';
    public static Boolean isAdultParticipant = false;
    public static Boolean isEmailAvailabelForParticipant = false;
    public static Boolean isDelegateSelfView = false;
    public static Boolean isIQIVAOutrechToggleOnAtCTP = false;
    public static Boolean isPrimaryDelegate = false;
    public static Boolean isPrimaryDelegateWithMultiRole = false;
    public static Boolean isDelegateAlsoAParticipant = false;
    public static Boolean isParticipantLoggedIn = true;
    public static Boolean checkIfDelAlsoAParticipant = false;
    public static Id currentParticipantId = null;
    public static Participant__c delegateParticipant = new Participant__c();
    public static Contact delegateContact = new Contact();
    public static Map<Id, List<Participant_Enrollment__c>> participantIdListOfPerMap = new Map<Id, List<Participant_Enrollment__c>>();
    public static List<Participant_Enrollment__c> perListforCommPref = new List<Participant_Enrollment__c>();
    public static List<Participant_Enrollment__c> perListAllforCommPref = new List<Participant_Enrollment__c>();
    @AuraEnabled
    public static PIR_ParticipantDetailController.CountyrStateInfo getCountryCodes(String userMode) {
        PIR_ParticipantDetailController.CountyrStateInfo countyrStateInfo = new PIR_ParticipantDetailController.CountyrStateInfo();
        countyrStateInfo = PIR_ParticipantDetailController.getCnData();
        return  countyrStateInfo;
    }
    
    @AuraEnabled
    public static String getInitData(String userMode) {
        try {
            loggedInUserMode = userMode;
            AccountSettingsController.AccountData initData = new AccountSettingsController.AccountData();
            initData.myContact = getCurrentContact();
            if (
                loggedInUserMode != USER_MODE_HCP &&
                initData.myContact.userCommunityDelegateId__c != null
            ) {
                //Get the Current Participant Id where Delegate is switched. 
                currentParticipantId = ParticipantContext.getCurrentParticipantId(); 
                 //This logic is not required as part of Delegate redesing changes, as delegate will be Primary/Secondary for study specific.
                // //Check if Patient Delegate is a Primary delegate if Patient Delegate clicks account setting of participant
                // initData.consentPreferenceData.isPrimaryDelegate = PatientDelegateService.isPrimaryDelegate(
                //     initData.myContact.Id,
                //     currentParticipantId
                // );
                //As delegate switched to Participant Account setting so set isParticipantLoggedIn to false.
                initData.consentPreferenceData.isParticipantLoggedIn = false;
                //Store the Delegate contact record.
                delegateContact = initData.myContact;
                //get the delegate's own participant record.
                delegateParticipant = getParticipantRecord(initData.myContact.Id);

                initData.myContact = ContactService.getContact(
                    initData.myContact.userCommunityDelegateId__c
                );
            }
            system.debug('userContact-->' + initData.myContact);

            ContactService.applyRelevantNames(initData.myContact);
            initData.cookieSettings = getCookieSettings();
            initData.cookieDescription = Label.AccountSettings_Cookie_Description;

            if (initData.myContact.primaryContact__c == null) {
                if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
                    // get the Participant record from contact Id.
                    initData.participant = getParticipantRecord(initData.myContact.Id);
                    //translate country:
                    initData.participant.Mailing_Country__c = CountryStateUtil.getCountryName(
                        initData.participant.Mailing_Country_Code__c
                    );

                    //translate state
                    initData.participant.Mailing_State__c = CountryStateUtil.getStateName(
                        initData.participant.Mailing_Country_Code__c,
                        initData.participant.Mailing_State_Code__c
                    );

                    //Task for updating profile exists Account
                    List<Task> tasks = TaskService.getInstance()
                        .getTasksCommon(
                            'Status = \'Open\' AND Task_Code__c = \'Complete_Your_Profile\''
                        );
                    initData.contactSectionData.participantHasUpdateTasks = !tasks.isEmpty();

                    initData.cookieDescription = Label.PP_Account_Settings_Cookie_Description;
                    String communityName = TranslateHelper.getLabelValue(
                        UserContext.getTemplateProperty('CommunityWelcome')
                    );
                    initData.cookieDescription = initData.cookieDescription.replace(
                        '##CommunityWelcome',
                        communityName
                    );
                    ParticipantService.ParticipantState participantState = ParticipantService.getInstance()
                        .getState();
                        initData.participantState = participantState;
                    List<Participant_Enrollment__c> participantEnrollments = new List<Participant_Enrollment__c>();
                    List<Id> peIds = new List<Id>();
                    peIds = PatientDelegateService.getAvailablePEIdsForContact(
                        participantState.participant.Contact__c
                    );

                    List<Participant_Enrollment__c> availablePEs = getPERRecords(peIds);

                    if (availablePEs != null)
                        participantEnrollments.addAll(availablePEs);
                    List<Participant_Enrollment__c> pastEnrollments = ContactService.getPastEnrollments(
                        participantState.participant.Contact__c
                    );

                    if (pastEnrollments != null)
                        participantEnrollments.addAll(pastEnrollments);

                    if (participantEnrollments != null){
                        perListAllforCommPref.addAll(participantEnrollments);
                    }
                    
                    //For Delegate of Alumni Participant, get the PER Record from Alumni Participant for Delegate View.
                    List<Id> peIdList= new List<Id>();
                    if (
                        (pastEnrollments == null || pastEnrollments.isEmpty()) &&
                        participantState.hasPatientDelegates                        
                        // && !participantState.isDelegate
                    ) {
                        peIdList = PatientDelegateService.getAvailablePEIdsForDelContact(
                            participantState.participant.Contact__c
                        );

                        List<Participant_Enrollment__c> availablePEsForDel = getPERRecords(peIdList);
                        if (availablePEsForDel != null)
                        perListAllforCommPref.addAll(availablePEsForDel);
                    }

                    //TODO: Redesign this logic for delegate redesign changes - Start
                    //When delegate was delegate of Alumi Participant and Delegate withdrawn from Alumi Participant.
                    //Note: In this case there wont be any PER record associated with Delegate via Participant. 
                    if (
                        !participantState.hasPatientDelegates &&
                        !participantState.isDelegate && 
                        (perListAllforCommPref == null || perListAllforCommPref.isEmpty())
                    ) {
                        //Get the PER Record from the alumni Participant.
                        peIdList = PatientDelegateService.getAvailablePEIdsForDelContact(
                            participantState.participant.Contact__c
                        );

                        List<Participant_Enrollment__c> availablePEsForDel = getPERRecords(peIdList);
                        if (availablePEsForDel != null)
                        perListAllforCommPref.addAll(availablePEsForDel);
                        initData.consentPreferenceData.isWithdrawnDelegate = true;
                        //isDelegateSelfView = true;
                        //checkIfDelAlsoAParticipant = true;
                    }
                     //TODO: Redesign this logic for delegate redesign changes - Start

                    //if (perListAllforCommPref != null) {
                        //Prepare Communication Preference data.
                        prepareCommunicationPreferenceData(perListAllforCommPref, initData);
                    //}

                    //Prepare Program Overview data
                    //check if delegate self view or delegate viewing as an alumni participant
                    if (
                        participantState.value == ParticipantService.ParticipantStates.ALUMNI &&
                        participantState.hasPatientDelegates
                    ) {
                        initData.programOverViewData.isDelegateSelfView = true;
                    }
                    if (
                        participantState.value == ParticipantService.ParticipantStates.ALUMNI &&
                        !participantState.hasPatientDelegates
                    ) {
                        //check if Alunmi participant
                        initData.programOverViewData.isAlumniParticipant = true;
                    }
                    initData.programOverViewData.communityName = participantState.communityName;

                    for (Participant_Enrollment__c p : participantEnrollments) {
                        if (p.Study_Site__r.SMS_Are_Available__c) {
                            initData.isSMSAvailableFromSS = true;
                            break;
                        }
                    }
                } else {
                    initData.contactSectionData.institute = getInstituteById(
                        initData.myContact.AccountId
                    );
                }
            } else {
                initData.contactSectionData.institute = getInstituteById(
                    initData.myContact.primaryContact__r.AccountId
                );
            }

            initData.contactSectionData.personWrapper = new PersonWrapper(
                initData.myContact,
                initData.participant
            );
            initData.userName = UserInfo.getUserName();
            User uval = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            initData.delegateContact = [SELECT Id FROM Contact WHERE Id = :uval.ContactId];

            if (
                initData.participant.Adult__c ||
                (userMode == 'PI' ||
                userMode == 'HCP' ||
                userMode == 'CC')
            ) {
                List<User> delUsers = [
                    SELECT Id, Email, Name, Username, FullPhotoUrl
                    FROM User
                    WHERE ContactId = :initData.myContact.Id
                ];
                if (delUsers != null && !delUsers.isEmpty()) {
                    initData.delegateUserName = delUsers[0];
                }
                if (initData.delegateUserName != null) {
                    initData.hasProfilePic = !initData.delegateUserName.FullPhotoUrl.contains(
                        'profilephoto/005/F'
                    );
                }
            }
            return JSON.serialize(initData, false);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void updateParticipant(String cont, String participantJSON) {
        try {
            Participant__c participant = (Participant__c) JSON.deserialize(
                participantJSON,
                Participant__c.class
            );
            Contact contact = (Contact) JSON.deserialize(cont, Contact.class);
            if (
                participant.Mailing_Country_Code__c != null &&
                !participant.Mailing_Country_Code__c.equals('US')
            ) {
                contact.Participant_Opt_In_Status_SMS__c = false;
            }
            update contact;

            TaskService.getInstance().completeCYPTaskForParticipant();
            upsert participant;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void updateContact(String cont) {
        try {
            Contact contact = (Contact) JSON.deserialize(cont, Contact.class);
            if (!contact.MailingCountryCode.equals('US'))
                contact.Participant_Opt_In_Status_SMS__c = false;
            update contact;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }
    @AuraEnabled
    public static void updateAccount(String AccName) {
        try {
            Account acc = [SELECT id FROM account WHERE id = :getCurrentContact().AccountId];
            acc.Name = AccName;
            update acc;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void updatePersonMain(String wrapperJSON,String commPrefWrapperJSON, String userMode ) {
        updatePerson(wrapperJSON);
        //If loggied in user is Participant or Patient Delegate.
        if(userMode=='Participant'){
            //Pefrorm SMS opt out if mobilePhone is deleted from Patient Portal profile information.
            try {
                ConsentPreferenceData commWrapper = (ConsentPreferenceData) JSON.deserialize(
                    commPrefWrapperJSON,
                    ConsentPreferenceData.class
                );
                
                //Populte Account Setting switcher variables.
                isAdultParticipant = commWrapper.isAdultParticipant;
                isDelegateSelfView = commWrapper.isDelegateSelfView;
                isPrimaryDelegate = commWrapper.isPrimaryDelegate;
                isDelegateAlsoAParticipant = commWrapper.isDelegateAlsoAParticipant;
                isParticipantLoggedIn = commWrapper.isParticipantLoggedIn;
                isPrimaryDelegateWithMultiRole = commWrapper.isPrimaryDelegateWithMultiRole;

                //Check if mobilePhone is deleted
                Boolean isMobilePhoneDeleted = checkIfMobilePhoneIsdeleted(commWrapper.myContact.Id, commWrapper.loggedInUserParticipantId);
                //if Mobile Phone is not available
                if(!isMobilePhoneDeleted){ 
                  PreferenceManagementController.optOutSMSWhenMobileIsDeleted(commWrapper.perList, commWrapper.myContact.Id);
                }
            } catch (Exception e) {
                AuraHelper.throwException(e);
            }
        }
    }
    
     /**
    * @description: This Method will check if MobilePhone is deleted, if yes then process SMS opt out. 
    * @author: Krishna Mahto
    * @param: contId
    * @param: ParticipantId
    * @return: Boolean
    **/
    public static Boolean checkIfMobilePhoneIsdeleted(Id contId, Id ParticipantId){
        Contact contact = [select Id, 
                        MobilePhone 
                        from contact 
                        Where Id =:contId][0];
        
        Participant__c participant = [select Id,
                              Alternative_Phone_Type__c, 
                              Alternative_Phone_Number__c, 
                              Phone_Type__c,Phone__c 
                              from Participant__c 
                              Where Id =:ParticipantId][0];

        return checkMobilePhoneIsAvailable(contact, participant);      
    }

    @AuraEnabled
    public static void updatePerson(String wrapperJSON) {
        try {
            PersonWrapper wrapper = (PersonWrapper) JSON.deserialize(
                wrapperJSON,
                PersonWrapper.class
            );
            update wrapper.convertToContact();

            TaskService.getInstance().completeCYPTaskForParticipant();

            Participant__c participant = wrapper.convertToParticipant();
            if (participant != null)
                update participant;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void changeEmail(String newEmail, String userMode) {
        try {
            AccountSettingsController.AccountData initData = new AccountSettingsController.AccountData();
            initData.myContact = getCurrentContact();
            loggedInUserMode = userMode;
            if (
                loggedInUserMode != USER_MODE_HCP &&
                initData.myContact.userCommunityDelegateId__c != null
            ) {
                initData.myContact = ContactService.getContact(
                    initData.myContact.userCommunityDelegateId__c
                );
            }
            initData.myContact.Email = newEmail;
            update initData.myContact;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void changePassword(
        String newPassword,
        String verifyNewPassword,
        String oldPassword
    ) {
        PageReference pr;
        try {
            pr = Site.changePassword(newPassword, verifyNewPassword, oldPassword);
        } catch (Exception ex) {
            if (
                ex.getMessage().contains(System.Label.Pswd_Val_strng1) ||
                ex.getMessage().contains(System.Label.Pswd_Val_strng2)
            ) {
                throw new AuraHandledException(
                    System.Label.Pswd_ValidationMsg3_1 +
                    ' ' +
                    System.Label.Pswd_ValidationMsg3_2
                );
            }
            if (ex.getMessage().contains(System.Label.Passwords_Do_Not_Match)) {
                throw new AuraHandledException(System.Label.Pswd_ValidationMsg5);
            } else if (ex.getMessage().contains(System.Label.Password_Easy_to_Guess)) {
                throw new AuraHandledException(System.Label.Pswd_ValidationMsg7);
            } else if (ex.getMessage().contains(System.Label.Password_Cannot_Be_Null)) {
                throw new AuraHandledException(System.Label.Pswd_ValidationMsg8);
            } else {
                if (Site.getMasterLabel() == Label.IQVIA_Patient_Portal){
                    if ((ex.getMessage() == System.Label.Cannot_Reuse_Old_Password) && (oldPassword ==  newPassword)){
                    throw new AuraHandledException(System.Label.PP_NewPwdCantCurrentPwd);
                }
                    else if (ex.getMessage() == System.Label.Old_Password_Invalid ){
                    throw new AuraHandledException(System.Label.TST_Your_current_password_is_invalid);
                }
                     else if (ex.getMessage() == System.Label.Cannot_Reuse_Old_Password ){
                    throw new AuraHandledException(System.Label.PP_CannotReuseOldPwd);
                }
                    else {
                        throw new AuraHandledException(ex.getMessage() + '\n' + ex.getStackTraceString());
                    }
                    throw new AuraHandledException(ex.getMessage() + '\n' + ex.getStackTraceString());
                }
            }
        }
    }

    @AuraEnabled
    public static void changeOptInEmail(
        Boolean participantOptInStatusEmail,
        Boolean hcpOptInPatientEmail,
        Boolean hcpOptInStudyEmail,
        Boolean hcpOptInRefStatusEmail,
        String userMode
    ) {
        try {
            AccountSettingsController.AccountData initData = new AccountSettingsController.AccountData();
            initData.myContact = getCurrentContact();
            loggedInUserMode = userMode;
            if (
                loggedInUserMode != USER_MODE_HCP &&
                initData.myContact.userCommunityDelegateId__c != null
            ) {
                initData.myContact = ContactService.getContact(
                    initData.myContact.userCommunityDelegateId__c
                );
            }
            initData.myContact.Participant_Opt_In_Status_Emails__c = participantOptInStatusEmail;
            initData.myContact.HCP_Opt_In_Patient_Status_Emails__c = hcpOptInPatientEmail;
            initData.myContact.HCP_Opt_In_Study_Emails__c = hcpOptInStudyEmail;
            initData.myContact.HCP_Opt_In_Referral_Status_Emails__c = hcpOptInRefStatusEmail;
            update initData.myContact;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void changeOptInSMS(Boolean participantOptInStatusSMS, String userMode) {
        try {
            AccountSettingsController.AccountData initData = new AccountSettingsController.AccountData();
            initData.myContact = getCurrentContact();
            loggedInUserMode = userMode;
            if (
                loggedInUserMode != USER_MODE_HCP &&
                initData.myContact.userCommunityDelegateId__c != null
            ) {
                initData.myContact = ContactService.getContact(
                    initData.myContact.userCommunityDelegateId__c
                );
            }
            initData.myContact.Participant_Opt_In_Status_SMS__c = participantOptInStatusSMS;

            update initData.myContact;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void changeOptInCookies(Boolean rrCookieAllowed, Boolean rrLanguageAllowed) {
        try {
            Contact currentContact = getCurrentContact();
            currentContact.RRCookiesAllowedCookie__c = rrCookieAllowed;
            currentContact.RRLanguageAllowedCookie__c = rrLanguageAllowed;
            update currentContact;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @TestVisible
    private static Contact fillParticipantContact(Contact pContact) {
        List<Participant__c> pList = [
            SELECT
                First_Name__c,
                Middle_Name__c,
                Last_Name__c,
                Initials__c,
                Gender__c,
                Date_of_Birth__c,
            	Birth_Year__c,
            	Birth_Month__c,
            	Birth_Day__c,
            	Age__c,
            	Nickname__c,
                Suffix__c,
                Use_as_Daytime_Phone__c,
                Phone_Type__c,
                Alternative_Phone_Number__c,
                Alternative_Phone_Type__c
            FROM Participant__c
            WHERE Contact__c = :pContact.Id
        ];
        if (!pList.isEmpty()) {
            pContact.FirstName = pList[0].First_Name__c;
            pContact.LastName = pList[0].Last_Name__c;
        }
        return pContact;
    }

    public static Contact getCurrentContact() {
        return [
            SELECT
                Id,
                FirstName,
                MiddleName,
                LastName,
                AccountId,
                Email,
                Fax,
                Phone,
                MailingAddress,
                MailingCity,
                MailingCountry,
                MailingCountryCode,
                MailingPostalCode,
                MailingState,
                MailingStateCode,
                MailingStreet,
                MobilePhone,
                Suffix,
                primaryContact__c,
                primaryContact__r.AccountId,
                HasOptedOutOfEmail,
                Participant_Opt_In_Status_Emails__c,
                Participant_Opt_In_Status_SMS__c,
                Participant_Phone_Opt_In_Permit_Phone__c,
                IQVIA_Direct_Mail_Consent__c,
                HCP_Opt_In_Patient_Status_Emails__c,
                HCP_Opt_In_Study_Emails__c,
                HCP_Opt_In_Referral_Status_Emails__c,
                Delegate_Opt_In_Status_Emails__c,
                RRCookiesAllowedCookie__c,
                RRLanguageAllowedCookie__c,
                Salutation,
                userCommunityDelegateId__c,
                userCommunytyType__c,
                Phone_Type__c,
                IQVIA_Contact_info_storage_consent__c,
                Is_First_Logon__c,
                Cookies_Agreed_on_Reg__c
            FROM Contact
            WHERE Id IN (SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId())
            LIMIT 1
        ];
    }

    @AuraEnabled
    public static void createCase(String description, String type) {
        Savepoint sp = Database.setSavepoint();
        List<AssignmentRule> ars = getCaseAssignmentRule();

        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        if (!ars.isEmpty())
            dmlOptions.assignmentRuleHeader.AssignmentRuleId = ars[0].Id;

        Case newCase = new Case();
        newCase.Status = 'New';
        newCase.Origin = 'Web';
        newCase.Description = description;
        newCase.Type = type;
        newCase.ContactId = getCurrentContact().Id;
        newCase.setOptions(dmlOptions);

        try {
            insert newCase;
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    private static List<AssignmentRule> getCaseAssignmentRule() {
        return [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = TRUE LIMIT 1];
    }

    /*private static Account getInstituteByParticipantId(Id pId) {

List<Contact> contacts = [
SELECT (SELECT Id FROM Participants__r)
FROM Contact
WHERE Id = :pId
];
if (contacts.isEmpty()) return null;

List<Participant_Enrollment__c> hcpEnrolls = [
SELECT HCP__r.HCP_Contact__r.AccountId
FROM Participant_Enrollment__c
WHERE Participant__c = :contacts[0].Participants__r[0].Id
];
if (hcpEnrolls.isEmpty()) return null;

return getInstituteById(hcpEnrolls[0].HCP__r.HCP_Contact__r.AccountId);
}*/

    @TestVisible
    private static Account getInstituteById(Id accountId) {
        return [
            SELECT
                Id,
                Name,
                BillingStreet,
                BillingState,
                BillingCity,
                Phone,
                Fax,
                BillingPostalCode,
                BillingCountry
            FROM Account
            WHERE Id = :accountId
        ];
    }
    // get community name
    @AuraEnabled
    public static String getCommunityUrl() {
        return site.getMasterLabel();
    }

    @AuraEnabled
    public static void updateTheRegCookieAcceptance() {
        try {
            Contact con = getCurrentContact();
            if (con.Cookies_Agreed_on_Reg__c) {
                con.Cookies_Agreed_on_Reg__c = false;
            }
            update con;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static List<CookieSettings> getCookieSettings() {
        List<CookieSettings> cookieSettings = new List<CookieSettings>();
        cookieSettings.add(
            new CookieSettings(
                Label.AccountSettings_Cookie_Autocomplete,
                Label.AccountSettings_Cookie_Autocomplete_Description
            )
        );
        cookieSettings.add(
            new CookieSettings(
                Label.AccountSettings_Cookie_ClientSrc,
                Label.AccountSettings_Cookie_ClientSrc_Description
            )
        );
        cookieSettings.add(
            new CookieSettings(
                Label.AccountSettings_Cookie_force_proxy_stream,
                Label.AccountSettings_Cookie_force_proxy_stream_Description
            )
        );
        cookieSettings.add(
            new CookieSettings(
                Label.AccountSettings_Cookie_force_stream,
                Label.AccountSettings_Cookie_force_stream_Description
            )
        );
        cookieSettings.add(
            new CookieSettings(
                Label.AccountSettings_Cookie_RRetURL,
                Label.AccountSettings_Cookie_RRetURL_Description
            )
        );
        cookieSettings.add(
            new CookieSettings(
                Label.AccountSettings_Cookie_RSID,
                Label.AccountSettings_Cookie_RSID_Description
            )
        );
        cookieSettings.add(
            new CookieSettings(
                Label.AccountSettings_Cookie_sfdc_stream,
                Label.AccountSettings_Cookie_sfdc_stream_Description
            )
        );
        cookieSettings.add(
            new CookieSettings(
                Label.AccountSettings_Cookie_sid,
                Label.AccountSettings_Cookie_sid_Description
            )
        );
        cookieSettings.add(
            new CookieSettings(
                Label.AccountSettings_Cookie_sid_Client,
                Label.AccountSettings_Cookie_sid_Client_Description
            )
        );
        cookieSettings.add(
            new CookieSettings(
                Label.AccountSettings_Cookie_oid,
                Label.AccountSettings_Cookie_oid_Description
            )
        );
        cookieSettings.add(
            new CookieSettings(
                Label.AccountSettings_Cookie_x_apm_brtm_bt_p,
                Label.AccountSettings_Cookie_x_apm_brtm_bt_p_Description
            )
        );
        cookieSettings.add(
            new CookieSettings(
                Label.AccountSettings_Cookie_x_apm_brtm_bt_pv,
                Label.AccountSettings_Cookie_x_apm_brtm_bt_pv_Description
            )
        );

        return cookieSettings;
    }

    public class AccountData {
        @AuraEnabled
        public Contact myContact;
        @AuraEnabled
        public String userName;
        @AuraEnabled
        public Contact delegateContact;
        @AuraEnabled
        public User delegateUserName;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public String cookieDescription;
        @AuraEnabled
        public List<CookieSettings> cookieSettings;
        @AuraEnabled
        public Boolean isSMSAvailableFromSS = false;
        @AuraEnabled
        public Boolean hasProfilePic = false;
        @AuraEnabled
        public ContactSectionData contactSectionData = new ContactSectionData();
        @AuraEnabled
        public Participant__c participant;
        @AuraEnabled
        public ConsentPreferenceData consentPreferenceData = new ConsentPreferenceData();
        @AuraEnabled
        public ProgramOverViewData programOverViewData = new ProgramOverViewData();
        @AuraEnabled
        public ParticipantService.ParticipantState participantState;
        
    }

    public class ContactSectionData {
        @AuraEnabled
        public PersonWrapper personWrapper;
        @AuraEnabled
        public Account institute;
        @AuraEnabled
        public Boolean participantHasUpdateTasks;
        @AuraEnabled
        public List<LabelValueItem> gendersLVList = ParticipantService.getGenderLVList();
        @AuraEnabled
        public List<LabelValueItem> phoneTypeList = ParticipantService.getPhoneTypeLVList();
        @AuraEnabled
        public List<LabelValueItem> prefixList = ParticipantService.getPrefixList();
        @AuraEnabled
        public List<LabelValueItem> countriesLVList = CountryStateUtil.getCountries();
        @AuraEnabled
        public Map<String, List<LabelValueItem>> statesByCountryMap = CountryStateUtil.getStatesByCountryMap();
    }

    public class CookieSettings {
        public CookieSettings(String name, String description) {
            this.cookieName = name;
            this.cookieDescription = description;
        }

        @AuraEnabled
        public String cookieName { get; set; }
        @AuraEnabled
        public String cookieDescription { get; set; }
    }

    public class ConsentPreferenceData {
        @AuraEnabled
        public Contact myContact;
        @AuraEnabled
        public String studySiteYOBFormat;
        @AuraEnabled
        public Id loggedInUserParticipantId;
        @AuraEnabled
        public Participant__c currentParticipant;
        @AuraEnabled
        public List<Participant_Enrollment__c> perList = new List<Participant_Enrollment__c>();
        @AuraEnabled
        public List<Patient_Delegate_Enrollment__c> pdeList = new List<Patient_Delegate_Enrollment__c>();
        @AuraEnabled
        public Boolean isAdultParticipant;
        @AuraEnabled
        public Boolean isPrimaryDelegate = false;
        @AuraEnabled
        public Boolean isEmailAvailabelForParticipant;
        @AuraEnabled
        public Boolean isIQIVAOutrechToggleOnAtCTP;
        @AuraEnabled
        public Boolean isDelegateSelfView;
        @AuraEnabled
        public Boolean isParticipantLoggedIn = true;
        @AuraEnabled
        public Boolean isMobilePhoneNumberAvailable = false;
        @AuraEnabled
        public Boolean isSelfAccountSettingWarningMessage = false;
        @AuraEnabled
        public Boolean isDelegateAlsoAParticipant = false;
        @AuraEnabled
        public Boolean isPrimaryDelegateWithMultiRole = false;
        @AuraEnabled
        public Boolean isWithdrawnDelegate = false;
        @AuraEnabled
        public Boolean isActiveDelegate = false;
    }

    
    public class ProgramOverViewData {
        public Boolean isDelegateSelfView = false;
        @AuraEnabled
        public Boolean isAlumniParticipant = false;
        @AuraEnabled
        public String communityName;
    }
    
    public class PersonWrapper {
        @AuraEnabled
        public Id contactId;
        @AuraEnabled
        public Id participantId;
        @AuraEnabled
        public String firstName;
        @AuraEnabled
        public String middleName;
        @AuraEnabled
        public String lastName;
        @AuraEnabled
        public String dateBirth;
        @AuraEnabled
        public String gender;
        @AuraEnabled
        public String homePhone;
        @AuraEnabled
        public String mobilePhone;
        @AuraEnabled
        public Boolean useAsDaytimePhone;
        @AuraEnabled
        public String fax;
        @AuraEnabled
        public Boolean optInEmail;
        @AuraEnabled
        public Boolean optInSMS;
        @AuraEnabled
        public String mailingCC;
        @AuraEnabled
        public String mailingSC;
        @AuraEnabled
        public String mailingCountry;
        @AuraEnabled
        public String mailingStreet;
        @AuraEnabled
        public String mailingCity;
        @AuraEnabled
        public String mailingState;
        @AuraEnabled
        public String zip;
        @AuraEnabled
        public String suffix;
        @AuraEnabled
        public String nickname;
        @AuraEnabled
        public String phoneType;
        @AuraEnabled
        public String prefix;

        @AuraEnabled
        public Boolean isParticipant;
        @AuraEnabled
        public Boolean showBirthDate;
        @AuraEnabled
        public String birthYear;
        @AuraEnabled
        public String birthDay;
        @AuraEnabled
        public String birthMonth;
        @AuraEnabled
        public Decimal age;
        @AuraEnabled
        public Boolean isAdultPar;



        public PersonWrapper(Contact contact, Participant__c participant) {
            contactId = contact.Id;
            isParticipant = participant != null;
            if (isParticipant)
                participantId = participant.Id;

            firstName = isParticipant ? participant.First_Name__c : contact.FirstName;
            middleName = isParticipant ? participant.Middle_Name__c : contact.MiddleName;
            lastName = isParticipant ? participant.Last_Name__c : contact.LastName;
            homePhone = isParticipant ? participant.Phone__c : contact.Phone;
            //mobilePhone = (contact.Phone_Type__c == 'Mobile' || (isParticipant ? participant.Phone_Type__c == 'Mobile':false)) ? homePhone : contact.MobilePhone;
            // mobilePhone = contact.MobilePhone;
            mobilePhone = isParticipant &&
                participant.Alternative_Phone_Type__c == 'Mobile' &&
                participant.Alternative_Phone_Number__c != null
                ? participant.Alternative_Phone_Number__c
                : isParticipant &&
                      participant.Alternative_Phone_Number__c == null &&
                      participant.Phone_Type__c == 'Mobile'
                      ? participant.Phone__c
                      : isParticipant &&
                            participant.Alternative_Phone_Type__c != 'Mobile' &&
                            participant.Phone_Type__c != 'Mobile'
                            ? ''
                            : contact.MobilePhone;

            useAsDaytimePhone = isParticipant ? participant.Use_as_Daytime_Phone__c : false;

            fax = contact.Fax;
            optInEmail = contact.Participant_Opt_In_Status_Emails__c;
            optInSMS = contact.Participant_Opt_In_Status_SMS__c;
            mailingCC = isParticipant
                ? participant.Mailing_Country_Code__c
                : contact.MailingCountryCode;
            mailingSC = isParticipant
                ? participant.Mailing_State_Code__c
                : contact.MailingStateCode;
            mailingCountry = contact.MailingCountry;
            suffix = contact.suffix;
            mailingStreet = contact.MailingStreet;
            mailingCity = contact.MailingCity;
            mailingState = contact.MailingState;
            zip = isParticipant
                ? participant.Mailing_Zip_Postal_Code__c
                : contact.MailingPostalCode;
            prefix = isParticipant ? participant.Salutation__c : contact.Salutation;
            phoneType = isParticipant ? participant.Phone_Type__c : contact.Phone_Type__c;

            if (isParticipant) {
                dateBirth = participant.Date_of_Birth__c;
                gender = participant.Gender__c;
                suffix = participant.Suffix__c;
                nickname = participant.Nickname__c;
                age = participant.Age__c;
                birthYear = participant.Birth_Year__c != null ? participant.Birth_Year__c : null; 
                birthMonth = participant.Birth_Month__c != null ? participant.Birth_Month__c : null;
                birthDay = participant.Birth_Day__c != null ? participant.Birth_Day__c : null;
                isAdultPar = participant.Adult__c;

                List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
                peList = [
                    SELECT Id
                    FROM Participant_Enrollment__c
                    WHERE Participant__c = :participant.Id
                ];
                if (peList.size() > 0) {
                    showBirthDate = true;
                } else { 
                    showBirthDate = false;
                }
            }
        }

        public Contact convertToContact() {
            Contact personContact = new Contact(Id = contactId);
            personContact.MobilePhone = mobilePhone;
            
            if (isParticipant)
                return personContact;               

            personContact.FirstName = firstName;
            personContact.MiddleName = MiddleName;
            personContact.LastName = lastName;
            personContact.Phone = homePhone;
            personContact.Fax = fax;
            personContact.MailingCountryCode = mailingCC;
            personContact.MailingStateCode = mailingSC;
            personContact.MailingCountry = mailingCountry;
            personContact.MailingStreet = mailingStreet;
            personContact.MailingCity = mailingCity;
            personContact.suffix = suffix;
            personContact.MailingState = mailingState;
            personContact.MailingPostalCode = zip;
            personContact.Salutation = prefix;
            personContact.Phone_Type__c = phoneType;
            return personContact;
        }

        public Participant__c convertToParticipant() {
            if (!isParticipant)
                return null;

            Participant__c personParticipant = new Participant__c(Id = participantId);
            personParticipant.First_Name__c = firstName;
            personParticipant.Middle_Name__c = middleName;
            personParticipant.Last_Name__c = lastName;
            personParticipant.Phone__c = homePhone;
            personParticipant.Mailing_Country_Code__c = mailingCC;
            personParticipant.Mailing_State_Code__c = mailingSC;
            personParticipant.Alternative_Phone_Number__c = mobilePhone;
            if (mobilePhone != null) {
                personParticipant.Alternative_Phone_Type__c = 'Mobile';
            }

            personParticipant.Date_of_Birth__c = dateBirth;
            personParticipant.Birth_Year__c = birthYear;
            personParticipant.Birth_Month__c = birthMonth;
            personParticipant.Birth_Day__c = birthDay;
            personParticipant.Age__c = age;
            personParticipant.Adult__c = isAdultPar;

            personParticipant.Gender__c = gender;
            personParticipant.Mailing_Zip_Postal_Code__c = zip;
            personParticipant.Suffix__c = suffix;
            personParticipant.Salutation__c = prefix;
            personParticipant.Nickname__c = nickname;
            personParticipant.Phone_Type__c = phoneType;
            personParticipant.Use_as_Daytime_Phone__c = useAsDaytimePhone;

            return personParticipant;
        }

        public Boolean isOptInSMS() {
            if (mailingCC == null || !mailingCC.equals('US'))
                return false;

            return true;
        }
    }

    /**
     * @description: This Method will return most restrictive study site DOB format.
     * @author: Anitha Chavva
     * @param: perList
     * @return:
     **/
    public static String leastYOBFormat(List<Participant_Enrollment__c> participantEnrollments){
        Set<String> participantSiteFormat = new Set<String>();
        Map<Integer,String> studySiteLenghtVsFormatMap = New Map<Integer,String>();
        Integer minStudySiteFormateLen = 0;
        String leastYOBFormat;
        if(participantEnrollments != null && participantEnrollments.size()>0){
            for(Participant_Enrollment__c per : participantEnrollments){
                participantSiteFormat.add(per.Study_Site__r.Participant_DOB_format__c);
            }
            if(!participantSiteFormat.isEmpty()){
                    List<String> yobStudySiteFormats = new List<String>(participantSiteFormat);    
                    if(yobStudySiteFormats.size() > 1){
                        for(String studySiteFormat : yobStudySiteFormats){
                            //get the lenght of each YOB formate
                            Integer siteFormatSize = studySiteFormat.length();
                            studySiteLenghtVsFormatMap.put(siteFormatSize,studySiteFormat);
                        }
                        //Define first element of Map as minimun.
                        minStudySiteFormateLen = yobStudySiteFormats[0].length();//studySiteLenghtVsFormatMap.keySet()[0]; // 10
                        for(Integer len: studySiteLenghtVsFormatMap.keySet()){
                            if(len< minStudySiteFormateLen){  
                                minStudySiteFormateLen = len;
                            }
                        }
                    }
                    else{
                        List<String> participantStudySiteFormat = new List<String>(participantSiteFormat);
                        Integer siteFormatSize = participantStudySiteFormat[0].length();
                        studySiteLenghtVsFormatMap.put(siteFormatSize,participantStudySiteFormat[0]);
                        minStudySiteFormateLen = siteFormatSize;
                    }
            }
            leastYOBFormat = studySiteLenghtVsFormatMap.isEmpty()?null:studySiteLenghtVsFormatMap.get(minStudySiteFormateLen);

        }
        return leastYOBFormat;
    }
    /**
     * @description: This Method will set the consent Preference data to the static variables.
     * @author: Krishna Mahto
     * @param: perList
     * @return:
     **/
    public static Void prepareCommunicationPreferenceData(
        List<Participant_Enrollment__c> participantEnrollments,
        AccountSettingsController.AccountData initData
    ) {
        // Populate Consent Preference Data to Static variables
        setConsentPreferenceData(
            participantEnrollments,
            initData.participant.Id,
            initData.myContact.Id
        );

        //Set the consent Preference data to wrapper variables.
        initData.consentPreferenceData.isAdultParticipant = isAdultParticipant;
        initData.consentPreferenceData.isEmailAvailabelForParticipant = isEmailAvailabelForParticipant;
        initData.consentPreferenceData.isDelegateSelfView = isDelegateSelfView;
        initData.consentPreferenceData.isIQIVAOutrechToggleOnAtCTP = isIQIVAOutrechToggleOnAtCTP;
        initData.consentPreferenceData.myContact = initData.myContact;
        initData.consentPreferenceData.loggedInUserParticipantId = initData.participant.Id;
        initData.consentPreferenceData.isActiveDelegate = PatientDelegateEnrollmentService.isActiveDelegate(initData.myContact.Id);

        if (isDelegateSelfView) {
            //Get patient Delegate Enrollment Records for the delegate.
            initData.consentPreferenceData.pdeList = PatientDelegateEnrollmentService.getPDEnrollmentforDelContact(initData.myContact.Id);
            //As Patient delegate switched to his own Account setting so set isParticipantLoggedIn to false.
            //But if patient Delegate is also acting as Participant then set  isParticipantLoggedIn to true and make Primary delegate to false and isDelegateSelfView to false.
            if (isDelegateAlsoAParticipant) {
                if(isPrimaryDelegate){
                    initData.consentPreferenceData.isPrimaryDelegateWithMultiRole = true;
                }
                initData.consentPreferenceData.isParticipantLoggedIn = true;
                initData.consentPreferenceData.isPrimaryDelegate = false;
                initData.consentPreferenceData.isDelegateSelfView = false;
                initData.consentPreferenceData.isDelegateAlsoAParticipant = true; 
                if (perListforCommPref != null) {
                    initData.consentPreferenceData.perList.addAll(perListforCommPref);
                }
            } else {
                //Pure Delegate Self View. 
                initData.consentPreferenceData.isParticipantLoggedIn = false;
                initData.consentPreferenceData.isPrimaryDelegate = isPrimaryDelegate;
                initData.consentPreferenceData.studySiteYOBFormat = 'YYYY';
            }
        } else {
            //Participant Logged In or Delegate switched to participant View.
            initData.consentPreferenceData.perList.addAll(participantEnrollments);
        }

        if(initData.consentPreferenceData.perList != null && initData.consentPreferenceData.perList.size()>0){
            initData.consentPreferenceData.studySiteYOBFormat = leastYOBFormat(initData.consentPreferenceData.perList);
        } 
        Boolean isParticipantLoggedInTemp = initData.consentPreferenceData.isParticipantLoggedIn;
        Boolean isDelegateSelfViewTemp = initData.consentPreferenceData.isDelegateSelfView;
        Participant__c currentParticipantTemp = new Participant__c();
        Contact currentContactTemp = new Contact();
        if (isParticipantLoggedInTemp || isDelegateSelfViewTemp) {
            //If Participant logged to his own accound setting or Delegate logged in to his Self Account setting.
            currentParticipantTemp = initData.participant;
            currentContactTemp = initData.myContact;
            initData.consentPreferenceData.isSelfAccountSettingWarningMessage = true;
        } else if (!isParticipantLoggedInTemp && !isDelegateSelfViewTemp) {
            //If Delegate switch to participant account setting
            if (!isAdultParticipant || (isAdultParticipant && !isEmailAvailabelForParticipant)) {
                //If Participant is Minor or adult without email, make current Participant to Delegate Participant record.
                currentParticipantTemp = delegateParticipant;
                currentContactTemp = delegateContact;
                initData.consentPreferenceData.isSelfAccountSettingWarningMessage = false;
            } else if (isAdultParticipant && isEmailAvailabelForParticipant) {
                //If Participant is adult with email, make current Participant to actual Participant record.
                currentParticipantTemp = initData.participant;
                currentContactTemp = initData.myContact;
                initData.consentPreferenceData.isSelfAccountSettingWarningMessage = true;
            }
        }
        if (currentParticipantTemp != null) {
            initData.consentPreferenceData.currentParticipant = currentParticipantTemp;
            /*if(currentParticipantTemp.Alternative_Phone_Type__c=='Mobile' && 
               !String.isEmpty(currentParticipantTemp.Alternative_Phone_Number__c)){
            	initData.consentPreferenceData.isMobilePhoneNumberAvailable =true;
        	}
			*/
            initData.consentPreferenceData.isMobilePhoneNumberAvailable = checkMobilePhoneIsAvailable(
                currentContactTemp,
                currentParticipantTemp
            );
        }
    }

    /**
     * @description: This Method will set the consent Preference data to the static variables.
     * @author: Krishna Mahto
     * @param: perList
     * @return:
     **/
    public static Void setConsentPreferenceData(
        List<Participant_Enrollment__c> perList,
        Id initDataParticipantId,
        Id initDataMyContactId
    ) {
        for (Participant_Enrollment__c per : perList) {
            //Populate the Map of list of PER for each Participant Id.
            if (participantIdListOfPerMap.containsKey(per.Participant__c)) {
                List<Participant_Enrollment__c> perTemp = participantIdListOfPerMap.get(
                    per.Participant__c
                );
                perTemp.Add(per);
                participantIdListOfPerMap.put(per.Participant__c, perTemp);
            } else {
                List<Participant_Enrollment__c> perTemp = new List<Participant_Enrollment__c>();
                perTemp.Add(per);
                participantIdListOfPerMap.put(per.Participant__c, perTemp);
            }
        }
        //Check if Participant is adult
        for (Participant_Enrollment__c per : perList) {
            if (per.Participant__r.Adult__c) {
                isAdultParticipant = true;
            }
            //Check if email is available at Participant
            if (per.Participant__r.Email__c != null) {
                isEmailAvailabelForParticipant = true;
            }
            //Check if Delegate is on self View
            if (initDataParticipantId != per.Participant__c) {
                isDelegateSelfView = true;
                checkIfDelAlsoAParticipant = true;
                currentParticipantId = per.Participant__c;
            }
            //Check if IQVIA outreach toggle is on at any of the CTP for the Participant.
            if (per.Clinical_Trial_Profile__r.IQVIA_Outreach__c) {
                isIQIVAOutrechToggleOnAtCTP = true;
            }
        }
        //This logic is not required as part of Delegate redesing changes, as delegate will be Primary/Secondary for study specific.
        //If Patient Delegate clicks the self Account setting, check if the Patient delegate is Primary delegate or not.
        // if (isDelegateSelfView) {
        //     isPrimaryDelegate = PatientDelegateService.isPrimaryDelegate(
        //         initDataMyContactId,
        //         currentParticipantId
        //     );
        // }
        //Check if Delegate is also acting as participant for other study(Multi Role).
        if (checkIfDelAlsoAParticipant) {
            checkIfDelegateIsAlsoAparticipant(initDataMyContactId);
            //If Delegate is also acting as Participant then only Pass the PER for Delegate contact when switching at self view.
            if (isDelegateAlsoAParticipant) {
                perListforCommPref = participantIdListOfPerMap.get(initDataParticipantId);
            }
        }
    }
    /**
     * @description: This Method will check if Patient Delegate is also working as Participant.
     * @author: Krishna Mahto
     * @param: delContId
     * @return:
     **/
    public static void checkIfDelegateIsAlsoAparticipant(Id delContId) {
        list<Participant_Enrollment__c> perList = [
            SELECT Id
            FROM Participant_Enrollment__c
            WHERE Participant_Contact__c = :delContId
        ];
        if (perList != null && !perList.isEmpty()) {
            isDelegateAlsoAParticipant = true;
        }
    }

    /**
     * @description: This Method return the Participant record from contact Id.
     * @author: Krishna Mahto
     * @param: ContId
     * @return:
     **/
    public static Participant__c getParticipantRecord(Id contId) {
        return [
            SELECT
                Id,
                First_Name__c,
                Middle_Name__c,
                Last_Name__c,
                Phone__c,
                Mailing_Zip_Postal_Code__c,
                Mailing_State__c,
                Mailing_Country__c,
                Mailing_Country_Code__c,
                Mailing_State_Code__c,
                Adult__c,
                Gender__c,
                Date_of_Birth__c,
            	Birth_Year__c,
                Birth_Month__c,
                Birth_Day__c,
                Age__c,
                Initials__c,
                Suffix__c,
                Salutation__c,
                Nickname__c,
                Phone_Type__c,
                Alternative_Phone_Number__c,
                Alternative_Phone_Type__c,
                Email__c,
                Contact__c,
                Use_as_Daytime_Phone__c
            FROM Participant__c
            WHERE Contact__c = :contId
        ][0];
    }
    /**
     * @description: This Method return check if mobile phone is available for participant is not.
     * @author: Krishna Mahto
     * @param: contact
     * @param: participant
     * @return:
     **/
    public static Boolean checkMobilePhoneIsAvailable(Contact contact, Participant__c participant) {
        Boolean isParticipant = participant != null;
        String mobilePhone = '';
        if (isParticipant) {
            mobilePhone = isParticipant &&
                participant.Alternative_Phone_Type__c == 'Mobile' &&
                participant.Alternative_Phone_Number__c != null
                ? participant.Alternative_Phone_Number__c
                : isParticipant &&
                      participant.Alternative_Phone_Number__c == null &&
                      participant.Phone_Type__c == 'Mobile'
                      ? participant.Phone__c
                      : isParticipant &&
                            participant.Alternative_Phone_Type__c != 'Mobile' &&
                            participant.Phone_Type__c != 'Mobile'
                            ? ''
                            : contact.MobilePhone;
        }

        if (mobilePhone != null && mobilePhone != '') {
            return true;
        } else {
            return false;
        }
    }
    /**
     * @description: This Method return the Participant Enrollment record from contact Id.
     * @author: Krishna Mahto
     * @param: peIds
     * @return:
     **/
    public static list<Participant_Enrollment__c> getPERRecords(List<Id> peIds) {
        return [
            SELECT
                Id,
                Participant__c,
                Participant_Contact__c,
            	Participant__r.Birth_Year__c,
            	Participant__r.Birth_Month__c,
                Participant__r.Birth_Day__c,
            	Participant__r.Age__c,
                Participant__r.Contact__c,
                Participant__r.Adult__c, 
                Participant__r.Email__c, 
                Study_Site__r.SMS_Are_Available__c,
                Permit_Mail_Email_contact_for_this_study__c,
                Permit_SMS_Text_for_this_study__c,
                Permit_Voice_Text_contact_for_this_study__c,
                Study_Direct_Mail_Consent__c,
                Clinical_Trial_Profile__r.IQVIA_Outreach__c,
                Clinical_Trial_Profile__c,
                Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
            	Study_Site__r.Participant_DOB_format__c
            FROM Participant_Enrollment__c
            WHERE Id = :peIds
        ];
    }
}