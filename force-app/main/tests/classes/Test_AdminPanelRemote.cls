/**
 * Created by Igor Malyuta on 13.06.2019.
 */

@IsTest
private class Test_AdminPanelRemote {

    @IsTest
    static void runBatchTest() {
        List<Batch_Executor__mdt> batchExecutors = [
                SELECT Id, Label, DeveloperName, Relaunch_Interval__c
                FROM Batch_Executor__mdt
        ];
        if(!batchExecutors.isEmpty()) AdminPanelRemote.runBatch(batchExecutors.get(0).DeveloperName);
    }

    @IsTest
    static void stopBatchTest() {
        List<Batch_Executor__mdt> batchExecutors = [
                SELECT Id, Label, DeveloperName, Relaunch_Interval__c
                FROM Batch_Executor__mdt
        ];
        if(!batchExecutors.isEmpty()) AdminPanelRemote.stopBatch(batchExecutors.get(0).DeveloperName);
    }

    @IsTest
    static void getStateTest() {
        List<Batch_Executor__mdt> batchExecutors = [
                SELECT Id, Label, DeveloperName, Relaunch_Interval__c
                FROM Batch_Executor__mdt
        ];
        if(!batchExecutors.isEmpty()) AdminPanelRemote.getState(batchExecutors.get(0).DeveloperName);
    }
}