/**
 * Created by Kryvolap
 */

trigger ParticipantEnrollmentStatusHistoryTrigger on Participant_Enrollment_Status_History__c (after insert) {
    ParticipantEnrollmentSHTriggerHandler.sendToEPR();
}