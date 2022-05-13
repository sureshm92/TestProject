@isTest
public class Test_Injector {
    @isTest
    private static void testComponentName() {
        TestData.loadTestData();
        Test.startTest();
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.CreatePIOrSendNotificationHandler.class
        );
        Injector.getBindingsByNames('Aura');
        Injector.getComponentName('ResourceContainer');
        Test.stopTest();
    }
}
