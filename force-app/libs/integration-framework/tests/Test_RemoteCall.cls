/**
 * Created by Nargiz Mamedova on 11/20/2019.
 */

@IsTest
private class Test_RemoteCall {
    public class TestedRemoteCall extends RemoteCall {
        public TestedRemoteCall() {
            this.endPointURL = 'https://th-apex-http-callout.herokuapp.com/animals';
            this.httpMethod = METHOD_POST;
            this.headersMap.putAll(new Map<String, String>{
                    'Content-Type' => 'application/json;charset=UTF-8'
            });
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
        String expectedValue = '{"animals": ["majestic badger", "fluffy bunny", "scary bear", "chicken", "mighty moose"]}';
        Test.stopTest();
        System.assertEquals(expectedValue, res);
    }
}