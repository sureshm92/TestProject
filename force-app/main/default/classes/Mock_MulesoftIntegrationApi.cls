@isTest
public with sharing class Mock_MulesoftIntegrationApi implements HttpCalloutMock {
    public static final String statusMessage = ''; 
    public HTTPResponse respond(HTTPRequest request) {
        HTTPResponse response = new HTTPResponse();
        if (request.getEndpoint().endsWith('callout:Test_Named_Credential')) {
            String jsonBody =
                '{'+
                '  "access_token":"test_token",'+
                '  "expires_in": 3600,' +
                '  "token_type": "Bearer"' +
                '}';
            response.setBody(jsonBody);
            response.setStatusCode(200);
            return response;
        }
        
        else if (request.getEndpoint().contains('callout:E_consent_create_participant')) {
            if (statusMessage == 'Success') {
                String jsonBody =
                    '['+
                    '{'+
                    '"statusCode": "200",'+
                    '"statusMessage": "Success",'+
                    '"studyId": "35696174-93D0-EC11-AAAD-0AFDAF45A89D",'+
                    '"siteId": "f3cb848f-93d0-ec11-aaad-0afdaf45a89d",'+
                    '"documentCollectionId": "1764e640-ccd3-ed11-aba2-125b9817a47b",'+
                    '"email": "jasika.kaur@iqvia.com",'+
                    '"externalKey": "ReferralHub",'+
                    '"externalId": "REF1036854",'+
                    '"participantId": "54d0a0ca-55ee-ed11-aba2-125b9817a47b",'+
                    '"consentingId": "0207",'+
                    '"subjectId": "REF1036854",'+
                    '"eConsentErrorCode": null,'+
                    '"eConsentErrorMessage": null,'+
                    '"errorType": null'+
                    '}'+
                    ']';
                response.setBody(jsonBody);
                response.setStatusCode(200);
            } else {
                String jsonBody =
                    '['+
                    '{'+
                    '"statusCode": 500,'+
                    '"statusMessage": "Failure",'+
                    '"studyId": "35696174-93D0-EC11-AAAD-0AFDAF45A89D",'+
                    '"siteId": "f3cb848f-93d0-ec11-aaad-0afdaf45a89d",'+
                    '"documentCollectionId": "1764e640-ccd3-ed11-aba2-125b9817a47b",'+
                    '"email": "jasika.kaur@iqvia.com",'+
                    '"externalKey": "ReferralHub",'+
                    '"externalId": "REF1036608",'+
                    '"participantId": null,'+
                    '"consentingId": null,'+
                    '"subjectId": "REF1036608",'+
                    '"errorType": "INTERNAL_SERVER_ERROR",'+
                    '"message": 5001,'+
                    '"eConsentErrorCode": 5001,'+
                    '"eConsentErrorMessage": "Unable to perform this operation, please contact administrator"'+
                    '}'+
                    ']';
                response.setBody(jsonBody);
                response.setStatusCode(500);
            }
            return response;
        } else if (request.getEndpoint().contains('callout:E_consent_document_collection')) {
            String jsonBody =
                '['+
                '{'+
                '"id": "2295b62c-d86a-eb11-aaab-0a72e79241c1",'+
                '"sponsor": "Sponsor_Name",'+
                '"protocolId": "Protocal_Id",'+
                '"protocolTitle": "Test Protocol",'+
                '"testOnly": false,'+
                '"statusId": "43208cc6-2889-4f4d-a3c8-dc9bba18b8f5",'+
                '"status": "Active"'+
                '}'+
                ']';
            response.setBody(jsonBody);
            response.setStatusCode(200);
            return response;
        }else {
            response.setStatusCode(400);
            return response;
        }
    }
}