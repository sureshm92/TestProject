/**
 * Created by D.Yasinskyi on 26.04.2018
 */
trigger ParticipantEnrollmentTrigger on Participant_Enrollment__c (before insert, before update, after insert, after update) {
    TriggerHandlerExecutor.execute(PETriggerHandler.class);

    new ParticipantEnrollmentTriggerHandler().handle();
}