/**
 * Created by user on 14-May-20.
 */
@IsTest(IsParallel=true)
public with sharing class Test_IncentivePlanConfigurationRemote {

    @TestSetup
    static void init() {
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.CreateStatusHistoryHandler.class);
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.CreatePIOrSendNotificationHandler.class);
        TriggerHandlerExecutor.bypassHandler(HCPEnrollmentTriggerHandler.CreateHCPUserOrSendNotificationHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class);

        Test.startTest();
        TestData.loadTestData();
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

        TestData testDataInstance = new TestData();
        Test.startTest();
        String planId = IncentivePlanConfigurationRemote.createUpdateIncentivePlan(tasksString, planName, testDataInstance.ctp.Id);
        Test.stopTest();
        System.assert(planId != null);
    }

    @IsTest
    static void testCheckNamePlan() {
        String planName = 'TestPlanName';
        TestData testDataInstance = new TestData();
        Incentive_Plan__c plan = new Incentive_Plan__c(Plan_Name__c = planName, Clinical_Trial_Profile__c = testDataInstance.ctp.Id);
        insert plan;
        Test.startTest();
        Boolean result = IncentivePlanConfigurationRemote.checkNamePlan(planName);
        Test.stopTest();
        System.assertEquals(true, result);
    }

    @IsTest
    static void testGetIncentiveProgramWrapper() {
        String planName = 'TestPlanName';
        TestData testDataInstance = new TestData();
        Incentive_Plan__c plan = new Incentive_Plan__c(Plan_Name__c = planName, Clinical_Trial_Profile__c = testDataInstance.ctp.Id);
        insert plan;

        Incentive_Task_Catalog__mdt taskMdt = [SELECT Id, DeveloperName, Title_Label__c, Description_Label__c, Default_Number_of_Points__c FROM Incentive_Task_Catalog__mdt LIMIT 1];

        Incentive_Plan_Task__c newTask = new Incentive_Plan_Task__c(Incentive_Plan__c = plan.Id, Incentive_Task_Catalog__c = taskMdt.DeveloperName, Points__c = 15,
                Enabled__c = true, IQVIA_Supported__c = true);
        insert newTask;

        Test.startTest();
        List<IncentivePlanConfigurationRemote.IPWrapper> wrapper = IncentivePlanConfigurationRemote.getIncentiveProgramWrapper(plan.Id);
        Test.stopTest();
        System.assert(wrapper != null);
    }

}