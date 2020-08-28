/**
 * Created by  Velu on 27-Aug-20.
 */

@IsTest
private class Test_Batch_SetPermissionGroupByProfile  {

    @IsTest
    static void testDataDoesNotExist() {
        Test.startTest();
        Batch_SetPermissionGroupByProfile.run();
        Test.stopTest();
    }

}