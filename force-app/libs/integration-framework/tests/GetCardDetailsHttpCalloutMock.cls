/**
 * Created by Nargiz Mamedova on 1/20/2020.
 */

public with sharing class GetCardDetailsHttpCalloutMock implements HttpCalloutMock{
    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('# ["first_name": "Test",     "middle_name": "Test",     "last_name": "Smith",     "email": "john.smith@email.address",     "date_of_birth": "1985-08-25",     "uuid": "FBA06AC1D5DB46009782356371F96DD9",     "mobile_phone": 1231231234,     "home_phone": 3213214321,     "cards": [  {         "token": 12345678,         "balance": 45.53,         "status": "Active",         "assigned_date": "2019-01-01"       }]      ]');
        response.setStatusCode(200);
        return response;
    }
}