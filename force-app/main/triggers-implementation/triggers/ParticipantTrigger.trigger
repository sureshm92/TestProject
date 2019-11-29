/**
 * Created by Leonid Bartenev
 */

trigger ParticipantTrigger on Participant__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    //TriggerHandlerExecutor.execute(ParticipantTriggerHandler.CheckDuplicatesHandler.class);
    TriggerHandlerExecutor.execute(ParticipantTriggerHandler.CreateContactsForParticipantsHandler.class);
    TriggerHandlerExecutor.execute(ParticipantTriggerHandler.UpdatePEAndContactLastNameHandler.class);
    TriggerHandlerExecutor.execute(ParticipantTriggerHandler.ChangeUserEmailOnParticipantEmailChangeHandler.class);
    TriggerHandlerExecutor.execute(ParticipantTriggerHandler.PrepareCityStateFieldsHandler.class);
}