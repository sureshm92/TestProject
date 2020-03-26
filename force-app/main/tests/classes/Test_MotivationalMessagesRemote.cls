/**
 * Created by Leonid Bartenev
 */

@IsTest(IsParallel=false)
private class Test_MotivationalMessagesRemote {
    
    @IsTest
    static void test1() {
        TestData.loadTestData();
        TestData testDataInstance = new TestData();
        testDataInstance.updatePEStatusEnrollmentSuccess();

        Clinical_Trial_Profile__c ctp = [SELECT Id FROM Clinical_Trial_Profile__c];
        Participant_Enrollment_Status_History__c peHistory = new Participant_Enrollment_Status_History__c(
                Date__c = Date.today(),
                ParticipantEnrollment__c = testDataInstance.pe.Id,
                Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS
        );
        insert peHistory;
        List<Motivational_Message__c> motivationalMessages = new List<Motivational_Message__c>{
                new Motivational_Message__c(
                        Number_of_Days_Active_after_Enrollment__c = 0,
                        Clinical_Trial_Profile__c = ctp.Id,
                        Message__c = 'Message 1'),
                new Motivational_Message__c(
                        Number_of_Days_Active_after_Enrollment__c = 0,
                        Clinical_Trial_Profile__c = ctp.Id,
                        Message__c = 'Message 2')
        };
        insert motivationalMessages;
        Test.startTest();
        String message;
        System.runAs(testDataInstance.participantUser){
            message = MotivationalMessagesRemote.getMotivationalMessage(CommunityService.USER_MODE_PARTICIPANT);
        }
        Test.stopTest();

        System.assertEquals('Message 2', message);
    }
}