/**
 * Created by Slav on 22.08.2019.
 */

@IsTest
public class Test_HomePageParticipantRemote {

    @IsTest
    public static void runTest() {
        TestData.loadTestData();

        Test.startTest();
        System.runAs(new TestData().participantUser) {
            HomePageParticipantRemote.getInitData();
        }
        Test.stopTest();
    }
}