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
            String steps = ReferralProfileRemote.getReferralProfileDetail(peId, userMode, delegateId);
            return steps;
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
    public static void updateParticipantAndDelegates(String participantS, String participantContactS, String delegatesS, List<String> doNotContinueIds, Boolean needsInvite) {
        try {
            Participant__c participant = (Participant__c)JSON.deserialize(participantS, Participant__c.class);
            Contact participantContact = (Contact)JSON.deserialize(participantContactS, Contact.class);
            List<Participant__c> delegates = (List<Participant__c>)JSON.deserialize(delegatesS, List<Participant__c>.class);
            system.debug('Participant__c: ' + participant);
            system.debug('Contact: ' + participantContact);
            system.debug('List<Participant__c>: ' + delegates);
            system.debug('List<Id>: ' + doNotContinueIds);
            system.debug('Boolean: ' + needsInvite);
            Map<Id, Id> toCreateUser = new Map<Id, Id>();

            update participant;
            if (participantContact.Id != null) {
                update participantContact;
            }

            if (needsInvite) {
                system.debug('needsInvite: ' + needsInvite);
                toCreateUser.put(participant.Contact__c, null);
            }

            List<Patient_Delegate__c> patientDelegates = [SELECT Id,
                                                                 Participant__c,
                                                                 Contact__c,
                                                                 Status__c
                                                          FROM Patient_Delegate__c
                                                          WHERE Participant__c = :participant.Id AND
                                                                Contact__c IN :doNotContinueIds];
            if (!patientDelegates.isEmpty()) {
                system.debug('patientDelegates: ' + patientDelegates);
                for (Patient_Delegate__c patientDelegate : patientDelegates) {
                    patientDelegate.Status__c = PatientDelegateTriggerHandler.PATIENT_DELEGATE_DISCONNECTED_STATUS;
                }

                update patientDelegates;
            }

            if (!delegates.isEmpty()) {
                system.debug('delegates.isEmpty(): ' + delegates.isEmpty());
                List<Patient_Delegate__c> patientDelegatesToInsert = new List<Patient_Delegate__c>();
                List<Participant__c> delegatesToUpdate = new List<Participant__c>();
                List<Participant__c> delegatesToInsert = new List<Participant__c>();
                for (Participant__c delegate : delegates) {
                    if (!String.isBlank(delegate.Id)) {
                        system.debug('delegatesToUpdate: ' + delegate);
                        delegatesToUpdate.add(delegate);
                    } else if (!String.isBlank(delegate.First_Name__c) && !String.isBlank(delegate.Last_Name__c) && !String.isBlank(delegate.Email__c)) {
                        delegatesToInsert.add(delegate);
                        system.debug('delegatesToInsert: ' + delegate);
                    }
                }
                update delegatesToUpdate;

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
                                delegate.Contact__c = duplicateService.findDuplicateContact(participant).Id;
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
            }

            system.debug('toCreateUser: ' + toCreateUser);
            if (!toCreateUser.isEmpty()) ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createParticipantUsers(toCreateUser);
        } catch (Exception exp) {
            throw new AuraHandledException(exp.getMessage() + '\n' + exp.getStackTraceString());
        }
    }

    @AuraEnabled
    public static List<Participant__c> getParticipantDelegates(String participantId) {
        try {
            return [SELECT Id,
                            Contact__c,
                            First_Name__c,
                            Middle_Name__c,
                            Last_Name__c,
                            Mailing_Zip_Postal_Code__c,
                            Mailing_State_Code__c,
                            Mailing_Country_Code__c,
                            Email__c,
                            Phone_Type__c,
                            Phone__c
                    FROM Participant__c
                    WHERE Contact__c IN (SELECT Contact__c
                                         FROM Patient_Delegate__c
                                         WHERE Participant__c = :participantId AND
                                               Status__c = :PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS)];
        } catch (Exception exp) {
            throw new AuraHandledException(exp.getMessage() + '\n' + exp.getStackTraceString());
        }
    }

}