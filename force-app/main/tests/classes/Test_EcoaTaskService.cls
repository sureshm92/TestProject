@IsTest
public  class Test_EcoaTaskService {
    @IsTest
    static void createTask() {
        TestData.loadTestData();
        Test.startTest();
        List<Ecoa_Task_Configuration__c> taskConfig = new List<Ecoa_Task_Configuration__c>();
        EcoaTaskService.createTask(taskConfig);
        Test.stopTest();
}
}public with sharing class Test_EcoaTaskService {
    public Test_EcoaTaskService() {

    }
}
