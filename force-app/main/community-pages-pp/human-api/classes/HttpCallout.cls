public class HttpCallout extends RemoteCall {
    public String methodType;
    public Map<String, String> requestMap;
    public String jsonReqBody;
    public Type classType;

    public HttpCallout(
        String endPointURL,
        String methodType,
        Map<String, String> headerMap,
        Map<String, String> requestMap,
        Type classType
    ) {
        this.endPointURL = 'callout:' + endPointURL;
        this.httpMethod = methodType;
        this.headersMap.putAll(headerMap);
        this.requestMap = requestMap;
        this.classType = classType;
        this.logAutoInsert = false;
    }

    public HttpCallout(
        String endPointURL,
        String methodType,
        Map<String, String> headerMap,
        String jsonReqBody,
        System.Type classType
    ) {
        this.endPointURL = 'callout:' + endPointURL;
        this.httpMethod = methodType;
        this.headersMap.putAll(headerMap);
        this.jsonReqBody = jsonReqBody;
        this.classType = classType;
        this.logAutoInsert = false;
    }

    public void setEndPointURL(String endPointURL) {
        this.endPointURL = endPointURL;
    }

    public void setAutoLogInsert(Boolean setAutoLogInsert) {
        this.logAutoInsert = setAutoLogInsert;
    }

    @TestVisible
    protected override String buildRequestBody() {
        if (jsonReqBody == null) {
            return constructJsonReq();
        } else {
            return jsonReqBody;
        }
    }

    @TestVisible
    public override Type getType() {
        return classType;
    }

    @TestVisible
    protected override Object parseResponse(String responseBody) {
        return responseBody;
    }

    public String constructJsonReq() {
        if (requestMap.isEmpty()) {
            return null;
        }
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        for (String key : requestMap.keySet()) {
            String value = requestMap.get(key);
            try {
                gen.writeStringField(key, value);
            } catch (Exception e) {
                System.debug('error' + e.getLineNumber());
            }
        }

        gen.writeEndObject();
        String jsonReqBody = gen.getAsString();
        System.debug('json' + jsonReqBody);
        return jsonReqBody;
    }
}
