/**
 * Created by Slav on 22.08.2019.
 */

@IsTest
public class Test_HomePageParticipantRemote {

    @IsTest
    public static void runTest() {
        TestData.loadTestData();
        TestData testDataInstance = new TestData();
        
        try {
            HomePageParticipantRemote.getInitData();
        } catch (Exception e) {
            // expected Exception
        }

        System.runAs(testDataInstance.participantUser) {
            HomePageParticipantRemote.getInitData();
        }
    }
    
}