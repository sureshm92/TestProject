public class UCPM_ConsentFetchController {
    // whatid Object Types
    private static final String PARTICIPANT_ENROLLMENT_OBJ_NAME = 'Participant_Enrollment__c';
    private static final String CLINICAL_TRIAL_PROFILE_OBJ_NAME = 'Clinical_Trial_Profile__c';
    private static final String STUDY_SITE_OBJ_NAME = 'Study_Site__c';
    private static final String HCP_ENROLLMENT_OBJ_NAME = 'HCP_Enrollment__c';
    private static final String SURVEY_INVITATION_OBJ_NAME = 'SurveyInvitation';
    private static final String CONTACT = 'Contact';
    private static final String TASK_OBJ_NAME = 'Task';
    private static final String PARTICIPANT_OBJ_NAME = 'Participant__c';
    private static final String CASE_OBJ_NAME = 'Case';
    private static final String TELEVISIT_OBJ_NAME = 'Televisit__c';
    private static final String TELEVISIT_ATTN_OBJ_NAME = 'Televisit_Attendee__c';
    private static final String PATIENT_DEL_ENROLLMENT = 'Patient_Delegate_Enrollment__c';
    private static String objTypeFinal;
    private static String identityType ='PARTICIPANT';

    //generate mulesoft access token
    public static String getAccessToken() {
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

        try{
           resp1= http1.send(request1);
           if (resp1.getStatusCode() == 200) {
            JsonParser parser = JSON.createParser(resp1.getBody());
            ResponseWrapperToken deserializedResponseWrapper = (ResponseWrapperToken) JSON.deserialize(
                resp1.getBody(),
                ResponseWrapperToken.class
            );
            accessToken = deserializedResponseWrapper.access_token;
        }
        }
        catch(exception e){
          //Integration log generation 
          IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
          objIntegrationLog.Response_Body__c = e.getMessage();
          objIntegrationLog.Function_Name__c = 'Access Token';
          objIntegrationLog.Success__c = false;
          insert objIntegrationLog;
        }
        
    
        return accessToken;
    }

    //@future(callout=true)
    public static returnValueWrapper callUCPMtoFetchConsents(
        List<id> ids,
        List<SObject> sobj,
        string typeName
    ) {
         TriggerHandlerExecutor.bypassHandler( 
            UCPM_UpdateConsentOptOutHandler.updateConsentPERtoUCPM.class
            );
        TriggerHandlerExecutor.bypassHandler( 
            UCPM_UpdateConsentOptOutHandler.updateConsentContacttoUCPM.class
            );
        TriggerHandlerExecutor.bypassHandler( 
            UCPM_UpdateConsentOptOutHandler.updateConsentPDERtoUCPM.class
            );
        //get mulesoft access token
        String accessToken;
        accessToken = getAccessToken();
        System.debug('accessToken ##: ' + accessToken);

        String objType;
        Map<id, List<SObject>> idbyObject = new Map<id, List<SObject>>();
        List<UCPMrequestBodyWrapper> requestBodyWrapperList = new List<UCPMrequestBodyWrapper>();
        List<id> perIDs = new List<id>();
        List<Id> participantIdList = new List<Id>();
        List<Id> ctpIdList = new List<Id>();
        List<Id> taskIdList = new List<Id>();
        List<Id> surveyInvitationIdList = new List<Id>();
        List<Id> ownerIdList = new List<Id>();
        List<Id> televisitIdList = new List<Id>();
        List<Id> televisitAttendeeIdList = new List<Id>();
        List<Id> pderIdList = new List<Id>();
        List<Id> conListId = new List<Id>();
        String responseBody;

        if (ids == null && sobj != null && typeName == 'notificationbatch') {
            for (SObject so : sobj) {
                objType = String.valueOf(so.getSobjectType());
                if (objType == PARTICIPANT_ENROLLMENT_OBJ_NAME) {
                    Id perid = (String) so.get('id');
                    perIDs.add(perid);
                    objTypeFinal = PARTICIPANT_ENROLLMENT_OBJ_NAME;
                    identityType ='PARTICIPANT';
                }
                else if (objType == PATIENT_DEL_ENROLLMENT) {
                    Id pdeID = (String) so.get('id');
                    pderIdList.add(pdeID);
                    objTypeFinal = PATIENT_DEL_ENROLLMENT;
                    identityType ='DELEGATE';
                } else if (objType == SURVEY_INVITATION_OBJ_NAME) {
                    Id surveyID = (String) so.get('id');
                    surveyInvitationIdList.add(surveyID);
                    objTypeFinal = SURVEY_INVITATION_OBJ_NAME;
                    identityType ='PARTICIPANT';
                } else if (objType == CONTACT) {
                    Id conID = (String) so.get('id');
                    conListId.add(conID);
                    objTypeFinal = CONTACT;
                    identityType ='PARTICIPANT';
                } else if (objType == PARTICIPANT_OBJ_NAME) {
                    Id partID = (String) so.get('id');
                    participantIdList.add(partID);
                    objTypeFinal = PARTICIPANT_OBJ_NAME;
                    identityType ='PARTICIPANT';
                }
            }
            List<Participant_Enrollment__c> perList = [
                SELECT
                    id,
                    PPMID__c,
                    Participant_Contact__r.PPM_ID__c,
                    Clinical_Trial_Profile__r.Study_Sponsor__c,
                    Clinical_Trial_Profile__c,
                    Clinical_Trial_Profile__r.Study_Code_Name__c,
                    Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c
                FROM Participant_Enrollment__c
                WHERE id = :perIDs
            ];
            Map<id, Participant_Enrollment__c> idTOpermap = new Map<id, Participant_Enrollment__c>();
            for (Participant_Enrollment__c p : perList) {
                idTOpermap.put(p.id, p);
            }
            List<Patient_Delegate_Enrollment__c> pderList = [
                SELECT
                    Id,
                    Participant_Enrollment__c,
                    PPM_ID__c,
                    Participant_Enrollment__r.PPMID__c,
                    Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Sponsor__c,
                    Participant_Enrollment__r.Clinical_Trial_Profile__c,
                    Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                    Participant_Enrollment__r.Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c
                FROM Patient_Delegate_Enrollment__c
                WHERE Id IN :pderIdList
            ];
            Map<id, Patient_Delegate_Enrollment__c> idTopdermap = new Map<id, Patient_Delegate_Enrollment__c>();
            for (Patient_Delegate_Enrollment__c pde : pderList) {
                idTopdermap.put(pde.id, pde);
            }
            List<Contact> conList = [
                SELECT Id, PPM_ID__c
                FROM Contact
                WHERE Id IN :conListId
            ];
            Map<id, Contact> idToConMap = new Map<id, Contact>();
            for (Contact c : conList) {
                idToConMap.put(c.id, c);
            }
            List<SurveyInvitation> surveyInvList = [
                SELECT
                    Id,
                    Participant_Enrollment__c,
                    Participant_Enrollment__r.PPMID__c,
                    Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Sponsor__c,
                    Participant_Enrollment__r.Clinical_Trial_Profile__c,
                    Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                    Participant_Enrollment__r.Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c
                FROM SurveyInvitation
                WHERE Id IN :surveyInvitationIdList
            ];
            Map<id, SurveyInvitation> idToSurveymap = new Map<id, SurveyInvitation>();
            for (SurveyInvitation s : surveyInvList) {
                idToSurveymap.put(s.id, s);
            }
            List<Participant__c> partList = [
                SELECT Id, Contact__c, Contact__r.PPM_ID__c
                FROM Participant__c
                WHERE Id IN :participantIdList
            ];
            Map<id, Participant__c> idToparticipantmap = new Map<id, Participant__c>();
            for (Participant__c part : partList) {
                idToparticipantmap.put(part.id, part);
            }
            for (SObject so : sobj) {
                UCPMrequestBodyWrapper requestBodyWrapper = new UCPMrequestBodyWrapper();
                objType = String.valueOf(so.getSobjectType());
                if (objType == PARTICIPANT_ENROLLMENT_OBJ_NAME) {
                    Id perid = (String) so.get('id');
                    Participant_Enrollment__c per = idTOpermap.get(perid); // sobject record
                    requestBodyWrapper.ppmid = per.PPMID__c;
                    requestBodyWrapper.participantPpmid = '';
                    requestBodyWrapper.applicationId=per.id;
                }
                else if (objType == PATIENT_DEL_ENROLLMENT) {
                    Id pdeid = (String) so.get('id');
                    Patient_Delegate_Enrollment__c pde = idTopdermap.get(pdeid); // sobject record
                    requestBodyWrapper.ppmid = pde.PPM_ID__c;
                    requestBodyWrapper.participantPpmid = pde.Participant_Enrollment__r.PPMID__c;
                    requestBodyWrapper.applicationId=pde.id;
                }
                else if (objType == PARTICIPANT_OBJ_NAME) {
                    Id partid = (String) so.get('id');
                    Participant__c p = idToparticipantmap.get(partid); // sobject record
                    requestBodyWrapper.ppmid = p.Contact__r.PPM_ID__c;
                    requestBodyWrapper.participantPpmid = '';
                    requestBodyWrapper.applicationId=p.id;
                } else if (objType == CONTACT) {
                    Id conid = (String) so.get('id');
                    Contact c = idToConMap.get(conid); // sobject record
                    requestBodyWrapper.ppmid = c.PPM_ID__c;
                    requestBodyWrapper.participantPpmid = '';
                    requestBodyWrapper.applicationId=c.id;
                } else if (objType == SURVEY_INVITATION_OBJ_NAME) {
                    Id surveyid = (String) so.get('id');
                    SurveyInvitation s = idToSurveymap.get(surveyid); // sobject record
                    requestBodyWrapper.ppmid = s.Participant_Enrollment__r.PPMID__c;
                    requestBodyWrapper.participantPpmid = '';
                    requestBodyWrapper.applicationId=s.id;
                }
                requestBodyWrapperList.add(requestBodyWrapper);
            }
        } 

        //Data prep for API callout
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartArray();
        for (UCPMrequestBodyWrapper wrapper : requestBodyWrapperList) {
            gen.writeStartObject();
            if (wrapper.ppmid != null) {
                gen.writeStringField('ppmid', wrapper.ppmid);
            } else {
                gen.writeStringField('ppmid', '');
            }
            if (wrapper.participantPpmid != null) {
                gen.writeStringField('participantPPMID', wrapper.participantPpmid);
            } else {
                gen.writeStringField('participantPPMID', '');
            }
             if (wrapper.applicationId != null) {
                gen.writeStringField('applicationId', wrapper.applicationId);
            } else {
                gen.writeStringField('applicationId', '');
            }
           gen.writeEndObject();
        }

        gen.writeEndArray();

        String requestString;
        requestString = gen.getAsString();

        DateTime dt = DateTime.now();

        //Integration log generation 
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
        r.setTimeout(120000);
        r.setMethod('POST');
        r.setHeader('Authorization', 'Bearer ' + accessToken);
        r.setbody(requestString);
        r.setHeader('identityType', identityType);
        r.setHeader('transactionId', MulesoftIntegrationApi.uniqueKeygeneration());

         HTTPResponse resp;
        try{
        
         resp = h.send(r);
        }
        catch(exception e){
             objIntegrationLog.Response_Body__c = e.getMessage();
             objIntegrationLog.Success__c = false;
            //set return value
            returnValueWrapper retDataWrap = new returnValueWrapper();
            retDataWrap.objIntegrationLog = objIntegrationLog;
            retDataWrap.updatedRecord = null;
            retDataWrap.isSuccess = false;
            return retDataWrap;
        }
         
        objIntegrationLog.Response_Body__c = resp.getBody();
        objIntegrationLog.Response_Status__c = resp.getStatus();
        objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();

        if (resp.getStatusCode() == 200) {
            objIntegrationLog.Success__c = true;
            responseBody = resp.getBody();

            UCPM_ConsentFetchController responseWrapper = (UCPM_ConsentFetchController) JSON.deserialize(
                responseBody,
                UCPM_ConsentFetchController.class
            );

            //call method to return wrapper with list of records to be updated and interation log           
            returnValueWrapper retDataWrap = updateRecords(responseWrapper, typeName);
            retDataWrap.objIntegrationLog = objIntegrationLog;
            
            return retDataWrap;
        } else {
            objIntegrationLog.Success__c = false;

            //set return value
            returnValueWrapper retDataWrap = new returnValueWrapper();
            retDataWrap.objIntegrationLog = objIntegrationLog;
            retDataWrap.updatedRecord = null;
            retDataWrap.isSuccess = false;
            return retDataWrap;
        }
    }

    public static returnValueWrapper updateRecords(
        UCPM_ConsentFetchController consentWrapper,
        string typeName
    ) {
        // Bypass triggers
        bypassContactTrigger();
        bypassPerTrigger();
        bypassPderTrigger();

        // Collect all ppmids and applicationIds to to retrieve the records
        List<String> ppmIdList = new List<String>();
        List<String> appIdList = new List<String>();
        for (payload payload : consentWrapper.payload) {
            ppmIdList.add(payload.requestPPMID);
            appIdList.add(payload.applicationId);
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
                IQVIA_Phone_Consent_Time__c,
                IQVIA_Assisted_Dialing_Consent__c,
                IQVIA_Assisted_Dialing_Consent_Time__c,
                IQVIA_Artificial_Voice_Consent__c,
                IQVIA_Artificial_Voice_Consent_Time__c,
                IQVIA_Pre_recorded_Calls_Consent_Time__c,
                IQVIA_Pre_recorded_Voice_Consent__c
            FROM Contact
            WHERE Id IN :appIdList
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
                Study_Assisted_Dialing_Consent__c,
                Study_Artificial_Voice_Consent__c,
                Study_Pre_recorded_Voice_Consent__c,
                Study_Artificial_Voice_Consent_Time__c,
                Study_Pre_recorded_Calls_Consent_Time__c,
                Study_Assisted_Dialing_Consent_Time__c,
                Participant_Contact__r.PPM_ID__c,
                Participant_Contact__r.Participant_Opt_In_Status_Emails__c,
                Participant_Contact__r.Participant_Opt_In_Status_SMS__c,
                Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
                Participant_Contact__r.IQVIA_Direct_Mail_Consent__c,
                Participant_Contact__r.IQVIA_SMS_Consent_Time__c,
                Participant_Contact__r.IQVIA_Phone_Consent_Time__c,
                Participant_Contact__r.IQVIA_Email_Consent_Time__c,
                Participant_Contact__r.IQVIA_Direct_Mail_Consent_Time__c,
                Participant_Contact__r.IQVIA_Assisted_Dialing_Consent__c,
                Participant_Contact__r.IQVIA_Assisted_Dialing_Consent_Time__c,
                Participant_Contact__r.IQVIA_Artificial_Voice_Consent__c,
                Participant_Contact__r.IQVIA_Artificial_Voice_Consent_Time__c,
                Participant_Contact__r.IQVIA_Pre_recorded_Calls_Consent_Time__c,
                Participant_Contact__r.IQVIA_Pre_recorded_Voice_Consent__c
            FROM Participant_Enrollment__c
            WHERE Id IN :appIdList
        ]) {
            ppmtoPerMap.put(per.PPMID__c, per);
        }

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
                Study_Assisted_Dialing_Consent__c,
                Study_Artificial_Voice_Consent__c,
                Study_Pre_recorded_Voice_Consent__c,
                Study_Artificial_Voice_Consent_Time__c,
                Study_Assisted_Dialing_Consent_Time__c,
                Study_Pre_recorded_Calls_Consent_Time__c,
                Patient_Delegate__r.Participant__r.Contact__c,
                Patient_Delegate__r.Participant__r.Contact__r.PPM_ID__c,
                Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_SMS__c,
                Patient_Delegate__r.Participant__r.Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
                Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Direct_Mail_Consent__c,
                Patient_Delegate__r.Participant__r.Contact__r.IQVIA_SMS_Consent_Time__c,
                Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Phone_Consent_Time__c,
                Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Email_Consent_Time__c,
                Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Direct_Mail_Consent_Time__c,
                Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Assisted_Dialing_Consent__c,
                Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Assisted_Dialing_Consent_Time__c,
                Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Artificial_Voice_Consent__c,
                Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Artificial_Voice_Consent_Time__c,
                Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Pre_recorded_Calls_Consent_Time__c,
                Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Pre_recorded_Voice_Consent__c
            FROM Patient_Delegate_Enrollment__c
            WHERE Id IN :appIdList
            //WHERE PPM_ID__c IN :ppmIdList
        ]) {
            ppmtoPdeMap.put(pde.PPM_ID__c, pde);
        }

        List<Sobject> conList = new List<Sobject>();
        List<Sobject> perList = new List<Sobject>();
        List<Sobject> pdeList = new List<Sobject>();

        for (payload payload : consentWrapper.payload) {
            if(payload.Purposes!=null){
            for (Purposes purpose : payload.Purposes) {

                for (CustomPreferences customPreference : purpose.CustomPreferences) {

                    for (Options option : customPreference.Options) {
                        //If ppmId from PER record
                        if (ppmtoPerMap.containsKey(payload.requestPPMID)) {
                            Participant_Enrollment__c per = ppmtoPerMap.get(payload.requestPPMID);
                            if (customPreference.Name == 'Communication-Consents') {
                                if (option.Name == 'sms') {
                                    per.Permit_SMS_Text_for_this_study__c = option.IsConsented;
                                        per.Study_SMS_Consent_Time__c = (DateTime) JSON.deserialize(
                                            '"' + purpose.ConsentDate + '"',
                                            DateTime.class
                                        );
                                        if (!perList.contains(per)) {
                                            perList.add(per);
                                        }
                                } else if (option.Name == 'email') {
                                    per.Permit_Mail_Email_contact_for_this_study__c = option.IsConsented;
                                        per.Study_Email_Consent_Time__c = (DateTime) JSON.deserialize(
                                            '"' + purpose.ConsentDate + '"',
                                            DateTime.class
                                        );
                                        if (!perList.contains(per)) {
                                            perList.add(per);
                                        }
                                } else if (option.Name == 'phone') {
                                    per.Permit_Voice_Text_contact_for_this_study__c = option.IsConsented;
                                        per.Study_Phone_Consent_Time__c = (DateTime) JSON.deserialize(
                                            '"' + purpose.ConsentDate + '"',
                                            DateTime.class
                                        );
                                    per.Study_Assisted_Dialing_Consent__c = option.IsConsented;
                                    per.Study_Artificial_Voice_Consent__c = option.IsConsented;
                                    per.Study_Pre_recorded_Voice_Consent__c = option.IsConsented;
                                    per.Study_Artificial_Voice_Consent_Time__c = (DateTime) JSON.deserialize(
                                            '"' + purpose.ConsentDate + '"',
                                            DateTime.class
                                        );
                                    per.Study_Pre_recorded_Calls_Consent_Time__c = (DateTime) JSON.deserialize(
                                            '"' + purpose.ConsentDate + '"',
                                            DateTime.class
                                        );
                                    per.Study_Assisted_Dialing_Consent_Time__c = (DateTime) JSON.deserialize(
                                            '"' + purpose.ConsentDate + '"',
                                            DateTime.class
                                        );
                                        if (!perList.contains(per)) {
                                            perList.add(per);
                                        }
                                } else if (option.Name == 'directMail') {
                                    per.Study_Direct_Mail_Consent__c = option.IsConsented;
                                        per.Study_Direct_Mail_Consent_Time__c = (DateTime) JSON.deserialize(
                                            '"' + purpose.ConsentDate + '"',
                                            DateTime.class
                                        );
                                        if (!perList.contains(per)) {
                                            perList.add(per);
                                        }
                                }
                            } else if (customPreference.Name == 'IQVIA-Outreach-Consents') {
                                if (option.Name == 'sms') {
                                    per.Participant_Contact__r.Participant_Opt_In_Status_SMS__c = option.IsConsented;
                                        per.Participant_Contact__r.IQVIA_SMS_Consent_Time__c = (DateTime) JSON.deserialize(
                                            '"' + purpose.ConsentDate + '"',
                                            DateTime.class
                                        );
                                        if (!perList.contains(per)) {
                                            perList.add(per);
                                        }
                                } else if (option.Name == 'email') {
                                    per.Participant_Contact__r.Participant_Opt_In_Status_Emails__c = option.IsConsented;
                                        per.Participant_Contact__r.IQVIA_Email_Consent_Time__c = (DateTime) JSON.deserialize(
                                            '"' + purpose.ConsentDate + '"',
                                            DateTime.class
                                        );
                                        if (!perList.contains(per)) {
                                            perList.add(per);
                                        }
                                } else if (option.Name == 'phone') {
                                    per.Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c = option.IsConsented;
                                        per.Participant_Contact__r.IQVIA_Phone_Consent_Time__c = (DateTime) JSON.deserialize(
                                            '"' + purpose.ConsentDate + '"',
                                            DateTime.class
                                        );
                                        per.Participant_Contact__r.IQVIA_Assisted_Dialing_Consent__c = option.IsConsented;
                                        per.Participant_Contact__r.IQVIA_Assisted_Dialing_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                        per.Participant_Contact__r.IQVIA_Artificial_Voice_Consent__c = option.IsConsented;
                                        per.Participant_Contact__r.IQVIA_Artificial_Voice_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                        per.Participant_Contact__r.IQVIA_Pre_recorded_Calls_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                        per.Participant_Contact__r.IQVIA_Pre_recorded_Voice_Consent__c = option.IsConsented;
                                        if (!perList.contains(per)) {
                                            perList.add(per);
                                        }
                                } else if (option.Name == 'directMail') {
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
                        // If ppmId from PDE record
                        else if (ppmtoPdeMap.containsKey(payload.requestPPMID)) {
                            Patient_Delegate_Enrollment__c pde = ppmtoPdeMap.get(payload.requestPPMID);
                            if (customPreference.Name == 'Communication-Consents') {
                                if (option.Name == 'sms') {
                                    pde.Study_SMS_Consent__c = option.IsConsented;
                                        pde.Study_SMS_Consent_Time__c = (DateTime) JSON.deserialize(
                                            '"' + purpose.ConsentDate + '"',
                                            DateTime.class
                                        );
                                        if (!pdeList.contains(pde)) {
                                            pdeList.add(pde);
                                        }
                                } else if (option.Name == 'email') {
                                    pde.Study_Email_Consent__c = option.IsConsented;
                                        pde.Study_Email_Consent_Time__c = (DateTime) JSON.deserialize(
                                            '"' + purpose.ConsentDate + '"',
                                            DateTime.class
                                        );
                                        if (!pdeList.contains(pde)) {
                                            pdeList.add(pde);
                                        }
                                } else if (option.Name == 'phone') {
                                    pde.Study_Phone_Consent__c = option.IsConsented;
                                        pde.Study_Phone_Consent_Time__c = (DateTime) JSON.deserialize(
                                            '"' + purpose.ConsentDate + '"',
                                            DateTime.class
                                        );
                                        pde.Study_Assisted_Dialing_Consent__c = option.IsConsented;
                                        pde.Study_Artificial_Voice_Consent__c = option.IsConsented;
                                        pde.Study_Pre_recorded_Voice_Consent__c = option.IsConsented;
                                        pde.Study_Artificial_Voice_Consent_Time__c = (DateTime) JSON.deserialize(
                                            '"' + purpose.ConsentDate + '"',
                                            DateTime.class
                                        );
                                        pde.Study_Assisted_Dialing_Consent_Time__c = (DateTime) JSON.deserialize(
                                            '"' + purpose.ConsentDate + '"',
                                            DateTime.class
                                        );
                                        pde.Study_Pre_recorded_Calls_Consent_Time__c = (DateTime) JSON.deserialize(
                                            '"' + purpose.ConsentDate + '"',
                                            DateTime.class
                                        );
                                        if (!pdeList.contains(pde)) {
                                            pdeList.add(pde);
                                        }
                                } else if (option.Name == 'directMail') {
                                    pde.Study_Direct_Mail_Consent__c = option.IsConsented;
                                        pde.Study_Direct_Mail_Consent_Time__c = (DateTime) JSON.deserialize(
                                            '"' + purpose.ConsentDate + '"',
                                            DateTime.class
                                        );
                                        if (!pdeList.contains(pde)) {
                                            pdeList.add(pde);
                                        }
                                }
                            } else if (customPreference.Name == 'IQVIA-Outreach-Consents') {
                                if (option.Name == 'sms') {
                                    pde.Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_SMS__c = option.IsConsented;
                                        pde.Patient_Delegate__r.Participant__r.Contact__r.IQVIA_SMS_Consent_Time__c = (DateTime) JSON.deserialize(
                                            '"' + purpose.ConsentDate + '"',
                                            DateTime.class
                                        );
                                        if (!pdeList.contains(pde)) {
                                            pdeList.add(pde);
                                        }
                                } else if (option.Name == 'email') {
                                    pde.Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c = option.IsConsented;
                                        pde.Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Email_Consent_Time__c = (DateTime) JSON.deserialize(
                                            '"' + purpose.ConsentDate + '"',
                                            DateTime.class
                                        );
                                        if (!pdeList.contains(pde)) {
                                            pdeList.add(pde);
                                        }
                                } else if (option.Name == 'phone') {
                                    pde.Patient_Delegate__r.Participant__r.Contact__r.Participant_Phone_Opt_In_Permit_Phone__c = option.IsConsented;
                                        pde.Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Phone_Consent_Time__c = (DateTime) JSON.deserialize(
                                            '"' + purpose.ConsentDate + '"',
                                            DateTime.class
                                        );
                                        pde.Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Assisted_Dialing_Consent__c = option.IsConsented;
                                        pde.Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Assisted_Dialing_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                        pde.Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Artificial_Voice_Consent__c = option.IsConsented;
                                        pde.Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Artificial_Voice_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                        pde.Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Pre_recorded_Calls_Consent_Time__c = (DateTime) JSON.deserialize(
                                                '"' + purpose.ConsentDate + '"',
                                                DateTime.class
                                            );
                                        pde.Patient_Delegate__r.Participant__r.Contact__r.IQVIA_Pre_recorded_Voice_Consent__c = option.IsConsented;
                                        if (!pdeList.contains(pde)) {
                                            pdeList.add(pde);
                                        }
                                } else if (option.Name == 'directMail') {
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
                        // If ppmId from Contact record
                        else if (ppmtoConMap.containsKey(payload.requestPPMID)) {
                            Contact con = ppmtoConMap.get(payload.requestPPMID);
                            if (customPreference.Name == 'IQVIA-Outreach-Consents') {
                                if (option.Name == 'sms') {
                                    con.Participant_Opt_In_Status_SMS__c = option.IsConsented;
                                        con.IQVIA_SMS_Consent_Time__c = (DateTime) JSON.deserialize(
                                            '"' + purpose.ConsentDate + '"',
                                            DateTime.class
                                        );
                                        if (!conList.contains(con)) {
                                            conList.add(con);
                                        }
                                } else if (option.Name == 'email') {
                                    con.Participant_Opt_In_Status_Emails__c = option.IsConsented;
                                        con.IQVIA_Email_Consent_Time__c = (DateTime) JSON.deserialize(
                                            '"' + purpose.ConsentDate + '"',
                                            DateTime.class
                                        );
                                        if (!conList.contains(con)) {
                                            conList.add(con);
                                        }
                                } else if (option.Name == 'phone') {
                                    con.Participant_Phone_Opt_In_Permit_Phone__c = option.IsConsented;
                                        con.IQVIA_Phone_Consent_Time__c = (DateTime) JSON.deserialize(
                                            '"' + purpose.ConsentDate + '"',
                                            DateTime.class
                                        );
                                    con.IQVIA_Assisted_Dialing_Consent__c = option.IsConsented;
                                    con.IQVIA_Assisted_Dialing_Consent_Time__c = (DateTime) JSON.deserialize(
                                            '"' + purpose.ConsentDate + '"',
                                            DateTime.class
                                        );
                                    con.IQVIA_Artificial_Voice_Consent__c = option.IsConsented;
                                    con.IQVIA_Artificial_Voice_Consent_Time__c = (DateTime) JSON.deserialize(
                                            '"' + purpose.ConsentDate + '"',
                                            DateTime.class
                                        );
                                    con.IQVIA_Pre_recorded_Calls_Consent_Time__c = (DateTime) JSON.deserialize(
                                            '"' + purpose.ConsentDate + '"',
                                            DateTime.class
                                        );
                                    con.IQVIA_Pre_recorded_Voice_Consent__c = option.IsConsented;
                                        if (!conList.contains(con)) {
                                            conList.add(con);
                                        }
                                } else if (option.Name == 'directMail') {
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
        updatedRecordsWrapper updatedRecWrap = new updatedRecordsWrapper();
        returnValueWrapper retDataWrap = new returnValueWrapper();
        Patient_Delegate_Enrollment__c pderNew = new Patient_Delegate_Enrollment__c();
        //DML to update local consents
        //Adding list of records to be updated in wrapper
        try {
            if (!perList.isEmpty()) {
                updatedRecWrap.perList.addAll(perList);
            }
            if (!pdeList.isEmpty()) {
                 updatedRecWrap.pdeList.addAll(pdeList);
            }
            if (!conList.isEmpty()) {
                 updatedRecWrap.conList.addAll(conList);
            }
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            //if DML fails return wrapper with isSuccess false
            retDataWrap.updatedRecord = null;
            retDataWrap.isSuccess = false;
            return retDataWrap;
        }
        //if method is called for notiifcation, call returnRecordPrep method to return list of records to be updated.
        //else return only isSuccess as true (no need to return updated records for other flows).
        if (typeName == 'notificationbatch') {
            retDataWrap.updatedRecord = returnRecordPrep(updatedRecWrap);
            if (retDataWrap.updatedRecord != null) {
                retDataWrap.isSuccess = true;
            } else {
                retDataWrap.isSuccess = false;
            }
            return retDataWrap;
        } else {
            retDataWrap.updatedRecord = null;
            retDataWrap.isSuccess = true;
            return retDataWrap;
        }
    }

    public static Sobject returnRecordPrep(
        UCPM_ConsentFetchController.updatedRecordsWrapper updatedRecWrap
    ) {
        if (objTypeFinal == 'Participant_Enrollment__c') {
            if (updatedRecWrap.perList != null && !updatedRecWrap.perList.isEmpty()) {
                return updatedRecWrap.perList[0];
            } else {
                return null;
            }
        } else if (objTypeFinal == 'Patient_Delegate_Enrollment__c') {
            if (updatedRecWrap.pdeList != null && !updatedRecWrap.pdeList.isEmpty()) {
                return updatedRecWrap.pdeList[0];
            } else {
                return null;
            }
        } else if (objTypeFinal == 'Contact') {
            if (updatedRecWrap.conList != null && !updatedRecWrap.conList.isEmpty()) {
                return updatedRecWrap.conList[0];
            } else {
                return null;
            }
        } else if (objTypeFinal == 'Participant__c') {
            if (updatedRecWrap.conList != null && !updatedRecWrap.conList.isEmpty()) {
                return updatedRecWrap.conList[0];
            } else {
                return null;
            }
        } else if (objTypeFinal == 'SurveyInvitation') {
            if (updatedRecWrap.perList != null && !updatedRecWrap.perList.isEmpty()) {
                return updatedRecWrap.pdeList[0];
            } else {
                return null;
            }
        }
        return null;
    }

    public class updatedRecordsWrapper {
        List<Sobject> conList = new List<Sobject>();
        List<Sobject> perList = new List<Sobject>();
        List<Sobject> pdeList = new List<Sobject>();
    }

    public class returnValueWrapper {
        public Sobject updatedRecord { get; set; }
        public Boolean isSuccess = false;
        public IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
        public String ppmID ;
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
        public String requestPPMID;
        public String applicationId;
        public String Language;
        public List<Purposes> Purposes;
    }

    public class Purposes {
        public String Name;
        public Object WithdrawalDate;
        public String ConsentDate;
        public Object ExpiryDate;
        public List<CustomPreferences> CustomPreferences;
    }
    //Response wrapper end

    public class UCPMFetchAPIErrorWrapper {
        public Integer statusCode;
        public String error;
        public String message;
    }
    public class UCPMrequestBodyWrapper {
        public String ppmid;
        public String participantPpmid;
        public String study;
        public String sponsor;
        public String applicationId;
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

    //Trigger bypass methods

    public static void bypassContactTrigger(){
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
    }

    public static void bypassPerTrigger(){
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
    }

    public static void bypassPderTrigger(){
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateEnrolTriggerHandler.CreateNewAssignmentNotification.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateEnrolTriggerHandler.CreateReactivatedNotification.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateEnrolTriggerHandler.SetDefaultPatientDelegateStatusHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateEnrolTriggerHandler.updateConsentTimeStamps.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateEnrolTriggerHandler.CreatePrimaryDelegateForMinor.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateEnrolTriggerHandler.CreateJanssenNotification.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateEnrolTriggerHandler.AssignCommunityPermissionSets.class
        );
        
    }

}