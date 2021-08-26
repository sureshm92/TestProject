public class RemoteCall_getHumanAPITokens{
    
    
    
    public static String clientId;
    public static String clientUserId; //referral Id
    public static String clientUserEmail;//patient email
    public static String clientSecret;
    public static String humanId;    
    public static String referralRecordId;
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

    public SessionTokenInfo remoteCallGetSessionToken(String participantEmail,String referralId,String humanId,String uniqueHumanId)
    {
        
        referralRecordId = referralId;
        String url='HumanAPI_Connect';
        Boolean isNewUser = false;
        Map<String, String> requestMap = new Map<String, String>();
        ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
        //clientUserEmail = participantState.pe.Participant__r.Email__c;
        // clientUserId = participantState.pe.Id;
        // participantState.pe.Unique_HumanId__c
        // participantState.pe.Human_Id__c
        clientUserEmail = participantEmail;
        //if(participantState.pe==null){
            clientUserEmail =participantState.participant.Email__c;
        //}
        clientUserId = referralId;
        
        if(String.isBlank(humanId) && participantState.pe != null )
        {
            requestMap = new Map<String, String>{ 'client_id' => clientId, 'client_user_id' => uniqueHumanId ,'client_user_email' => clientUserEmail,'client_secret' => clientSecret, 'type' => 'session'};
            isNewUser = true;
        }
        else
        {
            requestMap = new Map<String, String>{ 'client_id' => clientId, 'client_user_id' => uniqueHumanId ,'client_user_email' => clientUserEmail,'client_secret' => clientSecret, 'type' => 'id'};
        }
        if(!String.isEmpty(humanId) && participantState.pe.Referral_ID__c !=null){
            isNewUser = false;
        }
        Map<String, String> headerMap = new Map<String, String>{ 'Content-Type' => 'application/json' };
        
        HttpCallout remoteCall = new HttpCallout(url,'POST',headerMap,requestMap,MedicalRecordAccessRemote.class);
        String currentParticipantEnrollmentId = referralId;// determining logged in user's participant enrollment Id
        String sessionToken = TokenService.fetchToken(currentParticipantEnrollmentId,'session');
        SessionTokenInfo sessionTokenInfo = new SessionTokenInfo();
        if(isNewUser == false){
        if(!String.isBlank(sessionToken)){
           sessionTokenInfo.id_token = sessionToken;
        }
        else{ 
            String respBody = (String)remoteCall.execute();
            
           
            if(remoteCall.log.Response_Status_Code__c != 200){
               // requestMap = new Map<String, String>{ 'client_id' => clientId, 'client_user_id' => uniqueHumanId ,'client_user_email' => clientUserEmail,'client_secret' => clientSecret, 'type' => 'session'};
                requestMap.put('type','session');
                HttpCallout remoteCall2 = new HttpCallout(url,'POST',headerMap,requestMap,MedicalRecordAccessRemote.class);
                  //  sessionTokenInfo = parseSessionResponse((String)remoteCall2.execute()); //custom object
                   respBody = (String)remoteCall2.execute();
                 //sessionTokenInfo = parseNewUserSessionResponse((String)remoteCall2.execute());
                  NewUserSessionTokenInfo newUserTokenInfo =  parseNewUserSessionResponse((String)remoteCall2.execute());
            sessionTokenInfo.id_token = newUserTokenInfo.session_token;
            humanId = newUserTokenInfo.human_id;
            sessionTokenInfo.humanId = newUserTokenInfo.human_id;

            }
            else
            {
            sessionTokenInfo = parseSessionResponse(respBody); //custom object
            }
            
            
              

        }
        }
        else
        {
            
            NewUserSessionTokenInfo newUserTokenInfo = parseNewUserSessionResponse((String)remoteCall.execute());
            sessionTokenInfo.id_token = newUserTokenInfo.session_token;
            humanId = newUserTokenInfo.human_id;
            sessionTokenInfo.humanId = newUserTokenInfo.human_id;
            /** Participant_Enrollment__c peObj=new Participant_Enrollment__c();
             peObj.id=participantState.pe.Id;
            peObj.Human_Id__c = newUserTokenInfo.human_id;
            update peObj; **/
        }

        
        return sessionTokenInfo;
        
    }

    public AccessTokenInfo remoteCallGetAccessToken(String referralId,String clientUserEmail,String uniqueHumanId)
    {
        String url='HumanAPI_Connect'; //call referralid      
        ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
      //  clientUserEmail = participantState.pe.Participant__r.Email__c;
       // ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
       // participantState.pe.Id
       // participantState.pe.Participant__r.Email__c
       // participantState.pe.Unique_HumanId__c
        String currentParticipantEnrollmentId = referralId;
        referralRecordId  = referralId;
        clientUserEmail = clientUserEmail; 
        if(participantState.pe==null){
            clientUserEmail =participantState.participant.Email__c;  
            //client user email 
        }
        Map<String, String> headerMap = new Map<String, String>{ 'Content-Type' => 'application/json' };
        Map<String, String> requestMap = new Map<String, String>{ 'client_id' => clientId, 'client_user_id' => uniqueHumanId ,'client_user_email' => clientUserEmail,'client_secret' => clientSecret, 'type' => 'access'};
        HttpCallout remoteCall = new HttpCallout(url,'POST',headerMap,requestMap,MedicalRecordAccessRemote.class);
       AccessTokenInfo accessTokenInfo = new AccessTokenInfo();
        String accessToken = TokenService.fetchToken(currentParticipantEnrollmentId,'access');
        
        if(!String.isBlank(accessToken)){
            
            accessTokenInfo.access_token = accessToken;
        }
        else{ 
            accessTokenInfo = parseAccessResponse((String)remoteCall.execute());

          
        } 
       
        return accessTokenInfo;
        
    }    
   
    public SessionTokenInfo parseSessionResponse(String responseBody) {
       SessionTokenInfo sessionToken =(SessionTokenInfo) JSON.deserialize(responseBody, SessionTokenInfo.class);
       ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
       String participantReferralId;
        if(UserContext.getCurrentUserMode().hasPastStudies){
            participantReferralId = referralRecordId;
                }else
                {
         participantReferralId = participantState.pe.Id;
                }
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
        String participantReferralId ;
        AccessTokenInfo accessToken =(AccessTokenInfo) JSON.deserialize(responseBody, AccessTokenInfo.class);
        ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
        if(participantState.pe == null){
            participantReferralId = referralRecordId;
                }else
                {
         participantReferralId = participantState.pe.Id;
                }
        
       //TokenService.storeToken(participantReferralId, 'access', accessToken.access_token,null,accessToken.expires_in); 

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
        
        @AuraEnabled
        public String humanId;

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