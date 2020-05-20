/**
 * Created by Andrii Kryvolap.
 */

@IsTest(IsParallel=false)
private class Test_IncentiveProgram {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        TestData.createIncentiveProgram();
        Test.stopTest();

    }
    @IsTest
    static void createCompletedTask() {
        TestData testDataInstance = new TestData();
        Test.startTest();
        System.runAs(testDataInstance.piUser) {
            IncentiveProgramService.completeIncentiveTaskCurrentContact(IncentiveTaskCatalog.INCENTIVE_TASK_PRE_SCREENING, testDataInstance.ss.Id, testDataInstance.pe.Name);
            System.assertEquals(1, [SELECT Id FROM Completed_Incentive_Task__c].size());
        }
        Test.stopTest();
    }
    @IsTest
    static void getCurrentPoints() {
        TestData testDataInstance = new TestData();
        Test.startTest();
        System.runAs(testDataInstance.piUser) {
            IncentiveProgramService.completeIncentiveTaskCurrentContact(IncentiveTaskCatalog.INCENTIVE_TASK_PRE_SCREENING, testDataInstance.ss.Id, testDataInstance.pe.Name);
            IncentiveProgramService.PointsResultWrapper result = IncentiveProgramRemote.getCurrentPoints(Datetime.now());
            System.assertEquals(0, result.lastPoints);
            System.assertEquals(15, result.totalPoints);
        }
        Test.stopTest();
    }
    @IsTest
    static void getHistory() {
        TestData testDataInstance = new TestData();
        Test.startTest();
        System.runAs(testDataInstance.piUser) {
            IncentiveProgramService.completeIncentiveTaskCurrentContact(IncentiveTaskCatalog.INCENTIVE_TASK_PRE_SCREENING, testDataInstance.ss.Id, testDataInstance.pe.Name);
            IncentiveProgramService.IncentiveHistoryWrapper result = IncentiveProgramRemote.getIncentiveHistory();
            System.assertEquals(1, result.completedTasks.size());
            System.assertEquals(15, result.totalPoints);
        }
        Test.stopTest();
    }
    @IsTest
    static void getPlanForSS() {
        TestData testDataInstance = new TestData();
        Test.startTest();
        System.runAs(testDataInstance.piUser) {
            IncentiveProgramService.IncentivePlanResultWrapper result = IncentiveProgramRemote.getIncentivePlanResultWrapperForStudySite(testDataInstance.ss.Id);
            System.assertEquals(1, result.tasksGroups.size());
        }
        Test.stopTest();
    }
    @IsTest
    static void getPlanInitial() {
        TestData testDataInstance = new TestData();
        Test.startTest();
        System.runAs(testDataInstance.piUser) {
            IncentiveProgramService.IncentivePlanResultWrapper result = IncentiveProgramRemote.getInitialIncentivePlanResultWrapper();
            System.assertEquals(1, result.tasksGroups.size());
        }
        Test.stopTest();
    }

}