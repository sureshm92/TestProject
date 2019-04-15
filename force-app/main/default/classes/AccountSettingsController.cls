/**
 * Created by D.Yasinskyi on 07.05.2018
 */
public without sharing class AccountSettingsController {

    @AuraEnabled
    public static String getInitData(String userMode) {
        try {
            AccountSettingsController.AccountData initData = new AccountSettingsController.AccountData();
            initData.myContact = getCurrentContact();
            initData.cookieSettings = getCookieSettings();

            if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
                initData.myContact = fillParticipantContact(initData.myContact);
            }

            if (initData.myContact.primaryContact__c == null) {
        
                if (userMode == CommunityService.USER_MODE_PARTICIPANT
                        && !ParticipantService.getInstance().getState().isDelegate) {
                    initData.participant = [
                            SELECT Id, First_Name__c, Last_Name__c, Phone__c,
                                    Mailing_Zip_Postal_Code__c, Mailing_State__c, Mailing_Country__c,
                                    Mailing_Country_Code__c, Mailing_State_Code__c,
                                    Gender__c, Date_of_Birth__c, Initials__c
                            FROM Participant__c
                            WHERE Contact__c = :initData.myContact.Id
                    ];
                    //translate country:
                    initData.participant.Mailing_Country__c =
                            CountryStateUtil.getCountryName(initData.participant.Mailing_Country_Code__c);

                    //translate state
                    initData.participant.Mailing_State__c = CountryStateUtil.getStateName(
                            initData.participant.Mailing_Country_Code__c,
                            initData.participant.Mailing_State_Code__c
                    );

                } else {
                    initData.institute = getInstituteById(initData.myContact.AccountId);
                }
            } else {
                initData.institute = getInstituteById(initData.myContact.primaryContact__r.AccountId);
            }
            initData.userName = UserInfo.getUserName();
            initData.isDelegate = ParticipantService.getInstance().getState().isDelegate;
            return JSON.serialize(initData);
        } catch (Exception e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void updateParticipant(String participantJSON) {
        try {
            Participant__c participant = (Participant__c) JSON.deserialize(participantJSON, Participant__c.class);
            upsert participant;
        }  catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String isDelegate() {
        return PatientDelegateRemote.isDelegate();
    }

    @AuraEnabled
    public static void changeEmail(String newEmail) {
        try {
            Contact currentContact = getCurrentContact();
            currentContact.Email = newEmail;
            update currentContact;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void changePassword(String newPassword, String verifyNewPassword, String oldPassword) {
        PageReference pr;
        try {
            pr = Site.changePassword(newPassword, verifyNewPassword, oldPassword);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void changeOptInEmail(Boolean participantOptInStatusEmail, Boolean hcpOptInPatientEmail, Boolean hcpOptInStudyEmail, Boolean hcpOptInRefStatusEmail) {
        try {
            Contact currentContact = getCurrentContact();
            currentContact.Participant_Opt_In_Status_Emails__c = participantOptInStatusEmail;
            currentContact.HCP_Opt_In_Patient_Status_Emails__c = hcpOptInPatientEmail;
            currentContact.HCP_Opt_In_Study_Emails__c = hcpOptInStudyEmail;
            currentContact.HCP_Opt_In_Referral_Status_Emails__c = hcpOptInRefStatusEmail;
            update currentContact;
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

    private static Contact fillParticipantContact(Contact pContact) {
        List<Participant__c> pList = [
                SELECT  First_Name__c,
                        Last_Name__c,
                        Initials__c,
                        Gender__c,
                        Date_of_Birth__c
                FROM    Participant__c
                WHERE   Contact__c = :pContact.Id
        ];
        if (!pList.isEmpty()) {
            pContact.FirstName = pList[0].First_Name__c;
            pContact.LastName = pList[0].Last_Name__c;
        }
        return pContact;
    }

    public static Contact getCurrentContact() {
        return [
                SELECT Id
                        , FirstName
                        , LastName
                        , AccountId
                        , Email
                        , Phone
                        , primaryContact__c
                        , primaryContact__r.AccountId
                        , HasOptedOutOfEmail
                        , Participant_Opt_In_Status_Emails__c
                        , HCP_Opt_In_Patient_Status_Emails__c
                        , HCP_Opt_In_Study_Emails__c
                        , HCP_Opt_In_Referral_Status_Emails__c
                        , Delegate_Opt_In_Status_Emails__c
                        , RRCookiesAllowedCookie__c
                        , RRLanguageAllowedCookie__c
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
        if(!ars.isEmpty()) dmlOptions.assignmentRuleHeader.AssignmentRuleId = ars[0].Id;

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
                AND Active = true
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

    private static Account getInstituteById(Id accountId) {
        return [
                SELECT Id
                        , Name
                        , BillingStreet
                        , BillingState
                        , BillingCity
                        , Phone
                        , Fax
                FROM Account
                WHERE Id = :accountId
        ];
    }

    public static List<CookieSettings> getCookieSettings() {
        List<CookieSettings> cookieSettings = new List<CookieSettings>();
        cookieSettings.add(new CookieSettings('autocomplete', 'Used to determine whether the browser remembers a user’s login ID'));
        cookieSettings.add(new CookieSettings('clientSrc', 'Used to authenticate a user'));
        cookieSettings.add(new CookieSettings('force-proxy-stream', 'Used to redirect server requests for sticky sessions'));
        cookieSettings.add(new CookieSettings('force-stream', 'Used to redirect server requests for sticky sessions'));
        cookieSettings.add(new CookieSettings('RRetURL', 'Used to redirect user logins'));
        cookieSettings.add(new CookieSettings('RSID', 'Used to redirect user logins'));
        cookieSettings.add(new CookieSettings('sfdc-stream', 'Used to redirect server requests for sticky sessions'));
        cookieSettings.add(new CookieSettings('sid', 'Used to authenticate a user'));
        cookieSettings.add(new CookieSettings('sid_Client', 'Used to authenticate a user'));
        cookieSettings.add(new CookieSettings('oid', 'Used to redirect a user to the correct Salesforce org and assist the user for the next login'));
        cookieSettings.add(new CookieSettings('x-apm-brtm-bt-p', 'Used to maintain browser type'));
        cookieSettings.add(new CookieSettings('x-apm-brtm-bt-pv', 'Used to maintain browser version'));

        return cookieSettings;
    }

    public class AccountData {
        public Contact myContact;
        public Account institute;
        public Participant__c participant;
        public String userName;
     	public Boolean isDelegate;
        @AuraEnabled
        public List<CookieSettings> cookieSettings;
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
}
