public class HttpCallout extends RemoteCall{
    

    public String methodType;
    public Map<String, String> requestMap;
    public Type classType;
    
    public HttpCallout(String endPointURL,String methodType,Map<String, String> headerMap,Map<String, String> requestMap,Type classType)
    {
        this.endPointURL =  'callout:'+endPointURL;
        this.httpMethod = methodType;
        this.headersMap.putAll(headerMap);
        this.requestMap = requestMap;
        this.classType = classType;
    }

    @TestVisible
    protected override String buildRequestBody() {

        return constructJsonReq();
    }

    @TestVisible
    public override Type getType() {
        return classType;//RemoteCall_getSessionToken
    }

    @TestVisible
    protected override Object parseResponse(String responseBody) {
       return responseBody;

    }

    public String constructJsonReq()
        {
            JSONGenerator gen = JSON.createGenerator(true);   
            gen.writeStartObject(); 
            for (String key : requestMap.keySet()) {
                System.debug('key'+requestMap);
                String value = requestMap.get(key);
                gen.writeStringField(key,value );
            }
            gen.writeEndObject();    
            String jsonReqBody = gen.getAsString();
            System.debug('json'+jsonReqBody);
            return jsonReqBody;
        } 
}

