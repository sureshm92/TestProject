global class PatientSSOAuthProviderPlugin extends Auth.AuthProviderPluginClass {
    
    // Use this URL for the endpoint that the 
    // authentication provider calls back to for configuration.
    public String redirectUrl; 
    private String key;
    private String secret;
    private String policy;
    public String loginURL;
    
    // application redirection to the B2C website for authentication and authorization
    private String authUrl;  
    
    // uri to get the new access token from B2C using the Post verb.
    private String accessTokenUrl; 
    
    private String customMetadataTypeApiName = 'AzureB2CAuthProvider__mdt'; // api name for the custom metadata type created for this auth provider
    
    private String userAPIUrl; // api url to access the user in concur
    private String userAPIVersionUrl; // version of the user api url to access data from B2C
    
    private String authProvider;
    private String portal;
    Public static string username;
    
    public class RegPluginException extends Exception {}
    
    global String getCustomMetadataType() {
        return customMetadataTypeApiName;
    }
    
    global PageReference initiate(Map<string,string> authProviderConfiguration, String stateToPropagate) {
        
        authUrl = authProviderConfiguration.get('Auth_Url__c');
        key = authProviderConfiguration.get('Consumer_Key__c');
        String encodUrl= authProviderConfiguration.get('Proxy_Redirect_URL__c');
encodUrl= EncodingUtil.urlEncode(encodUrl, 'UTF-8');
encodUrl= encodUrl.replace ('+', '%2Fpp');
    redirectUrl =encodUrl;
        //redirectUrl = 'https%3A%2F%2Fquintilesimscmo--pi3alpha.sandbox.my.site.com%2Fpp%2Fservices%2Fauthcallback%2FPatient_SSO';//
        //redirectUrl =authProviderConfiguration.get('Proxy_Redirect_URL__c');
        policy = authProviderConfiguration.get('Policy__c');
        loginURL=authProviderConfiguration.get('CommunityHome__c');
            //loginURL =CommunityService.getCommunityURLFromTemplateName('PatientPortal');
             authProvider = authProviderConfiguration.get('AuthProviderName__c');
        //String sURL ='https://iqviavirtualtrials--avengers.sandbox.my.site.com/DemoWeb?state='+ stateToPropagate;
         String sURL = null;
         if(authProvider =='Patient_SSO'){
            //sURL =loginURL +'?state='+ stateToPropagate;
            sURL= loginURL +'/apex/Patientsso_statereceiver?state='+ stateToPropagate;
        }
        //String sURL =loginURL +'?state='+ stateToPropagate;
         
        String url = authUrl + '?p=' + policy + '&client_id='+ key +'&redirect_uri='+ redirectUrl + '&scope=openid email profile&response_type=code&state='+ stateToPropagate+'&prompt=select_account';
        //String url = authUrl + '?p=' + policy + '&client_id='+ key +'&redirect_uri='+ redirectUrl + '&scope=openid email profile&prompt=select_account&response_type=code&state=' + stateToPropagate;
        //String url = authUrl + '?p=' + policy + '&client_id='+ key +'&redirect_uri='+ redirectUrl + '&response_type=code&prompt=select_account&state=' + stateToPropagate;
        //system.debug('url::: '+ sURL);
        return new PageReference(sURL);
    }
    
    global Auth.AuthProviderTokenResponse handleCallback(Map<string,string> authProviderConfiguration, Auth.AuthProviderCallbackState state ) {
        
        // Here, the developer will get the callback with actual protocol. 
              // Their responsibility is to return a new object called AuthProviderTokenResponse. 
              // This will contain an optional accessToken and refreshToken
       key = authProviderConfiguration.get('Consumer_Key__c');
        secret = authProviderConfiguration.get('Consumer_Secret__c');
        accessTokenUrl = authProviderConfiguration.get('Access_Token_Url__c');
        authProvider = authProviderConfiguration.get('AuthProviderName__c');
        policy = authProviderConfiguration.get('Policy__c'); 
            
        Map<String,String> queryParams = state.queryParameters;
        String code = queryParams.get('code');
        String sfdcState = queryParams.get('state');
        
        system.debug('code****'+code+'*****state*****'+sfdcState);
        
        HttpRequest req = new HttpRequest();
        String url = accessTokenUrl+'?p=' + policy;
        req.setEndpoint(url);
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setMethod('POST');
        String reqbody = 'code=' + code + '&client_id=' + key + '&client_secret=' + secret + '&grant_type=authorization_code&scope=openid';
        //String reqbody = 'code=' + code + '&client_id=' + key + '&client_secret=' + secret;
        req.setBody(reqbody); 
        
        system.debug('reqbody '+reqbody);
        String token = null;
        try{
            Http http = new Http();
            HTTPResponse res = http.send(req);
            String responseBody = res.getBody();  
            system.debug('responseBody '+responseBody);    
            token = getTokenValueFromResponse(responseBody, 'id_token', false);
            //return new Auth.AuthProviderTokenResponse(authProvider, token, secret, sfdcState);
        } 
        catch(RegPluginException e){
            throw new RegPluginException(e.getMessage());
        }
         return new Auth.AuthProviderTokenResponse(authProvider, token, secret, sfdcState);
    }
    
    global Auth.UserData  getUserInfo(Map<string,string> authProviderConfiguration, Auth.AuthProviderTokenResponse response) {
        //Here the developer is responsible for constructing an 
        //Auth.UserData object 
       
                   String id ;
        String country ;
        String fname;
        String lname;
        String flname;
        String email;
        String locale;
        string username;
        string identifier;
        string shEmail;
        Map<String,String> provMap = new Map<String,String>();
        
        authProvider = authProviderConfiguration.get('AuthProviderName__c');
        portal = authProviderConfiguration.get('PortalName__c');
        
        String networkid = [select id, name from network where name =: portal Limit 1].id;
        
        /////This is necessary for the User info method to work as described in a lemma on the documentation for the plugin
        try{
            HttpRequest req = new HttpRequest();
            String url = 'https://login.salesforce.com/';
            req.setEndpoint(url);
            req.setMethod('GET');
            Http http = new Http();
            HTTPResponse res = http.send(req);
        } catch(Exception ex) {
            System.debug('Salesforce mock callout failed. ' + ex.getMessage());
        }
        //////
        
        try{
            if (String.isBlank(response.OAuthToken)){
                throw new RegPluginException('PP received empty token from SSO : ' + response.OAuthToken);
            }
            else{
                List<String> SplitToken =  response.OAuthToken.split('\\.');           
                
                Blob tokenPayloadBlob = EncodingUtil.base64decode(SplitToken[1]);
                
                String decrypted = tokenPayloadBlob.toString();
                
                id = getTokenValueFromResponse(decrypted, 'oid',false); 
                
                if(string.isEmpty(id)){
                    id = getTokenValueFromResponse(decrypted, 'tid',false);
                }
                
                if (Test.isRunningTest()) {
                    decrypted = '{"ver":"1.0","given_name":"test1","family_name":"test1","username":"testsso2024sso@gmail.com","oid":"70881d1a-9717-4ce4-bb18-a4eee553bceb","countryDefault_1":"India","email":"testsso2024sso@gmail.com","emails":[]}';
                    email = getTokenValueFromResponse(decrypted, 'emails',true);
                }
                
                fname = getTokenValueFromResponse(decrypted, 'given_name', false);
                lname = getTokenValueFromResponse(decrypted, 'family_name', false); 
                country = getTokenValueFromResponse(decrypted, 'countryDefault_1', false);
                flname = fname + ' ' + lname;
                
                email = getTokenValueFromResponse(decrypted, 'email', false);
                shEmail = getTokenValueFromResponse(decrypted, 'username', false);        
                username = getTokenValueFromResponse(decrypted, 'external_system_id', false);
                identifier = id + '_' + username;
                
                if(string.isEmpty(email)){
                    email = getTokenValueFromResponse(decrypted, 'emails',true);
                }                
                locale = 'en_US';
                provMap.put('oid', id);
                provMap.put('sfdc_networkid', networkid);
            }
        } catch(Exception ex) {
            System.debug(ex.getMessage());
            //new CustomExcptn().CustomError(ex);
        }
        return new Auth.UserData(identifier, fname, lname, flname, email,
                                 shEmail, username, country, authProvider, null, provMap);
                
    }
    
    private String getTokenValueFromResponse(String response, String key, Boolean isArray) {
         String ret = null;     
        try{
            Map<String, Object> jsonResponse =  (Map<String, Object>) json.deserializeUntyped(response);
            
            if(!isArray){
                if(jsonResponse.get(key) <> null)
                    ret=jsonResponse.get(key).toString();
            } else{
                if(jsonResponse.get(key) <> null){
                    List<Object> emailsArray =  (List<Object>) jsonResponse.get(key);
                    ret= emailsArray[0].toString();
                }                
            }            
        } catch(Exception ex) {
            system.debug(key + ' is not available in claims.' + ex.getMessage());
            //new CustomExcptn().CustomError(ex);
        }    
        return ret; 
        } 
       public without sharing Class CustomExcptn  {
        
        
    }
    
}