public without sharing class rpPatientOutreachAPIController {

    public class PatientOutreachWrapper {
        public String studyCodeName;
        public String participantId;
        public String participantFirstName;
        public String participantSurName;
        public String participantEmail;
        public String participantCountry;
        public Boolean isDelegate;
        public String primaryDelegateEmail;
        public String primaryDelegateFirstName;
        public String primaryDelegateLastName;
        public String studyURL;
        public String studySiteName;
        public String condition;
        public String language;
        public String statusCode;
        public String createdDate;
        public String indication;
        public RpDetailsWrapper rpDetails;
    }
    public class RpDetailsWrapper {
        public String rpName;
        public String rpTelephone;
        public String rpEmail;
        public RpAddressWrapper rpAddress;
    }
    
    public class RpAddressWrapper {
        public String rpAddressLine1;
        public String rpAddressLine2;
        public String rpZip;
        public String rpCity;
        public String rpCountry;
        public String rpState;
    }

   

	public class PatientOutreachResults {
		public String participantId;
		public String studyCodeName;
		public String studySiteName;
		public String statusCode;
		public String statusMessage;
		public Object salesforceErrorMessages;
	}

    public static PatientOutreachWrapper generateObjectToJSON(Participant_Enrollment__c per ){
        PatientOutreachWrapper outreachWrapper = new PatientOutreachWrapper();
        outreachWrapper.studyCodeName = per.Clinical_Trial_Profile__r.Study_Code_Name__c;
        outreachWrapper.participantId = per.Name;
        outreachWrapper.participantFirstName =  per.Participant_Name__c;
        outreachWrapper.participantSurName =  per.Participant_Surname__c;
        outreachWrapper.participantEmail =  per.Email__c;
        outreachWrapper.participantCountry =  per.Mailing_Country_Code__c;
        outreachWrapper.isDelegate =  false;
        outreachWrapper.primaryDelegateEmail =  per.Primary_Delegate_Email__c;
        outreachWrapper.primaryDelegateFirstName =  per.Primary_Delegate_First_Name__c;
        outreachWrapper.primaryDelegateLastName =  per.Primary_Delegate_Last_Name__c;
        outreachWrapper.studyURL = per.Clinical_Trial_Profile__r.Link_to_ePR_Campaign__c;
        outreachWrapper.studySiteName = per.Study_Name__c;
        outreachWrapper.condition = per.Clinical_Trial_Profile__r.Condition_s_Therapeutic_Area__c;
        String languageStr = per.PI_Contact__r.Language__c;
        outreachWrapper.language =  languageStr.substring(0,2);
        outreachWrapper.statusCode =  '';
        outreachWrapper.createdDate =  String.Valueof(per.createdDate);
        outreachWrapper.indication = per.Clinical_Trial_Profile__r.Condition_s_Therapeutic_Area__c;

        RpDetailsWrapper rpRecord = new RpDetailsWrapper();
        rpRecord.rpName = per.PI_Contact__r.Name;
        rpRecord.rpTelephone = per.PI_Contact__r.Phone;
        rpRecord.rpEmail = per.PI_Contact__r.Email;

        RpAddressWrapper rpAddressRecord = new RpAddressWrapper();
        rpAddressRecord.rpAddressLine1 = per.PI_Contact__r.MailingStreet;//String.Valueof(per.PI_Contact__r.MailingAddress);
        rpAddressRecord.rpAddressLine2 =  '';
        rpAddressRecord.rpZip = per.PI_Contact__r.MailingPostalCode;
        rpAddressRecord.rpCity = per.PI_Contact__r.MailingCity;
        rpAddressRecord.rpCountry = per.PI_Contact__r.MailingCountry;
        rpAddressRecord.rpState = per.PI_Contact__r.MailingState;
        rpRecord.rpAddress = rpAddressRecord;
        outreachWrapper.RpDetails = rpRecord;
        return outreachWrapper;
    }

    public static void sendDataToMuleSoft(String patientOutreachData) {        
        HTTP h = new HTTP();
        HTTPRequest r = new HTTPRequest();
        //	https://iqvia-rds-rh-outreach-exp-1-0-dev.us-e1.cloudhub.io/api/sitemediatedoutreaches
        //https://iqvia-rds-rh-outreach-exp-1-0-dev.us-e1.cloudhub.io/api/patientoutreaches
        r.setEndpoint('callout:HumanAPI_MulesoftCnct');
        r.setHeader('Content-Type', 'application/json;charset=UTF-8');
        r.setMethod('POST');
        r.setbody(patientOutreachData);
        System.debug('###### request ' +r.getBody());
        HTTPResponse resp = h.send(r);
        System.debug('###### resp ' +resp);
        System.debug('###### resp ' +resp.getBody());

        List<IntegrationLog__c> objIntegrationLogList = new List<IntegrationLog__c>();
       //JsonParser parser = JSON.createParser(resp.getBody());
       System.debug(resp.getBody());
       PatientOutreachLog log = PatientOutreachLog.parse(resp.getBody());
      System.debug (PatientOutreachLog.parse(resp.getBody()));
      //  String jSONstr = JSON.serialize(resp.getBody());
      //  System.debug(jSONstr);
      //  List<PatientOutreachResults> deserializedResponseWrapper = (List<PatientOutreachResults>)JSON.deserialize(jSONstr, List<PatientOutreachResults>.class);
      System.debug ('log' + log.results);

        for (PatientOutreachLog.Results wrap: log.results){
            IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
            objIntegrationLog.Request_Body__c = patientOutreachData;
            objIntegrationLog.Request_Time__c  = Datetime.now();
            objIntegrationLog.Response_Body__c = String.valueOf(wrap);
            objIntegrationLog.Response_Status__c = resp.getStatus();
            objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();
            objIntegrationLog.Request_Type__c = 'PatientOutreach_RHtoMulesoft';
            objIntegrationLog.Function_Name__c = 'rpPatientOutreachAPIController_sendDataToMuleSoft';
            objIntegrationLog.Success__c = resp.getStatusCode() == 200 ? True : false;
            objIntegrationLog.Http_Method__c = 'POST';
            objIntegrationLogList.add(objIntegrationLog);
        }

        insert objIntegrationLogList;

       /* IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
        objIntegrationLog.Request_Body__c = patientOutreachData;
        objIntegrationLog.Request_Time__c  = Datetime.now();
        objIntegrationLog.Response_Body__c = resp.getBody();
        objIntegrationLog.Response_Status__c = resp.getStatus();
        objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();
        objIntegrationLog.Request_Type__c = 'PatientOutreach_RHtoMulesoft';
        objIntegrationLog.Function_Name__c = 'rpPatientOutreachAPIController_sendDataToMuleSoft';
        objIntegrationLog.Success__c = resp.getStatusCode() == 200 ? True : false;
        objIntegrationLog.Http_Method__c = 'POST';
        insert objIntegrationLog;*/

    }
    
}