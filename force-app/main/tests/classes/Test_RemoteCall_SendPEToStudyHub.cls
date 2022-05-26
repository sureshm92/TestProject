@isTest
public class Test_RemoteCall_SendPEToStudyHub {
	@TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        TestData.createTCAcceptance();
        Test.stopTest();
    }
    @isTest
    Public Static Void Test_RemoteCall_SendPEToStudyHubMethod(){
        TestData testData = new TestData();
        Study_Site__c studySite = new Study_Site__c();
        studySite.Id = testData.ss.Id;
        studySite.Study_Site_Type__c = 'Virtual';
        update studySite;
        RemoteCall_SendPEToStudyHub req = new RemoteCall_SendPEToStudyHub(testData.pe.Id);
        req.getType();
		req.buildRequestBody();
        req.parseResponse('responseBody');
    }
    @isTest
    Public Static Void Test_RemoteCall_SendPEToStudyHubMethod1(){
        TestData testData = new TestData();
        RemoteCall_SendPEToStudyHub req = new RemoteCall_SendPEToStudyHub(testData.pe.Id);
        req.getType();
		req.buildRequestBody();
    }
}