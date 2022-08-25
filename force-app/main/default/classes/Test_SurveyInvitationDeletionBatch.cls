@IsTest(SeeAllData=true)
public class Test_SurveyInvitationDeletionBatch {
    
    @IsTest
    static void testSurveyInvitationDel_False() {
        

        TestData.loadTestData();
        TestData testData = new TestData();
        Test.startTest();
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=testData.ctp.Id,Clinical_Trial_Profile_Name__c='test surveyInvt');
        insert studClTest;
        List<Survey> survey = [SELECT Id, Name FROM Survey WHERE ActiveVersionId != NULL LIMIT 1];
        if (survey.isEmpty())
            return;

        Id communityId = CommunityService.getCommunityId(null);
        List<SurveyInvitation> invitations = new List<SurveyInvitation>();
        invitations.add(
            SurveyService.getInstance()
                .generateInvitation(survey.get(0), null, 5, false, testData.pe.Id, communityId)
        );
        invitations.add(
            SurveyService.getInstance()
                .generateInvitation(survey.get(0), null, 10, false, testData.pe.Id, communityId)
        );
        invitations.add(
            SurveyService.getInstance()
                .generateInvitation(survey.get(0), null, 15, false, testData.pe.Id, communityId)
        );
        insert invitations;
        Database.executeBatch(new SurveyInvitationDeletionBatch(testData.ctp.Id,false),10);
        Test.stopTest();
        List<SurveyInvitation> survetInvLst=[SELECT Id from SurveyInvitation where Participant_Enrollment__c =:testData.pe.Id limit 10];
        System.assertEquals(3,survetInvLst.size());
    }
    @IsTest
    static void testSurveyInvitationDel_True() {
        

        TestData.loadTestData();
        TestData testData = new TestData();
        Test.startTest();
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=testData.ctp.Id,Clinical_Trial_Profile_Name__c='test surveyInvt');
        insert studClTest;
        List<Survey> survey = [SELECT Id, Name FROM Survey WHERE ActiveVersionId != NULL LIMIT 1];
        if (survey.isEmpty())
            return;

        Id communityId = CommunityService.getCommunityId(null);
        List<SurveyInvitation> invitations = new List<SurveyInvitation>();
        invitations.add(
            SurveyService.getInstance()
                .generateInvitation(survey.get(0), null, 5, false, testData.pe.Id, communityId)
        );
        insert invitations;
        Database.executeBatch(new SurveyInvitationDeletionBatch(testData.ctp.Id,true),10);
        Test.stopTest();
        List<SurveyInvitation> survetInvLst=[SELECT Id from SurveyInvitation where Participant_Enrollment__c =:testData.pe.Id limit 10];
        System.assertEquals(0,survetInvLst.size());
    }
}