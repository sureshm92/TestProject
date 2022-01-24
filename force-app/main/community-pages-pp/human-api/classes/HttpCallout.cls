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
        Type classType
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

    public String constructJSONReq() {
        if (requestMap.isEmpty()) {
            return null;
        }
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        for (String key : requestMap.keySet()) {
            System.debug('key' + requestMap);
            String value = requestMap.get(key);
            try {
                System.debug('key:::' + key + ':::value::' + value);
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

    public static String base64UrlEncode(Blob input) {
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while (output.endsWith('=')) {
            output = output.subString(0, output.length() - 1);
        }
        return output;
    }
    /*
    **Generic method to construct JSON request from Map.
    *
    @param  itemValueMap    key value pair of the actual JSON construct
    @param  itemTypeMap     key: data type value: key of actual JSON consruct
    @param  prettyPrint     set true for pretty print JSON
    @return jsonString      JSON string    
    */
    public static String constructJSONReq(
        Map<String, Object> itemValueMap,
        Map<String, List<String>> itemTypeMap,
        Boolean prettyPrint
    ) {
        String jsonString;

        if (!itemValueMap.isEmpty() && !itemTypeMap.isEmpty()) {
            JSONGenerator gen = JSON.createGenerator(prettyPrint);
            gen.writeStartObject();
            if (itemTypeMap.containsKey('String')) {
                for (String item : itemTypeMap.get('String')) {
                    gen.writeStringField(item, itemValueMap.get(item));
                }
            }
            if (itemTypeMap.containsKey('Number')) {
                for (String item : itemTypeMap.get('Number')) {
                    gen.writeNumberField(item, itemValueMap.get(item));
                }
            }
            //TO-DO: Add other types supported by JSONGenerator method
            gen.writeEndObject();
            jsonString = gen.getAsString();
        }
        return jsonString;
    }
}
