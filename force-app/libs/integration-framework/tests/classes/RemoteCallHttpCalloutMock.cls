/**
 * Created by Nargiz Mamedova on 11/20/2019.
 */

public with sharing class RemoteCallHttpCalloutMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(
            '{ "applicationId": "90a75d33b4fb4e2da5ef354fc063d572", "requestId": "03c61dd5-3846-4cfd-8a6d-b7a311967200", "result": [ { "toNumber": "+187893434", "status": { "deliveryStatus": "SUCCESSFUL", "statusCode": 200, "statusMessage": "MessageId: ut0ehaifvdfkcho0sqff41c6bkvh25oodcnb98g0", "messageId": "ut0ehaifvdfkcho0sqff41c6bkvh25oodcnb98g0" } } ] }'
        );
        response.setStatusCode(200);
        return response;
    }
}
