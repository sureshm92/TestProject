/**
 * Created by Dmitry Velu on 27-Aug-20.
 */

@IsTest
private class Test_Batch_CreateParticipants  {

    @IsTest
    static void testDataDoesNotExist() {
        string post = 'Done';
        Test.startTest();
        Batch_CreateParticipants.run(1,post,1);
        Test.stopTest();
    }

}