/**
 * Created by user on 14-May-20.
 */
@IsTest(IsParallel=true)
public with sharing class Test_IncentivePlanConfigurationRemote {

    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        TestData.createIncentiveProgram();
        Test.stopTest();

    }

    @IsTest
    static void testGetIPWrap() {
        Test.startTest();
        List<IncentivePlanConfigurationRemote.IPWrapper> wrapper = IncentivePlanConfigurationRemote.getIPWrap();
        Test.stopTest();
        System.assert(wrapper != null);
    }
    @IsTest
    static void testCreateUpdateIncentivePlan() {
        String planName = 'TestPlan';
        IncentivePlanConfigurationRemote.IPWrapper task = new IncentivePlanConfigurationRemote.IPWrapper();
        task.taskName = 'TaskName';
        task.checkOn = true;
        task.checkIQVIA = true;
        task.points = 20;
        List<IncentivePlanConfigurationRemote.IPWrapper> tasks = new List<IncentivePlanConfigurationRemote.IPWrapper>();
        tasks.add(task);

        String tasksString = JSON.serialize(tasks);

        Test.startTest();
        String planId = IncentivePlanConfigurationRemote.createUpdateIncentivePlan(tasksString, planName);
        Test.stopTest();
        System.assert(planId != null);
    }
    @IsTest
    static void testCheckNamePlan() {
        String planName = 'Test IP1';
        Test.startTest();
        Boolean result = IncentivePlanConfigurationRemote.checkNamePlan(planName);
        Test.stopTest();
        System.assertEquals(true, result);
    }
    @IsTest
    static void testGetIncentiveProgramWrapper() {
        String planName = 'Test IP1';
        Incentive_Plan__c plan = [SELECT Id FROM Incentive_Plan__c WHERE Plan_Name__c = :planName];

        Test.startTest();
        List<IncentivePlanConfigurationRemote.IPWrapper> wrapper = IncentivePlanConfigurationRemote.getIncentiveProgramWrapper(plan.Id);
        Test.stopTest();
        System.assert(wrapper != null);
    }
}