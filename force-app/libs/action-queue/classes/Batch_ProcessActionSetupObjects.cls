/**
 * Created by Leonid Bartenev
 */ 

public without sharing class Batch_ProcessActionSetupObjects extends Batch_ScheduledAbstract {
    private List<Action__c> processedActions = new List<Action__c>();

    public Database.QueryLocator start(Database.BatchableContext param1) {
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
                    AND DML_With_Setup_Objects__c = TRUE
                ORDER BY CreatedDate ASC
            ]
        );
    }

    public override Type getType() {
        return Batch_ProcessActionSetupObjects.class;
    }

    public void execute(Database.BatchableContext bc, List<Object> actions) {
        for (Action__c actionObj : (List<Action__c>) actions) {
            Type actionType = Type.forName(actionObj.Type__c);
            Action action = (Action) JSON.deserialize(actionObj.Body__c, actionType);
            action.execute();
            processedActions.add(actionObj);
        }
    }

    public override virtual String getBatchDescription() {
        return 'Execute pending execution actions with DML operations on setup objects';
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 2;
    }

    public override Integer getRecommendedScopeSize() {
        return 10;
    }

    public override virtual void finalAction() {
        delete processedActions;
    }
}
