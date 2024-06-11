public without sharing class UCPM_ConsentPostBulkImport_Future {
    static List<Id> perRecIds;
    static List<Id> pDelEnrolRecIds;
    static String createtypeIdentity;
    static String updatetypeIdentity;
    static String createrequestJSON;
    static String updaterequestJSON;
    static String placeOfFunctionality;
    static List<IntegrationLog__c> logsToInsert = new List<IntegrationLog__c>();
    static List<Contact> conToUpdate = new List<Contact>();
    static List<Patient_Delegate_Enrollment__c> pderToUpdate = new List<Patient_Delegate_Enrollment__c>();
    static List<Participant_Enrollment__c> perToUpdate = new List<Participant_Enrollment__c>();
    static Set<Id> delgContIds = new Set<Id>();
    static Set<Id> partContIds = new Set<Id>();

    static Map<Participant_Enrollment__c, IntegrationLog__c> failedPerWithIntLog = new Map<Participant_Enrollment__c, IntegrationLog__c>();
    static Map<Patient_Delegate_Enrollment__c, IntegrationLog__c> failedPderWithIntLog = new Map<Patient_Delegate_Enrollment__c, IntegrationLog__c>();
    static Map<Contact, IntegrationLog__c> failedConWithIntLog = new Map<Contact, IntegrationLog__c>();

    @future(callout=true)
    public static void processRecords(
        List<Id> perIds,
        List<Id> pderIds,
        String placeOfFunctionality
    ) {
        try {
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
            Boolean saveAccessToken = false;
            String accessToken = MulesoftIntegrationApi.getAccessTokenIfValid(
                'Mulesoft Access Token UCPM'
            );
            MulesoftToken__c setting = MulesoftToken__c.getInstance(
                'Mulesoft Access Token UCPM'
            );
            MulesoftIntegrationApi.ResponseWrapper tokenWrap = new MulesoftIntegrationApi.ResponseWrapper();
            if (accessToken == null) {
                tokenWrap = MulesoftIntegrationApi.generateAccessTokenWithoutSave(setting);
                accessToken = tokenWrap.access_token;
                saveAccessToken = true;
            }
            System.debug('accessToken: ' + accessToken);

            if (perList != null && perList.size() > 0) {             

                for (Participant_Enrollment__c per : perList) {
                    //New PER without participant contact and without delegate
                    if (
                        placeOfFunctionality == 'RP BULK IMPORT' &&
                        per.Participant_Contact__c == null &&
                        per.PPMID__c == null
                    ) {
                        createtypeIdentity = 'PARTICIPANT';
                        createrequestJSON = UCPM_ConsentPostController.requestJsonGeneration_Create(
                            per,
                            null,
                            mapPerIdAndOutReach.get(per.Id),
                            'Participant',
                            placeOfFunctionality
                        );
                        if (
                            String.isNotBlank(createrequestJSON) &&
                            String.isNotEmpty(createrequestJSON)
                        ) {
                            callUCPMtoPostConsents(
                                createrequestJSON,
                                accessToken,
                                createtypeIdentity
                            );
                        }
                    }
                    //New PER and new participant contact without delegate
                    else if (
                        per.PPMID__c == null &&
                        per.Participant_Contact__r.PPM_ID__c == null &&
                        perandPderMap.get(per).size() == 0
                    ) {
                        createtypeIdentity = 'PARTICIPANT';
                        createrequestJSON = UCPM_ConsentPostController.requestJsonGeneration_Create(
                            per,
                            null,
                            mapPerIdAndOutReach.get(per.Id),
                            'Participant:ParticipantContact',
                            placeOfFunctionality
                        );
                        if (
                            String.isNotBlank(createrequestJSON) &&
                            String.isNotEmpty(createrequestJSON)
                        ) {
                            callUCPMtoPostConsents(
                                createrequestJSON,
                                accessToken,
                                createtypeIdentity
                            );
                        }
                    }
                    //New PER,existing participant contact without delegate
                    else if (
                        per.PPMID__c == null &&
                        per.Participant_Contact__r.PPM_ID__c != null &&
                        perandPderMap.get(per).size() == 0
                    ) {
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
                            String.isNotBlank(createrequestJSON) &&
                            String.isNotEmpty(createrequestJSON)
                        ) {
                            callUCPMtoPostConsents(
                                createrequestJSON,
                                accessToken,
                                createtypeIdentity
                            );
                        }
                        if (
                            String.isNotBlank(updaterequestJSON) &&
                            String.isNotEmpty(updaterequestJSON)
                        ) {
                            callUCPMtoupdateConsents(
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
                        if (
                            !delgContIds.contains(
                                perandPderMap.get(per)[0].Patient_Delegate__r.Contact__c
                            )
                        ) {
                            createtypeIdentity = 'PARTICIPANT-DELEGATE';
                            createrequestJSON = UCPM_ConsentPostController.requestJsonGeneration_Create(
                                per,
                                perandPderMap.get(per),
                                mapPerIdAndOutReach.get(per.Id),
                                'Participant:ParticipantContact:Delegate:DelegateContact',
                                placeOfFunctionality
                            );
                            if (
                                String.isNotBlank(createrequestJSON) &&
                                String.isNotEmpty(createrequestJSON)
                            ) {
                                callUCPMtoPostConsents(
                                    createrequestJSON,
                                    accessToken,
                                    createtypeIdentity
                                );
                            }
                            delgContIds.add(
                                perandPderMap.get(per)[0].Patient_Delegate__r.Contact__c
                            );
                        } else {
                            createtypeIdentity = 'PARTICIPANT-DELEGATE';
                            createrequestJSON = UCPM_ConsentPostController.requestJsonGeneration_Create(
                                per,
                                perandPderMap.get(per),
                                mapPerIdAndOutReach.get(per.Id),
                                'Participant:ParticipantContact:Delegate',
                                placeOfFunctionality
                            );
                            if (
                                String.isNotBlank(createrequestJSON) &&
                                String.isNotEmpty(createrequestJSON)
                            ) {
                                callUCPMtoPostConsents(
                                    createrequestJSON,
                                    accessToken,
                                    createtypeIdentity
                                );
                            }
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
                            String.isNotBlank(createrequestJSON) &&
                            String.isNotEmpty(createrequestJSON)
                        ) {
                            callUCPMtoPostConsents(
                                createrequestJSON,
                                accessToken,
                                createtypeIdentity
                            );
                        }
                        if (
                            String.isNotBlank(updaterequestJSON) &&
                            String.isNotEmpty(updaterequestJSON)
                        ) {
                            callUCPMtoupdateConsents(
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
                        if (
                            !delgContIds.contains(
                                perandPderMap.get(per)[0].Patient_Delegate__r.Contact__c
                            )
                        ) {
                            delgContIds.add(
                                perandPderMap.get(per)[0].Patient_Delegate__r.Contact__c
                            );
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
                                String.isNotBlank(createrequestJSON) &&
                                String.isNotEmpty(createrequestJSON)
                            ) {
                                callUCPMtoPostConsents(
                                    createrequestJSON,
                                    accessToken,
                                    createtypeIdentity
                                );
                            }
                            if (
                                String.isNotBlank(updaterequestJSON) &&
                                String.isNotEmpty(updaterequestJSON)
                            ) {
                                callUCPMtoupdateConsents(
                                    updaterequestJSON,
                                    accessToken,
                                    updatetypeIdentity
                                );
                            }
                        } else {
                            createtypeIdentity = 'PARTICIPANT-DELEGATE';
                            updatetypeIdentity = 'PARTICIPANT';
                            createrequestJSON = UCPM_ConsentPostController.requestJsonGeneration_Create(
                                per,
                                perandPderMap.get(per),
                                mapPerIdAndOutReach.get(per.Id),
                                'Participant:Delegate',
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
                                String.isNotBlank(createrequestJSON) &&
                                String.isNotEmpty(createrequestJSON)
                            ) {
                                callUCPMtoPostConsents(
                                    createrequestJSON,
                                    accessToken,
                                    createtypeIdentity
                                );
                            }
                            if (
                                String.isNotBlank(updaterequestJSON) &&
                                String.isNotEmpty(updaterequestJSON)
                            ) {
                                callUCPMtoupdateConsents(
                                    updaterequestJSON,
                                    accessToken,
                                    updatetypeIdentity
                                );
                            }
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
                            String.isNotBlank(createrequestJSON) &&
                            String.isNotEmpty(createrequestJSON)
                        ) {
                            callUCPMtoPostConsents(
                                createrequestJSON,
                                accessToken,
                                createtypeIdentity
                            );
                        }
                        if (
                            String.isNotBlank(updaterequestJSON) &&
                            String.isNotEmpty(updaterequestJSON)
                        ) {
                            callUCPMtoupdateConsents(
                                updaterequestJSON,
                                accessToken,
                                updatetypeIdentity
                            );
                        }
                    }
                }
            }

            if (!logsToInsert.isEmpty()) {
                Database.insert(logsToInsert, false);
            }

            //Append Int log id to failed per
            for (Participant_Enrollment__c per : failedPerWithIntLog.keySet()) {
                if (failedPerWithIntLog.get(per).Id != null) {
                    per.UCPM_Error_Message__c =
                        per.UCPM_Error_Message__c +
                        ' ' +
                        failedPerWithIntLog.get(per).Id;
                    perToUpdate.add(per);
                }
            }

            //Append Int log id to failed pder

            for (Patient_Delegate_Enrollment__c pder : failedPderWithIntLog.keySet()) {
                if (failedPderWithIntLog.get(pder).Id != null) {
                    pder.UCPM_Error_Message__c =
                        pder.UCPM_Error_Message__c +
                        ' ' +
                        failedPderWithIntLog.get(pder).Id;
                    pderToUpdate.add(pder);
                }
            }

            //Append Int log id to failed cont
            for (Contact con : failedConWithIntLog.keySet()) {
                if (failedConWithIntLog.get(con).Id != null) {
                    con.UCPM_Error_Message__c =
                        con.UCPM_Error_Message__c +
                        ' ' +
                        failedConWithIntLog.get(con).Id;
                    conToUpdate.add(con);
                }
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
                    ParticipantEnrollmentTriggerHandler.CreateJanssenNotification.class
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
                    ParticipantEnrollmentTriggerHandler.PatientVisitsDeletion.class
                );
                /*For Welcome Msg -- Added by Anitha*/
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentTriggerHandler.createNotifications.class
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
                    PENotificationTriggerHandler.CreateNotificationHandler.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
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
                    ParticipantEnrollmentTriggerHandler.UpdatePatientConsent.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentTriggerHandler.StudyConsentTimestamps.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentTriggerHandler.UpdateInitialVisits.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    UCPM_UpdateConsentOptOutHandler.updateConsentPERtoUCPM.class
                );
                database.update(perToUpdate, false);
            }
            if (!pderToUpdate.isEmpty()) {
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateEnrolTriggerHandler.SetDefaultPatientDelegateStatusHandler.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateEnrolTriggerHandler.CreateJanssenNotification.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateEnrolTriggerHandler.CreateNewAssignmentNotification.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateEnrolTriggerHandler.CreateReactivatedNotification.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateEnrolTriggerHandler.CreatePrimaryDelegateForMinor.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateEnrolTriggerHandler.UpdateDelegateConsent.class
                );
                //Timestamp should not be bypassed when consents are changed
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateEnrolTriggerHandler.UpdateConsentTimeStamps.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateEnrolTriggerHandler.AssignCommunityPermissionSets.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateEnrolTriggerHandler.UCPMStausChangeOrPrimaryChangeNotification.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    UCPM_UpdateConsentOptOutHandler.updateConsentPDERtoUCPM.class
                );

                database.update(pderToUpdate, false);
            }

            if (!conToUpdate.isEmpty()) {
                TriggerHandlerExecutor.bypassHandler(
                    ContactTriggerHandler.UpdateParticipantAndUserEmailsOnEmailChangeHandler.class
                );

                TriggerHandlerExecutor.bypassHandler(
                    ContactTriggerHandler.createNotificationsHandler.class
                );

                TriggerHandlerExecutor.bypassHandler(
                    ContactTriggerHandler.CreateUserForDelegateContactHandler.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ContactTriggerHandler.SetShowTourDefaultHandler.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ContactTriggerHandler.PopulateOverrideFields.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ContactTriggerHandler.CreateUserForCCContactHandler.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ContactTriggerHandler.UpdateParticipantDetailsHandler.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ContactTriggerHandler.UpdatePhoneNumberContactsHandler.class
                );

                TriggerHandlerExecutor.bypassHandler(
                    ContactTriggerHandler.ParticipantConsentUpdate.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ContactTriggerHandler.UpdateConsentTimeStamps.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    ContactTriggerHandler.UpdateNotificationHandler.class
                );

                TriggerHandlerExecutor.bypassHandler(
                    UCPM_UpdateConsentOptOutHandler.updateConsentContacttoUCPM.class
                );
                Database.update(conToUpdate, false);
            }
            //MulesoftIntegrationApi.saveAccessToken method to save the Access token for future use
            if (saveAccessToken) {
                MulesoftIntegrationApi.saveAccessToken(
                    setting,
                    tokenWrap.access_token,
                    tokenWrap.expires_in
                );
            }
        } catch (Exception e) {
            System.debug('e.getMessage(): ' + e.getMessage());
            System.debug('e.getStackTraceString(): ' + e.getStackTraceString());
            // IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
            // objIntegrationLog.Response_Body__c = e.getMessage() + ' ' + e.getStackTraceString();
            // objIntegrationLog.Request_Time__c = system.now();
            // objIntegrationLog.Request_Type__c = 'BULK IMPORT UCPM CONSENTS- Create/Update PPMID in UCPM-Exception';
            // objIntegrationLog.Function_Name__c = 'Class-UCPM_ConsentPostBulkImport_Future Method-fetchPerAndPderDetails';
            // objIntegrationLog.Http_Method__c = 'PUT/POST';
            // objIntegrationLog.Endpoint_URL__c = 'callout:UCPM_Post_Consent';
            // objIntegrationLog.Success__c = false;
            // insert objIntegrationLog;
        }
    }
    public static void callUCPMtoupdateConsents(
        String request,
        String accessToken,
        String IdentityType
    ) {
        List<UCPM_ConsentPostController.ParticipantData> respPart = new List<UCPM_ConsentPostController.ParticipantData>();
        List<UCPM_ConsentPostController.Delegates> respDelg = new List<UCPM_ConsentPostController.Delegates>();
        String requestString = request;
        try {
            System.debug('@@   ');
            List<UCPM_ConsentPostController.ResponseWrapper> responsWrap;

            System.debug('requestBody@@' + requestString);

            //Call Mulesoft-UCPM API for consents
            HTTP h = new HTTP();
            HTTPRequest r = new HTTPRequest();
            r.setEndpoint('callout:UCPM_Post_Consent');
            r.setHeader('Content-Type', 'application/json;charset=UTF-8');
            r.setMethod('PUT');
            r.setHeader('Authorization', 'Bearer ' + accessToken);
            r.setbody(requestString);

            // UPDATE DETAILS
            r.setHeader('identityType', IdentityType);
            r.setHeader('source', 'RH');
            r.setHeader('transactionId', MulesoftIntegrationApi.uniqueKeygeneration());
            r.setTimeout(120000);
            System.debug('###### request ' + r.getBody());
            HTTPResponse resp = h.send(r);
            System.debug('###### resp ' + resp);
            System.debug('###### resp body  ' + resp.getBody());

            //Create IntegrationLog__c for monitoring purpose
            IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
            objIntegrationLog.Request_Body__c = requestString;
            objIntegrationLog.Request_Time__c = system.now();
            objIntegrationLog.Request_Type__c = 'BULK IMPORT UCPM CONSENTS-Update Consents for PPMID in UCPM';
            objIntegrationLog.Function_Name__c = 'Class-UCPM_ConsentPostBulkImport_Future Method-callUCPMtoupdateConsents';
            objIntegrationLog.Http_Method__c = 'PUT';
            objIntegrationLog.Endpoint_URL__c = 'callout:UCPM_Post_Consent';

            system.debug('status code' + resp.getStatusCode());
            if (resp.getStatusCode() == 200) {
                System.debug('200 ' + resp.getStatusCode());
                objIntegrationLog.Success__c = true;
                objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();
                objIntegrationLog.Response_Body__c = resp.getBody();
                objIntegrationLog.Response_Time__c = system.now();
                List<UCPM_ConsentPostController.ResponseWrapper> deserializedResponseWrapper = (List<UCPM_ConsentPostController.ResponseWrapper>) JSON.deserialize(
                    resp.getBody(),
                    List<UCPM_ConsentPostController.ResponseWrapper>.class
                );
                if (deserializedResponseWrapper != null) {
                    if (deserializedResponseWrapper[0].ParticipantData != null)
                        respPart = deserializedResponseWrapper[0].ParticipantData;

                    if (deserializedResponseWrapper[0].Delegates != null)
                        respDelg = deserializedResponseWrapper[0].Delegates;

                    if (!respPart.isEmpty()) {
                        for (UCPM_ConsentPostController.ParticipantData partData : respPart) {
                            if (!partData.iqviaOrg && String.isNotBlank((partData.study))) {
                                if (partData.status != 'success') {
                                    // Create int log for failed per
                                    IntegrationLog__c intLog = new IntegrationLog__c();
                                    intLog.Request_Body__c = requestString;
                                    intLog.Request_Time__c = system.now();
                                    intLog.Request_Type__c = 'BULK IMPORT UCPM CONSENTS-Update PER Consents to UCPM';
                                    intLog.Function_Name__c = 'Class-UCPM_ConsentPostBulkImport_Future Method-callUCPMtoupdateConsents';
                                    intLog.Http_Method__c = 'PUT';
                                    intLog.Endpoint_URL__c = 'callout:UCPM_Post_Consent';
                                    intLog.Response_Status_Code__c = resp.getStatusCode();
                                    intLog.Response_Body__c = resp.getBody();
                                    intLog.Response_Time__c = system.now();
                                    intLog.Success__c = false;

                                    Participant_Enrollment__c failedPer = new Participant_Enrollment__c();
                                    failedPer.Id = partData.applicationId;
                                    failedPer.UCPM_Status__c = 'Failed';
                                    failedPer.UCPM_Error_Message__c =
                                        partData.status +
                                        ' ' +
                                        partData.transactionId;
                                    failedPerWithIntLog.put(failedPer, intLog);
                                    logsToInsert.add(intLog);
                                }
                            }
                            if (partData.iqviaOrg && partData.sponsor == 'IQVIA') {
                                if (partData.status != 'success') {
                                    Participant_Enrollment__c per = [
                                        SELECT Id, Participant_Contact__c
                                        FROM Participant_Enrollment__c
                                        WHERE Id = :partData.applicationId
                                    ];
                                    // Create int log for failed contact
                                    IntegrationLog__c intLog = new IntegrationLog__c();
                                    intLog.Request_Body__c = requestString;
                                    intLog.Request_Time__c = system.now();
                                    intLog.Request_Type__c = 'BULK IMPORT UCPM CONSENTS-Update Contact Consents to UCPM';
                                    intLog.Function_Name__c = 'Class-UCPM_ConsentPostBulkImport_Future Method-callUCPMtoupdateConsents';
                                    intLog.Http_Method__c = 'PUT';
                                    intLog.Endpoint_URL__c = 'callout:UCPM_Post_Consent';
                                    intLog.Response_Status_Code__c = resp.getStatusCode();
                                    intLog.Response_Body__c = resp.getBody();
                                    intLog.Response_Time__c = system.now();
                                    intLog.Success__c = false;

                                    Contact failedCont = new Contact();
                                    failedCont.Id = per.Participant_Contact__c;
                                    failedCont.UCPM_Status__c = 'Failed';
                                    failedCont.UCPM_Error_Message__c =
                                        partData.status +
                                        ' ' +
                                        partData.transactionId;

                                    failedConWithIntLog.put(failedCont, intLog);
                                    logsToInsert.add(intLog);
                                }
                            }
                        }
                    }
                    if (!respDelg.isEmpty()) {
                        for (UCPM_ConsentPostController.Delegates delgData : respDelg) {
                            if (!delgData.iqviaOrg && String.isNotBlank(delgData.study)) {
                                if (delgData.status != 'success') {
                                    // Create int log for failed pder
                                    IntegrationLog__c intLog = new IntegrationLog__c();
                                    intLog.Request_Body__c = requestString;
                                    intLog.Request_Time__c = system.now();
                                    intLog.Request_Type__c = 'BULK IMPORT UCPM CONSENTS-Update PDER Consents to UCPM';
                                    intLog.Function_Name__c = 'Class-UCPM_ConsentPostBulkImport_Future Method-callUCPMtoupdateConsents';
                                    intLog.Http_Method__c = 'PUT';
                                    intLog.Endpoint_URL__c = 'callout:UCPM_Post_Consent';
                                    intLog.Response_Status_Code__c = resp.getStatusCode();
                                    intLog.Response_Body__c = resp.getBody();
                                    intLog.Response_Time__c = system.now();
                                    intLog.Success__c = false;
                                    Patient_Delegate_Enrollment__c failedPder = new Patient_Delegate_Enrollment__c();
                                    failedPder.Id = delgData.applicationId;
                                    failedPder.UCPM_Error_Message__c =
                                        delgData.status +
                                        ' ' +
                                        delgData.transactionId;
                                    failedPder.UCPM_Status__c = 'Failed';

                                    failedPderWithIntLog.put(failedPder, intLog);
                                    logsToInsert.add(intLog);
                                }
                            }
                            if (delgData.iqviaOrg && delgData.sponsor == 'IQVIA') {
                                if (delgData.status != 'success') {
                                    Patient_Delegate_Enrollment__c pder = [
                                        SELECT Id, Patient_Delegate__r.Contact__c
                                        FROM Patient_Delegate_Enrollment__c
                                        WHERE Id = :delgData.applicationId
                                    ];
                                    Contact failedCont = new Contact();
                                    failedCont.Id = pder.Patient_Delegate__r.Contact__c;
                                    failedCont.UCPM_Status__c = 'Failed';
                                    failedCont.UCPM_Error_Message__c =
                                        delgData.status +
                                        ' ' +
                                        delgData.transactionId;

                                    // Create int log for failed pder contact
                                    IntegrationLog__c intLog = new IntegrationLog__c();
                                    intLog.Request_Body__c = requestString;
                                    intLog.Request_Time__c = system.now();
                                    intLog.Request_Type__c = 'BULK IMPORT UCPM CONSENTS-Update Contact Consents to UCPM';
                                    intLog.Function_Name__c = 'Class-UCPM_ConsentPostBulkImport_Future Method-callUCPMtoupdateConsents';
                                    intLog.Http_Method__c = 'PUT';
                                    intLog.Endpoint_URL__c = 'callout:UCPM_Post_Consent';
                                    intLog.Response_Status_Code__c = resp.getStatusCode();
                                    intLog.Response_Body__c = resp.getBody();
                                    intLog.Response_Time__c = system.now();
                                    intLog.Success__c = false;

                                    failedConWithIntLog.put(failedCont, intLog);
                                    logsToInsert.add(intLog);
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
            }
            logsToInsert.add(objIntegrationLog);
        } catch (Exception e) {
            System.debug('e.getMessage(): ' + e.getMessage());
            System.debug('e.getStackTraceString(): ' + e.getStackTraceString());
            IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
            objIntegrationLog.Response_Body__c = e.getMessage() + ' ' + e.getStackTraceString();
            objIntegrationLog.Request_Time__c = system.now();
            objIntegrationLog.Request_Type__c = 'BULK IMPORT UCPM CONSENTS- Update PPMID in UCPM-Exception';
            objIntegrationLog.Function_Name__c = 'Class-UCPM_ConsentPostBulkImport_Future Method-callUCPMtoupdateConsents';
            objIntegrationLog.Http_Method__c = 'PUT';
            objIntegrationLog.Endpoint_URL__c = 'callout:UCPM_Post_Consent';
            objIntegrationLog.Request_Body__c = requestString;
            objIntegrationLog.Success__c = false;

            logsToInsert.add(objIntegrationLog);
        }
    }

    public static void callUCPMtoPostConsents(
        String request,
        String accessToken,
        String IdentityType
    ) {
        String requestString = request;
        try {
            System.debug('@@   ');
            List<UCPM_ConsentPostController.ResponseWrapper> responsWrap;

            List<UCPM_ConsentPostController.ParticipantData> respPart = new List<UCPM_ConsentPostController.ParticipantData>();
            List<UCPM_ConsentPostController.Delegates> respDelg = new List<UCPM_ConsentPostController.Delegates>();

            //Call Mulesoft-UCPM API for consents
            HTTP h = new HTTP();
            HTTPRequest r = new HTTPRequest();
            r.setEndpoint('callout:UCPM_Post_Consent');
            r.setHeader('Content-Type', 'application/json;charset=UTF-8');
            r.setMethod('POST');
            r.setHeader('Authorization', 'Bearer ' + accessToken);
            r.setbody(requestString);

            // UPDATE DETAILS
            r.setHeader('identityType', IdentityType);
            r.setHeader('source', 'RH');
            r.setHeader('transactionId', MulesoftIntegrationApi.uniqueKeygeneration());
            r.setTimeout(120000);
            HTTPResponse resp = h.send(r);

            //Create IntegrationLog__c for monitoring purpose
            IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
            objIntegrationLog.Request_Body__c = requestString;
            objIntegrationLog.Request_Time__c = system.now();
            objIntegrationLog.Request_Type__c = 'BULK IMPORT UCPM CONSENTS Create PPMID in UCPM';
            objIntegrationLog.Function_Name__c = 'Class-UCPM_ConsentPostBulkImport_Future Method-callUCPMtoupdateConsents';
            objIntegrationLog.Http_Method__c = 'POST';
            objIntegrationLog.Endpoint_URL__c = 'callout:UCPM_Post_Consent';

            system.debug('status code' + resp.getStatusCode());
            if (resp.getStatusCode() == 200) {
                System.debug('200 ' + resp.getStatusCode());
                objIntegrationLog.Success__c = true;
                objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();
                objIntegrationLog.Response_Body__c = resp.getBody();
                objIntegrationLog.Response_Time__c = system.now();
                System.debug('resp.getBody(): ' + resp.getBody());
                String s1 = resp.getBody();
                s1 = s1.replace('failed-key', 'failed_key');
                List<UCPM_ConsentPostController.ResponseWrapper> deserializedResponseWrapper = (List<UCPM_ConsentPostController.ResponseWrapper>) JSON.deserialize(
                    s1,
                    List<UCPM_ConsentPostController.ResponseWrapper>.class
                );

                if (deserializedResponseWrapper != null) {
                    if (deserializedResponseWrapper[0].ParticipantData != null)
                        respPart = deserializedResponseWrapper[0].ParticipantData;

                    if (deserializedResponseWrapper[0].Delegates != null)
                        respDelg = deserializedResponseWrapper[0].Delegates;

                    if (!respPart.isEmpty()) {
                        for (UCPM_ConsentPostController.ParticipantData partData : respPart) {
                            if (!partData.iqviaOrg && String.isNotBlank((partData.study))) {
                                if (partData.status == 'success' && partData.ppmid != null) {
                                    Participant_Enrollment__c per = new Participant_Enrollment__c();
                                    per.Id = partData.applicationId;
                                    per.PPMID__c = partData.ppmid;
                                    per.UCPM_Status__c = 'Completed';
                                    perToUpdate.add(per);
                                } else {
                                    // Create int log for failed per
                                    IntegrationLog__c intLog = new IntegrationLog__c();
                                    intLog.Request_Body__c = requestString;
                                    intLog.Request_Time__c = system.now();
                                    intLog.Request_Type__c = 'BULK IMPORT UCPM CONSENTS- Post PER Consents to UCPM';
                                    intLog.Function_Name__c = 'Class-UCPM_ConsentPostBulkImport_Future Method-callUCPMtoPostConsents';
                                    intLog.Http_Method__c = 'POST';
                                    intLog.Endpoint_URL__c = 'callout:UCPM_Post_Consent';
                                    intLog.Response_Status_Code__c = resp.getStatusCode();
                                    intLog.Response_Body__c = resp.getBody();
                                    intLog.Response_Time__c = system.now();
                                    intLog.Success__c = false;

                                    Participant_Enrollment__c failedPer = new Participant_Enrollment__c();
                                    failedPer.Id = partData.applicationId;
                                    failedPer.UCPM_Status__c = 'Failed';
                                    failedPer.UCPM_Error_Message__c =
                                        partData.status +
                                        ' ' +
                                        partData.transactionId;
                                    failedPerWithIntLog.put(failedPer, intLog);
                                    logsToInsert.add(intLog);
                                }
                            }
                            if (partData.iqviaOrg && partData.sponsor == 'IQVIA') {
                                if (partData.status == 'success' && partData.ppmid != null) {
                                    Participant_Enrollment__c per = [
                                        SELECT Id, Participant_Contact__c
                                        FROM Participant_Enrollment__c
                                        WHERE Id = :partData.applicationId
                                    ];
                                    Contact con = new Contact();
                                    con.Id = per.Participant_Contact__c;
                                    con.PPM_ID__c = partData.ppmid;
                                    con.UCPM_Status__c = 'Completed';
                                    conToUpdate.add(con);
                                } else {
                                    Participant_Enrollment__c per = [
                                        SELECT Id, Participant_Contact__c
                                        FROM Participant_Enrollment__c
                                        WHERE Id = :partData.applicationId
                                    ];
                                    // Create int log for failed contact
                                    IntegrationLog__c intLog = new IntegrationLog__c();
                                    intLog.Request_Body__c = requestString;
                                    intLog.Request_Time__c = system.now();
                                    intLog.Request_Type__c = 'BULK IMPORT UCPM CONSENTS -Post Contact Consents to UCPM';
                                    intLog.Function_Name__c = 'Class-UCPM_ConsentPostBulkImport_Future Method-callUCPMtoPostConsents';
                                    intLog.Http_Method__c = 'POST';
                                    intLog.Endpoint_URL__c = 'callout:UCPM_Post_Consent';
                                    intLog.Response_Status_Code__c = resp.getStatusCode();
                                    intLog.Response_Body__c = resp.getBody();
                                    intLog.Response_Time__c = system.now();
                                    intLog.Success__c = false;

                                    Contact failedCont = new Contact();
                                    failedCont.Id = per.Participant_Contact__c;
                                    failedCont.UCPM_Status__c = 'Failed';
                                    failedCont.UCPM_Error_Message__c =
                                        partData.status +
                                        ' ' +
                                        partData.transactionId;

                                    failedConWithIntLog.put(failedCont, intLog);
                                    logsToInsert.add(intLog);
                                }
                            }
                        }
                    }
                    if (!respDelg.isEmpty()) {
                        for (UCPM_ConsentPostController.Delegates delgData : respDelg) {
                            if (!delgData.iqviaOrg && String.isNotBlank(delgData.study)) {
                                if (delgData.status == 'success' && delgData.ppmid != null) {
                                    Patient_Delegate_Enrollment__c pder = new Patient_Delegate_Enrollment__c();
                                    pder.Id = delgData.applicationId;
                                    pder.PPM_ID__c = delgData.ppmid;
                                    pder.UCPM_Status__c = 'Completed';
                                    pderToUpdate.add(pder);
                                } else {
                                    // Create int log for failed pder
                                    IntegrationLog__c intLog = new IntegrationLog__c();
                                    intLog.Request_Body__c = requestString;
                                    intLog.Request_Time__c = system.now();
                                    intLog.Request_Type__c = 'BULK IMPORT UCPM CONSENTS - Post PDER Consents to UCPM';
                                    intLog.Function_Name__c = 'Class-UCPM_ConsentPostBulkImport_Future Method-callUCPMtoPostConsents';
                                    intLog.Http_Method__c = 'POST';
                                    intLog.Endpoint_URL__c = 'callout:UCPM_Post_Consent';
                                    intLog.Response_Status_Code__c = resp.getStatusCode();
                                    intLog.Response_Body__c = resp.getBody();
                                    intLog.Response_Time__c = system.now();
                                    intLog.Success__c = false;
                                    Patient_Delegate_Enrollment__c failedPder = new Patient_Delegate_Enrollment__c();
                                    failedPder.Id = delgData.applicationId;
                                    failedPder.UCPM_Error_Message__c =
                                        delgData.status +
                                        ' ' +
                                        delgData.transactionId;
                                    failedPder.UCPM_Status__c = 'Failed';

                                    failedPderWithIntLog.put(failedPder, intLog);
                                    logsToInsert.add(intLog);
                                }
                            }
                            if (delgData.iqviaOrg && delgData.sponsor == 'IQVIA') {
                                if (delgData.status == 'success' && delgData.ppmid != null) {
                                    Patient_Delegate_Enrollment__c pder = [
                                        SELECT Id, Patient_Delegate__r.Contact__c
                                        FROM Patient_Delegate_Enrollment__c
                                        WHERE Id = :delgData.applicationId
                                    ];
                                    Contact con = new Contact();
                                    con.Id = pder.Patient_Delegate__r.Contact__c;
                                    con.PPM_ID__c = delgData.ppmid;
                                    con.UCPM_Status__c = 'Completed';
                                    conToUpdate.add(con);
                                } else {
                                    Patient_Delegate_Enrollment__c pder = [
                                        SELECT Id, Patient_Delegate__r.Contact__c
                                        FROM Patient_Delegate_Enrollment__c
                                        WHERE Id = :delgData.applicationId
                                    ];
                                    Contact failedCont = new Contact();
                                    failedCont.Id = pder.Patient_Delegate__r.Contact__c;
                                    failedCont.UCPM_Status__c = 'Failed';
                                    failedCont.UCPM_Error_Message__c =
                                        delgData.status +
                                        ' ' +
                                        delgData.transactionId;

                                    // Create int log for failed pder contact
                                    IntegrationLog__c intLog = new IntegrationLog__c();
                                    intLog.Request_Body__c = requestString;
                                    intLog.Request_Time__c = system.now();
                                    intLog.Request_Type__c = 'BULK IMPORT UCPM CONSENTS - Post Contact Consents to UCPM';
                                    intLog.Function_Name__c = 'Class-UCPM_ConsentPostBulkImport_Future Method-callUCPMtoPostConsents';
                                    intLog.Http_Method__c = 'POST';
                                    intLog.Endpoint_URL__c = 'callout:UCPM_Post_Consent';
                                    intLog.Response_Status_Code__c = resp.getStatusCode();
                                    intLog.Response_Body__c = resp.getBody();
                                    intLog.Response_Time__c = system.now();
                                    intLog.Success__c = false;

                                    failedConWithIntLog.put(failedCont, intLog);
                                    logsToInsert.add(intLog);
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
            }
            logsToInsert.add(objIntegrationLog);
        } catch (Exception e) {
            System.debug('e.getMessage(): ' + e.getMessage());
            System.debug('e.getStackTraceString(): ' + e.getStackTraceString());
            IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
            objIntegrationLog.Response_Body__c = e.getMessage() + ' ' + e.getStackTraceString();
            objIntegrationLog.Request_Time__c = system.now();
            objIntegrationLog.Request_Type__c = 'BULK IMPORT UCPM CONSENTS - Create PPMID in UCPM-Exception';
            objIntegrationLog.Function_Name__c = 'Class-UCPM_ConsentPostBulkImport_Future Method-callUCPMtoPostConsents';
            objIntegrationLog.Http_Method__c = 'POST';
            objIntegrationLog.Endpoint_URL__c = 'callout:UCPM_Post_Consent';
            objIntegrationLog.Success__c = false;
            objIntegrationLog.Request_Body__c = requestString;
            logsToInsert.add(objIntegrationLog);
        }
    }

    public class UCPM_RequestWrapper {
        public Id perId;
        public Boolean isIqviaOutreachEnabled;
    }
}
