/**
 * Created by Igor Malyuta on 04.10.2019.
 */

@IsTest(SeeAllData = true)
private class Test_Batch_CreateSurveyTasks {

    @IsTest
    static void testBehavior() {
        TestData.loadTestData();
        TestData testData = new TestData();

        Test.startTest();
        List<Survey> survey = [SELECT Id, Name FROM Survey WHERE ActiveVersionId != NULL LIMIT 1];
        if (survey.isEmpty()) return;

        Id communityId = CommunityService.getCommunityId(null);
        SurveyInvitation invitation = SurveyService.getInstance().generateInvitation(
                survey.get(0),
                null,
                5,
                false,
                testData.pe.Id,
                communityId
        );
        insert invitation;
        Map<Id, String> invitationsVisible = new Map<Id, String>{
                invitation.Id => SurveyService.SURVEY_RESPONSE_PATIENT_ONLY
        };

        Batch_CreateSurveyTasks.launch(invitationsVisible);
        Test.stopTest();

        Boolean isTaskExist = false;
        List<Task> tasks = [
                SELECT Id, Description, Survey_Invitation__c
                FROM Task
                WHERE Task_Type__c = 'Survey'
                AND CreatedDate = TODAY
                AND CreatedById =: UserInfo.getUserId()
        ];
        for(Task t : tasks) {
            if((t.Survey_Invitation__c != null && t.Survey_Invitation__c == invitation.Id) ||
                    (t.Description != null && t.Description.equals(invitation.Id))) {
                isTaskExist = true;
                break;
            }
        }
        System.assert(isTaskExist);
    }
}