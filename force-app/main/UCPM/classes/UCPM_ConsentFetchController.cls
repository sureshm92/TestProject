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
    // public static String getAccessToken(){
    //     return MulesoftIntegrationApi.getAccessToken('Mulesoft Access Token UCPM');
    // }
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

    //@future(callout=true)
    public static returnValueWrapper callUCPMtoFetchConsents(
        List<id> ids,
        List<SObject> sobj,
        string typeName
    ) {
        //get mulesoft access token
        String accessToken;
        accessToken = getAccessToken();
        System.debug('accessToken ##: ' + accessToken);
        // list<id> null  and object not null  and type is email then email
        // sobject  type kya hai // ppim, and rest le kar ayenge
        // list<id> not null  and object nulland type is sms  then sms
        // from id find object type then query based on that to get ppim and rest

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

        if (ids == null && sobj != null && typeName == 'email') {
            for (SObject so : sobj) {
                //per //contact
                objType = String.valueOf(so.getSobjectType());
                if (objType == PARTICIPANT_ENROLLMENT_OBJ_NAME) {
                    Id perid = (String) so.get('id');
                    perIDs.add(perid);
                    objTypeFinal = PARTICIPANT_ENROLLMENT_OBJ_NAME;
                    identityType ='PARTICIPANT';
                }
                /* if (objType == TELEVISIT_OBJ_NAME) { 
                  Id teleVisitid = (String)so.get('id'); 
                  televisitIdList.add(teleVisitid);
              }*/
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
            /* List<Televisit__c> teleVisitsList = [ SELECT
                        Id,
                        Participant_Enrollment__c,Participant_Enrollment__r.PPMID__c,Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Sponsor__c,Participant_Enrollment__r.Clinical_Trial_Profile__c 
                        from  Televisit__c where Id IN:televisitIdList  ];
		  Map<id, Televisit__c> idToteleVisitmap= new Map<id, Televisit__c>();
          for(Televisit__c t : teleVisitsList ){
              idToteleVisitmap.put(t.id,t);
          }*/
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
                    system.debug('perid:' + per);
                    //String getpartPPMid = (String)so.get('Participant_Contact__r.PPM_ID__c');
                    requestBodyWrapper.ppmid = per.PPMID__c;
                    requestBodyWrapper.participantPpmid = '';
                    requestBodyWrapper.sponsor = per.Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c;
                    requestBodyWrapper.study = per.Clinical_Trial_Profile__r.Study_Code_Name__c;
                }
                /* else if (objType == TELEVISIT_OBJ_NAME) {
			      Id teleid = (String)so.get('id'); 
                  Televisit__c teleVisit =idToteleVisitmap.get(teleid) ;// sobject record
				  requestBodyWrapper.ppmid=teleVisit.Participant_Enrollment__r.PPMID__c;
				  requestBodyWrapper.participantPpmid='';
				  requestBodyWrapper.sponsor=teleVisit.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Sponsor__c;
				  requestBodyWrapper.study=teleVisit.Participant_Enrollment__r.Clinical_Trial_Profile__c;
			  }*/
                else if (objType == PATIENT_DEL_ENROLLMENT) {
                    Id pdeid = (String) so.get('id');
                    Patient_Delegate_Enrollment__c pde = idTopdermap.get(pdeid); // sobject record
                    requestBodyWrapper.ppmid = pde.PPM_ID__c;
                    requestBodyWrapper.participantPpmid = pde.Participant_Enrollment__r.PPMID__c;
                    requestBodyWrapper.sponsor = pde.Participant_Enrollment__r.Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c;
                    requestBodyWrapper.study = pde.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c;
                }
                /* else if (objType == TELEVISIT_ATTN_OBJ_NAME) {
				  requestBodyWrapper.ppmid=so.Televisit__r.Participant_Enrollment__r.PPMID__c;
				  requestBodyWrapper.participantPpmid=so.Televisit__r.Participant_Enrollment__r.Participant_Contact__r.PPMID__c;
				  requestBodyWrapper.sponsor=so.Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Sponsor__c;
				  requestBodyWrapper.study=so.Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__c;
			  }*/
                else if (objType == PARTICIPANT_OBJ_NAME) {
                    Id partid = (String) so.get('id');
                    Participant__c p = idToparticipantmap.get(partid); // sobject record
                    requestBodyWrapper.ppmid = p.Contact__r.PPM_ID__c;
                    requestBodyWrapper.participantPpmid = '';
                    requestBodyWrapper.sponsor = '';
                    requestBodyWrapper.study = '';
                } else if (objType == CONTACT) {
                    Id conid = (String) so.get('id');
                    Contact c = idToConMap.get(conid); // sobject record
                    requestBodyWrapper.ppmid = c.PPM_ID__c;
                    requestBodyWrapper.participantPpmid = '';
                    requestBodyWrapper.sponsor = '';
                    requestBodyWrapper.study = '';
                } else if (objType == SURVEY_INVITATION_OBJ_NAME) {
                    Id surveyid = (String) so.get('id');
                    SurveyInvitation s = idToSurveymap.get(surveyid); // sobject record
                    requestBodyWrapper.ppmid = s.Participant_Enrollment__r.PPMID__c;
                    requestBodyWrapper.participantPpmid = '';
                    requestBodyWrapper.sponsor = s.Participant_Enrollment__r.Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c;
                    requestBodyWrapper.study = s.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c;
                }
                requestBodyWrapperList.add(requestBodyWrapper);
            }
            system.debug('requestBodyWrapperList:' + requestBodyWrapperList);
        } else if (!ids.isEmpty() && sobj == null && typeName != 'email') {
            for (id idObj : ids) {
                objType = String.valueOf(idObj.getSobjectType());
                if (objType == PARTICIPANT_ENROLLMENT_OBJ_NAME) {
                    Id perid = idObj;
                    perIDs.add(perid);
                    identityType ='PARTICIPANT';
                } else if (objType == TASK_OBJ_NAME) {
                    Id taskid = idObj;
                    taskIdList.add(taskid);
                } else if (objType == TELEVISIT_OBJ_NAME) {
                    Id teleVistid = idObj;
                    televisitIdList.add(teleVistid);
                    identityType ='PARTICIPANT';
                } else if (objType == TELEVISIT_ATTN_OBJ_NAME) {
                    Id teleVistAttid = idObj;
                    televisitAttendeeIdList.add(teleVistAttid);
                    identityType ='PARTICIPANT';
                } else if (objType == SURVEY_INVITATION_OBJ_NAME) {
                    Id surveyid = idObj;
                    surveyInvitationIdList.add(surveyid);
                    identityType ='PARTICIPANT';
                } else if (objType == PARTICIPANT_OBJ_NAME) {
                    Id partId = idObj;
                    participantIdList.add(partId);
                    identityType ='PARTICIPANT';
                } else if (objType == PATIENT_DEL_ENROLLMENT) {
                    Id pdeID = idObj;
                    pderIdList.add(pdeID);
                    identityType ='DELEGATE';
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
            List<Task> taskList = [
                SELECT id, Survey_Invitation__r.Participant_Enrollment__r.PPMID__c
                FROM task
                WHERE id = :taskIdList
            ];
            Map<id, Task> idTOtaskMap = new Map<id, Task>();
            for (Task t : taskList) {
                idTOtaskMap.put(t.id, t);
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
            List<Televisit__c> teleList = [
                SELECT id, Participant_Enrollment__r.PPMID__c,
                Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                Participant_Enrollment__r.Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c
                FROM Televisit__c
                WHERE id = :televisitIdList
            ];
            Map<id, Televisit__c> idTOtelemap = new Map<id, Televisit__c>();
            for (Televisit__c tele : teleList) {
                idTOtelemap.put(tele.id, tele);
            }

            for (id idList : ids) {
                UCPMrequestBodyWrapper requestBodyWrapper = new UCPMrequestBodyWrapper();
                objType = String.valueOf(idList.getSobjectType());
                if (objType == PARTICIPANT_ENROLLMENT_OBJ_NAME) {
                    Id perid = idList;
                    Participant_Enrollment__c per = idTOpermap.get(perid); // sobject record
                    system.debug('perid:' + per);
                    requestBodyWrapper.ppmid = per.PPMID__c;
                    requestBodyWrapper.participantPpmid = '';
                    requestBodyWrapper.sponsor = per.Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c;
                    requestBodyWrapper.study = per.Clinical_Trial_Profile__r.Study_Code_Name__c;
                }
                if (objType == PATIENT_DEL_ENROLLMENT) {
                    Id pderid = idList;
                    Patient_Delegate_Enrollment__c pder = idTopdermap.get(pderid); // sobject record
                    system.debug('pderid:' + pder);
                    requestBodyWrapper.ppmid = pder.Participant_Enrollment__r.PPMID__c;
                    requestBodyWrapper.participantPpmid = pder.Participant_Enrollment__r.PPMID__c;
                    requestBodyWrapper.sponsor = pder.Participant_Enrollment__r.Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c;
                    requestBodyWrapper.study = pder.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c;
                }
                if (objType == TELEVISIT_OBJ_NAME) {
                    Id televistID = idList;
                    Televisit__c teleVisit = idTOtelemap.get(televistID); // sobject record
                    system.debug('televistID:' + teleVisit);
                    requestBodyWrapper.ppmid = teleVisit.Participant_Enrollment__r.PPMID__c;
                    requestBodyWrapper.participantPpmid = teleVisit.Participant_Enrollment__r.PPMID__c;
                    requestBodyWrapper.sponsor = teleVisit.Participant_Enrollment__r.Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c;
                    requestBodyWrapper.study = teleVisit.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c;
                }
                requestBodyWrapperList.add(requestBodyWrapper);
            }
            system.debug('requestBodyWrapperList:' + requestBodyWrapperList);
        }

        //Data prep for API callout
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartArray();
        for (UCPMrequestBodyWrapper wrapper : requestBodyWrapperList) {
            system.debug('wrapper.ppmid:' + wrapper.ppmid);
            gen.writeStartObject();
            if (wrapper.ppmid != null) {
                gen.writeStringField('ppmid', wrapper.ppmid);
            } else {
                gen.writeStringField('ppmid', '');
            }
            if (wrapper.participantPpmid != null) {
                gen.writeStringField('participantPpmid', wrapper.participantPpmid);
            } else {
                gen.writeStringField('participantPpmid', '');
            }
            if (wrapper.sponsor != null) {
                gen.writeStringField('sponsor', wrapper.sponsor);
            } else {
                gen.writeStringField('sponsor', '');
            }
            if (wrapper.study != null) {
                gen.writeStringField('study',  wrapper.study);
            } else {
                gen.writeStringField('study', '');
            }
            gen.writeEndObject();
        }

        gen.writeEndArray();

        /*JSONGenerator gen = JSON.createGenerator(false);
    gen.writeStartArray();
    gen.writeStartObject();
    gen.writeStringField('ppmid', '01004_52e024af-7f0c-41a2-a69d-bd35ad692378');
    gen.writeStringField('participantPpmid', '01004_154564cc-2f03-4065-84cd-5cd1b47e0281');
    gen.writeStringField('sponsor', 'GSK');
    gen.writeStringField('study', 'STUDY1');
    gen.writeEndObject();*/
        String requestString;
        requestString = gen.getAsString();
        System.debug('requestBody: ' + requestString);

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
        r.setHeader('identityType', identityType);
        r.setHeader('tid', MulesoftIntegrationApi.uniqueKeygeneration());

        System.debug('###### request ' + r.getBody());

        HTTPResponse resp = h.send(r);
        System.debug('###### resp ' + resp.getStatusCode());
        System.debug('200 ' + resp.getBody());

        objIntegrationLog.Response_Body__c = resp.getBody();
        objIntegrationLog.Response_Status__c = resp.getStatus();
        objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();

        if (resp.getStatusCode() == 200) {
            System.debug('200 ' + resp.getBody());
            objIntegrationLog.Success__c = true;
            responseBody = resp.getBody();

            // Response code starts here
            String responseTest = '{"total": 1,"success": 1,"failed": 0,"payload": [{"code": 200,"status": "success","message": "Consents retrieved successfully","ppmid":"01004_386cc1c7-404d-47e4-b934-51660b68e0e2","Language": "en-US","Purposes": [{"Name":"GSK-Study1","WithdrawalDate":null,"ConsentDate":"2024-03-21T01:55:42.09","ExpiryDate":null,"CustomPreferences":[{"Name":"Communication-Consents","Options": [{"Name": "phone","IsConsented": true},{"Name": "email","IsConsented": true}]}]}]}]}';
            UCPM_ConsentFetchController responseWrapper = (UCPM_ConsentFetchController) JSON.deserialize(
                responseBody,
                UCPM_ConsentFetchController.class
            );
            // call method to update local records
            insert objIntegrationLog;
            returnValueWrapper retDataWrap = updateRecords(responseWrapper, typeName);
            System.debug('retDataWrap: ' + retDataWrap);
            
            return retDataWrap;
        } else {
           System.debug('Inside Error code 01: ');
            UCPMFetchAPIErrorWrapper deserializedResponseWrapperToken = (UCPMFetchAPIErrorWrapper) JSON.deserialize(
                responseBody,
                UCPMFetchAPIErrorWrapper.class
            );
            // objIntegrationLog.Error_Message__c = deserializedResponseWrapperToken.message;
            objIntegrationLog.Success__c = false;

            //set return value
            returnValueWrapper retDataWrap = new returnValueWrapper();
            retDataWrap.updatedRecord = null;
            retDataWrap.isSuccess = false;
            System.debug('Inside Error code: ');
            insert objIntegrationLog;
            return retDataWrap;
        }
    }

    public static returnValueWrapper updateRecords(
        UCPM_ConsentFetchController consentWrapper,
        string typeName
    ) {
        //for testing
        /* String responseTest = '{"total": 1,"success": 1,"failed": 0,"payload": [{"code": 200,"status": "success","message": "Consents retrieved successfully","ppmid":"01004_386cc1c7-404d-47e4-b934-51660b68e0e2","Language": "en-US","Purposes": [{"Name":"GSK-Study1","WithdrawalDate":null,"ConsentDate":"2024-03-21T01:55:42.09","ExpiryDate":null,"CustomPreferences":[{"Name":"Communication-Consents","Options": [{"Name": "phone","IsConsented": true},{"Name": "email","IsConsented": true}]}]}]}]}';
   UCPM_ConsentFetchController consentWrapper = (UCPM_ConsentFetchController) JSON.deserialize(
        responseTest,
        UCPM_ConsentFetchController.class
    );*/
        //for testing end

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
            ppmIdList.add(payload.ppmid);
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

        List<Contact> conList = new List<Contact>();
        List<Participant_Enrollment__c> perList = new List<Participant_Enrollment__c>();
        List<Patient_Delegate_Enrollment__c> pdeList = new List<Patient_Delegate_Enrollment__c>();

        for (payload payload : consentWrapper.payload) {
            // system.debug('payload: '+payload);
            if(payload.Purposes!=null){
            for (Purposes purpose : payload.Purposes) {
                system.debug('purpose: ' + purpose);

                for (CustomPreferences customPreference : purpose.CustomPreferences) {
                    system.debug('customPreference: ' + customPreference);

                    for (Options option : customPreference.Options) {
                        system.debug('Options: ' + option);
                        //If ppmId from PER record
                        System.debug('ppmId --->' + payload.ppmid);
                        if (ppmtoPerMap.containsKey(payload.ppmid)) {
                            Participant_Enrollment__c per = ppmtoPerMap.get(payload.ppmid);
                            if (customPreference.Name == 'Communication-Consents') {
                                if (option.Name == 'sms') {
                                    //Check if consent is changed
                                    if (
                                        per.Permit_SMS_Text_for_this_study__c != option.IsConsented
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
                                    if (per.Study_Direct_Mail_Consent__c != option.IsConsented) {
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
                            } else if (customPreference.Name == 'IQVIA-Outreach-Purpose') {
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
                        else if (ppmtoPdeMap.containsKey(payload.ppmid)) {
                            Patient_Delegate_Enrollment__c pde = ppmtoPdeMap.get(payload.ppmid);
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
                                    if (pde.Study_Direct_Mail_Consent__c != option.IsConsented) {
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
                            } else if (customPreference.Name == 'IQVIA-Outreach-Purpose') {
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
                        else if (ppmtoConMap.containsKey(payload.ppmid)) {
                            Contact con = ppmtoConMap.get(payload.ppmid);
                            if (customPreference.Name == 'IQVIA-Outreach-Purpose') {
                                if (option.Name == 'sms') {
                                    //Check if consent is changed
                                    if (
                                        con.Participant_Opt_In_Status_SMS__c != option.IsConsented
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
                                    if (con.IQVIA_Direct_Mail_Consent__c != option.IsConsented) {
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
        updatedRecordsWrapper updatedRecWrap = new updatedRecordsWrapper();
        returnValueWrapper retDataWrap = new returnValueWrapper();
        Patient_Delegate_Enrollment__c pderNew = new Patient_Delegate_Enrollment__c();
        //DML to update local consents
        try {
            if (!perList.isEmpty()) {
                update perList;
                updatedRecWrap.perList.addAll(perList);
            }
            if (!pdeList.isEmpty()) {
                update pdeList;
                updatedRecWrap.pdeList.addAll(pdeList);
            }
            if (!conList.isEmpty()) {
                update conList;
                updatedRecWrap.conList.addAll(conList);
            }
            System.debug('updatedRecWrap---->' + updatedRecWrap);
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            //if DML fails return wrapper with isSuccess false
            retDataWrap.updatedRecord = null;
            retDataWrap.isSuccess = false;
            return retDataWrap;
        }
        //if method is called for email, call returnRecordPrep method to return updated records.
        //else return only isSuccess as true (no need to return updated records for SMS or other notifications).
        if (typeName == 'email') {
            retDataWrap.updatedRecord = returnRecordPrep(updatedRecWrap);
            // Patient_Delegate_Enrollment__c pde= new Patient_Delegate_Enrollment__c();
            //  if(objTypeFinal == 'Patient_Delegate_Enrollment__c'){
            //    pde= (Patient_Delegate_Enrollment__c)retDataWrap.updatedRecord;
            //  }
            System.debug('retDataWrap.updatedRecord: ' + retDataWrap.updatedRecord);
            //System.debug('retDataWrap.updatedRecord Get: ' + pde.Patient_Delegate__r.Participant_Delegate__r.First_Name__c);
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
        system.debug('objTypeFinal:' + objTypeFinal);
        if (objTypeFinal == 'Participant_Enrollment__c') {
            if (updatedRecWrap.perList != null && !updatedRecWrap.perList.isEmpty()) {
                return [
                    SELECT
                        Id,
                        Permit_Mail_Email_contact_for_this_study__c,
                        Invited_To_PP_Date__c,
                        Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                        Study_Site__r.Suppress_Participant_Emails__c,
                        Study_Site__r.Principal_Investigator__r.Participant_Opt_In_Status_Emails__c,
                        Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                        Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                        Study_Site__r.Clinical_Trial_Profile__r.PPTemplate__c,
                        Study_Site__r.SMS_Are_Available__c,
                        Study_Site__r.Suppress_Study_Site_PI_Emails__c,
                        Participant__r.IsCountry_NOT_Eligible_for_Emails__c,
                        Participant_Status__c,
                        HCP__r.HCP_Contact__r.HCP_Opt_In_Patient_Status_Emails__c,
                        Clinical_Trial_Profile__r.Patient_Portal_Enabled__c
                    FROM Participant_Enrollment__c
                    WHERE Id = :updatedRecWrap.perList[0].Id
                    LIMIT 1
                ];
            } else {
                return null;
            }
        } else if (objTypeFinal == 'Patient_Delegate_Enrollment__c') {
            if (updatedRecWrap.pdeList != null && !updatedRecWrap.pdeList.isEmpty()) {
                return [
                    SELECT
                        Id,
                        Patient_Delegate__r.Participant__r.Full_Name__c,
                        Patient_Delegate__r.Id,
                        Welcome_Message_Sent__c,
                        Study_Email_Consent__c,
                        Study_SMS_Consent__c,
                        Welcome_Message_Delivered__c,
                        Patient_Delegate__r.Participant__r.Contact__c,
                        Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                        Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_SMS__c,
                        Patient_Delegate__r.Participant__r.First_Name__c,
                        Patient_Delegate__r.Participant__r.Last_Name__c,
                        Patient_Delegate__r.Contact__c,
                        Patient_Delegate__r.Participant__c,
                        Patient_Delegate__r.Participant_Delegate__r.Id,
                        Patient_Delegate__r.Participant_Delegate__r.First_Name__c,
                        Patient_Delegate__r.Participant_Delegate__r.Last_Name__c,
                        Patient_Delegate__r.Participant_Delegate__r.Email__c,
                        Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                        Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_SMS__c,
                        Status__c,
                        Participant_Enrollment__c,
                        Participant_Enrollment__r.Participant__r.IsCountry_NOT_Eligible_for_Emails__c,
                        Participant_Enrollment__r.Study_Site__r.Suppress_Participant_Emails__c,
                        Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c,
                        Participant_Enrollment__r.Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                        Participant_Enrollment__r.Name,
                        Participant_Enrollment__r.Participant_Status__c,
                        Participant_Enrollment__r.Clinical_Trial_Profile__c,
                        Participant_Enrollment__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                        Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                        Participant_Enrollment__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c
                    FROM Patient_Delegate_Enrollment__c
                    WHERE Id = :updatedRecWrap.pdeList[0].Id
                    LIMIT 1
                ];
            } else {
                return null;
            }
        } else if (objTypeFinal == 'Contact') {
            if (updatedRecWrap.conList != null && !updatedRecWrap.conList.isEmpty()) {
                return [
                    SELECT
                        Id,
                        Participant_Opt_In_Status_Emails__c,
                        Participant_Opt_In_Status_SMS__c,
                        UserCommunityIsDelegate__c,
                        userCommunityMode__c,
                        Language__c,
                        MailingCountryCode,
                        Is_Invalid_Number__c,
                        Is_Patient_User_Created__c,
                        (SELECT TimeZoneSidKey FROM Users)
                    FROM Contact
                    WHERE Id = :updatedRecWrap.conList[0].Id
                    LIMIT 1
                ];
            } else {
                return null;
            }
        } else if (objTypeFinal == 'Participant__c') {
            if (updatedRecWrap.conList != null && !updatedRecWrap.conList.isEmpty()) {
                return [
                    SELECT
                        Id,
                        Contact__r.Participant_Opt_In_Status_Emails__c,
                        Contact__r.Participant_Opt_In_Status_SMS__c,
                        IsCountry_NOT_Eligible_for_Emails__c,
                        Contact__r.Is_Patient_User_Created__c
                    FROM Participant__c
                    WHERE Contact__r.Id = :updatedRecWrap.conList[0].Id
                    LIMIT 1
                ];
            } else {
                return null;
            }
        } else if (objTypeFinal == 'SurveyInvitation') {
            if (updatedRecWrap.perList != null && !updatedRecWrap.perList.isEmpty()) {
                return [
                    SELECT
                        Id,
                        IsTrialSurvey__c,
                        Participant_Enrollment__c,
                        Participant_Enrollment__r.Invited_To_PP_Date__c,
                        Participant_Enrollment__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,
                        Participant_Enrollment__r.Clinical_Trial_Profile__r.PPTemplate__c,
                        Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                        Participant_Enrollment__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                        Participant_Enrollment__r.Permit_Mail_Email_contact_for_this_study__c,
                        Participant_Enrollment__r.Study_Site__r.Suppress_Participant_Emails__c,
                        Participant_Enrollment__r.Participant__r.IsCountry_NOT_Eligible_for_Emails__c
                    FROM SurveyInvitation
                    WHERE Participant_Enrollment__r.Id = :updatedRecWrap.perList[0].Id
                    LIMIT 1
                ];
            } else {
                return null;
            }
        }
        return null;
    }

    public class updatedRecordsWrapper {
        List<Contact> conList = new List<Contact>();
        List<Participant_Enrollment__c> perList = new List<Participant_Enrollment__c>();
        List<Patient_Delegate_Enrollment__c> pdeList = new List<Patient_Delegate_Enrollment__c>();
    }

    public class returnValueWrapper {
        public Sobject updatedRecord { get; set; }
        public Boolean isSuccess = false;
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
        public Integer code;
        public String status;
        public String message;
        public String ppmid;
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
}