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
        InitialWireframeController initialWireFrame =new InitialWireframeController();
        initialWireFrame.getUserMode();
        initialWireFrame.getBTNLabel();
        initialWireFrame.getSpecificProvider();
        initialWireFrame.getSourceId();
        initialWireFrame.getStudySiteType();
    }
}