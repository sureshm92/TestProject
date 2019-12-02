/**
 * Created by Nargiz Mamedova on 11/20/2019.
 */

public with sharing class RemoteCallHttpCalloutMock implements HttpCalloutMock{

    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"animals": ["majestic badger", "fluffy bunny", "scary bear", "chicken", "mighty moose"]}');
        response.setStatusCode(200);
        return response;
    }
}