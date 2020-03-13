/**
 * Created by Dmitry Ivakhnenko on 11-Mar-20.
 */

@IsTest
private class Test_MCloudSMSSender {

    private class SMSServiceMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            if (request.getEndpoint() == 'callout:MCloudAuthorization') {
                response.setStatusCode(200);
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"accessToken": "dlfhoi58o58o3"}');
            } else {
                response.setStatusCode(202);
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"tokenId": "atwe462erg4", "errors": ["Error1", "Error2"]}');
            }
            return response;
        }
    }

    @IsTest
    static void testSendSMSPositive() {
        Test.setMock(HttpCalloutMock.class, new SMSServiceMock());
        List<String> mobileNumbers = new List<String>{'19111111111', '19222222222'};
        String message = 'Test SMS';

        try {
            MCloudSMSSender.getInstance().sendSMS(mobileNumbers, message);
        } catch (Exception e) {}
    }

    @IsTest
    static void testSendSMSEmptyNumbers() {
        List<String> mobileNumbers = new List<String>();
        String message = 'Test SMS';

        try {
            MCloudSMSSender.getInstance().sendSMS(mobileNumbers, message);
        } catch (Exception e) {}
    }

    @IsTest
    static void testSendSMSTooManyNumbers() {
        List<String> mobileNumbers = new List<String>();
        String message = 'Test SMS';

        for (Integer i = 0; i < 300; i++) mobileNumbers.add(String.valueOf(i));

        try {
            MCloudSMSSender.getInstance().sendSMS(mobileNumbers, message);
        } catch (Exception e) {}
    }

    @IsTest
    static void testSendSMSInvalidNumbers() {
        List<String> mobileNumbers = new List<String>{'19111111111', '', '19222222222'};
        String message = 'Test SMS';

        try {
            MCloudSMSSender.getInstance().sendSMS(mobileNumbers, message);
        } catch (Exception e) {}
    }
}