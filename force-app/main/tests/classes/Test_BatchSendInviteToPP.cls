@isTest
public class Test_BatchSendInviteToPP {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @isTest
    private static void BatchSendInviteToPP() {
        TestData testData = new TestData();
        testData.createPatientDelegate();
        Test.startTest();
        Id ctpId = testData.ctp.Id;
        List<Id> participantIds = new List<Id>();
        List<Id> delegateParticipantIds = new List<Id>();
        DataBase.executeBatch(
            new BatchSendInviteToPP(
                new List<Id>{ testData.participant.Id },
                ctpId,
                new List<Id>{ testData.participant.Id }
            )
        );
        Test.stopTest();
    }
}
