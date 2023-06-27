public with sharing class HumanAPIcontroller {

  public class RequestWrapperToken{
    public String client_id;
    public String client_secret;
    public String client_user_id;
    public String type;
  }

  public class ResponseWrapperToken{
    public String access_token;
    public String expires_in;
    public String token_type;
    public String refresh_token;
  }

  public class ResponseWrapperReportList{
    @AuraEnabled
    public String id;
    @AuraEnabled
    public Datetime createdAt;
    @AuraEnabled
    public String updatedAt;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public ResponseWrapperReportListOrganization organization;
  }
    
    public class RH_MulesoftWrapper {

    public String salesforce_Id;
    public String enrollmentName;
    public String humanId;
    public String participantFullName;
    public String participantFirstName;
    public String participantLastName;
    public String participantEmail;
    public String studySiteName;
    public String studyCodeName;
    public String uniqueHumanId;
    public String primaryDelegateEmail;
    public String primaryDelegateFirstName;
    public String primaryDelegateLastName;
    public String pIname;
    public String language;
    public String country;
    public String salutation;
  Public String protocolId; 
     
    }

  public class ResponseWrapperReportListOrganization {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String href;
  }

  public class RequestWrapperTokenRegister {
    public String client_id;
    public String client_secret;
    public String client_user_id;
    public String client_user_email;
    public String type;
  }

  public class ResponseWrapperTokenRegister {
    public String session_token;
    public String human_id;
    public String expires_in;
  }

      public static String generateAccessToken(
        String client_id,
        String client_secret,
        String humanId
      ) {
    String accessToken = null;
    RequestWrapperToken reqWrap = new RequestWrapperToken();
    reqWrap.client_id = client_id;
    reqWrap.client_secret = client_secret;
    reqWrap.client_user_id = humanId;
    reqWrap.type = 'access';

    String requestBody = JSON.serialize(reqWrap);

    Http h = new HTTP();
    HTTPRequest req = new HTTPRequest();
    req.setEndpoint('callout:HumanAPI_Connect');
    req.setHeader('Content-Type', 'application/json;charset=UTF-8');
    req.setMethod('POST');
    req.setbody(requestBody);
    System.debug('###### request ' +req.getBody());
    HTTPResponse resp = h.send(req);
    System.debug('###### resp ' +resp);
    System.debug('###### resp ' +resp.getBody());
    if (resp.getStatusCode() == 200){
      ResponseWrapperToken deserializedResponseWrapperToken = (ResponseWrapperToken) JSON.deserialize(
        resp.getBody(),
        ResponseWrapperToken.class
      );
      accessToken = deserializedResponseWrapperToken.access_token;
    }
    return accessToken;
  }

  public static List<ReportListWrapperWithURL> getListOfReports(
    String accessToken,
    String reportUrl
  ) {
    List<ReportListWrapperWithURL> reportUrlWrapperList = new List<ReportListWrapperWithURL>();
    Map<String, String> sourceToSourceName = getSources(accessToken);
    if (!sourceToSourceName.isEmpty()){
      Http h = new HTTP();
      HTTPRequest req = new HTTPRequest();
      req.setEndpoint('callout:HumanAPI_ReportList');
      req.setHeader('Authorization', 'Bearer ' + accessToken);
      req.setHeader('Content-Type', 'application/json;charset=UTF-8');
      req.setMethod('GET');
      HTTPResponse resp = h.send(req);
      System.debug('###### resp ' +resp);
      System.debug('###### resp ' +resp.getBody());
      if(resp.getStatusCode() == 200){
        List<ResponseWrapperReportList> deserializedResponseWrapperReportList = (List<ResponseWrapperReportList>) JSON.deserialize(
          resp.getBody(),
          List<ResponseWrapperReportList>.class
        );
        for (
          ResponseWrapperReportList var : deserializedResponseWrapperReportList
        ) {
          ReportListWrapperWithURL wrap = new ReportListWrapperWithURL();
          if (var.name == 'unity') {
            String url = reportUrl;
            String tail = '/raw?format=pdf&access_token=' + accessToken;
            String reportId = var.id;
            String finalUrl = url + reportId + tail;
            wrap.reportName = 'Detailed Report';
            wrap.reportUrl = finalUrl;
            wrap.createdAt = var.createdAt.format('MMM dd, yyyy, hh:mm a');
            wrap.providerName = sourceToSourceName.get(var.organization.id);
            reportUrlWrapperList.add(wrap);
          } else if (var.name == 'highlights') {
            String url = reportUrl;
            String tail = '/raw?format=pdf&access_token=' + accessToken;
            String reportId = var.id;
            String finalUrl = url + reportId + tail;
            wrap.reportName = 'Highlights Report';
            wrap.reportUrl = finalUrl;
            reportUrlWrapperList.add(wrap);
          }
        }
      }
    }

    return reportUrlWrapperList;
  }

  public class ReportListWrapperWithURL {
    @AuraEnabled
    public String providerName;
    @AuraEnabled
    public String reportName;
    @AuraEnabled
    public String reportUrl;
    @AuraEnabled
    public String createdAt;
  }

  public class SourceDetails{
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String source;
    @AuraEnabled
    public String sourceName;
    @AuraEnabled
    public SyncStatus syncStatus;
  }

  public class SyncStatus{
    @AuraEnabled
    public String status;
    @AuraEnabled
    public String details;
  }
    
  public class HumanAPIErrorWrapper{
    public Integer statusCode;   
    public String error;     
    public String message;    
   }

  @AuraEnabled
  public static Map<String,String> getSources(String accessToken) {
    Map<String, String> sourceToSourceName = new Map<String, String>();
    Http h = new HTTP();
    HTTPRequest req = new HTTPRequest();
    req.setEndpoint('callout:HumanAPI_Sources');
    req.setHeader('Authorization', 'Bearer ' +accessToken);
    req.setHeader('Content-Type', 'application/json;charset=UTF-8');
    req.setMethod('GET');
    HTTPResponse resp = h.send(req);
    System.debug('###### resp ' +resp);
    System.debug('###### resp ' +resp.getBody());
    if(resp.getStatusCode() == 200){
      List<SourceDetails> deserializedSourceList = (List<SourceDetails>) JSON.deserialize(
        resp.getBody(),
        List<SourceDetails>.class
      );
      for (SourceDetails s: deserializedSourceList){
        if(s.syncStatus.status == 'ok'){
          sourceToSourceName.put(s.source, s.sourceName);
        }
      }
    }

    return sourceToSourceName;
  }

  public class ReportListWrapper{
    @AuraEnabled
    public String accessToken;
    @AuraEnabled
    public List<ReportListWrapperWithURL> reportList;
  }

  @AuraEnabled
  public static ReportListWrapper getReportList(String humanId){
    try { 
      String clientId;
      String clientSecret;
      List<App_Credential__mdt> appCreds = [
        SELECT Id,Client_Id__c, Client_Secret__c,DeveloperName, Label
        FROM App_Credential__mdt
        WHERE DeveloperName = 'Human_API_Creds'
      ];

      if (appCreds.size() > 0) {
        clientId = appCreds[0].Client_Id__c;
        clientSecret = appCreds[0].Client_Secret__c;
      }

      String reportUrl;
      List<NamedCredential> reportUrlList = [
        SELECT DeveloperName, Endpoint
        FROM NamedCredential
        WHERE DeveloperName = 'HumanAPI_ReportList'
      ];
      if(reportUrlList.size()> 0){
        reportUrl = reportUrlList[0].Endpoint +'/';
      }

      ReportListWrapper wrap = new ReportListWrapper();
      String accessToken = generateAccessToken(clientId, clientSecret, humanId);
      if (accessToken != null) {
        wrap.accessToken = accessToken;
        wrap.reportList = getListOfReports(accessToken, reportUrl);
      }

      System.debug('##### wrap: ' + wrap);
       
      return wrap;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static String requestMedicalRecords(
    Id peId,
    Id ParticipantId 
  ) {
    DateTime dt = DateTime.now();
    String strMessage = '';
    Map<String, String> COUNTRY_CODE_BY_NAME_MAP_Mdt = new Map<String, String>(); 
      
      Participant_Enrollment__c objPER = [SELECT ID,Name,Human_Id__c,Participant__c,Participant__r.Full_Name__c,Participant__r.First_Name__c
                                         ,Participant__r.Last_Name__c,Participant__r.Email__c,Study_Site__r.Name,Participant__r.Country__c,Participant__r.Adult__c
                                         ,Clinical_Trial_Profile__r.Study_Code_Name__c,Unique_HumanId__c,Clinical_Trial_Profile__r.Protocol_ID__c
                                          ,PI_Contact__c,PI_Contact__r.language__c ,PI_Contact__r.Salutation , Permit_Mail_Email_contact_for_this_study__c
                                          ,Study_Site__r.Principal_Investigator__r.Name
                                          from Participant_Enrollment__c Where ID=:peId];
      String email = objPER.Participant__r.Email__c;
      Boolean isAdult = objPER.Participant__r.Adult__c;
      String humanId = objPER.Human_Id__c;
      String uniqueId = objPER.Unique_HumanId__c;
      
      List<RH_Country_Name__mdt> countryMetaLst = [SELECT id,Country_Code__c,Country_Name__c,IsVisible__c FROM RH_Country_Name__mdt];
      for(RH_Country_Name__mdt meta: countryMetaLst){
            if(meta.IsVisible__c == true){
                COUNTRY_CODE_BY_NAME_MAP_Mdt.put(meta.Country_Name__c,meta.Country_Code__c); 
            }
        }  
      Participant__c objParticipantDelegate;

      if(!objPER.Permit_Mail_Email_contact_for_this_study__c){
        return 'NoPermitEmail';
    }
    	 
      if(String.isBlank(email) || isAdult == false){
         List<Patient_Delegate_Enrollment__c> lstPatientDelegate = [SELECT ID,Patient_Delegate__c,Patient_Delegate__r.Participant_Delegate__c 
                                                        FROM Patient_Delegate_Enrollment__c 
                                                        WHERE 
                                                        Participant_Enrollment__c =: peId
                                                        AND
                                                        Patient_Delegate__r.Participant__c =:ParticipantId 
                                                        AND 
                                                        Primary_Delegate__c = True LIMIT 1];
          if(!lstPatientDelegate.isEmpty())
          {
               objParticipantDelegate = [SELECT ID,Email__c,First_Name__c,Last_Name__c FROM Participant__c Where 
                                               id=:lstPatientDelegate[0].Patient_Delegate__r.Participant_Delegate__c];
              if(String.isBlank(objParticipantDelegate.Email__c))
              {
                  return 'EmailError';
              }
              else{
                email = objParticipantDelegate.Email__c;
              }
              
          }
          else{
              return 'EmailError' ;
          }
      }
      String strPILanguage = objPER.PI_Contact__r.language__c;
      if(strPILanguage.length() > 2)
          strPILanguage = strPILanguage.substring(0, 2);
      List<RH_MulesoftWrapper> lstMulesoftWrapper = new List<RH_MulesoftWrapper> ();
      RH_MulesoftWrapper objWrapper = new RH_MulesoftWrapper();
      objWrapper.salesforce_Id = objPER.Id;
      objWrapper.enrollmentName = objPER.Name;
      objWrapper.participantFullName = objPER.Participant__r.Full_Name__c;
      objWrapper.participantFirstName = objPER.Participant__r.First_Name__c;
      objWrapper.participantLastName = objPER.Participant__r.Last_Name__c;
      objWrapper.participantEmail = objPER.Participant__r.Email__c;
      objWrapper.studySiteName = objPER.Study_Site__r.Name;
      objWrapper.studyCodeName = objPER.Clinical_Trial_Profile__r.Study_Code_Name__c;
      objWrapper.uniqueHumanId = objPER.Unique_HumanId__c;
      objWrapper.primaryDelegateEmail = objParticipantDelegate != Null ? objParticipantDelegate.Email__c : '';
      objWrapper.primaryDelegateFirstName = objParticipantDelegate != Null ? objParticipantDelegate.First_Name__c : '' ;
      objWrapper.primaryDelegateLastName = objParticipantDelegate != Null ? objParticipantDelegate.Last_Name__c : '' ; 
      objWrapper.language = strPILanguage;
      objWrapper.country = COUNTRY_CODE_BY_NAME_MAP_Mdt.containskey(objPER.Participant__r.Country__c) ? COUNTRY_CODE_BY_NAME_MAP_Mdt.get(objPER.Participant__r.Country__c) : objPER.Participant__r.Country__c;
      objWrapper.pIname = objPER.Study_Site__r.Principal_Investigator__r.Name;
      objWrapper.protocolId = objPER.Clinical_Trial_Profile__r.Protocol_ID__c;
      objWrapper.salutation = objPER.PI_Contact__r.Salutation;
      
      
    if (humanId == null) {
      String clientId;
      String clientSecret;
      List<App_Credential__mdt> appCreds = [
        SELECT Id, Client_Id__c, Client_Secret__c, DeveloperName, Label
        FROM App_Credential__mdt
        WHERE DeveloperName = 'Human_API_Creds'
      ];
      if (appCreds.size() > 0) {
        clientId = appCreds[0].Client_Id__c;
        clientSecret = appCreds[0].Client_Secret__c;

        RequestWrapperTokenRegister reqWrap = new RequestWrapperTokenRegister();
        reqWrap.client_id = clientId;
        reqWrap.client_secret = clientSecret;
        reqWrap.client_user_id = uniqueId;
        reqWrap.client_user_email = email;
        reqWrap.type = 'session';

        String requestBody = JSON.serialize(reqWrap);
        IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
          objIntegrationLog.Request_Body__c = requestBody;
          objIntegrationLog.Request_Time__c  = dt;
          objIntegrationLog.Request_Type__c = 'SiteMediaRequest_HumanAPICallout_GenerateHumanId';
          objIntegrationLog.Function_Name__c = 'HumanAPIcontroller_requestMedicalRecords';
          objIntegrationLog.Http_Method__c = 'POST';

        Http h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint('callout:HumanAPI_Connect');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setMethod('POST');
        req.setbody(requestBody);
        HTTPResponse resp = h.send(req);
        objIntegrationLog.Response_Body__c = resp.getBody();
        objIntegrationLog.Response_Status__c = resp.getStatus();
        objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();
          
        if (resp.getStatusCode() == 200) {
          ResponseWrapperTokenRegister deserializedResponseWrapperToken = (ResponseWrapperTokenRegister) JSON.deserialize(
            resp.getBody(),
            ResponseWrapperTokenRegister.class
          );
          humanId = deserializedResponseWrapperToken.human_id;
          objIntegrationLog.Success__c = true;
          Participant_Enrollment__c p = new Participant_Enrollment__c(
            Id = peId,
            Human_Id__c = humanId,
            RequestedMedicalRecords__c = dt
          );
           objWrapper.humanId = humanId;
            lstMulesoftWrapper.add(objWrapper);
        	String strHuman_RH_Data = JSON.serialize(lstMulesoftWrapper);
          system.debug('>strHuman_RH_Data>>'+strHuman_RH_Data);
            sendDataToMule(strHuman_RH_Data);
          update p;
          //call mulesoft api to inform SFMC
          strMessage = 'true';
        }
          else{
               HumanAPIErrorWrapper deserializedResponseWrapperToken = (HumanAPIErrorWrapper) JSON.deserialize(
                                    resp.getBody(),HumanAPIErrorWrapper.class);
              objIntegrationLog.Error_Message__c = deserializedResponseWrapperToken.message;
              objIntegrationLog.Success__c = false;
              if(deserializedResponseWrapperToken.message.containsIgnoreCase('must be a valid email')){
                  strMessage = 'EmailNotCorrect';
              }
              else{
                  strMessage = 'APIError';
              } 
          }
         insert objIntegrationLog;
          
      }
    } else {
      Participant_Enrollment__c p = new Participant_Enrollment__c(
        Id = peId,
        RequestedMedicalRecords__c = dt
      );
      strMessage = 'true';
        objWrapper.humanId = objPER.Human_Id__c;
        lstMulesoftWrapper.add(objWrapper);
        String strHuman_RH_Data = JSON.serialize(lstMulesoftWrapper);
        system.debug('>strHuman_RH_Data>>'+strHuman_RH_Data);
        sendDataToMule(strHuman_RH_Data);
      update p;
      //call mulesoft api to inform SFMC
    }
    return strMessage;
  }
    
    public static void sendDataToMule(String strHumanRhData)
    {        
       
        HTTP h = new HTTP();
        HTTPRequest r = new HTTPRequest();
        r.setEndpoint('callout:HumanAPI_MulesoftCnct');
        r.setHeader('Content-Type', 'application/json;charset=UTF-8');
        r.setMethod('POST');
        r.setbody(strHumanRhData);
        r.setTimeout(120000);
        HTTPResponse resp = h.send(r);
        //lOGGED THE Details in Integration Log Object
        IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
        objIntegrationLog.Request_Body__c = strHumanRhData;
         objIntegrationLog.Request_Time__c  = Datetime.now();
        objIntegrationLog.Response_Body__c = resp.getBody();
        objIntegrationLog.Response_Status__c = resp.getStatus();
        objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();
        objIntegrationLog.Request_Type__c = 'SiteMediaRequest_RHtoMulesoft';
        objIntegrationLog.Function_Name__c = 'HumanAPIcontroller_sendDataToMule';
        objIntegrationLog.Success__c = resp.getStatusCode() == 200 ? True : false;
        objIntegrationLog.Http_Method__c = 'POST';
         
        insert objIntegrationLog;
        
    }

  @AuraEnabled
  public static List<Participant_Enrollment__History> getRequestHistory(
    Id peId
  ) {
    List<Participant_Enrollment__History> historyList = [
      SELECT
        NewValue,
        OldValue,
        ParentId
      FROM Participant_Enrollment__History
      WHERE Field = 'RequestedMedicalRecords__c' AND ParentId = :peId
      ORDER BY NewValue DESC NULLS FIRST
    ];
    return historyList;
  }
}