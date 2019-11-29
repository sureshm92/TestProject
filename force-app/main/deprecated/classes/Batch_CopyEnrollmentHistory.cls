/**
 * Created by Igor Malyuta on 09.08.2019.
 */

public without sharing class Batch_CopyEnrollmentHistory implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT Id,
                        Status__c, (
                        SELECT Id,
                                Changed_Date__c,
                                Status__c,
                                PSE__c
                        FROM PSE_Status_Histories__r
                )
                FROM Participant_Study_Enrollment__c
        ]);
    }

    public void execute(Database.BatchableContext param1, List<Participant_Study_Enrollment__c> enrollments) {
        disableTriggers();

        List<Participant_Enrollment__c> participantEnrollments = new List<Participant_Enrollment__c>();
        List<Participant_Enrollment_Status_History__c> peHistories = new List<Participant_Enrollment_Status_History__c>();
        List<PSE_Status_History__c> pseStatusHistories = new List<PSE_Status_History__c>();

        List<Participant_Enrollment__c> peList = [
                SELECT Id, Participant_Study_Enrollment__c
                FROM Participant_Enrollment__c
                WHERE Participant_Study_Enrollment__c IN: enrollments
        ];
        Map<Id, Participant_Enrollment__c> peByPSEIdMap = new Map<Id, Participant_Enrollment__c>();
        for(Participant_Enrollment__c pe : peList) peByPSEIdMap.put(pe.Participant_Study_Enrollment__c, pe);
        
        for (Participant_Study_Enrollment__c pse : enrollments) {
            Participant_Enrollment__c pe = peByPSEIdMap.get(pse.Id);
            if(pe == null) continue;
            pe.Participant_Status__c = pse.Status__c;
            participantEnrollments.add(pe);

            for (PSE_Status_History__c pseHistory : pse.PSE_Status_Histories__r) {
                pseStatusHistories.add(pseHistory);
                peHistories.add(new Participant_Enrollment_Status_History__c(
                        Date__c = pseHistory.Changed_Date__c,
                        Status__c = pseHistory.Status__c,
                        ParticipantEnrollment__c = pe.Id
                ));
            }
        }

        update participantEnrollments;
        if (!peHistories.isEmpty()) insert peHistories;

        if(!pseStatusHistories.isEmpty()) delete pseStatusHistories;
        delete enrollments;
    }

    public static void disableTriggers() {
        TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateUsersOrSendNotificationsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SendCalloutOnEligibilityPassedHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateWelcomeToStudyAlertHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SendDropOutEmailHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SetCurrentEnrollmentHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR.class);
    }

    public void finish(Database.BatchableContext param1) {
    }

    public static void run() {
        Database.executeBatch(new Batch_CopyEnrollmentHistory());
    }
}