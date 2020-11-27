/**
 * Created by  Velu on 27-Aug-20.
 */

@IsTest
private class Test_Batch_UpdateScreeningIds {
    @IsTest
    static void testDataDoesNotExist() {
        Test.startTest();
        Batch_UpdateScreeningIds.run();
        Test.stopTest();
    }
}
