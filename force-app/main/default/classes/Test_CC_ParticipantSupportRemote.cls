@IsTest
public class Test_CC_ParticipantSupportRemote {
    @TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    
    @IsTest
    static void testfetchParticipantEnrollment() {
        TestData testData = new TestData();
        testData.participant.Phone__c ='123456789';
        string searchKey = '123456789';
        Test.startTest();
        CC_ParticipantSupportRemote.fetchParticipantEnrollment(searchKey);
        Test.stopTest();
    }
    
}