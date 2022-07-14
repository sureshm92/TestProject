@isTest
public with sharing class OpenTokHttpCalloutMock implements HttpCalloutMock {

    private String sessionId {get; set;}

    public OpenTokHttpCalloutMock(String sessionId) {
        this.sessionId = sessionId;
    }

    public HTTPResponse respond(HTTPRequest req) {
        List<Object> responsePayload = new List<Object>();

        responsePayload.add(new Map<String, Object>{ 
            'session_id' => sessionId, 
            'project_id' => 'ourAPIkey', 
            'create_dt' => Datetime.now()
        });
        
        String endpoint = req.getEndpoint();
        HttpResponse res = new HttpResponse();

        if (endpoint == 'https://api.opentok.com/session/create') {
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(responsePayload));
            res.setStatusCode(200);
        }

        return res;
    }
}