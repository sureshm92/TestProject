@isTest
public class Test_FindCommunityName {
    
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        TestData.createTCAcceptance();
        Test.stopTest();
    }
    
    @isTest
    public static void test1(){
        
        TestData testData = new TestData();
        
        Test.startTest();
        //init();
        System.runAs(testData.piUser) {
            try{
                 system.debug(FindCommunityName.getcommunityName());
            }catch(Exception e){
                system.debug('Catch Block');
            }
           
        }
        Test.stopTest();
        
    }
    
}