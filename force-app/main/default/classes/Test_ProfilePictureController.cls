@IsTest
public class Test_ProfilePictureController {
    @IsTest(seeAllData=true)
    public static void runTest() {
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SendDropOutEmailHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SetCurrentEnrollmentHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateUsersOrSendNotificationsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateWelcomeToStudyAlertHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.CreateNotificationHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdateNameOnPE.class);
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.ChangeUserEmailOnParticipantEmailChangeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.CreatePIOrSendNotificationHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            HCPEnrollmentTriggerHandler.CreateHCPUserOrSendNotificationHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
        );
        TestData.loadTestData();
        TestData testDataInstance = new TestData();

        Test.startTest();

        System.runAs(testDataInstance.participantUser) {
            ProfilePictureController.getProfilePicture(
                UserInfo.getUserId(),
                CommunityService.USER_MODE_PARTICIPANT
            );
            ProfilePictureController.saveAttachment(
                UserInfo.getUserId(),
                'some.jpg',
                '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',
                'image/jpeg'
            );
        }
        Test.StopTest();
    }
}
