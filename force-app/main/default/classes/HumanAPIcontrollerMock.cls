@IsTest
public with sharing class HumanAPIcontrollerMock implements HttpCalloutMock {

  public HttpResponse respond(HttpRequest request) {
    HttpResponse response = new HttpResponse();
    if (request.getEndpoint().endsWith('callout:HumanAPI_Connect')) {
      String jsonBody =
        '{' +
        '  "access_token": "test_token",' +
        '  "expires_in": 86400,' +
        '  "token_type": "Bearer",' +
        '  "refresh_token": "test_refresh_token"' +
        '}';
      response.setBody(jsonBody);
      response.setStatusCode(200);
      return response;
    } else if (request.getEndpoint().endsWith('callout:HumanAPI_Sources')) {
      String jsonBody =
        '[' +
        '  {' +
        '    "id": "614d78467ab14207db7356d2",' +
        '    "source": "601880fc90ad299ccc7257bc",' +
        '    "supportedDataTypes": [],' +
        '    "sourceName": "Starfleet Labs",' +
        '    "connectedSince": "2021-09-24T07:03:34.347Z",' +
        '    "expectedSyncDuration": 5,' +
        '    "devices": [' +
        '      "601880fc90ad299ccc7257bc"' +
        '    ],' +
        '    "syncStatus": {' +
        '      "status": "ok",' +
        '      "details": "ok",' +
        '      "synchedAt": "2021-09-24T07:04:19.224Z"' +
        '    },' +
        '    "historySync": {' +
        '      "status": "completed"' +
        '    },' +
        '    "organization": {' +
        '      "id": "601880fc90ad299ccc7257bc",' +
        '      "name": "Starfleet Labs",' +
        '      "href": "/medical/organizations/601880fc90ad299ccc7257bc"' +
        '    },' +
        '    "resync": {' +
        '      "active": true' +
        '    }' +
        '  },' +
        '  {' +
        '    "id": "614d79c27ab1424c7a7356d3",' +
        '    "source": "55a83bdc8d1eb1420aa1a71b",' +
        '    "supportedDataTypes": [],' +
        '    "sourceName": "Starfleet Medical",' +
        '    "connectedSince": "2021-09-24T07:09:54.796Z",' +
        '    "expectedSyncDuration": 5,' +
        '    "devices": [' +
        '      "55a83bdc8d1eb1420aa1a71b"' +
        '    ],' +
        '    "syncStatus": {' +
        '      "status": "ok",' +
        '      "details": "ok",' +
        '      "synchedAt": "2021-09-24T07:10:43.964Z"' +
        '    },' +
        '    "historySync": {' +
        '      "status": "completed"' +
        '    },' +
        '    "organization": {' +
        '      "id": "55a83bdc8d1eb1420aa1a71b",' +
        '      "name": "Starfleet Medical",' +
        '      "href": "/medical/organizations/55a83bdc8d1eb1420aa1a71b"' +
        '    },' +
        '    "resync": {' +
        '      "active": true' +
        '    }' +
        '  }' +
        ']';
      response.setBody(jsonBody);
      response.setStatusCode(200);
      return response;
    } else if (request.getEndpoint().endsWith('callout:HumanAPI_ReportList')) {
      String jsonBody =
        '[' +
        '  {' +
        '    "id": "614d788027b8560012f5211c-000000-000000000000000000000000",' +
        '    "createdAt": "2021-09-24T07:04:32.314Z",' +
        '    "updatedAt": "2021-09-24T07:11:05.020Z",' +
        '    "name": "apidata"' +
        '  },' +
        '  {' +
        '    "id": "614d788027b8560012f5211c-000003-601880fc90ad299ccc7257bc",' +
        '    "createdAt": "2021-09-24T07:04:32.314Z",' +
        '    "updatedAt": "2021-09-24T07:11:05.020Z",' +
        '    "name": "unity",' +
        '    "organization": {' +
        '      "id": "601880fc90ad299ccc7257bc",' +
        '      "href": "/medical/organizations/601880fc90ad299ccc7257bc"' +
        '    }' +
        '  },' +
        '  {' +
        '    "id": "614d788027b8560012f5211c-000003-55a83bdc8d1eb1420aa1a71b",' +
        '    "createdAt": "2021-09-24T07:04:32.314Z",' +
        '    "updatedAt": "2021-09-24T07:11:05.020Z",' +
        '    "name": "unity",' +
        '    "organization": {' +
        '      "id": "55a83bdc8d1eb1420aa1a71b",' +
        '      "href": "/medical/organizations/55a83bdc8d1eb1420aa1a71b"' +
        '    }' +
        '  },' +
        '  {' +
        '    "id": "614d788027b8560012f5211c-000004-000000000000000000000000",' +
        '    "createdAt": "2021-09-24T07:04:32.314Z",' +
        '    "updatedAt": "2021-09-24T07:11:05.020Z",' +
        '    "name": "timeline"' +
        '  },' +
        '  {' +
        '    "id": "614d788027b8560012f5211c-000005-000000000000000000000000",' +
        '    "createdAt": "2021-09-24T07:04:32.314Z",' +
        '    "updatedAt": "2021-09-24T07:11:05.020Z",' +
        '    "name": "healthcheck"' +
        '  },' +
        '  {' +
        '    "id": "614d788027b8560012f5211c-000006-000000000000000000000000",' +
        '    "createdAt": "2021-09-24T07:04:32.314Z",' +
        '    "updatedAt": "2021-09-24T07:11:05.020Z",' +
        '    "name": "highlights"' +
        '  },' +
        '  {' +
        '    "id": "614d788027b8560012f5211c-000007-601880fc90ad299ccc7257bc",' +
        '    "createdAt": "2021-09-24T07:04:32.314Z",' +
        '    "updatedAt": "2021-09-24T07:11:05.020Z",' +
        '    "name": "uber",' +
        '    "organization": {' +
        '      "id": "601880fc90ad299ccc7257bc",' +
        '      "href": "/medical/organizations/601880fc90ad299ccc7257bc"' +
        '    }' +
        '  },' +
        '  {' +
        '    "id": "614d788027b8560012f5211c-000007-55a83bdc8d1eb1420aa1a71b",' +
        '    "createdAt": "2021-09-24T07:04:32.314Z",' +
        '    "updatedAt": "2021-09-24T07:11:05.020Z",' +
        '    "name": "uber",' +
        '    "organization": {' +
        '      "id": "55a83bdc8d1eb1420aa1a71b",' +
        '      "href": "/medical/organizations/55a83bdc8d1eb1420aa1a71b"' +
        '    }' +
        '  },' +
        '  {' +
        '    "id": "614d788027b8560012f5211c-000008-000000000000000000000000",' +
        '    "createdAt": "2021-09-24T07:04:32.314Z",' +
        '    "updatedAt": "2021-09-24T07:11:05.020Z",' +
        '    "name": "covid"' +
        '  },' +
        '  {' +
        '    "id": "614d7881b29adc00126aeea2-000001-601880fc90ad299ccc7257bc",' +
        '    "createdAt": "2021-09-24T07:04:33.774Z",' +
        '    "name": "ccdraw",' +
        '    "organization": {' +
        '      "id": "601880fc90ad299ccc7257bc",' +
        '      "href": "/medical/organizations/601880fc90ad299ccc7257bc"' +
        '    },' +
        '    "skipped": true' +
        '  },' +
        '  {' +
        '    "id": "614d7a0ab29adc00126aeea4-000001-55a83bdc8d1eb1420aa1a71b",' +
        '    "createdAt": "2021-09-24T07:11:06.150Z",' +
        '    "name": "ccdraw",' +
        '    "organization": {' +
        '      "id": "55a83bdc8d1eb1420aa1a71b",' +
        '      "href": "/medical/organizations/55a83bdc8d1eb1420aa1a71b"' +
        '    },' +
        '    "skipped": true' +
        '  }' +
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
