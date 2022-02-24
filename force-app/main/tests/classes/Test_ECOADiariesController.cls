@isTest
private class Test_ECOADiariesController {
    static user thisUser;
    @testSetup
    static void setUp() {
        TestData.loadTestData();
        Clinical_Trial_Profile__c ctp = [
            SELECT id, Study_GUID__c
            FROM Clinical_Trial_Profile__c
            LIMIT 1
        ];
        ctp.Study_GUID__c = 'testguid123';
        update ctp;
    }

    @isTest
    static void ecoaTest() {
        Test.startTest();

        try {
            ECOADiariesController.getToken();
        } catch (Exception ex) {
            system.debug('line number:' + ex.getLineNumber());
        }
        try {
            ECOADiariesController.getSubjectGuid();
        } catch (Exception ex) {
            system.debug('line number:' + ex.getLineNumber());
        }
        Test.StopTest();
    }
}
