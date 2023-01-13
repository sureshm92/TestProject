/**
 * Created by Leonid Bartenev
 */

public without sharing class IntegrationService {
    public class IntegrationServiceException extends Exception {
    }
    public static List<Integration_Log__c> intLogList; // Added by Krishna Mahto for REF-2183

    public class IntegrationMessage {
        public String protocolId;
        public String rrid;
        public SubjectDetails subjectDetails;
        public ReferralDetails referralDetails;
        public PatientDelegateDetails patientDelegateDetails; //REF-2882 
        public AuditLog auditLog;
        public string One_Key_ID;
        public string Site_Number;
    }

    public class CommunicationPreferences {
        public String Language;
    }

    public class Address {
        public String Street;
        public String Street2;
        public String City;
        public String State;
        public String PostalCode;
        public String Country;
        public String CountryCode;
    }

    public class ReferralDetails {
        public String ReferralId;
        public Date ReferralDate;
        public Date AcceptedDate;
        public boolean PriorityFlag;
        public Date InitialVisitScheduledDate;
        public Time InitialVisitScheduledTime;
        public String CountryName;
    }
    
    // START REF-2882
    public class PatientDelegateDetails {
        public String FirstName;
        public String LastName;
        public String Email;
        public String Phone;
        public String State;
        public String Country;
    }//END

    public class SubjectDetails {
        public String FirstName;
        public String LastName;
        public Address Address;
        public Contact Contact;
        public String DateOfBirth;
        public String Gender;
        public Boolean Adult; 
    } 

    public class AuditLog {
        public String UserId;
        public Datetime Timestamp;
    }

    public class Contact {
        public String Email;
        public String Phone;
        public CommunicationPreferences CommunicationPreferences;
    }

    public class ResponseResult {
        public Integration_Log__c log;
        public HttpResponse httpResponse;

        public ResponseResult(HttpResponse httpResponse, Integration_Log__c log) {
            this.httpResponse = httpResponse;
            this.log = log;
        }
    }

    public static final String END_POINT_URL = 'callout:ServiceNowAndStudyHub';
    public static final Integer TIMEOUT = 120000;

    private static Map<String, String> referralSourceEndpointMap;
    private static Map<String, Map<String, String>> referralSourceFieldsMap;
    private static String queriedStatusFields;

    public static Map<String, String> getReferralSourceEndpointMap() {
        if (referralSourceEndpointMap == null) {
            initStatusInegrationMaps();
        }
        return referralSourceEndpointMap;
    }
    public static Map<String, Map<String, String>> getReferralSourceFieldsMap() {
        if (referralSourceFieldsMap == null) {
            initStatusInegrationMaps();
        }
        return referralSourceFieldsMap;
    }
    public static String getQueriedStatusFields() {
        if (queriedStatusFields == null || queriedStatusFields == '') {
            initStatusInegrationMaps();
        }
        return queriedStatusFields;
    }
    //This method is not in use anymore.
    @Future(Callout=true)
    public static void sendPEToServiceNowAsync(Id participantEnrollmentId) {
        sendPEToServiceNow(participantEnrollmentId);
    }

    public static void sendPEToServiceNow(Id participantEnrollmentId) {
        IntegrationMessage integrationMessage = createIntegrationMessage(
            participantEnrollmentId,
            false
        );
        if (integrationMessage == null)
            return;
        String integrationMessageString = JSON.serializePretty(integrationMessage, true);
        ResponseResult result = sendIntegrationMessage(
            END_POINT_URL,
            participantEnrollmentId,
            integrationMessageString
        );
        update new Participant_Enrollment__c(
            Id = participantEnrollmentId
            //Service_Now_Sent_Date__c = Datetime.now()
            //Study_Hub_Log__c = result.log.Id
        );
    }

    @Future(Callout=true)
    public static void sendPEToStudyHubAsync(Id participantEnrollmentId) {
        sendPEToStudyHub(participantEnrollmentId);
    }

    @Future(Callout=true)
    public static void sendPESHToEPRAsync(List<Id> participantEnrollmentStatusHistoryIds) {
        sendPESHToEPR(participantEnrollmentStatusHistoryIds);
    }

    public static void sendPEToStudyHub(Id participantEnrollmentId) {
        IntegrationMessage integrationMessage = createIntegrationMessage(participantEnrollmentId,true, true);
        System.debug('PE: ' + integrationMessage);
        if (integrationMessage == null)
            return;
        String integrationMessageString = JSON.serializePretty(integrationMessage, true);
        ResponseResult result = sendIntegrationMessage(END_POINT_URL,participantEnrollmentId,integrationMessageString);
        update new Participant_Enrollment__c(Id = participantEnrollmentId,Study_Hub_Log__c = result.log.Id);
    }

    //Added by Krishna for REF-2183 - Start
    //Added to be called from UploadParticipantsBatch class
    public static Integration_Log__c sendPEToStudyHubBatch(Id participantEnrollmentId) {
        IntegrationMessage integrationMessage = createIntegrationMessage(participantEnrollmentId,true);
        System.debug('PE: ' + integrationMessage);
        if (integrationMessage == null) {
            return null;
        }
        String integrationMessageString = JSON.serializePretty(integrationMessage, true);
        ResponseResult result = sendIntegrationMessageBatch(END_POINT_URL,participantEnrollmentId,integrationMessageString);
        Integer logListLength = intLogList.size();
        //Removing The latest log from the List intLogList as latest log is getting returned in this method.
        if (logListLength > 0) {
            logListLength = logListLength - 1;
            intLogList.Remove(logListLength);
        }
        return result.log;
    }

    public static void sendPESHToEPR(List<Id> participantEnrollmentSHIds) {
        Map<String, String> integrationMessagesMap = createStatusIntegrationMessage(participantEnrollmentSHIds);
        System.debug('PESH: ' + integrationMessagesMap);
        if (integrationMessagesMap == null)
            return;
        for (String endpoint : integrationMessagesMap.keySet()) {
            ResponseResult result = sendIntegrationMessage( 'callout:' + endpoint, String.join(participantEnrollmentSHIds, ','), integrationMessagesMap.get(endpoint));
        }
    }

    //Added to be called from UploadParticipantsBatch class
    public static void sendPESHToEPRBatch(List<Id> participantEnrollmentSHIds) {
        Map<String, String> integrationMessagesMap = createStatusIntegrationMessage(participantEnrollmentSHIds);
        System.debug('PESH: ' + integrationMessagesMap);
        if (integrationMessagesMap == null)
            return;
        for (String endpoint : integrationMessagesMap.keySet()) {
            ResponseResult result = sendIntegrationMessageBatch(
                'callout:' + endpoint,String.join(participantEnrollmentSHIds, ','),integrationMessagesMap.get(endpoint));
        }
    }

    public static ResponseResult sendIntegrationMessage(String endpointURl,String sourceId,String integrationMessage) {
        ResponseResult responseResult;
        Integer currentAttempt = 1;
        Integer attemptsCount = 3;
        List<Integration_Log__c> logs = new List<Integration_Log__c>();
        while (true) {
            responseResult = send(endpointURl,'POST',TIMEOUT,sourceId,integrationMessage,currentAttempt);
            logs.add(responseResult.log);
            if (
                (responseResult.httpResponse != null &&
                responseResult.httpResponse.getStatusCode() == 500) &&
                currentAttempt < attemptsCount
            ) {
                currentAttempt++;
                sleep(10000);
                continue;
            }
            break;
        }
        insert logs;
        return responseResult;
    }

    public static ResponseResult sendIntegrationMessageBatch(String endpointURl,String sourceId,String integrationMessage) {
        ResponseResult responseResult;
        Integer currentAttempt = 1;
        Integer attemptsCount = 3;
        List<Integration_Log__c> logs = new List<Integration_Log__c>();
        while (true) {
            responseResult = send(endpointURl,'POST',TIMEOUT,sourceId,integrationMessage,currentAttempt);
            logs.add(responseResult.log);
            if (
                (responseResult.httpResponse != null && responseResult.httpResponse.getStatusCode() == 500) && currentAttempt < attemptsCount) {
                currentAttempt++;sleep(10000);continue;
            }
            break;
        }
        intLogList.AddAll(logs);
        return responseResult;
    }

    public static ResponseResult send( String url,String method,Integer timeout,String sourceId,String requestBody,Integer attemptNumber) {
        //init request:
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('POST');
        request.setTimeout(timeout);
        request.setBody(requestBody);
        Datetime requestDT = Datetime.now();
        Datetime responseDT;
        //init log:
        Integration_Log__c log = new Integration_Log__c(End_Point_URL__c = url.mid(0, 255),Method__c = method,Request__c = requestBody.mid(0, 32768),Response_Time__c = requestDT,Source_Id__c = sourceId.mid(0, 255),Attempt__c = attemptNumber, Request_Time__c = requestDT, Timeout__c = timeout);
        Http h = new Http();
        //send request:
        HttpResponse response;
        try {
            response = h.send(request);
            responseDT = Datetime.now();
            System.debug('RESPONSE: ' +response.getStatus() +' code: ' +response.getStatusCode());
            //update log:
            log.Response_Status__c = response.getStatus();
            log.Response_Status_Code__c = response.getStatusCode();
            log.Response__c = response.getBody().mid(0, 32768);
        } catch (Exception e) {
            responseDT = Datetime.now();
            System.debug('ERROR: ' + e.getMessage());
            //update log:
            log.Exception__c = (e.getMessage() + '\n' + e.getStackTraceString()).mid(0, 32768);
        } finally {
            //update log:
            log.Response_Time__c = responseDT;
            log.Call_Duration_Seconds__c = (responseDT.getTime() - requestDT.getTime()) / 1000.0;
        }
        return new ResponseResult(response, log);
    }

    public static IntegrationMessage createIntegrationMessage(Id participantEnrollmentId, Boolean setAcceptedDate
    ){
        return createIntegrationMessage(participantEnrollmentId, setAcceptedDate, false);
    }

    public static IntegrationMessage createIntegrationMessage(Id participantEnrollmentId,Boolean setAcceptedDate, Boolean isSendToSHOrNot
    ) {
        Participant_Enrollment__c pe = [
            SELECT
                Id,
                Name,
                Participant__r.First_Name__c,
                Participant__r.Last_Name__c,
                Participant__r.Phone__c,
                Participant__r.Email__c,
                Participant__r.Mailing_City__c,
                Participant__r.Mailing_State__c,
                Participant__r.Mailing_State_Code__c,
                Participant__r.Mailing_Zip_Postal_Code__c,
                Participant__r.Mailing_Country__c,
                Participant__r.Mailing_Country_Code__c,
                Participant__r.Country_Code__c,
                Participant__r.Country__c,
                Participant__r.Mailing_Street__c,
                Participant__r.Preferred_Language__c,
                Participant__r.Date_of_Birth__c,
                Participant__r.Birth_Day__c,
                Participant__r.Birth_Month__c,
                Participant__r.Birth_Year__c,
                Participant__r.Gender__c,
                Participant__r.Adult__c,
                Referral_ID__c,
                Referred_Date__c,
                High_Priority__c,
                Initial_visit_scheduled_date__c,
                Initial_visit_scheduled_time__c,
                Clinical_Trial_Profile__r.Promote_to_SH__c,
                Clinical_Trial_Profile__r.DCT_Platform__c,
                Study_Site__r.Participant_DOB_format__c,
                Study_Site__r.Protocol_ID__c,
                Study_Site__r.Study_Site_Type__c,
                Study_Site__r.Study_Site_Number__c,
                Study_Site__r.Principal_Investigator__r.OneKeyID__c,
                Study_Site__r.Site__r.BillingCountry
            FROM Participant_Enrollment__c
            WHERE Id = :participantEnrollmentId
        ];
		
        // START REF-2882
       List<Patient_Delegate__c> lstpatientDel = [
            SELECT
                Id,
            	Contact__c
            	FROM Patient_Delegate__c 
            	WHERE Participant__c =: pe.Participant__r.Id
            	AND Primary_Delegate__c = True ORDER BY CreatedDate ASC LIMIT 1               
        ]; //END
        
        List<Participant__c> lstParticipant = new List<Participant__c>();
        if(!lstpatientDel.isEmpty()){
			lstParticipant = [Select Id, First_Name__c, Last_Name__c, Email__c, Phone__c, Mailing_State__c, Mailing_Country__c FROM Participant__c where Contact__c =: lstpatientDel[0].Contact__c LIMIT 1];
		}
        
        if (!StudySiteService.SS_TYPE_VT_INTEGRATION.contains(pe.Study_Site__r.Study_Site_Type__c))
            return null;
        if(isSendToSHOrNot == true && 
            (pe.Clinical_Trial_Profile__r.Promote_to_SH__c != true || 
            pe.Clinical_Trial_Profile__r.DCT_Platform__c!= 'Study Hub')
        ) {
            return null;
        }
        Address addr = new Address();
        addr.Street = pe.Participant__r.Mailing_Street__c;
        addr.Street2 = pe.Participant__r.Mailing_Street__c;
        addr.City = pe.Participant__r.Mailing_City__c;
        addr.State = pe.Participant__r.Mailing_State_Code__c;
        addr.PostalCode = pe.Participant__r.Mailing_Zip_Postal_Code__c;
        addr.Country = pe.Participant__r.Mailing_Country__c;
        addr.CountryCode = pe.Participant__r.Mailing_Country_Code__c;

        CommunicationPreferences communicationPreferences = new CommunicationPreferences();
        communicationPreferences.Language = pe.Participant__r.Preferred_Language__c;

        Contact contact = new Contact();
        contact.Email = pe.Participant__r.Email__c;
        contact.Phone = pe.Participant__r.Phone__c;
        contact.CommunicationPreferences = communicationPreferences;

        ReferralDetails referralDetails = new ReferralDetails();
        referralDetails.ReferralId = pe.Name;
        referralDetails.ReferralDate = pe.Referred_Date__c;
        referralDetails.PriorityFlag = pe.High_Priority__c;
        referralDetails.InitialVisitScheduledDate = pe.Initial_visit_scheduled_date__c;
        referralDetails.InitialVisitScheduledTime = pe.Initial_visit_scheduled_time__c;
        referralDetails.CountryName = pe.Study_Site__r.Site__r.BillingCountry;
        if (setAcceptedDate)
            referralDetails.AcceptedDate = Date.today();
		
        PatientDelegateDetails patientDelegateDetails = new PatientDelegateDetails();
        // START Added by Sumit S REF-2882
        if(!lstParticipant.isEmpty()){
		patientDelegateDetails.FirstName = lstParticipant[0].First_Name__c;
		patientDelegateDetails.LastName = lstParticipant[0].Last_Name__c;
		patientDelegateDetails.Email = lstParticipant[0].Email__c;
		patientDelegateDetails.Phone = lstParticipant[0].Phone__c;
		patientDelegateDetails.State = lstParticipant[0].Mailing_State__c;
		patientDelegateDetails.Country = lstParticipant[0].Mailing_Country__c; 
        }
        //END
        
        SubjectDetails subjectDetails = new SubjectDetails();
        subjectDetails.FirstName = pe.Participant__r.First_Name__c;
        subjectDetails.LastName = pe.Participant__r.Last_Name__c;
        subjectDetails.Address = addr;
        subjectDetails.Contact = contact;
        //subjectDetails.DateOfBirth = pe.Participant__r.Date_of_Birth__c;
        subjectDetails.DateOfBirth = '';
        if(pe.Study_Site__r.Participant_DOB_format__c == 'DD-MM-YYYY' && !string.isblank(pe.Participant__r.Birth_Year__c)
           && !string.isblank(pe.Participant__r.Birth_Day__c) && !string.isBlank(pe.Participant__r.Birth_Month__c)){
            subjectDetails.DateOfBirth = pe.Participant__r.Birth_Year__c+'-'+pe.Participant__r.Birth_Month__c+'-'+pe.Participant__r.Birth_Day__c;            
        }else if(pe.Study_Site__r.Participant_DOB_format__c == 'MM-YYYY' && 
                 !string.isblank(pe.Participant__r.Birth_Year__c) && !string.isBlank(pe.Participant__r.Birth_Month__c)){
            subjectDetails.DateOfBirth = pe.Participant__r.Birth_Year__c+'-'+pe.Participant__r.Birth_Month__c;             
        }else if(pe.Study_Site__r.Participant_DOB_format__c == 'YYYY' && !string.isblank(pe.Participant__r.Birth_Year__c)){
            subjectDetails.DateOfBirth = pe.Participant__r.Birth_Year__c; 
        }
        subjectDetails.Gender = pe.Participant__r.Gender__c;
        subjectDetails.Adult = pe.Participant__r.Adult__c;

        AuditLog auditLog = new AuditLog();
        auditLog.UserId = UserInfo.getUserId();
        auditLog.Timestamp = Datetime.now();

        IntegrationMessage integrationMessage = new IntegrationMessage();
        integrationMessage.protocolId = pe.Study_Site__r.Protocol_ID__c;
        integrationMessage.rrid = pe.Id;
        integrationMessage.subjectDetails = subjectDetails;
        integrationMessage.referralDetails = referralDetails;
        integrationMessage.patientDelegateDetails = patientDelegateDetails; //REF-2882
        integrationMessage.auditLog = auditLog;
        integrationMessage.One_Key_ID = pe.Study_Site__r.Principal_Investigator__r.OneKeyID__c;
        integrationMessage.Site_Number = pe.Study_Site__r.Study_Site_Number__c; //Added by vicky REF-2653
        return integrationMessage;
    }

    public static Map<String, String> createStatusIntegrationMessage(
        List<Id> participantEnrollmentSHIds
    ) {
        Map<String, List<Map<String, String>>> endpointToIntegrationMessagesMap = new Map<String, List<Map<String, String>>>();
        Set<String> refSources = getReferralSourceEndpointMap().keySet();
        String quertString ='SELECT ' +getQueriedStatusFields() +' FROM Participant_Enrollment_Status_History__c ' + 'WHERE Id IN :participantEnrollmentSHIds AND ParticipantEnrollment__r.Referral_Source__c IN :refSources';
        List<Participant_Enrollment_Status_History__c> statusHistories = Database.query(quertString);
        for (Participant_Enrollment_Status_History__c pesh : statusHistories) {
            Map<String, String> statusIntegrationMessage = new Map<String, String>();
            Map<String, String> fieldMap = getReferralSourceFieldsMap()
                .get(pesh.ParticipantEnrollment__r.Referral_Source__c);
            String endpoint = getReferralSourceEndpointMap()
                .get(pesh.ParticipantEnrollment__r.Referral_Source__c);

            for (String key : fieldMap.keySet()) {
                statusIntegrationMessage.put(key, getFieldValue(pesh, fieldMap.get(key)));
            }

            if (endpointToIntegrationMessagesMap.get(endpoint) == null) {
                endpointToIntegrationMessagesMap.put(endpoint, new List<Map<String, String>>());
            }
            endpointToIntegrationMessagesMap.get(endpoint).add(statusIntegrationMessage);
        }
        Map<String, String> result = new Map<String, String>();
        for (String endpoint : endpointToIntegrationMessagesMap.keySet()) {
            result.put(endpoint,JSON.serializePretty(endpointToIntegrationMessagesMap.get(endpoint), true));
        }
        System.debug(result);
        return result;
    }

    //timeout on milliSeconds
    public static void sleep(Long milliSeconds) {
        Long timeDiff = 0;
        Datetime firstTime = System.now();
        do {
            timeDiff = System.now().getTime() - firstTime.getTime();
        } while (timeDiff <= milliSeconds);
    }

    public static void initStatusInegrationMaps() {
        referralSourceEndpointMap = new Map<String, String>();
        referralSourceFieldsMap = new Map<String, Map<String, String>>();
        Set<String> queriedStatusFieldsSet = new Set<String>();
        for (Participant_Status_Integration__mdt setting : [SELECT Id, Fields__c, ApiFieldNames__c, Referral_Sources__c, Named_Credential__c FROM Participant_Status_Integration__mdt]) {
            for (String field : setting.Fields__c.split(',')) {
                queriedStatusFieldsSet.add(field.trim());
            }
            Map<String, String> fieldMap = createFieldMap(
                setting.ApiFieldNames__c,
                setting.Fields__c
            );
            for (String refSource : setting.Referral_Sources__c.split(',')) {
                referralSourceEndpointMap.put(refSource.trim(), setting.Named_Credential__c);
                referralSourceFieldsMap.put(refSource.trim(), fieldMap);
            }
        }
        queriedStatusFields = string.join(new List<String>(queriedStatusFieldsSet), ', ');
        System.debug(referralSourceFieldsMap);
        System.debug(referralSourceEndpointMap);
        System.debug(queriedStatusFields);
    }
    public static Map<String, String> createFieldMap(String keys, String values) {
        Map<String, String> result = new Map<String, String>();
        List<String> keysList = keys.split(',');
        List<String> valuesList = values.split(',');
        for (Integer i = 0; i < Math.min(keysList.size(), valuesList.size()); i++) {
            result.put(keysList[i].trim(), valuesList[i].trim());
        }
        return result;
    }

    public static String getFieldValue(
        Participant_Enrollment_Status_History__c pesh,
        String fieldName
    ) {
        SObject tempSObject = pesh;
        List<String> fieldPath = fieldName.split('\\.');
        for (Integer i = 0; i < fieldPath.size() - 1; i++) {
            tempSObject = tempSObject.getSObject(fieldPath[i]);
        }
        Object field = tempSObject.get(fieldPath[fieldPath.size() - 1]);
        if (field == null) {
            return '';
        } else if (field instanceof Datetime) {
            return ((Datetime) field).format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        } else if (field instanceof Date) {
            return ((Date) field).format();
        }
        return (String) field;
    }
}