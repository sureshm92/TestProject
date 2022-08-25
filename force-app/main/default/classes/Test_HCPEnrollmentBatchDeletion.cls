@IsTest
public class Test_HCPEnrollmentBatchDeletion {
	@TestSetup
    static void init(){
        TestData.loadTestData();
    }
    @IsTest
    static void testHCPEnBatchDeletionStudyDel_False() { 
        List<Study_Site__c> testStudySites = [SELECT Id,Clinical_Trial_Profile__c,Site__c FROM Study_Site__c Limit 1];
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=testStudySites[0].Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test HCP');
        insert studClTest;
        List<HCP_Enrollment__c> hclLstbefore=[SELECT Id, Name from HCP_Enrollment__c where Clinical_Trial_Profile__c=:testStudySites[0].Clinical_Trial_Profile__c];
        Test.startTest();
		Database.executeBatch(new HCPEnrollmentBatchDeletion(testStudySites[0].Clinical_Trial_Profile__c,false),100);
        Test.stopTest();
        List<HCP_Enrollment__c> hclLst=[SELECT Id, Name from HCP_Enrollment__c where Clinical_Trial_Profile__c=:testStudySites[0].Clinical_Trial_Profile__c];
        System.assertEquals(hclLstbefore.size(),hclLst.size());
    }
    @IsTest
    static void testHCPEnBatchDeletionStudyDel_True() { 
        List<Study_Site__c> testStudySites = [SELECT Id,Clinical_Trial_Profile__c,Site__c FROM Study_Site__c Limit 1];
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=testStudySites[0].Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test HCP');
        insert studClTest;
        List<HCP_Enrollment__c> hclLstbefore=[SELECT Id, Name from HCP_Enrollment__c where Clinical_Trial_Profile__c=:testStudySites[0].Clinical_Trial_Profile__c];
        Test.startTest();
		Database.executeBatch(new HCPEnrollmentBatchDeletion(testStudySites[0].Clinical_Trial_Profile__c,true),100);
        Test.stopTest();
        List<HCP_Enrollment__c> hclLst=[SELECT Id, Name from HCP_Enrollment__c where Clinical_Trial_Profile__c=:testStudySites[0].Clinical_Trial_Profile__c];
        System.assertEquals(0,hclLst.size());
    }
}