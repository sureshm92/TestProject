@isTest
public class Test_Injector {
    @isTest
    private static void testComponentName() {
        TestData.loadTestData();
        Test.startTest();
        Injector.getBindingsByNames('Aura');
        Test.stopTest();
    }
}
