@isTest
public class Test_Batch_UpdateInviteToPPDateOneTime {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    
    @IsTest
    static void getMaxLength(){
    	        Test.startTest();
        DataBase.executeBatch(new Batch_UpdateInviteToPPDateOneTime());
        Test.stopTest();	    
    }    
}