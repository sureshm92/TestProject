/**
 * Created by  Velu on 27-Aug-20.
 */

@IsTest
private class Test_Batch_SetDefaultPermissionSets  {

    @IsTest
    static void testDataDoesNotExist() {
        Test.startTest();
        Batch_SetDefaultPermissionSets.run();
        Test.stopTest();
    }

}