/**
 * Created by Nikita Abrazhevitch on 05-Sep-19.
 */

public without sharing class ParticipantInformationRemote {

    @AuraEnabled
    public static AddPatientByPIRemote.FormData getInitData() {
        try {
            AddPatientByPIRemote.FormData formData = AddPatientByPIRemote.getInitData(null);
            return formData;
        } catch (Exception e) {
            return (AddPatientByPIRemote.FormData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getSteps(String peId, String userMode, String delegateId) {
        try {
            String steps = ReferralProfileRemote.getReferralProfileDetail(peId, userMode, delegateId);
            return steps;
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getPrintInformation(String peId, String userMode, String delegateId) {
        try {
            Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(peId, userMode, delegateId);
            ParticipantItem pi =  new ParticipantItem(pe);
            ParticipantWorkflowService.populatePatientItemsWithPathWrappers(new List<ParticipantItem>{pi});
            return JSON.serialize(pi);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void updatePatientInfo(String participantJSON, String peJSON) {
        AddPatientByPIRemote.updatePatientInfo(participantJSON, peJSON);
    }

    @AuraEnabled
    public static void updatePatientInfoWithDelegate(String participantJSON, String peJSON, String delegateJSON, String userInfoJSON) {
        AddPatientByPIRemote.updatePatientInfo(participantJSON, peJSON);
        if (!String.isBlank(delegateJSON)) {
            Contact delegateParticipant = (Contact) JSON.deserialize(delegateJSON, Contact.class);
            if (delegateParticipant != null) {
                try {
                    update delegateParticipant;
                } catch (Exception exp) {
                    system.debug('No delegate was provided');
                }
            }
        }
        updateUserLanguage(userInfoJSON);
    }

    @AuraEnabled
    public static List<User> createUserForPatientProtal(String peJSON, Boolean sendEmails) {
        Participant_Enrollment__c pe = (Participant_Enrollment__c) JSON.deserialize(peJSON, Participant_Enrollment__c.class);
        if (sendEmails) {
            update new Contact(Id = pe.Participant_Contact__c, Consent_To_Inform_About_Study__c = true);
        }
        try {
            List<User> returnUsers = new List<User>();
            if (pe.HCP_Contact__c == null) {
                 returnUsers = ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createParticipantUsers(new Map<Id, Id>{
                        pe.Participant_Contact__c => pe.PI_Contact__c
                });
            } else {
                 returnUsers = ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createParticipantUsers(new Map<Id, Id>{
                        pe.Participant_Contact__c => pe.HCP_Contact__c
                });
            }

            Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
            String permissionSetName = CommunityTemplateService.getTemplate(pe.Clinical_Trial_Profile__r.CommunityTemplate__c).permissionSet;
            actionAssignContactPermissions.addPermission(pe.Participant_Contact__c, permissionSetName);
            if (!actionAssignContactPermissions.isEmpty()) {
                ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
            }
            return returnUsers;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void updateParticipantAndDelegates(String participantS, String participantContactS, String delegatesS, List<String> doNotContinueIds, Boolean needsInvite, String studySiteId) {
        try {
            Participant__c participant = (Participant__c)JSON.deserialize(participantS, Participant__c.class);
            Contact participantContact = (Contact)JSON.deserialize(participantContactS, Contact.class);
            List<Participant__c> delegates = (List<Participant__c>)JSON.deserialize(delegatesS, List<Participant__c>.class);

            Study_Site__c studySite = StudySiteService.getStudySiteForPIById(studySiteId);
            Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
            String permissionSetName = CommunityTemplateService.getTemplate(studySite.Clinical_Trial_Profile__r.CommunityTemplate__c).permissionSet;

            system.debug('Participant__c: ' + participant);
            system.debug('Contact: ' + participantContact);
            system.debug('List<Participant__c>: ' + delegates);
            system.debug('List<Id>: ' + doNotContinueIds);
            system.debug('Boolean: ' + needsInvite);

            update participant;
            if (participantContact.Id != null) {
                participantContact.Email = participant.Email__c;
                if (participant.Phone_Type__c == 'Home') {
                    participantContact.HomePhone = participant.Phone__c;
                } if (participant.Phone_Type__c == 'Mobile') {
                    participantContact.MobilePhone = participant.Phone__c;
                } else {
                    participantContact.Phone = participant.Phone__c;
                }
                update participantContact;
            }

            Map<Id, Id> toCreateUser = new Map<Id, Id>();
            if (needsInvite) {
                system.debug('needsInvite: ' + needsInvite);
                toCreateUser.put(participant.Contact__c, null);
                actionAssignContactPermissions.addPermission(participant.Contact__c, permissionSetName);
            }

            List<Patient_Delegate__c> notPatientDelegatesEver = [SELECT Id,
                                                                 Participant__c,
                                                                 Contact__c,
                                                                 Status__c
                                                          FROM Patient_Delegate__c
                                                          WHERE Participant__c = :participant.Id AND
                                                                Contact__c IN :doNotContinueIds AND
                                                                Status__c = :PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS];
            if (!notPatientDelegatesEver.isEmpty()) {
                system.debug('patientDelegates: ' + notPatientDelegatesEver);
                for (Patient_Delegate__c patientDelegate : notPatientDelegatesEver) {
                    patientDelegate.Status__c = PatientDelegateTriggerHandler.PATIENT_DELEGATE_DISCONNECTED_STATUS;
                }

                update notPatientDelegatesEver;
            }

            List<Contact> contactsToUpdate = new List<Contact>();
            for (Participant__c delegateParticipant : delegates) {
                contactsToUpdate.add(new Contact(
                        Id = delegateParticipant.Contact__c,
                        MailingState = delegateParticipant.Mailing_State__c,
                        MailingCountry = delegateParticipant.Mailing_Country__c,
                        MailingStateCode = delegateParticipant.Mailing_State_Code__c,
                        MailingCountryCode = delegateParticipant.Mailing_Country_Code__c,
                        MailingPostalCode = delegateParticipant.Mailing_Zip_Postal_Code__c,
                        Email = delegateParticipant.Email__c,
                        Phone = delegateParticipant.Phone__c
                ));

            }
            update contactsToUpdate;

            system.debug('toCreateUser: ' + toCreateUser);
            if (!toCreateUser.isEmpty()) ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createParticipantUsers(toCreateUser);
            if (!actionAssignContactPermissions.isEmpty()) {
                ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
            }
        } catch (Exception exp) {
            throw new AuraHandledException(exp.getMessage() + '\n' + exp.getStackTraceString());
        }
    }

    @AuraEnabled
    public static List<Participant__c> getParticipantDelegates(String participantId) {
        try {
            List<Participant__c> participantDelegates = new List<Participant__c>();

            List<Contact> contacts =
                    [SELECT Id,
                            FirstName,
                            MiddleName,
                            LastName,
                            MailingPostalCode,
                            MailingStateCode,
                            MailingCountryCode,
                            MailingState,
                            MailingCountry,
                            Email,
                            HomePhone,
                            MobilePhone,
                            Phone
                    FROM Contact
                    WHERE Id IN (SELECT Contact__c
                                         FROM Patient_Delegate__c
                                         WHERE Participant__c = :participantId AND
                                               Status__c = :PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS)];
            for (Contact cnt : contacts) {
                Participant__c participantDelegate = new Participant__c(Contact__c = cnt.Id,
                    First_Name__c = cnt.FirstName,
                    Middle_Name__c = cnt.MiddleName,
                    Last_Name__c = cnt.LastName,
                    Mailing_Zip_Postal_Code__c = cnt.MailingPostalCode,
                    Mailing_State_Code__c = cnt.MailingStateCode,
                    Mailing_State__c = cnt.MailingState,
                    Mailing_Country_Code__c = cnt.MailingCountryCode,
                    Mailing_Country__c = cnt.MailingCountry,
                    Email__c = cnt.Email
                );

                if (cnt.HomePhone != null) {
                    participantDelegate.Phone__c = cnt.HomePhone;
                    participantDelegate.Phone_Type__c = 'Home';
                } if (cnt.MobilePhone != null) {
                    participantDelegate.Phone__c = cnt.MobilePhone;
                    participantDelegate.Phone_Type__c = 'Mobile';
                } else {
                    participantDelegate.Phone__c = cnt.Phone;
                    participantDelegate.Phone_Type__c = 'Work';
                }

                participantDelegates.add(participantDelegate);
            }

            return participantDelegates;
        } catch (Exception exp) {
            throw new AuraHandledException(exp.getMessage() + '\n' + exp.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String updatePatientStatus(String pathWrapperJSON, String peId){
        Participant_Enrollment__c pe = new Participant_Enrollment__c(Id = peId);
        return updatePatientStatus(pathWrapperJSON, pe);
    }

    public static String updatePatientStatus(String pathWrapperJSON, Participant_Enrollment__c pe){
        try {
            ParticipantWorkflowService.ParticipantWorkflowWrapper pathWrapper =
                    (ParticipantWorkflowService.ParticipantWorkflowWrapper)JSON.deserialize(pathWrapperJSON, ParticipantWorkflowService.ParticipantWorkflowWrapper.class);
            ParticipantWorkflowService.populatePEFromWorkflowWrapper(pathWrapper, pe);
            update pe;
            Participant_Enrollment_Status_History__c pesh = ParticipantWorkflowService.createPESHFromPathWrapper(pathWrapper, pe.Id);
            if(pesh != null){
                insert pesh;
            }
            pe = ParticipantEnrollmentService.getParticipantEnrollment(pe.Id, CommunityService.USER_MODE_PI);
            Clinical_Trial_Profile__c ctp = StudyTrialService.getFullTrial(pe.Clinical_Trial_Profile__c);
            if (pe == null) throw new CommunityServiceException('Participant enrollment not found');
            return JSON.serialize( new UpdateResponse(pe, ParticipantWorkflowService.prepareParticipantWorkflow(ctp, pe)));
        } catch (Exception e) {
            System.debug('ERROR: ' + e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());        }
    }

    @AuraEnabled
    public static String updatePatientInfoAndStatus(String participantJSON, String peJSON, String pathWrapperJSON, String peId){
        Participant__c participant = (Participant__c)JSON.deserialize(participantJSON, Participant__c.class);
        Participant_Enrollment__c pe = (Participant_Enrollment__c)JSON.deserialize(peJSON, Participant_Enrollment__c.class);
        update participant;
        return updatePatientStatus(pathWrapperJSON, pe);
    }

    @AuraEnabled
    public static String updatePatientInfoAndStatusWithDelegate(String participantJSON, String peJSON, String pathWrapperJSON, String peId, String delegateJSON, String userInfoJSON) {
        try{
            Participant__c participant = (Participant__c)JSON.deserialize(participantJSON, Participant__c.class);
            update participant;
        }catch (Exception e){
            AuraHelper.throwException(e);
        }
        Participant_Enrollment__c pe = (Participant_Enrollment__c)JSON.deserialize(peJSON, Participant_Enrollment__c.class);

        if (!String.isBlank(delegateJSON)) {
            Contact delegateParticipant = (Contact) JSON.deserialize(delegateJSON, Contact.class);
            if (delegateParticipant != null) {
                try {
                    update delegateParticipant;
                } catch (Exception exp) {
                    system.debug('No delegate was provided');
                }
            }
        }
        updateUserLanguage(userInfoJSON);

        return updatePatientStatus(pathWrapperJSON, pe);
    }

    public static void updateUserLanguage(String userJSON) {
        if (!String.isBlank(userJSON)) {
            try {
                User userL = (User)JSON.deserialize(userJSON, User.class);
                if (userL != null) {
                    update userL;
                }
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
            }

        }
    }

    public class UpdateResponse{
        @AuraEnabled public Participant_Enrollment__c pe;
        @AuraEnabled public ParticipantWorkflowService.ParticipantWorkflowWrapper participantPath;

        public UpdateResponse(Participant_Enrollment__c pe, ParticipantWorkflowService.ParticipantWorkflowWrapper participantPath){
            this.pe = pe;
            this.participantPath = participantPath;
        }
    }

}
