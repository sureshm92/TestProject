public class RemoteCall_getHumanAPITokens{
    
    
    
    public static String clientId;
    public static String clientUserId; //referral Id
    public static String clientUserEmail;//patient email
    public static String clientSecret;
    
    static
    {
        //clientId='72cd1f1f7b36cc80e104efd2a9332e74372fcb24'
        //clientSecret='8338fd6645b6b430fe186729a1a873e7cd57a839'
         List<App_Credential__mdt> appCreds = [
           Select Id,Client_Id__c, Client_Secret__c,DeveloperName, Label 
           from App_Credential__mdt 
           where DeveloperName = 'Human_API_Creds'
        ];
         if (appCreds.size() > 0)
         {
            clientId = appCreds[0].Client_Id__c;
            clientSecret = appCreds[0].Client_Secret__c;
         }
        
    }
    
    private static RemoteCall_getHumanAPITokens instance;

    public static RemoteCall_getHumanAPITokens getInstance() {
        if (instance == null)
            instance = new RemoteCall_getHumanAPITokens();
        return instance;
    }

    public SessionTokenInfo remoteCallGetSessionToken()
    {
        String url='HumanAPI_Connect';
        Boolean isNewUser = false;
        Map<String, String> requestMap = new Map<String, String>();
        ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
        clientUserEmail = participantState.pe.Participant__r.Email__c;
        clientUserId = participantState.pe.Id;
        if((participantState.pe.Human_Id__c==null) || (participantState.pe.Human_Id__c==''))
        {
            requestMap = new Map<String, String>{ 'client_id' => clientId, 'client_user_id' => participantState.pe.Name ,'client_user_email' => clientUserEmail,'client_secret' => clientSecret, 'type' => 'session'};
            isNewUser = true;
        }
        else
        {
            requestMap = new Map<String, String>{ 'client_id' => clientId, 'client_user_id' => participantState.pe.Name ,'client_user_email' => clientUserEmail,'client_secret' => clientSecret, 'type' => 'id'};
        }
        
        Map<String, String> headerMap = new Map<String, String>{ 'Content-Type' => 'application/json' };
        
        HttpCallout remoteCall = new HttpCallout(url,'POST',headerMap,requestMap,MedicalRecordAccessRemote.class);
        String currentParticipantEnrollmentId = participantState.pe.Id;// determining logged in user's participant enrollment Id
        String sessionToken = TokenService.fetchToken(currentParticipantEnrollmentId,'session');
        SessionTokenInfo sessionTokenInfo = new SessionTokenInfo();
        if(isNewUser == false){
        if(sessionToken != null){
           sessionTokenInfo.id_token = sessionToken;
        }
        else{ 
            system.debug('inside session Token null');
           sessionTokenInfo = parseSessionResponse((String)remoteCall.execute()); //custom object
            if(remoteCall.log.Response_Status_Code__c == 401){
                sessionTokenInfo = parseSessionResponse((String)remoteCall.execute()); //custom object
              system.debug('inside session Token null 401');

            }

        }
        }
        else
        {
            
            NewUserSessionTokenInfo newUserTokenInfo = parseNewUserSessionResponse((String)remoteCall.execute());
            sessionTokenInfo.id_token = newUserTokenInfo.session_token;
            system.debug('sessionTokeninfo for new user');
            /** Participant_Enrollment__c peObj=new Participant_Enrollment__c();
             peObj.id=participantState.pe.Id;
            peObj.Human_Id__c = newUserTokenInfo.human_id;
            update peObj; **/
        }
        return sessionTokenInfo;
        
    }

    public AccessTokenInfo remoteCallGetAccessToken()
    {
        String url='HumanAPI_Connect';
        // ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
      //  clientUserEmail = participantState.pe.Participant__r.Email__c;
        ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
        String currentParticipantEnrollmentId = participantState.pe.Id;
        clientUserEmail = participantState.pe.Participant__r.Email__c;
        Map<String, String> headerMap = new Map<String, String>{ 'Content-Type' => 'application/json' };
        Map<String, String> requestMap = new Map<String, String>{ 'client_id' => clientId, 'client_user_id' => participantState.pe.Name ,'client_user_email' => clientUserEmail,'client_secret' => clientSecret, 'type' => 'access'};
        HttpCallout remoteCall = new HttpCallout(url,'POST',headerMap,requestMap,MedicalRecordAccessRemote.class);
       AccessTokenInfo accessTokenInfo = new AccessTokenInfo();
        String accessToken = TokenService.fetchToken(currentParticipantEnrollmentId,'access');
        
        if(accessToken != null){
            
            accessTokenInfo.access_token = accessToken;
            System.debug('accessToken in ifblock'+accessToken);
        }
        else{ 
            accessTokenInfo = parseAccessResponse((String)remoteCall.execute());
            System.debug('accessTokenInfo:::'+accessTokenInfo);
            if(remoteCall.log.Response_Status_Code__c == 401){
               accessTokenInfo = parseAccessResponse((String)remoteCall.execute());
                System.debug('401::accessTokenInfo'+accessTokenInfo);
            }

          
        } 
        System.debug('before return accessTokenInfo:::'+accessTokenInfo);
        return accessTokenInfo;
        
    }    
   
    public SessionTokenInfo parseSessionResponse(String responseBody) {
       SessionTokenInfo sessionToken =(SessionTokenInfo) JSON.deserialize(responseBody, SessionTokenInfo.class);
       ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
       String participantReferralId = participantState.pe.Id;
       TokenService.storeToken(participantReferralId, 'session', sessionToken.id_token,null,sessionToken.id_token_expires_in);
       return sessionToken;
    }
    
    public NewUserSessionTokenInfo parseNewUserSessionResponse(String responseBody) {
       NewUserSessionTokenInfo sessionToken =(NewUserSessionTokenInfo) JSON.deserialize(responseBody, NewUserSessionTokenInfo.class);
       ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
       String participantReferralId = participantState.pe.Id; 
       
       TokenService.storeToken(participantReferralId, 'session', sessionToken.session_token,sessionToken.human_id,sessionToken.expires_in);
       return sessionToken;
    }

    public AccessTokenInfo parseAccessResponse(String responseBody) {
        System.debug('responseBody:::'+responseBody);
        AccessTokenInfo accessToken =(AccessTokenInfo) JSON.deserialize(responseBody, AccessTokenInfo.class);
        ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
        String participantReferralId = participantState.pe.Id;
        
       TokenService.storeToken(participantReferralId, 'access', accessToken.access_token,null,accessToken.expires_in); 

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
    public class NewUserSessionTokenInfo
    {

        @AuraEnabled
        public String session_token;       

        @AuraEnabled
        public String expires_in;
        
        @AuraEnabled
        public String human_id;

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