/**
 * Created by Dmitry Ivakhnenko on 23-Mar-20.
 */

@IsTest
public class Test_ParticipantIRBCheckerRemote {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void testCheckLanguagePermissions() {
        Test.startTest();
        TestData testData = new TestData();

        System.runAs(testData.participantUser) {
            ParticipantIRBCheckerRemote.checkLanguagePermissions(testData.pe.Id);
        }
        Test.stopTest();
    }
}
