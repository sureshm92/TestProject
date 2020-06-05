/**
 * Created by Leonid Bartenev
 */

public without sharing class AddPatientByPIRemote {

    public class FormData {
        @AuraEnabled public List<LabelValueItem> countriesLVList = CountryStateUtil.getCountries();
        @AuraEnabled public Map<String, List<LabelValueItem>> statesByCountryMap = CountryStateUtil.getStatesByCountryMap();
        @AuraEnabled public List<LabelValueItem> genderLVList = ParticipantService.getGenderLVList();
        @AuraEnabled public List<LabelValueItem> phoneTypeLVList = SObjectHelper.getPicklistLabelValueList(Participant__c.Phone_Type__c);
        @AuraEnabled public List<LabelValueItem> referredByLVList = SObjectHelper.getPicklistLabelValueList(Participant_Enrollment__c.Referred_By__c);
        @AuraEnabled public List<LabelValueItem> languageLVList = SObjectHelper.getPicklistLabelValueList(Contact.Language__c);
        @AuraEnabled public List<LabelValueItem> peStatusLVList;
        @AuraEnabled public List<LabelValueItem> visitPlansLVList;
        @AuraEnabled public Clinical_Trial_Profile__c ctp;
        @AuraEnabled public Study_Site__c ss;
        @AuraEnabled public String userLanguage;
        
        public FormData() {}
    }
    
    @AuraEnabled
    public static FormData getInitData(Id ssId) {
        try {
            FormData initData = new FormData();
            if(ssId != null) {
                initData.ss =  StudySiteService.getStudySiteForPIById(ssId);
                initData.ctp = TrialService.getTrial(initData.ss.Clinical_Trial_Profile__c);
                initData.visitPlansLVList = StudySiteService.getVisitPlansLVList(ssId);
                initData.peStatusLVList = PEStatusState.getParticipantImportStatusesLV(initData.ctp);
                initData.userLanguage = getUserLanguage();
            }
            return initData;
        } catch (Exception e) {
            return (FormData) AuraHelper.throwException(e);
        }
    }

    //TODO:Review
    @AuraEnabled
    public static void saveParticipant(String participantJSON, String peJSON, String userLanguage, String ssId, Boolean createUser, String participantDelegateJSON, String delegateDuplicateInfo){
        try {
            if (!createUser) {
                TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class);
                TriggerHandlerExecutor.bypassHandler(UserTriggerHandler.AssignCommunityPermissionSetToUserHandler.class);
            }

            Participant__c participant = (Participant__c)JSON.deserialize(participantJSON, Participant__c.class);
            trimParticipantFields(participant);
            Participant_Enrollment__c pe = (Participant_Enrollment__c)JSON.deserialize(peJSON, Participant_Enrollment__c.class);
            participant.Secondary_Source__c = ParticipantEnrollmentService.PE_REFERRAL_SOURCE_PI;
            pe.Referral_Source__c = 'PI';
            ReferHealthcareProviderRemote.HealthcareProvider ddInfo;
            if (delegateDuplicateInfo != null) ddInfo = (ReferHealthcareProviderRemote.HealthcareProvider) JSON.deserialize(delegateDuplicateInfo, ReferHealthcareProviderRemote.HealthcareProvider.class);

            Participant__c participantDelegate;
            if (!String.isBlank(participantDelegateJSON)) {
                participantDelegate = (Participant__c) JSON.deserialize(participantDelegateJSON, Participant__c.class);
                if (participantDelegate != null) {
                    participantDelegate.Secondary_Source__c = ParticipantEnrollmentService.PE_REFERRAL_SOURCE_HCP;
                }
            }

            ParticipantService.createParticipantAndUpdatePE(participant, participantDelegate, pe, userLanguage);

            String participantId = !String.isBlank(participant.Id) ? participant.Id : pe.Participant__c;
            Participant__c newParticipant = [SELECT Id, Contact__c FROM Participant__c WHERE Id = :participantId];
            if (createUser && newParticipant != null && !String.isBlank(newParticipant.Contact__c) && !String.isBlank(ssId)) {
                Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
                Study_Site__c ss = StudySiteService.getStudySiteForPIById(ssId);
                String permissionSetName = CommunityTemplateService.getTemplate(ss.Clinical_Trial_Profile__r.CommunityTemplate__c).permissionSet;
                actionAssignContactPermissions.addPermission(newParticipant.Contact__c, permissionSetName);
                if (!actionAssignContactPermissions.isEmpty()) {
                    ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
                }
            }
            Boolean createDelegateuser = true;
            if (participantDelegate != null && !String.isEmpty(participantDelegate.Last_Name__c) &&
                    !String.isEmpty(participantDelegate.Email__c)) {
                Contact newContact;
                if(ddInfo == null || String.isBlank(ddInfo.contactId)) {
                    newContact = new Contact();
                    newContact.FirstName = participantDelegate.First_Name__c;
                    newContact.LastName = participantDelegate.Last_Name__c;
                    newContact.Email = participantDelegate.Email__c;
                    newContact.AccountId = [
                            SELECT Id
                            FROM Account
                            WHERE Name = :CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
                            LIMIT 1
                            FOR UPDATE
                    ].Id;
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
                    if ('Home' == participantDelegate.Phone_Type__c) {
                        newContact.HomePhone = participantDelegate.Phone__c;
                    } if ('Mobile' == participantDelegate.Phone_Type__c) {
                        newContact.MobilePhone = participantDelegate.Phone__c;
                    } else {
                        newContact.Phone = participantDelegate.Phone__c;
                    }
                    insert newContact;
                } else{
                    newContact = [
                            Select Id,
                                    FirstName,
                                    LastName,
                                    Email,
                                    MailingCity,
                                    MailingCountryCode,
                                    MailingStateCode
                            FROM Contact
                            WHERE Id = :ddInfo.contactId
                    ];
                    createDelegateuser = false;
                }
                if(ddInfo == null || ddInfo.participantId == null) {
                    participantDelegate.Contact__c = newContact.Id;
                    if (String.isBlank(participantDelegate.Phone__c) && !String.isBlank(participant.Phone__c)) {
                        participantDelegate.Phone__c = participant.Phone__c;
                        participantDelegate.Phone_Type__c = participant.Phone_Type__c;
                    }
                    insert participantDelegate;
                }
                if(ddInfo == null || !ddInfo.isDuplicateDelegate) {
                    Patient_Delegate__c ptDelegateRef = new Patient_Delegate__c();
                    ptDelegateRef.Participant__c = participant.Id;
                    ptDelegateRef.Contact__c = newContact.Id;
                    insert ptDelegateRef;
                }
                if(createDelegateuser) {
                    ReferringRemote.createParticipantUsers(new Map<Id, Id>{
                            newContact.Id => null
                    });
                }
            }
            //Moved history Creation to Trigger
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static Participant_Enrollment__c updatePatientInfo(String participantJSON, String peJSON){
        try{
            Participant__c participant = (Participant__c)JSON.deserialize(participantJSON, Participant__c.class);
            if(participant.Contact__r.Email == null && participant.Email__c != null){
                update new Contact(Id = participant.Contact__c, Email = participant.Email__c);
            }
            Participant_Enrollment__c pe = (Participant_Enrollment__c)JSON.deserialize(peJSON, Participant_Enrollment__c.class);
            update pe;
            update participant;
            return pe;
        }catch (Exception e){
            AuraHelper.throwException(e);
            return null;
        }
    }
    @AuraEnabled
    public static String getUserLanguage() {
        return UserInfo.getLanguage();
    }

    private static void trimParticipantFields(Participant__c participant){
        participant.Phone__c = !String.isBlank(participant.Phone__c) ? participant.Phone__c.trim() : null;
        participant.First_Name__c = !String.isBlank(participant.First_Name__c) ? participant.First_Name__c.trim() : null;
        participant.Last_Name__c = !String.isBlank(participant.Last_Name__c) ? participant.Last_Name__c.trim() : null;
        participant.Email__c = !String.isBlank(participant.Email__c) ? participant.Email__c.trim() : null;
    }

    @AuraEnabled
    public static String checkNeedsGuardian(String participantJSON) {
        return ReferringRemote.checkNeedsGuardian(participantJSON);
    }

    @AuraEnabled
    public static ReferHealthcareProviderRemote.HealthcareProvider checkDuplicateDelegate(String email, String firstName, String lastName){
        return ReferHealthcareProviderRemote.checkDuplicate(null,email, firstName, lastName, null);
    }

}