/**
 * Created by Igor Malyuta on 04.10.2019.
 */

@IsTest
public class Test_Batch_CreateSurveyTasks {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @IsTest
    static void testBehavior() {
        
        TestData testData = new TestData();
        User delegateUser = testData.createPatientDelegate();
        insert delegateUser;
		
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

        Map<Id, String> invitationsVisible = new Map<Id, String>{
            invitations[0].Id => SurveyService.SURVEY_RESPONSE_PATIENT_ONLY,
            invitations[1].Id => SurveyService.SURVEY_RESPONSE_EACH_DELEGATE,
            invitations[2].Id => SurveyService.SURVEY_RESPONSE_PATIENT_EACH_DELEGATE
        };

        Batch_CreateSurveyTasks.launch(invitationsVisible);

        Integer numberOfCreatedTasks = 0;
        List<Task> tasks = [
            SELECT Id, Description, Survey_Invitation__c
            FROM Task
            WHERE
                Task_Type__c = 'Survey'
                AND CreatedDate = TODAY
                AND CreatedById = :UserInfo.getUserId()
        ];
        Set<Id> invitationIds = invitationsVisible.keySet();
        for (Task t : tasks) {
            if (
                (t.Survey_Invitation__c != null &&
                invitationIds.contains(t.Survey_Invitation__c)) ||
                (t.Description != null && invitationIds.contains(t.Description))
            ) {
                numberOfCreatedTasks++;
            }
        }
        System.assertEquals(4, numberOfCreatedTasks);

        List<Id> taskIds = Batch_CreateSurveyTasks.countFailedTask(invitationsVisible);
        System.assertEquals(4, taskIds.size());
    }
}