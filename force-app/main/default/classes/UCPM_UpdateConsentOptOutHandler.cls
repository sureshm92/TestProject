public with sharing class UCPM_UpdateConsentOptOutHandler {
    public static String token_type;
    public static String access_token;
    public static Integer expires_in;
    public static String settingName;
    public class updateConsentPERtoUCPM extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            List<Participant_Enrollment__c> pernewList = [
                SELECT
                    Id,
                    Participant__r.First_Name__c,
                    Participant__r.Last_Name__c,
                    Participant__r.Birth_Year__c,
                    Participant__r.Phone__c,
                    Participant__r.Email__c,
                    Participant__c,
                    Referral_Source__c,
                    DataControllerOrg__c,
                    Participant_Contact__c,
                    Clinical_Trial_Profile__r.Study_Code_Name__c,
                    Clinical_Trial_Profile__r.NCT_Number__c,
                    Clinical_Trial_Profile__r.CommunityTemplate__c,
                    Clinical_Trial_Profile__r.PPTemplate__c,
                    Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c,
                    Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c,
                    Clinical_Trial_Profile__r.MDM_Sponsor_Name__c,
                    Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c,
                    Clinical_Trial_Profile__r.IQVIA_Outreach__c,
                    Participant_Contact__r.IQVIA_Direct_Mail_Consent__c,
                    Participant_Contact__r.Participant_Opt_In_Status_Emails__c,
                    Participant_Contact__r.Participant_Opt_In_Status_SMS__c,
                    Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
                    Participant_Contact__r.PPM_ID__c,
                    Participant__r.Mailing_Country_Code__c,
                    Permit_Mail_Email_contact_for_this_study__c,
                    Permit_SMS_Text_for_this_study__c,
                    Permit_Voice_Text_contact_for_this_study__c,
                    Study_Direct_Mail_Consent__c,
                    Study_Phone_Consent_Time__c,
                    Study_Email_Consent_Time__c,
                    Study_SMS_Consent_Time__c,
                    Study_Direct_Mail_Consent_Time__c,
                    PPMID__c
                FROM Participant_Enrollment__c
                WHERE id IN :newList
            ];
            Map<Id, Participant_Enrollment__c> peroldMap = (Map<Id, Participant_Enrollment__c>) oldMap;
            List<Participant_Enrollment__c> eligiblePERforUCPM = new List<Participant_Enrollment__c>();
            for (Participant_Enrollment__c per : pernewList) {
                Participant_Enrollment__c oldPer = peroldMap.get(per.Id);
                if (
                    per.Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c != null &&
                    per.Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c != null &&
                    per.PPMID__c != null &&
                    (per.Permit_Voice_Text_contact_for_this_study__c !=
                    oldPer.Permit_Voice_Text_contact_for_this_study__c ||
                    per.Study_Phone_Consent_Time__c != oldPer.Study_Phone_Consent_Time__c ||
                    per.Study_Email_Consent_Time__c != oldPer.Study_Email_Consent_Time__c ||
                    per.Permit_Mail_Email_contact_for_this_study__c !=
                    oldPer.Permit_Mail_Email_contact_for_this_study__c ||
                    per.Permit_SMS_Text_for_this_study__c !=
                    oldPer.Permit_SMS_Text_for_this_study__c ||
                    per.Study_SMS_Consent_Time__c != oldPer.Study_SMS_Consent_Time__c ||
                    per.Study_Direct_Mail_Consent__c != oldPer.Study_Direct_Mail_Consent__c ||
                    per.Study_Direct_Mail_Consent_Time__c !=
                    oldPer.Study_Direct_Mail_Consent_Time__c)
                ) {
                    eligiblePERforUCPM.add(per);
                }
            }
            if (!eligiblePERforUCPM.isEmpty()) {
                createRequestBodyPER(eligiblePERforUCPM);
            }
        }
    }

    private static void createRequestBodyPER(List<Participant_Enrollment__c> eligiblePERforUCPM) {
        List<String> reqBodyString = new List<String>();
        List<id> perID = new List<id>();
        for (Participant_Enrollment__c per : eligiblePERforUCPM) {
            perID.add(per.id);
            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartObject();
            gen.writeFieldName('ParticipantData');
            gen.writeStartObject();
            gen.writeStringField('studyPPMID', string.isblank(per.PPMID__c) ? ' ' : per.PPMID__c);
            gen.writeStringField(
                'iqviaPPMID',
                string.isblank(per.Participant_Contact__r.PPM_ID__c)
                    ? ' '
                    : per.Participant_Contact__r.PPM_ID__c
            );
            gen.writeStringField(
                'sponsor',
                per.Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c
            );
            gen.writeStringField('iqviaSponsorId', 'IQVIA-Outreach');
            gen.writeStringField('study', per.Clinical_Trial_Profile__r.Study_Code_Name__c);
            gen.writeStringField(
                'nctId',
                string.isblank(per.Clinical_Trial_Profile__r.NCT_Number__c)
                    ? ' '
                    : per.Clinical_Trial_Profile__r.NCT_Number__c
            );
            gen.writeStringField(
                'otSponsorId',
                per.Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c
            );
            gen.writeStringField(
                'otPurposeId',
                per.Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c
            );
            gen.writeStringField('otCPId', ' ');
            gen.writeStringField('applicationId', per.Id);
            gen.writeDateTimeField('time', System.now());
            gen.writeStringField(
                'countryCode',
                string.isblank(per.Participant__r.Mailing_Country_Code__c)
                    ? ''
                    : per.Participant__r.Mailing_Country_Code__c
            );

            gen.writeFieldName('processingPurpose');
            // start processing purpose
            gen.writeStartArray();

            // Study consent start
            gen.writeStartObject();
            gen.writeStringField('key', 'Communication-Consents');
            gen.writeBooleanField('iqviaOrg', false);
            gen.writeFieldName('consentPurpose');

            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('key', 'email');
            gen.writeBooleanField('value', per.Permit_Mail_Email_contact_for_this_study__c);
            gen.writeEndObject();
            gen.writeStartObject();
            gen.writeStringField('key', 'phone');
            gen.writeBooleanField('value', per.Permit_Voice_Text_contact_for_this_study__c);
            gen.writeEndObject();
            gen.writeStartObject();
            gen.writeStringField('key', 'sms');
            gen.writeBooleanField('value', per.Permit_SMS_Text_for_this_study__c);
            gen.writeEndObject();
            gen.writeStartObject();
            gen.writeStringField('key', 'directMail');
            gen.writeBooleanField('value', per.Study_Direct_Mail_Consent__c);
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeEndObject();

            // Study consent end

            gen.writeEndArray();

            gen.writeFieldName('Delegates');
            //delegate start
            gen.writeStartArray();
            gen.writeEndArray();
            // end of processing purpose
            gen.writeEndObject(); // end of participant
            String requestString = gen.getAsString();
            reqBodyString.add(requestString);
        }
        if (!reqBodyString.isEmpty()) {
            callUCPMforUpdate(reqBodyString, perID);
        }
    }
    @future(callout=true)
    public static void callUCPMforUpdate(List<String> reqBodyString, List<Id> perId) {
        List<Participant_Enrollment__c> perToUpdate = new List<Participant_Enrollment__c>();
        List<IntegrationLog__c> objIntegrationLogList = new List<IntegrationLog__c>();
        try {
            List<ParticipantData> respPart = new List<ParticipantData>();

            List<Delegates> respDelg = new List<Delegates>();
            String accessToken;
            accessToken = getAccessToken();
            for (String requestString : reqBodyString) {
                //Call Mulesoft-UCPM API for consents
                HTTP h = new HTTP();
                HTTPRequest r = new HTTPRequest();
                r.setEndpoint('callout:UCPM_Post_Consent');
                r.setHeader('Content-Type', 'application/json;charset=UTF-8');
                r.setMethod('PUT');
                r.setHeader('Authorization', 'Bearer ' + accessToken);
                r.setbody(requestString);

                // UPDATE DETAILS
                r.setHeader('identityType', 'PARTICIPANT');
                r.setHeader('source', 'RH');
                r.setHeader('transactionId', MulesoftIntegrationApi.uniqueKeygeneration());
                r.setTimeout(120000);
                HTTPResponse resp = h.send(r);
                System.debug('###### resp ' + resp);
                System.debug('###### resp body  ' + resp.getBody());

                //Create IntegrationLog__c for monitoring purpose
                IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
                objIntegrationLog.Request_Body__c = requestString;
                objIntegrationLog.Request_Time__c = system.now();
                objIntegrationLog.Request_Type__c = 'Update PPMID in UCPM from PER Trigger';
                objIntegrationLog.Function_Name__c = 'UCPM_ConsentPostController.postconsentUCPMdata';
                objIntegrationLog.Http_Method__c = 'PUT';
                objIntegrationLog.Endpoint_URL__c = 'callout:UCPM_Post_Consent';

                if (resp.getStatusCode() == 200) {
                    objIntegrationLog.Success__c = true;
                    objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();
                    objIntegrationLog.Response_Body__c = resp.getBody();
                    objIntegrationLog.Response_Time__c = system.now();
                    List<ResponseWrapper> deserializedResponseWrapper = (List<ResponseWrapper>) JSON.deserialize(
                        resp.getBody(),
                        List<ResponseWrapper>.class
                    );
                    if (deserializedResponseWrapper != null) {
                        if (deserializedResponseWrapper[0].ParticipantData != null)
                            respPart = deserializedResponseWrapper[0].ParticipantData;

                        if (deserializedResponseWrapper[0].Delegates != null)
                            respDelg = deserializedResponseWrapper[0].Delegates;

                        if (!respPart.isEmpty()) {
                            for (ParticipantData partData : respPart) {
                                Participant_Enrollment__c perRef = new Participant_Enrollment__c();
                                if (partData.status == 'success') {
                                    perRef.Id = partData.applicationId;
                                    perRef.UCPM_Status__c = 'Completed';
                                    if (!perToUpdate.contains(perRef)) {
                                        perToUpdate.add(perRef);
                                    }
                                } else if (partData.status != 'success') {
                                    perRef.Id = partData.applicationId;
                                    perRef.UCPM_Status__c = 'Failed';
                                    perRef.UCPM_Error_Message__c =
                                        partData.message + partData.transactionId;
                                    if (!perToUpdate.contains(perRef)) {
                                        perToUpdate.add(perRef);
                                    }
                                }
                            }
                        }
                    }
                } else {
                    List<Participant_Enrollment__c> per = [
                        SELECT id, UCPM_Status__c, UCPM_Error_Message__c
                        FROM Participant_Enrollment__c
                        WHERE id IN :perId
                    ];
                    for (Participant_Enrollment__c partData : per) {
                        Participant_Enrollment__c perRef = new Participant_Enrollment__c();
                        perRef.Id = partData.id;
                        perRef.UCPM_Status__c = 'Failed';
                        perRef.UCPM_Error_Message__c = resp.getBody();
                        if (!perToUpdate.contains(perRef)) {
                            perToUpdate.add(perRef);
                        }
                    }
                    objIntegrationLog.Success__c = false;
                    objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();
                    objIntegrationLog.Response_Body__c = resp.getBody();
                    objIntegrationLog.Response_Time__c = system.now();
                }
                objIntegrationLogList.add(objIntegrationLog);
                //insert objIntegrationLog;
            }
        } catch (Exception e) {
            System.debug('e.getMessage(): ' + e.getMessage());
            System.debug('e.getStackTraceString(): ' + e.getStackTraceString());
            IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
            objIntegrationLog.Response_Body__c = e.getMessage() + ' ' + e.getStackTraceString();
            objIntegrationLog.Request_Time__c = system.now();
            objIntegrationLog.Request_Type__c = 'Create PPMID in UCPM-Exception PER Trigger ';
            objIntegrationLog.Function_Name__c = 'UCPM_ConsentPostController.postconsentUCPMdata';
            objIntegrationLog.Http_Method__c = 'POST';
            objIntegrationLog.Endpoint_URL__c = 'callout:UCPM_Post_Consent';
            objIntegrationLogList.add(objIntegrationLog);
            //insert objIntegrationLog;
            List<Participant_Enrollment__c> per = [
                SELECT id, UCPM_Status__c, UCPM_Error_Message__c
                FROM Participant_Enrollment__c
                WHERE id IN :perId
            ];
            for (Participant_Enrollment__c partData : per) {
                Participant_Enrollment__c perRef = new Participant_Enrollment__c();
                perRef.Id = partData.id;
                perRef.UCPM_Status__c = 'Failed';
                perRef.UCPM_Error_Message__c = e.getMessage() + ' ' + e.getStackTraceString();
                if (!perToUpdate.contains(perRef)) {
                    perToUpdate.add(perRef);
                }
            }
        }
        if (!objIntegrationLogList.isEmpty()) {
            insert objIntegrationLogList;
        }
        if (!perToUpdate.isEmpty()) {
            TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                PENotificationTriggerHandler.SendEmailIfSSWasChanged.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.SendFOVtoAPI.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.UnenrollorCancelPer.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.UpdateParticipantInitialVisit.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CreateMissingStatuses.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.EcoaEvents.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.DefaultEcoaTask.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.StudyConsentTimestamps.class
            );

            TriggerHandlerExecutor.bypassHandler(
                PatientDelegateEnrolTriggerHandler.updateConsentTimeStamps.class
            );
            update perToUpdate;
        }
    }
    public class updateConsentPDERtoUCPM extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            List<Patient_Delegate_Enrollment__c> eligiblePDERforUCPM = new List<Patient_Delegate_Enrollment__c>();

            List<Patient_Delegate_Enrollment__c> pdernewList = [
                SELECT
                    Id,
                    Patient_Delegate__c,
                    Patient_Delegate__r.Participant_Delegate__r.Mailing_Country_Code__c,
                    Patient_Delegate__r.Participant_Delegate__r.Id,
                    Patient_Delegate__r.Participant_Delegate__r.First_Name__c,
                    Patient_Delegate__r.Participant_Delegate__r.Last_Name__c,
                    Patient_Delegate__r.Participant_Delegate__r.Email__c,
                    Patient_Delegate__r.Participant_Delegate__r.Phone__c,
                    Patient_Delegate__r.Participant_Delegate__r.Birth_Year__c,
                    Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                    Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_SMS__c,
                    Patient_Delegate__r.Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
                    Patient_Delegate__r.Contact__r.IQVIA_Direct_Mail_Consent__c,
                    Participant_Enrollment__r.Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c,
                    Participant_Enrollment__r.Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c,
                    Participant_Enrollment__r.Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c,
                    Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                    Participant_Enrollment__r.Clinical_Trial_Profile__r.NCT_Number__c,
                    Participant_Enrollment__r.PPMID__c,
                    Participant_Enrollment__r.Participant_Contact__r.PPM_ID__c,
                    Participant_Enrollment__r.id,
                    Participant_Enrollment__r.Participant__r.Mailing_Country_Code__c,
                    Study_Phone_Consent__c,
                    Study_Email_Consent__c,
                    Study_SMS_Consent__c,
                    Study_Direct_Mail_Consent__c,
                    Study_Phone_Consent_Time__c,
                    Study_Email_Consent_Time__c,
                    Study_SMS_Consent_Time__c,
                    Study_Direct_Mail_Consent_Time__c,
                    Status__c,
                    PPM_ID__c,
                    Primary_Delegate__c,
                    Patient_Delegate__r.Contact__r.PPM_ID__c
                FROM Patient_Delegate_Enrollment__c
                WHERE ID IN :newList
            ];
            Map<Id, Patient_Delegate_Enrollment__c> pderoldMap = (Map<Id, Patient_Delegate_Enrollment__c>) oldMap;
            for (Patient_Delegate_Enrollment__c pder : pdernewList) {
                Patient_Delegate_Enrollment__c oldPder = pderoldMap.get(pder.Id);
                if (
                    pder.Participant_Enrollment__r.Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c !=
                    null &&
                    pder.Participant_Enrollment__r.Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c !=
                    null &&
                    pder.PPM_ID__c != null &&
                    (pder.Study_Phone_Consent__c != oldPder.Study_Phone_Consent__c ||
                    pder.Study_Phone_Consent_Time__c != oldPder.Study_Phone_Consent_Time__c ||
                    pder.Study_Email_Consent__c != oldPder.Study_Email_Consent__c ||
                    pder.Study_Email_Consent_Time__c != oldPder.Study_Email_Consent_Time__c ||
                    pder.Study_SMS_Consent__c != oldPder.Study_SMS_Consent__c ||
                    pder.Study_SMS_Consent_Time__c != oldPder.Study_SMS_Consent_Time__c ||
                    pder.Study_Direct_Mail_Consent__c != oldPder.Study_Direct_Mail_Consent__c ||
                    pder.Study_Direct_Mail_Consent_Time__c !=
                    oldPder.Study_Direct_Mail_Consent_Time__c)
                ) {
                    eligiblePDERforUCPM.add(pder);
                }
            }
            if (!eligiblePDERforUCPM.isEmpty()) {
                createRequestBodyPDER(eligiblePDERforUCPM);
            }
        }
    }

    private static void createRequestBodyPDER(
        List<Patient_Delegate_Enrollment__c> eligiblePDERforUCPM
    ) {
        Map<Participant_Enrollment__c, List<Patient_Delegate_Enrollment__c>> mapofPERtoPDER = new Map<Participant_Enrollment__c, List<Patient_Delegate_Enrollment__c>>();
        List<String> reqBodyString = new List<String>();
        List<id> pderID = new List<id>();

        for (Patient_Delegate_Enrollment__c pder : eligiblePDERforUCPM) {
            if (!mapofPERtoPDER.containsKey(pder.Participant_Enrollment__r)) {
                mapofPERtoPDER.put(
                    pder.Participant_Enrollment__r,
                    new List<Patient_Delegate_Enrollment__c>{ pder }
                );
            } else {
                mapofPERtoPDER.get(pder.Participant_Enrollment__r)
                    .addAll(new List<Patient_Delegate_Enrollment__c>{ pder });
            }
        }

        for (Participant_Enrollment__c per : mapofPERtoPDER.keySet()) {
            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartObject();
            gen.writeFieldName('ParticipantData');
            gen.writeStartObject();
            gen.writeStringField('studyPPMID', string.isblank(per.PPMID__c) ? ' ' : per.PPMID__c);
            gen.writeStringField(
                'iqviaPPMID',
                string.isblank(per.Participant_Contact__r.PPM_ID__c)
                    ? ' '
                    : per.Participant_Contact__r.PPM_ID__c
            );
            gen.writeStringField(
                'sponsor',
                per.Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c
            );
            gen.writeStringField('iqviaSponsorId', 'IQVIA-Outreach');
            gen.writeStringField('study', per.Clinical_Trial_Profile__r.Study_Code_Name__c);
            gen.writeStringField(
                'nctId',
                string.isblank(per.Clinical_Trial_Profile__r.NCT_Number__c)
                    ? ' '
                    : per.Clinical_Trial_Profile__r.NCT_Number__c
            );
            gen.writeStringField(
                'otSponsorId',
                per.Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c
            );
            gen.writeStringField(
                'otPurposeId',
                per.Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c
            );
            gen.writeStringField('otCPId', ' ');
            gen.writeStringField('applicationId', per.Id);
            gen.writeDateTimeField('time', System.now());
            gen.writeStringField(
                'countryCode',
                string.isblank(per.Participant__r.Mailing_Country_Code__c)
                    ? ''
                    : per.Participant__r.Mailing_Country_Code__c
            );

            gen.writeFieldName('processingPurpose');
            // start processing purpose
            gen.writeStartArray();
            gen.writeEndArray();
            // end of processing purpose
            gen.writeEndObject();

            //
            //Delegates
            gen.writeFieldName('Delegates');
            //delegate start
            gen.writeStartArray();
            for (Patient_Delegate_Enrollment__c pder : mapofPERtoPDER.get(per)) {
                System.debug('here: ' + mapofPERtoPDER.get(per));
                pderID.add(pder.id);
                gen.writeStartObject();
                gen.writeStringField(
                    'studyPPMID',
                    string.isblank(pder.PPM_ID__c) ? ' ' : pder.PPM_ID__c
                );
                gen.writeStringField(
                    'iqviaPPMID',
                    string.isblank(pder.Patient_Delegate__r.Contact__r.PPM_ID__c)
                        ? ' '
                        : pder.Patient_Delegate__r.Contact__r.PPM_ID__c
                );

                gen.writeStringField(
                    'sponsor',
                    per.Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c
                );
                gen.writeStringField('iqviaSponsorId', 'IQVIA-Outreach');
                gen.writeStringField('study', per.Clinical_Trial_Profile__r.Study_Code_Name__c);
                gen.writeStringField(
                    'nctId',
                    string.isblank(per.Clinical_Trial_Profile__r.NCT_Number__c)
                        ? ' '
                        : per.Clinical_Trial_Profile__r.NCT_Number__c
                );
                gen.writeStringField(
                    'otSponsorId',
                    per.Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c
                );
                gen.writeStringField(
                    'otPurposeId',
                    per.Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c
                );
                gen.writeStringField('otCPId', ' ');
                gen.writeStringField('applicationId', pder.Id);
                gen.writeBooleanField('isPrimary', pder.Primary_Delegate__c ? true : false);
                gen.writeBooleanField('isActive', pder.Status__c == 'Active' ? true : false);
                gen.writeStringField(
                    'countryCode',
                    string.isblank(
                            pder.Patient_Delegate__r.Participant_Delegate__r.Mailing_Country_Code__c
                        )
                        ? ''
                        : pder.Patient_Delegate__r.Participant_Delegate__r.Mailing_Country_Code__c
                );
                gen.writeDateTimeField('time', System.now());
                gen.writeFieldName('processingPurpose');
                // prcessinf start
                gen.writeStartArray();
                gen.writeStartObject();
                gen.writeStringField('key', 'Communication-Consents');
                gen.writeBooleanField('iqviaOrg', false);
                gen.writeFieldName('consentPurpose');

                gen.writeStartArray();
                gen.writeStartObject();
                gen.writeStringField('key', 'email');
                gen.writeBooleanField('value', pder.Study_Email_Consent__c);
                gen.writeEndObject();
                gen.writeStartObject();
                gen.writeStringField('key', 'phone');
                gen.writeBooleanField('value', pder.Study_Phone_Consent__c);
                gen.writeEndObject();
                gen.writeStartObject();
                gen.writeStringField('key', 'sms');
                gen.writeBooleanField('value', pder.Study_SMS_Consent__c);
                gen.writeEndObject();
                gen.writeStartObject();
                gen.writeStringField('key', 'directMail');
                gen.writeBooleanField('value', pder.Study_Direct_Mail_Consent__c);
                gen.writeEndObject();
                gen.writeEndArray();
                gen.writeEndObject();
                gen.writeEndArray();
                // procesing end

                gen.writeEndObject();
            }
            gen.writeEndArray();
            //
            gen.writeEndObject();
            String requestString = gen.getAsString();
            reqBodyString.add(requestString);
        }
        if (!reqBodyString.isEmpty()) {
            callUCPMforUpdatePDER(reqBodyString, pderID);
        }
    }

    @future(callout=true)
    public static void callUCPMforUpdatePDER(List<String> reqBodyString, List<Id> pderID) {
        List<IntegrationLog__c> objIntegrationLogList = new List<IntegrationLog__c>();
        List<Participant_Enrollment__c> perToUpdate = new List<Participant_Enrollment__c>();
        List<Patient_Delegate_Enrollment__c> pderToUpdate = new List<Patient_Delegate_Enrollment__c>();
        try {
            Patient_Delegate_Enrollment__c pderRef = new Patient_Delegate_Enrollment__c();

            List<Contact> conToUpdate = new List<Contact>();

            List<Contact> contactToUpdate = new List<Contact>();
            List<ParticipantData> respPart = new List<ParticipantData>();
            List<Delegates> respDelg = new List<Delegates>();

            System.debug('@@   ');
            //List<ResponseWrapper> responsWrap;
            String accessToken;
            accessToken = getAccessToken();
            //System.debug('accessToken@@'+accessToken);

            //Call Mulesoft-UCPM API for consents
            for (String requestString : reqBodyString) {
                HTTP h = new HTTP();
                HTTPRequest r = new HTTPRequest();
                r.setEndpoint('callout:UCPM_Post_Consent');
                r.setHeader('Content-Type', 'application/json;charset=UTF-8');
                r.setMethod('PUT');
                r.setHeader('Authorization', 'Bearer ' + accessToken);
                r.setbody(requestString);

                // UPDATE DETAILS
                r.setHeader('identityType', 'DELEGATE');
                r.setHeader('source', 'RH');
                r.setHeader('transactionId', MulesoftIntegrationApi.uniqueKeygeneration());
                r.setTimeout(120000);
                HTTPResponse resp = h.send(r);
                System.debug('###### resp ' + resp);
                System.debug('###### resp body  ' + resp.getBody());

                //Create IntegrationLog__c for monitoring purpose

                IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
                objIntegrationLog.Request_Body__c = requestString;
                objIntegrationLog.Request_Time__c = system.now();
                objIntegrationLog.Request_Type__c = 'Update PPMID in UCPM from PDER trigger';
                objIntegrationLog.Function_Name__c = 'UCPM_ConsentPostController.postconsentUCPMdata';
                objIntegrationLog.Http_Method__c = 'PUT';
                objIntegrationLog.Endpoint_URL__c = 'callout:UCPM_Post_Consent';
                objIntegrationLog.Response_Body__c = resp.getBody();

                if (resp.getStatusCode() == 200) {
                    objIntegrationLog.Success__c = true;
                    objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();

                    objIntegrationLog.Response_Time__c = system.now();
                    List<ResponseWrapperDelegate> deserializedResponseWrapper = (List<ResponseWrapperDelegate>) JSON.deserialize(
                        resp.getBody(),
                        List<ResponseWrapperDelegate>.class
                    );

                    if (deserializedResponseWrapper != null) {
                        for (ResponseWrapperDelegate dw : deserializedResponseWrapper) {
                            for (Delegates del : dw.Delegates) {
                                respDelg.add(del);
                            }
                        }

                        for (Delegates delgData : respDelg) {
                            if (delgData.status == 'success') {
                                Patient_Delegate_Enrollment__c pder = new Patient_Delegate_Enrollment__c();
                                pder.id = id.valueof(delgData.applicationId);
                                pder.UCPM_Status__c = 'Completed';
                                if (!pderToUpdate.contains(pder)) {
                                    pderToUpdate.add(pder);
                                }
                            } else {
                                Patient_Delegate_Enrollment__c pder = new Patient_Delegate_Enrollment__c();
                                pder.Id = delgData.applicationId;
                                pder.UCPM_Status__c = 'Failed';
                                pder.UCPM_Error_Message__c =
                                    delgData.message + delgData.transactionId;
                                if (!pderToUpdate.contains(pder)) {
                                    pderToUpdate.add(pder);
                                }
                            }
                        }
                    }
                } else {
                    objIntegrationLog.Success__c = false;
                    objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();
                    objIntegrationLog.Response_Body__c = resp.getBody();
                    objIntegrationLog.Response_Time__c = system.now();
                    List<Patient_Delegate_Enrollment__c> per = [
                        SELECT id, UCPM_Status__c, UCPM_Error_Message__c
                        FROM Patient_Delegate_Enrollment__c
                        WHERE id IN :pderID
                    ];
                    for (Patient_Delegate_Enrollment__c partData : per) {
                        Patient_Delegate_Enrollment__c pder = new Patient_Delegate_Enrollment__c();
                        pder.Id = partData.id;
                        pder.UCPM_Status__c = 'Failed';
                        pder.UCPM_Error_Message__c = resp.getBody();
                        if (!pderToUpdate.contains(pder)) {
                            pderToUpdate.add(pder);
                        }
                    }
                }
                objIntegrationLogList.add(objIntegrationLog);
            }
        } catch (Exception e) {
            System.debug('e.getMessage(): ' + e.getMessage());
            System.debug('e.getStackTraceString(): ' + e.getStackTraceString());
            IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
            objIntegrationLog.Response_Body__c = e.getMessage() + ' ' + e.getStackTraceString();
            objIntegrationLog.Request_Time__c = system.now();
            objIntegrationLog.Request_Type__c = 'Update PPMID in UCPM-Exception in PDER Trigger';
            objIntegrationLog.Function_Name__c = 'UCPM_ConsentPostController.postconsentUCPMdata';
            objIntegrationLog.Http_Method__c = 'PUT';
            objIntegrationLog.Endpoint_URL__c = 'callout:UCPM_Post_Consent';
            objIntegrationLogList.add(objIntegrationLog);
            List<Patient_Delegate_Enrollment__c> per = [
                SELECT id, UCPM_Status__c, UCPM_Error_Message__c
                FROM Patient_Delegate_Enrollment__c
                WHERE id IN :pderID
            ];
            for (Patient_Delegate_Enrollment__c partData : per) {
                Patient_Delegate_Enrollment__c pder = new Patient_Delegate_Enrollment__c();
                pder.Id = partData.id;
                pder.UCPM_Status__c = 'Failed';
                pder.UCPM_Error_Message__c = e.getMessage() + ' ' + e.getStackTraceString();
                if (!pderToUpdate.contains(pder)) {
                    pderToUpdate.add(pder);
                }
            }
        }
        if (!objIntegrationLogList.isEmpty()) {
            insert objIntegrationLogList;
        }
        if (!pderToUpdate.isEmpty()) {
            TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                PENotificationTriggerHandler.SendEmailIfSSWasChanged.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.SendFOVtoAPI.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.UnenrollorCancelPer.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.UpdateParticipantInitialVisit.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CreateMissingStatuses.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.EcoaEvents.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.DefaultEcoaTask.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.StudyConsentTimestamps.class
            );

            TriggerHandlerExecutor.bypassHandler(
                PatientDelegateEnrolTriggerHandler.updateConsentTimeStamps.class
            );
            //database.update(pderToUpdate, false);
            if (!pderToUpdate.isEmpty()) {
                update pderToUpdate;
            }
        }
    }

    public class updateConsentContacttoUCPM extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            Set<Contact> eligibleContactforUCPM = new Set<Contact>();
            Patient_Delegate_Enrollment__c pderMatch; //= new Patient_Delegate_Enrollment__c();
            List<Contact> connewList = newList;
            Boolean isPer = false;
            Boolean isPder = false;
            Map<Id, Contact> conoldMap = (Map<Id, Contact>) oldMap;
            Map<Contact, Participant_Enrollment__c> mapofContoPER = new Map<Contact, Participant_Enrollment__c>();
            Map<Contact, Patient_Delegate_Enrollment__c> mapofContoPDER = new Map<Contact, Patient_Delegate_Enrollment__c>();
            List<Patient_Delegate_Enrollment__c> getPDERforContact = [
                SELECT
                    Id,
                    Patient_Delegate__c,
                    Patient_Delegate__r.Participant_Delegate__r.Mailing_Country_Code__c,
                    Patient_Delegate__r.Participant_Delegate__r.Id,
                    Patient_Delegate__r.Participant_Delegate__r.First_Name__c,
                    Patient_Delegate__r.Participant_Delegate__r.Last_Name__c,
                    Patient_Delegate__r.Participant_Delegate__r.Email__c,
                    Patient_Delegate__r.Participant_Delegate__r.Phone__c,
                    Patient_Delegate__r.Participant_Delegate__r.Birth_Year__c,
                    Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                    Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_SMS__c,
                    Patient_Delegate__r.Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
                    Patient_Delegate__r.Contact__r.IQVIA_Direct_Mail_Consent__c,
                    Participant_Enrollment__r.Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c,
                    Participant_Enrollment__r.Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c,
                    Participant_Enrollment__r.Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c,
                    Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                    Participant_Enrollment__r.Clinical_Trial_Profile__r.NCT_Number__c,
                    Participant_Enrollment__r.PPMID__c,
                    Participant_Enrollment__r.Participant_Contact__r.PPM_ID__c,
                    Participant_Enrollment__r.id,
                    Participant_Enrollment__r.Participant__r.Mailing_Country_Code__c,
                    Study_Phone_Consent__c,
                    Study_Email_Consent__c,
                    Study_SMS_Consent__c,
                    Study_Direct_Mail_Consent__c,
                    Study_Phone_Consent_Time__c,
                    Study_Email_Consent_Time__c,
                    Study_SMS_Consent_Time__c,
                    Study_Direct_Mail_Consent_Time__c,
                    Status__c,
                    PPM_ID__c,
                    Primary_Delegate__c,
                    Patient_Delegate__r.Contact__r.PPM_ID__c,
                    Patient_Delegate__r.Contact__r.IQVIA_Email_Consent_Time__c,
                    Patient_Delegate__r.Contact__r.IQVIA_SMS_Consent_Time__c,
                    Patient_Delegate__r.Contact__r.IQVIA_Direct_Mail_Consent_Time__c,
                    Patient_Delegate__r.Contact__r.IQVIA_Phone_Consent_Time__c
                FROM Patient_Delegate_Enrollment__c
                WHERE
                    PPM_ID__c != NULL
                    AND Patient_Delegate__r.Contact__c IN :newList
                    AND Participant_Enrollment__r.Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c != NULL
                    AND Participant_Enrollment__r.Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c != NULL
            ];
            List<Participant_Enrollment__c> getPERforContact = [
                SELECT
                    Id,
                    Participant__r.First_Name__c,
                    Participant__r.Last_Name__c,
                    Participant__r.Birth_Year__c,
                    Participant__r.Phone__c,
                    Participant__r.Email__c,
                    Participant__c,
                    Referral_Source__c,
                    DataControllerOrg__c,
                    Participant_Contact__c,
                    Participant_Contact__r.id,
                    Clinical_Trial_Profile__r.Study_Code_Name__c,
                    Clinical_Trial_Profile__r.NCT_Number__c,
                    Clinical_Trial_Profile__r.CommunityTemplate__c,
                    Clinical_Trial_Profile__r.PPTemplate__c,
                    Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c,
                    Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c,
                    Clinical_Trial_Profile__r.MDM_Sponsor_Name__c,
                    Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c,
                    Clinical_Trial_Profile__r.IQVIA_Outreach__c,
                    Participant_Contact__r.IQVIA_Direct_Mail_Consent__c,
                    Participant_Contact__r.Participant_Opt_In_Status_Emails__c,
                    Participant_Contact__r.Participant_Opt_In_Status_SMS__c,
                    Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
                    Participant_Contact__r.PPM_ID__c,
                    Participant__r.Mailing_Country_Code__c,
                    Permit_Mail_Email_contact_for_this_study__c,
                    Permit_SMS_Text_for_this_study__c,
                    Permit_Voice_Text_contact_for_this_study__c,
                    Study_Direct_Mail_Consent__c,
                    Study_Phone_Consent_Time__c,
                    Study_Email_Consent_Time__c,
                    Study_SMS_Consent_Time__c,
                    Study_Direct_Mail_Consent_Time__c,
                    PPMID__c,
                    Participant_Contact__r.IQVIA_Email_Consent_Time__c,
                    Participant_Contact__r.IQVIA_SMS_Consent_Time__c,
                    Participant_Contact__r.IQVIA_Direct_Mail_Consent_Time__c,
                    Participant_Contact__r.IQVIA_Phone_Consent_Time__c
                FROM Participant_Enrollment__c
                WHERE
                    PPMID__c != NULL
                    AND Participant_Contact__c IN :newList
                    AND Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c != NULL
                    AND Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c != NULL
            ];

            if (!getPERforContact.isEmpty()) {
                for (Participant_Enrollment__c per : getPERforContact) {
                    if (!mapofContoPER.containsKey(per.Participant_Contact__r)) {
                        mapofContoPER.put(per.Participant_Contact__r, per); //c1, per1
                    }
                }
            }

            if (!getPDERforContact.isEmpty()) {
                for (Patient_Delegate_Enrollment__c pder : getPDERforContact) {
                    if (!mapofContoPDER.containsKey(pder.Patient_Delegate__r.Contact__r)) {
                        mapofContoPDER.put(pder.Patient_Delegate__r.Contact__r, pder); // c2, pder1
                    }
                }
            }
            for (Contact con : mapofContoPER.KeySet()) {
                Participant_Enrollment__c per = new Participant_Enrollment__c();
                per = mapofContoPER.get(con);
                Contact oldCon = conoldMap.get(con.Id);
                if (mapofContoPER.containsKey(con)) {
                    mapofContoPDER.remove(con);
                }
                if (
                    per.Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c != null &&
                    per.Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c != null &&
                    con.PPM_ID__c != null &&
                    (con.IQVIA_Phone_Consent_Time__c != oldCon.IQVIA_Phone_Consent_Time__c ||
                    con.Participant_Phone_Opt_In_Permit_Phone__c !=
                    oldCon.Participant_Phone_Opt_In_Permit_Phone__c ||
                    con.Participant_Opt_In_Status_Emails__c !=
                    oldCon.Participant_Opt_In_Status_Emails__c ||
                    con.IQVIA_Email_Consent_Time__c != oldCon.IQVIA_Email_Consent_Time__c ||
                    con.Participant_Opt_In_Status_SMS__c !=
                    oldCon.Participant_Opt_In_Status_SMS__c ||
                    con.IQVIA_SMS_Consent_Time__c != oldCon.IQVIA_SMS_Consent_Time__c ||
                    con.IQVIA_Direct_Mail_Consent__c != oldCon.IQVIA_Direct_Mail_Consent__c ||
                    con.IQVIA_Direct_Mail_Consent_Time__c !=
                    oldCon.IQVIA_Direct_Mail_Consent_Time__c)
                ) {
                    eligibleContactforUCPM.add(con);
                }
            }
            for (Contact con : mapofContoPDER.KeySet()) {
                Patient_Delegate_Enrollment__c pder = new Patient_Delegate_Enrollment__c();
                pder = mapofContoPDER.get(con);
                Contact oldCon = conoldMap.get(con.Id);
                if (
                    pder.Participant_Enrollment__r.Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c !=
                    null &&
                    pder.Participant_Enrollment__r.Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c !=
                    null &&
                    con.PPM_ID__c != null &&
                    (con.IQVIA_Phone_Consent_Time__c != oldCon.IQVIA_Phone_Consent_Time__c ||
                    con.Participant_Phone_Opt_In_Permit_Phone__c !=
                    oldCon.Participant_Phone_Opt_In_Permit_Phone__c ||
                    con.Participant_Opt_In_Status_Emails__c !=
                    oldCon.Participant_Opt_In_Status_Emails__c ||
                    con.IQVIA_Email_Consent_Time__c != oldCon.IQVIA_Email_Consent_Time__c ||
                    con.Participant_Opt_In_Status_SMS__c !=
                    oldCon.Participant_Opt_In_Status_SMS__c ||
                    con.IQVIA_SMS_Consent_Time__c != oldCon.IQVIA_SMS_Consent_Time__c ||
                    con.IQVIA_Direct_Mail_Consent__c != oldCon.IQVIA_Direct_Mail_Consent__c ||
                    con.IQVIA_Direct_Mail_Consent_Time__c !=
                    oldCon.IQVIA_Direct_Mail_Consent_Time__c)
                ) {
                    eligibleContactforUCPM.add(con);
                }
            }

            List<String> reqString = new List<String>();
            List<id> conID = new List<id>();
            Map<String, String> reqStringtoIdentitytype = new Map<String, String>();
            if (!eligibleContactforUCPM.isEmpty()) {
                for (Contact con : eligibleContactforUCPM) {
                    conID.add(con.id);
                    if (mapofContoPER.containsKey(con)) {
                        String s = createRequestBodyContact(con, mapofContoPER.get(con), null);
                        reqStringtoIdentitytype.put(s, 'PARTICIPANT');
                    } else if (mapofContoPDER.containsKey(con)) {
                        String s = createRequestBodyContact(con, null, mapofContoPDER.get(con));
                        reqStringtoIdentitytype.put(s, 'DELEGATE');
                    }
                }
            }
            if (!reqStringtoIdentitytype.isEmpty()) {
                callUCPMforUpdateContact(reqStringtoIdentitytype, conID);
            }
        }
    }
    private static String createRequestBodyContact(
        Contact con,
        Participant_Enrollment__c per,
        Patient_Delegate_Enrollment__c pder
    ) {
        List<String> reqBodyString = new List<String>();
        List<id> perID = new List<id>();
        if (per != null) {
            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartObject();
            gen.writeFieldName('ParticipantData');
            gen.writeStartObject();
            gen.writeStringField('studyPPMID', string.isblank(per.PPMID__c) ? ' ' : per.PPMID__c);
            gen.writeStringField(
                'iqviaPPMID',
                string.isblank(per.Participant_Contact__r.PPM_ID__c)
                    ? ' '
                    : per.Participant_Contact__r.PPM_ID__c
            );
            gen.writeStringField(
                'sponsor',
                per.Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c
            );
            gen.writeStringField('iqviaSponsorId', 'IQVIA-Outreach');
            gen.writeStringField('study', per.Clinical_Trial_Profile__r.Study_Code_Name__c);
            gen.writeStringField(
                'nctId',
                string.isblank(per.Clinical_Trial_Profile__r.NCT_Number__c)
                    ? ' '
                    : per.Clinical_Trial_Profile__r.NCT_Number__c
            );
            gen.writeStringField(
                'otSponsorId',
                per.Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c
            );
            gen.writeStringField(
                'otPurposeId',
                per.Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c
            );
            gen.writeStringField('otCPId', ' ');
            gen.writeStringField('applicationId', per.Id);
            gen.writeDateTimeField('time', System.now());
            gen.writeStringField(
                'countryCode',
                string.isblank(per.Participant__r.Mailing_Country_Code__c)
                    ? ''
                    : per.Participant__r.Mailing_Country_Code__c
            );

            gen.writeFieldName('processingPurpose');
            // start processing purpose
            gen.writeStartArray();
            
            gen.writeStartObject();
            gen.writeStringField('key', 'IQVIA-Outreach-Consents');
            gen.writeBooleanField('iqviaOrg', true);
            gen.writeFieldName('consentPurpose');

            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('key', 'email');
            gen.writeBooleanField('value', con.Participant_Opt_In_Status_Emails__c);
            gen.writeEndObject();
            gen.writeStartObject();
            gen.writeStringField('key', 'phone');
            gen.writeBooleanField('value', con.Participant_Phone_Opt_In_Permit_Phone__c);
            gen.writeEndObject();
            gen.writeStartObject();
            gen.writeStringField('key', 'sms');
            gen.writeBooleanField('value', con.Participant_Opt_In_Status_SMS__c);
            gen.writeEndObject();
            gen.writeStartObject();
            gen.writeStringField('key', 'directMail');
            gen.writeBooleanField('value', con.IQVIA_Direct_Mail_Consent__c);
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeEndObject();
            //}
            // }
            // gen.writeEndArray();
            gen.writeEndArray();
            // end of processing purpose
            gen.writeEndObject(); // end of participant

            gen.writeFieldName('Delegates');
            //delegate start
            gen.writeStartArray();
            gen.writeEndArray();
            // end of processing purpose
            String requestString = gen.getAsString();
            reqBodyString.add(requestString);
            return requestString;
        } else if (pder != null) {
            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartObject();
            gen.writeFieldName('ParticipantData');
            gen.writeStartObject();
            gen.writeStringField(
                'studyPPMID',
                string.isblank(pder.Participant_Enrollment__r.PPMID__c)
                    ? ' '
                    : pder.Participant_Enrollment__r.PPMID__c
            );
            gen.writeStringField(
                'iqviaPPMID',
                string.isblank(pder.Participant_Enrollment__r.Participant_Contact__r.PPM_ID__c)
                    ? ' '
                    : pder.Participant_Enrollment__r.Participant_Contact__r.PPM_ID__c
            );
            gen.writeStringField(
                'sponsor',
                pder.Participant_Enrollment__r.Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c
            );
            gen.writeStringField('iqviaSponsorId', 'IQVIA-Outreach');
            gen.writeStringField(
                'study',
                pder.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c
            );
            gen.writeStringField(
                'nctId',
                string.isblank(
                        pder.Participant_Enrollment__r.Clinical_Trial_Profile__r.NCT_Number__c
                    )
                    ? ' '
                    : pder.Participant_Enrollment__r.Clinical_Trial_Profile__r.NCT_Number__c
            );
            gen.writeStringField(
                'otSponsorId',
                pder.Participant_Enrollment__r.Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c
            );
            gen.writeStringField(
                'otPurposeId',
                pder.Participant_Enrollment__r.Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c
            );
            gen.writeStringField('otCPId', ' ');
            gen.writeStringField('applicationId', pder.Participant_Enrollment__r.Id);
            gen.writeDateTimeField('time', System.now());
            gen.writeStringField(
                'countryCode',
                string.isblank(
                        pder.Participant_Enrollment__r.Participant__r.Mailing_Country_Code__c
                    )
                    ? ''
                    : pder.Participant_Enrollment__r.Participant__r.Mailing_Country_Code__c
            );

            gen.writeFieldName('processingPurpose');
            // start processing purpose
            gen.writeStartArray();
            gen.writeEndArray();
            // end of processing purpose
            gen.writeEndObject();

            //
            //Delegates
            gen.writeFieldName('Delegates');
            //delegate start
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField(
                'studyPPMID',
                string.isblank(pder.PPM_ID__c) ? ' ' : pder.PPM_ID__c
            );
            gen.writeStringField(
                'iqviaPPMID',
                string.isblank(pder.Patient_Delegate__r.Contact__r.PPM_ID__c)
                    ? ' '
                    : pder.Patient_Delegate__r.Contact__r.PPM_ID__c
            );

            gen.writeStringField(
                'sponsor',
                pder.Participant_Enrollment__r.Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c
            );
            gen.writeStringField('iqviaSponsorId', 'IQVIA-Outreach');
            gen.writeStringField(
                'study',
                pder.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c
            );
            gen.writeStringField(
                'nctId',
                string.isblank(
                        pder.Participant_Enrollment__r.Clinical_Trial_Profile__r.NCT_Number__c
                    )
                    ? ' '
                    : pder.Participant_Enrollment__r.Clinical_Trial_Profile__r.NCT_Number__c
            );
            gen.writeStringField(
                'otSponsorId',
                pder.Participant_Enrollment__r.Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c
            );
            gen.writeStringField(
                'otPurposeId',
                pder.Participant_Enrollment__r.Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c
            );
            gen.writeStringField('otCPId', ' ');
            gen.writeStringField('applicationId', pder.Id);
            gen.writeBooleanField('isPrimary', pder.Primary_Delegate__c ? true : false);
            gen.writeBooleanField('isActive', pder.Status__c == 'Active' ? true : false);
            gen.writeStringField(
                'countryCode',
                string.isblank(
                        pder.Patient_Delegate__r.Participant_Delegate__r.Mailing_Country_Code__c
                    )
                    ? ''
                    : pder.Patient_Delegate__r.Participant_Delegate__r.Mailing_Country_Code__c
            );
            gen.writeDateTimeField('time', System.now());
            gen.writeFieldName('processingPurpose');
            // prcessing start
            gen.writeStartArray();
            // gen.writeEndArray();
            // procesing end

            //gen.writeEndObject();
            
            gen.writeStartObject();
            gen.writeStringField('key', 'IQVIA-Outreach-Consents');
            gen.writeBooleanField('iqviaOrg', true);
            gen.writeFieldName('consentPurpose');

            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('key', 'email');
            gen.writeBooleanField('value', con.Participant_Opt_In_Status_Emails__c);
            gen.writeEndObject();
            gen.writeStartObject();
            gen.writeStringField('key', 'phone');
            gen.writeBooleanField('value', con.Participant_Phone_Opt_In_Permit_Phone__c);
            gen.writeEndObject();
            gen.writeStartObject();
            gen.writeStringField('key', 'sms');
            gen.writeBooleanField('value', con.Participant_Opt_In_Status_SMS__c);
            gen.writeEndObject();
            gen.writeStartObject();
            gen.writeStringField('key', 'directMail');
            gen.writeBooleanField('value', con.IQVIA_Direct_Mail_Consent__c);
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeEndObject();
            // }
            // IQVIA consent end
            gen.writeEndArray();
            //
            gen.writeEndObject();
            String requestString = gen.getAsString();

            reqBodyString.add(requestString);
            System.debug('reqBodyString pder : ' + reqBodyString);

            return requestString;
        }
        return '';

       
    }
    @future(callout=true)
    public static void callUCPMforUpdateContact(
        Map<String, string> reqBodyString,
        List<Id> conID
    ) {
        List<IntegrationLog__c> objIntegrationLogList = new List<IntegrationLog__c>();
        List<Contact> contactToUpdate = new List<Contact>();
        List<Contact> conToUpdate = new List<Contact>();
        try {
            Patient_Delegate_Enrollment__c pderRef = new Patient_Delegate_Enrollment__c();
            List<Participant_Enrollment__c> perToUpdate = new List<Participant_Enrollment__c>();

            List<Patient_Delegate_Enrollment__c> pderToUpdate = new List<Patient_Delegate_Enrollment__c>();

            List<ParticipantData> respPart = new List<ParticipantData>();
            List<Delegates> respDelg = new List<Delegates>();

            String accessToken;
            accessToken = getAccessToken();

            //Call Mulesoft-UCPM API for consents
            for (String requestString : reqBodyString.keySet()) {
                HTTP h = new HTTP();
                HTTPRequest r = new HTTPRequest();
                r.setEndpoint('callout:UCPM_Post_Consent');
                r.setHeader('Content-Type', 'application/json;charset=UTF-8');
                r.setMethod('PUT');
                r.setHeader('Authorization', 'Bearer ' + accessToken);
                r.setbody(requestString);

                // UPDATE DETAILS
                r.setHeader('identityType', reqBodyString.get(requestString));
                r.setHeader('source', 'RH');
                r.setHeader('transactionId', MulesoftIntegrationApi.uniqueKeygeneration());
                r.setTimeout(120000);
                HTTPResponse resp = h.send(r);
                System.debug('###### resp ' + resp);
                System.debug('###### resp body  ' + resp.getBody());

                //Create IntegrationLog__c for monitoring purpose

                IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
                objIntegrationLog.Request_Body__c = requestString;
                objIntegrationLog.Request_Time__c = system.now();
                objIntegrationLog.Request_Type__c = 'Update PPMID in UCPM from Contact trigger';
                objIntegrationLog.Function_Name__c = 'UCPM_ConsentPostController.postconsentUCPMdata';
                objIntegrationLog.Http_Method__c = 'PUT';
                objIntegrationLog.Endpoint_URL__c = 'callout:UCPM_Post_Consent';
                objIntegrationLog.Response_Body__c = resp.getBody();

                if (resp.getStatusCode() == 200) {
                    objIntegrationLog.Success__c = true;
                    objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();

                    objIntegrationLog.Response_Time__c = system.now();
                    List<ResponseWrapper> deserializedResponseWrapper = (List<ResponseWrapper>) JSON.deserialize(
                        resp.getBody(),
                        List<ResponseWrapper>.class
                    );

                    if (deserializedResponseWrapper != null) {
                        for (ResponseWrapper dw : deserializedResponseWrapper) {
                            if (deserializedResponseWrapper[0].ParticipantData != null)
                                respPart = deserializedResponseWrapper[0].ParticipantData;

                            if (deserializedResponseWrapper[0].Delegates != null)
                                respDelg = deserializedResponseWrapper[0].Delegates;
                        }


                        if (!respPart.isEmpty()) {
                            for (ParticipantData partData : respPart) {
                                if (partData.status == 'success' && partData.iqviaOrg) {
                                    Participant_Enrollment__c per = [
                                        SELECT Id, Participant_Contact__c
                                        FROM Participant_Enrollment__c
                                        WHERE Id = :partData.applicationId
                                    ];
                                    Contact con = new Contact();
                                    con.Id = per.Participant_Contact__c;
                                    con.UCPM_Status__c = 'Completed';
                                    if (!conToUpdate.contains(con)) {
                                        conToUpdate.add(con);
                                    }
                                } else if (partData.message != 'success') {
                                    Participant_Enrollment__c per = [
                                        SELECT Id, Participant_Contact__c
                                        FROM Participant_Enrollment__c
                                        WHERE Id = :partData.applicationId
                                    ];
                                    Contact con = new Contact();
                                    con.Id = per.Participant_Contact__c;
                                    con.UCPM_Status__c = 'Failed';
                                    con.UCPM_Error_Message__c =
                                        partData.message + partData.transactionId;
                                    if (!conToUpdate.contains(con)) {
                                        conToUpdate.add(con);
                                    }
                                }
                            }
                        }
                        if (!respDelg.isEmpty()) {
                            for (Delegates delgData : respDelg) {
                                if (
                                    delgData.status == 'success' &&
                                    delgData.ppmid != null &&
                                    delgData.iqviaOrg
                                ) {
                                    Patient_Delegate_Enrollment__c pder = [
                                        SELECT
                                            Id,
                                            Patient_Delegate__c,
                                            Patient_Delegate__r.Contact__c
                                        FROM Patient_Delegate_Enrollment__c
                                        WHERE Id = :delgData.applicationId
                                    ];
                                    id cond = pder.Patient_Delegate__r.Contact__c;
                                    Contact con = new Contact();
                                    con.Id = cond;
                                    con.UCPM_Status__c = 'Completed';
                                    if (!conToUpdate.contains(con)) {
                                        conToUpdate.add(con);
                                    }
                                    //conToUpdate.add(con);
                                } else if (delgData.status != 'success') {
                                    Patient_Delegate_Enrollment__c pder = [
                                        SELECT Id, Patient_Delegate__r.Contact__c
                                        FROM Patient_Delegate_Enrollment__c
                                        WHERE Id = :delgData.applicationId
                                    ];
                                    Contact con = new Contact();
                                    con.Id = pder.Patient_Delegate__r.Contact__c;
                                    con.UCPM_Status__c = 'Failed';
                                    con.UCPM_Error_Message__c =
                                        delgData.message + delgData.transactionId;
                                    if (!conToUpdate.contains(con)) {
                                        conToUpdate.add(con);
                                    }
                                }
                            }
                        }
                    }
                } else {
                    objIntegrationLog.Success__c = false;
                    objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();
                    objIntegrationLog.Response_Body__c = resp.getBody();
                    objIntegrationLog.Response_Time__c = system.now();
                    List<Contact> conList = [
                        SELECT id, UCPM_Status__c, UCPM_Error_Message__c
                        FROM Contact
                        WHERE id IN :conID
                    ];
                    for (Contact c : conList) {
                        Contact con = new Contact();
                        con.Id = c.id;
                        con.UCPM_Status__c = 'Failed';
                        con.UCPM_Error_Message__c = resp.getBody();
                        if (!conToUpdate.contains(con)) {
                            conToUpdate.add(con);
                        }
                    }
                }
                objIntegrationLogList.add(objIntegrationLog);
            }
        } catch (Exception e) {
            System.debug('e.getMessage(): ' + e.getMessage());
            System.debug('e.getStackTraceString(): ' + e.getStackTraceString());
            IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
            objIntegrationLog.Response_Body__c = e.getMessage() + ' ' + e.getStackTraceString();
            objIntegrationLog.Request_Time__c = system.now();
            objIntegrationLog.Request_Type__c = 'Update PPMID in UCPM-Exception in Comtact Trigger';
            objIntegrationLog.Function_Name__c = 'UCPM_ConsentPostController.postconsentUCPMdata';
            objIntegrationLog.Http_Method__c = 'PUT';
            objIntegrationLog.Endpoint_URL__c = 'callout:UCPM_Post_Consent';
            objIntegrationLogList.add(objIntegrationLog);
            List<Contact> conList = [
                SELECT id, UCPM_Status__c, UCPM_Error_Message__c
                FROM Contact
                WHERE id IN :conID
            ];
            for (Contact c : conList) {
                Contact con = new Contact();
                con.Id = c.id;
                con.UCPM_Status__c = 'Failed';
                con.UCPM_Error_Message__c = e.getMessage() + ' ' + e.getStackTraceString();
                if (!conToUpdate.contains(con)) {
                    conToUpdate.add(con);
                }
            }
        }
        if (!objIntegrationLogList.isEmpty()) {
            insert objIntegrationLogList;
        }
        if (!conToUpdate.isEmpty()) {
            TriggerHandlerExecutor.bypassHandler(
                ContactTriggerHandler.UpdateConsentTimeStamps.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ContactTriggerHandler.CreateUserForCCContactHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ContactTriggerHandler.PopulateOverrideFields.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ContactTriggerHandler.UpdatePhoneNumberContactsHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ContactTriggerHandler.CreateUserForDelegateContactHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ContactTriggerHandler.CreateUserForDelegateContactHandler.class
            );
            update conToUpdate;
        }
    }

    //generate mulesoft access token
    public static String getAccessToken() {
        String accessToken;
        MulesoftToken__c setting = MulesoftToken__c.getInstance(
          'Mulesoft Access Token UCPM'
        );
        Http http1 = new Http();
        HttpRequest request1 = new HttpRequest();
        request1.setEndpoint('callout:' + setting.Named_Credentials_Name__c);
        request1.setMethod('POST');
        request1.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request1.setTimeout(120000);
        String requestBody1 = 'grant_type=client_credentials';
        request1.setBody(requestBody1);
        System.debug('###### request1 ' + request1);

        HttpResponse resp1;

        try {
          resp1 = http1.send(request1);
        } catch (exception e) {
          //Integration log generation
          IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
          objIntegrationLog.Response_Body__c = e.getMessage();
          objIntegrationLog.Function_Name__c = 'Access Token';
          objIntegrationLog.Success__c = false;
          insert objIntegrationLog;
        }

        System.debug('###### resp1 ' + resp1);
        System.debug('###### resp1 ' + resp1.getBody());
        if (resp1.getStatusCode() == 200) {
          JsonParser parser = JSON.createParser(resp1.getBody());
          ResponseWrapperToken deserializedResponseWrapper = (ResponseWrapperToken) JSON.deserialize(
            resp1.getBody(),
            ResponseWrapperToken.class
          );
          accessToken = deserializedResponseWrapper.access_token;
        }
        return accessToken;
    }
    public class ResponseWrapper {
        public List<ParticipantData> ParticipantData;
        public List<Delegates> Delegates;
    }
    public class ResponseWrapperDelegate {
        // public List<ParticipantData> ParticipantData;
        public List<Delegates> Delegates;
    }
    public class ParticipantData {
        public Integer code;
        public String status;
        public String message;
        public String transactionId;
        public String applicationId;
        public String otSponsorId;
        public String otPurposeId;
        public String ppmid;
        public String sponsor;
        public String study;
        public String failedkey;
        public String timestamp;
        public Boolean iqviaOrg;
    }
    public class Delegates {
        public Integer code;
        public String status;
        public String message;
        public String transactionId;
        public String applicationId;
        public String otSponsorId;
        public String otPurposeId;
        public String ppmid;
        public String sponsor;
        public String study;
        public String failed_key;
        public String timestamp;
        public Boolean iqviaOrg;
    }
    //Response wrapper start
    public class ResponseWrapperToken {
        public String token_type;
        public String access_token;
        public Integer expires_in;
        public String message;
        public Boolean success;
        public Integer statusCode;
    }

    //Response wrapper end

    public class MapWrapper {
        public String status;
        public String message;
        public String transactionId;
    }
}