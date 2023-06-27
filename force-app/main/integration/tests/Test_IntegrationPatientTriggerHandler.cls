@IsTest
private class Test_IntegrationPatientTriggerHandler {

	@TestSetup
	static void setup() {
	
       
          Account acc = new Account();
		acc.Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME;
         byPassTriggersMethod();
		insert acc;
 		ParticipantEnrollmentFactory.createParticipantEnrollmentRecords('1','2','3');
        Participant_Enrollment__c pe = [ SELECT Id, Participant_Status__c,External_Key_WF__c,External_Key__c FROM Participant_Enrollment__c
										WHERE External_Key__c = '1~2~3']; 
        pe.External_Key_WF__c = pe.External_Key__c;
        update pe;
 		Test.startTest();
         Integration_Patient__c externalPatient = new Integration_Patient__c();
		externalPatient.External_ID__c = '1~2~3';
		externalPatient.Subject_Status__c = 'Completed';
		externalPatient.Subject_Date__c = Date.today().addDays(1);
		externalPatient.IsDeletedInSDH__c = 'N';
         insert externalPatient; 
         Test.stopTest();
	}
 
	@IsTest
	static void integration_Test(){ 
         Integration_Patient__c externalPatient = [SELECT ID,IsDeletedInSDH__c,Subject_Status__c,Subject_Date__c from Integration_Patient__c
                                                 where IsDeletedInSDH__c = 'N'];
 		Test.startTest(); 
       	externalPatient.IsDeletedInSDH__c = 'Y';
         byPassTriggersMethod();
        update externalPatient;
        System.assertEquals('Participation Complete', getPEStatus());
		Test.stopTest();
	}
    

	private static String getPEStatus(){
        
		Participant_Enrollment__c pe = [
			SELECT Id,
			Participant_Status__c
			FROM Participant_Enrollment__c
			WHERE External_Key__c = '1~2~3'
		];
        
		return pe.Participant_Status__c;
        
	}
    
    static void byPassTriggersMethod() {
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.prepareAdditionalFields.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.UpdateParticipantInitialVisit.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateMissingStatuses.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SendFOVtoAPI.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.UnenrollorCancelPer.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PETriggerHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
        );        
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.CreateNotificationHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ClinicalTrialProfileTriggerHandler.UpdateClinicalTrialProfile.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.CreateWelcomeToStudyAlertHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.CreateUserForDelegateContactHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.CreateUserForCCContactHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.UpdateParticipantAndUserEmailsOnEmailChangeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.UpdateParticipantDetailsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.UpdatePEAndContactLastNameHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateTriggerHandler.CreatePrimaryDelegateForMinor.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateTriggerHandler.CreateNewAssignmentNotification.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.UpdateContactDetailsFromParticipant.class
        );
         TriggerHandlerExecutor.bypassHandler(
            TherapeuticAreaPatientService.createTAP.class
        );
         TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.selectPEnrollmentsByIds.class
        );
         
    }
}