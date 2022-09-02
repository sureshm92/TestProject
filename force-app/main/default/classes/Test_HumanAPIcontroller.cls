@IsTest
public with sharing class Test_HumanAPIcontroller {
  @TestSetup
  static void init(){
     
      TestData.loadTestData(); 
  }

  @IsTest
  public static void getReportListTest() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new HumanAPIcontrollerMock());
    HumanAPIcontroller.ReportListWrapper wrap = new HumanAPIcontroller.ReportListWrapper();
    wrap = HumanAPIcontroller.getReportList('humanid');
    system.assertEquals('test_token', wrap.accessToken);
    Test.stopTest();
  }

  @IsTest
  public static void testRequestMedicalReocrds() {
    TestData testData = new TestData();
    byPassTriggersMethod();
    testData.pe.Email__c = null;
    testData.pe.Permit_Mail_Email_contact_for_this_study__c = true;
    update testData.pe;
   /* testData.participant.Adult__c = false;
    testData.participant.Email__c = null;
    update testData.participant; */
    //Participant__c par = [SELECT Id,Adult__c,Email__c FROM Participant__c WHERE Id=:testData.participant.Id];
    System.debug('per:'+testData.pe.Participant__c);
    System.debug('par:'+testData.participant.Id);
   /* Contact delegate = new Contact(
        FirstName = 'Patient',
        LastName = 'Delegate',
        Email = 'delegate@somemail.com',
        AccountId = testData.participant.Contact__r.AccountId,
        Current_Participant_Enrollment__c = testData.pe.Id,
        userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
        userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
        UserCommunityIsDelegate__c = true
    );
    insert delegate;    
    Participant__c p = new Participant__c(
        First_Name__c = 'Patient',
        Last_Name__c = 'Delegate',
        Email__c = 'delegate@somemail.com',
        Contact__c = delegate.Id
    );
    insert p;

    Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
        Contact__c = delegate.Id,
        Contact__r = delegate,
        Primary_Delegate__c = true,
        Participant__c = testData.participant.Id,
        Participant__r = testData.participant,
        Participant_Delegate__c = p.Id,
        Participant_Delegate__r = p
    );
    
    insert patientDelegate; */ 
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new HumanAPIcontrollerMock());
    String strMessage = HumanAPIcontroller.requestMedicalRecords(testData.pe.Id,testData.pe.Participant__c);
    System.assertEquals('true',strMessage);
    Test.stopTest();

  }
    
    @IsTest
  public static void testRequestMedicalReocrds_ExistingHumanId() {
    TestData testData = new TestData();
    byPassTriggersMethod();
    testData.pe.Email__c = null;
    testData.pe.Permit_Mail_Email_contact_for_this_study__c = true;
      testData.pe.Human_Id__c = 'Heighy9877129lkj';
    update testData.pe;
       Test.startTest();
    Test.setMock(HttpCalloutMock.class, new HumanAPIcontrollerMock());
    String strMessage = HumanAPIcontroller.requestMedicalRecords(testData.pe.Id,testData.pe.Participant__c);
    System.assertEquals('true',strMessage);
    Test.stopTest();

  }

  @isTest
  static void testGetRequestHistory(){
    TestData testData = new TestData();
    Test.startTest();
    HumanAPIcontroller.getRequestHistory(testData.pe.Id);
    Test.stopTest();

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
      ParticipantTriggerHandler.ChangeUserEmailOnParticipantEmailChangeHandler.class
    );
    TriggerHandlerExecutor.bypassHandler(
      ParticipantTriggerHandler.changeUserEmailOnParticipantEmailChange.class
    );
    TriggerHandlerExecutor.bypassHandler(
      ParticipantTriggerHandler.UpdateContactDetailsFromParticipant.class
    );
  }

  
}