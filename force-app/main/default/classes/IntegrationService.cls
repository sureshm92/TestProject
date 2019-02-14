/**
 * Created by Leonid Bartenev
 */

public without sharing class  IntegrationService {
    
    public class IntegrationServiceException extends Exception{}
    
    public class IntegrationMessage{
        public String protocolId;
        public String rrid;
        public SubjectDetails subjectDetails;
        public ReferralDetails referralDetails;
        public AuditLog auditLog;
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
    }
    
    public class SubjectDetails {
        public String FirstName;
        public String LastName;
        public Address Address;
        public Contact Contact;
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
    
    public class ResponseResult{
        public Integration_Log__c log;
        public HttpResponse httpResponse;
    
        public ResponseResult(HttpResponse httpResponse, Integration_Log__c log){
            this.httpResponse = httpResponse;
            this.log = log;
        }
    }
    
    public static final String END_POINT_URL = 'callout:ServiceNowAndStudyHub';
    public static final Integer TIMEOUT = 120000;
    
    @Future(Callout=true)
    public static void sendPEToServiceNowAsync(Id participantEnrollmentId){
        sendPEToServiceNow(participantEnrollmentId);
    }
    
    public static void sendPEToServiceNow(Id participantEnrollmentId){
        IntegrationMessage integrationMessage = createIntegrationMessage(participantEnrollmentId, false);
        if(integrationMessage == null) return;
        ResponseResult result = sendIntegrationMessage(participantEnrollmentId, integrationMessage);
        update new Participant_Enrollment__c(
                Id = participantEnrollmentId
                //Service_Now_Sent_Date__c = Datetime.now()
                //Study_Hub_Log__c = result.log.Id
        );
    }
    
    @Future(Callout=true)
    public static void sendPEToStudyHubAsync(Id participantEnrollmentId){
        sendPEToStudyHub(participantEnrollmentId);
    }
    
    public static void sendPEToStudyHub(Id participantEnrollmentId){
        IntegrationMessage integrationMessage = createIntegrationMessage(participantEnrollmentId, true);
        System.debug('PE: ' + integrationMessage);
        if(integrationMessage == null) return;
        ResponseResult result = sendIntegrationMessage(participantEnrollmentId, integrationMessage);
        update new Participant_Enrollment__c(
                Id = participantEnrollmentId,
                Study_Hub_Log__c = result.log.Id
        );
    }
    
    public static ResponseResult sendIntegrationMessage(String sourceId, IntegrationMessage integrationMessage){
        String dataJSON = JSON.serializePretty(integrationMessage, true);
        ResponseResult responseResult;
        Integer currentAttempt = 1;
        Integer attemptsCount = 3;
        List<Integration_Log__c> logs = new List<Integration_Log__c>();
        while(true){
            responseResult = send(END_POINT_URL, 'POST', TIMEOUT, sourceId, dataJSON, currentAttempt);
            logs.add(responseResult.log);
            if((responseResult.httpResponse != null && responseResult.httpResponse.getStatusCode() == 500) && currentAttempt < attemptsCount){
                currentAttempt ++;
                sleep(10000);
                continue;
            }
            break;
        }
        insert logs;
        return responseResult;
    }
    
    public static ResponseResult send(String url, String method, Integer timeout,String sourceId, String requestBody, Integer attemptNumber){
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
        Integration_Log__c log = new Integration_Log__c(
                End_Point_URL__c = url.mid(0, 255),
                Method__c = method,
                Request__c = requestBody.mid(0, 32768),
                Response_Time__c = requestDT,
                Source_Id__c = sourceId.mid(0, 255),
                Attempt__c = attemptNumber,
                Request_Time__c = requestDT,
                Timeout__c = timeout
        );
        Http h = new Http();
        //send request:
        HttpResponse response;
        try{
            response = h.send(request);
            responseDT = Datetime.now();
            System.debug('RESPONSE: ' + response.getStatus() + ' code: ' + response.getStatusCode());
            //update log:
            log.Response_Status__c = response.getStatus();
            log.Response_Status_Code__c = response.getStatusCode();
            log.Response__c = response.getBody().mid(0, 32768);
        }catch (Exception e){
            responseDT = Datetime.now();
            System.debug('ERROR: ' + e.getMessage());
            //update log:
            log.Exception__c = (e.getMessage() + '\n' + e.getStackTraceString()).mid(0, 32768);
        }finally {
            //update log:
            log.Response_Time__c = responseDT;
            log.Call_Duration_Seconds__c = (responseDT.getTime() - requestDT.getTime()) / 1000.0;
        }
        return new ResponseResult(response, log);
    }
    
    public static IntegrationMessage createIntegrationMessage(Id participantEnrollmentId, Boolean setAcceptedDate){
        Participant_Enrollment__c pe = [
                SELECT Id,
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
                        Participant__r.Language_Preference_Code__c,
                        Referral_ID__c,
                        Referred_Date__c,
                        Study_Site__r.Protocol_ID__c,
                        Study_Site__r.Is_Virtual_Study_Site__c
                FROM Participant_Enrollment__c
                WHERE Id =: participantEnrollmentId
        ];
        
        if(!pe.Study_Site__r.Is_Virtual_Study_Site__c) return null;
        
        Address addr = new Address();
        addr.Street = pe.Participant__r.Mailing_Street__c;
        addr.Street2 = pe.Participant__r.Mailing_Street__c;
        addr.City = pe.Participant__r.Mailing_City__c;
        addr.State = pe.Participant__r.Mailing_State_Code__c;
        addr.PostalCode = pe.Participant__r.Mailing_Zip_Postal_Code__c;
        addr.Country = pe.Participant__r.Mailing_Country__c;
        addr.CountryCode = pe.Participant__r.Mailing_Country_Code__c;
        
        CommunicationPreferences communicationPreferences = new CommunicationPreferences();
        communicationPreferences.Language = pe.Participant__r.Language_Preference_Code__c;
        
        Contact contact = new Contact();
        contact.Email = pe.Participant__r.Email__c;
        contact.Phone = pe.Participant__r.Phone__c;
        contact.CommunicationPreferences = communicationPreferences;
        
        ReferralDetails referralDetails = new ReferralDetails();
        referralDetails.ReferralId = pe.Name;
        referralDetails.ReferralDate =  pe.Referred_Date__c;
        if(setAcceptedDate) referralDetails.AcceptedDate = Date.today();
        
        SubjectDetails subjectDetails = new SubjectDetails();
        subjectDetails.FirstName = pe.Participant__r.First_Name__c;
        subjectDetails.LastName = pe.Participant__r.Last_Name__c;
        subjectDetails.Address = addr;
        subjectDetails.Contact = contact; 
    
        AuditLog auditLog = new AuditLog();
        auditLog.UserId = UserInfo.getUserId();
        auditLog.Timestamp = Datetime.now();
        
        IntegrationMessage integrationMessage = new IntegrationMessage();
        integrationMessage.protocolId = pe.Study_Site__r.Protocol_ID__c;
        integrationMessage.rrid = pe.Id;
        integrationMessage.subjectDetails = subjectDetails;
        integrationMessage.referralDetails = referralDetails;
        integrationMessage.auditLog = auditLog;

        return integrationMessage;
    }
    
    //timeout on milliSeconds
    public static void sleep(Long milliSeconds){
        Long timeDiff = 0;
        Datetime firstTime = System.now();
        do {
            timeDiff = System.now().getTime() - firstTime.getTime();
        } while (timeDiff <= milliSeconds);
    }


}