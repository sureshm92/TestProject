global class DPicklistCMPwithRTAndMSPCalloutMock implements HttpCalloutMock{

    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"values":[{ "label":"Warm" },{ "value" : "Cold" }]}');
        res.setStatusCode(200);
        return res;
    }
}