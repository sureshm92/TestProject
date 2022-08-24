/**
 * Created by Leonid Bartenev
 */

public abstract class RemoteCall {
    public class RemoteCallException extends Exception {
    }

    public static final String METHOD_POST = 'POST';
    public static final String METHOD_GET = 'GET';
    public static final String METHOD_PUT = 'PUT';

    protected Integer timeout = 120000;
    protected String endPointURL;
    protected String httpMethod = METHOD_GET;
    protected Map<String, String> headersMap = new Map<String, String>();
    protected Map<String, String> hiddenParams = new Map<String, String>();
    public IntegrationLog__c log;
    protected String uuid = generateUUID();
    protected Boolean logAutoInsert = true;
    public Boolean hideParamsInLog = true;


    public abstract Type getType();
    protected abstract String buildRequestBody();
    protected abstract Object parseResponse(String responseBody);
    protected  Integer responseCode;

    public Object execute() {
        System.debug('endPointURL::::' + endPointURL);
        if (endPointURL == null)
            throw new RemoteCallException('Endpoint URL can not be null');
        System.debug('METHOD: ' + httpMethod + ', ENDPOINT: ' + endPointURL);
        //init request:
        HttpRequest req = new HttpRequest();
        req.setMethod(httpMethod);
        req.setEndpoint(endPointURL);
        for (String headerName : headersMap.keySet()) {
            req.setHeader(headerName, headersMap.get(headerName));
            System.debug('headerName::::' + headerName + 'value::::' + headersMap.get(headerName));
        }
        req.setTimeout(timeout);
        Datetime requestDT = Datetime.now();
        Datetime responseDT;
        //init log:
        log = new IntegrationLog__c(
            Function_Name__c = getType().toString(),
            Http_Method__c = httpMethod,
            Endpoint_URL__c = endPointURL,
            UUID__c = uuid,
            Request_Time__c = requestDT,
            Timeout__c = timeout,
            Success__c = false
        );
        //execute request:
        HttpResponse res;
        try {
            //build request body:
            String requestBodySource = buildRequestBody();
            if (requestBodySource != null) {
                String requestBodyResult = substituteSecuredParams(requestBodySource);
                req.setBody(requestBodyResult);
                if (hideParamsInLog) {
                    log.Request_Body__c = requestBodySource.mid(
                        0,
                        IntegrationLog__c.Request_Body__c.getDescribe().length
                    );
                } else {
                    log.Request_Body__c = requestBodyResult.mid(
                        0,
                        IntegrationLog__c.Request_Body__c.getDescribe().length
                    );
                }
            }
            Http http = new Http();
            res = http.send(req);
            responseDT = Datetime.now();
            //update log info:
            log.Response_Status_Code__c = res.getStatusCode();
            log.Response_Status__c = res.getStatus();
            if (!String.isEmpty(res.getBody())) {
                log.Response_Body__c = res.getBody()
                    .mid(0, IntegrationLog__c.Response_Body__c.getDescribe().length);
            }
            if (
                res.getStatusCode() == 200 ||
                res.getStatusCode() == 201 ||
                res.getStatusCode() == 202
            ) {
                log.Success__c = true;
            } else {
                log.Error_Message__c = res.getStatus();
            }
            System.debug('RESPONSE STATUS: ' + res.getStatusCode() + ' ' + res.getStatus());
            System.debug(res.getBody());
            responseCode= res.getstatusCode();
            return parseResponse(res.getBody());

        } catch (Exception e) {
            responseDT = Datetime.now();
            String errorMessage = e.getMessage() + ' ' + e.getStackTraceString();
            System.debug('ERROR: ' + errorMessage);
            //update log info:
            log.Error_Message__c = errorMessage.mid(
                0,
                IntegrationLog__c.Error_Message__c.getDescribe().length
            );
            log.Timeout_Encountered__c = e.getMessage().equalsIgnoreCase('Read timed out');
        } finally {
            //update log info:
            log.Response_Time__c = responseDT;
            log.Call_Duration__c = responseDT.getTime() - requestDT.getTime();
            if (logAutoInsert) {
                DMLService.insertRecord(log);
            }
        }
        return null;
    }

    private String substituteSecuredParams(String requestBody) {
        String result = requestBody;
        for (String param : hiddenParams.keySet()) {
            result = result.replaceAll(
                '\\{!' +
                param +
                '\\}',
                Matcher.quoteReplacement(hiddenParams.get(param))
            );
        }
        return result;
    }

    private static String generateUUID() {
        Blob b = Crypto.generateAesKey(128);
        String h = EncodingUtil.convertToHex(b);
        String uuid =
            h.substring(0, 8) +
            '-' +
            h.substring(8, 12) +
            '-' +
            h.substring(12, 16) +
            '-' +
            h.substring(16, 20) +
            '-' +
            h.substring(20);
        return uuid;
    }
}
