/**
* Created by D.Yasinskyi on 07.05.2018
*/
public without sharing class AccountSettingsController {
    
    @AuraEnabled
    public static String getInitData(String userMode) {
        try {
            AccountSettingsController.AccountData initData = new AccountSettingsController.AccountData();
            initData.myContact = getCurrentContact();
            if(initData.myContact.userCommunityDelegateId__c != null){
                initData.myContact = ContactService.getContact(initData.myContact.userCommunityDelegateId__c);
            }
            system.debug('userContact-->'+initData.myContact);

            ContactService.applyRelevantNames(initData.myContact);
            initData.cookieSettings = getCookieSettings();
            initData.cookieDescription = Label.AccountSettings_Cookie_Description;
            
            if (initData.myContact.primaryContact__c == null) {
                if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
                        initData.participant = [
                            SELECT Id, First_Name__c, Middle_Name__c, Last_Name__c, Phone__c,
                            Mailing_Zip_Postal_Code__c, Mailing_State__c, Mailing_Country__c,
                            Mailing_Country_Code__c, Mailing_State_Code__c,Adult__c,
                            Gender__c, Date_of_Birth__c, Initials__c,Suffix__c,Salutation__c,Nickname__c,Phone_Type__c
                            FROM Participant__c
                            WHERE Contact__c = :initData.myContact.Id
                        ][0];
                        //translate country:
                        initData.participant.Mailing_Country__c =
                            CountryStateUtil.getCountryName(initData.participant.Mailing_Country_Code__c);
                        
                        //translate state
                        initData.participant.Mailing_State__c = CountryStateUtil.getStateName(
                            initData.participant.Mailing_Country_Code__c,
                            initData.participant.Mailing_State_Code__c
                        );
                        
                        //Task for updating profile exists Account
                        List<Task> tasks = TaskService.getInstance().getTasksCommon('Status = \'Open\' AND Task_Code__c = \'Complete_Your_Profile\'');
                        initData.contactSectionData.participantHasUpdateTasks = !tasks.isEmpty();
                    
                    initData.cookieDescription = Label.PP_Account_Settings_Cookie_Description;
                    String communityName = TranslateHelper.getLabelValue(UserContext.getTemplateProperty('CommunityWelcome'));
                    initData.cookieDescription = initData.cookieDescription.replace('##CommunityWelcome', communityName);
                    ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
                    List<Participant_Enrollment__c> participantEnrollments = new List<Participant_Enrollment__c>();
                    List<Id> peIds = new List<Id>();
                    peIds = PatientDelegateService.getAvailablePEIdsForContact(participantState.participant.Contact__c);
                    List<Participant_Enrollment__c> availablePEs = [SELECT Id, Study_Site__r.SMS_Are_Available__c FROM Participant_Enrollment__c WHERE Id =: peIds];
                    if (availablePEs != null) participantEnrollments.addAll(availablePEs);
                    List<Participant_Enrollment__c> pastEnrollments =
                        ContactService.getPastEnrollments(participantState.participant.Contact__c);
                    if(pastEnrollments != null) participantEnrollments.addAll(pastEnrollments);
                    for (Participant_Enrollment__c p: participantEnrollments) {
                        if (p.Study_Site__r.SMS_Are_Available__c) {
                            initData.isSMSAvailableFromSS = true;
                            break;
                        }
                    }
                    
                } else {
                    initData.contactSectionData.institute = getInstituteById(initData.myContact.AccountId);
                }
            } else {
                initData.contactSectionData.institute = getInstituteById(initData.myContact.primaryContact__r.AccountId);
            }
            
            initData.contactSectionData.personWrapper = new PersonWrapper(initData.myContact, initData.participant);
            if(initData.participant.Adult__c || (userMode == 'PI' || userMode == 'HCP')){
            initData.userName = UserInfo.getUserName();
            User uval = [Select Id,ContactId from User where Id =: UserInfo.getUserId()];
            initData.delegateContact = [Select Id From Contact where Id =: uval.ContactId];
            initData.delegateUserName = [Select Id,Email,Name,Username ,FullPhotoUrl from User where ContactId =: initData.myContact.Id LIMIT 1];
            initData.hasProfilePic = !initData.delegateUserName.FullPhotoUrl.contains('profilephoto/005/F');
            }
           return JSON.serialize(initData, false);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }
    
    @AuraEnabled
    public static void updateParticipant(String cont, String participantJSON) {
        try {
            Participant__c participant = (Participant__c) JSON.deserialize(participantJSON, Participant__c.class);
            Contact contact = (Contact) JSON.deserialize(cont, Contact.class);
            if (participant.Mailing_Country_Code__c != null && !participant.Mailing_Country_Code__c.equals('US')) {
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
            if (!contact.MailingCountryCode.equals('US')) contact.Participant_Opt_In_Status_SMS__c = false;
            update contact;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }
     @AuraEnabled
    public static void updateAccount(String AccName) {
        try {
            Account acc = [select id from account where id=: getCurrentContact().AccountId];
            acc.Name = AccName;
            update acc;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }
    
    @AuraEnabled
    public static void updatePerson(String wrapperJSON) {
        try {
            PersonWrapper wrapper = (PersonWrapper) JSON.deserialize(wrapperJSON, PersonWrapper.class);
            update wrapper.convertToContact();
            
            TaskService.getInstance().completeCYPTaskForParticipant();
            
            Participant__c participant = wrapper.convertToParticipant();
            if (participant != null) update participant;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }
    
   @AuraEnabled
    public static void changeEmail(String newEmail) {
        try {
            AccountSettingsController.AccountData initData = new AccountSettingsController.AccountData();
            initData.myContact = getCurrentContact();
            if(initData.myContact.userCommunityDelegateId__c != null){
                initData.myContact = ContactService.getContact(initData.myContact.userCommunityDelegateId__c);
            }
            initData.myContact.Email = newEmail;
            update initData.myContact;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static void changePassword(String newPassword, String verifyNewPassword, String oldPassword) {
        PageReference pr;
        try {
            pr = Site.changePassword(newPassword, verifyNewPassword, oldPassword);
           
        } catch (Exception ex) {
            if(ex.getMessage().contains(System.Label.Pswd_Val_strng1) || ex.getMessage().contains(System.Label.Pswd_Val_strng2))
            {
                throw new AuraHandledException(System.Label.Pswd_ValidationMsg3_1 + ' '+ System.Label.Pswd_ValidationMsg3_2);
            }else{
                throw new AuraHandledException(ex.getMessage() + '\n' + ex.getStackTraceString());
            }            
        }
    }
    
    @AuraEnabled
    public static void changeOptInEmail(Boolean participantOptInStatusEmail, Boolean hcpOptInPatientEmail, Boolean hcpOptInStudyEmail, Boolean hcpOptInRefStatusEmail) {
        try {
            AccountSettingsController.AccountData initData = new AccountSettingsController.AccountData();
                        initData.myContact = getCurrentContact();
            if(initData.myContact.userCommunityDelegateId__c != null){
                initData.myContact = ContactService.getContact(initData.myContact.userCommunityDelegateId__c);
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
    public static void changeOptInSMS(Boolean participantOptInStatusSMS) {
        try {
            AccountSettingsController.AccountData initData = new AccountSettingsController.AccountData();
            initData.myContact = getCurrentContact();
            if(initData.myContact.userCommunityDelegateId__c != null){
                initData.myContact = ContactService.getContact(initData.myContact.userCommunityDelegateId__c);
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
            SELECT First_Name__c,
            Middle_Name__c,
            Last_Name__c,
            Initials__c,
            Gender__c,
            Date_of_Birth__c,
            Nickname__c,
            Suffix__c,
            Phone_Type__c  
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
            SELECT Id,
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
            HCP_Opt_In_Patient_Status_Emails__c,
            HCP_Opt_In_Study_Emails__c,
            HCP_Opt_In_Referral_Status_Emails__c,
            Delegate_Opt_In_Status_Emails__c,
            RRCookiesAllowedCookie__c,
            RRLanguageAllowedCookie__c,
            Salutation,
            userCommunityDelegateId__c,
			userCommunytyType__c,
            Phone_Type__c
            FROM Contact
            WHERE Id IN (
                SELECT ContactId
                FROM User
                WHERE Id = :UserInfo.getUserId()
            )
            LIMIT 1
        ];
    }
    
    @AuraEnabled
    public static void createCase(String description, String type) {
        Savepoint sp = Database.setSavepoint();
        List<AssignmentRule> ars = getCaseAssignmentRule();
        
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        if (!ars.isEmpty()) dmlOptions.assignmentRuleHeader.AssignmentRuleId = ars[0].Id;
        
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
        
        return [
            SELECT Id
            FROM AssignmentRule
            WHERE SobjectType = 'Case'
            AND Active = TRUE
            LIMIT 1
        ];
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
            SELECT Id
            , Name
            , BillingStreet
            , BillingState
            , BillingCity
            , Phone
            , Fax
            , BillingPostalCode
            , BillingCountry
            FROM Account
            WHERE Id = :accountId
        ];
    }
    
    public static List<CookieSettings> getCookieSettings() {
        List<CookieSettings> cookieSettings = new List<CookieSettings>();
        cookieSettings.add(new CookieSettings(Label.AccountSettings_Cookie_Autocomplete, Label.AccountSettings_Cookie_Autocomplete_Description));
        cookieSettings.add(new CookieSettings(Label.AccountSettings_Cookie_ClientSrc, Label.AccountSettings_Cookie_ClientSrc_Description));
        cookieSettings.add(new CookieSettings(Label.AccountSettings_Cookie_force_proxy_stream, Label.AccountSettings_Cookie_force_proxy_stream_Description));
        cookieSettings.add(new CookieSettings(Label.AccountSettings_Cookie_force_stream, Label.AccountSettings_Cookie_force_stream_Description));
        cookieSettings.add(new CookieSettings(Label.AccountSettings_Cookie_RRetURL, Label.AccountSettings_Cookie_RRetURL_Description));
        cookieSettings.add(new CookieSettings(Label.AccountSettings_Cookie_RSID, Label.AccountSettings_Cookie_RSID_Description));
        cookieSettings.add(new CookieSettings(Label.AccountSettings_Cookie_sfdc_stream, Label.AccountSettings_Cookie_sfdc_stream_Description));
        cookieSettings.add(new CookieSettings(Label.AccountSettings_Cookie_sid, Label.AccountSettings_Cookie_sid_Description));
        cookieSettings.add(new CookieSettings(Label.AccountSettings_Cookie_sid_Client, Label.AccountSettings_Cookie_sid_Client_Description));
        cookieSettings.add(new CookieSettings(Label.AccountSettings_Cookie_oid, Label.AccountSettings_Cookie_oid_Description));
        cookieSettings.add(new CookieSettings(Label.AccountSettings_Cookie_x_apm_brtm_bt_p, Label.AccountSettings_Cookie_x_apm_brtm_bt_p_Description));
        cookieSettings.add(new CookieSettings(Label.AccountSettings_Cookie_x_apm_brtm_bt_pv, Label.AccountSettings_Cookie_x_apm_brtm_bt_pv_Description));
        
        return cookieSettings;
    }
    
    public class AccountData {
        @AuraEnabled public Contact myContact;
        @AuraEnabled public String userName;
        @AuraEnabled public Contact delegateContact;
        @AuraEnabled public User delegateUserName;
        @AuraEnabled public String message;
        @AuraEnabled public String cookieDescription;
        @AuraEnabled public List<CookieSettings> cookieSettings;
        @AuraEnabled public Boolean isSMSAvailableFromSS = false;
        @AuraEnabled public Boolean hasProfilePic = false;
        @AuraEnabled public ContactSectionData contactSectionData = new ContactSectionData();
        @AuraEnabled public Participant__c participant;
    }
    
    public class ContactSectionData {
        @AuraEnabled public PersonWrapper personWrapper;
        @AuraEnabled public Account institute;
        @AuraEnabled public Boolean participantHasUpdateTasks;
        @AuraEnabled public List<LabelValueItem> gendersLVList = ParticipantService.getGenderLVList();
        @AuraEnabled public List<LabelValueItem> phoneTypeList = ParticipantService.getPhoneTypeLVList();
        @AuraEnabled public List<LabelValueItem> prefixList = ParticipantService.getPrefixList();
        @AuraEnabled public List<LabelValueItem> countriesLVList = CountryStateUtil.getCountries();
        @AuraEnabled public Map<String, List<LabelValueItem>> statesByCountryMap = CountryStateUtil.getStatesByCountryMap();
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
    
    public class PersonWrapper {
        @AuraEnabled public Id contactId;
        @AuraEnabled public Id participantId;
        @AuraEnabled public String firstName;
        @AuraEnabled public String middleName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String dateBirth;
        @AuraEnabled public String gender;
        @AuraEnabled public String homePhone;
        @AuraEnabled public String mobilePhone;
        @AuraEnabled public String fax;
        @AuraEnabled public Boolean optInEmail;
        @AuraEnabled public Boolean optInSMS;
        @AuraEnabled public String mailingCC;
        @AuraEnabled public String mailingSC;
        @AuraEnabled public String mailingCountry;
        @AuraEnabled public String mailingStreet;
        @AuraEnabled public String mailingCity;
        @AuraEnabled public String mailingState;
        @AuraEnabled public String zip;
        @AuraEnabled public String suffix;
        @AuraEnabled public String nickname;
        @AuraEnabled public String phoneType;
        @AuraEnabled public String prefix;
        
        @AuraEnabled public Boolean isParticipant;
        
        public PersonWrapper(Contact contact, Participant__c participant) {
            contactId = contact.Id;
            isParticipant = participant != null;
            if (isParticipant) participantId = participant.Id;
            
            firstName = isParticipant ? participant.First_Name__c : contact.FirstName;
			middleName = isParticipant ? participant.Middle_Name__c : contact.MiddleName;
            lastName = isParticipant ? participant.Last_Name__c : contact.LastName;
            homePhone = isParticipant ? participant.Phone__c : contact.Phone;
           //mobilePhone = (contact.Phone_Type__c == 'Mobile' || (isParticipant ? participant.Phone_Type__c == 'Mobile':false)) ? homePhone : contact.MobilePhone;
            mobilePhone = contact.MobilePhone;
            fax = contact.Fax;
            optInEmail = contact.Participant_Opt_In_Status_Emails__c;
            optInSMS = contact.Participant_Opt_In_Status_SMS__c;
            mailingCC = isParticipant ? participant.Mailing_Country_Code__c : contact.MailingCountryCode;
            mailingSC = isParticipant ? participant.Mailing_State_Code__c : contact.MailingStateCode;
            mailingCountry = contact.MailingCountry;
            suffix = contact.suffix;
            mailingStreet = contact.MailingStreet;
            mailingCity = contact.MailingCity;
            mailingState = contact.MailingState;
            zip = isParticipant ? participant.Mailing_Zip_Postal_Code__c : contact.MailingPostalCode;
            prefix = isParticipant ? participant.Salutation__c : contact.Salutation;
            phoneType = isParticipant ? participant.Phone_Type__c : contact.Phone_Type__c;

            if (isParticipant) {
                dateBirth = participant.Date_of_Birth__c;
                gender = participant.Gender__c;
                suffix = participant.Suffix__c ;
                nickname= participant.Nickname__c;
            }
        }
        
        public Contact convertToContact() {
            Contact personContact = new Contact(Id = contactId);
                  personContact.MobilePhone = mobilePhone;

            
            if (isParticipant) return personContact;
            
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
             personContact.suffix=suffix;
            personContact.MailingState = mailingState;
            personContact.MailingPostalCode = zip;
            personContact.Salutation=prefix;
            personContact.Phone_Type__c=phoneType;
            return personContact;
        }
        
        public Participant__c convertToParticipant() {
            if (!isParticipant) return null;
            
            Participant__c personParticipant = new Participant__c(Id = participantId);
            personParticipant.First_Name__c = firstName;
            personParticipant.Middle_Name__c = middleName;
            personParticipant.Last_Name__c = lastName;
            personParticipant.Phone__c = homePhone;
            personParticipant.Mailing_Country_Code__c = mailingCC;
            personParticipant.Mailing_State_Code__c = mailingSC;
            
            personParticipant.Date_of_Birth__c = dateBirth;
            personParticipant.Gender__c = gender;
            personParticipant.Mailing_Zip_Postal_Code__c = zip;
            personParticipant.Suffix__c = suffix;
            personParticipant.Salutation__c=prefix;
            personParticipant.Nickname__c = nickname;
            personParticipant.Phone_Type__c = phoneType;
            
            
            return personParticipant;
        }
        
        public Boolean isOptInSMS() {
            if (mailingCC == null || !mailingCC.equals('US')) return false;
            
            return true;
        }
    }
}