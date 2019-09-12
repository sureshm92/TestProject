/**
 * Created by Slav on 21.08.2019.
 */

@IsTest
public class Test_ExternalParticipantRemote {

    @IsTest
    public static void runTest() {
        Test_ExternalParticipantHttpMock httpMock = new Test_ExternalParticipantHttpMock();
        Test.setMock(HttpCalloutMock.class, httpMock);			// set mock for HTTP callouts

        ExternalParticipantsService.ExternalParticipant ep = ExternalParticipantRemote.init();

        ep.dob = Date.today() + '';
        ExternalParticipantRemote.saveParticipant(JSON.serialize(ep));
        
        httpMock.statusCode = 500;
        try {
            ExternalParticipantRemote.saveParticipant(JSON.serialize(ep));
        } catch (Exception e) {
            // expected Exception
        }
    
        httpMock.statusCode = 200;

        ep.dob = '' + Date.newInstance(2019, 4, 2);
        ep.countryCode = 'USA';
        ExternalParticipantRemote.saveParticipant(JSON.serialize(ep));
    
        httpMock.returnEmpty = true;
        ExternalParticipantRemote.saveParticipant(JSON.serialize(ep));
    
        ExternalParticipantRemote.getExternalParticipants('patientId');
    }
}