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
        Boolean isStatusCode202 = false;
        try {
            MCloudSMSSender.getInstance().sendSMS(mobileNumbers, message);
        } catch (Exception e) {
            isStatusCode202 = e.getMessage().contains('Error1') ? true : false;
        }
        System.assertEquals(true, isStatusCode202);
    }

    @IsTest
    static void testSendSMSEmptyNumbers() {
        List<String> mobileNumbers = new List<String>();
        String message = 'Test SMS';
        Boolean isExceptionThrown = false;
        try {
            MCloudSMSSender.getInstance().sendSMS(mobileNumbers, message);
        } catch (Exception e) {
            isExceptionThrown = e.getMessage().contains('Mobile numbers not specified') ? true : false;
        }
        System.assertEquals(true, isExceptionThrown);
    }

    @IsTest
    static void testSendSMSTooManyNumbers() {
        List<String> mobileNumbers = new List<String>();
        String message = 'Test SMS';

        for (Integer i = 0; i < 300; i++) mobileNumbers.add(String.valueOf(i));
        Boolean isExceptionThrown = false;
        try {
            MCloudSMSSender.getInstance().sendSMS(mobileNumbers, message);
        } catch (Exception e) {
            isExceptionThrown = e.getMessage().contains('Mobile number list size exceeds 250') ? true : false;
        }
        System.assertEquals(true, isExceptionThrown);
    }

    @IsTest
    static void testSendSMSInvalidNumbers() {
        List<String> mobileNumbers = new List<String>{'19111111111', '', '19222222222'};
        String message = 'Test SMS';
        Boolean isExceptionThrown = false;
        try {
            MCloudSMSSender.getInstance().sendSMS(mobileNumbers, message);
        } catch (Exception e) {
            isExceptionThrown = e.getMessage().contains('Specified phone list has invalid numbers') ? true : false;
        }
        System.assertEquals(true, isExceptionThrown);
    }
}