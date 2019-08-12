/**
 * Created by Kryvolap
 */

trigger ParticipantEnrollmentStatusHistoryTrigger on Participant_Enrollment_Status_History__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerExecutor.execute(ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR.class);
}