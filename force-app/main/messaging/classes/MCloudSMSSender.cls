/**
 * Created by Slav on 08.14.2019.
 */

public class MCloudSMSSender {
    
    /**************************************************************************
     * RequestBean class contains request data
     **************************************************************************/
    private class RequestBean {
        private String			clientId;
        private String			clientSecret;
        private List<String>	mobileNumbers;
        private String			keyword;
        private Boolean			subscribe;
        private Boolean			resubscribe;
        private String			shortCode;
        private Boolean			override_x;         // it's a workaround, since the word 'override' is reserved
        private String			messageText;
        private String			sendTime;
    }

    /**************************************************************************
     * ResponseBean class contains response data
     **************************************************************************/
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

    /**************************************************************************
     * InvalidSubscriber class contains information on invalid subscriber
     **************************************************************************/
    private class InvalidSubscriber {
        private String			mobileNumber;
        private String			validationErrorMessage;
    }

    /**************************************************************************
     * UnauthorizedException
     **************************************************************************/
    public class AuthorizationException extends Exception {
    }

    /**************************************************************************
     * SendException
     **************************************************************************/
    public class SendException extends Exception {
    }

    /******************************************************************************************************************/
    private final String clientId;
    private final String clientSecret;
    private final String testPhone;
    private final String restURI;
    private final String msgApiKey;
    private final String sendSMS;
    private final String sendOptIn;
    private final String deliveryCheck;

    private String accessToken;				// authorization Access Token
    private String tokenId;					// Token Id is returned if Send was successful
    /******************************************************************************************************************/

    private static MCloudSMSSender instance = new MCloudSMSSender();
    public static MCloudSMSSender getInstance(){
        return instance;
    }

    /********************************************************************
     * constructor
     * TODO: Marketing Cloud information should be assigned from either
     * TODO: Custom metadata settings or a custom object
     ********************************************************************/
    public MCloudSMSSender () {
        clientId        = '{!$Credential.Username}';
        clientSecret    = '{!$Credential.Password}';
        testPhone       = '16463311399';                        // this is the Dev test phone, it stands by 24x7
        restURI			= 'https://mc2gwv28hdsr86gd-sldnjzvzzgm.rest.marketingcloudapis.com/';
        msgApiKey		= 'OTk6Nzg6MA';                         // RH_API_TEST (test API-triggered message)
        sendSMS			= 'sms/v1/messageContact/' + msgApiKey + '/send';
        sendOptIn		= 'sms/v1/queueMO';
        deliveryCheck	= 'sms/v1/messageContact/' + msgApiKey + '/deliveries';
    }

    /**************************************************************************
     * authorize() logs on Marketing Cloud and obtains an Access Token
     * if authorization fails the method throws AuthorizationException
     **************************************************************************/
    private void authorize () {
        RequestBean requestBean     = new RequestBean();
        requestBean.clientId        = clientId;
        requestBean.clientSecret    = clientSecret;
        String body                 = JSON.serialize(requestBean);

        HttpRequest request         = new HttpRequest();
        request.setTimeout(60000);
        request.setMethod('POST');
        request.setEndpoint('callout:MCloudAuthorization');     //
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Content-Length', '' + body.length());
        request.setBody(body);
        HttpResponse response       = new Http().send(request);

        if (response.getStatusCode() == 200) {
            ResponseBean responseBean = (ResponseBean) JSON.deserialize(response.getBody(), ResponseBean.class);
            accessToken = responseBean.accessToken;
        } else {
            AuthorizationException e = new AuthorizationException();
            e.setMessage('Failed to authorize on Marketing Cloud');
            throw e;
        }
    }

    /**************************************************************************
     * sendSMSAsync() send SMS asynchronously
     *
     * @param mobileNumbers
     * @param message
     **************************************************************************/
    @Future(Callout=true)
    public static void sendSMSAsync (List<String> mobileNumbers, String message) {
        MCloudSMSSender.getInstance().sendSMS(mobileNumbers, message);
    }

