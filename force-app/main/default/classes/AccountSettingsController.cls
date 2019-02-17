/**
 * Created by D.Yasinskyi on 07.05.2018
 */
public without sharing class AccountSettingsController {

    @AuraEnabled
    public static String getInitData(String userMode) {
        try{
            AccountSettingsController.AccountData initData = new AccountSettingsController.AccountData();
    
            initData.myContact = getCurrentContact();
            if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
                initData.myContact = fillParticipantContact(initData.myContact);
            }
    
            if (initData.myContact.primaryContact__c == null) {
        
                if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
                    initData.participant = [
                            SELECT Id, First_Name__c, Last_Name__c, Phone__c,
                                    Mailing_Zip_Postal_Code__c, Mailing_State__c, Mailing_Country__c,
                                    Mailing_Country_Code__c, Mailing_State_Code__c
                            FROM Participant__c
                            WHERE Contact__c =: initData.myContact.Id
                    ];
                    //translate country:
                    initData.participant.Mailing_Country__c = CountryStateUtil.getCountryName(initData.participant.Mailing_Country_Code__c);

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
            return JSON.serialize(initData);
        }catch (Exception e){
            System.debug(e);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void changeEmail(String newEmail) {
        try {
            Contact currentContact = CommunityService.getUserContact();
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
    public static void changeOptInEmail(Boolean participantOptInStatusEmail, Boolean hcpOptInPatientEmail, Boolean hcpOptInStudyEmail, Boolean hcpOptInRefStatusEmail){
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
    
    private static Contact fillParticipantContact(Contact pContact) {
        List<Participant__c> pList = [
                SELECT First_Name__c
                        , Last_Name__c
                FROM Participant__c
                WHERE Contact__c = :pContact.Id
        ];
        if (!pList.isEmpty()) {
            pContact.FirstName = pList[0].First_Name__c;
            pContact.LastName = pList[0].Last_Name__c;
        }
        return pContact;
    }

    private static Contact getCurrentContact() {
        return [
                SELECT Id
                        , FirstName
                        , LastName
                        , AccountId
                        , Email
                        , primaryContact__c
                        , primaryContact__r.AccountId
                        , HasOptedOutOfEmail
                        , Participant_Opt_In_Status_Emails__c
                        , HCP_Opt_In_Patient_Status_Emails__c
                        , HCP_Opt_In_Study_Emails__c
                        , HCP_Opt_In_Referral_Status_Emails__c

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
        if(ars.isEmpty()) throw new AuraHandledException('No case assigenment rule found!');

        Database.DMLOptions dmlOptions = new Database.DMLOptions();
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

    public class AccountData {
        public Contact myContact;
        public Account institute;
        public Participant__c participant;
        public String userName;
    }
}