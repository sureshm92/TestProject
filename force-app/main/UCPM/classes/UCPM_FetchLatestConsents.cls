public without sharing class UCPM_FetchLatestConsents {
    public static String getAccessToken() {
        String accessToken;
        MulesoftToken__c setting = MulesoftToken__c.getInstance('Mulesoft Access Token UCPM');
        Http http1 = new Http();
        HttpRequest request1 = new HttpRequest();
        request1.setEndpoint('callout:' + setting.Named_Credentials_Name__c);
        request1.setMethod('POST');
        request1.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String requestBody1 = 'grant_type=client_credentials';
        request1.setBody(requestBody1);
        System.debug('###### request1 ' + request1);

        HttpResponse resp1 = http1.send(request1);
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
    public static void callUCPMtoFetchConsents(
        Id PerId,
        List<Id> pderIdList,
        Id conId,
        Boolean isParticipant,
        String placeOffunctionality
    ) {
        String responseBody;
        Participant_Enrollment__c per;
        List<Patient_Delegate_Enrollment__c> pdeList = new List<Patient_Delegate_Enrollment__c>();
        List<Participant_Enrollment__c> listPE = new List<Participant_Enrollment__c>();
        if(conId != null && PerId == null){
            listPE = [Select Id,PPMID__c,Participant_Contact__c,Participant_Contact__r.PPM_ID__c
                      from Participant_Enrollment__c where 
                      Participant_Contact__c =:conId AND Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = true AND Participant_Status__c NOT IN:PEStatusState.PE_STATUS_GROUP_ALUMNI AND Invited_To_PP_Date__c != null AND
                      (Clinical_Trial_Profile__r.CommunityTemplate__c = 'PatientPortal' OR (Clinical_Trial_Profile__r.CommunityTemplate__c = 'Janssen' AND Clinical_Trial_Profile__r.PPTemplate__c = 'PP 2.0'))
                    ]; 
            if(!isParticipant){
                pdeList = [Select Id,PPM_ID__c,Participant_Enrollment__r.PPMID__c from Patient_Delegate_Enrollment__c
                where Patient_Delegate__r.Contact__c =:conId AND Status__c = 'Active' AND
                (Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c = 'PatientPortal' OR (Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c = 'Janssen' AND Participant_Enrollment__r.Clinical_Trial_Profile__r.PPTemplate__c = 'PP 2.0'))
               ];
            }  
        }
        else if (pderIdList != null && pderIdList.size() > 0) {
            per = [
                SELECT
                    id,
                    PPMID__c,
                    Participant_Contact__c,
                    Participant_Contact__r.PPM_ID__c,
                    Clinical_Trial_Profile__r.Study_Sponsor__c,
                    Clinical_Trial_Profile__c,
                    (
                        SELECT id, PPM_ID__c, Participant_Enrollment__r.PPMID__c,Patient_Delegate__r.Contact__r.PPM_ID__c,Patient_Delegate__r.Contact__c
                        FROM Patient_Delegate_Enrollments__r
                        WHERE Id IN :pderIdList
                    )
                FROM Participant_Enrollment__c
                WHERE id = :PerId
            ];
        } else {
            per = [
                SELECT
                    id,
                    PPMID__c,
                    Participant_Contact__c,
                    Participant_Contact__r.PPM_ID__c,
                    Clinical_Trial_Profile__r.Study_Sponsor__c,
                    Clinical_Trial_Profile__c
                FROM Participant_Enrollment__c
                WHERE id = :PerId
            ];
        }

        Boolean fetchconsentsfromUCPM = false;
        String requestString;
        if(conId == null && PerId != null){
            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartArray();
    
            if (per.PPMID__c != null) {
                fetchconsentsfromUCPM = true;
                gen.writeStartObject();
                gen.writeStringField('ppmid', per.PPMID__c);
                gen.writeStringField('participantPPMID', '');
                gen.writeStringField('applicationId', per.Id);
                gen.writeEndObject();
            }
    
            if (per.Participant_Contact__r.PPM_ID__c != null) {
                fetchconsentsfromUCPM = true;
                gen.writeStartObject();
                gen.writeStringField('ppmid', per.Participant_Contact__r.PPM_ID__c);
                gen.writeStringField('participantPPMID', '');
                gen.writeStringField('applicationId', per.Participant_Contact__c);
                gen.writeEndObject();
            }
    
            if (pderIdList != null && pderIdList.size() > 0) {
                for (Patient_Delegate_Enrollment__c pde : per.Patient_Delegate_Enrollments__r) {
                    if (pde.PPM_ID__c != null) {
                        if(!fetchconsentsfromUCPM){
                            fetchconsentsfromUCPM = true;
                        }
                        gen.writeStartObject();
                        gen.writeStringField('ppmid', pde.PPM_ID__c);
                        gen.writeStringField(
                            'participantPPMID',
                            pde.Participant_Enrollment__r.PPMID__c
                        );
                        gen.writeStringField('applicationId', pde.Id);
                        gen.writeEndObject();
                    }
                    if(pde.Patient_Delegate__r.Contact__r.PPM_ID__c != null){
                        if(!fetchconsentsfromUCPM){
                            fetchconsentsfromUCPM = true;
                        }
                        gen.writeStartObject();
                        gen.writeStringField('ppmid', pde.Patient_Delegate__r.Contact__r.PPM_ID__c);
                        gen.writeStringField(
                            'participantPPMID',
                            pde.Participant_Enrollment__r.PPMID__c
                        );
                        gen.writeStringField('applicationId', pde.Patient_Delegate__r.Contact__c);
                        gen.writeEndObject();
                    }
                }
            }
    
            gen.writeEndArray();
            requestString = gen.getAsString();
            System.debug('requestBody: ' + requestString);
        }else if(conId != null && PerId == null){
            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartArray();
            for ( Participant_Enrollment__c perRec : listPE) {
                if (perRec.PPMID__c != null) {
                    if(!fetchconsentsfromUCPM){
                        fetchconsentsfromUCPM = true;
                    }
                    gen.writeStartObject();
                    gen.writeStringField('ppmid', perRec.PPMID__c);
                    gen.writeStringField('participantPPMID', '');
                    gen.writeStringField('applicationId', perRec.Id);
                    gen.writeEndObject();
                }
            }
            for ( Patient_Delegate_Enrollment__c pder : pdeList) {
                if (pder.PPM_ID__c != null) {
                    if(!fetchconsentsfromUCPM){
                        fetchconsentsfromUCPM = true;
                    }
                    gen.writeStartObject();
                    gen.writeStringField('ppmid', pder.PPM_ID__c);
                    gen.writeStringField('participantPPMID', pder.Participant_Enrollment__r.PPMID__c);
                    gen.writeStringField('applicationId', pder.Id);
                    gen.writeEndObject();
                }
            }
            if(listPE[0].Participant_Contact__r.PPM_ID__c != null){
                if(!fetchconsentsfromUCPM){
                    fetchconsentsfromUCPM = true;
                }
                gen.writeStartObject();
                gen.writeStringField('ppmid', listPE[0].Participant_Contact__r.PPM_ID__c);
                gen.writeStringField('participantPPMID', '');
                gen.writeStringField('applicationId', listPE[0].Participant_Contact__c);
                gen.writeEndObject();
            }
            gen.writeEndArray();
            requestString = gen.getAsString();

        }

        if(fetchconsentsfromUCPM){
            
            String accessToken;
            accessToken = getAccessToken();
            DateTime dt = DateTime.now();
    
            //Integration log insertion
            IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
            objIntegrationLog.Request_Body__c = requestString;
            objIntegrationLog.Request_Time__c = dt;
            objIntegrationLog.Request_Type__c = 'UCPM_Fetch_Consent';
            objIntegrationLog.Function_Name__c = 'UCPM_Fetch_Consent';
            objIntegrationLog.Http_Method__c = 'POST';
    
            //Call Mulesoft-UCPM API for consents
            HTTP h = new HTTP();
            HTTPRequest r = new HTTPRequest();
            r.setEndpoint('callout:UCPM_Fetch_Consent');
            r.setHeader('Content-Type', 'application/json;charset=UTF-8');
            r.setMethod('POST');
            r.setHeader('Authorization', 'Bearer ' + accessToken);
            r.setbody(requestString);
            r.setHeader('identityType', 'PARTICIPANT');
            r.setHeader('tid', MulesoftIntegrationApi.uniqueKeygeneration());
    
            System.debug('###### request ' + r.getBody());
    
            HTTPResponse resp = h.send(r);
            System.debug('###### resp ' + resp);
            System.debug('200 ' + resp.getBody());
    
            objIntegrationLog.Response_Body__c = resp.getBody();
            objIntegrationLog.Response_Status__c = resp.getStatus();
            objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();
    
            if (resp.getStatusCode() == 200) {
                System.debug('200 ' + resp.getBody());
                objIntegrationLog.Success__c = true;
                responseBody = resp.getBody();
    
                // Response code starts here
                UCPM_FetchLatestConsents responseWrapper = (UCPM_FetchLatestConsents) JSON.deserialize(
                    responseBody,
                    UCPM_FetchLatestConsents.class
                );
                // call method to update local records
                updateRecords(responseWrapper);
                insert objIntegrationLog;
            } else {
                objIntegrationLog.Success__c = false;
                insert objIntegrationLog;
            }
        }

    }
    public static void updateRecords(UCPM_FetchLatestConsents consentWrapper) {
        // Bypass triggers
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.UpdateConsentTimeStamps.class);
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.CreateUserForCCContactHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.PopulateOverrideFields.class);
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.UpdatePhoneNumberContactsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.CreateUserForDelegateContactHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.CreateUserForDelegateContactHandler.class
        );
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
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.EcoaEvents.class);
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.DefaultEcoaTask.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.StudyConsentTimestamps.class
        );

        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateEnrolTriggerHandler.updateConsentTimeStamps.class
        );

        // Collect all ppmids to to retrieve the records
        List<String> ppmIdList = new List<String>();
        for (payload payload : consentWrapper.payload) {
            system.debug('payload: ' + payload);
            ppmIdList.add(payload.requestPPMID);
        }

        Map<String, Contact> ppmtoConMap = new Map<String, Contact>();
        for (Contact con : [
            SELECT
                Id,
                PPM_ID__c,
                Participant_Opt_In_Status_Emails__c,
                Participant_Opt_In_Status_SMS__c,
                Participant_Phone_Opt_In_Permit_Phone__c,
                IQVIA_Direct_Mail_Consent__c,
                IQVIA_Email_Consent_Time__c,
                IQVIA_SMS_Consent_Time__c,
                IQVIA_Direct_Mail_Consent_Time__c,
                IQVIA_Phone_Consent_Time__c
            FROM Contact
            WHERE PPM_ID__c IN :ppmIdList
        ]) {
            ppmtoConMap.put(con.PPM_ID__c, con);
        }

        Map<String, Participant_Enrollment__c> ppmtoPerMap = new Map<String, Participant_Enrollment__c>();
        for (Participant_Enrollment__c per : [
            SELECT
                Id,
                PPMID__c,
                Permit_Mail_Email_contact_for_this_study__c,
                Permit_SMS_Text_for_this_study__c,
                Permit_Voice_Text_contact_for_this_study__c,
                Study_Direct_Mail_Consent__c,
                Study_Email_Consent_Time__c,
                Study_Phone_Consent_Time__c,
                Study_Direct_Mail_Consent_Time__c,
                Study_SMS_Consent_Time__c,
                Participant_Contact__r.PPM_ID__c,
                Participant_Contact__r.Participant_Opt_In_Status_Emails__c,
                Participant_Contact__r.Participant_Opt_In_Status_SMS__c,
                Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
                Participant_Contact__r.IQVIA_Direct_Mail_Consent__c,
                Participant_Contact__r.IQVIA_SMS_Consent_Time__c,
                Participant_Contact__r.IQVIA_Phone_Consent_Time__c,
                Participant_Contact__r.IQVIA_Email_Consent_Time__c,
                Participant_Contact__r.IQVIA_Direct_Mail_Consent_Time__c
            FROM Participant_Enrollment__c
            WHERE PPMID__c IN :ppmIdList
        ]) {
            ppmtoPerMap.put(per.PPMID__c, per);
        }
        System.debug('ppmtoPerMap--->' + ppmtoPerMap);

        Map<String, Patient_Delegate_Enrollment__c> ppmtoPdeMap = new Map<String, Patient_Delegate_Enrollment__c>();
        for (Patient_Delegate_Enrollment__c pde : [
            SELECT
                Id,
                PPM_ID__c,
                Study_Email_Consent__c,
                Study_SMS_Consent__c,
                Study_Phone_Consent__c,
                Study_Direct_Mail_Consent__c,
                Study_SMS_Consent_Time__c,
                Study_Email_Consent_Time__c,
                Study_Phone_Consent_Time__c,
                Study_Direct_Mail_Consent_Time__c,
                Patient_Delegate__r.Participant__r.Contact__c,
                Patient_Delegate__r.Participant__r.Contact__r.PPM_ID__c,
                Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_SMS__c,
                Patient_Delegate__r.Participant__r.Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
                Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Direct_Mail_Consent__c,
                Patient_Delegate__r.Participant__r.Contact__r.IQVIA_SMS_Consent_Time__c,
                Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Phone_Consent_Time__c,
                Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Email_Consent_Time__c,
                Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Direct_Mail_Consent_Time__c
            FROM Patient_Delegate_Enrollment__c
            WHERE PPM_ID__c IN :ppmIdList
        ]) {
            ppmtoPdeMap.put(pde.PPM_ID__c, pde);
        }
        System.debug('ppmtoPdeMap--->' + ppmtoPdeMap);

        List<Sobject> conList = new List<Sobject>();
        List<Sobject> perList = new List<Sobject>();
        List<Sobject> pdeList = new List<Sobject>();

        for (payload payload : consentWrapper.payload) {
            // system.debug('payload: '+payload);
            if (payload.Purposes != null) {
                for (Purposes purpose : payload.Purposes) {
                    system.debug('purpose: ' + purpose);

                    for (CustomPreferences customPreference : purpose.CustomPreferences) {
                        system.debug('customPreference: ' + customPreference);

                        for (Options option : customPreference.Options) {
                            system.debug('Options: ' + option);
                            //If ppmId from PER record
                            System.debug('ppmId --->' + payload.requestPPMID);
                            if (ppmtoPerMap.containsKey(payload.requestPPMID)) {
                                Participant_Enrollment__c per = ppmtoPerMap.get(
                                    payload.requestPPMID
                                );
                                if (customPreference.Name == 'Communication-Consents') {
                                    if (option.Name == 'sms') {
                                        //Check if consent is changed
                                        if (
                                            per.Permit_SMS_Text_for_this_study__c !=
                                            option.IsConsented
                                        ) {
                                            per.Permit_SMS_Text_for_this_study__c = option.IsConsented;
                                            per.Study_SMS_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!perList.contains(per)) {
                                                perList.add(per);
                                            }
                                        }
                                    } else if (option.Name == 'email') {
                                        System.debug('inside per email');
                                        //Check if consent is changed
                                        if (
                                            per.Permit_Mail_Email_contact_for_this_study__c !=
                                            option.IsConsented
                                        ) {
                                            System.debug('inside per email 1');
                                            per.Permit_Mail_Email_contact_for_this_study__c = option.IsConsented;
                                            per.Study_Email_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!perList.contains(per)) {
                                                perList.add(per);
                                            }
                                        }
                                    } else if (option.Name == 'phone') {
                                        System.debug('inside per phone');
                                        //Check if consent is changed
                                        if (
                                            per.Permit_Voice_Text_contact_for_this_study__c !=
                                            option.IsConsented
                                        ) {
                                            System.debug('inside per phone 1');
                                            per.Permit_Voice_Text_contact_for_this_study__c = option.IsConsented;
                                            per.Study_Phone_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!perList.contains(per)) {
                                                perList.add(per);
                                            }
                                        }
                                    } else if (option.Name == 'directMail') {
                                        //Check if consent is changed
                                        if (
                                            per.Study_Direct_Mail_Consent__c != option.IsConsented
                                        ) {
                                            per.Study_Direct_Mail_Consent__c = option.IsConsented;
                                            per.Study_Direct_Mail_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!perList.contains(per)) {
                                                perList.add(per);
                                            }
                                        }
                                    }
                                } else if (customPreference.Name == 'IQVIA-Outreach-Consents') {
                                    if (option.Name == 'sms') {
                                        //Check if consent is changed
                                        if (
                                            per.Participant_Contact__r.Participant_Opt_In_Status_SMS__c !=
                                            option.IsConsented
                                        ) {
                                            per.Participant_Contact__r.Participant_Opt_In_Status_SMS__c = option.IsConsented;
                                            per.Participant_Contact__r.IQVIA_SMS_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!perList.contains(per)) {
                                                perList.add(per);
                                            }
                                        }
                                    } else if (option.Name == 'email') {
                                        //Check if consent is changed
                                        if (
                                            per.Participant_Contact__r.Participant_Opt_In_Status_Emails__c !=
                                            option.IsConsented
                                        ) {
                                            per.Participant_Contact__r.Participant_Opt_In_Status_Emails__c = option.IsConsented;
                                            per.Participant_Contact__r.IQVIA_Email_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!perList.contains(per)) {
                                                perList.add(per);
                                            }
                                        }
                                    } else if (option.Name == 'phone') {
                                        //Check if consent is changed
                                        if (
                                            per.Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c !=
                                            option.IsConsented
                                        ) {
                                            per.Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c = option.IsConsented;
                                            per.Participant_Contact__r.IQVIA_Phone_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!perList.contains(per)) {
                                                perList.add(per);
                                            }
                                        }
                                    } else if (option.Name == 'directMail') {
                                        //Check if consent is changed
                                        if (
                                            per.Participant_Contact__r.IQVIA_Direct_Mail_Consent__c !=
                                            option.IsConsented
                                        ) {
                                            per.Participant_Contact__r.IQVIA_Direct_Mail_Consent__c = option.IsConsented;
                                            per.Participant_Contact__r.IQVIA_Direct_Mail_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!perList.contains(per)) {
                                                perList.add(per);
                                            }
                                        }
                                    }
                                }
                            }
                            // If ppmId from PDE record
                            else if (ppmtoPdeMap.containsKey(payload.requestPPMID)) {
                                Patient_Delegate_Enrollment__c pde = ppmtoPdeMap.get(
                                    payload.requestPPMID
                                );
                                if (customPreference.Name == 'Communication-Consents') {
                                    if (option.Name == 'sms') {
                                        //Check if consent is changed
                                        if (pde.Study_SMS_Consent__c != option.IsConsented) {
                                            pde.Study_SMS_Consent__c = option.IsConsented;
                                            pde.Study_SMS_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!pdeList.contains(pde)) {
                                                pdeList.add(pde);
                                            }
                                        }
                                    } else if (option.Name == 'email') {
                                        //Check if consent is changed
                                        if (pde.Study_Email_Consent__c != option.IsConsented) {
                                            pde.Study_Email_Consent__c = option.IsConsented;
                                            pde.Study_Email_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!pdeList.contains(pde)) {
                                                pdeList.add(pde);
                                            }
                                        }
                                    } else if (option.Name == 'phone') {
                                        //Check if consent is changed
                                        if (pde.Study_Phone_Consent__c != option.IsConsented) {
                                            pde.Study_Phone_Consent__c = option.IsConsented;
                                            pde.Study_Phone_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!pdeList.contains(pde)) {
                                                pdeList.add(pde);
                                            }
                                        }
                                    } else if (option.Name == 'directMail') {
                                        //Check if consent is changed
                                        if (
                                            pde.Study_Direct_Mail_Consent__c != option.IsConsented
                                        ) {
                                            pde.Study_Direct_Mail_Consent__c = option.IsConsented;
                                            pde.Study_Direct_Mail_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!pdeList.contains(pde)) {
                                                pdeList.add(pde);
                                            }
                                        }
                                    }
                                } else if (customPreference.Name == 'IQVIA-Outreach-Consents') {
                                    if (option.Name == 'sms') {
                                        //Check if consent is changed
                                        if (
                                            pde.Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_SMS__c !=
                                            option.IsConsented
                                        ) {
                                            pde.Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_SMS__c = option.IsConsented;
                                            pde.Patient_Delegate__r.Participant__r.Contact__r.IQVIA_SMS_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!pdeList.contains(pde)) {
                                                pdeList.add(pde);
                                            }
                                        }
                                    } else if (option.Name == 'email') {
                                        //Check if consent is changed
                                        if (
                                            pde.Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c !=
                                            option.IsConsented
                                        ) {
                                            pde.Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c = option.IsConsented;
                                            pde.Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Email_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!pdeList.contains(pde)) {
                                                pdeList.add(pde);
                                            }
                                        }
                                    } else if (option.Name == 'phone') {
                                        //Check if consent is changed
                                        if (
                                            pde.Patient_Delegate__r.Participant__r.Contact__r.Participant_Phone_Opt_In_Permit_Phone__c !=
                                            option.IsConsented
                                        ) {
                                            pde.Patient_Delegate__r.Participant__r.Contact__r.Participant_Phone_Opt_In_Permit_Phone__c = option.IsConsented;
                                            pde.Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Phone_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!pdeList.contains(pde)) {
                                                pdeList.add(pde);
                                            }
                                        }
                                    } else if (option.Name == 'directMail') {
                                        //Check if consent is changed
                                        if (
                                            pde.Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Direct_Mail_Consent__c !=
                                            option.IsConsented
                                        ) {
                                            pde.Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Direct_Mail_Consent__c = option.IsConsented;
                                            pde.Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Direct_Mail_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!pdeList.contains(pde)) {
                                                pdeList.add(pde);
                                            }
                                        }
                                    }
                                }
                            }
                            // If ppmId from Contact record
                            else if (ppmtoConMap.containsKey(payload.requestPPMID)) {
                                Contact con = ppmtoConMap.get(payload.requestPPMID);
                                if (customPreference.Name == 'IQVIA-Outreach-Consents') {
                                    if (option.Name == 'sms') {
                                        //Check if consent is changed
                                        if (
                                            con.Participant_Opt_In_Status_SMS__c !=
                                            option.IsConsented
                                        ) {
                                            con.Participant_Opt_In_Status_SMS__c = option.IsConsented;
                                            con.IQVIA_SMS_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!conList.contains(con)) {
                                                conList.add(con);
                                            }
                                        }
                                    } else if (option.Name == 'email') {
                                        //Check if consent is changed
                                        if (
                                            con.Participant_Opt_In_Status_Emails__c !=
                                            option.IsConsented
                                        ) {
                                            con.Participant_Opt_In_Status_Emails__c = option.IsConsented;
                                            con.IQVIA_Email_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!conList.contains(con)) {
                                                conList.add(con);
                                            }
                                        }
                                    } else if (option.Name == 'phone') {
                                        //Check if consent is changed
                                        if (
                                            con.Participant_Phone_Opt_In_Permit_Phone__c !=
                                            option.IsConsented
                                        ) {
                                            con.Participant_Phone_Opt_In_Permit_Phone__c = option.IsConsented;
                                            con.IQVIA_Phone_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!conList.contains(con)) {
                                                conList.add(con);
                                            }
                                        }
                                    } else if (option.Name == 'directMail') {
                                        //Check if consent is changed
                                        if (
                                            con.IQVIA_Direct_Mail_Consent__c != option.IsConsented
                                        ) {
                                            con.IQVIA_Direct_Mail_Consent__c = option.IsConsented;
                                            con.IQVIA_Direct_Mail_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!conList.contains(con)) {
                                                conList.add(con);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        try {
            if (!perList.isEmpty()) {
                update perList;
            }
            if (!pdeList.isEmpty()) {
                update pdeList;
            }
            if (!conList.isEmpty()) {
                update conList;
            }
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
    public static ReturnResponse callUCPMtoFetchConsentdetails(
        Id PerId,
        List<Id> pderIdList,
        Id conId,
        Boolean isParticipant,
        String placeOffunctionality
    ) {
        String responseBody;
        Participant_Enrollment__c per;
        List<Patient_Delegate_Enrollment__c> pdeList = new List<Patient_Delegate_Enrollment__c>();
        List<Participant_Enrollment__c> listPE = new List<Participant_Enrollment__c>();
        if(conId != null && PerId == null){
            listPE = [Select Id,PPMID__c,Participant_Contact__c,Participant_Contact__r.PPM_ID__c
                      from Participant_Enrollment__c where 
                      Participant_Contact__c =:conId AND Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = true AND Participant_Status__c NOT IN:PEStatusState.PE_STATUS_GROUP_ALUMNI AND Invited_To_PP_Date__c != null AND
                      (Clinical_Trial_Profile__r.CommunityTemplate__c = 'PatientPortal' OR (Clinical_Trial_Profile__r.CommunityTemplate__c = 'Janssen' AND Clinical_Trial_Profile__r.PPTemplate__c = 'PP 2.0'))
                    ]; 
            if(!isParticipant){
                pdeList = [Select Id,PPM_ID__c,Participant_Enrollment__r.PPMID__c,Patient_Delegate__r.Contact__r.PPM_ID__c,Patient_Delegate__r.Contact__c from Patient_Delegate_Enrollment__c
                where Patient_Delegate__r.Contact__c =:conId AND Status__c = 'Active' AND
                (Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c = 'PatientPortal' OR (Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c = 'Janssen' AND Participant_Enrollment__r.Clinical_Trial_Profile__r.PPTemplate__c = 'PP 2.0'))
               ];
            }  
        }
        else if (pderIdList != null && pderIdList.size() > 0) {
            per = [
                SELECT
                    id,
                    PPMID__c,
                    Participant_Contact__c,
                    Participant_Contact__r.PPM_ID__c,
                    Clinical_Trial_Profile__r.Study_Sponsor__c,
                    Clinical_Trial_Profile__c,
                    (
                        SELECT id, PPM_ID__c, Participant_Enrollment__r.PPMID__c,Patient_Delegate__r.Contact__r.PPM_ID__c,Patient_Delegate__r.Contact__c
                        FROM Patient_Delegate_Enrollments__r
                        WHERE Id IN :pderIdList
                    )
                FROM Participant_Enrollment__c
                WHERE id = :PerId
            ];
        } else {
            per = [
                SELECT
                    id,
                    PPMID__c,
                    Participant_Contact__c,
                    Participant_Contact__r.PPM_ID__c,
                    Clinical_Trial_Profile__r.Study_Sponsor__c,
                    Clinical_Trial_Profile__c
                FROM Participant_Enrollment__c
                WHERE id = :PerId
            ];
        }

        Boolean fetchconsentsfromUCPM = false;
        String requestString;
        if(conId == null && PerId != null){
            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartArray();
    
            if (per.PPMID__c != null) {
                fetchconsentsfromUCPM = true;
                gen.writeStartObject();
                gen.writeStringField('ppmid', per.PPMID__c);
                gen.writeStringField('participantPPMID', '');
                gen.writeStringField('applicationId', per.Id);
                gen.writeEndObject();
            }
    
            if (per.Participant_Contact__r.PPM_ID__c != null) {
                fetchconsentsfromUCPM = true;
                gen.writeStartObject();
                gen.writeStringField('ppmid', per.Participant_Contact__r.PPM_ID__c);
                gen.writeStringField('participantPPMID', '');
                gen.writeStringField('applicationId', per.Participant_Contact__c);
                gen.writeEndObject();
            }
    
            if (pderIdList != null && pderIdList.size() > 0) {
                for (Patient_Delegate_Enrollment__c pde : per.Patient_Delegate_Enrollments__r) {
                    if (pde.PPM_ID__c != null) {
                        if(!fetchconsentsfromUCPM){
                            fetchconsentsfromUCPM = true;
                        }
                        gen.writeStartObject();
                        gen.writeStringField('ppmid', pde.PPM_ID__c);
                        gen.writeStringField(
                            'participantPPMID',
                            pde.Participant_Enrollment__r.PPMID__c
                        );
                        gen.writeStringField('applicationId', pde.Id);
                        gen.writeEndObject();
                    }
                    if(pde.Patient_Delegate__r.Contact__r.PPM_ID__c != null){
                        if(!fetchconsentsfromUCPM){
                            fetchconsentsfromUCPM = true;
                        }
                        gen.writeStartObject();
                        gen.writeStringField('ppmid', pde.Patient_Delegate__r.Contact__r.PPM_ID__c);
                        gen.writeStringField(
                            'participantPPMID',
                            pde.Participant_Enrollment__r.PPMID__c
                        );
                        gen.writeStringField('applicationId', pde.Patient_Delegate__r.Contact__c);
                        gen.writeEndObject();
                    }
                }
            }
    
            gen.writeEndArray();
            requestString = gen.getAsString();
            System.debug('requestBody: ' + requestString);
        }else if(conId != null && PerId == null){
            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartArray();
            for ( Participant_Enrollment__c perRec : listPE) {
                if (perRec.PPMID__c != null) {
                    if(!fetchconsentsfromUCPM){
                        fetchconsentsfromUCPM = true;
                    }
                    gen.writeStartObject();
                    gen.writeStringField('ppmid', perRec.PPMID__c);
                    gen.writeStringField('participantPPMID', '');
                    gen.writeStringField('applicationId', perRec.Id);
                    gen.writeEndObject();
                }
            }
            for ( Patient_Delegate_Enrollment__c pder : pdeList) {
                if (pder.PPM_ID__c != null) {
                    if(!fetchconsentsfromUCPM){
                        fetchconsentsfromUCPM = true;
                    }
                    gen.writeStartObject();
                    gen.writeStringField('ppmid', pder.PPM_ID__c);
                    gen.writeStringField('participantPPMID', pder.Participant_Enrollment__r.PPMID__c);
                    gen.writeStringField('applicationId', pder.Id);
                    gen.writeEndObject();
                }
            }
            system.debug('+++++++++++++'+listPE);
            if(listPE != null && !listPE.isEmpty()  && listPE[0].Participant_Contact__r.PPM_ID__c != null){
                if(!fetchconsentsfromUCPM){
                    fetchconsentsfromUCPM = true;
                }
                gen.writeStartObject();
                gen.writeStringField('ppmid', listPE[0].Participant_Contact__r.PPM_ID__c);
                gen.writeStringField('participantPPMID', '');
                gen.writeStringField('applicationId', listPE[0].Participant_Contact__c);
                gen.writeEndObject();
            }else if(pdeList != null && !pdeList.isEmpty() && pdeList[0].Patient_Delegate__r.Contact__r.PPM_ID__c != null){
                if(!fetchconsentsfromUCPM){
                    fetchconsentsfromUCPM = true;
                }
                gen.writeStartObject();
                gen.writeStringField('ppmid', pdeList[0].Patient_Delegate__r.Contact__r.PPM_ID__c);
                gen.writeStringField('participantPPMID', '');
                gen.writeStringField('applicationId', pdeList[0].Patient_Delegate__r.Contact__c);
                gen.writeEndObject();
            }
            gen.writeEndArray();
            requestString = gen.getAsString();

        }
        ReturnResponse rr = new ReturnResponse();
        if(fetchconsentsfromUCPM){
            
            String accessToken;
            accessToken = getAccessToken();
            DateTime dt = DateTime.now();
    
            //Integration log insertion
            IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
            objIntegrationLog.Request_Body__c = requestString;
            objIntegrationLog.Request_Time__c = dt;
            objIntegrationLog.Request_Type__c = 'UCPM_Fetch_Consent';
            objIntegrationLog.Function_Name__c = 'UCPM_Fetch_Consent';
            objIntegrationLog.Http_Method__c = 'POST';
    
            //Call Mulesoft-UCPM API for consents
            HTTP h = new HTTP();
            HTTPRequest r = new HTTPRequest();
            r.setEndpoint('callout:UCPM_Fetch_Consent');
            r.setHeader('Content-Type', 'application/json;charset=UTF-8');
            r.setMethod('POST');
            r.setHeader('Authorization', 'Bearer ' + accessToken);
            r.setbody(requestString);
            r.setHeader('identityType', 'PARTICIPANT');
            r.setHeader('tid', MulesoftIntegrationApi.uniqueKeygeneration());
    
            System.debug('###### request ' + r.getBody());
    
            HTTPResponse resp = h.send(r);
            System.debug('###### resp ' + resp);
            System.debug('200 ' + resp.getBody());
    
            objIntegrationLog.Response_Body__c = resp.getBody();
            objIntegrationLog.Response_Status__c = resp.getStatus();
            objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();
            if (resp.getStatusCode() == 200) {
                System.debug('200 ' + resp.getBody());
                objIntegrationLog.Success__c = true;
                responseBody = resp.getBody();
    
                // Response code starts here
                UCPM_FetchLatestConsents responseWrapper = (UCPM_FetchLatestConsents) JSON.deserialize(
                    responseBody,
                    UCPM_FetchLatestConsents.class
                );
                // call method to update local records
                rr = updateRecordsReturn(responseWrapper);
                rr.log = objIntegrationLog;
            } else {
                objIntegrationLog.Success__c = false;
                rr.log = objIntegrationLog;
            }
        }
        return rr;

    }
    public static ReturnResponse updateRecordsReturn(UCPM_FetchLatestConsents consentWrapper) {
        // Bypass triggers
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.UpdateConsentTimeStamps.class);
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.CreateUserForCCContactHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.PopulateOverrideFields.class);
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.UpdatePhoneNumberContactsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.CreateUserForDelegateContactHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.CreateUserForDelegateContactHandler.class
        );
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
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.EcoaEvents.class);
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.DefaultEcoaTask.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.StudyConsentTimestamps.class
        );

        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateEnrolTriggerHandler.updateConsentTimeStamps.class
        );

        // Collect all ppmids to to retrieve the records
        List<String> ppmIdList = new List<String>();
        for (payload payload : consentWrapper.payload) {
            system.debug('payload: ' + payload);
            ppmIdList.add(payload.requestPPMID);
        }

        Map<String, Contact> ppmtoConMap = new Map<String, Contact>();
        for (Contact con : [
            SELECT
                Id,
                PPM_ID__c,
                Participant_Opt_In_Status_Emails__c,
                Participant_Opt_In_Status_SMS__c,
                Participant_Phone_Opt_In_Permit_Phone__c,
                IQVIA_Direct_Mail_Consent__c,
                IQVIA_Email_Consent_Time__c,
                IQVIA_SMS_Consent_Time__c,
                IQVIA_Direct_Mail_Consent_Time__c,
                IQVIA_Phone_Consent_Time__c
            FROM Contact
            WHERE PPM_ID__c IN :ppmIdList
        ]) {
            ppmtoConMap.put(con.PPM_ID__c, con);
        }

        Map<String, Participant_Enrollment__c> ppmtoPerMap = new Map<String, Participant_Enrollment__c>();
        for (Participant_Enrollment__c per : [
            SELECT
                Id,
                PPMID__c,
                Permit_Mail_Email_contact_for_this_study__c,
                Permit_SMS_Text_for_this_study__c,
                Permit_Voice_Text_contact_for_this_study__c,
                Study_Direct_Mail_Consent__c,
                Study_Email_Consent_Time__c,
                Study_Phone_Consent_Time__c,
                Study_Direct_Mail_Consent_Time__c,
                Study_SMS_Consent_Time__c,
                Participant_Contact__r.PPM_ID__c,
                Participant_Contact__r.Participant_Opt_In_Status_Emails__c,
                Participant_Contact__r.Participant_Opt_In_Status_SMS__c,
                Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
                Participant_Contact__r.IQVIA_Direct_Mail_Consent__c,
                Participant_Contact__r.IQVIA_SMS_Consent_Time__c,
                Participant_Contact__r.IQVIA_Phone_Consent_Time__c,
                Participant_Contact__r.IQVIA_Email_Consent_Time__c,
                Participant_Contact__r.IQVIA_Direct_Mail_Consent_Time__c
            FROM Participant_Enrollment__c
            WHERE PPMID__c IN :ppmIdList
        ]) {
            ppmtoPerMap.put(per.PPMID__c, per);
        }
        System.debug('ppmtoPerMap--->' + ppmtoPerMap);

        Map<String, Patient_Delegate_Enrollment__c> ppmtoPdeMap = new Map<String, Patient_Delegate_Enrollment__c>();
        for (Patient_Delegate_Enrollment__c pde : [
            SELECT
                Id,
                PPM_ID__c,
                Study_Email_Consent__c,
                Study_SMS_Consent__c,
                Study_Phone_Consent__c,
                Study_Direct_Mail_Consent__c,
                Study_SMS_Consent_Time__c,
                Study_Email_Consent_Time__c,
                Study_Phone_Consent_Time__c,
                Study_Direct_Mail_Consent_Time__c,
                Patient_Delegate__r.Participant__r.Contact__c,
                Patient_Delegate__r.Participant__r.Contact__r.PPM_ID__c,
                Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_SMS__c,
                Patient_Delegate__r.Participant__r.Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
                Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Direct_Mail_Consent__c,
                Patient_Delegate__r.Participant__r.Contact__r.IQVIA_SMS_Consent_Time__c,
                Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Phone_Consent_Time__c,
                Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Email_Consent_Time__c,
                Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Direct_Mail_Consent_Time__c
            FROM Patient_Delegate_Enrollment__c
            WHERE PPM_ID__c IN :ppmIdList
        ]) {
            ppmtoPdeMap.put(pde.PPM_ID__c, pde);
        }
        System.debug('ppmtoPdeMap--->' + ppmtoPdeMap);

        List<Sobject> conList = new List<Sobject>();
        List<Sobject> perList = new List<Sobject>();
        List<Sobject> pdeList = new List<Sobject>();

        for (payload payload : consentWrapper.payload) {
            // system.debug('payload: '+payload);
            if (payload.Purposes != null) {
                for (Purposes purpose : payload.Purposes) {
                    system.debug('purpose: ' + purpose);

                    for (CustomPreferences customPreference : purpose.CustomPreferences) {
                        system.debug('customPreference: ' + customPreference);

                        for (Options option : customPreference.Options) {
                            system.debug('Options: ' + option);
                            //If ppmId from PER record
                            System.debug('ppmId --->' + payload.requestPPMID);
                            if (ppmtoPerMap.containsKey(payload.requestPPMID)) {
                                Participant_Enrollment__c per = ppmtoPerMap.get(
                                    payload.requestPPMID
                                );
                                if (customPreference.Name == 'Communication-Consents') {
                                    if (option.Name == 'sms') {
                                        //Check if consent is changed
                                        if (
                                            per.Permit_SMS_Text_for_this_study__c !=
                                            option.IsConsented
                                        ) {
                                            per.Permit_SMS_Text_for_this_study__c = option.IsConsented;
                                            per.Study_SMS_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!perList.contains(per)) {
                                                perList.add(per);
                                            }
                                        }
                                    } else if (option.Name == 'email') {
                                        System.debug('inside per email');
                                        //Check if consent is changed
                                        if (
                                            per.Permit_Mail_Email_contact_for_this_study__c !=
                                            option.IsConsented
                                        ) {
                                            System.debug('inside per email 1');
                                            per.Permit_Mail_Email_contact_for_this_study__c = option.IsConsented;
                                            per.Study_Email_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!perList.contains(per)) {
                                                perList.add(per);
                                            }
                                        }
                                    } else if (option.Name == 'phone') {
                                        System.debug('inside per phone');
                                        //Check if consent is changed
                                        if (
                                            per.Permit_Voice_Text_contact_for_this_study__c !=
                                            option.IsConsented
                                        ) {
                                            System.debug('inside per phone 1');
                                            per.Permit_Voice_Text_contact_for_this_study__c = option.IsConsented;
                                            per.Study_Phone_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!perList.contains(per)) {
                                                perList.add(per);
                                            }
                                        }
                                    } else if (option.Name == 'directMail') {
                                        //Check if consent is changed
                                        if (
                                            per.Study_Direct_Mail_Consent__c != option.IsConsented
                                        ) {
                                            per.Study_Direct_Mail_Consent__c = option.IsConsented;
                                            per.Study_Direct_Mail_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!perList.contains(per)) {
                                                perList.add(per);
                                            }
                                        }
                                    }
                                } else if (customPreference.Name == 'IQVIA-Outreach-Consents') {
                                    if (option.Name == 'sms') {
                                        //Check if consent is changed
                                        if (
                                            per.Participant_Contact__r.Participant_Opt_In_Status_SMS__c !=
                                            option.IsConsented
                                        ) {
                                            per.Participant_Contact__r.Participant_Opt_In_Status_SMS__c = option.IsConsented;
                                            per.Participant_Contact__r.IQVIA_SMS_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!perList.contains(per)) {
                                                perList.add(per);
                                            }
                                        }
                                    } else if (option.Name == 'email') {
                                        //Check if consent is changed
                                        if (
                                            per.Participant_Contact__r.Participant_Opt_In_Status_Emails__c !=
                                            option.IsConsented
                                        ) {
                                            per.Participant_Contact__r.Participant_Opt_In_Status_Emails__c = option.IsConsented;
                                            per.Participant_Contact__r.IQVIA_Email_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!perList.contains(per)) {
                                                perList.add(per);
                                            }
                                        }
                                    } else if (option.Name == 'phone') {
                                        //Check if consent is changed
                                        if (
                                            per.Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c !=
                                            option.IsConsented
                                        ) {
                                            per.Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c = option.IsConsented;
                                            per.Participant_Contact__r.IQVIA_Phone_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!perList.contains(per)) {
                                                perList.add(per);
                                            }
                                        }
                                    } else if (option.Name == 'directMail') {
                                        //Check if consent is changed
                                        if (
                                            per.Participant_Contact__r.IQVIA_Direct_Mail_Consent__c !=
                                            option.IsConsented
                                        ) {
                                            per.Participant_Contact__r.IQVIA_Direct_Mail_Consent__c = option.IsConsented;
                                            per.Participant_Contact__r.IQVIA_Direct_Mail_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!perList.contains(per)) {
                                                perList.add(per);
                                            }
                                        }
                                    }
                                }
                            }
                            // If ppmId from PDE record
                            else if (ppmtoPdeMap.containsKey(payload.requestPPMID)) {
                                Patient_Delegate_Enrollment__c pde = ppmtoPdeMap.get(
                                    payload.requestPPMID
                                );
                                if (customPreference.Name == 'Communication-Consents') {
                                    if (option.Name == 'sms') {
                                        //Check if consent is changed
                                        if (pde.Study_SMS_Consent__c != option.IsConsented) {
                                            pde.Study_SMS_Consent__c = option.IsConsented;
                                            pde.Study_SMS_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!pdeList.contains(pde)) {
                                                pdeList.add(pde);
                                            }
                                        }
                                    } else if (option.Name == 'email') {
                                        //Check if consent is changed
                                        if (pde.Study_Email_Consent__c != option.IsConsented) {
                                            pde.Study_Email_Consent__c = option.IsConsented;
                                            pde.Study_Email_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!pdeList.contains(pde)) {
                                                pdeList.add(pde);
                                            }
                                        }
                                    } else if (option.Name == 'phone') {
                                        //Check if consent is changed
                                        if (pde.Study_Phone_Consent__c != option.IsConsented) {
                                            pde.Study_Phone_Consent__c = option.IsConsented;
                                            pde.Study_Phone_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!pdeList.contains(pde)) {
                                                pdeList.add(pde);
                                            }
                                        }
                                    } else if (option.Name == 'directMail') {
                                        //Check if consent is changed
                                        if (
                                            pde.Study_Direct_Mail_Consent__c != option.IsConsented
                                        ) {
                                            pde.Study_Direct_Mail_Consent__c = option.IsConsented;
                                            pde.Study_Direct_Mail_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!pdeList.contains(pde)) {
                                                pdeList.add(pde);
                                            }
                                        }
                                    }
                                } else if (customPreference.Name == 'IQVIA-Outreach-Consents') {
                                    if (option.Name == 'sms') {
                                        //Check if consent is changed
                                        if (
                                            pde.Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_SMS__c !=
                                            option.IsConsented
                                        ) {
                                            pde.Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_SMS__c = option.IsConsented;
                                            pde.Patient_Delegate__r.Participant__r.Contact__r.IQVIA_SMS_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!pdeList.contains(pde)) {
                                                pdeList.add(pde);
                                            }
                                        }
                                    } else if (option.Name == 'email') {
                                        //Check if consent is changed
                                        if (
                                            pde.Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c !=
                                            option.IsConsented
                                        ) {
                                            pde.Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c = option.IsConsented;
                                            pde.Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Email_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!pdeList.contains(pde)) {
                                                pdeList.add(pde);
                                            }
                                        }
                                    } else if (option.Name == 'phone') {
                                        //Check if consent is changed
                                        if (
                                            pde.Patient_Delegate__r.Participant__r.Contact__r.Participant_Phone_Opt_In_Permit_Phone__c !=
                                            option.IsConsented
                                        ) {
                                            pde.Patient_Delegate__r.Participant__r.Contact__r.Participant_Phone_Opt_In_Permit_Phone__c = option.IsConsented;
                                            pde.Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Phone_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!pdeList.contains(pde)) {
                                                pdeList.add(pde);
                                            }
                                        }
                                    } else if (option.Name == 'directMail') {
                                        //Check if consent is changed
                                        if (
                                            pde.Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Direct_Mail_Consent__c !=
                                            option.IsConsented
                                        ) {
                                            pde.Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Direct_Mail_Consent__c = option.IsConsented;
                                            pde.Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Direct_Mail_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!pdeList.contains(pde)) {
                                                pdeList.add(pde);
                                            }
                                        }
                                    }
                                }
                            }
                            // If ppmId from Contact record
                            else if (ppmtoConMap.containsKey(payload.requestPPMID)) {
                                Contact con = ppmtoConMap.get(payload.requestPPMID);
                                if (customPreference.Name == 'IQVIA-Outreach-Consents') {
                                    if (option.Name == 'sms') {
                                        //Check if consent is changed
                                        if (
                                            con.Participant_Opt_In_Status_SMS__c !=
                                            option.IsConsented
                                        ) {
                                            con.Participant_Opt_In_Status_SMS__c = option.IsConsented;
                                            con.IQVIA_SMS_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!conList.contains(con)) {
                                                conList.add(con);
                                            }
                                        }
                                    } else if (option.Name == 'email') {
                                        //Check if consent is changed
                                        if (
                                            con.Participant_Opt_In_Status_Emails__c !=
                                            option.IsConsented
                                        ) {
                                            con.Participant_Opt_In_Status_Emails__c = option.IsConsented;
                                            con.IQVIA_Email_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!conList.contains(con)) {
                                                conList.add(con);
                                            }
                                        }
                                    } else if (option.Name == 'phone') {
                                        //Check if consent is changed
                                        if (
                                            con.Participant_Phone_Opt_In_Permit_Phone__c !=
                                            option.IsConsented
                                        ) {
                                            con.Participant_Phone_Opt_In_Permit_Phone__c = option.IsConsented;
                                            con.IQVIA_Phone_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!conList.contains(con)) {
                                                conList.add(con);
                                            }
                                        }
                                    } else if (option.Name == 'directMail') {
                                        //Check if consent is changed
                                        if (
                                            con.IQVIA_Direct_Mail_Consent__c != option.IsConsented
                                        ) {
                                            con.IQVIA_Direct_Mail_Consent__c = option.IsConsented;
                                            con.IQVIA_Direct_Mail_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                            if (!conList.contains(con)) {
                                                conList.add(con);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        try {
            /*if (!perList.isEmpty()) {
                update perList;
            }
            if (!pdeList.isEmpty()) {
                update pdeList;
            }
            if (!conList.isEmpty()) {
                update conList;
            }*/
            ReturnResponse rr = new ReturnResponse();
            rr.perslist = perList;
            rr.consList = conList;
            rr.pderslist = pdeList;
            return rr;
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
    }

    public class ReturnResponse{
        public list<Participant_Enrollment__c> perslist;
        public list<Contact> consList;
        public list<Patient_Delegate_Enrollment__c> pderslist;
        public IntegrationLog__c log;
    }

    public class ResponseWrapperToken {
        public String token_type;
        public String access_token;
        public Integer expires_in;
        public String message;
        public Boolean success;
        public Integer statusCode;
    }

    //Response wrapper start
    public class CustomPreferences {
        public String Name;
        public List<Options> Options;
    }

    public class Options {
        public String Name;
        public Boolean IsConsented;
    }

    public Integer total;
    public Integer success;
    public Integer failed;
    public List<Payload> payload;

    public class Payload {
        public String code;
        public String status;
        public String message;
        public String ppmid;
        public String Language;
        public string requestPPMID;
        public List<Purposes> Purposes;
    }

    public class Purposes {
        public String Name;
        public String  WithdrawalDate;
        public String ConsentDate;
        public String ExpiryDate;
        public List<CustomPreferences> CustomPreferences;
    }
    //Response wrapper end
}