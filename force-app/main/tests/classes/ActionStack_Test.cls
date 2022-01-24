/**
* Created by Gaurav Saxena
*/
@isTest
public class ActionStack_Test {
    //private static Action action;
    
    static testmethod void test_1(){
        Test.startTest();
        Test_Action testAction = new Test_Action();
        ActionStack astack = new ActionStack();
        astack.add(testAction);
        astack.run();
        astack.add(testAction);
        astack.run();
        ActionChain achain = new ActionChain(testAction);
        //achain.next(testAction);
        System.enqueueJob(achain);
        Test.Stoptest(); 
    }
}