@IsTest
private class Test_IntegrationPatientTriggerHandler {

	@TestSetup
	static void setup() {
		TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SendDropOutEmailHandler.class);
		TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SetCurrentEnrollmentHandler.class);
		TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateUsersOrSendNotificationsHandler.class);
		TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class);
		TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateWelcomeToStudyAlertHandler.class);
		TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class);
		TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.CreateNotificationHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.ChangeUserEmailOnParticipantEmailChangeHandler.class);
		TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdateNameOnPE.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.UnenrollorCancelPer.class);
        

		Test.startTest();
		Account acc = new Account();
		acc.Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME;
		insert acc;
		ParticipantEnrollmentFactory.createParticipantEnrollmentRecords('1','2','3');
		Test.stopTest();
	}

	@IsTest
	static void integration_Test(){
		Integration_Patient__c externalPatient = new Integration_Patient__c();
		externalPatient.External_ID__c = '1~2~3';
		externalPatient.Subject_Status__c = 'Completed';
		externalPatient.Subject_Date__c = Date.today().addDays(1);
		externalPatient.IsDeletedInSDH__c = 'N';

		Test.startTest();
		insert externalPatient;
       	externalPatient.IsDeletedInSDH__c = 'Y';
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
}