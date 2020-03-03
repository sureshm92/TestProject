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
    public static void createUserForPatientProtal(String peJSON, Boolean sendEmails) {
        Participant_Enrollment__c pe = (Participant_Enrollment__c) JSON.deserialize(peJSON, Participant_Enrollment__c.class);
        if (sendEmails) {
            update new Contact(Id = pe.Participant_Contact__c, Consent_To_Inform_About_Study__c = true);
        }
        try {
            if (pe.HCP_Contact__c == null) {
                ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createParticipantUsers(new Map<Id, Id>{
                        pe.Participant_Contact__c => pe.PI_Contact__c
                });
            } else {
                ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createParticipantUsers(new Map<Id, Id>{
                        pe.Participant_Contact__c => pe.HCP_Contact__c
                });
            }
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
            system.debug('Participant__c: ' + participant);
            system.debug('Contact: ' + participantContact);
            system.debug('List<Participant__c>: ' + delegates);
            system.debug('List<Id>: ' + doNotContinueIds);
            system.debug('Boolean: ' + needsInvite);

            update participant;
            if (participantContact.Id != null) {
                update participantContact;
            }

            Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
            Study_Site__c studySiteDetails = [SELECT Id, Name, Principal_Investigator__c, Clinical_Trial_Profile__c, Clinical_Trial_Profile__r.CommunityTemplate__c FROM Study_Site__c WHERE Id = :studySiteId];
            String permissionSetName = CommunityTemplateService.getTemplate(studySiteDetails.Clinical_Trial_Profile__r.CommunityTemplate__c).permissionSet;
            Map<Id, Id> toCreateUser = new Map<Id, Id>();
            if (needsInvite) {
                system.debug('needsInvite: ' + needsInvite);
                toCreateUser.put(participant.Contact__c, null);
                actionAssignContactPermissions.addPermission(participant.Contact__c, permissionSetName);
            }

            List<Contact> delegateContacts = [SELECT Id FROM Contact WHERE Id IN :doNotContinueIds];
            List<Patient_Delegate__c> notPatientDelegatesEver = [SELECT Id,
                                                                 Participant__c,
                                                                 Contact__c,
                                                                 Status__c
                                                          FROM Patient_Delegate__c
                                                          WHERE Participant__c = :participant.Id AND
                                                                Contact__c IN :delegateContacts];
            if (!notPatientDelegatesEver.isEmpty()) {
                system.debug('patientDelegates: ' + notPatientDelegatesEver);
                for (Patient_Delegate__c patientDelegate : notPatientDelegatesEver) {
                    patientDelegate.Status__c = PatientDelegateTriggerHandler.PATIENT_DELEGATE_DISCONNECTED_STATUS;
                }

                update notPatientDelegatesEver;
            }

            // TODO: the functionality which will be used in future
            /*if (!delegates.isEmpty()) {
                Set<Id> excludeIds = new Set<Id>((List<Id>)doNotContinueIds);
                system.debug('delegates.isEmpty(): ' + delegates.isEmpty());
                List<Patient_Delegate__c> patientDelegatesToInsert = new List<Patient_Delegate__c>();
                List<Participant__c> delegatesToUpdate = new List<Participant__c>();
                List<Participant__c> delegatesToInsert = new List<Participant__c>();
                for (Participant__c delegate : delegates) {
                    if (!String.isBlank(delegate.Id) && !excludeIds.contains(delegate.Id)) {
                        system.debug('delegatesToUpdate: ' + delegate);
                        delegatesToUpdate.add(delegate);
                    } else if (String.isBlank(delegate.Id) && !String.isBlank(delegate.First_Name__c) &&
                            !String.isBlank(delegate.Last_Name__c) && !String.isBlank(delegate.Email__c)) {
                        delegatesToInsert.add(delegate);
                        system.debug('delegatesToInsert: ' + delegate);
                    }
                }
                if (!delegatesToUpdate.isEmpty()) {
                    update delegatesToUpdate;
                }

                if (!delegatesToInsert.isEmpty()) {
                    system.debug('delegatesToInsert.isEmpty(): ' + delegatesToInsert.isEmpty());
                    List<Participant__c> filteredDelegates = new List<Participant__c>();
                    ParticipantDuplicateService duplicateService = new ParticipantDuplicateService(delegatesToInsert);
                    for (Participant__c delegate : delegatesToInsert) {
                        Participant__c delegateFromDatabase = duplicateService.findDuplicate(delegate);
                        if (delegateFromDatabase != null) {
                            filteredDelegates.add(delegateFromDatabase);
                        } else {
                            //check contact duplicate:
                            if (duplicateService.findDuplicateContact(delegate) != null) {
                                delegate.Contact__c = duplicateService.findDuplicateContact(delegate).Id;
                            }
                            filteredDelegates.add(delegate);
                        }
                    }
                    upsert filteredDelegates;

                    List<Participant__c> newDelegates = [SELECT Id, Contact__c FROM Participant__c WHERE Id IN :(new Map<Id, Participant__c>(delegatesToInsert)).keySet()];
                    for (Participant__c newDelegate : newDelegates) {
                        if (newDelegate.Contact__c != null) {
                            patientDelegatesToInsert.add(
                                    new Patient_Delegate__c(
                                            Participant__c = participant.Id,
                                            Contact__c = newDelegate.Contact__c,
                                            Status__c = PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS
                                    )
                            );
                            toCreateUser.put(newDelegate.Contact__c, null);
                        }
                    }

                    if (!patientDelegatesToInsert.isEmpty()) {
                        insert patientDelegatesToInsert;
                    }
                }
            }*/

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
            return JSON.serialize(ParticipantWorkflowService.prepareParticipantWorkflow(ctp, pe));
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


}