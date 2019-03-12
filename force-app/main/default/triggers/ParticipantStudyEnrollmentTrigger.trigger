/**
 * Created by Yehor Dobrovolskyi
 */
trigger ParticipantStudyEnrollmentTrigger on Participant_Study_Enrollment__c (before insert, before update, before delete, after insert, after update) {

    System.debug('ParticipantStudyEnrollmentTrigger:');
    TriggerHandlerExecutor.execute(ParticipantStudyEnrollmentTriggerHandler.class);
}