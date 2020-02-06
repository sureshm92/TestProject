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
    public static void updateParticipantAndDelegates(Participant__c participant, Contact participantContact, List<Participant__c> delegates, List<Id> doNotContinueIds) {
        try {
            List<SObject> objectsToUpdate = new List<SObject> {participant, participantContact};
            update objectsToUpdate;

            List<Patient_Delegate__c> patientDelegates = [SELECT Id,
                                                                 Participant__c,
                                                                 Contact__c,
                                                                 Status__c
                                                          FROM Patient_Delegate__c
                                                          WHERE Participant__c = :participant.Id AND
                                                                Contact__c IN :doNotContinueIds];
            if (!patientDelegates.isEmpty()) {
                for (Patient_Delegate__c patientDelegate : patientDelegates) {
                    patientDelegate.Status__c = PatientDelegateTriggerHandler.PATIENT_DELEGATE_DISCONNECTED_STATUS;
                }

                update patientDelegates;
            }

            List<Participant__c> delegatesToUpsert = new List<Participant__c>();
            for (Participant__c delegate : delegates) {
                if (!String.isBlank(delegate.Id) ||
                        (!String.isBlank(delegate.First_Name__c) && !String.isBlank(delegate.Last_Name__c) && !String.isBlank(delegate.Email__c))) {
                    delegatesToUpsert.add(delegate);
                }
            }
            upsert delegatesToUpsert;
        } catch (Exception exp) {
            throw new AuraHandledException(exp.getMessage() + '\n' + exp.getStackTraceString());
        }
    }

    @AuraEnabled
    public static List<Participant__c> getParticipantDelegates(String participantId) {
        try {
            return [SELECT Id, Contact__c, First_Name__c, Middle_Name__c, Last_Name__c, Mailing_Zip_Postal_Code__c, Mailing_State_Code__c, Mailing_Country_Code__c, Email__c, Phone_Type__c, Phone__c FROM Participant__c WHERE Contact__c IN (SELECT Contact__c FROM Patient_Delegate__c WHERE Participant__c = :participantId)];
        } catch (Exception exp) {
            throw new AuraHandledException(exp.getMessage() + '\n' + exp.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String updatePatientStatus(String stepWrapperJSON, String peId){
        try {
            String steps = ReferralProfileRemote.updateParticipantStatus(stepWrapperJSON, peId);
            return steps;
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

}