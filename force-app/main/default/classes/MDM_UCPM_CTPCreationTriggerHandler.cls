public with sharing class MDM_UCPM_CTPCreationTriggerHandler {
  // ---------------------------------------------Handlers----------------------------------------------------------
  public class CreateStudySponser extends TriggerHandler {
    public override void afterInsert(List<SObject> newList) {
      List<Clinical_Trial_Profile__c> ctpList = newList;
      List<Clinical_Trial_Profile__c> eligibleCTPforUCPM = new List<Clinical_Trial_Profile__c>();
      for (Clinical_Trial_Profile__c ctp : ctpList) {
        if (
          ctp.MDM_trigger_status__c == null &&
          ctp.UCPM_Sponsor_Org_Id__c == null &&
          ctp.UCPM_Study_Purpose_Id__c == null &&
          ctp.MDM_Parent_Sponsor_Name__c != null &&
          ctp.MDM_Parent_Sponsor_Entity_Id__c != null &&
          ctp.MDM_Protocol_Entity_Id__c != null &&
          ctp.Protocol_ID__c != null &&
          (ctp.Recruitment_Status__c == 'Enrolling' ||
          ctp.Recruitment_Status__c == 'In Development' ||
          ctp.Recruitment_Status__c == 'Open to Enrollment' ||
          ctp.Recruitment_Status__c == 'On Hold' ||
          ctp.Recruitment_Status__c == 'Enrollment Closed' ||
          ctp.Recruitment_Status__c == 'Planning')
        ) {
          eligibleCTPforUCPM.add(ctp);
        }
      }
      if (!eligibleCTPforUCPM.isEmpty()) {
        createCreateStudySponser(eligibleCTPforUCPM);
      }
    }

    public override void afterUpdate(
      List<SObject> newList,
      Map<Id, SObject> oldMap
    ) {
      List<Clinical_Trial_Profile__c> ctpnewList = newList;
      // Map<Id,Clinical_Trial_Profile__c> ctpoldMap = (Map<Id,Clinical_Trial_Profile__c>)oldMap;

      List<Clinical_Trial_Profile__c> eligibleCTPforUCPM = new List<Clinical_Trial_Profile__c>();
      for (Clinical_Trial_Profile__c ctp : ctpnewList) {
        if (
          (ctp.MDM_trigger_status__c == null &&
          ctp.UCPM_Sponsor_Org_Id__c == null &&
          ctp.UCPM_Study_Purpose_Id__c == null &&
          ctp.MDM_Parent_Sponsor_Name__c != null &&
          ctp.MDM_Parent_Sponsor_Entity_Id__c != null &&
          ctp.MDM_Protocol_Entity_Id__c != null &&
          ctp.Protocol_ID__c != null &&
          (ctp.Recruitment_Status__c == 'Enrolling' ||
          ctp.Recruitment_Status__c == 'In Development' ||
          ctp.Recruitment_Status__c == 'Open to Enrollment' ||
          ctp.Recruitment_Status__c == 'On Hold' ||
          ctp.Recruitment_Status__c == 'Enrollment Closed' ||
          ctp.Recruitment_Status__c == 'Planning'))
        ) {
          eligibleCTPforUCPM.add(ctp);
        }
      }
      //   System.debug('####eligibleCTPforUCPM: ' + eligibleCTPforUCPM);
      if (!eligibleCTPforUCPM.isEmpty()) {
        createCreateStudySponser(eligibleCTPforUCPM);
      }
    }
  }

  // ---------------------------------------------Logic----------------------------------------------------------
  private static void createCreateStudySponser(
    List<Clinical_Trial_Profile__c> eligibleCTPforUCPM
  ) {
    List<Clinical_Trial_Profile__c> ctpUpdateListUCPM = new List<Clinical_Trial_Profile__c>();
    Map<String, List<Clinical_Trial_Profile__c>> sponserToStudyMap = new Map<String, List<Clinical_Trial_Profile__c>>();
    for (Clinical_Trial_Profile__c ctp : eligibleCTPforUCPM) {
      List<Clinical_Trial_Profile__c> studyList = new List<Clinical_Trial_Profile__c>();
      if (sponserToStudyMap.containsKey(ctp.MDM_Parent_Sponsor_Entity_Id__c)) {
        sponserToStudyMap.get(ctp.MDM_Parent_Sponsor_Entity_Id__c).add(ctp);
      } else {
        sponserToStudyMap.put(
          ctp.MDM_Parent_Sponsor_Entity_Id__c,
          new List<Clinical_Trial_Profile__c>{ ctp }
        );
      }
    }
    //Data prep for API callout

    String requestString;

    List<Id> ctpId = new List<Id>();
    JSONGenerator gen = JSON.createGenerator(false);
    gen.writeStartArray();
    for (String key : sponserToStudyMap.keySet()) {
      String name = sponserToStudyMap.get(key)[0].MDM_Parent_Sponsor_Name__c;
      String externalId = sponserToStudyMap.get(key)[0]
        .MDM_Parent_Sponsor_Entity_Id__c;

      gen.writeStartObject();
      gen.writeFieldName('Org');

      gen.writeStartObject();
      gen.writeStringField('externalId', externalId);
      gen.writeStringField('name', name);
      gen.writeStringField('description', name);
      gen.writeEndObject();

      gen.writeFieldName('ProcessingPurpose');
      gen.writeStartArray();
      for (Clinical_Trial_Profile__c ctpList : sponserToStudyMap.get(key)) {
        ctpId.add(ctpList.Id);
        gen.writeStartObject();
        gen.writeStringField('name', ctpList.MDM_Protocol_Entity_Id__c);
        gen.writeStringField('description', ctpList.Protocol_ID__c);
        gen.writeFieldName('organizations');
        gen.writeStartArray();
        gen.writeString(externalId);
        gen.writeEndArray();
        gen.writeStringField('applicationId', ctpList.Id);
        gen.writeEndObject();
      }

      gen.writeEndArray();
      gen.writeEndObject();
    }

    gen.writeEndArray();
    requestString = gen.getAsString();

    System.debug(requestString);
    callUCPMtoCreateStudySponser(requestString, ctpId);
  }

  @future(callout=true)
  public static void callUCPMtoCreateStudySponser(
    String reqString,
    List<Id> ctpId
  ) {
    try {
      //-------------------------------------------generate mulesoft access token------------------------------------
      String accessToken;
      MulesoftToken__c setting = MulesoftToken__c.getInstance(
        'Mulesoft Access Token UCPM'
      );
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
      //Call Mulesoft-UCPM API for study sponser creation
      HTTP h = new HTTP();
      HTTPRequest r = new HTTPRequest();
      r.setEndpoint('callout:UCPM_organization_purpose');
      r.setTimeout(120000);
      r.setHeader('Content-Type', 'application/json;charset=UTF-8');
      r.setMethod('POST');
      r.setHeader('Authorization', 'Bearer ' + accessToken);
      r.setbody(reqString);
      String tid = MulesoftIntegrationApi.uniqueKeygeneration();
      r.setHeader('tid', tid);
      System.debug('tid: ' + tid);
      System.debug('###### request ' + r.getBody());
      HTTPResponse resp = h.send(r);
      System.debug('###### resp ' + resp);

      //Create IntegrationLog__c for monitoring purpose
      IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
      objIntegrationLog.Request_Body__c = reqString;
      objIntegrationLog.Request_Time__c = system.now();
      objIntegrationLog.Request_Type__c = 'Create Organization and Purpose in UCPM';
      objIntegrationLog.Function_Name__c = 'UCPM_ORG_PP_creation';
      objIntegrationLog.Http_Method__c = 'POST';
      objIntegrationLog.Endpoint_URL__c = 'callout:UCPM_organization_purpose';

      //Update CTP with In Progress status
      if (resp.getStatusCode() == 200) {
        objIntegrationLog.Success__c = true;
        objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();
        objIntegrationLog.Response_Body__c = resp.getBody();
        objIntegrationLog.Response_Time__c = system.now();

        List<Clinical_Trial_Profile__c> ctpToUpdate = new List<Clinical_Trial_Profile__c>();
        for (Id c : ctpId) {
          Clinical_Trial_Profile__c ct = new Clinical_Trial_Profile__c();
          ct.Id = c;
          ct.MDM_trigger_status__c = 'In Progress';
          ctpToUpdate.add(ct);
        }
        update ctpToUpdate;
      } else {
        objIntegrationLog.Success__c = false;
        objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();
        objIntegrationLog.Response_Body__c = resp.getBody();
        objIntegrationLog.Response_Time__c = system.now();
      }
      insert objIntegrationLog;
    } catch (Exception e) {
      System.debug('e.getMessage(): ' + e.getMessage());
      System.debug('e.getStackTraceString(): ' + e.getStackTraceString());
    }
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