public without sharing class UCPM_ConsentPostBulkImport_Queueable implements Queueable, Database.AllowsCallouts {
    String accessToken;
    List<Id> perRecIds;
    List<Id> pDelEnrolRecIds;
    String createtypeIdentity;
    String updatetypeIdentity;
    String createrequestJSON;
    String updaterequestJSON;
    String placeOfFunctionality;
    List<IntegrationLog__c> logsToInsert = new List<IntegrationLog__c>();
    List<Contact> conToUpdate = new List<Contact>();
    List<Patient_Delegate_Enrollment__c> pderToUpdate = new List<Patient_Delegate_Enrollment__c>();
    List<Participant_Enrollment__c> perToUpdate = new List<Participant_Enrollment__c>();
    public UCPM_ConsentPostBulkImport_Queueable(
        List<Id> perIdList,
        List<Id> pderEnrolIds,
        String functionalityPlace
    ) {
        perRecIds = perIdList != null ? perIdList : null;
        pDelEnrolRecIds = pderEnrolIds != null ? pderEnrolIds : null;
        placeOfFunctionality = functionalityPlace;
    }

    public void execute(QueueableContext context) {
        fetchPerAndPderDetails(perRecIds, pDelEnrolRecIds);
    }
    public void fetchPerAndPderDetails(List<Id> perIds, List<Id> pderIds) {
        List<Participant_Enrollment__c> perList;
        Map<Participant_Enrollment__c, List<Patient_Delegate_Enrollment__c>> perandPderMap = new Map<Participant_Enrollment__c, List<Patient_Delegate_Enrollment__c>>();
        if (pderIds != null && pderIds.size() > 0 && perIds != null && perIds.size() > 0) {
            perList = [
                SELECT
                    Id,
                    Participant__r.Email__c,
                    Participant__c,
                    Referral_Source__c,
                    DataControllerOrg__c,
                    Clinical_Trial_Profile__r.Study_Code_Name__c,
                    Clinical_Trial_Profile__r.NCT_Number__c,
                    Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c,
                    Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c,
                    Clinical_Trial_Profile__r.MDM_Sponsor_Name__c,
                    Clinical_Trial_Profile__r.IQVIA_Outreach__c,
                    Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c,
                    Clinical_Trial_Profile__r.CommunityTemplate__c,
                    Clinical_Trial_Profile__r.PPTemplate__c,
                    Participant_Contact__c,
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
                    PPMID__c,
                    (
                        SELECT
                            Id,
                            Patient_Delegate__c,
                            Patient_Delegate__r.Participant_Delegate__r.Mailing_Country_Code__c,
                            Patient_Delegate__r.Participant_Delegate__r.Id,
                            Patient_Delegate__r.Participant_Delegate__r.Email__c,
                            Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                            Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_SMS__c,
                            Patient_Delegate__r.Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
                            Patient_Delegate__r.Contact__r.IQVIA_Direct_Mail_Consent__c,
                            Study_Phone_Consent__c,
                            Study_Email_Consent__c,
                            Study_SMS_Consent__c,
                            Study_Direct_Mail_Consent__c,
                            Status__c,
                            PPM_ID__c,
                            Primary_Delegate__c,
                            Patient_Delegate__r.Contact__r.PPM_ID__c
                        FROM Patient_Delegate_Enrollments__r
                        WHERE ID IN :pderIds
                    )
                FROM Participant_Enrollment__c
                WHERE id IN :perIds
            ];
        } else if (
            perIds != null &&
            perIds.size() > 0 &&
            (pderIds == null ||
            pderIds.size() == 0)
        ) {
            perList = [
                SELECT
                    Id,
                    Participant__r.Email__c,
                    Participant__c,
                    Referral_Source__c,
                    DataControllerOrg__c,
                    Clinical_Trial_Profile__r.Study_Code_Name__c,
                    Clinical_Trial_Profile__r.NCT_Number__c,
                    Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c,
                    Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c,
                    Clinical_Trial_Profile__r.MDM_Sponsor_Name__c,
                    Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c,
                    Clinical_Trial_Profile__r.IQVIA_Outreach__c,
                    Clinical_Trial_Profile__r.CommunityTemplate__c,
                    Clinical_Trial_Profile__r.PPTemplate__c,
                    Participant_Contact__c,
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
                    PPMID__c
                FROM Participant_Enrollment__c
                WHERE id IN :perIds
            ];
        }

        Map<Participant_Enrollment__c, Id> mapPerAndCtpIds = new Map<Participant_Enrollment__c, Id>();
        if (!perList.isEmpty()) {
            for (Participant_Enrollment__c per : perList) {
                perandPderMap.put(per, per.Patient_Delegate_Enrollments__r);
                mapPerAndCtpIds.put(per, per.Clinical_Trial_Profile__c);
            }
        }
        Map<Id, List<Restricted_Source_Config__c>> mapCtpAndRestSources = new Map<Id, List<Restricted_Source_Config__c>>();

        for (Clinical_Trial_Profile__c ctp : [
            SELECT
                Id,
                IQVIA_Outreach__c,
                (
                    SELECT Id, Sponsor__c, Study__c, Referral_Resource__c
                    FROM Restricted_Source_Config__r
                )
            FROM Clinical_Trial_Profile__c
            WHERE Id IN :mapPerAndCtpIds.values()
        ]) {
            mapCtpAndRestSources.put(ctp.Id, ctp.Restricted_Source_Config__r);
        }
        Map<Id, Boolean> mapPerIdAndOutReach = new Map<Id, Boolean>();

        //Checking restricted resource and Iqvia Outreach validation
        for (Participant_Enrollment__c per : perList) {
            String referralSource;
            Boolean iqviaOutreach = false;
            String[] restrictedlst;
            if (per.Clinical_Trial_Profile__r.IQVIA_Outreach__c) {
                if (
                    per.Clinical_Trial_Profile__r.CommunityTemplate__c != 'PatientPortal' &&
                    (per.Clinical_Trial_Profile__r.CommunityTemplate__c != 'Janssen' ||
                    per.Clinical_Trial_Profile__r.PPTemplate__c != 'PP 2.0')
                ) {
                    iqviaOutreach = true;
                } else {
                    List<Restricted_Source_Config__c> restrictedRecrd = (mapCtpAndRestSources !=
                        null &&
                        mapCtpAndRestSources.get(per.Clinical_Trial_Profile__c) != null)
                        ? mapCtpAndRestSources.get(per.Clinical_Trial_Profile__c)
                        : null;
                    if (restrictedRecrd != null && !restrictedRecrd.isEmpty()) {
                        for (Restricted_Source_Config__c rsc : restrictedRecrd) {
                            restrictedlst = rsc.Referral_Resource__c != null
                                ? rsc.Referral_Resource__c.split(';')
                                : null;
                            if (restrictedlst != null && !restrictedlst.isEmpty()) {
                                referralSource = (per.Referral_Source__c == 'ePR' ||
                                    per.Referral_Source__c == 'ePRCampaign')
                                    ? per.Referral_Source__c + '-' + per.DataControllerOrg__c
                                    : per.Referral_Source__c;
                                if (restrictedlst.contains(referralSource)) {
                                    iqviaOutreach = false;
                                    break;
                                } else {
                                    iqviaOutreach = true;
                                }
                            }
                        }
                    } else {
                        iqviaOutreach = true;
                    }
                }
            } else {
                iqviaOutreach = false;
            }

            mapPerIdAndOutReach.put(per.Id, iqviaOutreach);
        }

        if (perList != null && perList.size() > 0) {
            accessToken = getAccessToken();
            System.debug('accessToken: ' + accessToken);
            for (Participant_Enrollment__c per : perList) {
                //New PER without participant contact and without delegate
                if (
                    placeOfFunctionality == 'RP BULK IMPORT' &&
                    per.Participant_Contact__c == null &&
                    per.PPMID__c == null
                ) {
                    createtypeIdentity = 'PARTICIPANT';
                    // accessToken = UCPM_ConsentPostController.getAccessToken();
                    createrequestJSON = UCPM_ConsentPostController.requestJsonGeneration_Create(
                        per,
                        null,
                        mapPerIdAndOutReach.get(per.Id),
                        'Participant',
                        placeOfFunctionality
                    );
                    if (
                        String.isNotBlank(createrequestJSON) && String.isNotEmpty(createrequestJSON)
                    ) {
                        UCPM_ConsentPostController.ReturnWrapper rw = new UCPM_ConsentPostController.ReturnWrapper();
                        rw = UCPM_ConsentPostController.callUCPMtoSaveConsents(
                            createrequestJSON,
                            accessToken,
                            createtypeIdentity
                        );
                        if(rw != null ){
                            if(rw.per != null){
                                perToUpdate.add(rw.per);
                            }
                            if(rw.log != null){
                                logsToInsert.add(rw.log);
                            }
                        }
                    }
                }
                //New PER and new participant contact without delegate
                else if (
                    per.PPMID__c == null &&
                    per.Participant_Contact__r.PPM_ID__c == null &&
                    perandPderMap.get(per).size() == 0
                ) {
                    createtypeIdentity = 'PARTICIPANT';
                    // accessToken = UCPM_ConsentPostController.getAccessToken();
                    createrequestJSON = UCPM_ConsentPostController.requestJsonGeneration_Create(
                        per,
                        null,
                        mapPerIdAndOutReach.get(per.Id),
                        'Participant:ParticipantContact',
                        placeOfFunctionality
                    );
                    if (
                        String.isNotBlank(createrequestJSON) && String.isNotEmpty(createrequestJSON)
                    ) {
                        UCPM_ConsentPostController.callUCPMtoPostConsents(createrequestJSON, accessToken, createtypeIdentity);
                    }
                }
                //New PER,existing participant contact without delegate
                else if (
                    per.PPMID__c == null &&
                    per.Participant_Contact__r.PPM_ID__c != null &&
                    perandPderMap.get(per).size() == 0
                ) {
                    // accessToken = UCPM_ConsentPostController.getAccessToken();
                    createtypeIdentity = 'PARTICIPANT';
                    updatetypeIdentity = 'PARTICIPANT';
                    createrequestJSON = UCPM_ConsentPostController.requestJsonGeneration_Create(
                        per,
                        null,
                        mapPerIdAndOutReach.get(per.Id),
                        'Participant',
                        placeOfFunctionality
                    );
                    updaterequestJSON = UCPM_ConsentPostController.requestJsonGeneration_update(
                        per,
                        null,
                        mapPerIdAndOutReach.get(per.Id),
                        'ParticipantContact',
                        placeOfFunctionality
                    );
                    if (
                        String.isNotBlank(createrequestJSON) && String.isNotEmpty(createrequestJSON)
                    ) {
                        UCPM_ConsentPostController.callUCPMtoPostConsents(
                            createrequestJSON,
                            accessToken,
                            createtypeIdentity
                        );
                    }
                    if (
                        String.isNotBlank(updaterequestJSON) && String.isNotEmpty(updaterequestJSON)
                    ) {
                        UCPM_ConsentPostController.callUCPMtoupdateConsents(
                            updaterequestJSON,
                            accessToken,
                            updatetypeIdentity
                        );
                    }
                }
                //New PER ,new participant contact,new delegate and new delegate contact
                else if (
                    per.PPMID__c == null &&
                    per.Participant_Contact__r.PPM_ID__c == null &&
                    perandPderMap.get(per) != null &&
                    perandPderMap.get(per).size() > 0 &&
                    perandPderMap.get(per)[0].PPM_ID__c == null &&
                    perandPderMap.get(per)[0].Patient_Delegate__r.Contact__r.PPM_ID__c == null
                ) {
                    // accessToken = UCPM_ConsentPostController.getAccessToken();
                    createtypeIdentity = 'PARTICIPANT-DELEGATE';
                    createrequestJSON = UCPM_ConsentPostController.requestJsonGeneration_Create(
                        per,
                        perandPderMap.get(per),
                        mapPerIdAndOutReach.get(per.Id),
                        'Participant:ParticipantContact:Delegate:DelegateContact',
                        placeOfFunctionality
                    );
                    if (
                        String.isNotBlank(createrequestJSON) && String.isNotEmpty(createrequestJSON)
                    ) {
                        UCPM_ConsentPostController.callUCPMtoPostConsents(
                            createrequestJSON,
                            accessToken,
                            createtypeIdentity
                        );
                    }
                }
                //New PER,new participant contact,new delegate,existing delegate contact
                else if (
                    per.PPMID__c == null &&
                    per.Participant_Contact__r.PPM_ID__c == null &&
                    perandPderMap.get(per) != null &&
                    perandPderMap.get(per).size() > 0 &&
                    perandPderMap.get(per)[0].PPM_ID__c == null &&
                    perandPderMap.get(per)[0].Patient_Delegate__r.Contact__r.PPM_ID__c != null
                ) {
                    // accessToken = UCPM_ConsentPostController.getAccessToken();
                    createtypeIdentity = 'PARTICIPANT-DELEGATE';
                    updatetypeIdentity = 'DELEGATE';
                    createrequestJSON = UCPM_ConsentPostController.requestJsonGeneration_Create(
                        per,
                        perandPderMap.get(per),
                        mapPerIdAndOutReach.get(per.Id),
                        'Participant:ParticipantContact:Delegate',
                        placeOfFunctionality
                    );

                    updaterequestJSON = UCPM_ConsentPostController.requestJsonGeneration_update(
                        per,
                        perandPderMap.get(per),
                        mapPerIdAndOutReach.get(per.Id),
                        'DelegateContact',
                        placeOfFunctionality
                    );
                    if (
                        String.isNotBlank(createrequestJSON) && String.isNotEmpty(createrequestJSON)
                    ) {
                        UCPM_ConsentPostController.callUCPMtoPostConsents(
                            createrequestJSON,
                            accessToken,
                            createtypeIdentity
                        );
                    }
                    if (
                        String.isNotBlank(updaterequestJSON) && String.isNotEmpty(updaterequestJSON)
                    ) {
                        UCPM_ConsentPostController.callUCPMtoupdateConsents(
                            updaterequestJSON,
                            accessToken,
                            updatetypeIdentity
                        );
                    }
                }
                //New PER,old participant contact,new delegate,new delegate contact
                else if (
                    per.PPMID__c == null &&
                    per.Participant_Contact__r.PPM_ID__c != null &&
                    perandPderMap.get(per) != null &&
                    perandPderMap.get(per).size() > 0 &&
                    perandPderMap.get(per)[0].PPM_ID__c == null &&
                    perandPderMap.get(per)[0].Patient_Delegate__r.Contact__r.PPM_ID__c == null
                ) {
                    // accessToken = UCPM_ConsentPostController.getAccessToken();
                    createtypeIdentity = 'PARTICIPANT-DELEGATE';
                    updatetypeIdentity = 'PARTICIPANT';
                    createrequestJSON = UCPM_ConsentPostController.requestJsonGeneration_Create(
                        per,
                        perandPderMap.get(per),
                        mapPerIdAndOutReach.get(per.Id),
                        'Participant:Delegate:DelegateContact',
                        placeOfFunctionality

                    );
                    updaterequestJSON = UCPM_ConsentPostController.requestJsonGeneration_update(
                        per,
                        null,
                        mapPerIdAndOutReach.get(per.Id),
                        'ParticipantContact',
                        placeOfFunctionality
                    );

                    if (
                        String.isNotBlank(createrequestJSON) && String.isNotEmpty(createrequestJSON)
                    ) {
                        UCPM_ConsentPostController.callUCPMtoPostConsents(
                            createrequestJSON,
                            accessToken,
                            createtypeIdentity
                        );
                    }
                    if (
                        String.isNotBlank(updaterequestJSON) && String.isNotEmpty(updaterequestJSON)
                    ) {
                        UCPM_ConsentPostController.callUCPMtoupdateConsents(
                            updaterequestJSON,
                            accessToken,
                            updatetypeIdentity
                        );
                    }
                }
                //New PER,old participant contact,new delegate,old delegate contact
                else if (
                    per.PPMID__c == null &&
                    per.Participant_Contact__r.PPM_ID__c != null &&
                    perandPderMap.get(per) != null &&
                    perandPderMap.get(per).size() > 0 &&
                    perandPderMap.get(per)[0].PPM_ID__c == null &&
                    perandPderMap.get(per)[0].Patient_Delegate__r.Contact__r.PPM_ID__c != null
                ) {
                    // accessToken = UCPM_ConsentPostController.getAccessToken();
                    createtypeIdentity = 'PARTICIPANT-DELEGATE';
                    updatetypeIdentity = 'PARTICIPANT-DELEGATE';
                    createrequestJSON = UCPM_ConsentPostController.requestJsonGeneration_Create(
                        per,
                        perandPderMap.get(per),
                        mapPerIdAndOutReach.get(per.Id),
                        'Participant:Delegate',
                        placeOfFunctionality
                    );
                    updaterequestJSON = UCPM_ConsentPostController.requestJsonGeneration_update(
                        per,
                        perandPderMap.get(per),
                        mapPerIdAndOutReach.get(per.Id),
                        'ParticipantContact:DelegateContact',
                        placeOfFunctionality
                    );

                    if (
                        String.isNotBlank(createrequestJSON) && String.isNotEmpty(createrequestJSON)
                    ) {
                        UCPM_ConsentPostController.callUCPMtoPostConsents(
                            createrequestJSON,
                            accessToken,
                            createtypeIdentity
                        );
                    }
                    if (
                        String.isNotBlank(updaterequestJSON) && String.isNotEmpty(updaterequestJSON)
                    ) {
                        UCPM_ConsentPostController.callUCPMtoupdateConsents(
                            updaterequestJSON,
                            accessToken,
                            updatetypeIdentity
                        );
                    }
                }
            }
        }

        try {
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
                database.update(perToUpdate, false);
            }
            if (!pderToUpdate.isEmpty()) {
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
                database.update(pderToUpdate, false);
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
                database.update(conToUpdate, false);
            }
            if (!logsToInsert.isEmpty()) {
                database.insert(logsToInsert, false);
            }
        } catch (Exception e) {
            System.debug('e.getMessage(): ' + e.getMessage());
            System.debug('e.getStackTraceString(): ' + e.getStackTraceString());
            IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
            objIntegrationLog.Response_Body__c = e.getMessage() + ' ' + e.getStackTraceString();
            objIntegrationLog.Request_Time__c = system.now();
            objIntegrationLog.Request_Type__c = 'Updation failed UCPM-Exception';
            objIntegrationLog.Function_Name__c = 'UCPM_ConsentPostController.postconsentUCPMdata';
            objIntegrationLog.Http_Method__c = 'POST';
            objIntegrationLog.Endpoint_URL__c = 'callout:UCPM_Post_Consent';
            insert objIntegrationLog;
        }
    }
    public String getAccessToken() {
        String accessToken;
        MulesoftToken__c setting = MulesoftToken__c.getInstance('Mulesoft Access Token UCPM');
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
            System.debug('MSGbody##: ' + e.getMessage());
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
    //Response wrapper start
    public class ResponseWrapperToken {
        public String token_type;
        public String access_token;
        public Integer expires_in;
        public String message;
        public Boolean success;
        public Integer statusCode;
    }
}