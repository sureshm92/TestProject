/**
 * purpose : to integrate with econsent system for various operations
 * Initial Release : 10th May 2023
 * */

public class CreateConsentIntegration {
    
  public static final String E_CONSENT_END_POINT = '';
  public static final String E_CONSENT_SUCCESS = 'Participant is successfully sent to eConsent';
  public static final String E_CONSENT_DUPLICATE_ERROR = 'Participant already exists in eConsent';
  public static final String E_CONSENT_TECHNICAL_EROROR = 'A technical error has ocurred, please try again later'; 
  public static final String USER_NOT_FOUND_ECONSENT = 'User not found in e-consent system, please contact your support team';   
  
       
     /***
     * Method name : documentCollectionResponse
     * Use: use to fetch documentcollections for specific site and study from econsent
     * Params-
     * studyId : study id for which document collections are required
     * siteId : site id for which document collections are required 
     * access_token : authentication token received from mulesoft
     * */
    public static List<DocumentCollection> documentCollectionResponse(String studyId, String siteId,String access_token) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:E_consent_document_collection'+'?studyId='+studyId+'&siteId='+siteId);
        request.setMethod('GET');
        request.setTimeout(120000);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Authorization', 'Bearer '+access_token);
        request.setHeader('Source', 'RH');
        request.setHeader('tid',MulesoftIntegrationApi.uniqueKeygeneration());
        //tid to be sent in header
        system.debug('document collection request:'+request);
        List<DocumentCollection> documentcollections;
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            system.debug('response body:'+response.getBody());
            List<DocumentCollection> deserializedResponseWrapper = (List<DocumentCollection>) JSON.deserialize(response.getBody(), List<DocumentCollection>.class);
            if (deserializedResponseWrapper != null ) {
                documentcollections = deserializedResponseWrapper;
                String documentCollectionId = documentcollections[0].id;
                String documentCollectionTitle = documentcollections[0].title;
                System.debug('Document Collection Id: '+documentCollectionId);
                System.debug('Document Collection Title: '+documentCollectionTitle);
                return documentcollections;
                
            }
        } else {
            String errorMsg = 'HTTP ' + response.getStatusCode() + ' ' + response.getStatus() + ': ' + response.getBody();
            system.debug('Error : '+errorMsg);
        }
        return documentcollections;
    }

    public class DocumentCollection{
        public String id;
        public String title;
        public String name;
    }

  public class RequestWrapper{
    @AuraEnabled
    public String studyId;
    @AuraEnabled
    public String siteId;
    @AuraEnabled
    public String documentCollectionId;
    @AuraEnabled
    public String email;
    @AuraEnabled
    public String subjectId;
    @AuraEnabled
    public String externalId;
    @AuraEnabled
    public String externalKey;
  }    
    public Class ResponseWrapper{
        @AuraEnabled
        public String statusCode;
        @AuraEnabled
        public String statusMessage;
        @AuraEnabled
        public String studyId;
        @AuraEnabled
        public String siteId;
        @AuraEnabled
        public String documentCollectionId;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String externalKey;
        @AuraEnabled
        public String externalId;
        @AuraEnabled
        public String participantId;
        @AuraEnabled
        public String consentingId;
        @AuraEnabled
        public String subjectId;
        @AuraEnabled
        public String errorType;
        @AuraEnabled
        public String eConsentErrorCode;
        @AuraEnabled
        public String eConsentErrorMessage; 
        @AuraEnabled
        public String message;
        
    }
    
    public Class statusInfo{
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String  errorcode;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public String UI_MESSAGE;
    }
 
    /***
     * Method name : createParticipant
     * Use: use to call consent create participant API
     * Params-
     * enrollmentList : list of enrollments for which create consent to be called
     * accessToken : token received from mulesoft
     * */
    public static Map<String,statusInfo> createParticipant(List<Participant_Enrollment__c> enrollmentList,String accessToken){
      List<ResponseWrapper> response;
      String requestStr = (String)JSON.serialize(createParticipantRequest(enrollmentList));
      Map<String,statusInfo> perVsStatus = new Map<String,statusInfo>();
      system.debug('request structure for create participant:'+requestStr);
      
       //logging  integration details in a logger object
      IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
      objIntegrationLog.Request_Body__c = requestStr;
      objIntegrationLog.Request_Time__c  = system.now();
      objIntegrationLog.Request_Type__c = 'createParticipant';
      objIntegrationLog.Function_Name__c = 'eConsentIntegration_createParticipant';
      objIntegrationLog.Http_Method__c = 'POST'; 
      objIntegrationLog.Endpoint_URL__c = 'callout:E_consent_create_participant';
      
      //http callout preparation 
      Http h = new HTTP();
      HTTPRequest req = new HTTPRequest();
      req.setEndpoint('callout:E_consent_create_participant');
      req.setTimeout(120000);
      req.setHeader('Authorization', 'Bearer ' + accessToken);
      req.setHeader('Content-Type', 'application/json;charset=UTF-8');
      req.setHeader('Accept', 'application/json');
      req.setHeader('Source', 'RH');
      req.setHeader('tid',MulesoftIntegrationApi.uniqueKeygeneration());
      req.setMethod('POST');      
      req.setBody(requestStr);
        
      HTTPResponse resp = h.send(req);
      //handle success status
      if(resp.getStatusCode() == 200){
          Boolean isSuccess = true;
          String errorMessage;
          system.debug('returned response:'+resp.getBody());
          Map<String,ResponseWrapper> refIdVsresponse = new Map<String,ResponseWrapper>();
          response = (List<ResponseWrapper>) JSON.deserialize(
          resp.getBody(),
          List<ResponseWrapper>.class
        );
          
          for(ResponseWrapper wrapper : response){
              // handle if received any failed status in response
              if(wrapper.statusCode != '200' && wrapper.statusMessage == 'Failure'){
                  isSuccess = false;
                  errorMessage = (wrapper.eConsentErrorCode != '' || wrapper.eConsentErrorMessage != '')? 
                      			  wrapper.eConsentErrorCode +':::'+ wrapper.eConsentErrorMessage :
                  				 wrapper.message;
                  statusInfo info = new statusInfo();
                  info.isSuccess =  false;
                  info.errorCode = wrapper.eConsentErrorCode;
                  info.errorMessage = wrapper.eConsentErrorMessage;
                  //duplicate consent 
                  if(wrapper.eConsentErrorCode == '40029' || wrapper.eConsentErrorCode == '40014'){
                      info.UI_MESSAGE = E_CONSENT_DUPLICATE_ERROR;
                      refIdVsresponse.put(wrapper.subjectId,wrapper);
                  }
                  else if(wrapper.eConsentErrorCode == '40017'){
                      info.UI_MESSAGE = USER_NOT_FOUND_ECONSENT;
                  }
                  //other technical error from eConsent
                  else{
                     info.UI_MESSAGE = E_CONSENT_TECHNICAL_EROROR; 
                  }
                  
                  perVsStatus.put(wrapper.subjectId,info);
              }
              else{
                  statusInfo info = new statusInfo();
                  info.isSuccess =  true;
                  info.UI_MESSAGE = E_CONSENT_SUCCESS;
                  perVsStatus.put(wrapper.subjectId,info);
                  refIdVsresponse.put(wrapper.subjectId,wrapper);
              }
              
          }
          if(!refIdVsresponse.keySet().isEmpty()){
             updateparticipantEnrollments(enrollmentList,refIdVsresponse); 
          }
          objIntegrationLog.Success__c = isSuccess;
          objIntegrationLog.Error_Message__c = errorMessage;
          objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();
          objIntegrationLog.Response_Body__c = resp.getBody();
          objIntegrationLog.Response_Status__c = resp.getStatus();
          objIntegrationLog.Response_Time__c = system.now();
      }
         else {
           //handling if any status apart from 200 is received  
           objIntegrationLog.Success__c = false;
           objIntegrationLog.Error_Message__c = resp.getStatus();
           objIntegrationLog.Response_Status_Code__c =resp.getStatusCode();
           objIntegrationLog.Response_Body__c = resp.getBody();
           objIntegrationLog.Response_Status__c = resp.getStatus();
           objIntegrationLog.Response_Time__c = system.now();
           String errorMsg = 'HTTP ' + resp.getStatusCode() + ' ' + resp.getStatus() + ': ' + resp.getBody();
           system.debug('Error : '+errorMsg);
		   
           statusInfo info = new statusInfo();
           info.isSuccess =  false;
           info.errorCode = String.valueOf(resp.getStatusCode());
           info.errorMessage = errorMsg;
           info.UI_MESSAGE = E_CONSENT_TECHNICAL_EROROR;
           perVsStatus.put('StatusFailed',info);
        }
        insert objIntegrationLog;
        return perVsStatus;
    }

     /***
     * Method name : updateparticipantEnrollments
     * Use: use to update participant enrollments after econsent success response
     * Params-
     * enrollmentList : list of enrollments for which create consent to be called
     * responseMap : refId vs response(response for participant received in createconsent) map
     * */
    public static void updateparticipantEnrollments(List<Participant_Enrollment__c> enrollmentList,Map<String,ResponseWrapper> responseMap){ //,Map<Id,LabelValueItem> documentCollection
        List<Participant_Enrollment__c> enrollmentToUpdate = new List<Participant_Enrollment__c>();
        for(Participant_Enrollment__c enrollment : enrollmentList){
            if(responseMap.containsKey(enrollment.Name) && responseMap.get(enrollment.name).participantId != null){
                enrollment.ParticipantGUID__c = responseMap.get(enrollment.name).participantId;
                enrollment.SenttoCompleteConsent__c = system.now();
                enrollment.Participantavailableincompleteconsen__c = true;   
                enrollmentToUpdate.add(enrollment);
            } 
        }
        if(!enrollmentToUpdate.isEmpty()){
      		bypassParticipantEnrollmentTrigger();      
            update enrollmentToUpdate;
        }
        
    } 
    
    public static void bypassParticipantEnrollmentTrigger(){
        
        TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class);
        TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.SendEmailIfSSWasChanged.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.createNotifications.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class);
        TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.CreateNotificationHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SendFOVtoAPI.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.UnenrollorCancelPer.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.UpdateParticipantInitialVisit.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateMissingStatuses.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.EcoaEvents.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.DefaultEcoaTask.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.UpdatePatientConsent.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.StudyConsentTimestamps.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.UpdateInitialVisits.class);
        
      
    }
    
     /***
     * Method name : createParticipantRequest
     * Use: use to generate request for createconsent API
     * Params-
     * enrollList : list of enrollments for which create consent to be called
     * */
    public static List<RequestWrapper> createParticipantRequest(List<Participant_Enrollment__c> enrollList){ //,Map<Id,LabelValueItem> docCollection
        
        List<RequestWrapper> requests = new List<RequestWrapper>();
        for(Participant_Enrollment__c enrollment : enrollList){
            RequestWrapper request = new RequestWrapper();
            request.studyId = enrollment.Clinical_Trial_Profile__r.StudyGUID__c;
            request.siteId = enrollment.Study_Site__r.SiteGuid__c;
            //request.documentCollectionID = (enrollment.DocumentCollectionId__c != null) ? enrollment.DocumentCollectionId__c :docCollection.get(enrollment.id).value ;
            request.documentCollectionID = enrollment.DocumentCollectionId__c;
            request.email = userInfo.getUserEmail();  //'jasika.kaur@iqvia.com'
            request.subjectId = enrollment.name;
            request.externalId = enrollment.name;
            request.externalKey = 'ReferralHub';
            requests.add(request);
        }
        return requests;
    }
    
}