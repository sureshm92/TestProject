/**
 * Created by Igor Malyuta on 31.05.2019.
 */

public abstract class Batch_ScheduledAbstract implements Database.Batchable<SObject>, Database.Stateful{

    public abstract Type getType();

    public virtual void finish(Database.BatchableContext param1) {
        if(Test.isRunningTest()) return;
        List<Batch_Executor__mdt> batchExecutor = [
                SELECT Relaunch_Interval__c, Scope_Size__c
                FROM Batch_Executor__mdt
                WHERE DeveloperName = : getType().getName()
        ];
        if(!batchExecutor.isEmpty()) {
            Integer minutes = batchExecutor.get(0).Relaunch_Interval__c.intValue();
            Integer scopeSize = batchExecutor.get(0).Scope_Size__c.intValue();
            System.scheduleBatch(
                    (Database.Batchable<SObject>) getType().newInstance(), getType().getName(), minutes, scopeSize);
        }
    }

}