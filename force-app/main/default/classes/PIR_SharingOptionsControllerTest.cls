@isTest
public with sharing class PIR_SharingOptionsControllerTest {
    @TestSetup
    static void init(){
        TestData.loadTestData();
    }

    @isTest static void testfetchParticipantData() {

        TestData testData = new TestData();
        Test.startTest();
        PIR_SharingOptionsController sharingOptions = new PIR_SharingOptionsController();
        PIR_SharingOptionsController.fetchParticipantData(testData.pe.Id);
        PIR_SharingOptionsController.fetchYearOfBirth();
        PIR_SharingOptionsController.getGenderLVList();
        PIR_SharingOptionsController.getpeData(testData.pe.Id,testData.participant.Id);
        PIR_SharingOptionsController.getHCPData(testData.pe.Id);
        Test.stopTest();

    }
}