@IsTest
public class Test_IntegrationTrialMatchBatchDeletion {
	
    @TestSetup
    static void init() {
        TestData.loadTestData();
    }
    @IsTest
    static void testIntegrationTrialMatchBatchDel() {
        Test.startTest();
        List<Participant_Enrollment__c>  enrollLst = [select Id,Clinical_Trial_Profile__c,External_Key__c,Clinical_Trial_Profile__r.Protocol_ID__c from Participant_Enrollment__c limit 10];
        List<Integration_Trial_Match__c> intMatchLst= new List<Integration_Trial_Match__c>();
        for(Participant_Enrollment__c enroll: enrollLst){
            Integration_Trial_Match__c intTMatch= new Integration_Trial_Match__c();
            intTMatch.Participant_Enrollment_External_ID__c=enroll.External_Key__c;
            intTMatch.Protocol_ID__c=enroll.Clinical_Trial_Profile__r.Protocol_ID__c;
            intTMatch.Matching_Score__c=200;
			intMatchLst.add(intTMatch);       
        }
        insert intMatchLst;
        Database.executeBatch(new IntegrationTrialMatchBatchDeletion(enrollLst[0].Clinical_Trial_Profile__c),10);
        Test.stopTest();
        List<Integration_Trial_Match__c> intTrialMatchList=[SELECT Id from Integration_Trial_Match__c where Protocol_ID__c=:enrollLst[0].Clinical_Trial_Profile__r.Protocol_ID__c];
        System.assertEquals(0,intTrialMatchList.size());
    }
}