/**
 * Created by Nargiz Mamedova on 12/3/2019.
 */

public interface Action {

    void execute();
    Type getType();
    Boolean isDMLWithSetupObjects();
    void postDML(Action__c dbAction, Execution_History__c executionHistory);
}