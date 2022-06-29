public with sharing class OpenTokHttpClient {
    private final String apiUrl;
    private final String apiKey;
    private final String apiSecret;
    private Http http;
    private HttpRequest request;
    private HttpResponse response;

    public OpenTokHttpClient(String apiUrl, String apiKey, String apiSecret) {
        this.apiUrl     = apiUrl;
        this.apiKey     = apiKey;
        this.apiSecret  = apiSecret;
        this.http       = new Http();
        this.request    = new HttpRequest();
        this.response   = new HttpResponse();
    }

    public String createSession() {
        
        this.setRequest('POST', 'application/json', 'application/x-www-form-urlencoded', '/session/create', null);
        return this.doSend();
    }
    private String doSend() {
        this.response = http.send(this.request);

        if (this.response.getStatusCode() == 200) {
            return this.response.getBody();
                    
        } else {
            return 'Some issue is happening please check with sys admin';
        }
    }
    

    private void setRequest(String method, String accept, String contentType, String endpoint, String body) {
        this.request.setMethod(method);
        this.request.setHeader('Content-Type', contentType);
        this.request.setHeader('X-OPENTOK-AUTH', new OpenTokJWT(apiUrl, apiKey, apiSecret).getAuthJWTHeader());
        this.request.setEndpoint(this.apiUrl + endpoint);
        if(String.isNotBlank(accept)) {
            this.request.setHeader('Accept', accept);
        }

        if(String.isNotBlank(body)) {
            this.request.setBody(body);
        }
    }
}