public with sharing class UCPM_FetchConsentFromButtonController {
    private static String identityType ='PARTICIPANT';

    //call from record detail page
     @AuraEnabled
    public static String callUCPMtoFetchLatestConsentsFromRecord(
        Id applicationId
    ) {
        TriggerHandlerExecutor.bypassHandler( 
            UCPM_UpdateConsentOptOutHandler.updateConsentPERtoUCPM.class
            );
        TriggerHandlerExecutor.bypassHandler( 
            UCPM_UpdateConsentOptOutHandler.updateConsentContacttoUCPM.class
            );
        TriggerHandlerExecutor.bypassHandler( 
            UCPM_UpdateConsentOptOutHandler.updateConsentPDERtoUCPM.class
            );
        System.debug('Inside callUCPMtoFetchLatestConsentsFromRecord ##: ');
        //get mulesoft access token
        String accessToken;
        accessToken = UCPM_ConsentFetchController.getAccessToken();
        System.debug('accessToken ##: ' + accessToken);

        String ppmId;
        String participantPpmid;
        Schema.SObjectType objTypeSch = applicationId.getsobjecttype();
        String objType = objTypeSch.getDescribe().getName();

        if (objType == 'Participant_Enrollment__c') {
            Participant_Enrollment__c per = [
                SELECT
                    id,
                    PPMID__c,
                    Participant_Contact__r.PPM_ID__c,
                    Clinical_Trial_Profile__r.Study_Sponsor__c,
                    Clinical_Trial_Profile__c,
                    Clinical_Trial_Profile__r.Study_Code_Name__c,
                    Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c
                FROM Participant_Enrollment__c
                WHERE id = :applicationId limit 1
            ];
            
            ppmId = per.PPMID__c;

        }else if (objType == 'Patient_Delegate_Enrollment__c') {
            Patient_Delegate_Enrollment__c pder = [
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
                WHERE Id = :applicationId  limit 1
            ];

            ppmId = pder.PPM_ID__c;
            participantPpmid = pder.Participant_Enrollment__r.PPMID__c;
        
        } else if (objType == 'Contact') {
            Contact con = [
                SELECT Id, PPM_ID__c
                FROM Contact
                WHERE Id = :applicationId limit 1
            ];
            ppmId = con.PPM_ID__c;

        }

        UCPM_ConsentFetchController.UCPMrequestBodyWrapper wrapper = new UCPM_ConsentFetchController.UCPMrequestBodyWrapper();
        wrapper.ppmid = ppmId;
        wrapper.participantPpmid = participantPpmid;
        wrapper.applicationId = applicationId;
        
        //Data prep for API callout
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartArray();
            gen.writeStartObject();
            if (wrapper.ppmid != null) {
                gen.writeStringField('ppmid', wrapper.ppmid);
            } else {
                gen.writeStringField('ppmid', '');
            }
            if (wrapper.participantPpmid != null) {
                gen.writeStringField('participantPPMID', wrapper.participantPpmid);
            } else {
                gen.writeStringField('participantPPMID', '');
            }
             if (wrapper.applicationId != null) {
                gen.writeStringField('applicationId', wrapper.applicationId);
            } else {
                gen.writeStringField('applicationId', '');
            }
           gen.writeEndObject();

        gen.writeEndArray();

        String requestString;
        String responseBody;
        requestString = gen.getAsString();

        DateTime dt = DateTime.now();

        //Integration log generation 
        IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
        objIntegrationLog.Request_Body__c = requestString;
        objIntegrationLog.Request_Time__c = dt;
        objIntegrationLog.Request_Type__c = 'UCPM_Fetch_Consent';
        objIntegrationLog.Function_Name__c = 'UCPM_Fetch_Consent_fromButton';
        objIntegrationLog.Http_Method__c = 'POST';

        //Call Mulesoft-UCPM API for consents
        HTTP h = new HTTP();
        HTTPRequest r = new HTTPRequest();
        r.setEndpoint('callout:UCPM_Fetch_Consent');
        r.setHeader('Content-Type', 'application/json;charset=UTF-8');
        r.setTimeout(120000);
        r.setMethod('POST');
        r.setHeader('Authorization', 'Bearer ' + accessToken);
        r.setbody(requestString);
        r.setHeader('identityType', identityType);
        r.setHeader('transactionId', MulesoftIntegrationApi.uniqueKeygeneration());

         HTTPResponse resp;
        try{
         resp = h.send(r);
        }
        catch(exception e){
            objIntegrationLog.Response_Body__c = e.getMessage();
            objIntegrationLog.Success__c = false;
            return objIntegrationLog.Response_Status__c;   
        }

        objIntegrationLog.Response_Body__c = resp.getBody();
        objIntegrationLog.Response_Status__c = resp.getStatus();
        objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();

        if (resp.getStatusCode() == 200) {
            objIntegrationLog.Success__c = true;
            responseBody = resp.getBody();

            UCPM_ConsentFetchController responseWrapper = (UCPM_ConsentFetchController) JSON.deserialize(
                responseBody,
                UCPM_ConsentFetchController.class
            );

            //call method to return wrapper with list of records to be updated and interation log           
            UCPM_ConsentFetchController.returnValueWrapper retDataWrap = UCPM_ConsentFetchController.updateRecords(responseWrapper, 'RecordPage');
            Sobject sObj = retDataWrap.updatedRecord;
            
            //update record
            if(retDataWrap.isSuccess){
                try{
                    update sObj;
                 } 
                catch(DmlException e) {
                    System.debug('The following exception has occurred while updating the consents: ' + e.getMessage());
                    return objIntegrationLog.Response_Status__c;   
                }
            }

        } 
        else {
            objIntegrationLog.Success__c = false;
        }

        //Create integartion log records
        try{
            insert objIntegrationLog;
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred while creating Itegration log: ' + e.getMessage());
            return objIntegrationLog.Response_Status__c;   
        }  
        return objIntegrationLog.Response_Status__c;      
    }

    
}