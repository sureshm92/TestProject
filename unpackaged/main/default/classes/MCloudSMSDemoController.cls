/**
 * Created by Slav Van on 15.08.2019.
 */

public with sharing class MCloudSMSDemoController {
    
    /********************************************************************
     * RequestBean class contains HTTP request data
     ********************************************************************/
    private class RequestBean {
        private String			clientId;
        private String			clientSecret;
        
        private List<String>	mobileNumbers;
        private String			keyword;
        private Boolean			subscribe;
        private Boolean			resubscribe;
        private String			shortCode;
        private Boolean			override_x;
        private String			messageText;
        private String			sendTime;
    }
    
    /********************************************************************
     * ResponseBean class contains HTTP response data
     ********************************************************************/
    private class ResponseBean {
        private String					accessToken;
        private Integer					expiresIn;
        private String					message;
        private Integer					errorcode;
        private String					documentation;
        private List<String>			errors;
        private List<InvalidSubscriber>	invalidSubscribers;
        private String					tokenId;
    }
    
    /********************************************************************
     * InvalidSubscriber class contains information on invalid subscriber
     ********************************************************************/
    private class InvalidSubscriber {
        private String			mobileNumber;
        private String			validationErrorMessage;
    }
    
    /********************************************************************
     * Custom exception UnauthorizedException
     ********************************************************************/
    public class AuthorizationException extends Exception {
    }
    
    /********************************************************************
     * Custom exception SendException
     ********************************************************************/
    public class SendException extends Exception {
    }
    
    /********************************************************************
     * private fields
     ********************************************************************/
    private final String clientId;
    private final String clientSecret;
    
    public  String testPhone                    { get; set; }
    public  String outboundMessage              { get; set; }
    public  String keyword                      { get; set; }
    public  List<SelectOption> keywordOptions   { get; set; }

    private final String loginURI;
    private final String restURI;
    public  final String shortCode              { get; private set; }
    private final String msgApiKey;
    private final String sendSMS;
    private final String sendOptIn;
    private final String deliveryCheck;
    
    private String accessToken;				// authorization Access Token
//    private String tokenId;					// Token Id is returned if Send was successful
    private String errorMessage;			// MC API request error message
    
    /********************************************************************
     * constructor
     * TODO: Marketing Cloud information should be assigned from either
     * TODO: Custom metadata settings or a custom object
     ********************************************************************/
    public MCloudSMSDemoController () {
        clientId        = 'lmqygxkpy599h99gw1xjlc8i';           //'{!$Credential.Username}';
        clientSecret    = 'YgjRpY6Aj7oK234j6ELW2hvy';           //'{!$Credential.Password}';
        testPhone       = '16463311399';                        // this is the Dev test phone, it stands by 24x7
        loginURI        = 'https://mc2gwv28hdsr86gd-sldnjzvzzgm.auth.marketingcloudapis.com/v1/requestToken';
        restURI			= 'https://mc2gwv28hdsr86gd-sldnjzvzzgm.rest.marketingcloudapis.com/';
        shortCode		= '64586';                              // short number (USA only)
        msgApiKey		= 'OTk6Nzg6MA';     // RH_API_TEST (test API-triggered message)
        sendSMS			= 'sms/v1/messageContact/' + msgApiKey + '/send';
        sendOptIn		= 'sms/v1/queueMO';
        deliveryCheck	= 'sms/v1/messageContact/' + msgApiKey + '/deliveries';
    
        keywordOptions  = new List<SelectOption>();
        keywordOptions.add(new SelectOption('STOP01', 'STOP01'));
        keywordOptions.add(new SelectOption('STOP02', 'STOP02'));
        keywordOptions.add(new SelectOption('STOP03', 'STOP03'));
        keywordOptions.add(new SelectOption('STOP04', 'STOP04'));
        
        authorize();
    }
    
    /********************************************************************
     * authorize() logs on Marketing Cloud and obtains an Access Token
     * returns TRUE if successful, or FALSE otherwise
     ********************************************************************/
    private Boolean authorize () {
        try {
            errorMessage = null;
            
            RequestBean requestBean     = new RequestBean();
            requestBean.clientId        = clientId;
            requestBean.clientSecret    = clientSecret;
            String body                 = JSON.serialize(requestBean);
            System.debug('----------------- BODY = '+body);
            
            HttpRequest request         = new HttpRequest();
            request.setTimeout(60000);
            request.setMethod('POST');
            request.setEndpoint(loginURI);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Content-Length', '' + body.length());
            request.setBody(body);
            HttpResponse response       = new Http().send(request);
            System.debug('========================----------------- response = '+response);
            
            if (response.getStatusCode() == 200) {
                ResponseBean responseBean = (ResponseBean) JSON.deserialize(response.getBody(), ResponseBean.class);
                accessToken = responseBean.accessToken;
                System.debug('----------------- successful login accessToken = '+accessToken);
                return true;
            } else {
                AuthorizationException e = new AuthorizationException();
                e.setMessage('Failed to authorize on Marketing Cloud');
                throw e;
            }
        } catch (Exception e) {
            errorMessage = e.getMessage() + ' ' + e.getStackTraceString();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
            System.debug('----------------- EXCEPTION '+e.getMessage() + ' ' + e.getStackTraceString());
        }
        
        return false;
    }
    
    /********************************************************************
     * sendMessage()
     ********************************************************************/
    public PageReference sendMessage () {
        errorMessage = null;
        RequestBean requestBean = new RequestBean();
        requestBean.mobileNumbers = new List<String>();
        requestBean.mobileNumbers.add(testPhone);
       
        try {
            if (String.isBlank(outboundMessage)) {
                requestBean.subscribe = true;
                requestBean.resubscribe = true;
                requestBean.override_x = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Message text not specified. Sending default text.'));
            } else {
                requestBean.subscribe = true;
                requestBean.resubscribe = false;
                requestBean.override_x = true;
                requestBean.messageText = outboundMessage;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Sending message \'' + outboundMessage + '\''));
            }

            requestBean.keyword = keyword;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Keyword: \'' + keyword + '\''));
            String body = JSON.serialize(requestBean).replaceAll('_x', '');
            
            HttpRequest request = new HttpRequest();
            request.setTimeout(60000);
            request.setMethod('POST');
            request.setEndpoint(restURI + sendSMS);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', 'Bearer ' + accessToken);
            request.setHeader('Content-Length', '' + body.length());
            request.setBody(body);
            HttpResponse response = new Http().send(request);
            
            if (response.getStatusCode() == 401) {		//
                if (authorize()) {
                    //------------------------------------------------------------------//
                    // if not authorized then try to authorize and re-send the request	//
                    //------------------------------------------------------------------//
                    request.setHeader('Authorization', 'Bearer ' + accessToken);
                    response = new Http().send(request);
                } else {
                    SendException e = new SendException();
                    e.setMessage(response.getStatusCode() + ' ' + response.getStatus());
                    throw e;
                }
            }
            
            ResponseBean responseBean = (ResponseBean) JSON.deserialize(response.getBody(), ResponseBean.class);
            if (response.getStatusCode() == 202) {
                //--------------------------------------------------------------------------------------//
                // Send request was accepted, but we have to check if any phone numbers were invalid	//
                //--------------------------------------------------------------------------------------//
                String tokenId = responseBean.tokenId;
                System.debug('----------------TOKEN_ID: '+tokenId);
                Map<String, String> failedNumbers = new Map<String, String>();
                if (responseBean.invalidSubscribers != null) {
                    System.debug('----------------INVALI NUMBERS: '+responseBean.invalidSubscribers);
                    for (InvalidSubscriber invalidSubscriber : responseBean.invalidSubscribers) {
                        failedNumbers.put(invalidSubscriber.mobileNumber, invalidSubscriber.validationErrorMessage);
                    }
                }
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Successfully sent'));
                
                checkDelivery(tokenId);
            } else {
                System.debug('----------------RESPONSE: '+response.getBody());
                SendException e = new SendException();
                String errMsg = '';
                for (String error : responseBean.errors) {
                    errMsg += error + '<br>\n';
                }
                e.setMessage(errMsg);
                throw e;
            }
        } catch (Exception e) {
            errorMessage = e.getMessage() + ' ' + e.getStackTraceString();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
            System.debug('----------------ERROR: '+errorMessage);
        }
        
        return null;
    }
    
    /********************************************************************
     * checkDelivery() checks delivery status of the Send request
     * specified by tokenId and returns its outbound message
     ********************************************************************/
    private String checkDelivery (String tokenId) {
        HttpRequest request = new HttpRequest();
        request.setTimeout(60000);
        request.setMethod('GET');
        request.setEndpoint(restURI + deliveryCheck + '/' + tokenId);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        
        HttpResponse response = new Http().send(request);
        System.debug('CHECK DELIVERY --------------> ' + response.getBody());
        ResponseBean responseBean = (ResponseBean) JSON.deserialize(response.getBody(), ResponseBean.class);
        
        if (response.getStatusCode() == 200) {
            return responseBean.message;
        } else {
            return null;
        }
    }

}