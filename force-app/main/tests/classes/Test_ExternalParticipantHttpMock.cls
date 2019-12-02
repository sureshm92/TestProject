/**
 * Created by Slav on 21.08.2019.
 */

@IsTest
public class Test_ExternalParticipantHttpMock implements HttpCalloutMock {
    public Integer statusCode = 200;
    public Boolean returnEmpty = false;
    private HttpResponse response;
    
    public HttpResponse respond (HttpRequest request) {
        response = new HttpResponse();
        ExternalParticipantsService.ExternalParticipant ep = new ExternalParticipantsService.ExternalParticipant();
        ep.patientId        = 'patientId';
        ep.firstName        = 'firstName';
        ep.lastName         = 'lastName';
        ep.initials         = 'initials';
        ep.dob              = 'dob';
        ep.subjectId        = 'subjectId';
        ep.gender           = 'gender';
        ep.addressLine1     = 'addressLine1';
        ep.addressLine2     = 'addressLine2';
        ep.city             = 'city';
        ep.state            = 'state';
        ep.zipcode          = 'zipcode';
        ep.country          = 'country';
        ep.countryCode      = 'countryCode';
        ep.email            = 'email';
        ep.phone            = 'phone';
        ep.mobile           = 'mobile';
    
        if (returnEmpty) {
            response.setBody(JSON.serialize(new List<ExternalParticipantsService.ExternalParticipant>{
            }));
        } else {
            response.setBody(JSON.serialize(new List<ExternalParticipantsService.ExternalParticipant>{
                    ep
            }));
        }
        response.setStatus('OK');
        response.setStatusCode(statusCode);
        return response;
    }
}