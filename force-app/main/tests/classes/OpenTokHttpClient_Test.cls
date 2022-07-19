@isTest
private class OpenTokHttpClient_Test {

    private static final String TEST_SESSION_ID = 'test-session-id';

    @isTest
    private static void createSessionSuccess() {
        TokBoxSettings2__c tokBoxSettings = TokBoxSettings2__c.getOrgDefaults();
        tokBoxSettings.API_Key__c = '12345678';
        tokBoxSettings.API_Secret__c = 'test';
        tokBoxSettings.API_URL__c = 'https://api.opentok.com';
        upsert tokBoxSettings;

        Test.setMock(HttpCalloutMock.class, new OpenTokHttpCalloutMock(TEST_SESSION_ID));

        Test.startTest();
        OpenTokHttpClient openTokClient = new OpenTokHttpClient(
            tokBoxSettings.API_URL__c,
            tokBoxSettings.API_Key__c,
            tokBoxSettings.API_Secret__c
        );

        String result = openTokClient.createSession();

        Test.stopTest();
        List<Object> response = (List<Object>)JSON.deserializeUntyped(result);
        System.assertEquals(TEST_SESSION_ID, ((Map<String, Object>)response[0]).get('session_id'));
    }

}