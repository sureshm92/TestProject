@IsTest
public class Test_RemoteCall_getHumanAPIData {

    @IsTest
    static void testMethod1() {
        
          Test.setMock(HttpCalloutMock.class, new Test_HumanAPIMultipleCallout()); 
        RemoteCall_getHumanAPIData.getHumanSources('aa');
        
        
    }
}