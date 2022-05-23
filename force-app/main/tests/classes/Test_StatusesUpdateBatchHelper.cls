@IsTest
private class Test_StatusesUpdateBatchHelper {
    @testSetup
    static void setup() {
        TestData.loadTestData();
    }
    @IsTest
    static void testGetUpdateFromMap() {
        TestData testData = new TestData();

        Test.startTest();
        String status;
        String reason;
        StatusesUpdateBatchHelper.getUpdatedStatus(status, reason);
        StatusesUpdateBatchHelper.getUpdatedReason(status, reason);
        StatusesUpdateBatchHelper.getUpdatedNotes(status, reason);
        Test.stopTest();
    }
}
