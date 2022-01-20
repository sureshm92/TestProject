/**
 * Created by Sandeep on 10/1/2022.
 */
public with sharing class ECOAService {
    public static final String ECOA_URL = 'ECOA_API';
    public static final String ECOA_CONFIG_NAME = 'ECOAIntegration';
    public static final String AUTHORIZATION_KEY = 'Authorization_Key';
    public static final String END_POINT_URL = 'EndPoint';
    public static final String ORG_GUID = 'OrgGuid';

    public static Map<String, Config_API_Param__mdt> apiParamsMap;

    static {
        apiParamsMap = new Map<String, Config_API_Param__mdt>();
        for (Config_API_Param__mdt mdt : [
            SELECT DeveloperName, ParamValue__c
            FROM Config_API_Param__mdt
            WHERE ConfigAPI__r.DeveloperName = :ECOA_CONFIG_NAME
        ]) {
            apiParamsMap.put(mdt.DeveloperName, mdt);
        }
        System.debug('apiParamsMap::' + apiParamsMap);
    }

    public static void createSubject(List<Participant_Enrollment__c> peList) {
        List<Id> contactIds = new List<Id>();
        List<Id> ctpIds = new List<Id>();
        List<SObject> sObjectsList = new List<SObject>();
        // List<Participant_Enrollment__c> pesToUpdate = new List<Participant_Enrollment__c>();

        Map<Id, User> userContactIdMap = new Map<Id, User>();
        Map<Id, List<ECOA_Study_Schedule__c>> ctpScheduleMap = new Map<Id, List<ECOA_Study_Schedule__c>>();
        for (Participant_Enrollment__c peObj : peList) {
            contactIds.add(peObj.Participant_Contact__c);
            ctpIds.add(peObj.Clinical_Trial_Profile__c);
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
                User userObj = userContactIdMap.get(peObj.Participant_Contact__c);
                List<ECOA_Study_Schedule__c> studySchedulesList = ctpScheduleMap.get(
                    peObj.Clinical_Trial_Profile__c
                );
                System.debug(peObj);
                if (studySchedulesList.size() > 0) {
                    Map<String, String> headerMap = new Map<String, String>{
                        'Content-Type' => 'application/json',
                        'Authorization' => apiParamsMap.get(AUTHORIZATION_KEY).ParamValue__c,
                        'Av-Origin-Guid' => 'origin'
                    };
                    Map<String, String> requestMap = new Map<String, String>{
                        'username' => peObj.Participant__r.Email__c,
                        'email' => peObj.Participant__r.Email__c,
                        'timezone' => userObj.TimeZoneSidKey,
                        'ident' => peObj.Id,
                        'studyGuid' => peObj.Clinical_Trial_Profile__r.Study_GUID__c,
                        'studyVersionGuid' => peObj.Clinical_Trial_Profile__r.Study_Version_GUID__c,
                        'subjectLocale' => 'en',
                        'eproRuleSetGuid' => studySchedulesList[0].EproRuleSetGuid__c,
                        'clinroRuleSetGuid' => studySchedulesList[0].ClinroRuleSetGuid__c,
                        'loginType' => 'COGNITO'
                    };
                    HttpCallout remoteCall = new HttpCallout(
                        null,
                        'POST',
                        headerMap,
                        requestMap,
                        ECOAService.class
                    );

                    remoteCall.setEndPointURL(
                        apiParamsMap.get(END_POINT_URL).ParamValue__c +
                        '/api/v1/' +
                        apiParamsMap.get(ORG_GUID).ParamValue__c +
                        '/studies/' +
                        peObj.Clinical_Trial_Profile__r.Study_GUID__c +
                        '/subjects'
                    );

                    remoteCall.setAutoLogInsert(false);

                    String respBody = (String) remoteCall.execute();

                    if (remoteCall.log.Success__c) {
                        peObj.Subject_GUID__c = respBody;
                        // pesToUpdate.add(peObj);
                        sObjectsList.add(peObj);
                    }
                    if (remoteCall.log != null) {
                        sObjectsList.add(remoteCall.log);
                    }
                }
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
            allowedCallouts--;
        }

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
            ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
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
            ParticipantEnrollmentTriggerHandler.CreateWelcomeToStudyAlertHandler.class
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
            ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SendFOVtoAPI.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.UnenrollorCancelPer.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateECOASubject.class
        );

        if (sObjectsList.size() > 0) {
            sObjectsList.sort();
            Database.upsert(sObjectsList, false);
        }
    }
}
