/**
 * Created by Slav on 21.08.2019.
 */

@IsTest
public class Test_ExternalParticipantRemote {

    @IsTest
    static void saveParticipantSuccessTest() {
        Test_ExternalParticipantHttpMock httpMock = new Test_ExternalParticipantHttpMock();
        Test.setMock(HttpCalloutMock.class, httpMock);

        ExternalParticipantsService.ExternalParticipant ep = ExternalParticipantRemote.init();
        ep.dob = '' + Date.newInstance(2019, 4, 2);
        ep.countryCode = 'USA';

        Test.startTest();
        ExternalParticipantRemote.saveParticipant(JSON.serialize(ep));
        Test.stopTest();
    }

    @IsTest
    static void saveParticipantFailTest() {
        Test_ExternalParticipantHttpMock httpMock = new Test_ExternalParticipantHttpMock();
        httpMock.statusCode = 500;
        Test.setMock(HttpCalloutMock.class, httpMock);

        ExternalParticipantsService.ExternalParticipant ep = ExternalParticipantRemote.init();
        Test.startTest();
        try {
            ExternalParticipantRemote.saveParticipant(JSON.serialize(ep));
        } catch (Exception e) {
            // expected Exception
        }
        Test.stopTest();
    }

    @IsTest
    static void getExternalParticipantsTest() {
        Test_ExternalParticipantHttpMock httpMock = new Test_ExternalParticipantHttpMock();
        Test.setMock(HttpCalloutMock.class, httpMock);

        ExternalParticipantsService.ExternalParticipant ep = ExternalParticipantRemote.init();
        Test.startTest();
        ExternalParticipantRemote.getExternalParticipants('patientId');
        Test.stopTest();
    }
}