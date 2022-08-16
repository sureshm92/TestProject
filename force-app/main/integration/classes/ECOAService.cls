/**
 * Created by Sandeep on 10/1/2022.
 */
public with sharing class ECOAService {
    public static final String ECOA_URL = 'ECOA_API';
    public static final String ECOA_CONFIG_NAME = 'ECOAIntegration';
    public static final String AUTHORIZATION_KEY = 'Authorization_Key';
    public static final String END_POINT_URL = 'EndPoint';
    public static final String ORG_GUID = 'OrgGuid';
    public static final String ALGORITHM = 'Algorithm';
    public static final String ISSUER_GUID = 'IssuerGuid';
    public static final String AUD = 'Environment';
    public static final String ACTOR_TYPE = 'ActorType';
    public static final String SCHEDULE = 'eCOASchedule';
    public static final String DIARY_URL = 'DiaryURL';
    public static final String PVT_KEY = 'PrivateKey';
    public static final string TOKEN_TYPE = 'JWT';
    public static final String ALGO_NAME = 'rsa-sha256';

    public static Map<String, Config_API_Param__mdt> apiParamsMap;
    public static final Map<String, List<String>> dataTypeTokenHeader = new Map<String, List<String>>{
        'String' => new List<String>{ 'alg', 'typ' }
    };
    public static final Map<String, List<String>> dataTypeTokenBody = new Map<String, List<String>>{
        'String' => new List<String>{
            'iss',
            'sub',
            'aud',
            'ecoa:study_guid',
            'ecoa:actor_type',
            'ecoa:actor_id',
            'ecoa:schedule'
        },
        'LongNumber' => new List<String>{ 'iat', 'exp' }
    };
    static {
        apiParamsMap = new Map<String, Config_API_Param__mdt>();
        for (Config_API_Param__mdt mdt : [
            SELECT DeveloperName, ParamValue__c, Param_Value_Long__c
            FROM Config_API_Param__mdt
            WHERE ConfigAPI__r.DeveloperName = :ECOA_CONFIG_NAME
        ]) {
            apiParamsMap.put(mdt.DeveloperName, mdt);
        }
        System.debug('apiParamsMap::' + apiParamsMap);
    }
    //---Wrappers-------------------
    class MessageSiteResponseWrapper {
        public String statusMessage;
        public String siteName;
        public String siteGuid;
    }

    class MessageSiteRequest {
        public String name;
        public String description;
        public List<String> locales;
        public string countryCode;
        public String orgGuid;
        public String studyGuid;

        public Address address;
    }
    class Address {
        public String street;
        public String City;
        public String state;
        public String Country;
        public String PostalCode;
    }
    public class CreateSubjectResponse {
        @AuraEnabled
        public String ecoaResponseID;
        @AuraEnabled
        public String orgGuid;
        @AuraEnabled
        public String studyGuid;
        @AuraEnabled
        public String subjectId;
        @AuraEnabled
        public String ecoaErrorMessage;
        @AuraEnabled
        public String statusMessage;
    }

    public static void createEcoaEvent(List<Map<String, String>> ecoaEventList) {
        Map<String, String> headerMap = new Map<String, String>{
            'Content-Type' => 'application/json'
        };
        List<SObject> sObjectsList = new List<SObject>();

        HttpCallout remoteCall = new HttpCallout(
            null,
            'POST',
            headerMap,
            JSON.serializePretty(ecoaEventList),
            ECOAService.class
        );
        remoteCall.setEndPointURL('callout:ECOAIntegration/subjects/eventdates');
        String respBody = (String) remoteCall.execute();

        if (remoteCall.log.Success__c) {
            //perform on success
        }

        if (remoteCall.log != null) {
            sObjectsList.add(remoteCall.log);
        }
        disableTriggers();
        if (sObjectsList.size() > 0) {
            sObjectsList.sort();
            Database.upsert(sObjectsList, false);
        }
    }
    private static ECOAService instance;

    public static ECOAService getInstance() {
        if (instance == null)
            instance = new ECOAService();
        return instance;
    }

    public static void setMock(StubProvider stubProvider) {
        instance = (ECOAService) Test.createStub(ECOAService.class, stubProvider);
    }
    public static void createSite(List<Study_Site__c> siteList) {
        Integer allowedCallouts = Limits.getLimitCallouts() - Limits.getCallouts();
        list<string> locales = new List<String>();
        List<SObject> sObjectsList = new List<SObject>();
        locales.add('en');
        for (Study_Site__c siteObj : siteList) {
            Map<String, String> headerMap = new Map<String, String>{
                'Content-Type' => 'application/json'
            };

            list<MessageSiteRequest> lstRequest = new List<MessageSiteRequest>();
            MessageSiteRequest objMsgReq = new MessageSiteRequest();
            objMsgReq.name = siteObj.Id;
            objMsgReq.description = siteObj.Name;
            objMsgReq.locales = (new List<String>{ 'en' });
            objMsgReq.studyGuid = siteObj.Clinical_Trial_Profile__r.Study_GUID__c;
            objMsgReq.orgGuid = apiParamsMap.get(ORG_GUID).ParamValue__c;
            objMsgReq.countryCode = siteObj.site__r.billingcountrycode;
            Address add = new Address();
            add.street = siteObj.site__r.BillingStreet;
            add.City = siteObj.site__r.BillingCity;
            add.state = siteObj.site__r.billingState;
            add.Country = siteObj.Site__r.billingcountry;
            add.PostalCode = siteObj.Site__r.BillingPostalCode;
            objMsgReq.Address = add;
            lstRequest.add(objMsgReq);

            HttpCallout remoteCall = new HttpCallout(
                null,
                'POST',
                headerMap,
                JSON.serializePretty(lstRequest),
                ECOAService.class
            );

            remoteCall.setEndPointURL('callout:ECOAIntegration/sites');
            remoteCall.setAutoLogInsert(false);
            String respBody = (String) remoteCall.execute();
            if (remoteCall.log.Success__c) {
                list<ECOAService.MessageSiteResponseWrapper> responseWrapper = parseResponseBody(
                    respBody
                );
                String siteGuid = responseWrapper[0].siteGuid;
                siteObj.ECOA_Site_Guid__c = siteGuid;
                sObjectsList.add(siteObj);
                system.debug('siteGuid--' + siteGuid);
            }
            if (remoteCall.log != null) {
                sObjectsList.add(remoteCall.log);
            }
        }
        if (sObjectsList.size() > 0) {
            sObjectsList.sort();
            Database.upsert(sObjectsList, false);
        }
    }
    public static void createSubject(List<Participant_Enrollment__c> peList) {
        List<Id> contactIds = new List<Id>();
        List<Id> ctpIds = new List<Id>();
        List<SObject> sObjectsList = new List<SObject>();
        // List<Participant_Enrollment__c> pesToUpdate = new List<Participant_Enrollment__c>();

        Map<Id, User> userContactIdMap = new Map<Id, User>();
        Map<Id, Id> primarydelegateContactMap = new Map<Id, Id>();

        Map<Id, List<ECOA_Study_Schedule__c>> ctpScheduleMap = new Map<Id, List<ECOA_Study_Schedule__c>>();
        for (Participant_Enrollment__c peObj : peList) {
            contactIds.add(peObj.Participant_Contact__c);
            ctpIds.add(peObj.Clinical_Trial_Profile__c);
        }
        List<Patient_Delegate__c> patientdelegatesList = [
            SELECT Contact__c, Participant__r.Contact__c
            FROM Patient_Delegate__c
            WHERE Participant__r.Contact__c IN :contactIds AND Primary_Delegate__c = TRUE
        ];
        for (Patient_Delegate__c pd : patientdelegatesList) {
            primarydelegateContactMap.put(pd.Participant__r.Contact__c, pd.Contact__c);
            if (!contactIds.contains(pd.Contact__c)) {
                contactIds.add(pd.Contact__c);
            }
        }
        List<User> participantUsers = [
            SELECT Id, ContactId, LocaleSidKey, TimeZoneSidKey, LanguageLocaleKey
            FROM User
            WHERE ContactId IN :contactIds
        ];
        List<ECOA_Study_Schedule__c> studySchedules = [
            SELECT Id, ClinroRuleSetGuid__c, EproRuleSetGuid__c, Clinical_Trial_Profile__c
            FROM ECOA_Study_Schedule__c
            WHERE Clinical_Trial_Profile__c IN :ctpIds
        ];
        for (User userObj : participantUsers) {
            userContactIdMap.put(userObj.ContactId, userObj);
        }
        for (ECOA_Study_Schedule__c schedule : studySchedules) {
            if (ctpScheduleMap.containsKey(schedule.Clinical_Trial_Profile__c)) {
                ctpScheduleMap.get(schedule.Clinical_Trial_Profile__c).add(schedule);
            } else {
                ctpScheduleMap.put(
                    schedule.Clinical_Trial_Profile__c,
                    new List<ECOA_Study_Schedule__c>{ schedule }
                );
            }
        }
        Integer allowedCallouts = Limits.getLimitCallouts() - Limits.getCallouts();
        for (Participant_Enrollment__c peObj : peList) {
            try {
                if (allowedCallouts <= 0) {
                    break;
                }
                String timeZoneVal = '';
                User userObj = userContactIdMap.get(peObj.Participant_Contact__c);
                User delegateUserObj;
                List<ECOA_Study_Schedule__c> studySchedulesList = ctpScheduleMap.get(
                    peObj.Clinical_Trial_Profile__c
                );
                if (studySchedulesList.size() > 0) {
                    Map<String, String> headerMap = new Map<String, String>{
                        'Content-Type' => 'application/json'
                    };
                    if (userObj != null) {
                        timeZoneVal = userObj.TimeZoneSidKey;
                    } else {
                        Id delegatecontactId = primarydelegateContactMap.get(
                            peObj.Participant_Contact__c
                        );
                        delegateUserObj = userContactIdMap.get(delegatecontactId);
                        if (delegateUserObj != null) {
                            timeZoneVal = delegateUserObj.TimeZoneSidKey;
                        }
                    }
                    if(timeZoneVal != ''){
                        List<Map<String, String>> requestMapList = new List<Map<String, String>>();
                        Map<String, String> requestMap = new Map<String, String>{
                            'username' => peObj.Id,
                            //'email' => peObj.Participant__r.Email__c,
                            'timezone' => timeZoneVal,
                            'subjectId' => peObj.Id,
                            'studyGuid' => peObj.Clinical_Trial_Profile__r.Study_GUID__c,
                            'studyVersionGuid' => peObj.Clinical_Trial_Profile__r.Study_Version_GUID__c,
                            'subjectLocale' => 'en',
                            'eproRuleSetGuid' => studySchedulesList[0].EproRuleSetGuid__c,
                            'clinroRuleSetGuid' => studySchedulesList[0].ClinroRuleSetGuid__c,
                            'orgGuid' => apiParamsMap.get(ORG_GUID).ParamValue__c,
                            'siteGuid' => peObj.Study_Site__r.ECOA_Site_Guid__c,
                            'loginType' => 'SSO',
                            'loginSsoId' => peObj.Id,
                            'loginSsoIssuerGuid' => apiParamsMap.get(ISSUER_GUID).ParamValue__c
                        };
                        requestMapList.add(requestMap);
                        HttpCallout remoteCall = new HttpCallout(
                            null,
                            'POST',
                            headerMap,
                            JSON.serializePretty(requestMapList),
                            ECOAService.class
                        );

                        remoteCall.setEndPointURL('callout:ECOAIntegration/subjects');

                        remoteCall.setAutoLogInsert(false);

                        String respBody = (String) remoteCall.execute();

                        if (remoteCall.log.Success__c) {
                            List<ECOAService.CreateSubjectResponse> newSubjectInfo = getSubjectResponse(
                                respBody
                            );
                            peObj.Subject_GUID__c = newSubjectInfo[0].ecoaResponseID;
                            // pesToUpdate.add(peObj);
                            sObjectsList.add(peObj);
                        }
                        if (remoteCall.log != null) {
                            sObjectsList.add(remoteCall.log);
                        }
                    }
                }
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
            allowedCallouts--;
        }
        disableTriggers();

        if (sObjectsList.size() > 0) {
            sObjectsList.sort();
            Database.upsert(sObjectsList, false);
        }
    }

    public static void disableTriggers() {
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.SendEmailIfSSWasChanged.class
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
            ParticipantEnrollmentTriggerHandler.UnenrollorCancelPer.class
        );

        TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateUsersOrSendNotificationsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SendCalloutOnEligibilityPassedHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SetParticipantStatusHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.UpdatePEHistoryOnAutoAcceptedHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateWelcomeToStudyAlertHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SendDropOutEmailHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SetCurrentEnrollmentHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR.class
        );
    }
    public static List<ECOAService.CreateSubjectResponse> getSubjectResponse(String responseBody) {
        list<ECOAService.CreateSubjectResponse> subResponseWrap = (list<ECOAService.CreateSubjectResponse>) JSON.deserialize(
            responseBody,
            list<ECOAService.CreateSubjectResponse>.class
        );
        return subResponseWrap;
    }
    public static String getSubjectGuid() {
        if (ParticipantContext.getCurrentPEId() != null) {
            return ParticipantContext.getCurrentPE().Subject_GUID__c;
        }
        return '';
    }
    public static String getJWTToken() {
        String jwtToken;
        String subjectGUID;
        String studyGUID;
        String endpoint = apiParamsMap.get(DIARY_URL).ParamValue__c;
        String payload;
        String verifySign;
        String pvtKey = apiParamsMap.get(PVT_KEY).Param_Value_Long__c.replace('\n', '');
        String pubKey;
        String header;
        Long rightNow = (dateTime.now().getTime() / 1000) + 1;
        Blob privateKey = EncodingUtil.base64Decode(pvtKey);

        if (ParticipantContext.getCurrentPEId() != null) {
            studyGUID = ParticipantContext.getCurrentPE().Clinical_Trial_Profile__r.Study_GUID__c;
            subjectGUID = ParticipantContext.getCurrentPE().Subject_GUID__c;
        }
        Map<String, Object> tokenHeaderValueMap = new Map<String, Object>{
            'alg' => apiParamsMap.get(ALGORITHM).ParamValue__c,
            'typ' => 'JWT'
        };

        Map<String, Object> tokenBodyValueMap = new Map<String, Object>{
            'iss' => apiParamsMap.get(ISSUER_GUID).ParamValue__c,
            'sub' => ('guid:' + subjectGUID),
            'aud' => apiParamsMap.get(AUD).ParamValue__c,
            'iat' => rightNow,
            'exp' => (rightNow + 36000),
            'ecoa:study_guid' => studyGUID,
            'ecoa:actor_type' => apiParamsMap.get(ACTOR_TYPE).ParamValue__c,
            'ecoa:actor_id' => ('guid:' + subjectGUID),
            'ecoa:schedule' => apiParamsMap.get(SCHEDULE).ParamValue__c
        };

        header = HttpCallout.base64UrlEncode(
            Blob.valueOf(
                HttpCallout.constructJSONReq(tokenHeaderValueMap, dataTypeTokenHeader, false)
            )
        );
        payload = HttpCallout.base64UrlEncode(
            Blob.valueOf(HttpCallout.constructJSONReq(tokenBodyValueMap, dataTypeTokenBody, false))
        );

        String jwtTemp = header + '.' + payload;
        Blob sign = Crypto.sign(ALGO_NAME, Blob.valueOf(jwtTemp), privateKey);

        String output = EncodingUtil.base64Encode(sign);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while (output.endsWith('=')) {
            output = output.subString(0, output.length() - 1);
        }
        jwtToken = jwtTemp + '.' + output;
        return endpoint + jwtToken;
    }

    public static list<ECOAService.MessageSiteResponseWrapper> parseResponseBody(
        String responseBody
    ) {
        try {
            list<ECOAService.MessageSiteResponseWrapper> msgResponseWrap = (list<ECOAService.MessageSiteResponseWrapper>) JSON.deserialize(
                responseBody,
                list<ECOAService.MessageSiteResponseWrapper>.class
            );
            return msgResponseWrap;
        } catch (JSONException e) {
            return new List<MessageSiteResponseWrapper>();
        }
    }
}