    /**************************************************************************
     * sendSMS() send SMS
     *
     * @param mobileNumbers
     * @param message
     **************************************************************************/
    public void sendSMS (List<String> mobileNumbers, String message) {
        if (Trigger.isExecuting) {
            // if method is invoked from a Trigger then run asynchronously
            sendSMSAsync(mobileNumbers, message);
            return;
        }

        try {
            validateMobileNumbers(mobileNumbers);
            if (accessToken == null) authorize();

            RequestBean requestBean     = new RequestBean();
            requestBean.mobileNumbers   = new List<String>();
            requestBean.mobileNumbers.addAll(mobileNumbers);
            requestBean.mobileNumbers.add(testPhone);
            requestBean.subscribe       = true;
            requestBean.resubscribe     = true;
            requestBean.keyword         = 'STOP01';

            if (String.isBlank(message)) {
                requestBean.override_x  = false;
            } else {
                requestBean.override_x  = true;
                requestBean.messageText = message;
            }

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
            ResponseBean responseBean = (ResponseBean) JSON.deserialize(response.getBody(), ResponseBean.class);

            if (response.getStatusCode() == 202) {
                //--------------------------------------------------------------------------------------//
                // Send request was accepted, but we have to check if any phone numbers were declined	//
                //--------------------------------------------------------------------------------------//
                String tokenId = responseBean.tokenId;
                Map<String, String> failedNumbers = new Map<String, String>();
                if (responseBean.invalidSubscribers != null) {
                    for (InvalidSubscriber invalidSubscriber : responseBean.invalidSubscribers) {
                        System.debug('INVALID NUMBER: ====> ' + invalidSubscriber.mobileNumber + ' - ' + invalidSubscriber.validationErrorMessage);
                        failedNumbers.put(invalidSubscriber.mobileNumber, invalidSubscriber.validationErrorMessage);
                    }
                }

                checkDelivery(tokenId);
            } else {
                SendException e = new SendException();
                String errMsg = '';
                for (String error : responseBean.errors) {
                    errMsg += error + '<br>\n';
                }
                e.setMessage(errMsg);
                throw e;
            }
        } catch (Exception e) {
            String errorMessage = e.getMessage() + ' ' + e.getStackTraceString();
            if (System.isFuture()) {
                System.debug('ERROR: ====> ' + errorMessage);
            } else {
                SendException se = new SendException();
                se.setMessage(errorMessage);
                throw se;
            }
        }
    }

    /**************************************************************************
     * validateMobileNumbers() validates the list of phone numbers
     * if it's invalid (null, empty or exceeds 250) the method throws an Exception
     **************************************************************************/
    private void validateMobileNumbers (List<String> mobileNumbers) {
        if (mobileNumbers == null || mobileNumbers.isEmpty()) {
            SendException e = new SendException();
            e.setMessage('Mobile numbers not specified');
            throw e;
        }

        if (mobileNumbers.size() > 250) {
            SendException e = new SendException();
            e.setMessage('Mobile number list size exceeds 250');
            throw e;
        }

        for (String mobileNumber : mobileNumbers) {
            if (String.isBlank(mobileNumber)) {
                SendException e = new SendException();
                e.setMessage('Specified phone list has invalid numbers');
                throw e;
            }
        }
    }

    /**************************************************************************
     * checkDelivery() checks delivery status of the Send request
     * specified by tokenId and returns its outbound message
     **************************************************************************/
    private void checkDelivery (String tokenId) {
        HttpRequest request = new HttpRequest();
        request.setTimeout(60000);
        request.setMethod('GET');
        request.setEndpoint(restURI + deliveryCheck + '/' + tokenId);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + accessToken);

        HttpResponse response = new Http().send(request);
        ResponseBean responseBean = (ResponseBean) JSON.deserialize(response.getBody(), ResponseBean.class);

        if (response.getStatusCode() == 200) {
            System.debug('DELIVERY STATUS: ====> ' + response.getBody());
        } else {
            SendException e = new SendException();
            String errMsg = '';
            for (String error : responseBean.errors) {
                errMsg += error + '<br>\n';
            }
            e.setMessage(errMsg);
            throw e;
        }
    }
}

