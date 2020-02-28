/**
 * Created by Nargiz Mamedova on 12/3/2019.
 */

@IsTest
private class Test_ActionExecutor {

    @IsTest
    static void testBatch() {
        Test.startTest();
        Test_ActionSuccess testAction = new Test_ActionSuccess();
        Datetime testDatetime = Datetime.now().addDays(-1);

        ActionExecutor.executeAsync(testAction, testDatetime);
        Database.executeBatch(new Batch_ProcessAction());
        Test.stopTest();
    }

    @IsTest
    static void testExecuteAsyncAction() {
        Action_Execution_Setting__c settingWithType = new Action_Execution_Setting__c(
                Type__c = 'TestAction',
                Relaunch_Interval__c = 5,
                Repetitions_Count__c = 5,
                Remove_After_Complete__c = false
        );
        insert settingWithType;

        Test.startTest();
        Test_ActionSuccess testAction = new Test_ActionSuccess();
        ActionExecutor.executeAsync(testAction);
        Test.stopTest();
    }

    @IsTest
    static void testExecuteAsyncObject() {
        Action_Execution_Setting__c settingWithoutType = new Action_Execution_Setting__c(
                Relaunch_Interval__c = 5,
                Repetitions_Count__c = 5,
                Remove_After_Complete__c = true
        );
        insert settingWithoutType;

        Test.startTest();
        Datetime testDatetime = Datetime.now().addDays(-1);
        Test_ActionSuccess testAction = new Test_ActionSuccess();
        Action__c action = new Action__c(
                Type__c = testAction.getType().toString(),
                Body__c = JSON.serialize(testAction),
                Execution_Time__c = testDatetime
        );
        insert action;
        ActionExecutor.executeAsync(action);
        Test.stopTest();

        List<Action__c> result = [SELECT Id FROM Action__c WHERE Status__c =: ActionExecutor.ACTION_STATUS_COMPLETED];
        System.assertEquals(0, result.size());
    }

    @IsTest
    static void testExecuteAsyncActionException() {
        Test.startTest();
        Test_Action testAction = new Test_Action();
        ActionExecutor.executeAsync(testAction);
        Test.stopTest();
    }

    @IsTest
    static void testExecuteAsyncObjectException() {
        Test.startTest();
        Datetime testDatetime = Datetime.now().addDays(-1);
        Test_Action testAction = new Test_Action();
        Action__c action = new Action__c(
                Type__c = testAction.getType().toString(),
                Body__c = JSON.serialize(testAction),
                Execution_Time__c = testDatetime
        );
        insert action;
        ActionExecutor.executeAsync(action);
        Test.stopTest();
    }

    @IsTest
    static void testExecuteAsyncObjectExceptionLastRepetition() {
        Action_Execution_Setting__c settingWithoutType = new Action_Execution_Setting__c(
                Relaunch_Interval__c = 5,
                Repetitions_Count__c = 1,
                Remove_After_Complete__c = false
        );
        insert settingWithoutType;

        Test.startTest();
        Datetime testDatetime = Datetime.now().addDays(-1);
        Test_Action testAction = new Test_Action();
        Action__c action = new Action__c(
                Type__c = testAction.getType().toString(),
                Body__c = JSON.serialize(testAction),
                Execution_Time__c = testDatetime
        );
        insert action;
        ActionExecutor.executeAsync(action);

        List<Action__c> queriedAction = [SELECT Id FROM Action__c];
        ActionExecutor.executeAsync(queriedAction[0]);
        Test.stopTest();

        List<Action__c> result = [SELECT Id, Status__c FROM Action__c];
        System.assertEquals(ActionExecutor.ACTION_STATUS_FAILED, result[0].Status__c);
    }
}