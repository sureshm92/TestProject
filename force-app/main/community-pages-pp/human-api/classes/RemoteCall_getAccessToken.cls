public class RemoteCall_getAccessToken extends RemoteCall{
    
    public static String clientId='72cd1f1f7b36cc80e104efd2a9332e74372fcb24';
    public static  String clientUserId='SK_Sandeep'; //referral Id
    public static String clientUserEmail='sandeepsfdc527@gmail.com';//patient email
    public static String clientSecret='8338fd6645b6b430fe186729a1a873e7cd57a839';

    
    public RemoteCall_getAccessToken()
    {
        this.endPointURL =  'callout:HumanAPI_Connect';
        this.httpMethod = METHOD_POST;
        this.headersMap.putAll(new Map<String, String>{ 'Content-Type' => 'application/json' });
    }

    @TestVisible
    protected override String buildRequestBody() {

        return jsonTokenRequest(clientId,clientUserId,clientUserEmail,clientSecret,'access');
    }

    @TestVisible
    public override Type getType() {
        return RemoteCall_getAccessToken.class;//RemoteCall_getSessionToken
    }

    @TestVisible
    protected override Object parseResponse(String responseBody) {

       TokenData tokenResponse = (TokenData) JSON.deserialize(responseBody, TokenData.class);
       return tokenResponse;

    }

    public String jsonTokenRequest(String clientId,String clientUserId,String clientUserEmail,String clientSecret,String tokentype)
        {
            JSONGenerator gen = JSON.createGenerator(true);    
            gen.writeStartObject();      
            gen.writeStringField('client_id',clientId );
            gen.writeStringField('client_user_id',clientUserId);
            gen.writeStringField('client_user_email',clientUserEmail);
            gen.writeStringField('client_secret',clientSecret);
            gen.writeStringField('type',tokentype);
            gen.writeEndObject();    
            String jsonReqBody = gen.getAsString();
            System.debug('json'+jsonReqBody);
            return jsonReqBody;
        } 


        public class TokenData {

            @AuraEnabled
            public String token_type;

            @AuraEnabled
            public String id_token;

            @AuraEnabled
            public String id_refresh_token;

            @AuraEnabled
            public String id_token_expires_in;
        }


}
