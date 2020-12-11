@IsTest
public class Test_InitialWireFrameController {
    
    @TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    
      @IsTest
    public static void runTest() {
        TestData tstData = new TestData();
        Test.startTest();
        System.runAs(tstData.participantUser) {
        InitialWireFrameController initialWireFrame =new InitialWireFrameController();
        initialWireFrame.recordId= tstData.participantUser.Id;   
        initialWireFrame.getUserMode();
        initialWireFrame.getBTNLabel();
        initialWireFrame.getSpecificProvider();
        initialWireFrame.getSourceId();
        initialWireFrame.getStudySiteType();
        initialWireFrame.getTitleLabel();
        }
    }

}