@isTest
public class Test_Path {
    @isTest
    private static void getPath() {
        TestData.loadTestData();
        List<String> steps = new List<String>{ '1', '34', '45', '5' };
        String currentStep = '45';
        Test.startTest();
        Path.generatePath(steps, currentStep);
        Test.stopTest();
    }
}
