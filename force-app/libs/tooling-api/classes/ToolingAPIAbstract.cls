/**
 * Created by Leonid Bartenev
 */

public abstract without sharing class ToolingAPIAbstract {
    
    public class ToolingAPIServiceException extends Exception {}
    
    private static final String SALESFORCE_URL = 'callout:Salesforce_Credential';
    
    public static final String METHOD_POST = 'POST';
    public static final String METHOD_GET = 'GET';
    
    protected Integer timeout = 120000;
    protected String endPointURL;
    protected String httpMethod = METHOD_GET;
    protected Map<String, String> headersMap = new Map<String, String>();
    
    protected abstract String buildRequestBody();
    protected abstract Object parseResponse(String responseBody);

    public Object execute(){
        HttpRequest request = createRequest();
        request.setEndpoint(SALESFORCE_URL + endPointURL);
        return sendRequest(request);
    }
    
    public Object executeInCurrentSession() {
        if(String.isEmpty(UserInfo.getSessionId())) throw new ToolingAPIServiceException('Session Id not available, use execute() method instead');
        HttpRequest request = createRequest();
        request.setEndpoint(Url.getSalesforceBaseUrl().toExternalForm() + endPointURL);
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        return sendRequest(request);
    }
    
    private HttpRequest createRequest(){
        HttpRequest request = new HttpRequest();
        request.setMethod(httpMethod);
        request.setHeader('Content-Type', 'application/json');
        for(String headerName: headersMap.keySet()){
            request.setHeader(headerName, headersMap.get(headerName));
        }
        request.setTimeout(timeout);
        String requestBody = buildRequestBody();
        System.debug('Tooling API Endpoint: ' + endPointURL);
        if(requestBody != null) {
            System.debug('Tooling API Request body: ' + requestBody);
            request.setBody(buildRequestBody());
        }
        return request;
    }
    
    private Object sendRequest(HttpRequest request){
        if(endPointURL == null) throw new ToolingAPIServiceException('EndPointURL not initialized');
        HttpResponse response = new Http().send(request);
        System.debug('Tooling API Response: ' + response.toString() + '\n' + response.getBody());
        checkResponse(response);
        return parseResponse(response.getBody());
    }
    
    private void checkResponse(HttpResponse response) {
        if(response.getStatusCode() != 200 || String.isEmpty(response.getBody())){
            throw new ToolingAPIServiceException('Response status: ' + response.toString() + ' \nResponse body: ' + response.getBody());
        }
    }

}