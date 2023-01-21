/**
 * Created by Nargiz Mamedova on 12/3/2019.
 */
 
public with sharing class Batch_ProcessAction extends Batch_ScheduledAbstract implements Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime currentTime = System.now();
        return Database.getQueryLocator(
            [
                SELECT
                    Id,
                    Type__c,
                    Body__c,
                    Execution_Time__c,
                    (
                        SELECT Id, Error_Message__c, Stack_Trace__c, Is_Success__c
                        FROM Execution_Histories__r
                    )
                FROM Action__c
                WHERE
                    Status__c = :ActionExecutor.ACTION_STATUS_PENDING
                    AND Execution_Time__c <= :currentTime
                    AND DML_With_Setup_Objects__c = FALSE
            ]
        );
    }

    public override Type getType() {
        return Batch_ProcessAction.class;
    }

    public void execute(Database.BatchableContext bc, List<Object> dbActions) {
        System.debug('SCOPE SIZE: ' + dbActions.size());
        DMLService.useDMLBuffer(true);
        List<ActionExecutor.ExecutionResult> executionResults = new List<ActionExecutor.ExecutionResult>();
        for (Action__c dbAction : (List<Action__c>) dbActions) {
            executionResults.add(ActionExecutor.execute(dbAction));
        }
        DMLService.pushDMLBuffer();
        for (ActionExecutor.ExecutionResult executionResult : executionResults)
            executionResult.complete();
    }

    public override virtual String getBatchDescription() {
        return 'Execute pending execution actions';
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 5;
    }

    public override Integer getRecommendedScopeSize() {
        return 10;
    }
}
