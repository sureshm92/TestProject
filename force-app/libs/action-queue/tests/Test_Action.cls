/**
 * Created by Nargiz Mamedova on 12/4/2019.
 */

public with sharing class Test_Action implements Action{
    public class Test_ActionException extends Exception{}

    public void execute() {
        throw new Test_ActionException('Hello Exception');
    }

    public Type getType() {
        return Test_Action.class;
    }
    
    public Boolean isDMLWithSetupObjects() {
        return false;
    }
}