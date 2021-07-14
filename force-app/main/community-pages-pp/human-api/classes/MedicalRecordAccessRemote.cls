public class MedicalRecordAccessRemote {
    
    public static String clientId='72cd1f1f7b36cc80e104efd2a9332e74372fcb24';
    public static  String clientUserId='SK_Sandeep'; //referral Id
    public static String clientUserEmail='sandeepsfdc527@gmail.com';//patient email
    public static String clientSecret='8338fd6645b6b430fe186729a1a873e7cd57a839';
    
    @AuraEnabled
    public static String getSessionToken(){        
        String type='id';
        String url='https://auth.humanapi.co/v1/connect/token';
        JSONGenerator gen = JSON.createGenerator(true);    
        gen.writeStartObject();      
        gen.writeStringField('client_id',clientId );
        gen.writeStringField('client_user_id',clientUserId);
        gen.writeStringField('client_user_email',clientUserEmail);
        gen.writeStringField('client_secret',clientSecret);
        gen.writeStringField('type',type);
        gen.writeEndObject();    
        String jsonReqBody = gen.getAsString();
        Map<String,Object> deserializedResponse=httpCallout(url,jsonReqBody,'POST');
        return (String)deserializedResponse.get('id_token');
    }
    
    @AuraEnabled
    public static String getAccessToken(){
        String type ='access';
        String url='https://auth.humanapi.co/v1/connect/token';
        JSONGenerator gen = JSON.createGenerator(true);    
        gen.writeStartObject();      
        gen.writeStringField('client_id',clientId );
        gen.writeStringField('client_user_id',clientUserId);
        gen.writeStringField('client_user_email',clientUserEmail);
        gen.writeStringField('client_secret',clientSecret);
        gen.writeStringField('type',type);
        gen.writeEndObject();    
        String jsonBody = gen.getAsString();        
        Map<String,Object> deserializedResponse=httpCallout(url,jsonBody,'POST');
        return (String)deserializedResponse.get('access_token');
        
        
    }
    
    
    @AuraEnabled
    public static List<Provider> getHumanSourcesList(String accessToken){
        String url='https://api.humanapi.co/v1/human/sources';
        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        HttpResponse resp = new HttpResponse();        
        req.setMethod('GET');
        req.setHeader('Content-Type', 'Application/JSON ');   
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setEndpoint(url);
        resp = h.send(req);
        System.debug('#### Response Status '+resp.getStatus());
        System.debug('#### Response Status Code '+resp.getStatusCOde());  
        System.debug(resp.getBody());
        List<Object> objslist = (List<Object>)Json.deserializeUntyped(resp.getBody());      
        List<Provider> providersList=new List<Provider>();
        for(Object obj : objslist)
        {
            Map<String,Object> mp_StrObj = (Map<string,Object>)obj;
            
            system.debug(mp_StrObj.get('sourceName')+'::::connectedSince==='+mp_StrObj.get('connectedSince'));
            Map<String,Object> objMap=(Map<String,Object>)mp_StrObj.get('syncStatus');
            System.debug('status'+objMap.get('status'));
            
            Provider providerObj=new Provider();
            providerObj.providerName =(String)mp_StrObj.get('sourceName');
            providerObj.status = (String)objMap.get('status');
            providersList.add(providerObj);
        }
        System.debug('providersList::'+providersList);
        return providersList;
        
        
    }
    
    
    public static Map<String,Object> httpCallout(String url,String jsonRequestbody,String httpMethod)
    {
        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        HttpResponse resp = new HttpResponse();        
        req.setMethod('POST');
        req.setHeader('Content-Type', 'Application/JSON ');        
        req.setbody(jsonRequestbody);
        req.setEndpoint(url);
        resp = h.send(req);
        System.debug('#### Response Status '+resp.getStatus());
        System.debug('#### Response Status Code '+resp.getStatusCOde());       
        Map<String,Object> deserializedResponse=(Map<String,Object>)JSON.deserializeUntyped(
            resp.getBody());
        return deserializedResponse;
    }
    
      @AuraEnabled
    public static Blob downloadReportbyId(String id,String accessToken,String format)
    {
        String url='https://api.humanapi.co/v1/human/medical/reports/'+id+'/raw?format='+format;
        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        HttpResponse resp = new HttpResponse();        
        req.setMethod('GET');
        req.setHeader('Content-Type', 'Application/JSON ');   
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setEndpoint(url);
        resp = h.send(req);
        System.debug('#### Response Status '+resp.getStatus());
        System.debug('#### Response Status Code '+resp.getStatusCOde());  
        System.debug(resp.getBodyAsBlob());
        System.debug('sss'+EncodingUtil.Base64Encode(resp.getBodyAsBlob()));
        return resp.getBodyAsBlob();
    }
    
    
    @AuraEnabled
    public static String downloadBlob()
    {
        String accesst=ApiCallLightningComponent.getAccessToken();
        return EncodingUtil.Base64Encode(ApiCallLightningComponent.downloadReportbyId('60d43bf25d8598001107e1b3-000003-55a83bdc8d1eb1420aa1a71b',accesst,'pdf'));
    } 
    
    public  class Provider
    {
        
        @AuraEnabled
        public String providerName;
        
        @AuraEnabled
        public String status;
    } 
    
}
