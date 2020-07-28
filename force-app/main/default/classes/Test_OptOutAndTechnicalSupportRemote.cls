/**
 * Created by Keyur Shah on 07.21.2020.
 */

@IsTest
private class Test_OptOutAndTechnicalSupportRemote {
    private static final String TECH_SUPPORT_QUEUE_NAME='Tech_Support_Case_Queue';
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @isTest
    private static void getOptoutAndTechnicalSupportData_test(){
        Test.startTest();
        List<OptOutAndTechnicalSupport.InitDataWrapper> intitDataWrapperList=OptOutAndTechnicalSupportRemote.getInitData('en_us');
        System.assert(intitDataWrapperList.size()>0);
        Test.stopTest();
    }
    @isTest
    private static void createSupportCases_test(){
        Test.startTest();
        TestData testData=new TestData();
        String strContactId=testData.piContact.Id;
        OptOutAndTechnicalSupportRemote.createSupportCases('I do not want to receive optional emails','I need addtional techincal support',strContactId);    
        List<Group> groupList=[SELECT Id FROM Group WHERE developerName=:TECH_SUPPORT_QUEUE_NAME];
        List<Case> caseList=[SELECT ID,ownerId From Case WHERE  OwnerId=:groupList[0].Id];
        System.assert(caseList.size()>0);
        Test.stopTest();
    }
}