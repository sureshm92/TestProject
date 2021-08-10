@isTest
public with sharing class Mock_LLRHeventTriggerHandler implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[{"success":true,"rhId":"123456qwert","redoxId":"asdfg1234","statusCode":"200","message":"success"}]');
        response.setStatusCode(200);
        return response; 
    }
}