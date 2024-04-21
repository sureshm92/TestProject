/**
 * purpose : to integrate with Mulesoft system to get Access token
 * Initial Release : 10th May 2023
 * */
public with sharing class MulesoftIntegrationApi {
    /***
     * Method name : getAccessToken
     * Use: this method provide access token from custom setting else calls API
     * Params-
     * studyId : name of service for which token to be fetched
     * prerequisits-
     * Custom setting record for the mule soft service to be used should be created with named credentials details
     * */
    public static String getAccessToken(String name) {
        MulesoftToken__c setting = MulesoftToken__c.getInstance(name); 
        if(setting !=null){
            //existing token expiration time should be less then current time
            if(setting.Token__c != null && setting.Expiration_Date__c != null && setting.Expiration_Date__c > DateTime.now()){
                return setting.Token__c ;
            }
            else if(setting.Named_Credentials_Name__c !=null){
                return generateAccessToken(setting);
                
            }
            
        }
        return null;
        
    }
    
     /***
     * Method name : generateAccessToken
     * Use: this method call mulesoft to retrieve access token
     * Params-
     * studyId : custom setting record on which token can be updated once retrieved
     * */
    public static String generateAccessToken(MulesoftToken__c setting) {
        String token = setting.Token__c;
        if (setting.Expiration_Date__c != null && setting.Expiration_Date__c > DateTime.now()) {
            // Token has not expired yet
            return token;
        }
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:'+setting.Named_Credentials_Name__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String requestBody = 'grant_type=client_credentials';
        request.setBody(requestBody);
        System.debug('###### request ' +request);
        
        HttpResponse resp = http.send(request);
        System.debug('###### resp ' +resp);
        System.debug('###### resp ' +resp.getBody());
        
        if (resp.getStatusCode() == 200) {
            JsonParser parser = JSON.createParser(resp.getBody());
            ResponseWrapper deserializedResponseWrapper = (ResponseWrapper)JSON.deserialize(resp.getBody(), ResponseWrapper.class);            
            token = deserializedResponseWrapper.access_token;
            setting.Token__c = token;
            setting.Expiration_Date__c = DateTime.now().addSeconds(deserializedResponseWrapper.expires_in);
            
            
            update setting;
        }
        else {
            String errorMsg = 'HTTP ' + resp.getStatusCode() + ' ' + resp.getStatus() + ': ' + resp.getBody();
            system.debug('Error : '+errorMsg);
            IntegrationLog__c objIntegrationLog = new IntegrationLog__c();
            objIntegrationLog.Request_Body__c = requestBody;
            objIntegrationLog.Request_Time__c  = system.now();
            objIntegrationLog.Request_Type__c = 'generate_access_token';
            objIntegrationLog.Function_Name__c = 'MulesoftIntegrationApi_generateAccessToken';
            objIntegrationLog.Http_Method__c = 'POST'; 
            objIntegrationLog.Endpoint_URL__c = 'callout:+setting.Named_Credentials_Name__c';
            objIntegrationLog.Success__c = false;
            objIntegrationLog.Error_Message__c = errorMsg;
            objIntegrationLog.Response_Status_Code__c = resp.getStatusCode();
            objIntegrationLog.Response_Body__c = resp.getBody();
            objIntegrationLog.Response_Status__c = resp.getStatus();
            objIntegrationLog.Response_Time__c = system.now();
            insert objIntegrationLog;
        }
        
        return token;
    }
   
     /***
     * Method name : generateAccessToken
     * Use: this method is used to generate unique key identifier for each API call
     * Params-
     * studyId : name of service for which token to be fetched
     * */
    Public static String uniqueKeygeneration(){
         Blob keyBlob = Crypto.GenerateAESKey(128);
         String keyStr = EncodingUtil.ConvertTohex(keyBlob);
         String guid = keyStr.SubString(0,8)+ '-' + keyStr.SubString(8,12) + '-' + keyStr.SubString(12,16) + '-' + keyStr.SubString(16,20) + '-' + keyStr.substring(20);
         guid = guid.replaceAll('[-: ]','');
         String uniqueId = String.valueof(DateTime.now());
         uniqueId = uniqueId.replaceAll('[-: ]','');
         return (guid+'_'+uniqueId );
    }
    
    
    public class ResponseWrapper{
        public String token_type;
        public String access_token;
        public Integer expires_in;
        public String message;
        public Boolean success;
        public Integer statusCode;
        
    }
}