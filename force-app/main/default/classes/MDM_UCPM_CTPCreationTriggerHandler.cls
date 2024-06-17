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
          ctp.Protocol_ID__c != null
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

      List<Clinical_Trial_Profile__c> eligibleCTPforUCPM = new List<Clinical_Trial_Profile__c>();
      for (Clinical_Trial_Profile__c ctp : ctpnewList) {
        if (
          (ctp.MDM_trigger_status__c == null &&
          ctp.UCPM_Sponsor_Org_Id__c == null &&
          ctp.UCPM_Study_Purpose_Id__c == null &&
          ctp.MDM_Parent_Sponsor_Name__c != null &&
          ctp.MDM_Parent_Sponsor_Entity_Id__c != null &&
          ctp.MDM_Protocol_Entity_Id__c != null &&
          ctp.Protocol_ID__c != null)
        ) {
          eligibleCTPforUCPM.add(ctp);
        }
      }
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
    List<Map<String, List<Clinical_Trial_Profile__c>>> mapChunksList = chunkMap(
      sponserToStudyMap,
      50
    );
    for (
      Map<String, List<Clinical_Trial_Profile__c>> chunkedSponserToStudyMap : mapChunksList
    ) {
      DataPrepWrapper dwrap = new DataPrepWrapper();
      dwrap = createRequestWrapper(chunkedSponserToStudyMap);
      callUCPMtoCreateStudySponser(dwrap.requestString, dwrap.ctpId);
    }
  }

  public static DataPrepWrapper createRequestWrapper(
    Map<String, List<Clinical_Trial_Profile__c>> sponserToStudyMap
  ) {
    //Data prep for API callout
    DataPrepWrapper dwrap = new DataPrepWrapper();
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
    dwrap.requestString = requestString;
    dwrap.ctpId = ctpId;
    return dwrap;
  }

  @future(callout=true)
  public static void callUCPMtoCreateStudySponser(
    String reqString,
    List<Id> ctpId
  ) {
    try {
      //-------------------------------------------generate mulesoft access token------------------------------------
      String accessToken = MulesoftIntegrationApi.getAccessTokenIfValid(
        'Mulesoft Access Token UCPM'
      );
      MulesoftToken__c setting = MulesoftToken__c.getInstance(
        'Mulesoft Access Token UCPM'
      );
      Boolean saveAccessToken = false;
      MulesoftIntegrationApi.ResponseWrapper tokenWrap = new MulesoftIntegrationApi.ResponseWrapper();
      if (accessToken == null) {
        tokenWrap = MulesoftIntegrationApi.generateAccessTokenWithoutSave(
          setting
        );
        accessToken = tokenWrap.access_token;
        saveAccessToken = true;
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
      String sizeString = reqString;
      Integer maxSize = 130000;
      if (sizeString.length() > maxSize) {
        sizeString = sizeString.substring(0, maxSize);
      }
      objIntegrationLog.Request_Body__c = sizeString;
      objIntegrationLog.Request_Time__c = system.now();
      objIntegrationLog.Request_Type__c = 'Create Organization and Purpose in UCPM';
      objIntegrationLog.Function_Name__c = 'UCPM_ORG_PP_creation';
      objIntegrationLog.Http_Method__c = 'POST';
      objIntegrationLog.Endpoint_URL__c = 'callout:UCPM_organization_purpose';

      //Update CTP with In Progress status
      String CTPstatus;
      String messageBody;
      if (resp.getStatusCode() == 200) {
        objIntegrationLog.Success__c = true;
        objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();
        objIntegrationLog.Response_Body__c = resp.getBody();
        objIntegrationLog.Response_Time__c = system.now();
        CTPstatus = 'In Progress';
      } else {
        objIntegrationLog.Success__c = false;
        objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();
        objIntegrationLog.Response_Body__c = resp.getBody();
        objIntegrationLog.Response_Time__c = system.now();
        CTPstatus = 'Failed';
        messageBody = resp.getStatus();
      }

      List<Clinical_Trial_Profile__c> ctpToUpdate = new List<Clinical_Trial_Profile__c>();
      for (Id c : ctpId) {
        Clinical_Trial_Profile__c ct = new Clinical_Trial_Profile__c();
        ct.Id = c;
        ct.MDM_trigger_status__c = CTPstatus;
        ct.UCPM_error_message__c = messageBody;
        ctpToUpdate.add(ct);
      }
      //TODO: need to write all CTP bypass trigger logic
      if (!ctpToUpdate.isEmpty()) {
        update ctpToUpdate;
      }

      insert objIntegrationLog;
      //MulesoftIntegrationApi.saveAccessToken method to save the Access token for future use
      if (saveAccessToken) {
        MulesoftIntegrationApi.saveAccessToken(
          setting,
          tokenWrap.access_token,
          tokenWrap.expires_in
        );
      }
    } catch (Exception e) {
      System.debug('e.getMessage(): ' + e.getMessage());
      System.debug('e.getStackTraceString(): ' + e.getStackTraceString());
    }
  }

  public class DataPrepWrapper {
    public String requestString;
    public List<Id> ctpId;
  }

  //method to chunk a map into n number of maps
  //here chunksize we will pass as 50
  public static List<Map<String, List<Clinical_Trial_Profile__c>>> chunkMap(
    Map<String, List<Clinical_Trial_Profile__c>> originalMap,
    Integer chunkSize
  ) {
    // List to hold the resulting chunks
    List<Map<String, List<Clinical_Trial_Profile__c>>> mapChunks = new List<Map<String, List<Clinical_Trial_Profile__c>>>();
    // Temporary map to hold current chunk
    Map<String, List<Clinical_Trial_Profile__c>> currentChunk = new Map<String, List<Clinical_Trial_Profile__c>>();
    // Counter to keep track of entries added to the current chunk
    Integer counter = 0;
    // Iterate through the original map
    for (String key : originalMap.keySet()) {
      // Add the current entry to the current chunk
      currentChunk.put(key, originalMap.get(key));
      counter++;
      // If the current chunk has reached the specified size, add it to the list of chunks and start a new chunk
      if (counter == chunkSize) {
        mapChunks.add(
          new Map<String, List<Clinical_Trial_Profile__c>>(currentChunk)
        );
        currentChunk.clear();
        counter = 0;
      }
    }
    // If there are any remaining entries in the current chunk, add it to the list of chunks
    if (!currentChunk.isEmpty()) {
      mapChunks.add(
        new Map<String, List<Clinical_Trial_Profile__c>>(currentChunk)
      );
    }
    return mapChunks;
  }
}