/**
 * Created by Kryvolap on 10.12.2019.
 */


global without sharing class Batch_FixReferralAcceptedEPR implements Database.Batchable<SObject> {

    private String userId;
    private String peId;
    global Batch_FixReferralAcceptedEPR(String userId, String peId) {
        this.userId = userId;
        this.peId = peId;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(peId == '' || peId == null)
            return Database.getQueryLocator([
                    SELECT Id, NewStatus__c, ParticipantEnrollment__c
                    FROM Participant_Enrollment_Status_History__c
                    WHERE CreatedById = :userId AND CreatedDate = LAST_N_DAYS:7 AND Status__c = 'Referral Accepted'
            ]);
        return Database.getQueryLocator([
                SELECT Id, NewStatus__c, ParticipantEnrollment__c
                FROM Participant_Enrollment_Status_History__c
                WHERE CreatedById = :userId AND CreatedDate = LAST_N_DAYS:7 AND Status__c = 'Referral Accepted' AND ParticipantEnrollment__c = :peId
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Participant_Enrollment_Status_History__c> scope) {
        disableTriggers();
        Set<id> peIds = new Set<Id>();
        for (Participant_Enrollment_Status_History__c pesh : scope) {
            peIds.add(pesh.ParticipantEnrollment__c);
        }
        Map<Id, String> PEStatusesMap = new Map<Id, String>();
        for(Participant_Enrollment_Status_History__c pesh: [
                SELECT Id, NewStatus__c, Status__c, ParticipantEnrollment__c
                FROM Participant_Enrollment_Status_History__c
                WHERE CreatedById != :userId AND ParticipantEnrollment__c IN :peIds
                ORDER BY Date__c DESC
        ]){
            if(!PEStatusesMap.containsKey(pesh.ParticipantEnrollment__c)){
                PEStatusesMap.put(pesh.ParticipantEnrollment__c, (pesh.NewStatus__c == null || pesh.NewStatus__c == '')?pesh.Status__c:pesh.NewStatus__c);
            }
        }
        List<Participant_Enrollment__c> participantEnrollmentsToUpdate = new List<Participant_Enrollment__c>();
        for(Id peID : PEStatusesMap.keySet()){
            Participant_Enrollment__c pe = new Participant_Enrollment__c(
                    Id = peID,
                    Participant_Status__c = PEStatusesMap.get(peId)
            );
            participantEnrollmentsToUpdate.add(pe);
        }

        delete scope;
        update participantEnrollmentsToUpdate;
    }

    public static void disableTriggers() {
        TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateUsersOrSendNotificationsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SendCalloutOnEligibilityPassedHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SetParticipantStatusHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.UpdatePEHistoryOnAutoAcceptedHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateWelcomeToStudyAlertHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SendDropOutEmailHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SetCurrentEnrollmentHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR.class);
    }

    global void finish(Database.BatchableContext bc) {
    }

}