/**
 * Created by Leonid Bartenev
 */

@IsTest(IsParallel=false)
private class Test_MotivationalMessagesRemote {
    @IsTest
    static void test1() {
        TestData.loadTestData();
        Test.startTest();
        TestData testDataInstance = new TestData();
        testDataInstance.updatePEStatusEnrollmentSuccess();
        User delegateUser = testDataInstance.createPatientDelegate();
        Contact con = [SELECT Id, userCommunityDelegateId__c FROM Contact Where Id =: delegateUser.ContactId];
        Patient_Delegate__c pd = [SELECT Id FROM Patient_Delegate__c Where Contact__c =: con.Id];
        Patient_delegate_enrollment__c patientDelEnrollment =new Patient_delegate_enrollment__c(
            Participant_Enrollment__c = testDataInstance.pe.Id,
            Patient_Delegate__c= pd.id,
            Study_Email_Consent__c=true,
            Study_SMS_Consent__c=true,
            Study_Phone_Consent__c=true,
            Study_Direct_Mail_Consent__c=true
        );
        insert patientDelEnrollment;
        System.assert(patientDelEnrollment.id != null);
 
        
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
                Message__c = 'Message 1'
            ),
            new Motivational_Message__c(
                Number_of_Days_Active_after_Enrollment__c = 0,
                Clinical_Trial_Profile__c = ctp.Id,
                Message__c = 'Message 2'
            )
        };
        insert motivationalMessages;
        
        String message;
        System.runAs(testDataInstance.participantUser) {
            message = MotivationalMessagesRemote.getMotivationalMessage(
                CommunityService.USER_MODE_PARTICIPANT
            );
        }
        System.assertEquals('Message 2', message);
        
        con.userCommunityDelegateId__c = testDataInstance.participantUser.ContactId;
        update con;
         System.runAs(delegateUser) {
            message = MotivationalMessagesRemote.getMotivationalMessage(
                CommunityService.USER_MODE_PARTICIPANT
            );
        }
        
        System.runAs(testDataInstance.participantUser) {
            message = MotivationalMessagesRemote.getMotivationalMessage(
                CommunityService.USER_MODE_HCP
            );
            
            delete patientDelEnrollment;
            message = MotivationalMessagesRemote.getMotivationalMessage(
                CommunityService.USER_MODE_PARTICIPANT
            );
            
            delete peHistory;
            message = MotivationalMessagesRemote.getMotivationalMessage(
                CommunityService.USER_MODE_PARTICIPANT
            );
            
        }
        
        Test.stopTest();
        
    }
}