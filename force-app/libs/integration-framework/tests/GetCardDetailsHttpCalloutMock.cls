/**
 * Created by Nargiz Mamedova on 1/20/2020.
 */

public with sharing class GetCardDetailsHttpCalloutMock implements HttpCalloutMock{
    public  integer rescode;
    public  GetCardDetailsHttpCalloutMock  (Integer in_rescode){
        rescode=in_rescode;
    }
    public  GetCardDetailsHttpCalloutMock (integer rescode){
    this.rescode= rescode;
    }
    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[{"balance": 3053.47, "status": "active"},{"balance": 747.42, "status": "replaced"}]');
        response.setStatusCode(200);
       if (rescode==null){
           rescode=200;
       }else{
           response.setStatus('Internal Server Error');
       }

        response.setStatusCode(rescode);
        return response;
    }
}