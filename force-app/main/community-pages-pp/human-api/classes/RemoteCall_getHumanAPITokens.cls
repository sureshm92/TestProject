public class RemoteCall_getHumanAPITokens{
    
    
    public static String clientId='72cd1f1f7b36cc80e104efd2a9332e74372fcb24';
    public static  String clientUserId='SK_Sandeep'; //referral Id
    public static String clientUserEmail='sandeepsfdc527@gmail.com';//patient email
    public static String clientSecret='8338fd6645b6b430fe186729a1a873e7cd57a839';

  

    public SessionTokenInfo remoteCallGetSessionToken()
    {
        String url='HumanAPI_Connect';
        Map<String, String> headerMap = new Map<String, String>{ 'Content-Type' => 'application/json' };
        Map<String, String> requestMap = new Map<String, String>{ 'client_id' => clientId, 'client_user_id' => clientUserId ,'client_user_email' => clientUserEmail,'client_secret' => clientSecret, 'type' => 'id'};
        HttpCallout remoteCall = new HttpCallout(url,'POST',headerMap,requestMap,MedicalRecordAccessRemote.class);
        SessionTokenInfo sessionTokenInfo = parseSessionResponse((String)remoteCall.execute());
        return SessionTokenInfo;
        
    }

    public AccessTokenInfo remoteCallGetAccessToken()
    {
        String url='HumanAPI_Connect';
        Map<String, String> headerMap = new Map<String, String>{ 'Content-Type' => 'application/json' };
        Map<String, String> requestMap = new Map<String, String>{ 'client_id' => clientId, 'client_user_id' => clientUserId ,'client_user_email' => clientUserEmail,'client_secret' => clientSecret, 'type' => 'access'};
        HttpCallout remoteCall = new HttpCallout(url,'POST',headerMap,requestMap,MedicalRecordAccessRemote.class);
        AccessTokenInfo accessTokenInfo = parseAccessResponse((String)remoteCall.execute());
        return accessTokenInfo;
        
    }    
   
    public SessionTokenInfo parseSessionResponse(String responseBody) {
        SessionTokenInfo sessionToken =(SessionTokenInfo) JSON.deserialize(responseBody, SessionTokenInfo.class);
       return sessionToken;
    }

    public AccessTokenInfo parseAccessResponse(String responseBody) {
        AccessTokenInfo accessToken =(AccessTokenInfo) JSON.deserialize(responseBody, AccessTokenInfo.class);
       return accessToken;
    }

    public class SessionTokenInfo
    {
        @AuraEnabled
        public String token_type;

        @AuraEnabled
        public String id_token;

        @AuraEnabled
        public String id_refresh_token;

        @AuraEnabled
        public String id_token_expires_in;

    }

    public class AccessTokenInfo
    {
        @AuraEnabled
        public String token_type;

        @AuraEnabled
        public String access_token;

        @AuraEnabled
        public String refresh_token;

        @AuraEnabled
        public String expires_in;

    }




}
