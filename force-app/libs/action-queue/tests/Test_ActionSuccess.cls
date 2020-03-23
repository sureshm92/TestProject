/**
 * Created by Nargiz Mamedova on 12/4/2019.
 */

public with sharing class Test_ActionSuccess implements Action{

    public void execute() {
        System.debug('Success!');
    }

    public Type getType() {
        return Test_ActionSuccess.class;
    }
    
    public Boolean isDMLWithSetupObjects() {
        return false;
    }
    
    public void postDML(Action__c dbAction, Execution_History__c executionHistory){
    
    }

}