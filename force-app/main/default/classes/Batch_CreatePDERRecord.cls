/*This is one time batch to create PDER records for historical data */
public without sharing class Batch_CreatePDERRecord implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            [
                SELECT
                    id,
                    Attestation_TimeStamp__c,
                    Attested_by__c,
                    Is_Created_by_Bulk_Import__c,
                    isInviteToPP__c,
                    Primary_Delegate__c,
                    Status__c,
                    Contact__c,
                    Participant__c,
                    Contact__r.IQVIA_Artificial_Voice_Consent__c,
                    Contact__r.IQVIA_Artificial_Voice_Consent_Time__c,
                    Contact__r.IQVIA_Assisted_Dialing_Consent__c,
                    Contact__r.IQVIA_Assisted_Dialing_Consent_Time__c,
                    Contact__r.IQVIA_Direct_Mail_Consent__c,
                    Contact__r.IQVIA_Direct_Mail_Consent_Time__c,
                    Contact__r.Participant_Opt_In_Status_Emails__c,
                    Contact__r.IQVIA_Email_Consent_Time__c,
                    Contact__r.IQVIA_Contact_info_storage_consent__c,
                    Contact__r.IQVIA_PI_Storage_Consent_Time__c,
                    Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
                    Contact__r.IQVIA_Phone_Consent_Time__c,
                    Contact__r.IQVIA_Pre_recorded_Voice_Consent__c,
                    Contact__r.IQVIA_Pre_recorded_Calls_Consent_Time__c,
                    Contact__r.Participant_Opt_In_Status_SMS__c,
                    Contact__r.IQVIA_SMS_Consent_Time__c
                FROM Patient_Delegate__c
            ]
        );
    }

    public void execute(
        Database.BatchableContext bc,
        List<Patient_Delegate__c> lstPatientDelegate
    ) {
        set<Id> setParticipantId = new Set<Id>();
        Map<Id, List<Participant_Enrollment__c>> mapParticipantIdToParticipantEnrollment = new Map<Id, list<Participant_Enrollment__c>>();
        list<Id> lstPatientDelegateToIgnore = new list<Id> ();
        set<String> setExistingPer = new Set<String>();
        for (Patient_Delegate_Enrollment__c objPDER : [
            SELECT ID, Participant_Enrollment__c, Patient_Delegate__c
            FROM Patient_Delegate_Enrollment__c
            WHERE Patient_Delegate__c IN :lstPatientDelegate
        ]) {
          setExistingPer.add(objPDER.Participant_Enrollment__c + '__'+objPDER.Patient_Delegate__c); 
          lstPatientDelegateToIgnore.add(objPDER.Patient_Delegate__c) ;
        }

        List<String> lstPPStudy = system.label.PP_Studies_For_Data_Load.split(';');

        for (Patient_Delegate__c objDel : lstPatientDelegate) {
            setParticipantId.add(objDel.Participant__c);
        }

        Date objstartdate = date.newInstance(2022, 12, 10);
        Date objEndDate = date.newInstance(2023, 03, 26);

        for (Participant_Enrollment__c objPart : [
            SELECT
                id,
                Participant__c,
                Clinical_Trial_Profile__c,
                Clinical_Trial_Profile__r.IQVIA_Outreach__c,
                Clinical_Trial_Profile__r.Name
            FROM Participant_Enrollment__c
            WHERE
                Participant__c IN :setParticipantId
                AND Clinical_Trial_Profile__r.IQVIA_Outreach__c = FALSE
        ]) {
            if (!mapParticipantIdToParticipantEnrollment.containskey(objPart.Participant__c))
                mapParticipantIdToParticipantEnrollment.put(
                    objPart.Participant__c,
                    new List<Participant_Enrollment__c>{ objPart }
                );
            else {
                list<Participant_Enrollment__c> lstTempPER = new List<Participant_Enrollment__c>();
                lstTempPER = mapParticipantIdToParticipantEnrollment.get(objPart.Participant__c);
                lstTempPER.add(objPart);
                mapParticipantIdToParticipantEnrollment.put(objPart.Participant__c, lstTempPER);
            }
        }
        List<Patient_Delegate_Enrollment__c> lstPDER = new List<Patient_Delegate_Enrollment__c>();
        for (Patient_Delegate__c objDel : lstPatientDelegate) {
          if (mapParticipantIdToParticipantEnrollment.containskey(objDel.Participant__c)  && !lstPatientDelegateToIgnore.contains(objDel.id)) {
                for (
                    Participant_Enrollment__c objper : mapParticipantIdToParticipantEnrollment.get(
                        objDel.Participant__c
                    )
                ) {
                  if(!setExistingPer.contains(objper.Id + '__' + objDel.Id)) {
                        Patient_Delegate_Enrollment__c objPDER = new Patient_Delegate_Enrollment__c();
                        objPDER.Participant_Enrollment__c = objper.Id;
                        objPDER.Patient_Delegate__c = objDel.Id;
                        objPDER.Attestation_TimeStamp__c = objDel.Attestation_TimeStamp__c;
                        objPDER.Attested_By__c = objDel.Attested_by__c;
                        objPDER.Is_Created_by_Bulk_Import__c = objDel.Is_Created_by_Bulk_Import__c;
                        objPDER.isInviteToPP__c = objDel.isInviteToPP__c;
                        objPDER.Primary_Delegate__c = objDel.Primary_Delegate__c;
                        objPDER.Status__c = objDel.Status__c;
                        if((!lstPPStudy.isEmpty() && !lstPPStudy.contains(objper.Clinical_Trial_Profile__r.Name)) || lstPPStudy.isEmpty())
                        {
                            if(objDel.Contact__r.IQVIA_Artificial_Voice_Consent_Time__c  > objstartdate 
                            && objDel.Contact__r.IQVIA_Artificial_Voice_Consent_Time__c <= objEndDate) {
                            objPDER.Study_Artificial_Voice_Consent__c = objDel.Contact__r.IQVIA_Artificial_Voice_Consent__c;
                            objPDER.Study_Artificial_Voice_Consent_Time__c = objDel.Contact__r.IQVIA_Artificial_Voice_Consent_Time__c;
                            }
                            if(objDel.Contact__r.IQVIA_Assisted_Dialing_Consent_Time__c  > objstartdate 
                            && objDel.Contact__r.IQVIA_Assisted_Dialing_Consent_Time__c <= objEndDate) {
                            objPDER.Study_Assisted_Dialing_Consent__c = objDel.Contact__r.IQVIA_Assisted_Dialing_Consent__c;
                            objPDER.Study_Assisted_Dialing_Consent_Time__c = objDel.Contact__r.IQVIA_Assisted_Dialing_Consent_Time__c;
                            }
                            if(objDel.Contact__r.IQVIA_Direct_Mail_Consent_Time__c  > objstartdate 
                            && objDel.Contact__r.IQVIA_Direct_Mail_Consent_Time__c <= objEndDate) {
                            objPDER.Study_Direct_Mail_Consent__c = objDel.Contact__r.IQVIA_Direct_Mail_Consent__c;
                            objPDER.Study_Direct_Mail_Consent_Time__c = objDel.Contact__r.IQVIA_Direct_Mail_Consent_Time__c;
                            }
                            if(objDel.Contact__r.IQVIA_Email_Consent_Time__c  > objstartdate 
                            && objDel.Contact__r.IQVIA_Email_Consent_Time__c <= objEndDate) {
                            objPDER.Study_Email_Consent__c = objDel.Contact__r.Participant_Opt_In_Status_Emails__c;
                            objPDER.Study_Email_Consent_Time__c = objDel.Contact__r.IQVIA_Email_Consent_Time__c;
                            }
                            if(objDel.Contact__r.IQVIA_PI_Storage_Consent_Time__c  > objstartdate 
                            && objDel.Contact__r.IQVIA_PI_Storage_Consent_Time__c <= objEndDate) {
                            objPDER.Study_info_storage_consent__c = objDel.Contact__r.IQVIA_Contact_info_storage_consent__c;
                            objPDER.Study_Storage_Consent_Time__c = objDel.Contact__r.IQVIA_PI_Storage_Consent_Time__c;
                            }
                            if(objDel.Contact__r.IQVIA_Phone_Consent_Time__c  > objstartdate 
                            && objDel.Contact__r.IQVIA_Phone_Consent_Time__c <= objEndDate) {
                            objPDER.Study_Phone_Consent__c = objDel.Contact__r.Participant_Phone_Opt_In_Permit_Phone__c;
                            objPDER.Study_Phone_Consent_Time__c = objDel.Contact__r.IQVIA_Phone_Consent_Time__c;
                            }
                            if(objDel.Contact__r.IQVIA_Pre_recorded_Calls_Consent_Time__c  > objstartdate 
                            && objDel.Contact__r.IQVIA_Pre_recorded_Calls_Consent_Time__c <= objEndDate) {
                            objPDER.Study_Pre_recorded_Voice_Consent__c = objDel.Contact__r.IQVIA_Pre_recorded_Voice_Consent__c;
                            objPDER.Study_Pre_recorded_Calls_Consent_Time__c = objDel.Contact__r.IQVIA_Pre_recorded_Calls_Consent_Time__c;
                            }
                            if(objDel.Contact__r.IQVIA_SMS_Consent_Time__c  > objstartdate 
                            && objDel.Contact__r.IQVIA_SMS_Consent_Time__c <= objEndDate) {
                            objPDER.Study_SMS_Consent__c = objDel.Contact__r.Participant_Opt_In_Status_SMS__c;
                            objPDER.Study_SMS_Consent_Time__c = objDel.Contact__r.IQVIA_SMS_Consent_Time__c;
                            }
                        }
                        lstPDER.add(objPDER);
                    }
                }
            }
        }

        if (!lstPDER.isEmpty()) {
            TriggerHandlerExecutor.bypassHandler(
                PatientDelegateEnrolTriggerHandler.CreateNewAssignmentNotification.class
            );
            TriggerHandlerExecutor.bypassHandler(
                PatientDelegateEnrolTriggerHandler.SetDefaultPatientDelegateStatusHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                PatientDelegateEnrolTriggerHandler.CreatePrimaryDelegateForMinor.class
            );
            TriggerHandlerExecutor.bypassHandler(
                PatientDelegateEnrolTriggerHandler.CreateReactivatedNotification.class
            );
            TriggerHandlerExecutor.bypassHandler(
                PatientDelegateEnrolTriggerHandler.UpdateDelegateConsent.class
            );
            TriggerHandlerExecutor.bypassHandler(
                PatientDelegateEnrolTriggerHandler.UpdateConsentTimeStamps.class
            );
            TriggerHandlerExecutor.bypassHandler(
                PatientDelegateEnrolTriggerHandler.AssignCommunityPermissionSets.class
            );
            database.insert(lstPDER,false);
        }

    }

    public void finish(Database.BatchableContext bc) {
    }
}