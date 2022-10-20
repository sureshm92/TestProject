/**
 * Created by Nargiz Mamedova on 11/20/2019.
 */

@IsTest
private class Test_RemoteCall {
    public class TestedRemoteCall extends RemoteCall {
        public TestedRemoteCall() {
            this.endPointURL = 'https://th-apex-http-callout.herokuapp.com/animals';
            this.httpMethod = METHOD_POST;
            this.headersMap.putAll(
                new Map<String, String>{ 'Content-Type' => 'application/json;charset=UTF-8' }
            );
        }

        public override Type getType() {
            return TestedRemoteCall.class;
        }

        protected override String buildRequestBody() {
            return '{"name":"mighty moose"}';
        }

        protected override Object parseResponse(String responseBody) {
            return responseBody;
        }
    }

    @IsTest
    static void testBehavior() {
        TestedRemoteCall remoteCall = new TestedRemoteCall();
        Test.setMock(HttpCalloutMock.class, new RemoteCallHttpCalloutMock());

        Test.startTest();
        Object res = remoteCall.execute();
        String expectedValue = '{ "applicationId": "90a75d33b4fb4e2da5ef354fc063d572", "requestId": "03c61dd5-3846-4cfd-8a6d-b7a311967200", "result": [ { "toNumber": "+187893434", "status": { "deliveryStatus": "SUCCESSFUL", "statusCode": 200, "statusMessage": "MessageId: ut0ehaifvdfkcho0sqff41c6bkvh25oodcnb98g0", "messageId": "ut0ehaifvdfkcho0sqff41c6bkvh25oodcnb98g0" } } ] }';
        Test.stopTest();
        System.assertEquals(expectedValue, res);
    }
}
